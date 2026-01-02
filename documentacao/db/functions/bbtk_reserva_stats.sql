CREATE OR REPLACE FUNCTION public.bbtk_reserva_stats(p_id_empresa uuid)
RETURNS json
LANGUAGE plpgsql
AS $function$
DECLARE
    v_total bigint;
    v_no_prazo bigint;
    v_atrasadas bigint;
BEGIN
    -- Total active reservations (not returned yet)
    SELECT count(*) INTO v_total
    FROM bbtk_historico_interacao
    WHERE id_empresa = p_id_empresa 
      AND tipo_interacao = 'Reserva' 
      AND status_reserva = 'Reservado';

    SELECT count(*) INTO v_no_prazo
    FROM bbtk_historico_interacao
    WHERE id_empresa = p_id_empresa
      AND tipo_interacao = 'Reserva'
      AND status_reserva = 'Reservado'
      AND (data_prevista_devolucao >= CURRENT_DATE OR data_prevista_devolucao IS NULL);

    SELECT count(*) INTO v_atrasadas
    FROM bbtk_historico_interacao
    WHERE id_empresa = p_id_empresa
      AND tipo_interacao = 'Reserva'
      AND status_reserva = 'Reservado'
      AND data_prevista_devolucao < CURRENT_DATE;

    RETURN json_build_object(
        'total', v_total,
        'no_prazo', v_no_prazo,
        'atrasadas', v_atrasadas
    );
END;
$function$;

ALTER FUNCTION public.bbtk_reserva_stats(uuid)
    OWNER TO postgres;
