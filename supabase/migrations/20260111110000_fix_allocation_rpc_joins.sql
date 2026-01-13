-- Fix RPC matricula_turma_get_por_matricula Joins
-- Data: 2026-01-11 11:00


DROP FUNCTION public.matricula_turma_get_por_matricula;
CREATE OR REPLACE FUNCTION public.matricula_turma_get_por_matricula(
    p_id_empresa uuid,
    p_id_matricula uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_itens json;
BEGIN
    SELECT COALESCE(json_agg(t), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            mt.id,
            mt.id_matricula,
            mt.id_turma,
            mt.data_entrada,
            mt.data_saida,
            mt.status,
            -- Nome composto da turma: "1º Ano A"
            t.nome as turma_nome,
            -- Detalhes extras para exibição
            e.nome as escola_nome,
            h.periodo::text as periodo,
            t.ano as turma_ano,
            h.hora_completo
        FROM public.matricula_turma mt
        JOIN public.turmas t ON t.id = mt.id_turma
        JOIN public.escolas e ON t.id_escola = e.id
        JOIN public.ano_etapa ae ON t.id_ano_etapa = ae.id
        JOIN public.classe c ON t.id_classe = c.id
        JOIN public.horarios_escola h ON t.id_horario = h.id
        WHERE mt.id_empresa = p_id_empresa
          AND mt.id_matricula = p_id_matricula
        ORDER BY mt.data_entrada DESC, mt.criado_em DESC
    ) t;

    RETURN json_build_object(
        'itens', v_itens
    );
END;
$$;

GRANT ALL ON FUNCTION public.matricula_turma_get_por_matricula(uuid, uuid) TO anon;
GRANT ALL ON FUNCTION public.matricula_turma_get_por_matricula(uuid, uuid) TO authenticated;
GRANT ALL ON FUNCTION public.matricula_turma_get_por_matricula(uuid, uuid) TO service_role;
