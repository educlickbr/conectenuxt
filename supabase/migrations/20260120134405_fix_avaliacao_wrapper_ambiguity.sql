-- Fix: Drop ambiguous function signatures before re-creating
-- Removing both (uuid, jsonb) and (jsonb, uuid) variants to be safe

DROP FUNCTION IF EXISTS public.avaliacao_aluno_registrar_completa_wrapper(uuid, jsonb);
DROP FUNCTION IF EXISTS public.avaliacao_aluno_registrar_completa_wrapper(jsonb, uuid);

CREATE OR REPLACE FUNCTION public.avaliacao_aluno_registrar_completa_wrapper(
    p_id_empresa uuid,
    p_data jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    v_item jsonb;
    v_id_turma uuid;
    v_id_aluno uuid;
    v_id_modelo uuid;
BEGIN
    -- Extract Context
    v_id_turma := (p_data->>'id_turma')::uuid;
    v_id_aluno := (p_data->>'id_aluno')::uuid;
    v_id_modelo := (p_data->>'id_modelo_avaliacao')::uuid;

    IF v_id_turma IS NULL OR v_id_aluno IS NULL OR v_id_modelo IS NULL THEN
        RAISE EXCEPTION 'Dados incompletos para registro de avaliação.';
    END IF;

    -- Safety Check: Ensure 'respostas' is a valid array
    IF p_data->'respostas' IS NOT NULL AND jsonb_typeof(p_data->'respostas') = 'array' THEN
        -- Loop through responses
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_data->'respostas')
        LOOP
            INSERT INTO public.avaliacao_resposta (
                id_empresa,
                id_turma,
                id_aluno,
                id_modelo,
                id_item,
                conceito,
                modificado_em
            ) VALUES (
                p_id_empresa,
                v_id_turma,
                v_id_aluno,
                v_id_modelo,
                (v_item->>'id_item_avaliacao')::uuid,
                (v_item->>'conceito')::numeric,
                now()
            )
            ON CONFLICT (id_turma, id_aluno, id_item)
            DO UPDATE SET
                conceito = EXCLUDED.conceito,
                modificado_em = now();
        END LOOP;
    END IF;

    RETURN jsonb_build_object('success', true, 'message', 'Notas salvas com sucesso.');
END;
$function$;
