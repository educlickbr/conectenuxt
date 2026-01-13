-- Migration: Refactor diario_presenca_get_por_turma to return unified student + presenca data
-- Date: 2026-01-12
-- Description: Drops existing function and recreates it with LEFT JOIN logic to return all active students in the class
-- along with their attendance status for the given date (if any).

DROP FUNCTION IF EXISTS public.diario_presenca_get_por_turma(uuid, uuid, date, uuid);

CREATE OR REPLACE FUNCTION public.diario_presenca_get_por_turma(
    p_id_empresa uuid,
    p_id_turma uuid,
    p_data date,
    p_id_componente uuid DEFAULT NULL
)
RETURNS TABLE(
    -- Student Info
    id_matricula uuid,
    aluno_nome text,
    aluno_avatar text, -- Placeholder or actual URL if we had it, using just text for now
    
    -- Class Context
    turma_nome text,
    escola_nome text,
    turno_nome text,
    ano_etapa_nome text,
    
    -- Presence Info
    id_presenca uuid,
    presente boolean,
    observacao text,
    data_presenca date,
    registrado_em timestamp with time zone,
    
    -- Metadata
    status_matricula text
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        m.id AS id_matricula,
        u.nome_completo AS aluno_nome,
        NULL::text AS aluno_avatar, -- Placeholder
        
        -- Joining Context Data
        t.nome AS turma_nome,
        e.nome AS escola_nome,
        tu.nome AS turno_nome,
        ae.nome AS ano_etapa_nome,
        
        -- Presence Data (Null if no record)
        dp.id AS id_presenca,
        dp.presente,
        dp.observacao,
        dp.data AS data_presenca,
        dp.registrado_em,
        
        m.status AS status_matricula
    FROM
        public.matricula_turma mt
    JOIN
        public.matriculas m ON m.id = mt.id_matricula
    JOIN
        public.user_expandido u ON u.id = m.id_aluno
    JOIN
        public.turmas t ON t.id = mt.id_turma
    JOIN
        public.escolas e ON e.id = t.id_escola
    LEFT JOIN
        public.turnos tu ON tu.id = t.id_turno
    JOIN
        public.ano_etapa ae ON ae.id = t.id_ano_etapa

    -- Left Join Presence for the specific date/component
    LEFT JOIN
        public.diario_presenca dp ON
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
        -- Ensure active student
        AND mt.status = 'ativa'
        AND m.status = 'ativa'
        AND u.soft_delete IS FALSE
        
    ORDER BY
        u.nome_completo ASC;
END;
$function$;

-- Grant permission
GRANT EXECUTE ON FUNCTION public.diario_presenca_get_por_turma(uuid, uuid, date, uuid) TO authenticated;
