-- Migration to update lms_avaliacoes_get and create lms_get_submission_details for detailed quiz views

-- 1. Update lms_avaliacoes_get to return text_answer and file_path
DROP FUNCTION IF EXISTS public.lms_avaliacoes_get;
CREATE OR REPLACE FUNCTION public.lms_avaliacoes_get(
    p_id_empresa uuid,
    p_user_id uuid DEFAULT auth.uid(),
    p_filtro_status text DEFAULT NULL,
    p_filtro_turma_id uuid DEFAULT NULL,
    p_filtro_aluno_id uuid DEFAULT NULL,
    p_filtro_escopo text DEFAULT NULL
)
RETURNS TABLE (
    id_submissao uuid,
    id_aluno uuid,
    aluno_nome text,
    aluno_avatar text,
    id_turma uuid,
    turma_nome text,
    id_conteudo uuid,
    conteudo_titulo text,
    escopo text,
    id_item uuid,
    item_titulo text,
    item_tipo text,
    data_envio timestamp with time zone,
    status text,
    nota numeric,
    pontuacao_maxima numeric,
    comentario_professor text,
    texto_resposta text,         -- NEW
    caminho_arquivo text,        -- NEW
    data_inicio timestamp with time zone -- NEW
)
LANGUAGE plpgsql
SET search_path TO 'public'
AS $$
DECLARE
    v_user_expandido_id uuid;
    v_papel_id uuid;
    v_admin_role uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
    v_prof_role uuid := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
    v_aluno_role uuid := 'b7f53d6e-70b5-453b-b564-728aeb4635d5';
BEGIN
    SELECT ue.id, ue.papel_id
    INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido ue
    WHERE ue.user_id = p_user_id AND ue.id_empresa = p_id_empresa;

    RETURN QUERY
    SELECT DISTINCT ON (s.id)
        s.id AS id_submissao,
        ue_aluno.id AS id_aluno,
        ue_aluno.nome_completo AS aluno_nome,
        NULL::text AS aluno_avatar,
        t.id AS id_turma,
        (t.ano || ' - ' || c_turma.nome)::text AS turma_nome,
        c.id AS id_conteudo,
        c.titulo AS conteudo_titulo,
        c.escopo,
        ic.id AS id_item,
        ic.titulo AS item_titulo,
        ic.tipo::text AS item_tipo,
        s.data_envio,
        s.status,
        s.nota,
        ic.pontuacao_maxima,
        s.comentario_professor,
        s.texto_resposta,       -- Added
        s.caminho_arquivo,      -- Added
        s.data_inicio           -- Added
    FROM public.lms_submissao s
    JOIN public.lms_item_conteudo ic ON ic.id = s.id_item_conteudo
    JOIN public.lms_conteudo c ON c.id = ic.id_lms_conteudo
    JOIN public.user_expandido ue_aluno ON ue_aluno.id = s.id_aluno
    LEFT JOIN public.matriculas m ON m.id_aluno = s.id_aluno AND m.status = 'ativa'
    LEFT JOIN public.matricula_turma mt ON mt.id_matricula = m.id AND mt.status = 'ativa'
    LEFT JOIN public.turmas t ON t.id = mt.id_turma
    LEFT JOIN public.classe c_turma ON c_turma.id = t.id_classe
    WHERE 
        c.id_empresa = p_id_empresa
        AND (p_filtro_status IS NULL OR 
             (p_filtro_status = 'pendente' AND s.nota IS NULL) OR 
             (p_filtro_status = 'avaliado' AND s.nota IS NOT NULL) OR
             (s.status = p_filtro_status)
            )
        AND (p_filtro_turma_id IS NULL OR mt.id_turma = p_filtro_turma_id)
        AND (p_filtro_aluno_id IS NULL OR s.id_aluno = p_filtro_aluno_id)
        AND (p_filtro_escopo IS NULL OR c.escopo = p_filtro_escopo)
        AND (
            (v_papel_id = v_admin_role)
            OR
            (v_papel_id = v_aluno_role AND s.id_aluno = v_user_expandido_id)
            OR
            (
                v_papel_id = v_prof_role AND (
                    (ic.criado_por = v_user_expandido_id)
                    OR
                    (c.escopo = 'Global')
                    OR
                    (c.escopo = 'Turma' AND c.id_turma IN (
                        SELECT at.id_turma 
                        FROM public.atrib_atribuicao_turmas at
                        WHERE at.id_professor = v_user_expandido_id
                        AND (at.data_fim IS NULL OR at.data_fim >= CURRENT_DATE)
                        UNION
                        SELECT ac.id_turma 
                        FROM public.atrib_atribuicao_componentes ac
                        WHERE ac.id_professor = v_user_expandido_id
                        AND (ac.data_fim IS NULL OR ac.data_fim >= CURRENT_DATE)
                    ))
                    OR
                    (c.escopo = 'Aluno' AND EXISTS (
                        SELECT 1
                        FROM public.matricula_turma mt_aluno
                        JOIN public.matriculas m_aluno ON m_aluno.id = mt_aluno.id_matricula
                        WHERE m_aluno.id_aluno = s.id_aluno
                        AND m_aluno.status = 'ativa'
                        AND mt_aluno.status = 'ativa'
                        AND mt_aluno.id_turma IN (
                            SELECT at.id_turma 
                            FROM public.atrib_atribuicao_turmas at
                            WHERE at.id_professor = v_user_expandido_id
                            AND (at.data_fim IS NULL OR at.data_fim >= CURRENT_DATE)
                            UNION
                            SELECT ac.id_turma 
                            FROM public.atrib_atribuicao_componentes ac
                            WHERE ac.id_professor = v_user_expandido_id
                            AND (ac.data_fim IS NULL OR ac.data_fim >= CURRENT_DATE)
                        )
                    ))
                )
            )
        )
    ORDER BY s.id, s.data_envio DESC;
END;
$$;

ALTER FUNCTION public.lms_avaliacoes_get(uuid, uuid, text, uuid, uuid, text) OWNER TO postgres;


-- 2. Create lms_get_submission_details for deep quiz fetching
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
    SELECT s.*, ic.titulo as item_titulo, ic.tipo as item_tipo, ic.pontuacao_maxima, ue.nome_completo as aluno_nome
    INTO v_submission
    FROM public.lms_submissao s
    JOIN public.lms_item_conteudo ic ON ic.id = s.id_item_conteudo
    JOIN public.user_expandido ue ON ue.id = s.id_aluno
    WHERE s.id = p_id_submissao AND s.id_empresa = p_id_empresa;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    -- If it's a Quiz (Questionário), fetch questions and answers
    IF v_submission.item_tipo = 'Questionário' OR v_submission.item_tipo = 'QUESTIONARIO' THEN
        
        -- Aggregate questions with their options and user's answer
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
                            'correta', o.correta -- Only return correct flag if needed for teacher view (YES)
                        ) ORDER BY o.ordem
                    )
                    FROM public.lms_opcoes o
                    WHERE o.id_pergunta = p.id
                ),
                'resposta_usuario', (
                    SELECT jsonb_build_object(
                        'id_resposta_possivel', ru.id_resposta_possivel, -- ID of selected option
                        'texto_resposta', ru.resposta,       -- Text answer or fallback
                        'correta', (
                             -- Check correctness
                             CASE 
                                WHEN p.tipo = 'Múltipla Escolha' THEN 
                                    EXISTS (SELECT 1 FROM public.lms_opcoes op WHERE op.id = ru.id_resposta_possivel AND op.correta = true)
                                ELSE NULL -- Essay requires manual grading usually
                             END
                        )
                    )
                    FROM public.respostas_user ru
                    WHERE ru.id_pergunta = p.id 
                    AND ru.id_user = v_submission.id_aluno 
                    AND ru.criado_em >= v_submission.data_inicio -- Ensure answer belongs to this attempt timeline (approx)
                    -- Note: id_submissao is not on respostas_user, so we rely on user + item context. 
                    -- Ideally respostas_user should have id_submissao, but for now we infer or take latest.
                    -- LIMIT 1 DESC created_at
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
