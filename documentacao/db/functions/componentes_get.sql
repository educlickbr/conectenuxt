CREATE OR REPLACE FUNCTION public.componentes_get(
    p_id_empresa uuid
)
RETURNS SETOF public.componente
LANGUAGE plpgsql
STABLE
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.componente
    WHERE id_empresa = p_id_empresa
    ORDER BY nome ASC;
END;
$BODY$;

ALTER FUNCTION public.componentes_get(uuid)
    OWNER TO postgres;
