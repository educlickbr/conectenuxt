-- include previous content...

-- 5. NEW Function to reset quiz (for retake)
DROP FUNCTION IF EXISTS public.lms_quiz_reset(uuid, uuid, uuid);
CREATE OR REPLACE FUNCTION public.lms_quiz_reset(
    p_user_id uuid,
    p_item_id uuid,
    p_id_empresa uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_real_user_id uuid;
BEGIN
    SELECT id INTO v_real_user_id 
    FROM public.user_expandido 
    WHERE user_id = p_user_id 
    AND id_empresa = p_id_empresa 
    LIMIT 1;

    IF v_real_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado.';
    END IF;

    -- Delete answers
    DELETE FROM public.lms_resposta
    WHERE id_user = v_real_user_id
    AND id_pergunta IN (
        SELECT id FROM public.lms_pergunta WHERE id_item_conteudo = p_item_id
    );

    -- Delete submission
    DELETE FROM public.lms_submissao
    WHERE id_item_conteudo = p_item_id
    AND id_aluno = v_real_user_id;

END;
$function$;
