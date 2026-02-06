-- Update bbtk_obra_get_paginado to fetch cover from global_arquivos
Drop function if exists bbtk_obra_get_paginado;
CREATE OR REPLACE FUNCTION "public"."bbtk_obra_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
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
                SELECT ga.path
                FROM public.bbtk_edicao e
                JOIN public.global_arquivos ga ON e.id_arquivo_capa = ga.id
                WHERE e.obra_uuid = o.uuid
                LIMIT 1
            ) AS capa_imagem
        FROM public.bbtk_obra o
        LEFT JOIN public.bbtk_dim_cdu cdu ON o.cdu_uuid = cdu.uuid
        LEFT JOIN public.bbtk_dim_categoria cat ON o.categoria_uuid = cat.uuid
        LEFT JOIN public.bbtk_dim_autoria aut ON o.id_autoria = aut.uuid
        WHERE 
            o.id_empresa = p_id_empresa
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
$$;
ALTER FUNCTION "public"."bbtk_obra_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";

Drop function public.bbtk_obra_get_detalhes_cpx;
-- Update bbtk_obra_get_detalhes_cpx to fetch files from global_arquivos
CREATE OR REPLACE FUNCTION "public"."bbtk_obra_get_detalhes_cpx"("p_uuid" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_obra jsonb;
    v_edicoes jsonb;
    v_categorias jsonb;
    v_cdus jsonb;
    v_autores jsonb;
    v_editoras jsonb;
BEGIN
    -- 1. Buscar detalhes da Obra
    SELECT row_to_json(t)::jsonb INTO v_obra
    FROM (
        SELECT 
            o.*,
            cdu.codigo AS cdu_codigo,
            cdu.nome AS cdu_nome,
            cat.nome AS categoria_nome,
            aut.nome_completo AS autor_principal_nome,
            aut.uuid AS autor_principal_uuid
        FROM public.bbtk_obra o
        LEFT JOIN public.bbtk_dim_cdu cdu ON o.cdu_uuid = cdu.uuid
        LEFT JOIN public.bbtk_dim_categoria cat ON o.categoria_uuid = cat.uuid
        LEFT JOIN public.bbtk_dim_autoria aut ON o.id_autoria = aut.uuid
        WHERE o.uuid = p_uuid AND o.id_empresa = p_id_empresa
    ) t;

    -- 2. Buscar Edições e seus dados relacionados (apenas se p_uuid não for nulo)
    IF p_uuid IS NOT NULL THEN
        SELECT COALESCE(jsonb_agg(row_to_json(e)), '[]'::jsonb) INTO v_edicoes
        FROM (
            SELECT 
                ed.uuid,
                ed.ano_lancamento,
                ed.isbn,
                -- Return R2 paths if available, otherwise fallback to old fields (or null)
                COALESCE(ga_pdf.path, ed.arquivo_pdf) as arquivo_pdf,
                COALESCE(ga_capa.path, ed.arquivo_capa) as arquivo_capa,
                ed.tipo_livro,
                ed.livro_retiravel,
                ed.livro_recomendado,
                ed.editora_uuid,
                edit.nome AS nome_editora,
                (v_obra->>'titulo_principal') AS titulo_obra,
                CASE 
                    WHEN ed.tipo_livro::text <> 'Digital' THEN (
                        SELECT count(*) 
                        FROM public.bbtk_inventario_copia ic 
                        WHERE ic.edicao_uuid = ed.uuid
                    )
                    ELSE 0
                END AS qtd_copias,
                (
                    SELECT COALESCE(json_agg(row_to_json(a)), '[]'::json)
                    FROM (
                        SELECT 
                            au.nome_completo,
                            jea.funcao,
                            au.uuid AS autor_uuid
                        FROM public.bbtk_juncao_edicao_autoria jea
                        JOIN public.bbtk_dim_autoria au ON jea.autoria_uuid = au.uuid
                        WHERE jea.edicao_uuid = ed.uuid
                    ) a
                ) AS autores_secundarios
            FROM public.bbtk_edicao ed
            LEFT JOIN public.bbtk_dim_editora edit ON ed.editora_uuid = edit.uuid
            LEFT JOIN public.global_arquivos ga_pdf ON ed.id_arquivo_livro = ga_pdf.id
            LEFT JOIN public.global_arquivos ga_capa ON ed.id_arquivo_capa = ga_capa.id
            WHERE ed.obra_uuid = p_uuid
        ) e;
    ELSE
        v_edicoes := '[]'::jsonb;
    END IF;

    -- 3. Buscar todas as Categorias
    SELECT COALESCE(jsonb_agg(row_to_json(c)), '[]'::jsonb) INTO v_categorias
    FROM (
        SELECT uuid, nome, descricao
        FROM public.bbtk_dim_categoria
        WHERE id_empresa = p_id_empresa
        ORDER BY nome ASC
    ) c;

    -- 4. Buscar todos os CDUs
    SELECT COALESCE(jsonb_agg(row_to_json(d)), '[]'::jsonb) INTO v_cdus
    FROM (
        SELECT uuid, codigo, nome
        FROM public.bbtk_dim_cdu
        WHERE id_empresa = p_id_empresa
        ORDER BY codigo ASC
    ) d;

    -- 5. Buscar todos os Autores (para dropdown)
    SELECT COALESCE(jsonb_agg(row_to_json(a)), '[]'::jsonb) INTO v_autores
    FROM (
        SELECT uuid, nome_completo
        FROM public.bbtk_dim_autoria
        WHERE id_empresa = p_id_empresa
        ORDER BY nome_completo ASC
    ) a;

    -- 6. Buscar todas as Editoras (para dropdown)
    SELECT COALESCE(jsonb_agg(row_to_json(ed)), '[]'::jsonb) INTO v_editoras
    FROM (
        SELECT uuid, nome
        FROM public.bbtk_dim_editora
        WHERE id_empresa = p_id_empresa
        ORDER BY nome ASC
    ) ed;

    -- Retornar objeto completo
    RETURN jsonb_build_object(
        'obra', v_obra, -- pode ser null
        'edicoes', COALESCE(v_edicoes, '[]'::jsonb),
        'categorias', v_categorias,
        'cdus', v_cdus,
        'autores', v_autores,
        'editoras', v_editoras
    );
END;
$$;
ALTER FUNCTION "public"."bbtk_obra_get_detalhes_cpx"("p_uuid" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
