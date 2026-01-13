CREATE OR REPLACE FUNCTION public.mtz_matriz_curricular_get_paginado(
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
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    SELECT COUNT(*) INTO v_total_itens
    FROM public.mtz_matriz_curricular
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR CAST(ano AS TEXT) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT *
        FROM public.mtz_matriz_curricular
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR CAST(ano AS TEXT) LIKE v_busca_like
            )
        ORDER BY ano DESC, dia_semana ASC, aula ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$BODY$;

ALTER FUNCTION public.mtz_matriz_curricular_get_paginado(uuid, integer, integer, text) OWNER TO postgres;
