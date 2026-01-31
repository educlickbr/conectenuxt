-- Migration: Debug Step 1 - Isolate matricula_turma (No Joins)
-- Reason: RPC returning empty items despite count=1. Isolating base table retrieval.

DROP FUNCTION IF EXISTS public.matricula_turma_get_historico(uuid, uuid);

CREATE OR REPLACE FUNCTION public.matricula_turma_get_historico(p_id_empresa uuid, p_id_matricula uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    v_items jsonb;
    v_count integer;
BEGIN
    -- Debug count
    SELECT count(*) INTO v_count
    FROM public.matricula_turma mt
    WHERE mt.id_empresa = p_id_empresa
      AND mt.id_matricula = p_id_matricula;

    -- STEP 1: Query ONLY the base table. No joins.
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', mt.id,
            'id_turma', mt.id_turma,
            'data_entrada', mt.data_entrada,
            'data_saida', mt.data_saida,
            'status', mt.status,
            'debug_note', 'base_table_only'
        )
    ) INTO v_items
    FROM public.matricula_turma mt
    WHERE mt.id_empresa = p_id_empresa
      AND mt.id_matricula = p_id_matricula;

    RETURN jsonb_build_object(
        'items', COALESCE(v_items, '[]'::jsonb),
        'debug_info', jsonb_build_object(
            'p_id_empresa', p_id_empresa,
            'p_id_matricula', p_id_matricula,
            'rows_found', v_count,
            'version', 'v7-step1-no-joins'
        )
    );
END;
$function$;
