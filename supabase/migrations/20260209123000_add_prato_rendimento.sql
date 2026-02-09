-- Migration: Add Yield (Rendimento) to mrd_prato
-- Date: 2026-02-09

-- 1. Add column to table
ALTER TABLE public.mrd_prato 
ADD COLUMN IF NOT EXISTS rendimento integer DEFAULT 1;

-- 2. Update UPSERT RPC
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
        id, empresa_id, nome, modo_preparo, rendimento,
        created_by, updated_by
    )
    VALUES (
        v_id,
        p_id_empresa,
        p_data ->> 'nome',
        p_data ->> 'modo_preparo',
        coalesce((p_data ->> 'rendimento')::integer, 1),
        auth.uid(), auth.uid()
    )
    ON CONFLICT (id) DO UPDATE SET
        nome = excluded.nome,
        modo_preparo = excluded.modo_preparo,
        rendimento = excluded.rendimento,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE mrd_prato.empresa_id = p_id_empresa
    RETURNING * INTO v_record;

    RETURN to_jsonb(v_record);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$function$;
