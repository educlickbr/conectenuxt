CREATE OR REPLACE FUNCTION public.componentes_get(p_id_empresa uuid)
 RETURNS SETOF componente
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.componente
    WHERE id_empresa = p_id_empresa
    ORDER BY nome ASC;
END;
$function$
