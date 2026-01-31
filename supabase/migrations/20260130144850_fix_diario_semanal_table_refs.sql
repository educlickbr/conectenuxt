-- Fix table names and column references in get_diario_semanal_aluno
DROP FUNCTION IF EXISTS get_diario_semanal_aluno(UUID, UUID, UUID, DATE, DATE);

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
        c.uuid AS id_componente,
        c.nome::TEXT AS componente_nome,
        c.cor::TEXT AS componente_cor,
        d.data,
        d.status
    -- First, get the components associated with the turma's ano_etapa
    FROM turmas t
    JOIN carga_horaria ch ON ch.id_ano_etapa = t.id_ano_etapa
    JOIN componente c ON c.uuid = ch.id_componente
    
    -- Then, LEFT JOIN with attendance records for the specific student within the date range
    LEFT JOIN diario_presenca d ON 
        d.id_componente = c.uuid AND 
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
