DROP FUNCTION IF EXISTS public.bbtk_obra_get_detalhes_cpx;
CREATE OR REPLACE FUNCTION public.bbtk_obra_get_detalhes_cpx(
    p_uuid uuid,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
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
                ed.arquivo_pdf,
                ed.arquivo_capa,
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

ALTER FUNCTION public.bbtk_obra_get_detalhes_cpx(uuid, uuid)
    OWNER TO postgres;
