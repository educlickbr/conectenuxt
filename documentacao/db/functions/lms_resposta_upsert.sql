DROP FUNCTION IF EXISTS public.lms_resposta_upsert(uuid, uuid, uuid, uuid, text);
DROP FUNCTION IF EXISTS public.lms_resposta_upsert(uuid, uuid, uuid, uuid, text, uuid);

CREATE OR REPLACE FUNCTION public.lms_resposta_upsert(
    p_user_id uuid,
    p_id_item uuid,
    p_id_pergunta uuid,
    p_id_resposta_possivel uuid DEFAULT NULL,
    p_texto_resposta text DEFAULT NULL,
    p_id_empresa uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_sub_id uuid;
    v_tipo_pergunta lms_tipo_pergunta;
    v_real_user_id uuid;
BEGIN
    -- 0. Lookup Real User ID (User Expandido)
    IF p_id_empresa IS NOT NULL THEN
        SELECT id INTO v_real_user_id FROM public.user_expandido WHERE user_id = p_user_id AND id_empresa = p_id_empresa LIMIT 1;
    ELSE
         SELECT id INTO v_real_user_id FROM public.user_expandido WHERE user_id = p_user_id LIMIT 1;
    END IF;

    IF v_real_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado na tabela user_expandido.';
    END IF;

    -- 1. Validate Submission exists and is open
    SELECT id INTO v_sub_id
    FROM public.lms_submissao
    WHERE id_item_conteudo = p_id_item
    AND id_aluno = v_real_user_id
    AND data_envio IS NULL;

    -- If no active submission, CREATE ONE naturally (Auto-recovery)
    IF v_sub_id IS NULL THEN
         INSERT INTO public.lms_submissao (id_item_conteudo, id_aluno, criado_em, id_empresa)
         VALUES (p_id_item, v_real_user_id, now(), p_id_empresa)
         ON CONFLICT (id_item_conteudo, id_aluno) 
         DO UPDATE SET data_envio = NULL, criado_em = now(), id_empresa = EXCLUDED.id_empresa -- Revive/Reset existing submission
         RETURNING id INTO v_sub_id;
    END IF;

    -- 2. Get Question Type to validate input
    SELECT tipo INTO v_tipo_pergunta
    FROM public.lms_pergunta
    WHERE id = p_id_pergunta;

    -- 3. Upsert Answer
    INSERT INTO public.lms_resposta (
        id_user,
        id_pergunta,
        tipo_pergunta,
        resposta,
        id_resposta_possivel,
        modificado_em
    ) VALUES (
        v_real_user_id,
        p_id_pergunta,
        v_tipo_pergunta,
        p_texto_resposta,
        p_id_resposta_possivel,
        now()
    )
    ON CONFLICT (id_user, id_pergunta) DO UPDATE SET
        resposta = EXCLUDED.resposta,
        id_resposta_possivel = EXCLUDED.id_resposta_possivel,
        modificado_em = now();
END;
$function$;