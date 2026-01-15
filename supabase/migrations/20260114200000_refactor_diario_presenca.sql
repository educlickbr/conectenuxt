-- Migration: Refactor Diario Presenca and Matriz Inheritance Helper
-- Date: 2026-01-14

-- 1. Create Helper Function to get Merged Rows (Internal use)
-- Returns the effective schedule rows (Specific overriding General)
CREATE OR REPLACE FUNCTION public._mtz_get_merged_rows(
    p_id_empresa uuid,
    p_id_ano_etapa uuid,
    p_id_turma uuid DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    dia_semana integer,
    aula integer,
    id_componente uuid,
    escopo public.mtz_escopo_enum,
    componente_nome text,
    componente_cor text
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        base.id,
        base.dia_semana,
        base.aula,
        base.id_componente,
        base.escopo,
        c.nome as componente_nome,
        c.cor as componente_cor
    FROM (
        SELECT DISTINCT ON (dia_semana, aula)
            m.id, m.dia_semana, m.aula, m.id_componente, m.escopo
        FROM public.mtz_matriz_curricular m
        WHERE m.id_empresa = p_id_empresa
          AND (
              -- Match General Scope
              (m.id_ano_etapa = p_id_ano_etapa AND m.escopo = 'ano_etapa')
              OR
              -- Match Specific Scope (if Turma provided)
              (p_id_turma IS NOT NULL AND m.id_turma = p_id_turma AND m.escopo = 'turma')
          )
        ORDER BY dia_semana, aula, 
                 CASE WHEN m.escopo = 'turma' THEN 1 ELSE 2 END -- Priority: Turma (1) > Ano (2)
    ) base
    JOIN public.componente c ON c.uuid = base.id_componente;
$$;

-- 2. Update existing RPC to use the Helper
CREATE OR REPLACE FUNCTION public.mtz_matriz_curricular_get_merged(
    p_id_empresa uuid,
    p_id_ano_etapa uuid,
    p_id_turma uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_items jsonb;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', m.id, 
            'dia_semana', m.dia_semana,
            'aula', m.aula,
            'id_componente', m.id_componente,
            'componente_nome', m.componente_nome,
            'componente_cor', m.componente_cor,
            'escopo', m.escopo,
            'is_inherited', (m.escopo = 'ano_etapa' AND p_id_turma IS NOT NULL)
        ) ORDER BY m.dia_semana, m.aula
    ) INTO v_items
    FROM public._mtz_get_merged_rows(p_id_empresa, p_id_ano_etapa, p_id_turma) m;

    RETURN jsonb_build_object('status', 'success', 'items', COALESCE(v_items, '[]'::jsonb));
END;
$$;


-- 3. Adjust Diario Presenca Table (Safe Alter)
DO $$
BEGIN
    -- Ensure 'escopo' column exists if we want to use it for explicit filtering, 
    -- though 'id_componente IS NULL' implies 'diario' (Geral).
    -- User provided schema does not have 'escopo'. Let's add it for consistency if desired, 
    -- or we can skip and just rely on id_componente.
    -- Given the constraint logic "coalesce id_componente", we can infer scope.
    -- But explicit is better. Let's add it.
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'diario_presenca' AND column_name = 'escopo') THEN
        ALTER TABLE public.diario_presenca ADD COLUMN escopo text CHECK (escopo IN ('diario', 'componente'));
        
        -- Backfill existing data defaults
        UPDATE public.diario_presenca SET escopo = 'componente' WHERE id_componente IS NOT NULL;
        UPDATE public.diario_presenca SET escopo = 'diario' WHERE id_componente IS NULL;
    END IF;

    -- Ensure Index exists (User provided Create Index IF NOT EXISTS, we can just reinforce or skip)
    -- The unique index provided by user: id_matricula, id_turma, data, COALESCE(id_componente...)
    -- This handles the uniqueness perfectly for both null and not null.
    -- If we keep it, we don't need changes there.
END $$;

-- Validation: Ensure the Unique Index matches User's definition (Re-apply if needed to be sure)
DROP INDEX IF EXISTS idx_diario_presenca_unique;
CREATE UNIQUE INDEX IF NOT EXISTS idx_diario_presenca_unique ON public.diario_presenca (
  id_matricula,
  id_turma,
  data,
  COALESCE(id_componente, '00000000-0000-0000-0000-000000000000'::uuid)
);


-- 4. RPC: Get Components for the Day (for the Frontend Scheduler)
CREATE OR REPLACE FUNCTION public.diario_get_componentes_dia(
    p_id_empresa uuid,
    p_id_turma uuid,
    p_data date
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_dia_semana integer;
    v_id_ano_etapa uuid;
    v_items jsonb;
BEGIN
    -- 1. Calculate Day of Week (Postgres ISO: 1=Monday, 7=Sunday). Matriz uses 1=Mon..5=Fri usually.
    v_dia_semana := extract(isodow from p_data)::integer;

    -- 2. Get Ano Etapa from Turma
    SELECT id_ano_etapa INTO v_id_ano_etapa FROM public.turmas WHERE id = p_id_turma;
    
    IF v_id_ano_etapa IS NULL THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Turma sem Ano/Etapa vinculado.');
    END IF;

    -- 3. Call Helper to get merged rows, filter by day, unique by component
    SELECT jsonb_agg(DISTINCT jsonb_build_object(
        'id_componente', m.id_componente,
        'nome', m.componente_nome,
        'cor', m.componente_cor
    )) INTO v_items
    FROM public._mtz_get_merged_rows(p_id_empresa, v_id_ano_etapa, p_id_turma) m
    WHERE m.dia_semana = v_dia_semana;

    RETURN jsonb_build_object(
        'status', 'success', 
        'dia_semana', v_dia_semana,
        'items', COALESCE(v_items, '[]'::jsonb)
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.diario_get_componentes_dia(uuid, uuid, date) TO authenticated, service_role;
