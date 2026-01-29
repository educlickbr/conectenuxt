CREATE OR REPLACE FUNCTION public.lms_task_submit(
    p_item_id uuid,
    p_user_id uuid,
    p_texto text DEFAULT NULL,
    p_arquivo text DEFAULT NULL,
    p_id_empresa uuid DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_sub_id uuid;
    v_real_user_id uuid;
BEGIN
    -- 0. Lookup Real User ID
    IF p_id_empresa IS NOT NULL THEN
        SELECT id INTO v_real_user_id FROM public.user_expandido WHERE user_id = p_user_id AND id_empresa = p_id_empresa LIMIT 1;
    ELSE
         SELECT id INTO v_real_user_id FROM public.user_expandido WHERE user_id = p_user_id LIMIT 1;
    END IF;

    IF v_real_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado na tabela user_expandido.';
    END IF;

    -- 1. Upsert Submission
    -- Handles both creating a new submission or updating an existing one (e.g. draft or resubmission)
    INSERT INTO public.lms_submissao (
        id_item_conteudo, 
        id_aluno, 
        texto_resposta, 
        caminho_arquivo, 
        data_envio, 
        status, 
        criado_em, 
        id_empresa
    )
    VALUES (
        p_item_id, 
        v_real_user_id, 
        p_texto, 
        p_arquivo, 
        now(), -- data_envio set implies submitted
        'concluido', 
        now(), 
        p_id_empresa
    )
    ON CONFLICT (id_item_conteudo, id_aluno) 
    DO UPDATE SET 
        texto_resposta = EXCLUDED.texto_resposta,
        caminho_arquivo = EXCLUDED.caminho_arquivo,
        data_envio = now(),
        status = 'concluido',
        modificado_em = now(),
        id_empresa = COALESCE(EXCLUDED.id_empresa, public.lms_submissao.id_empresa);

    RETURN json_build_object(
        'status', 'success',
        'message', 'Tarefa enviada com sucesso.'
    );
END;
$function$;
