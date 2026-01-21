-- Create bbtk_reserva_entregar function to handle book delivery/return

CREATE OR REPLACE FUNCTION public.bbtk_reserva_entregar(
    p_reserva_uuid uuid,
    p_id_empresa uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_user_uuid uuid;
    v_copia_uuid uuid;
    v_status_atual public.bbtk_status_reserva;
BEGIN
    -- Resolve user_expandido.id for the currently authenticated user (RECEIVER)
    SELECT id INTO v_user_uuid
    FROM public.user_expandido
    WHERE user_id = auth.uid()
    LIMIT 1;

    -- Raise exception if profile not found
    IF v_user_uuid IS NULL THEN
        RAISE EXCEPTION 'Perfil de usuário não encontrado para o usuário logado.';
    END IF;

    -- Get current status and copy UUID
    SELECT status_reserva, copia_uuid INTO v_status_atual, v_copia_uuid
    FROM public.bbtk_historico_interacao
    WHERE uuid = p_reserva_uuid AND id_empresa = p_id_empresa;

    IF v_status_atual IS NULL THEN
        RAISE EXCEPTION 'Reserva não encontrada.';
    END IF;

    IF v_status_atual = 'Entregue'::public.bbtk_status_reserva OR v_status_atual = 'Cancelado'::public.bbtk_status_reserva THEN
        RAISE EXCEPTION 'Esta reserva já foi finalizada.';
    END IF;

    -- Update reservation history
    UPDATE public.bbtk_historico_interacao
    SET 
        status_reserva = 'Entregue'::public.bbtk_status_reserva,
        data_fim = NOW(),
        recebido_em = NOW(),
        recebido_por = v_user_uuid,
        modificado_em = NOW(),
        modificado_por = v_user_uuid
    WHERE uuid = p_reserva_uuid;

    -- Update copy status to Available
    UPDATE public.bbtk_inventario_copia
    SET status_copia = 'Disponível'::public.bbtk_status_copia
    WHERE uuid = v_copia_uuid;

END;
$function$;
