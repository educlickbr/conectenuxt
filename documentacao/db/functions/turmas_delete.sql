CREATE OR REPLACE FUNCTION public.turmas_delete(
    p_id_empresa uuid,
    p_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
    DELETE FROM public.turmas
    WHERE id = p_id AND id_empresa = p_id_empresa;
    
    RETURN FOUND;
END;
$$;
