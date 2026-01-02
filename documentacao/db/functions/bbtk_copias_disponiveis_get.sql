CREATE OR REPLACE FUNCTION public.bbtk_copias_disponiveis_get(
    p_id_empresa uuid,
    p_edicao_uuid uuid
)
RETURNS json
LANGUAGE plpgsql
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_copias json;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json)
    INTO v_copias
    FROM (
        SELECT 
            c.uuid as id_copia,
            c.registro_bibliotecario,
            e.nome as nome_estante,
            s.nome as nome_sala,
            p.nome as nome_predio,
            esc.nome as nome_escola
        FROM public.bbtk_inventario_copia c
        JOIN public.bbtk_dim_estante e ON c.estante_uuid = e.uuid
        JOIN public.bbtk_dim_sala s ON e.sala_uuid = s.uuid
        JOIN public.bbtk_dim_predio p ON s.predio_uuid = p.uuid
        JOIN public.escolas esc ON p.id_escola = esc.id
        WHERE c.id_empresa = p_id_empresa
          AND c.edicao_uuid = p_edicao_uuid
          AND c.status_copia::text = 'Disponível'
    ) t;

    RETURN v_copias;
END;
$BODY$;

ALTER FUNCTION public.bbtk_copias_disponiveis_get(uuid, uuid)
    OWNER TO postgres;
