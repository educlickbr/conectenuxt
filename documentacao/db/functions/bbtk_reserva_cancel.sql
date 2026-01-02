CREATE OR REPLACE FUNCTION public.bbtk_reserva_cancel(
    p_id_empresa uuid,
    p_user_uuid uuid,
    p_edicao_uuid uuid
)
RETURNS boolean
LANGUAGE plpgsql
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_copia_uuid uuid;
    v_interaction_uuid uuid;
BEGIN
    -- Find the reservation for this user and edition
    SELECT hi.uuid, hi.copia_uuid
    INTO v_interaction_uuid, v_copia_uuid
    FROM public.bbtk_historico_interacao hi
    JOIN public.bbtk_inventario_copia c ON hi.copia_uuid = c.uuid
    WHERE hi.user_uuid = p_user_uuid
      AND hi.id_empresa = p_id_empresa
      AND c.edicao_uuid = p_edicao_uuid
      AND hi.tipo_interacao = 'Reserva'::public.bbtk_tipo_interacao
    LIMIT 1;

    IF v_interaction_uuid IS NULL THEN
        RETURN false; -- No reservation found
    END IF;

    -- Delete reservation record
    DELETE FROM public.bbtk_historico_interacao
    WHERE uuid = v_interaction_uuid;

    -- Reset copy status to 'Disponível'
    UPDATE public.bbtk_inventario_copia
    SET status_copia = 'Disponível'::public.bbtk_status_copia
    WHERE uuid = v_copia_uuid;

    RETURN true;
END;
$BODY$;

ALTER FUNCTION public.bbtk_reserva_cancel(uuid, uuid, uuid)
    OWNER TO postgres;
