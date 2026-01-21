-- Refactor bbtk_reserva_create to resolve user_expandido.id internally
-- This removes the reliability on passing user_uuid from the client/API

CREATE OR REPLACE FUNCTION public.bbtk_reserva_create(
    p_copia_uuid uuid,
    p_id_empresa uuid,
    p_data_inicio date
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_user_uuid uuid;
BEGIN
    -- Resolve user_expandido.id for the currently authenticated user
    SELECT id INTO v_user_uuid
    FROM public.user_expandido
    WHERE user_id = auth.uid()
    LIMIT 1;

    -- Raise exception if profile not found
    IF v_user_uuid IS NULL THEN
        RAISE EXCEPTION 'Perfil de usuário não encontrado para o usuário logado.';
    END IF;

    -- Insert into history
    INSERT INTO public.bbtk_historico_interacao (
        copia_uuid,
        user_uuid,
        data_inicio,
        status,
        tipo,
        id_empresa
    ) VALUES (
        p_copia_uuid,
        v_user_uuid, 
        p_data_inicio,
        'reservado',
        'reserva',
        p_id_empresa
    );

    -- Update copy status
    UPDATE public.bbtk_inventario_copia
    SET status_item = 'reservado'
    WHERE id = p_copia_uuid;

END;
$function$;
