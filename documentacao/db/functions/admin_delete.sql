CREATE OR REPLACE FUNCTION public.admin_delete(
    p_id uuid,
    p_id_empresa uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
    UPDATE public.user_expandido
    SET soft_delete = TRUE
    WHERE id = p_id AND id_empresa = p_id_empresa;
END;
$$;

ALTER FUNCTION public.admin_delete(uuid, uuid)
    OWNER TO postgres;
