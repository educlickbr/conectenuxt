-- componente_get_paginado
CREATE OR REPLACE FUNCTION public.componente_get_paginado(
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
    FROM public.componente
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
        FROM public.componente
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like 
            )
        ORDER BY nome ASC
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

-- upsert_componentes
CREATE OR REPLACE FUNCTION public.upsert_componentes(
    p_data jsonb,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_uuid uuid;
    v_componente_salvo public.componente;
BEGIN
    v_uuid := coalesce(nullif(p_data ->> 'uuid', '')::uuid, gen_random_uuid());

    IF NOT EXISTS (SELECT 1 FROM public.empresa WHERE id = p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    END IF;

    INSERT INTO public.componente (
        uuid, nome, cor, id_empresa
    )
    VALUES (
        v_uuid,
        p_data ->> 'nome',
        p_data ->> 'cor',
        p_id_empresa
    )
    ON CONFLICT (uuid) DO UPDATE 
    SET 
        nome = COALESCE(excluded.nome, componente.nome),
        cor = COALESCE(excluded.cor, componente.cor)
    WHERE componente.id_empresa = p_id_empresa
    RETURNING * INTO v_componente_salvo;

    RETURN to_jsonb(v_componente_salvo);

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
END;
$$;


-- componente_delete
CREATE OR REPLACE FUNCTION public.componente_delete(
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
    v_dependency_count integer;
    v_dependency_info text;
BEGIN
    -- 1. Check for dependencies in carga_horaria
    SELECT count(*), 
           string_agg(ae.nome, ', ')
    INTO v_dependency_count, v_dependency_info
    FROM public.carga_horaria ch
    JOIN public.ano_etapa ae ON ae.id = ch.id_ano_etapa
    WHERE ch.id_componente = p_id
      AND ch.id_empresa = p_id_empresa;

    IF v_dependency_count > 0 THEN
        RETURN jsonb_build_object(
            'status', 'error', 
            'message', 'Não é possível excluir: este componente possui carga horária vinculada em: ' || v_dependency_info || '. Exclua as cargas horárias primeiro.',
            'id', p_id
        );
    END IF;

    -- 2. Proced with deletion
    DELETE FROM public.componente
    WHERE uuid = p_id
      AND id_empresa = p_id_empresa;
      
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN jsonb_build_object('status', 'success', 'message', 'Componente deletado com sucesso.', 'id', p_id);
    ELSE
        RETURN jsonb_build_object('status', 'error', 'message', 'Componente não encontrado ou não pertence à empresa.', 'id', p_id);
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
END;
$$;
