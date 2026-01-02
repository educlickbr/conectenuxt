-- 1. Function to Get Content List (Modules only)
-- Removed SECURITY DEFINER to respect RLS
DROP FUNCTION public.lms_consumo_get;
CREATE OR REPLACE FUNCTION public.lms_consumo_get(
    p_id_empresa uuid,
    p_user_id uuid
)
RETURNS TABLE (
    id uuid,
    titulo text,
    descricao text,
    escopo text, 
    ordem integer
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
    -- Get User Info
    -- RLS should allow user to see their own record in user_expandido
    SELECT ue.id, ue.papel_id
    INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido ue
    WHERE ue.user_id = p_user_id AND ue.id_empresa = p_id_empresa;

    RETURN QUERY
    SELECT 
        c.id,
        c.titulo,
        c.descricao,
        c.escopo,
        c.ordem
    FROM public.lms_conteudo c
    WHERE 
        c.id_empresa = p_id_empresa
        AND (
            -- Admin
            (v_papel_id = v_admin_role)
            OR
            -- Global Content
            (c.escopo = 'Global')
            OR
            -- Student Access
            (
                v_papel_id = v_aluno_role AND (
                    (c.escopo = 'Turma' AND c.id_turma IN (
                        SELECT m.id_turma FROM public.matriculas m
                        WHERE m.id_aluno = v_user_expandido_id 
                        AND m.status = 'ativa'
                    ))
                    OR
                    (c.escopo = 'Aluno' AND c.id_aluno = v_user_expandido_id)
                )
            )
            OR
            -- Professor Access
            (
                v_papel_id = v_prof_role AND (
                    (c.escopo = 'Turma' AND c.id_turma IN (
                        SELECT tpa.id_turma FROM public.turma_professor_atribuicao tpa
                        WHERE tpa.id_professor = v_user_expandido_id
                        AND (tpa.data_fim IS NULL OR tpa.data_fim >= CURRENT_DATE)
                    ))
                )
            )
        )
    ORDER BY c.ordem ASC;
END;
$$;
DROP FUNCTION lms_itens_get(uuid,uuid,uuid);
-- 2. Function to Get Items for a specific Content (Lazy Load)
-- Removed SECURITY DEFINER to respect RLS
CREATE OR REPLACE FUNCTION public.lms_itens_get(
    p_id_empresa uuid,
    p_user_id uuid,
    p_conteudo_id uuid
)
RETURNS TABLE (
    id uuid,
    titulo text,
    tipo lms_tipo_item,
    rich_text text,
    url_externa text,
    caminho_arquivo text,
    video_link text,
    duracao_minutos integer,
    pontuacao_maxima numeric,
    data_disponivel timestamp with time zone,
    data_entrega_limite timestamp with time zone,
    submissao jsonb,
    livro jsonb
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
    SELECT 
        ic.id,
        ic.titulo,
        ic.tipo,
        ic.rich_text,
        ic.url_externa,
        ic.caminho_arquivo,
        ic.video_link,
        ic.duracao_minutos,
        ic.pontuacao_maxima,
        ic.data_disponivel,
        ic.data_entrega_limite,
        (
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
        ) as submissao,
        (
            CASE WHEN ic.id_bbtk_edicao IS NOT NULL THEN
                (SELECT jsonb_build_object(
                    'uuid', e.uuid,
                    'titulo', o.titulo_principal,
                    'capa', e.arquivo_capa,
                    'arquivo_pdf', e.arquivo_pdf,
                    'autores', (
                        SELECT string_agg(a.nome_completo, ', ')
                        FROM public.bbtk_juncao_edicao_autoria jea
                        JOIN public.bbtk_dim_autoria a ON a.uuid = jea.autoria_uuid
                        WHERE jea.edicao_uuid = e.uuid
                    )
                )
                FROM public.bbtk_edicao e
                JOIN public.bbtk_obra o ON o.uuid = e.obra_uuid
                WHERE e.uuid = ic.id_bbtk_edicao)
            ELSE NULL END
        ) as livro
    FROM public.lms_item_conteudo ic
    JOIN public.lms_conteudo c ON c.id = ic.id_lms_conteudo
    WHERE 
        ic.id_lms_conteudo = p_conteudo_id
        AND c.id_empresa = p_id_empresa
        AND (
            (v_papel_id = v_admin_role)
            OR (c.escopo = 'Global')
            OR (
                v_papel_id = v_aluno_role AND (
                    (c.escopo = 'Turma' AND c.id_turma IN (
                        SELECT m.id_turma FROM public.matriculas m
                        WHERE m.id_aluno = v_user_expandido_id AND m.status = 'ativa'
                    ))
                    OR (c.escopo = 'Aluno' AND c.id_aluno = v_user_expandido_id)
                )
            )
            OR (
                v_papel_id = v_prof_role AND (
                    (c.escopo = 'Turma' AND c.id_turma IN (
                        SELECT tpa.id_turma FROM public.turma_professor_atribuicao tpa
                        WHERE tpa.id_professor = v_user_expandido_id AND (tpa.data_fim IS NULL OR tpa.data_fim >= CURRENT_DATE)
                    ))
                )
            )
        )
    ORDER BY ic.ordem ASC;
END;
$$;
