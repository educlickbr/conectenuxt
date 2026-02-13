-- 1. Alter Tables
ALTER TABLE IF EXISTS public.lms_item_conteudo 
ADD COLUMN IF NOT EXISTS duracao_minutos integer,
ADD COLUMN IF NOT EXISTS tentativas_permitidas integer DEFAULT 1;

ALTER TABLE IF EXISTS public.lms_submissao 
ADD COLUMN IF NOT EXISTS data_inicio timestamp with time zone,
ADD COLUMN IF NOT EXISTS status text DEFAULT 'em_andamento'; 
-- status: 'em_andamento', 'concluido'

-- 2. Function to Get Content
CREATE OR REPLACE FUNCTION public.lms_consumo_get(
    p_user_id uuid
)
RETURNS TABLE (
    id uuid,
    titulo text,
    descricao text,
    escopo text, -- 'Global', 'Turma', 'Aluno'
    items jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_user_expandido_id uuid;
    v_papel_id uuid;
    v_admin_role uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
    v_prof_role uuid := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
    v_aluno_role uuid := 'b7f53d6e-70b5-453b-b564-728aeb4635d5';
BEGIN
    -- Get User Info
    SELECT id, papel_id INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido
    WHERE user_id = p_user_id;

    RETURN QUERY
    SELECT 
        c.id,
        c.titulo,
        c.descricao,
        c.escopo,
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'id', ic.id,
                    'titulo', ic.titulo,
                    'tipo', ic.tipo,
                    'rich_text', ic.rich_text,
                    'url_externa', ic.url_externa,
                    'caminho_arquivo', ic.caminho_arquivo,
                    'video_link', ic.video_link,
                    'duracao_minutos', ic.duracao_minutos,
                    'pontuacao_maxima', ic.pontuacao_maxima,
                    'submissao', (
                        SELECT jsonb_build_object(
                            'id', s.id,
                            'data_inicio', s.data_inicio,
                            'data_envio', s.data_envio,
                            'status', s.status,
                            'nota', s.nota
                        )
                        FROM public.lms_submissao s
                        WHERE s.id_item_conteudo = ic.id AND s.id_aluno = v_user_expandido_id
                        LIMIT 1
                    ),
                    -- If it's a book (bbtk_edicao), include cover
                    'livro', (
                        CASE WHEN ic.id_bbtk_edicao IS NOT NULL THEN
                           (SELECT jsonb_build_object(
                               'uuid', e.uuid,
                               'titulo', o.titulo_principal,
                               'capa', e.arquivo_capa,
                               'arquivo_pdf', e.arquivo_conteudo
                           )
                           FROM public.bbtk_edicao e
                           JOIN public.bbtk_obra o ON o.id = e.id_obra
                           WHERE e.uuid = ic.id_bbtk_edicao)
                        ELSE NULL END
                    )
                ) ORDER BY ic.ordem
            ) FILTER (WHERE ic.id IS NOT NULL),
            '[]'::jsonb
        ) as items
    FROM public.lms_conteudo c
    LEFT JOIN public.lms_item_conteudo ic ON ic.id_lms_conteudo = c.id
    WHERE 
        -- Admin sees everything
        (v_papel_id = v_admin_role)
        OR
        -- Global
        (c.escopo = 'Global')
        OR
        -- Student: Enrolled in Turma or targeted individually
        (
            v_papel_id = v_aluno_role AND (
                (c.escopo = 'Turma' AND c.id_turma IN (
                    SELECT id_turma FROM public.matriculas 
                    WHERE id_aluno = v_user_expandido_id 
                    AND status = 'ativa'
                ))
                OR
                (c.escopo = 'Aluno' AND c.id_aluno = v_user_expandido_id)
            )
        )
        OR
        -- Professor: Assigned to Turma
        (
            v_papel_id = v_prof_role AND (
                (c.escopo = 'Turma' AND c.id_turma IN (
                    SELECT id_turma FROM public.turma_professor_atribuicao 
                    WHERE id_professor = v_user_expandido_id
                    AND (data_fim IS NULL OR data_fim >= CURRENT_DATE)
                ))
            )
        )
    GROUP BY c.id, c.titulo, c.descricao, c.escopo, c.ordem
    ORDER BY c.ordem ASC;
END;
$$;

-- 3. Function to Start Quiz (Create Submission with Start Time)
CREATE OR REPLACE FUNCTION public.lms_quiz_start(
    p_user_id uuid,
    p_item_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_user_expandido_id uuid;
    v_submissao_id uuid;
    v_existing_status text;
    v_duracao int;
    v_data_inicio timestamptz;
BEGIN
    SELECT id INTO v_user_expandido_id FROM public.user_expandido WHERE user_id = p_user_id;

    -- Check if submission exists
    SELECT id, status, data_inicio INTO v_submissao_id, v_existing_status, v_data_inicio
    FROM public.lms_submissao
    WHERE id_item_conteudo = p_item_id AND id_aluno = v_user_expandido_id;

    IF v_submissao_id IS NOT NULL THEN
        RETURN jsonb_build_object('status', 'exists', 'id', v_submissao_id, 'data_inicio', v_data_inicio);
    END IF;

    -- Create new submission
    INSERT INTO public.lms_submissao (
        id_item_conteudo,
        id_aluno,
        data_inicio,
        status
    ) VALUES (
        p_item_id,
        v_user_expandido_id,
        now(),
        'em_andamento'
    ) RETURNING id, data_inicio INTO v_submissao_id, v_data_inicio;

    RETURN jsonb_build_object('status', 'created', 'id', v_submissao_id, 'data_inicio', v_data_inicio);
END;
$$;
