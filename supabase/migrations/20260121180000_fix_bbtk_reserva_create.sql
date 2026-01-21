-- 1. Ensure the function is defined correctly (as requested)
CREATE OR REPLACE FUNCTION public.bbtk_reserva_create(
    p_copia_uuid uuid,
    p_user_uuid uuid,
    p_id_empresa uuid,
    p_data_inicio date DEFAULT CURRENT_DATE
)
RETURNS uuid
LANGUAGE plpgsql
AS $BODY$
DECLARE
    v_id uuid;
    v_data_prevista date;
BEGIN
    v_data_prevista := p_data_inicio + INTERVAL '7 days';

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
        p_user_uuid,
        'Reserva'::public.bbtk_tipo_interacao,
        p_data_inicio,
        v_data_prevista,
        'Reservado'::public.bbtk_status_reserva,
        p_id_empresa
    ) RETURNING uuid INTO v_id;

    -- Update copy status to 'Reservado'
    UPDATE public.bbtk_inventario_copia
    SET status_copia = 'Reservado'::public.bbtk_status_copia
    WHERE uuid = p_copia_uuid;

    RETURN v_id;
END;
$BODY$;

ALTER FUNCTION public.bbtk_reserva_create(uuid, uuid, uuid, date)
    OWNER TO postgres;

-- 2. Add FK to user_expandido if not exists (to enforce the "link with user_expandido" rule)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.table_constraints 
        WHERE constraint_name = 'bbtk_historico_interacao_user_uuid_fkey'
    ) THEN
        ALTER TABLE public.bbtk_historico_interacao 
        ADD CONSTRAINT bbtk_historico_interacao_user_uuid_fkey 
        FOREIGN KEY (user_uuid) 
        REFERENCES public.user_expandido (id);
    END IF;
END $$;
