-- Drop existing functions to avoid signature ambiguity
DROP FUNCTION IF EXISTS public.lms_quiz_submit_batch;
DROP FUNCTION IF EXISTS public.lms_task_submit;

-- Recreate lms_quiz_submit_batch with default p_user_id
CREATE OR REPLACE FUNCTION public.lms_quiz_submit_batch(
    p_item_id uuid,
    p_respostas json,
    p_user_id uuid DEFAULT auth.uid(),
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

-- Recreate lms_task_submit with default p_user_id
CREATE OR REPLACE FUNCTION public.lms_task_submit(
    p_item_id uuid,
    p_texto text DEFAULT NULL::text,
    p_arquivo text DEFAULT NULL::text,
    p_user_id uuid DEFAULT auth.uid(),
    p_id_empresa uuid DEFAULT NULL::uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_submissao_id uuid;
    v_status text;
    v_aluno_id uuid;
BEGIN
    -- Get User ID from User Expandido
    SELECT id INTO v_aluno_id FROM public.user_expandido WHERE user_id = p_user_id;

    IF v_aluno_id IS NULL THEN
         RETURN json_build_object('status', 'error', 'message', 'Aluno não encontrado.');
    END IF;

    -- Upsert Submission
    INSERT INTO public.lms_submissao (
        id_item_conteudo,
        id_aluno,
        texto_resposta,
        caminho_arquivo,
        status,
        id_empresa,
        modificado_em
    ) VALUES (
        p_item_id,
        v_aluno_id,
        p_texto,
        p_arquivo,
        'em_andamento', -- Default status, maybe 'concluido' depending on logic? Assuming 'em_andamento' or 'entregue'?
        p_id_empresa,
        now()
    )
    ON CONFLICT (id_item_conteudo, id_aluno) 
    DO UPDATE SET
        texto_resposta = EXCLUDED.texto_resposta,
        caminho_arquivo = EXCLUDED.caminho_arquivo,
        modificado_em = now(),
        status = 'em_andamento'; -- Reset status on update

    -- Return success
    RETURN json_build_object('status', 'success', 'message', 'Tarefa enviada com sucesso.');
END;
$function$;
