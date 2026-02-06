-- Migration: Create Merenda RPCs Group 1 (Dimensions)
-- Date: 2026-02-05

--------------------------------------------------------------------------------
-- 1. mrd_refeicao_tipo
--------------------------------------------------------------------------------

-- GET ALL
CREATE OR REPLACE FUNCTION public.mrd_refeicao_tipo_get_all(p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_result jsonb;
BEGIN
    SELECT jsonb_agg(to_jsonb(t.*))
    INTO v_result
    FROM public.mrd_refeicao_tipo t
    WHERE t.empresa_id = p_id_empresa
      AND t.ativo = true
    ORDER BY t.ordem ASC, t.nome ASC;

    RETURN coalesce(v_result, '[]'::jsonb);
END;
$function$;

-- UPSERT
CREATE OR REPLACE FUNCTION public.mrd_refeicao_tipo_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_id uuid;
    v_record public.mrd_refeicao_tipo;
BEGIN
    -- Validate empresa access
    IF NOT EXISTS (SELECT 1 FROM public.empresa WHERE id = p_id_empresa) THEN
         RETURN jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada.');
    END IF;

    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());

    INSERT INTO public.mrd_refeicao_tipo (
        id, empresa_id, nome, ordem,
        created_by, updated_by
    )
    VALUES (
        v_id,
        p_id_empresa,
        p_data ->> 'nome',
        coalesce((p_data ->> 'ordem')::integer, 0),
        auth.uid(), auth.uid()
    )
    ON CONFLICT (id) DO UPDATE SET
        nome = excluded.nome,
        ordem = excluded.ordem,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE mrd_refeicao_tipo.empresa_id = p_id_empresa
    RETURNING * INTO v_record;

    RETURN to_jsonb(v_record);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$function$;

-- DELETE
CREATE OR REPLACE FUNCTION public.mrd_refeicao_tipo_delete(p_id uuid, p_id_empresa uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    UPDATE public.mrd_refeicao_tipo
    SET ativo = false,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE id = p_id AND empresa_id = p_id_empresa;
END;
$function$;

--------------------------------------------------------------------------------
-- 2. mrd_alimento
--------------------------------------------------------------------------------

-- GET PAGINADO
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

    -- Fetch Items
    SELECT jsonb_agg(to_jsonb(t.*))
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

-- UPSERT
CREATE OR REPLACE FUNCTION public.mrd_alimento_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_id uuid;
    v_record public.mrd_alimento;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.empresa WHERE id = p_id_empresa) THEN
         RETURN jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada.');
    END IF;

    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());

    INSERT INTO public.mrd_alimento (
        id, empresa_id, nome, unidade_medida, ata_registro_ref, categoria,
        valor_nutricional_100g, preco_medio, fornecedor_preferencial,
        created_by, updated_by
    )
    VALUES (
        v_id,
        p_id_empresa,
        p_data ->> 'nome',
        p_data ->> 'unidade_medida',
        p_data ->> 'ata_registro_ref',
        p_data ->> 'categoria',
        coalesce(p_data -> 'valor_nutricional_100g', '{}'::jsonb),
        (p_data ->> 'preco_medio')::numeric,
        p_data ->> 'fornecedor_preferencial',
        auth.uid(), auth.uid()
    )
    ON CONFLICT (id) DO UPDATE SET
        nome = excluded.nome,
        unidade_medida = excluded.unidade_medida,
        ata_registro_ref = excluded.ata_registro_ref,
        categoria = excluded.categoria,
        valor_nutricional_100g = excluded.valor_nutricional_100g,
        preco_medio = excluded.preco_medio,
        fornecedor_preferencial = excluded.fornecedor_preferencial,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE mrd_alimento.empresa_id = p_id_empresa
    RETURNING * INTO v_record;

    RETURN to_jsonb(v_record);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$function$;

-- DELETE
CREATE OR REPLACE FUNCTION public.mrd_alimento_delete(p_id uuid, p_id_empresa uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    UPDATE public.mrd_alimento
    SET ativo = false,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE id = p_id AND empresa_id = p_id_empresa;
END;
$function$;


--------------------------------------------------------------------------------
-- 3. mrd_prato
--------------------------------------------------------------------------------

-- GET PAGINADO
CREATE OR REPLACE FUNCTION public.mrd_prato_get_paginado(
    p_id_empresa uuid,
    p_pagina integer DEFAULT 1,
    p_limite integer DEFAULT 10,
    p_busca text DEFAULT ''
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
    FROM public.mrd_prato t
    WHERE t.empresa_id = p_id_empresa
      AND t.ativo = true
      AND (p_busca = '' OR t.nome ILIKE '%' || p_busca || '%');

    -- Fetch Items
    SELECT jsonb_agg(to_jsonb(t.*))
    INTO v_itens
    FROM (
        SELECT *
        FROM public.mrd_prato t
        WHERE t.empresa_id = p_id_empresa
          AND t.ativo = true
          AND (p_busca = '' OR t.nome ILIKE '%' || p_busca || '%')
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

-- UPSERT
CREATE OR REPLACE FUNCTION public.mrd_prato_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_id uuid;
    v_record public.mrd_prato;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.empresa WHERE id = p_id_empresa) THEN
         RETURN jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada.');
    END IF;

    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());

    INSERT INTO public.mrd_prato (
        id, empresa_id, nome, modo_preparo,
        created_by, updated_by
    )
    VALUES (
        v_id,
        p_id_empresa,
        p_data ->> 'nome',
        p_data ->> 'modo_preparo',
        auth.uid(), auth.uid()
    )
    ON CONFLICT (id) DO UPDATE SET
        nome = excluded.nome,
        modo_preparo = excluded.modo_preparo,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE mrd_prato.empresa_id = p_id_empresa
    RETURNING * INTO v_record;

    RETURN to_jsonb(v_record);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$function$;

-- DELETE
CREATE OR REPLACE FUNCTION public.mrd_prato_delete(p_id uuid, p_id_empresa uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    UPDATE public.mrd_prato
    SET ativo = false,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE id = p_id AND empresa_id = p_id_empresa;
END;
$function$;
