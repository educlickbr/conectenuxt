CREATE OR REPLACE FUNCTION "public"."bbtk_dashboard_get_obras_por_categoria"("p_id_empresa" "uuid") 
RETURNS TABLE("categoria_nome" "text", "quantidade" bigint) 
LANGUAGE "plpgsql" 
SECURITY DEFINER 
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        c.nome as categoria_nome,
        COUNT(o.uuid) as quantidade
    FROM
        public.bbtk_dim_categoria c
        LEFT JOIN public.bbtk_obra o ON c.uuid = o.categoria_uuid 
            AND o.soft_delete = false 
            AND o.id_empresa = p_id_empresa
    WHERE
        c.id_empresa = p_id_empresa
    GROUP BY
        c.uuid, c.nome
    ORDER BY
        quantidade DESC;
END;
$function$;

ALTER FUNCTION "public"."bbtk_dashboard_get_obras_por_categoria"("p_id_empresa" "uuid") OWNER TO "postgres";
GRANT EXECUTE ON FUNCTION "public"."bbtk_dashboard_get_obras_por_categoria"("p_id_empresa" "uuid") TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."bbtk_dashboard_get_obras_por_categoria"("p_id_empresa" "uuid") TO "service_role";
