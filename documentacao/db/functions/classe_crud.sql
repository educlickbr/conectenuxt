-- classe_get_paginado
CREATE OR REPLACE FUNCTION public.classe_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text)
    RETURNS json
    LANGUAGE plpgsql
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    SELECT COUNT(*) INTO v_total_itens
    FROM public.classe
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome) LIKE v_busca_like 
        );

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT *
        FROM public.classe
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like 
            )
        ORDER BY ordem ASC, nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$BODY$;

-- classe_upsert
CREATE OR REPLACE FUNCTION public.classe_upsert(
    p_data jsonb,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_id uuid;
    v_classe_salva public.classe;
BEGIN
    v_id := coalesce(nullif(p_data ->> 'id', '')::uuid, gen_random_uuid());

    IF NOT EXISTS (SELECT 1 FROM public.empresa WHERE id = p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    END IF;

    INSERT INTO public.classe (
        id, nome, ordem, id_empresa
    )
    VALUES (
        v_id,
        p_data ->> 'nome',
        COALESCE((p_data ->> 'ordem')::integer, 0),
        p_id_empresa
    )
    ON CONFLICT (id) DO UPDATE 
    SET 
        nome = COALESCE(excluded.nome, classe.nome),
        ordem = COALESCE(excluded.ordem, classe.ordem)
    WHERE classe.id_empresa = p_id_empresa
    RETURNING * INTO v_classe_salva;

    RETURN to_jsonb(v_classe_salva);

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
END;
$$;


-- classe_delete
CREATE OR REPLACE FUNCTION public.classe_delete(
    p_id uuid,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_deleted_count integer;
BEGIN
    DELETE FROM public.classe
    WHERE id = p_id
      AND id_empresa = p_id_empresa;
      
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN jsonb_build_object('status', 'success', 'message', 'Classe deletada com sucesso.', 'id', p_id);
    ELSE
        RETURN jsonb_build_object('status', 'error', 'message', 'Classe não encontrada ou não pertence à empresa.', 'id', p_id);
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
END;
$$;
