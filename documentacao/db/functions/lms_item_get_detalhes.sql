
DROP FUNCTION public.lms_item_get_detalhes;
CREATE OR REPLACE FUNCTION public.lms_item_get_detalhes(
    p_id_item uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_result json;
BEGIN
    SELECT json_build_object(
        'id', i.id,
        'id_lms_conteudo', i.id_lms_conteudo,
        'tipo', i.tipo,
        'titulo', i.titulo,
        'caminho_arquivo', i.caminho_arquivo,
        'url_externa', i.url_externa,
        'video_link', i.video_link,
        'rich_text', i.rich_text,
        'pontuacao_maxima', i.pontuacao_maxima,
        'id_bbtk_edicao', i.id_bbtk_edicao,
        'ordem', i.ordem,
        'data_disponivel', i.data_disponivel,
        'data_entrega_limite', i.data_entrega_limite,
        'tempo_questionario', i.tempo_questionario,
        
        -- Detalhes Livro (Se houver)
        'livro_digital', CASE WHEN i.id_bbtk_edicao IS NOT NULL THEN
             (SELECT json_build_object('titulo', o.titulo_principal, 'capa', e.arquivo_capa) 
              FROM bbtk_edicao e JOIN bbtk_obra o ON o.uuid = e.obra_uuid WHERE e.uuid = i.id_bbtk_edicao)
             ELSE NULL END,

        -- Perguntas (Se houver)
        'perguntas', (
            SELECT json_agg(
                json_build_object(
                    'id', p.id,
                    'tipo', p.tipo,
                    'enunciado', p.enunciado,
                    'caminho_imagem', p.caminho_imagem,
                    'obrigatoria', p.obrigatoria,
                    'ordem', p.ordem,
                    -- Opções (Se houver)
                    'opcoes', (
                        SELECT json_agg(
                            json_build_object(
                                'id', rp.id,
                                'texto', rp.texto,
                                'correta', rp.correta,
                                'ordem', rp.ordem
                            ) ORDER BY rp.ordem
                        )
                        FROM public.lms_resposta_possivel rp
                        WHERE rp.id_pergunta = p.id
                    )
                ) ORDER BY p.ordem
            )
            FROM public.lms_pergunta p
            WHERE p.id_item_conteudo = i.id
        )
    )
    INTO v_result
    FROM public.lms_item_conteudo i
    WHERE i.id = p_id_item;

    RETURN v_result;
END;
$function$;
