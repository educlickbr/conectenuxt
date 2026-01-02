DROP FUNCTION IF EXISTS public.lms_conteudo_get_paginado;
CREATE OR REPLACE FUNCTION public.lms_conteudo_get_paginado(
    p_id_empresa uuid,
    p_pagina integer,
    p_limite_itens_pagina integer,
    p_termo_busca text DEFAULT NULL,
    p_id_turma uuid DEFAULT NULL,
    p_id_aluno uuid DEFAULT NULL,
    p_id_meta_turma uuid DEFAULT NULL,
    p_somente_ativos boolean DEFAULT true
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_offset integer;
    v_total integer;
    v_result json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- 1. Contar total de registros (para paginação)
    SELECT COUNT(*)
    INTO v_total
    FROM public.lms_conteudo c
    WHERE c.id_empresa = p_id_empresa
    AND (p_termo_busca IS NULL OR c.titulo ILIKE '%' || p_termo_busca || '%')
    AND (
        -- Filtro de Visibilidade (Ativo/Inativo)
        (p_somente_ativos IS FALSE OR (c.data_disponivel IS NULL OR c.data_disponivel <= now()) AND c.visivel_para_alunos IS TRUE)
    )
    AND (
        -- Lógica de "Feed Inteligente": Combina (OR) os contextos passados
        -- Se nenhum contexto for passado, retorna itens Globais por padrão ou nada? 
        -- Vamos assumir que retorna tudo se nenhum ID for passado (Admin view) ou restringe se IDs forem passados.
        (p_id_turma IS NULL AND p_id_aluno IS NULL AND p_id_meta_turma IS NULL)
        OR
        (p_id_turma IS NOT NULL AND c.id_turma = p_id_turma)
        OR
        (p_id_aluno IS NOT NULL AND c.id_aluno = p_id_aluno)
        OR
        (p_id_meta_turma IS NOT NULL AND c.id_meta_turma = p_id_meta_turma)
        OR
        (c.escopo = 'Global')
    );

    -- 2. Buscar dados paginados
    SELECT json_agg(t) INTO v_result FROM (
        SELECT 
            c.*,
            (ae.nome || ' ' || cl.nome) as nome_turma,
            u.nome_completo as nome_criador,
            
            -- Subquery para buscar os itens (materiais, tarefas, etc) deste conteúdo
            (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', i.id,
                        'tipo', i.tipo,
                        'titulo', i.titulo,
                        'ordem', i.ordem,
                        'caminho_arquivo', i.caminho_arquivo,
                        'url_externa', i.url_externa,
                        'video_link', i.video_link,
                        'rich_text', i.rich_text,
                        'pontuacao_maxima', i.pontuacao_maxima,
                        'tempo_questionario', i.tempo_questionario,
                        'id_bbtk_edicao', i.id_bbtk_edicao,
                        -- Se for livro, traz infos extras
                        'livro_detalhes', CASE WHEN i.id_bbtk_edicao IS NOT NULL THEN
                             (SELECT jsonb_build_object(
                                 'titulo_obra', o.titulo_principal,
                                 'capa', e.arquivo_capa
                             ) 
                             FROM bbtk_edicao e 
                             JOIN bbtk_obra o ON o.uuid = e.obra_uuid 
                             WHERE e.uuid = i.id_bbtk_edicao)
                             ELSE NULL END
                    ) ORDER BY i.ordem
                )
                FROM public.lms_item_conteudo i
                WHERE i.id_lms_conteudo = c.id
            ) as itens

        FROM public.lms_conteudo c
        LEFT JOIN public.turmas t ON t.id = c.id_turma
        LEFT JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        LEFT JOIN public.classe cl ON cl.id = t.id_classe
        LEFT JOIN public.user_expandido u ON u.id = c.criado_por
        WHERE c.id_empresa = p_id_empresa
        AND (p_termo_busca IS NULL OR c.titulo ILIKE '%' || p_termo_busca || '%')
        AND (
            (p_somente_ativos IS FALSE OR (c.data_disponivel IS NULL OR c.data_disponivel <= now()) AND c.visivel_para_alunos IS TRUE)
        )
        AND (
            (p_id_turma IS NULL AND p_id_aluno IS NULL AND p_id_meta_turma IS NULL)
            OR
            (p_id_turma IS NOT NULL AND c.id_turma = p_id_turma)
            OR
            (p_id_aluno IS NOT NULL AND c.id_aluno = p_id_aluno)
            OR
            (p_id_meta_turma IS NOT NULL AND c.id_meta_turma = p_id_meta_turma)
            OR
            (c.escopo = 'Global')
        )
        ORDER BY c.data_referencia DESC, c.criado_em DESC
        LIMIT p_limite_itens_pagina OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'total', COALESCE(v_total, 0),
        'dados', COALESCE(v_result, '[]'::json)
    );
END;
$function$;
