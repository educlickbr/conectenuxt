-- Migration: 20260111190000_alter_matriz_for_turma.sql

-- 1. Alter Table mtz_matriz_curricular
ALTER TABLE public.mtz_matriz_curricular
    DROP COLUMN IF EXISTS id_ano_etapa CASCADE, -- cascade might remove foreign keys
    ADD COLUMN IF NOT EXISTS id_turma uuid NOT NULL REFERENCES public.turmas(id) ON DELETE CASCADE;

-- Remove singular unique constraints if any were based on ano_etapa, add new one for Turma
-- Note: 'aula' is the slot number. 'dia_semana' is 1-7.
CREATE UNIQUE INDEX IF NOT EXISTS idx_mtz_matriz_unique_slot 
    ON public.mtz_matriz_curricular (id_turma, dia_semana, aula);

CREATE INDEX IF NOT EXISTS idx_mtz_matriz_id_turma ON public.mtz_matriz_curricular(id_turma);

-- 2. RPC: Upsert (Insert or Update a slot)
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
BEGIN
    -- Validations
    IF NOT EXISTS (SELECT 1 FROM public.turmas WHERE id = (p_data->>'id_turma')::uuid AND id_empresa = p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Turma inválida ou não pertence à empresa.');
    END IF;

    INSERT INTO public.mtz_matriz_curricular (
        id_empresa,
        id_turma,
        ano,
        dia_semana,
        aula,
        id_componente,
        criado_por,
        modificado_por,
        modificado_em
    ) VALUES (
        p_id_empresa,
        (p_data->>'id_turma')::uuid,
        (p_data->>'ano')::integer,
        (p_data->>'dia_semana')::integer,
        (p_data->>'aula')::integer,
        (p_data->>'id_componente')::uuid,
        auth.uid(),
        auth.uid(),
        now()
    )
    ON CONFLICT (id_turma, dia_semana, aula) DO UPDATE SET
        id_componente = EXCLUDED.id_componente,
        modificado_por = EXCLUDED.modificado_por,
        modificado_em = EXCLUDED.modificado_em
    RETURNING * INTO v_record;

    RETURN jsonb_build_object('status', 'success', 'data', row_to_json(v_record));
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$$;

-- 3. RPC: Delete (Remove a slot)
CREATE OR REPLACE FUNCTION public.mtz_matriz_curricular_delete(
    p_id_empresa uuid,
    p_id uuid -- ID of the row
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    DELETE FROM public.mtz_matriz_curricular
    WHERE id = p_id AND id_empresa = p_id_empresa;

    IF FOUND THEN
        RETURN jsonb_build_object('status', 'success');
    ELSE
        RETURN jsonb_build_object('status', 'error', 'message', 'Item não encontrado.');
    END IF;
END;
$$;

-- 4. RPC: Get by Turma
CREATE OR REPLACE FUNCTION public.mtz_matriz_curricular_get_by_turma(
    p_id_empresa uuid,
    p_id_turma uuid
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
            'componente_nome', c.nome,
            'componente_cor', c.cor
        ) 
    ) INTO v_items
    FROM public.mtz_matriz_curricular m
    JOIN public.componente c ON c.uuid = m.id_componente
    WHERE m.id_empresa = p_id_empresa 
      AND m.id_turma = p_id_turma;

    RETURN jsonb_build_object('status', 'success', 'items', COALESCE(v_items, '[]'::jsonb));
END;
$$;

-- 5. RPC: Turmas Get Simple (For Selector)
CREATE OR REPLACE FUNCTION public.turmas_get_simple(
    p_id_empresa uuid,
    p_id_escola uuid DEFAULT NULL,
    p_id_ano_etapa uuid DEFAULT NULL
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
            'id', t.id,
            'nome', ae.nome || ' - ' || c.nome, -- Construct a name: Ano - Classe (e.g. 1º Ano - A)
            'ano', t.ano,
            'id_ano_etapa', t.id_ano_etapa,
            'id_escola', t.id_escola
        ) ORDER BY t.ano, ae.nome, c.nome
    ) INTO v_items
    FROM public.turmas t
    JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
    JOIN public.classe c ON c.id = t.id_classe
    WHERE t.id_empresa = p_id_empresa
      AND (p_id_escola IS NULL OR t.id_escola = p_id_escola)
      AND (p_id_ano_etapa IS NULL OR t.id_ano_etapa = p_id_ano_etapa);

    RETURN jsonb_build_object('status', 'success', 'items', COALESCE(v_items, '[]'::jsonb));
END;
$$;

-- Grant Permissions
GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_upsert(uuid, jsonb) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_delete(uuid, uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_get_by_turma(uuid, uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.turmas_get_simple(uuid, uuid, uuid) TO authenticated, service_role;
