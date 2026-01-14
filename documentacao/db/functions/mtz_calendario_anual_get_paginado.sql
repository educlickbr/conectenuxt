CREATE OR REPLACE FUNCTION public.mtz_calendario_anual_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text,
    p_id_ano_etapa uuid DEFAULT NULL,
    p_id_escola uuid DEFAULT NULL,
    p_modo_visualizacao text DEFAULT 'Tudo' -- 'Tudo', 'Rede', 'Segmentado'
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
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    WITH data_source AS (
        SELECT 
            c.*,
            ae.nome as ano_etapa_nome,
            mc.nome as modelo_nome,
            e.nome as escola_nome
        FROM public.mtz_calendario_anual c
        LEFT JOIN public.ano_etapa ae ON c.id_ano_etapa = ae.id
        LEFT JOIN public.mtz_modelo_calendario mc ON c.id_modelo_calendario = mc.id
        LEFT JOIN public.escolas e ON c.id_escola = e.id
        WHERE c.id_empresa = p_id_empresa
    )
    SELECT COUNT(*) INTO v_total_itens
    FROM data_source c
    WHERE 
        (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR CAST(c.ano AS TEXT) LIKE v_busca_like
        )
        AND (
            CASE 
                WHEN p_modo_visualizacao = 'Rede' THEN c.escopo = 'Rede'
                WHEN p_modo_visualizacao = 'Segmentado' THEN c.escopo = 'Ano_Etapa'
                ELSE TRUE -- 'Tudo'
            END
        )
        AND (
            (p_id_ano_etapa IS NULL OR c.id_ano_etapa = p_id_ano_etapa)
            AND
            (p_id_escola IS NULL OR c.id_escola = p_id_escola)
        );

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT *
        FROM (
            SELECT 
                c.*,
                ae.nome as ano_etapa_nome,
                mc.nome as modelo_nome,
                e.nome as escola_nome
            FROM public.mtz_calendario_anual c
            LEFT JOIN public.ano_etapa ae ON c.id_ano_etapa = ae.id
            LEFT JOIN public.mtz_modelo_calendario mc ON c.id_modelo_calendario = mc.id
            LEFT JOIN public.escolas e ON c.id_escola = e.id
            WHERE c.id_empresa = p_id_empresa
        ) c
        WHERE 
            (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR CAST(c.ano AS TEXT) LIKE v_busca_like
            )
            AND (
                CASE 
                    WHEN p_modo_visualizacao = 'Rede' THEN c.escopo = 'Rede'
                    WHEN p_modo_visualizacao = 'Segmentado' THEN c.escopo = 'Ano_Etapa'
                    ELSE TRUE -- 'Tudo'
                END
            )
            AND (
                (p_id_ano_etapa IS NULL OR c.id_ano_etapa = p_id_ano_etapa)
                AND
                (p_id_escola IS NULL OR c.id_escola = p_id_escola)
            )
        ORDER BY c.ano DESC, c.numero_periodo ASC
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
ALTER FUNCTION public.mtz_calendario_anual_get_paginado(uuid, integer, integer, text, uuid, uuid, text) OWNER TO postgres;
