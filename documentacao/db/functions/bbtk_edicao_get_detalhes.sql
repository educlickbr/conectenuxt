CREATE OR REPLACE FUNCTION public.bbtk_edicao_get_detalhes(
    p_uuid uuid,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_edicao jsonb;
BEGIN
    SELECT row_to_json(t)::jsonb INTO v_edicao
    FROM (
        SELECT 
            e.*,
            -- Joins simples
            o.titulo_principal AS obra_titulo,
            edit.nome AS editora_nome,
            doad.nome AS doador_nome,
            
            -- Autores secundários (Junção)
            (
                SELECT COALESCE(json_agg(row_to_json(a)), '[]'::json)
                FROM (
                    SELECT 
                        au.uuid,
                        au.nome_completo,
                        jea.funcao
                    FROM public.bbtk_juncao_edicao_autoria jea
                    JOIN public.bbtk_dim_autoria au ON jea.autoria_uuid = au.uuid
                    WHERE jea.edicao_uuid = e.uuid
                ) a
            ) AS autores_secundarios,

            -- Metadados (Junção)
            (
                SELECT COALESCE(json_agg(row_to_json(m)), '[]'::json)
                FROM (
                    SELECT 
                        met.uuid,
                        met.nome
                    FROM public.bbtk_juncao_edicao_metadado jem
                    JOIN public.bbtk_dim_metadado met ON jem.metadado_uuid = met.uuid
                    WHERE jem.edicao_uuid = e.uuid
                ) m
            ) AS metadados,

            -- Contagem de cópias (se não for Digital)
            CASE 
                WHEN e.tipo_livro::text <> 'Digital' THEN (
                    SELECT count(*) 
                    FROM public.bbtk_inventario_copia ic 
                    WHERE ic.edicao_uuid = e.uuid
                )
                ELSE 0
            END AS qtd_copias_inventario

        FROM public.bbtk_edicao e
        JOIN public.bbtk_obra o ON e.obra_uuid = o.uuid
        LEFT JOIN public.bbtk_dim_editora edit ON e.editora_uuid = edit.uuid
        LEFT JOIN public.bbtk_dim_doador doad ON e.doador_uuid = doad.uuid
        WHERE e.uuid = p_uuid 
          AND e.id_empresa = p_id_empresa
    ) t;

    IF v_edicao IS NULL THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Edição não encontrada');
    END IF;

    RETURN v_edicao;
END;
$$;

ALTER FUNCTION public.bbtk_edicao_get_detalhes(uuid, uuid)
    OWNER TO postgres;
