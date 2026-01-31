-- Migration: Make matricula_turma_get_historico robust with LEFT JOINs
-- Prevents empty returns if related tables (ano_etapa, classe, etc) are missing data.
drop function public.matricula_turma_get_historico;
CREATE OR REPLACE FUNCTION public.matricula_turma_get_historico(p_id_empresa uuid, p_id_matricula uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
DECLARE
    v_items jsonb;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', mt.id,
            'id_turma', mt.id_turma,
            'turma_nome', 
                COALESCE(ae.nome, '?') || ' - ' || 
                COALESCE(c.nome, '?') || ' - ' || 
                COALESCE(h.periodo, '?'),
            'ano', t.ano,
            'periodo', h.periodo,
            'escola_nome', COALESCE(e.nome, 'Escola não encontrada'),
            'data_entrada', mt.data_entrada,
            'data_saida', mt.data_saida,
            'status', mt.status
        ) ORDER BY mt.data_entrada DESC
    ) INTO v_items
    FROM public.matricula_turma mt
    LEFT JOIN public.turmas t ON t.id = mt.id_turma
    LEFT JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
    LEFT JOIN public.classe c ON c.id = t.id_classe
    LEFT JOIN public.escolas e ON e.id = t.id_escola
    LEFT JOIN public.horarios_escola h ON h.id = t.id_horario
    WHERE mt.id_empresa = p_id_empresa
      AND mt.id_matricula = p_id_matricula;

    RETURN jsonb_build_object('items', COALESCE(v_items, '[]'::jsonb));
END;
$function$;
