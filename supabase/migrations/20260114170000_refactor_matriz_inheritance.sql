-- Migration: Refactor Matriz Curricular for Inheritance (Scope Enum)
-- Date: 2026-01-14

-- 1. Create Enum 'mtz_escopo_enum'
DO $$ BEGIN
    CREATE TYPE public.mtz_escopo_enum AS ENUM ('ano_etapa', 'turma');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Alter Table 'mtz_matriz_curricular'
-- Add columns and modify constraints
ALTER TABLE public.mtz_matriz_curricular
    ADD COLUMN IF NOT EXISTS id_ano_etapa uuid REFERENCES public.ano_etapa(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS escopo public.mtz_escopo_enum, -- Initially nullable
    ALTER COLUMN id_turma DROP NOT NULL;

-- Update existing records to strict scope 'turma' since they were created with id_turma
UPDATE public.mtz_matriz_curricular SET escopo = 'turma' WHERE escopo IS NULL AND id_turma IS NOT NULL;
-- If any have null id_turma (unlikely per old schema), set to ano_etapa?
UPDATE public.mtz_matriz_curricular SET escopo = 'ano_etapa' WHERE escopo IS NULL;

-- Now enforce Not Null and Default
ALTER TABLE public.mtz_matriz_curricular
    ALTER COLUMN escopo SET DEFAULT 'ano_etapa',
    ALTER COLUMN escopo SET NOT NULL;

-- Add constraint to ensure correctness of scope vs foreign keys
ALTER TABLE public.mtz_matriz_curricular
    DROP CONSTRAINT IF EXISTS check_escopo_turma;

ALTER TABLE public.mtz_matriz_curricular
    ADD CONSTRAINT check_escopo_turma CHECK (
        (escopo = 'turma' AND id_turma IS NOT NULL) OR
        (escopo = 'ano_etapa' AND id_turma IS NULL)
    );

-- 3. Adjust Indexes for Unique Constraints (Partial Indexes)
-- Drop old strict index
DROP INDEX IF EXISTS public.idx_mtz_matriz_unique_slot;

-- Create Scope-based Unique Indexes
-- A slot (day, aula) can exist ONCE per Scope for a given entity (Ano or Turma)
CREATE UNIQUE INDEX IF NOT EXISTS idx_mtz_matriz_ano_scope 
    ON public.mtz_matriz_curricular (id_ano_etapa, dia_semana, aula) 
    WHERE escopo = 'ano_etapa';

CREATE UNIQUE INDEX IF NOT EXISTS idx_mtz_matriz_turma_scope 
    ON public.mtz_matriz_curricular (id_turma, dia_semana, aula) 
    WHERE escopo = 'turma';


-- 4. Update 'upsert' RPC
CREATE OR REPLACE FUNCTION public.mtz_matriz_curricular_upsert(
    p_id_empresa uuid,
    p_data jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_id uuid;
    v_record record;
    v_escopo public.mtz_escopo_enum;
    v_id_ano_etapa uuid;
    v_id_turma uuid;
    v_dia integer;
    v_aula integer;
    v_componente uuid;
BEGIN
    -- Extract Vars
    v_id_ano_etapa := (p_data->>'id_ano_etapa')::uuid;
    v_id_turma := (p_data->>'id_turma')::uuid;
    v_dia := (p_data->>'dia_semana')::integer;
    v_aula := (p_data->>'aula')::integer;
    v_componente := (p_data->>'id_componente')::uuid;

    -- Determine Scope
    IF v_id_turma IS NOT NULL THEN
        v_escopo := 'turma';
    ELSE
        v_escopo := 'ano_etapa';
    END IF;

    -- Validations
    IF v_escopo = 'turma' THEN
        IF NOT EXISTS (SELECT 1 FROM public.turmas WHERE id = v_id_turma AND id_empresa = p_id_empresa) THEN
            RETURN jsonb_build_object('status', 'error', 'message', 'Turma inválida.');
        END IF;
        -- Also validate Ano Etapa matches Turma? Or just assume frontend ensures it.
    END IF;

    IF v_escopo = 'ano_etapa' THEN
        IF NOT EXISTS (SELECT 1 FROM public.ano_etapa WHERE id = v_id_ano_etapa AND id_empresa = p_id_empresa) THEN
             RETURN jsonb_build_object('status', 'error', 'message', 'Ano/Etapa inválido.');
        END IF;
    END IF;

    -- Upsert Logic
    -- We need to handle the ON CONFLICT separately because the unique constraint is partial and different for each scope.
    
    IF v_escopo = 'ano_etapa' THEN
        INSERT INTO public.mtz_matriz_curricular (
            id_empresa, id_ano_etapa, id_turma, escopo,
            ano, dia_semana, aula, id_componente,
            criado_por, modificado_por, modificado_em
        ) VALUES (
            p_id_empresa, v_id_ano_etapa, NULL, 'ano_etapa',
            (p_data->>'ano')::integer, v_dia, v_aula, v_componente,
            auth.uid(), auth.uid(), now()
        )
        ON CONFLICT (id_ano_etapa, dia_semana, aula) WHERE escopo = 'ano_etapa'
        DO UPDATE SET
            id_componente = EXCLUDED.id_componente,
            modificado_por = EXCLUDED.modificado_por,
            modificado_em = EXCLUDED.modificado_em
        RETURNING * INTO v_record;
    
    ELSE -- Scope: Turma
        INSERT INTO public.mtz_matriz_curricular (
            id_empresa, id_ano_etapa, id_turma, escopo,
            ano, dia_semana, aula, id_componente,
            criado_por, modificado_por, modificado_em
        ) VALUES (
            p_id_empresa, v_id_ano_etapa, v_id_turma, 'turma',
            (p_data->>'ano')::integer, v_dia, v_aula, v_componente,
            auth.uid(), auth.uid(), now()
        )
        ON CONFLICT (id_turma, dia_semana, aula) WHERE escopo = 'turma'
        DO UPDATE SET
            id_componente = EXCLUDED.id_componente,
            modificado_por = EXCLUDED.modificado_por,
            modificado_em = EXCLUDED.modificado_em
        RETURNING * INTO v_record;
    END IF;

    RETURN jsonb_build_object('status', 'success', 'data', row_to_json(v_record));

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$$;


-- 5. RPC: Get Merged Matrix (Inheritance Logic)
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
            'id', base.id, -- Valid ID (either general or specific)
            'dia_semana', base.dia_semana,
            'aula', base.aula,
            'id_componente', base.id_componente,
            'componente_nome', c.nome,
            'componente_cor', c.cor,
            'escopo', base.escopo,
            'is_inherited', (base.escopo = 'ano_etapa' AND p_id_turma IS NOT NULL) -- Flag if it's inherited from Ano Etapa while viewing a Turma
        ) ORDER BY base.dia_semana, base.aula
    ) INTO v_items
    FROM (
        -- Logic: 
        -- 1. Select all Specific (Turma) items
        -- 2. Select all General (Ano) items that do NOT conflict with Specific ones
        
        -- OR using DISTINCT ON (dia, aula) with ORDER BY precedence priority?
        -- Yes: ORDER BY case escopo when 'turma' then 1 else 2 end.
        
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

    RETURN jsonb_build_object('status', 'success', 'items', COALESCE(v_items, '[]'::jsonb));
END;
$$;


-- Grant Permissions
GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_upsert(uuid, jsonb) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_get_merged(uuid, uuid, uuid) TO authenticated, service_role;
