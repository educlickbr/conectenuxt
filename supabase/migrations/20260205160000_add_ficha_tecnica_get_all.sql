-- Migration: Fix Ficha Técnica List RPC
-- Date: 2026-02-05

DROP FUNCTION IF EXISTS public.mrd_ficha_tecnica_get_all(uuid);

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
            COALESCE(stats.ingredientes_count, 0) as ingredientes_count,
            COALESCE(stats.total_gramagem, 0) as total_gramagem
        FROM public.mrd_prato p
        LEFT JOIN (
            SELECT 
                ft.prato_id,
                COUNT(ft.id) as ingredientes_count,
                SUM(ft.gramagem_per_capita) as total_gramagem
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
