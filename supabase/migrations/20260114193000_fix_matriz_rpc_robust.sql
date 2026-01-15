-- Migration: Fix Matriz Upsert User ID (Robust Version)
-- Date: 2026-01-14

-- Update 'upsert' RPC to extract id_usuario from p_data and auto-resolve Auth ID
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
    v_id_usuario uuid;
BEGIN
    -- Extract Vars
    v_id_ano_etapa := (p_data->>'id_ano_etapa')::uuid;
    v_id_turma := (p_data->>'id_turma')::uuid;
    v_dia := (p_data->>'dia_semana')::integer;
    v_aula := (p_data->>'aula')::integer;
    v_componente := (p_data->>'id_componente')::uuid;
    
    -- Extract User ID and resolve Auth ID -> Profile ID
    DECLARE
        v_input_user_id uuid;
    BEGIN
        v_input_user_id := (p_data->>'id_usuario')::uuid;
        
        -- 1. Is it a valid Profile ID?
        IF EXISTS (SELECT 1 FROM public.user_expandido WHERE id = v_input_user_id) THEN
            v_id_usuario := v_input_user_id;
        
        -- 2. Is it a valid Auth ID?
        ELSIF EXISTS (SELECT 1 FROM public.user_expandido WHERE user_id = v_input_user_id) THEN
            SELECT id INTO v_id_usuario FROM public.user_expandido WHERE user_id = v_input_user_id;
            
        -- 3. Is it NULL? Try current Auth User
        ELSIF v_input_user_id IS NULL THEN
            SELECT id INTO v_id_usuario FROM public.user_expandido WHERE user_id = auth.uid();
            
        ELSE
            -- Input was provided but didn't match Profile or Auth. Fallback to current Auth User.
            SELECT id INTO v_id_usuario FROM public.user_expandido WHERE user_id = auth.uid();
        END IF;
    END;

    -- Validations
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
    END IF;

    IF v_escopo = 'ano_etapa' THEN
        IF NOT EXISTS (SELECT 1 FROM public.ano_etapa WHERE id = v_id_ano_etapa AND id_empresa = p_id_empresa) THEN
             RETURN jsonb_build_object('status', 'error', 'message', 'Ano/Etapa inválido.');
        END IF;
    END IF;

    -- Upsert Logic
    IF v_escopo = 'ano_etapa' THEN
        INSERT INTO public.mtz_matriz_curricular (
            id_empresa, id_ano_etapa, id_turma, escopo,
            ano, dia_semana, aula, id_componente,
            criado_por, modificado_por, modificado_em
        ) VALUES (
            p_id_empresa, v_id_ano_etapa, NULL, 'ano_etapa',
            (p_data->>'ano')::integer, v_dia, v_aula, v_componente,
            v_id_usuario, v_id_usuario, now()
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
            v_id_usuario, v_id_usuario, now()
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
