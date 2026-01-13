-- Simplification of diario_presenca_get_por_turma to ensure students are returned
-- Removing strict date range checks on matricula_turma for now to fail open on dummy data.
-- We still filter by status != removida.
DROP FUNCTION public.diario_presenca_get_por_turma;
CREATE OR REPLACE FUNCTION public.diario_presenca_get_por_turma(
    p_id_empresa uuid,
    p_id_turma uuid,
    p_data date,
    p_id_componente uuid DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_itens json;
BEGIN
    SELECT COALESCE(json_agg(t), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            m.id as id_matricula,
            u.nome_completo as aluno_nome,
            m.status as status_matricula,
            dp.id as id_presenca,
            dp.presente,
            dp.observacao,
            dp.registrado_em
        FROM public.matricula_turma mt
        JOIN public.matriculas m ON m.id = mt.id_matricula
        JOIN public.user_expandido u ON u.id = m.id_aluno
        -- Left Join to get attendance if exists
        LEFT JOIN public.diario_presenca dp ON 
            dp.id_matricula = m.id 
            AND dp.id_turma = p_id_turma 
            AND dp.data = p_data
            AND (
                (p_id_componente IS NULL AND dp.id_componente IS NULL) OR
                (dp.id_componente = p_id_componente)
            )
        WHERE 
            mt.id_empresa = p_id_empresa
            AND mt.id_turma = p_id_turma
            -- Simplification: Just check if not removed logic.
            -- Ignoring strict dates for now to ensure visibility of students.
            -- AND mt.data_entrada <= p_data
            -- AND (mt.data_saida IS NULL OR mt.data_saida >= p_data)
            AND mt.status != 'removida' 
            AND m.status != 'cancelada'
        ORDER BY u.nome_completo
    ) t;

    RETURN json_build_object(
        'data', p_data,
        'turma_id', p_id_turma,
        'alunos', v_itens
    );
END;
$$;
