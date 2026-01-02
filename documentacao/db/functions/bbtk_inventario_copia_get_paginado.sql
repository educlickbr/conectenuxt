CREATE OR REPLACE FUNCTION public.bbtk_inventario_copia_get_paginado(
    p_id_empresa uuid,
    p_edicao_uuid uuid,
    p_pagina integer DEFAULT 1,
    p_limite_itens_pagina integer DEFAULT 10,
    p_termo_busca text DEFAULT NULL::text,
    p_id_escola uuid DEFAULT NULL::uuid,
    p_predio_uuid uuid DEFAULT NULL::uuid,
    p_sala_uuid uuid DEFAULT NULL::uuid,
    p_estante_uuid uuid DEFAULT NULL::uuid
)
RETURNS json
LANGUAGE plpgsql
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_offset integer;
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
    v_busca_like text;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    IF p_termo_busca IS NOT NULL AND TRIM(p_termo_busca) <> '' THEN
         v_busca_like := '%' || UPPER(p_termo_busca) || '%';
    ELSE
         v_busca_like := NULL;
    END IF;

    -- Contar total de itens
    SELECT COUNT(*)
    INTO v_total_itens
    FROM public.bbtk_inventario_copia c
    LEFT JOIN public.bbtk_dim_estante est ON c.estante_uuid = est.uuid
    LEFT JOIN public.bbtk_dim_sala sala ON est.sala_uuid = sala.uuid
    LEFT JOIN public.bbtk_dim_predio predio ON sala.predio_uuid = predio.uuid
    LEFT JOIN public.escolas esc ON predio.id_escola = esc.id
    WHERE c.id_empresa = p_id_empresa
      AND c.edicao_uuid = p_edicao_uuid
      -- Filter to show active copies OR allow soft_deleted if specific requirement? 
      -- Typically GET shows active only, but user said "er o soft mostra ba tela mesmo como livro removido"
      -- assuming we want to fetch all and let frontend display status, OR user means "soft deleted items are displayed specially".
      -- Let's return soft_delete status so frontend can style it.
      -- If we want to hide deleted by default, we would add: AND c.soft_delete = false
      -- But user said: "er o soft mostra ba tela mesmo como livro removido (a pessoa mesmo pode recolocar)"
      -- So we should RETURN them, but perhaps sorted differently or just included.
      AND (p_id_escola IS NULL OR predio.id_escola = p_id_escola)
      AND (p_predio_uuid IS NULL OR sala.predio_uuid = p_predio_uuid)
      AND (p_sala_uuid IS NULL OR est.sala_uuid = p_sala_uuid)
      AND (p_estante_uuid IS NULL OR c.estante_uuid = p_estante_uuid)
      AND (v_busca_like IS NULL OR UPPER(c.registro_bibliotecario) LIKE v_busca_like);

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- Buscar itens
    SELECT COALESCE(
        json_agg(row_to_json(t)),
        '[]'::json
    )
    INTO v_itens
    FROM (
        SELECT
            c.uuid AS id_copia,
            c.registro_bibliotecario,
            c.status_copia,
            c.avaria_flag,
            c.descricao_avaria,
            c.doacao_ou_compra,
            c.soft_delete,
            c.estante_uuid AS id_estante,
            est.nome AS nome_estante,
            sala.uuid AS id_sala,
            sala.nome AS nome_sala,
            predio.uuid AS id_predio,
            predio.nome AS nome_predio,
            esc.id AS id_escola,
            esc.nome AS nome_escola
        FROM public.bbtk_inventario_copia c
        LEFT JOIN public.bbtk_dim_estante est ON c.estante_uuid = est.uuid
        LEFT JOIN public.bbtk_dim_sala sala ON est.sala_uuid = sala.uuid
        LEFT JOIN public.bbtk_dim_predio predio ON sala.predio_uuid = predio.uuid
        LEFT JOIN public.escolas esc ON predio.id_escola = esc.id
        WHERE c.id_empresa = p_id_empresa
          AND c.edicao_uuid = p_edicao_uuid
          AND (p_id_escola IS NULL OR predio.id_escola = p_id_escola)
          AND (p_predio_uuid IS NULL OR sala.predio_uuid = p_predio_uuid)
          AND (p_sala_uuid IS NULL OR est.sala_uuid = p_sala_uuid)
          AND (p_estante_uuid IS NULL OR c.estante_uuid = p_estante_uuid)
          AND (v_busca_like IS NULL OR UPPER(c.registro_bibliotecario) LIKE v_busca_like)
        ORDER BY c.soft_delete ASC, c.registro_bibliotecario ASC -- Sort active first
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- Retornar resultado
    RETURN json_build_object(
        'itens', v_itens,
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas
    );
END;
$BODY$;

ALTER FUNCTION public.bbtk_inventario_copia_get_paginado(uuid, uuid, integer, integer, text, uuid, uuid, uuid, uuid)
    OWNER TO postgres;
