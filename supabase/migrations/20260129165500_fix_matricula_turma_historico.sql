-- Migration: Fix matricula_turma_get_historico RPC
-- Reason: The 'turmas' table does not have 'nome_turma'. We need to join with ano_etapa and classe to build the name.

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
            -- Construct the name: "Ano Etapa - Classe - Periodo"
            'turma_nome', ae.nome || ' - ' || c.nome || ' - ' || h.periodo, 
            'ano', t.ano,
            'periodo', h.periodo,
            'escola_nome', e.nome,
            'data_entrada', mt.data_entrada,
            'data_saida', mt.data_saida,
            'status', mt.status
        ) ORDER BY mt.data_entrada DESC
    ) INTO v_items
    FROM public.matricula_turma mt
    JOIN public.turmas t ON t.id = mt.id_turma
    JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
    JOIN public.classe c ON c.id = t.id_classe
    LEFT JOIN public.escolas e ON e.id = t.id_escola
    LEFT JOIN public.horarios_escola h ON h.id = t.id_horario
    WHERE mt.id_empresa = p_id_empresa
      AND mt.id_matricula = p_id_matricula;

    RETURN jsonb_build_object('items', COALESCE(v_items, '[]'::jsonb));
END;
$function$;
