CREATE OR REPLACE FUNCTION public.lms_quiz_submit_batch(
    p_user_id uuid,
    p_item_id uuid,
    p_respostas json,
    p_id_empresa uuid DEFAULT NULL::uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_resposta json;
    v_id_pergunta uuid;
    v_id_resposta_possivel uuid;
    v_texto_resposta text;
    v_submit_result json;
BEGIN
    -- Iterate through the answers array
    IF p_respostas IS NOT NULL THEN
        FOR v_resposta IN SELECT * FROM json_array_elements(p_respostas)
        LOOP
            v_id_pergunta := (v_resposta->>'id_pergunta')::uuid;
            
            -- Handle possible nulls for different answer types
            IF (v_resposta->>'id_resposta_possivel') IS NOT NULL THEN
                v_id_resposta_possivel := (v_resposta->>'id_resposta_possivel')::uuid;
            ELSE
                v_id_resposta_possivel := NULL;
            END IF;

            v_texto_resposta := v_resposta->>'texto_resposta';

            -- Call the existing upsert function for each answer
            PERFORM public.lms_resposta_upsert(
                p_user_id := p_user_id,
                p_id_item := p_item_id,
                p_id_pergunta := v_id_pergunta,
                p_id_resposta_possivel := v_id_resposta_possivel,
                p_texto_resposta := v_texto_resposta,
                p_id_empresa := p_id_empresa
            );
        END LOOP;
    END IF;

    -- After saving all answers, submit the quiz
    v_submit_result := public.lms_quiz_submit(
        p_user_id := p_user_id,
        p_item_id := p_item_id
    );

    RETURN v_submit_result;
END;
$function$;
