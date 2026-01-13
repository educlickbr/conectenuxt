-- Diagnostic version: Use LEFT JOINs to see if the root matricula_turma entries are visible.
-- If this returns rows with null names, it means User data is blocked/missing.
-- If this returns 0 rows, it means matricula_turma itself is blocked/missing.

DROP FUNCTION IF EXISTS public.diario_presenca_get_por_turma;

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
            COALESCE(u.nome_completo, 'Nome Indisponível (RLS/Missing)') as aluno_nome,
            m.status as status_matricula,
            dp.id as id_presenca,
            dp.presente,
            dp.observacao,
            dp.registrado_em
        FROM public.matricula_turma mt
        -- Changed to LEFT JOIN for diagnostics
        LEFT JOIN public.matriculas m ON m.id = mt.id_matricula
        LEFT JOIN public.user_expandido u ON u.id = m.id_aluno
        LEFT JOIN public.diario_presenca dp ON 
            dp.id_matricula = m.id 
            AND dp.id_turma = p_id_turma 
            AND dp.data = p_data
            AND (
                (p_id_componente IS NULL AND dp.id_componente IS NULL) OR
                (dp.id_componente = p_id_componente)
            )
        WHERE 
            mt.id_turma = p_id_turma
            AND mt.id_empresa = p_id_empresa
            AND mt.status = 'ativa'
            -- Relaxed filters on joined tables to null checks if they are missing
            AND (m.status IS NULL OR m.status = 'ativa')
            AND (u.soft_delete IS NULL OR u.soft_delete IS FALSE)
        ORDER BY u.nome_completo
    ) t;

    RETURN json_build_object(
        'data', p_data,
        'turma_id', p_id_turma,
        'alunos', v_itens
    );
END;
$$;
