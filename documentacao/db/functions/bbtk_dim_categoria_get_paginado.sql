-- 1. Remover a função existente para evitar conflitos com a nova assinatura de retorno (JSON)
DROP FUNCTION IF EXISTS public.bbtk_dim_categoria_get_paginado(uuid, integer, integer, text);

-- 2. Recriar a função com retorno JSON consolidado (Metadados + Itens Simples)
CREATE OR REPLACE FUNCTION public.bbtk_dim_categoria_get_paginado(
    p_id_empresa uuid,
    p_pagina integer DEFAULT 1,
    p_limite_itens_pagina integer DEFAULT 10,
    p_busca text DEFAULT ''::text
)
RETURNS json
LANGUAGE plpgsql
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    -- 1. Calcular Offset
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    -- 2. Calcular Total de Itens (mantém a lógica robusta de busca NULL/Vazio)
    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_dim_categoria
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome) LIKE v_busca_like 
            OR UPPER(descricao) LIKE v_busca_like
        );

    -- 3. Calcular Total de Páginas
    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- 4. Buscar Itens Paginados e converter para um array JSON simples
    -- Usamos json_agg(t) em um subselect para retornar um array de objetos JSON limpos,
    -- sem a lógica de label/ordem.
    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT uuid, nome, descricao, id_empresa, id_bubble, id_bubble as id_bubble
        FROM public.bbtk_dim_categoria
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like 
                OR UPPER(descricao) LIKE v_busca_like
            )
        ORDER BY nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- 5. Retornar Objeto JSON Final com metadados
    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$BODY$;