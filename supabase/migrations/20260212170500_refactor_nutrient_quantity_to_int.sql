-- Migration: Refactor Nutrient Quantity to Integer (x100 factor)
-- Date: 2026-02-12

--------------------------------------------------------------------------------
-- 1. Alter Table
--------------------------------------------------------------------------------
ALTER TABLE public.mrd_alimento_nutriente
ALTER COLUMN quantidade_100g TYPE integer
USING (quantidade_100g * 100)::integer;

--------------------------------------------------------------------------------
-- 2. Update RPC: mrd_alimento_upsert
--------------------------------------------------------------------------------
drop function public.mrd_alimento_upsert;
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
    v_nutrientes := p_data -> 'nutrientes'; -- Expected array of objects { nutriente_id, quantidade_100g (INTEGER) }

    -- 1. Upsert Alimento
    INSERT INTO public.mrd_alimento (
        id, empresa_id, nome, unidade_medida, ata_registro_ref, categoria,
        preco_medio, fornecedor_preferencial,
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
    -- Note: 'quantidade_100g' coming from frontend is expected to be ALREADY scaled (integer).
    -- But just in case, we cast to integer.
    IF v_nutrientes IS NOT NULL AND jsonb_array_length(v_nutrientes) > 0 THEN
        INSERT INTO public.mrd_alimento_nutriente (empresa_id, alimento_id, nutriente_id, quantidade_100g)
        SELECT 
            p_id_empresa,
            v_id,
            (item ->> 'nutriente_id')::uuid,
            (item ->> 'quantidade_100g')::integer 
        FROM jsonb_array_elements(v_nutrientes) AS item
        WHERE (item ->> 'quantidade_100g')::numeric > 0;
    END IF;

    RETURN to_jsonb(v_record);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$function$;
