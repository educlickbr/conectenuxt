-- Migration: Refine Units (ENUM) and Quantities (Rename)
-- Date: 2026-02-09

-- 1. Create the Units ENUM
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'mrd_unidade_medida') THEN
        CREATE TYPE public.mrd_unidade_medida AS ENUM ('KG', 'GR', 'LITRO', 'ML', 'UNIDADE', 'FARDO', 'CX');
    END IF;
END $$;

-- 2. Update mrd_alimento (Convert text to ENUM)
-- Note: We use casting. If some values don't match exactly, they might need mapping first.
-- In our case, UI uses 'KG', 'LITRO', etc. which match.
ALTER TABLE public.mrd_alimento 
ALTER COLUMN unidade_medida TYPE public.mrd_unidade_medida 
USING (
    CASE 
        WHEN unidade_medida = 'UN' THEN 'UNIDADE'::public.mrd_unidade_medida
        WHEN unidade_medida = 'L' THEN 'LITRO'::public.mrd_unidade_medida
        WHEN unidade_medida = 'G' THEN 'GR'::public.mrd_unidade_medida
        ELSE unidade_medida::public.mrd_unidade_medida
    END
);

-- 3. Update mrd_ficha_tecnica (Rename gramagem_per_capita to quantidade)
ALTER TABLE public.mrd_ficha_tecnica 
RENAME COLUMN gramagem_per_capita TO quantidade;

-- 4. Update RPC: mrd_ficha_tecnica_get_by_prato
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
            'quantidade', t.quantidade,
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

-- 5. Update RPC: mrd_ficha_tecnica_upsert_batch
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
            alimento_id, quantidade,
            modo_preparo_complementar, ordem_adicao,
            opcional, substituivel_por,
            created_by, updated_by
        )
        VALUES (
            v_id,
            p_id_empresa,
            p_prato_id,
            (v_item ->> 'alimento_id')::uuid,
            (v_item ->> 'quantidade')::numeric,
            v_item ->> 'modo_preparo_complementar',
            coalesce((v_item ->> 'ordem_adicao')::integer, 0),
            coalesce((v_item ->> 'opcional')::boolean, false),
            (v_item ->> 'substituivel_por')::uuid,
            auth.uid(), auth.uid()
        )
        ON CONFLICT (id) DO UPDATE SET
            quantidade = excluded.quantidade,
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

-- 6. Update RPC: mrd_ficha_tecnica_get_all
CREATE OR REPLACE FUNCTION public.mrd_ficha_tecnica_get_all(p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_result jsonb;
BEGIN
    SELECT jsonb_agg(row_to_json(t))
    INTO v_result
    FROM (
        SELECT 
            p.id as prato_id,
            p.nome as prato_nome,
            p.modo_preparo as prato_modo_preparo,
            p.rendimento,
            COALESCE(stats.ingredientes_count, 0) as ingredientes_count,
            COALESCE(stats.total_quantidade, 0) as total_quantidade
        FROM public.mrd_prato p
        LEFT JOIN (
            SELECT 
                ft.prato_id,
                COUNT(ft.id) as ingredientes_count,
                SUM(ft.quantidade) as total_quantidade
            FROM public.mrd_ficha_tecnica ft
            WHERE ft.ativo = true
            GROUP BY ft.prato_id
        ) stats ON stats.prato_id = p.id
        WHERE p.empresa_id = p_id_empresa
          AND p.ativo = true
        ORDER BY p.nome ASC
    ) t;

    RETURN coalesce(v_result, '[]'::jsonb);
END;
$function$;
