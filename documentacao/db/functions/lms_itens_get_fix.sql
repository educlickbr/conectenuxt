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
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_user_expandido_id uuid;
    v_papel_id uuid;
BEGIN
    SELECT ue.id, ue.papel_id
    INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido ue
    WHERE ue.user_id = p_user_id AND ue.id_empresa = p_id_empresa;

    IF v_user_expandido_id IS NULL THEN
        -- Try finding user without company check strictness if needed, or just return empty
        -- But for now assume strictness is good. 
        RETURN;
    END IF;

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
                'data_inicio', COALESCE(s.criado_em, s.data_envio),
                'data_envio', s.data_envio,
                'status', CASE WHEN s.data_envio IS NOT NULL THEN 'concluido' ELSE 'em_andamento' END,
                'nota', s.nota
            )
            FROM public.lms_submissao s
            WHERE s.id_item_conteudo = ic.id AND s.id_aluno = v_user_expandido_id
            ORDER BY s.criado_em DESC
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
    ORDER BY ic.ordem ASC;
END;
$$;
