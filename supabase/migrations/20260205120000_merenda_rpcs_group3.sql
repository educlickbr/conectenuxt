-- Migration: Create Merenda RPCs Group 3 (Variable Ops)
-- Date: 2026-02-05

--------------------------------------------------------------------------------
-- 1. mrd_cardapio_grupo
--------------------------------------------------------------------------------

-- GET PAGINADO
CREATE OR REPLACE FUNCTION public.mrd_cardapio_grupo_get_paginado(
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
    FROM public.mrd_cardapio_grupo t
    WHERE t.empresa_id = p_id_empresa
      AND t.ativo = true
      AND (p_busca = '' OR t.nome ILIKE '%' || p_busca || '%');

    -- Fetch Items with Etapa Names
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', t.id,
            'nome', t.nome,
            'data_inicio', t.data_inicio,
            'data_fim', t.data_fim,
            'etapas', (
                SELECT jsonb_agg(ae.nome)
                FROM public.mrd_cardapio_etapa ce
                JOIN public.ano_etapa ae ON ce.ano_etapa_id = ae.id
                WHERE ce.cardapio_grupo_id = t.id
            )
        )
    )
    INTO v_itens
    FROM (
        SELECT *
        FROM public.mrd_cardapio_grupo t
        WHERE t.empresa_id = p_id_empresa
          AND t.ativo = true
          AND (p_busca = '' OR t.nome ILIKE '%' || p_busca || '%')
        ORDER BY t.data_inicio DESC
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
CREATE OR REPLACE FUNCTION public.mrd_cardapio_grupo_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_id uuid;
    v_record public.mrd_cardapio_grupo;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.empresa WHERE id = p_id_empresa) THEN
         RETURN jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada.');
    END IF;

    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());

    INSERT INTO public.mrd_cardapio_grupo (
        id, empresa_id, nome, data_inicio, data_fim,
        created_by, updated_by
    )
    VALUES (
        v_id,
        p_id_empresa,
        p_data ->> 'nome',
        (p_data ->> 'data_inicio')::timestamptz,
        (p_data ->> 'data_fim')::timestamptz,
        auth.uid(), auth.uid()
    )
    ON CONFLICT (id) DO UPDATE SET
        nome = excluded.nome,
        data_inicio = excluded.data_inicio,
        data_fim = excluded.data_fim,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE mrd_cardapio_grupo.empresa_id = p_id_empresa
    RETURNING * INTO v_record;

    RETURN to_jsonb(v_record);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$function$;


--------------------------------------------------------------------------------
-- 2. mrd_cardapio_semanal
--------------------------------------------------------------------------------

-- GET GRID
-- Returns the grid cells for a specific week and group.
CREATE OR REPLACE FUNCTION public.mrd_cardapio_semanal_get(
    p_id_empresa uuid,
    p_cardapio_grupo_id uuid,
    p_ano integer,
    p_semana_iso integer
)
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
            'dia_semana_indice', t.dia_semana_indice,
            'p_dia_semana', t.p_dia_semana,
            'refeicao_tipo_id', t.refeicao_tipo_id,
            'prato_id', t.prato_id,
            'prato_alternativo_id', t.prato_alternativo_id,
            'observacoes', t.observacoes,
            'status', t.status,
            'prato_nome', p.nome,
            'refeicao_nome', rt.nome
        ) ORDER BY t.dia_semana_indice ASC, rt.ordem ASC
    )
    INTO v_itens
    FROM public.mrd_cardapio_semanal t
    JOIN public.mrd_refeicao_tipo rt ON t.refeicao_tipo_id = rt.id
    LEFT JOIN public.mrd_prato p ON t.prato_id = p.id
    WHERE t.empresa_id = p_id_empresa
      AND t.cardapio_grupo_id = p_cardapio_grupo_id
      AND t.ano = p_ano
      AND t.semana_iso = p_semana_iso
      AND t.ativo = true;

    RETURN coalesce(v_itens, '[]'::jsonb);
END;
$function$;

-- UPSERT BATCH
-- Syncs the grid for a week.
CREATE OR REPLACE FUNCTION public.mrd_cardapio_semanal_upsert_batch(
    p_id_empresa uuid,
    p_cardapio_grupo_id uuid,
    p_ano integer,
    p_semana_iso integer,
    p_itens jsonb
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
    -- 1. Validate Group
    IF NOT EXISTS (SELECT 1 FROM public.mrd_cardapio_grupo WHERE id = p_cardapio_grupo_id AND empresa_id = p_id_empresa) THEN
         RETURN jsonb_build_object('status', 'error', 'message', 'Grupo de cardápio não encontrado.');
    END IF;

    -- 2. Loop through items
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_itens)
    LOOP
        v_id := coalesce((v_item ->> 'id')::uuid, gen_random_uuid());

        INSERT INTO public.mrd_cardapio_semanal (
            id, empresa_id, cardapio_grupo_id,
            ano, semana_iso,
            p_dia_semana, u_dia_semana,
            dia_semana_indice,
            refeicao_tipo_id, prato_id, prato_alternativo_id,
            observacoes, status,
            created_by, updated_by
        )
        VALUES (
            v_id,
            p_id_empresa,
            p_cardapio_grupo_id,
            p_ano,
            p_semana_iso,
            (v_item ->> 'p_dia_semana')::timestamptz,
            (v_item ->> 'u_dia_semana')::timestamptz,
            (v_item ->> 'dia_semana_indice')::integer,
            (v_item ->> 'refeicao_tipo_id')::uuid,
            (v_item ->> 'prato_id')::uuid,
            (v_item ->> 'prato_alternativo_id')::uuid,
            v_item ->> 'observacoes',
            coalesce(v_item ->> 'status', 'PLANEJADO'),
            auth.uid(), auth.uid()
        )
        ON CONFLICT (id) DO UPDATE SET
            prato_id = excluded.prato_id,
            prato_alternativo_id = excluded.prato_alternativo_id,
            observacoes = excluded.observacoes,
            status = excluded.status,
            ativo = true,
            updated_at = now(),
            updated_by = auth.uid()
        WHERE mrd_cardapio_semanal.empresa_id = p_id_empresa;

        v_ids_touched := array_append(v_ids_touched, v_id);
    END LOOP;

    -- 3. Soft-delete missing items for this week
    UPDATE public.mrd_cardapio_semanal
    SET ativo = false,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE empresa_id = p_id_empresa
      AND cardapio_grupo_id = p_cardapio_grupo_id
      AND ano = p_ano
      AND semana_iso = p_semana_iso
      AND id NOT IN (SELECT unnest(v_ids_touched));

    RETURN jsonb_build_object('status', 'success', 'touched_count', array_length(v_ids_touched, 1));
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$function$;
