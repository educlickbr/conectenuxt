CREATE OR REPLACE FUNCTION public.mtz_calendario_anual_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text)
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
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- 2. Calcular Total de Itens
    SELECT COUNT(*) INTO v_total_itens
    FROM public.mtz_calendario_anual
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR CAST(ano AS TEXT) LIKE v_busca_like
        );

    -- 3. Calcular Total de Páginas
    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- 4. Buscar Itens Paginados
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT *
        FROM public.mtz_calendario_anual
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR CAST(ano AS TEXT) LIKE v_busca_like
            )
        ORDER BY ano DESC, numero_periodo ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- 5. Retornar Objeto JSON Final
    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$BODY$;

ALTER FUNCTION public.mtz_calendario_anual_get_paginado(uuid, integer, integer, text) OWNER TO postgres;
