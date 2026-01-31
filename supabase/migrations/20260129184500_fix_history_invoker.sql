-- Migration: Switch matricula_turma_get_historico to SECURITY INVOKER
-- Reason: User confirmed RLS is sufficient and SECURITY DEFINER environment issues were causing empty returns.
-- Removing SECURITY DEFINER and search_path hacks. Keeping robust joins/logic.

DROP FUNCTION IF EXISTS public.matricula_turma_get_historico(uuid, uuid);

CREATE OR REPLACE FUNCTION public.matricula_turma_get_historico(p_id_empresa uuid, p_id_matricula uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 -- SECURITY DEFINER removed
 -- search_path removed
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

    -- Standard Query (Invoker uses caller's path and permissions)
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', mt.id,
            'id_turma', mt.id_turma,
            'turma_nome', 
                COALESCE(ae.nome, '?') || ' - ' || 
                COALESCE(c.nome, '?') || ' - ' || 
                COALESCE(h.periodo || '', '?'),
            'ano', t.ano,
            'periodo', h.periodo, 
            'escola_nome', COALESCE(e.nome, 'Escola não encontrada'),
            'data_entrada', mt.data_entrada,
            'data_saida', mt.data_saida,
            'status', mt.status
        )
    ) INTO v_items
    FROM public.matricula_turma mt
    LEFT JOIN public.turmas t ON t.id = mt.id_turma
    LEFT JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
    LEFT JOIN public.classe c ON c.id = t.id_classe
    LEFT JOIN public.escolas e ON e.id = t.id_escola
    LEFT JOIN public.horarios_escola h ON h.id = t.id_horario
    WHERE mt.id_empresa = p_id_empresa
      AND mt.id_matricula = p_id_matricula;

    RETURN jsonb_build_object(
        'items', COALESCE(v_items, '[]'::jsonb),
        'debug_info', jsonb_build_object(
            'p_id_empresa', p_id_empresa,
            'p_id_matricula', p_id_matricula,
            'rows_found', v_count,
            'version', 'v6-invoker'
        )
    );
END;
$function$;
