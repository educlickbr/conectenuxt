-- Migration: Fix mrd_refeicao_tipo_get_all ordering issue
-- Date: 2026-02-05

DROP FUNCTION IF EXISTS public.mrd_refeicao_tipo_get_all(uuid);

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
    FROM (
        SELECT *
        FROM public.mrd_refeicao_tipo t
        WHERE t.empresa_id = p_id_empresa
          AND t.ativo = true
        ORDER BY t.ordem ASC, t.nome ASC
    ) t;

    RETURN coalesce(v_result, '[]'::jsonb);
END;
$function$;
