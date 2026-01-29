CREATE OR REPLACE FUNCTION public.lms_quiz_submit(
    p_item_id uuid,
    p_user_id uuid DEFAULT auth.uid()
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_aluno_id uuid;
    v_submissao_id uuid;
    v_total_questions integer;
    v_answered_questions integer;
    v_score numeric(5,2) := 0;
    v_max_score numeric(5,2) := 100; -- Assuming 100 or fetch from item?
    v_correct_answers integer := 0;
    v_is_auto_gradable boolean := true; -- Check if all questions are multiple choice types
BEGIN
    -- Get User ID (Aluno)
    SELECT id INTO v_aluno_id FROM public.user_expandido WHERE user_id = p_user_id;
    
    IF v_aluno_id IS NULL THEN
        RETURN json_build_object('status', 'error', 'message', 'Aluno não encontrado.');
    END IF;

    -- Upsert Submission Record (Initialize if not exists, or update timestamp)
    INSERT INTO public.lms_submissao (
        id_item_conteudo,
        id_aluno,
        data_envio,
        status,
        modificado_em
    ) VALUES (
        p_item_id,
        v_aluno_id,
        now(),
        'pendente', -- Default to pending grading
        now()
    )
    ON CONFLICT (id_item_conteudo, id_aluno)
    DO UPDATE SET
        data_envio = now(),
        status = 'pendente',
        modificado_em = now()
    RETURNING id INTO v_submissao_id;

    -- TODO: Implement Auto-Grading Logic here if needed.
    -- For now, we trust lms_resposta_upsert has saved the answers.
    -- We could count correct answers if we join with lms_question_options where correta = true.

    -- Attempt Auto-Grading (Simplified)
    -- Calculate score based on multiple choice questions
    -- SELECT ...
    
    -- For now, just return success.
    RETURN json_build_object(
        'status', 'success', 
        'message', 'Questionário enviado com sucesso.',
        'id_submissao', v_submissao_id
    );
END;
$function$;
