-- Force Re-Creation of lms_get_submission_details to ensure Type Cast is applied
-- dropping explicitly first

DROP FUNCTION IF EXISTS public.lms_get_submission_details(uuid, uuid);

CREATE OR REPLACE FUNCTION public.lms_get_submission_details(
    p_id_submissao uuid,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path TO 'public'
AS $$
DECLARE
    v_submission record;
    v_questions jsonb;
BEGIN
    -- Fetch Submission Basic Info
    -- Force cast ic.tipo to text to allow flexible comparison (CRITICAL FIX for Enum Error)
    SELECT s.*, ic.titulo as item_titulo, ic.tipo::text as item_tipo, ic.pontuacao_maxima, ue.nome_completo as aluno_nome
    INTO v_submission
    FROM public.lms_submissao s
    JOIN public.lms_item_conteudo ic ON ic.id = s.id_item_conteudo
    JOIN public.user_expandido ue ON ue.id = s.id_aluno
    WHERE s.id = p_id_submissao AND s.id_empresa = p_id_empresa;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    -- If it's a Quiz (Questionário), fetch questions and answers
    -- Now v_submission.item_tipo is TEXT, so 'QUESTIONARIO' comparison is safe
    IF v_submission.item_tipo = 'Questionário' OR v_submission.item_tipo = 'QUESTIONARIO' THEN
        
        SELECT jsonb_agg(
            jsonb_build_object(
                'id_pergunta', p.id,
                'enunciado', p.enunciado,
                'tipo_pergunta', p.tipo,
                'valor', p.valor,
                'ordem', p.ordem,
                'opcoes', (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id', o.id,
                            'texto', o.texto,
                            'correta', o.correta
                        ) ORDER BY o.ordem
                    )
                    FROM public.lms_opcoes o
                    WHERE o.id_pergunta = p.id
                ),
                'resposta_usuario', (
                    SELECT jsonb_build_object(
                        'id_resposta_possivel', ru.id_resposta_possivel,
                        'texto_resposta', ru.resposta,
                        'correta', (
                             CASE 
                                WHEN p.tipo = 'Múltipla Escolha' THEN 
                                    EXISTS (SELECT 1 FROM public.lms_opcoes op WHERE op.id = ru.id_resposta_possivel AND op.correta = true)
                                ELSE NULL
                             END
                        )
                    )
                    FROM public.respostas_user ru
                    WHERE ru.id_pergunta = p.id 
                    AND ru.id_user = v_submission.id_aluno 
                    AND ru.criado_em >= v_submission.data_inicio
                    ORDER BY ru.criado_em DESC
                    LIMIT 1
                )
            ) ORDER BY p.ordem
        )
        INTO v_questions
        FROM public.lms_perguntas p
        WHERE p.id_item = v_submission.id_item_conteudo
        AND p.soft_delete = false;
        
    END IF;

    RETURN jsonb_build_object(
        'submission', row_to_json(v_submission),
        'questions', COALESCE(v_questions, '[]'::jsonb)
    );
END;
$$;

ALTER FUNCTION public.lms_get_submission_details(uuid, uuid) OWNER TO postgres;
