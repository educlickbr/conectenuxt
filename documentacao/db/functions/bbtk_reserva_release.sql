CREATE OR REPLACE FUNCTION public.bbtk_reserva_release(p_interacao_uuid uuid)
RETURNS boolean
LANGUAGE plpgsql
AS $function$
DECLARE
    v_copia_uuid uuid;
BEGIN
    UPDATE bbtk_historico_interacao
    SET data_fim = CURRENT_DATE,
        status_reserva = 'Entregue'::public.bbtk_status_reserva
    WHERE uuid = p_interacao_uuid
    RETURNING copia_uuid INTO v_copia_uuid;

    IF v_copia_uuid IS NOT NULL THEN
        UPDATE bbtk_inventario_copia
        SET status_copia = 'Disponível'
        WHERE uuid = v_copia_uuid;
        RETURN true;
    END IF;

    RETURN false;
END;
$function$;

ALTER FUNCTION public.bbtk_reserva_release(uuid)
    OWNER TO postgres;
