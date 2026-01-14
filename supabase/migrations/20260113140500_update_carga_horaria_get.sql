-- Make p_id_ano_etapa optional in carga_horaria_get

CREATE OR REPLACE FUNCTION public.carga_horaria_get(
    p_id_empresa uuid,
    p_id_ano_etapa uuid DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_itens json;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            ch.*,
            c.nome as componente_nome,
            c.cor as componente_cor,
            ae.nome as ano_etapa_nome  -- Also useful to know which year/stage it belongs to
        FROM public.carga_horaria ch
        JOIN public.componente c ON c.uuid = ch.id_componente
        JOIN public.ano_etapa ae ON ae.id = ch.id_ano_etapa
        WHERE ch.id_empresa = p_id_empresa
          AND (p_id_ano_etapa IS NULL OR ch.id_ano_etapa = p_id_ano_etapa)
        ORDER BY ae.nome, c.nome ASC
    ) t;

    RETURN json_build_object(
        'itens', v_itens
    );
END;
$$;
