-- Fix bbtk_reserva_create column names and logic
-- Corrects `status` -> `status_reserva`, `tipo` -> `tipo_interacao`, and restores UUID generation/date calc.

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
    v_data_prevista date;
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
    
    -- Calculate expected return date (7 days default)
    v_data_prevista := p_data_inicio + INTERVAL '7 days';

    -- Insert into history
    INSERT INTO public.bbtk_historico_interacao (
        uuid,
        copia_uuid,
        user_uuid,
        tipo_interacao,
        data_inicio,
        data_prevista_devolucao,
        status_reserva,
        id_empresa
    ) VALUES (
        gen_random_uuid(),
        p_copia_uuid,
        v_user_uuid,
        'Reserva'::public.bbtk_tipo_interacao,
        p_data_inicio,
        v_data_prevista,
        'Reservado'::public.bbtk_status_reserva,
        p_id_empresa
    );

    -- Update copy status
    UPDATE public.bbtk_inventario_copia
    SET status_copia = 'Reservado'::public.bbtk_status_copia
    WHERE uuid = p_copia_uuid;

END;
$function$;
