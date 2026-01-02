DROP FUNCTION IF EXISTS public.bbtk_dim_sala_get_paginado(uuid, integer, integer, text);

CREATE OR REPLACE FUNCTION public.bbtk_dim_sala_get_paginado(
    p_id_empresa uuid,
    p_pagina integer DEFAULT 1,
    p_limite_itens_pagina integer DEFAULT 10,
    p_busca text DEFAULT ''::text,
    p_predio_uuid uuid DEFAULT NULL
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
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_dim_sala s
    INNER JOIN public.bbtk_dim_predio p ON s.predio_uuid = p.uuid
    LEFT JOIN public.escolas e ON p.id_escola = e.id
    WHERE 
        p.id_empresa = p_id_empresa
        AND (p_predio_uuid IS NULL OR s.predio_uuid = p_predio_uuid)
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(s.nome) LIKE v_busca_like
            OR UPPER(p.nome) LIKE v_busca_like
            OR UPPER(e.nome) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT 
            s.*, 
            p.nome as predio_nome, 
            e.nome as escola_nome, 
            e.id as escola_id
        FROM public.bbtk_dim_sala s
        INNER JOIN public.bbtk_dim_predio p ON s.predio_uuid = p.uuid
        LEFT JOIN public.escolas e ON p.id_escola = e.id
        WHERE 
            p.id_empresa = p_id_empresa
            AND (p_predio_uuid IS NULL OR s.predio_uuid = p_predio_uuid)
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(s.nome) LIKE v_busca_like
                OR UPPER(p.nome) LIKE v_busca_like
                OR UPPER(e.nome) LIKE v_busca_like
            )
        ORDER BY s.nome ASC
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
