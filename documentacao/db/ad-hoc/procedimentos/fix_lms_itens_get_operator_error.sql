-- FIX: Overwriting lms_itens_get to resolve "operator does not exist: || unknown" error.
-- This version ensures no unsafe string concatenations are used.

DROP FUNCTION IF EXISTS public.lms_itens_get(uuid, uuid, uuid);

CREATE OR REPLACE FUNCTION public.lms_itens_get(
    p_id_empresa uuid,
    p_user_id uuid, -- Auth ID
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
    -- 1. Lookup User Safely
    SELECT ue.id, ue.papel_id
    INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido ue
    WHERE ue.user_id = p_user_id AND ue.id_empresa = p_id_empresa;

    IF v_user_expandido_id IS NULL THEN
        -- If user not found, return empty set (safe fallback)
        RETURN;
    END IF;

    -- 2. Return Query
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
        -- Submissão (JSON Object)
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
        -- Livro (JSON Object)
        (
            CASE WHEN ic.id_bbtk_edicao IS NOT NULL THEN
                (SELECT jsonb_build_object(
                    'uuid', e.uuid,
                    'titulo', o.titulo_principal,
                    'capa', e.arquivo_capa,
                    'arquivo_pdf', e.arquivo_pdf,
                    'autores', (
                        -- Using string_agg which is safe for text
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
