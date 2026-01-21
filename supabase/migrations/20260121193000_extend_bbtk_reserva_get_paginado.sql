-- Extend bbtk_reserva_get_paginado to include copy details and audit names

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
    LEFT JOIN user_expandido ue ON hi.user_uuid = ue.id
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
            hi.criado_em,
            hi.criado_por,
            hi.modificado_em,
            hi.modificado_por,
            hi.recebido_em,
            hi.recebido_por,
            
            -- User names for audit
            ue_criado.nome_completo as criado_por_nome,
            ue_recebido.nome_completo as recebido_por_nome,

            -- Book details
            ob.titulo_principal as livro_titulo,
            ed.arquivo_capa as livro_capa,
            
            -- Copy details
            cop.registro_bibliotecario as copia_registro,
            est.nome as copia_estante,

            -- User details (Requester)
            ue.nome_completo as usuario_nome,
            ue.matricula as usuario_matricula,

            CASE
                WHEN hi.status_reserva = 'Entregue' THEN 'Entregue'
                WHEN hi.status_reserva = 'Cancelado' THEN 'Cancelado'
                WHEN hi.status_reserva = 'Reservado' AND hi.data_prevista_devolucao < CURRENT_TIMESTAMP THEN 'Atrasado'
                ELSE 'No Prazo'
            END as status_calculado
        FROM bbtk_historico_interacao hi
        JOIN bbtk_inventario_copia cop ON hi.copia_uuid = cop.uuid
        JOIN bbtk_edicao ed ON cop.edicao_uuid = ed.uuid
        JOIN bbtk_obra ob ON ed.obra_uuid = ob.uuid
        LEFT JOIN bbtk_dim_estante est ON cop.estante_uuid = est.uuid
        LEFT JOIN user_expandido ue ON hi.user_uuid = ue.id
        LEFT JOIN user_expandido ue_criado ON hi.criado_por = ue_criado.id
        LEFT JOIN user_expandido ue_recebido ON hi.recebido_por = ue_recebido.id
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
