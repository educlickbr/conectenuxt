CREATE OR REPLACE FUNCTION public.bbtk_reserva_get_paginado(
    p_id_empresa uuid,
    p_offset integer,
    p_limit integer,
    p_filtro text
)
RETURNS json
LANGUAGE plpgsql
AS $function$
DECLARE
    v_total integer;
    v_result json;
BEGIN
    SELECT count(*)
    INTO v_total
    FROM bbtk_historico_interacao hi
    JOIN bbtk_inventario_copia cop ON hi.copia_uuid = cop.uuid
    JOIN bbtk_edicao ed ON cop.edicao_uuid = ed.uuid
    JOIN bbtk_obra ob ON ed.obra_uuid = ob.uuid
    LEFT JOIN user_expandido ue ON hi.user_uuid = ue.user_id
    WHERE hi.id_empresa = p_id_empresa
      AND hi.tipo_interacao = 'Reserva'
      AND (
          p_filtro IS NULL OR
          ob.titulo_principal ILIKE '%' || p_filtro || '%' OR
          ue.nome_completo ILIKE '%' || p_filtro || '%'
      );

    SELECT json_agg(t) INTO v_result
    FROM (
        SELECT
            hi.uuid,
            hi.data_inicio,
            hi.data_prevista_devolucao,
            hi.data_fim,
            hi.status_reserva,
            ob.titulo_principal as livro_titulo,
            ed.arquivo_capa as livro_capa,
            ue.nome_completo as usuario_nome,
            ue.matricula as usuario_matricula,
            CASE
                WHEN hi.status_reserva = 'Entregue' THEN 'Entregue'
                WHEN hi.status_reserva = 'Cancelado' THEN 'Cancelado'
                WHEN hi.status_reserva = 'Reservado' AND hi.data_prevista_devolucao < CURRENT_DATE THEN 'Atrasado'
                ELSE 'No Prazo'
            END as status_calculado
        FROM bbtk_historico_interacao hi
        JOIN bbtk_inventario_copia cop ON hi.copia_uuid = cop.uuid
        JOIN bbtk_edicao ed ON cop.edicao_uuid = ed.uuid
        JOIN bbtk_obra ob ON ed.obra_uuid = ob.uuid
        LEFT JOIN user_expandido ue ON hi.user_uuid = ue.user_id
        WHERE hi.id_empresa = p_id_empresa
          AND hi.tipo_interacao = 'Reserva'
          AND (
              p_filtro IS NULL OR
              ob.titulo_principal ILIKE '%' || p_filtro || '%' OR
              ue.nome_completo ILIKE '%' || p_filtro || '%'
          )
        ORDER BY 
            CASE 
                WHEN hi.status_reserva = 'Reservado' THEN 0 
                ELSE 1 
            END,
            hi.data_inicio DESC
        LIMIT p_limit OFFSET p_offset
    ) t;

    RETURN json_build_object('total', v_total, 'data', COALESCE(v_result, '[]'::json));
END;
$function$;

ALTER FUNCTION public.bbtk_reserva_get_paginado(uuid, integer, integer, text)
    OWNER TO postgres;
