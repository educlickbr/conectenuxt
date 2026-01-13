CREATE OR REPLACE FUNCTION public.mtz_modelo_calendario_get()
RETURNS json
LANGUAGE plpgsql
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_itens json;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT id, nome
        FROM public.mtz_modelo_calendario
        ORDER BY nome ASC
    ) t;

    RETURN v_itens;
END;
$BODY$;

ALTER FUNCTION public.mtz_modelo_calendario_get() OWNER TO postgres;
