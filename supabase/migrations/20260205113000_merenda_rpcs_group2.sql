-- Migration: Create Merenda RPCs Group 2 (Persistent Ops)
-- Date: 2026-02-05

--------------------------------------------------------------------------------
-- 1. mrd_ficha_tecnica
--------------------------------------------------------------------------------

-- GET BY PRATO
CREATE OR REPLACE FUNCTION public.mrd_ficha_tecnica_get_by_prato(p_id_empresa uuid, p_prato_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_itens jsonb;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', t.id,
            'prato_id', t.prato_id,
            'alimento_id', t.alimento_id,
            'gramagem_per_capita', t.gramagem_per_capita,
            'modo_preparo_complementar', t.modo_preparo_complementar,
            'ordem_adicao', t.ordem_adicao,
            'opcional', t.opcional,
            'substituivel_por', t.substituivel_por,
            'ativo', t.ativo,
            'alimento_nome', a.nome,
            'alimento_unidade', a.unidade_medida
        ) ORDER BY t.ordem_adicao ASC
    )
    INTO v_itens
    FROM public.mrd_ficha_tecnica t
    JOIN public.mrd_alimento a ON t.alimento_id = a.id
    WHERE t.empresa_id = p_id_empresa
      AND t.prato_id = p_prato_id
      AND t.ativo = true;

    RETURN coalesce(v_itens, '[]'::jsonb);
END;
$function$;

-- UPSERT BATCH
-- Receives a list of items for a dish.
-- Strategy:
-- 1. Validate Prato ownership.
-- 2. Upsert provided items.
-- 3. Soft-delete items NOT in the provided list.
CREATE OR REPLACE FUNCTION public.mrd_ficha_tecnica_upsert_batch(
    p_id_empresa uuid,
    p_prato_id uuid,
    p_itens jsonb -- array of objects
)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_item jsonb;
    v_ids_touched uuid[] := ARRAY[]::uuid[];
    v_id uuid;
BEGIN
    -- 1. Validate Prato
    IF NOT EXISTS (SELECT 1 FROM public.mrd_prato WHERE id = p_prato_id AND empresa_id = p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Prato não encontrado ou acesso negado.');
    END IF;

    -- 2. Loop through items
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_itens)
    LOOP
        v_id := coalesce((v_item ->> 'id')::uuid, gen_random_uuid());
        
        INSERT INTO public.mrd_ficha_tecnica (
            id, empresa_id, prato_id, 
            alimento_id, gramagem_per_capita,
            modo_preparo_complementar, ordem_adicao,
            opcional, substituivel_por,
            created_by, updated_by
        )
        VALUES (
            v_id,
            p_id_empresa,
            p_prato_id,
            (v_item ->> 'alimento_id')::uuid,
            (v_item ->> 'gramagem_per_capita')::numeric,
            v_item ->> 'modo_preparo_complementar',
            coalesce((v_item ->> 'ordem_adicao')::integer, 0),
            coalesce((v_item ->> 'opcional')::boolean, false),
            (v_item ->> 'substituivel_por')::uuid,
            auth.uid(), auth.uid()
        )
        ON CONFLICT (id) DO UPDATE SET
            gramagem_per_capita = excluded.gramagem_per_capita,
            modo_preparo_complementar = excluded.modo_preparo_complementar,
            ordem_adicao = excluded.ordem_adicao,
            opcional = excluded.opcional,
            substituivel_por = excluded.substituivel_por,
            ativo = true, -- Re-activate if it was deleted
            updated_at = now(),
            updated_by = auth.uid()
        WHERE mrd_ficha_tecnica.empresa_id = p_id_empresa;

        v_ids_touched := array_append(v_ids_touched, v_id);
    END LOOP;

    -- 3. Soft-delete missing items
    UPDATE public.mrd_ficha_tecnica
    SET ativo = false,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE empresa_id = p_id_empresa
      AND prato_id = p_prato_id
      AND id NOT IN (SELECT unnest(v_ids_touched));

    RETURN jsonb_build_object('status', 'success', 'touched_count', array_length(v_ids_touched, 1));
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$function$;


--------------------------------------------------------------------------------
-- 2. mrd_cardapio_etapa
--------------------------------------------------------------------------------

-- LINK (Sync)
-- Links a CardapioGrupo to a list of AnoEtapa IDs.
CREATE OR REPLACE FUNCTION public.mrd_cardapio_etapa_link(
    p_id_empresa uuid,
    p_cardapio_grupo_id uuid,
    p_ano_etapa_ids uuid[]
)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_id uuid;
BEGIN
    -- 1. Validate CardapioGrupo
    IF NOT EXISTS (SELECT 1 FROM public.mrd_cardapio_grupo WHERE id = p_cardapio_grupo_id AND empresa_id = p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Grupo de Cardápio não encontrado.');
    END IF;

    -- 2. Delete links NOT in the new list
    DELETE FROM public.mrd_cardapio_etapa
    WHERE cardapio_grupo_id = p_cardapio_grupo_id
      AND empresa_id = p_id_empresa
      AND (p_ano_etapa_ids IS NULL OR ano_etapa_id NOT IN (SELECT unnest(p_ano_etapa_ids)));

    -- 3. Insert new links
    IF p_ano_etapa_ids IS NOT NULL THEN
        FOREACH v_id IN ARRAY p_ano_etapa_ids
        LOOP
            INSERT INTO public.mrd_cardapio_etapa (
                cardapio_grupo_id, ano_etapa_id, empresa_id,
                created_by
            )
            VALUES (
                p_cardapio_grupo_id, v_id, p_id_empresa,
                auth.uid()
            )
            ON CONFLICT (cardapio_grupo_id, ano_etapa_id) DO NOTHING;
        END LOOP;
    END IF;

    RETURN jsonb_build_object('status', 'success');
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$function$;
