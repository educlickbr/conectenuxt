CREATE OR REPLACE FUNCTION public.perguntas_get(
    p_id_empresa uuid,
    p_papeis jsonb
)
RETURNS SETOF public.perguntas_user
LANGUAGE plpgsql
STABLE
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.perguntas_user
    WHERE 
        -- Verifica se algum dos papéis passados existe no array de papéis da pergunta
        papel ?| ARRAY(SELECT jsonb_array_elements_text(p_papeis))
    ORDER BY ordem ASC;
END;
$BODY$;

ALTER FUNCTION public.perguntas_get(uuid, jsonb)
    OWNER TO postgres;
