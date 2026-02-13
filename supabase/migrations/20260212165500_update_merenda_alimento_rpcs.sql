-- Migration: Update Merenda Alimento RPCs (Nutrients Relation)
-- Date: 2026-02-12

--------------------------------------------------------------------------------
-- mrd_alimento_upsert
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.mrd_alimento_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_id uuid;
    v_record public.mrd_alimento;
    v_nutrientes jsonb;
    v_nutriente jsonb;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.empresa WHERE id = p_id_empresa) THEN
         RETURN jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada.');
    END IF;

    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_nutrientes := p_data -> 'nutrientes'; -- Expected array of objects { nutriente_id, quantidade_100g }

    -- 1. Upsert Alimento (ignoring valor_nutricional_100g legacy column)
    INSERT INTO public.mrd_alimento (
        id, empresa_id, nome, unidade_medida, ata_registro_ref, categoria,
        preco_medio, fornecedor_preferencial,
        active, -- Assuming active column name is 'active' or 'ativo'? 
        -- Checking previous schema in Step 6: 'ativo bool DEFAULT true'
        ativo,
        created_by, updated_by
    )
    VALUES (
        v_id,
        p_id_empresa,
        p_data ->> 'nome',
        p_data ->> 'unidade_medida',
        p_data ->> 'ata_registro_ref',
        p_data ->> 'categoria',
        (p_data ->> 'preco_medio')::numeric,
        p_data ->> 'fornecedor_preferencial',
        coalesce((p_data ->> 'ativo')::boolean, true),
        auth.uid(), auth.uid()
    )
    ON CONFLICT (id) DO UPDATE SET
        nome = excluded.nome,
        unidade_medida = excluded.unidade_medida,
        ata_registro_ref = excluded.ata_registro_ref,
        categoria = excluded.categoria,
        preco_medio = excluded.preco_medio,
        fornecedor_preferencial = excluded.fornecedor_preferencial,
        ativo = excluded.ativo,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE mrd_alimento.empresa_id = p_id_empresa
    RETURNING * INTO v_record;

    -- 2. Handle Nutrients Relation
    -- Delete existing
    DELETE FROM public.mrd_alimento_nutriente WHERE alimento_id = v_id;

    -- Insert new if any
    IF v_nutrientes IS NOT NULL AND jsonb_array_length(v_nutrientes) > 0 THEN
        INSERT INTO public.mrd_alimento_nutriente (empresa_id, alimento_id, nutriente_id, quantidade_100g)
        SELECT 
            p_id_empresa,
            v_id,
            (item ->> 'nutriente_id')::uuid,
            (item ->> 'quantidade_100g')::numeric
        FROM jsonb_array_elements(v_nutrientes) AS item
        WHERE (item ->> 'quantidade_100g')::numeric > 0;
    END IF;

    RETURN to_jsonb(v_record);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$function$;


--------------------------------------------------------------------------------
-- mrd_alimento_get_paginado
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.mrd_alimento_get_paginado(
    p_id_empresa uuid,
    p_pagina integer DEFAULT 1,
    p_limite integer DEFAULT 10,
    p_busca text DEFAULT '',
    p_categoria text DEFAULT NULL
)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_offset integer;
    v_total integer;
    v_itens jsonb;
BEGIN
    v_offset := (p_pagina - 1) * p_limite;

    -- Count Total
    SELECT count(*) INTO v_total
    FROM public.mrd_alimento t
    WHERE t.empresa_id = p_id_empresa
      AND t.ativo = true
      AND (p_busca = '' OR t.nome ILIKE '%' || p_busca || '%')
      AND (p_categoria IS NULL OR t.categoria = p_categoria);

    -- Fetch Items with Nutrients
    SELECT jsonb_agg(
        to_jsonb(t.*) || 
        jsonb_build_object('nutrientes', (
            SELECT coalesce(jsonb_agg(
                jsonb_build_object(
                    'nutriente_id', n.nutriente_id,
                    'quantidade_100g', n.quantidade_100g,
                    'nome', nut.nome,
                    'unidade', nut.unidade
                )
            ), '[]'::jsonb)
            FROM public.mrd_alimento_nutriente n
            JOIN public.mrd_nutriente nut ON nut.id = n.nutriente_id
            WHERE n.alimento_id = t.id
        ))
    )
    INTO v_itens
    FROM (
        SELECT *
        FROM public.mrd_alimento t
        WHERE t.empresa_id = p_id_empresa
          AND t.ativo = true
          AND (p_busca = '' OR t.nome ILIKE '%' || p_busca || '%')
          AND (p_categoria IS NULL OR t.categoria = p_categoria)
        ORDER BY t.nome ASC
        LIMIT p_limite OFFSET v_offset
    ) t;

    RETURN jsonb_build_object(
        'data', coalesce(v_itens, '[]'::jsonb),
        'total', v_total,
        'pagina', p_pagina,
        'limite', p_limite
    );
END;
$function$;
