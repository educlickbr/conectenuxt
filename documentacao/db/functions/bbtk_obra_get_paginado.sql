DROP FUNCTION IF EXISTS public.bbtk_obra_get_paginado(uuid, integer, integer, text);

CREATE OR REPLACE FUNCTION public.bbtk_obra_get_paginado(
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
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_obra o
    LEFT JOIN public.bbtk_dim_autoria aut ON o.id_autoria = aut.uuid
    WHERE 
        o.id_empresa = p_id_empresa
        AND o.soft_delete = false
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(o.titulo_principal) LIKE v_busca_like 
            OR UPPER(o.sub_titulo_principal) LIKE v_busca_like
            OR UPPER(aut.nome_completo) LIKE v_busca_like
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
            o.*,
            cdu.codigo AS cdu_codigo,
            cdu.nome AS cdu_nome,
            cat.nome AS categoria_nome,
            aut.nome_completo AS autor_principal_nome,
            (
                SELECT e.arquivo_capa
                FROM public.bbtk_edicao e
                WHERE e.obra_uuid = o.uuid
                  AND e.arquivo_capa IS NOT NULL
                LIMIT 1
            ) AS capa_imagem
        FROM public.bbtk_obra o
        LEFT JOIN public.bbtk_dim_cdu cdu ON o.cdu_uuid = cdu.uuid
        LEFT JOIN public.bbtk_dim_categoria cat ON o.categoria_uuid = cat.uuid
        LEFT JOIN public.bbtk_dim_autoria aut ON o.id_autoria = aut.uuid
        WHERE 
            o.id_empresa = p_id_empresa
            AND o.soft_delete = false
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(o.titulo_principal) LIKE v_busca_like 
                OR UPPER(o.sub_titulo_principal) LIKE v_busca_like
                OR UPPER(aut.nome_completo) LIKE v_busca_like
            )
        ORDER BY o.titulo_principal ASC
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
