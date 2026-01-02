CREATE OR REPLACE FUNCTION public.edicao_update_remover_arquivos_coluna(
    p_edicao_uuid uuid,
    p_coluna text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
BEGIN
    -- Validate column name to prevent SQL injection and ensure logical correctness
    IF p_coluna NOT IN ('arquivo_pdf', 'arquivo_capa') THEN
        RETURN jsonb_build_object('success', false, 'error', 'Nome de coluna inválido. Use "arquivo_pdf" ou "arquivo_capa".');
    END IF;

    -- Update the specified column to NULL
    IF p_coluna = 'arquivo_pdf' THEN
        UPDATE public.bbtk_edicao 
        SET arquivo_pdf = NULL 
        WHERE uuid = p_edicao_uuid;
    ELSIF p_coluna = 'arquivo_capa' THEN
        UPDATE public.bbtk_edicao 
        SET arquivo_capa = NULL 
        WHERE uuid = p_edicao_uuid;
    END IF;

    IF FOUND THEN
        RETURN jsonb_build_object('success', true);
    ELSE
        RETURN jsonb_build_object('success', false, 'error', 'Edição não encontrada.');
    END IF;
END;
$$;

ALTER FUNCTION public.edicao_update_remover_arquivos_coluna(uuid, text) OWNER TO postgres;
