-- Drop existing functions if they exist (to ensure clean recreation)
DROP FUNCTION IF EXISTS get_alunos_turma(UUID);
DROP FUNCTION IF EXISTS nxt_get_alunos_turma(UUID);
DROP FUNCTION IF EXISTS get_diario_semanal_aluno(UUID, UUID, UUID, DATE, DATE);
DROP FUNCTION IF EXISTS nxt_get_diario_semanal_aluno(UUID, UUID, UUID, DATE, DATE);

-- Create RPC to get students for a specific class (for dropdown)
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
        ue.nome AS aluno_nome
    FROM matricula_turma mt
    JOIN matriculas m ON mt.id_matricula = m.id
    JOIN user_expandido ue ON m.id_aluno = ue.id
    WHERE mt.id_turma = p_id_turma
    AND mt.status = 'ativa' -- Only active class assignments
    ORDER BY ue.nome;
END;
$$ LANGUAGE plpgsql;

-- Create RPC to get weekly attendance for a specific student
-- Returns attendance status for each component for a given week
CREATE OR REPLACE FUNCTION get_diario_semanal_aluno(
    p_id_empresa UUID,
    p_id_turma UUID,
    p_id_matricula UUID,
    p_data_inicio DATE,
    p_data_fim DATE
)
RETURNS TABLE (
    id_componente UUID,
    componente_nome TEXT,
    componente_cor TEXT,
    data DATE,
    status CHARACTER(1)
)
AS $$
BEGIN
    -- This query gets all components for the year/stage and joins with attendance records
    RETURN QUERY
    SELECT 
        c.id AS id_componente,
        c.nome::TEXT AS componente_nome,
        c.cor::TEXT AS componente_cor,
        d.data,
        d.status
    -- First, get the components associated with the turma's ano_etapa
    FROM turma t
    JOIN carga_horaria ch ON ch.id_ano_etapa = t.id_ano_etapa
    JOIN componente c ON c.id = ch.id_componente
    
    -- Then, LEFT JOIN with attendance records for the specific student within the date range
    LEFT JOIN diario_presenca d ON 
        d.id_componente = c.id AND 
        d.id_turma = t.id AND
        d.id_matricula_turma = (
            SELECT mt.id 
            FROM matricula_turma mt 
            WHERE mt.id_matricula = p_id_matricula 
            AND mt.id_turma = p_id_turma 
            AND mt.status = 'ativa'
            LIMIT 1
        ) AND
        d.data BETWEEN p_data_inicio AND p_data_fim
        
    WHERE t.id = p_id_turma
    AND t.id_empresa = p_id_empresa
    ORDER BY c.nome, d.data;
END;
$$ LANGUAGE plpgsql;
