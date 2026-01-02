-- 1. Function to get quiz content securely
DROP FUNCTION IF EXISTS public.lms_quiz_get_content(uuid, uuid);
DROP FUNCTION IF EXISTS public.lms_quiz_get_content(uuid, uuid, uuid);

CREATE OR REPLACE FUNCTION public.lms_quiz_get_content(
    p_item_id uuid,
    p_user_id uuid,
    p_id_empresa uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_result json;
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

    SELECT json_build_object(
        'id', i.id,
        'titulo', i.titulo,
        'rich_text', i.rich_text,
        'tempo_questionario', i.tempo_questionario,
        'data_entrega_limite', i.data_entrega_limite,
        'perguntas', (
            SELECT json_agg(
                json_build_object(
                    'id', p.id,
                    'tipo', p.tipo,
                    'enunciado', p.enunciado,
                    'caminho_imagem', p.caminho_imagem,
                    'obrigatoria', p.obrigatoria,
                    'ordem', p.ordem,
                    -- Return Options WITHOUT 'correta' field for security
                    'opcoes', (
                        SELECT json_agg(
                            json_build_object(
                                'id', rp.id,
                                'texto', rp.texto,
                                'ordem', rp.ordem
                            ) ORDER BY rp.ordem
                        )
                        FROM public.lms_resposta_possivel rp
                        WHERE rp.id_pergunta = p.id
                    ),
                    -- User's existing answer for this question
                    'resposta_usuario', (
                        SELECT json_build_object(
                            'texto_resposta', r.resposta,
                            'id_resposta_possivel', r.id_resposta_possivel
                        )
                        FROM public.lms_resposta r
                        WHERE r.id_pergunta = p.id
                        AND r.id_user = v_real_user_id
                    )
                ) ORDER BY p.ordem
            )
            FROM public.lms_pergunta p
            WHERE p.id_item_conteudo = i.id
        ),
        'submissao', (
            SELECT json_build_object(
                'status', CASE 
                    WHEN s.data_envio IS NOT NULL THEN 'concluido' 
                    ELSE 'em_andamento' 
                END,
                'data_inicio', s.criado_em,
                'data_envio', s.data_envio,
                'nota', s.nota
            )
            FROM public.lms_submissao s
            WHERE s.id_item_conteudo = i.id
            AND s.id_aluno = v_real_user_id
        )
    )
    INTO v_result
    FROM public.lms_item_conteudo i
    WHERE i.id = p_item_id;

    RETURN v_result;
END;
$function$;

-- 2. Function to start quiz
DROP FUNCTION IF EXISTS public.lms_quiz_start(uuid, uuid);
DROP FUNCTION IF EXISTS public.lms_quiz_start(uuid, uuid, uuid);

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
            criado_em
        ) VALUES (
            p_item_id,
            v_real_user_id,
            now()
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
    END IF;

    RETURN json_build_object(
        'id_submissao', v_submissao_id,
        'status', v_status,
        'data_inicio', v_data_inicio
    );
END;
$function$;

-- 3. Function to upsert answer
DROP FUNCTION IF EXISTS public.lms_resposta_upsert(uuid, uuid, uuid, uuid, text);
DROP FUNCTION IF EXISTS public.lms_resposta_upsert(uuid, uuid, uuid, uuid, text, uuid);

CREATE OR REPLACE FUNCTION public.lms_resposta_upsert(
    p_user_id uuid,
    p_id_item uuid,
    p_id_pergunta uuid,
    p_id_resposta_possivel uuid DEFAULT NULL,
    p_texto_resposta text DEFAULT NULL,
    p_id_empresa uuid DEFAULT NULL -- Made optional/last to avoid signature break initially, but logically required
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
    -- Fallback for safety if p_id_empresa is null (shouldn't be with updated frontend)
    IF p_id_empresa IS NOT NULL THEN
        SELECT id INTO v_real_user_id FROM public.user_expandido WHERE user_id = p_user_id AND id_empresa = p_id_empresa LIMIT 1;
    ELSE
         -- Try loose lookup, unsafe
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

    IF v_sub_id IS NULL THEN
        RAISE EXCEPTION 'Não há submissão ativa para este usuário neste item.';
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

-- 4. Function to submit quiz
DROP FUNCTION IF EXISTS public.lms_quiz_submit(uuid, uuid);
DROP FUNCTION IF EXISTS public.lms_quiz_submit(uuid, uuid, uuid);

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

    -- Close Submission
    UPDATE public.lms_submissao
    SET data_envio = now(),
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
