DROP FUNCTION public.lms_quiz_start;
CREATE OR REPLACE FUNCTION public.lms_quiz_start(
    p_user_id uuid,
    p_item_id uuid,
    p_id_empresa uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_submissao_id uuid;
    v_status text;
    v_data_inicio timestamp with time zone;
    v_real_user_id uuid;
BEGIN
    SELECT id INTO v_real_user_id 
    FROM public.user_expandido 
    WHERE user_id = p_user_id 
    AND id_empresa = p_id_empresa 
    LIMIT 1;

    IF v_real_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado na tabela user_expandido para esta empresa.';
    END IF;

    -- Check if submission exists
    SELECT id, criado_em, CASE WHEN data_envio IS NOT NULL THEN 'concluido' ELSE 'em_andamento' END
    INTO v_submissao_id, v_data_inicio, v_status
    FROM public.lms_submissao
    WHERE id_item_conteudo = p_item_id
    AND id_aluno = v_real_user_id;

    IF v_submissao_id IS NULL THEN
        -- Create new submission
        INSERT INTO public.lms_submissao (
            id_item_conteudo,
            id_aluno,
            criado_em,
            id_empresa
        ) VALUES (
            p_item_id,
            v_real_user_id,
            now(),
            p_id_empresa
        )
        RETURNING id, criado_em INTO v_submissao_id, v_data_inicio;
        
        v_status := 'created';
    ELSE
        -- Already exists
        IF v_status = 'concluido' THEN
             v_status := 'completed_previously';
        ELSE
             v_status := 'resumed';
        END IF;

        -- Optional: Update id_empresa if missing
        UPDATE public.lms_submissao SET id_empresa = p_id_empresa WHERE id = v_submissao_id AND id_empresa IS NULL;
    END IF;

    RETURN json_build_object(
        'id_submissao', v_submissao_id,
        'status', v_status,
        'data_inicio', v_data_inicio
    );
END;
$function$;
