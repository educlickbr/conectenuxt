-- Update bbtk_reserva_create to support audit columns and timestamptz

CREATE OR REPLACE FUNCTION public.bbtk_reserva_create(
    p_copia_uuid uuid,
    p_id_empresa uuid,
    p_data_inicio timestamptz DEFAULT CURRENT_TIMESTAMP -- Changed from date to timestamptz
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_user_uuid uuid;
    v_data_prevista timestamptz; -- Changed to timestamptz
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
    -- Using INTERVAL '7 days' works with timestamptz
    v_data_prevista := p_data_inicio + INTERVAL '7 days';

    -- Insert into history with audit fields
    INSERT INTO public.bbtk_historico_interacao (
        uuid,
        copia_uuid,
        user_uuid,
        tipo_interacao,
        data_inicio,
        data_prevista_devolucao,
        status_reserva,
        id_empresa,
        criado_por,
        criado_em,
        modificado_por,
        modificado_em
    ) VALUES (
        gen_random_uuid(),
        p_copia_uuid,
        v_user_uuid,
        'Reserva'::public.bbtk_tipo_interacao,
        p_data_inicio,
        v_data_prevista,
        'Reservado'::public.bbtk_status_reserva,
        p_id_empresa,
        v_user_uuid, -- criado_por
        NOW(),       -- criado_em
        v_user_uuid, -- modificado_por
        NOW()        -- modificado_em
    );

    -- Update copy status
    UPDATE public.bbtk_inventario_copia
    SET status_copia = 'Reservado'::public.bbtk_status_copia
    WHERE uuid = p_copia_uuid;

END;
$function$;
