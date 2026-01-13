-- Migration: 20260112100000_fix_matriz_rpc_security.sql
-- Description: Fixes duplicate RPC issues and Foreign Key violations in Matriz Curricular functions

-- 1. RPC: Upsert (Fix FK Violation by using id_usuario from payload)
DROP FUNCTION IF EXISTS public.mtz_matriz_curricular_upsert(uuid, jsonb);

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
    v_user_id uuid;
BEGIN
    v_user_id := (p_data->>'id_usuario')::uuid;

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
        v_user_id,
        v_user_id,
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

-- 2. RPC: Delete (Ensuring correct parameter signature and drop)
DROP FUNCTION IF EXISTS public.mtz_matriz_curricular_delete(uuid, uuid);

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

-- Grant Permissions
GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_upsert(uuid, jsonb) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_delete(uuid, uuid) TO authenticated, service_role;
