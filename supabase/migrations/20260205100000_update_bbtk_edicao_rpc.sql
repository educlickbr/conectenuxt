-- Migration to update bbtk_edicao_get_paginado to use R2 paths from global_arquivos
-- Matches strategy from bbtk_obra_get_detalhes_cpx logic

CREATE OR REPLACE FUNCTION "public"."bbtk_edicao_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_termo_busca" "text" DEFAULT NULL::"text", "p_tipo_livro" "text" DEFAULT 'Impresso'::"text", "p_user_uuid" "uuid" DEFAULT NULL::"uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
    v_busca_like text;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);
    
    IF p_termo_busca IS NOT NULL AND TRIM(p_termo_busca) <> '' THEN
         v_busca_like := '%' || UPPER(p_termo_busca) || '%';
    ELSE
         v_busca_like := NULL;
    END IF;

    -- Contar total de itens
    SELECT COUNT(*)
    INTO v_total_itens
    FROM public.bbtk_edicao e
    JOIN public.bbtk_obra o ON e.obra_uuid = o.uuid
    WHERE e.id_empresa = p_id_empresa
      AND o.soft_delete = false
      AND e.tipo_livro = p_tipo_livro::public.bbtk_tipo_livro
      AND (v_busca_like IS NULL OR UPPER(o.titulo_principal) LIKE v_busca_like);

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- Buscar itens
    SELECT COALESCE(
        json_agg(row_to_json(t)),
        '[]'::json
    )
    INTO v_itens
    FROM (
        SELECT
            e.uuid AS id_edicao,
            o.uuid AS id_obra,
            o.titulo_principal,
            o.sub_titulo_principal AS subtitulo,
            o.descricao,
            aut.nome_completo AS autor_principal,
            e.isbn,
            cat.nome AS categoria,
            json_build_object(
                'codigo', cdu.codigo,
                'nome', cdu.nome
            ) AS cdu,
            ed.nome AS editora,
            EXTRACT(YEAR FROM e.ano_lancamento) AS ano_edicao,
            
            -- R2 Integration with Fallback (Same strategy as details RPC)
            COALESCE(ga_pdf.path, e.arquivo_pdf) AS pdf,
            COALESCE(ga_capa.path, e.arquivo_capa) AS capa,

            e.tipo_livro,
            e.livro_retiravel,
            e.livro_recomendado,
            -- Check for active reservation
            EXISTS(
                SELECT 1
                FROM public.bbtk_historico_interacao hi
                JOIN public.bbtk_inventario_copia c ON hi.copia_uuid = c.uuid
                WHERE hi.user_uuid = p_user_uuid
                  AND c.edicao_uuid = e.uuid
                  AND hi.tipo_interacao = 'Reserva'::public.bbtk_tipo_interacao
            ) AS possui_reserva
        FROM public.bbtk_edicao e
        JOIN public.bbtk_obra o ON e.obra_uuid = o.uuid
        LEFT JOIN public.bbtk_dim_autoria aut ON o.id_autoria = aut.uuid
        LEFT JOIN public.bbtk_dim_categoria cat ON o.categoria_uuid = cat.uuid
        LEFT JOIN public.bbtk_dim_cdu cdu ON o.cdu_uuid = cdu.uuid
        LEFT JOIN public.bbtk_dim_editora ed ON e.editora_uuid = ed.uuid
        
        -- Joins for R2 Files (Added)
        LEFT JOIN public.global_arquivos ga_pdf ON e.id_arquivo_livro = ga_pdf.id
        LEFT JOIN public.global_arquivos ga_capa ON e.id_arquivo_capa = ga_capa.id

        WHERE e.id_empresa = p_id_empresa
          AND o.soft_delete = false
          AND e.tipo_livro = p_tipo_livro::public.bbtk_tipo_livro
          AND (v_busca_like IS NULL OR UPPER(o.titulo_principal) LIKE v_busca_like)
        ORDER BY o.titulo_principal ASC, e.ano_lancamento DESC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- Retornar resultado
    RETURN json_build_object(
        'itens', v_itens,
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas
    );
END;
$$;
ALTER FUNCTION "public"."bbtk_edicao_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_tipo_livro" "text", "p_user_uuid" "uuid") OWNER TO "postgres";
