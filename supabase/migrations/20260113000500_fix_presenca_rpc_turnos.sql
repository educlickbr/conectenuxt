-- Migration: Fix diario_presenca_get_por_turma to use horarios_escola instead of turnos
-- Date: 2026-01-13
-- Description: Updates the function to correctly join with horarios_escola to get the shift period.

CREATE OR REPLACE FUNCTION public.diario_presenca_get_por_turma(
    p_id_empresa uuid,
    p_id_turma uuid,
    p_data date,
    p_id_componente uuid DEFAULT NULL
)
RETURNS TABLE(
    id_matricula uuid,
    aluno_nome text,
    aluno_avatar text,
    turma_nome text,
    escola_nome text,
    turno_nome text,
    ano_etapa_nome text,
    id_presenca uuid,
    presente boolean,
    observacao text,
    data_presenca date,
    registrado_em timestamp with time zone,
    status_matricula text
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        m.id AS id_matricula,
        u.nome_completo AS aluno_nome,
        NULL::text AS aluno_avatar,
        
        -- Joining Context Data
        t.nome AS turma_nome,
        e.nome AS escola_nome,
        he.periodo::text AS turno_nome, -- Using periodo from horarios_escola
        ae.nome AS ano_etapa_nome,
        
        -- Presence Data
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
        public.horarios_escola he ON he.id = t.id_horario
    JOIN
        public.ano_etapa ae ON ae.id = t.id_ano_etapa

    -- Left Join Presence
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
        AND mt.status = 'ativa'
        AND m.status = 'ativa'
        AND u.soft_delete IS FALSE
        
    ORDER BY
        u.nome_completo ASC;
END;
$function$;
