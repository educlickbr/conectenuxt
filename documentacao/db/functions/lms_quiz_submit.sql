DROP FUNCTION public.lms_quiz_submit;
CREATE OR REPLACE FUNCTION public.lms_quiz_submit(
    p_user_id uuid,
    p_item_id uuid,
    p_id_empresa uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_pontuacao_total numeric := 0;
    v_nota_aluno numeric := 0;
    v_perg record;
    v_resp record;
    v_item_pontuacao_maxima numeric;
    v_real_user_id uuid;
BEGIN
    -- Lookup Real User ID
    SELECT id INTO v_real_user_id 
    FROM public.user_expandido 
    WHERE user_id = p_user_id 
    AND id_empresa = p_id_empresa 
    LIMIT 1;

    IF v_real_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado na tabela user_expandido para esta empresa.';
    END IF;

    -- Get Max Score of the Item
    SELECT pontuacao_maxima INTO v_item_pontuacao_maxima
    FROM public.lms_item_conteudo
    WHERE id = p_item_id;

    -- Calculate Score
    DECLARE
        v_total_questions_gradable integer := 0;
        v_correct_answers integer := 0;
    BEGIN
        FOR v_perg IN SELECT * FROM public.lms_pergunta WHERE id_item_conteudo = p_item_id AND tipo = 'Múltipla Escolha'
        LOOP
            v_total_questions_gradable := v_total_questions_gradable + 1;
            
            -- Check user answer
            SELECT * INTO v_resp 
            FROM public.lms_resposta 
            WHERE id_pergunta = v_perg.id AND id_user = v_real_user_id;
            
            IF v_resp.id_resposta_possivel IS NOT NULL THEN
                -- Check if it is correct
                PERFORM 1 FROM public.lms_resposta_possivel 
                WHERE id = v_resp.id_resposta_possivel AND correta = true;
                
                IF FOUND THEN
                    v_correct_answers := v_correct_answers + 1;
                END IF;
            END IF;
        END LOOP;

        IF v_total_questions_gradable > 0 THEN
             v_nota_aluno := (v_correct_answers::numeric / v_total_questions_gradable::numeric) * COALESCE(v_item_pontuacao_maxima, 10);
        ELSE
             v_nota_aluno := 0; 
        END IF;
    END;

    -- Close Submission (Update data_envio and status)
    UPDATE public.lms_submissao
    SET data_envio = now(),
        status = 'concluido', -- Ensure status is updated for simpler frontend check
        nota = v_nota_aluno
    WHERE id_item_conteudo = p_item_id
    AND id_aluno = v_real_user_id;

    RETURN json_build_object(
        'status', 'concluido',
        'nota', v_nota_aluno,
        'maxima', v_item_pontuacao_maxima
    );
END;
$function$;
