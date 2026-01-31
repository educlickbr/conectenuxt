-- Fix column name in get_alunos_turma (nome -> nome_completo)
DROP FUNCTION IF EXISTS get_alunos_turma(UUID);

CREATE OR REPLACE FUNCTION get_alunos_turma(
    p_id_turma UUID
)
RETURNS TABLE (
    id_matricula UUID,
    aluno_nome TEXT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mt.id_matricula,
        ue.nome_completo AS aluno_nome
    FROM matricula_turma mt
    JOIN matriculas m ON mt.id_matricula = m.id
    JOIN user_expandido ue ON m.id_aluno = ue.id
    WHERE mt.id_turma = p_id_turma
    AND mt.status = 'ativa' -- Only active class assignments
    ORDER BY ue.nome_completo;
END;
$$ LANGUAGE plpgsql;
