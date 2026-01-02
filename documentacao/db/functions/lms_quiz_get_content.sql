DROP FUNCTION public.lms_quiz_get_content;
CREATE OR REPLACE FUNCTION public.lms_quiz_get_content(
    p_item_id uuid,
    p_user_id uuid,
    p_id_empresa uuid DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_result json;
    v_real_user_id uuid;
BEGIN
    -- Lookup Real User ID
    IF p_id_empresa IS NOT NULL THEN
        SELECT id INTO v_real_user_id FROM public.user_expandido WHERE user_id = p_user_id AND id_empresa = p_id_empresa LIMIT 1;
    ELSE
         SELECT id INTO v_real_user_id FROM public.user_expandido WHERE user_id = p_user_id LIMIT 1;
    END IF;

    IF v_real_user_id IS NULL THEN
        -- Fallback or Error? Ideally error if we can't identify user in context
        RAISE EXCEPTION 'Usuário não encontrado na tabela user_expandido.';
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
