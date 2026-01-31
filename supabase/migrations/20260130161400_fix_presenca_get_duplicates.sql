-- Fix diario_presenca_get_por_turma to handle NULL p_id_componente correctly (Daily View)
-- When p_id_componente is NULL, we should return a single status per student (e.g. from the first found component)
-- preventing duplicates in the student list.

DROP FUNCTION IF EXISTS public.diario_presenca_get_por_turma;

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
    status public.tipo_presenca_enum,
    observacao text,
    data_presenca date,
    registrado_em timestamp with time zone,
    status_matricula text
)
LANGUAGE plpgsql
STABLE
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        m.id AS id_matricula,
        u.nome_completo AS aluno_nome,
        NULL::text AS aluno_avatar,
        
        -- Joining Context Data
        c.nome AS turma_nome,
        e.nome AS escola_nome,
        he.periodo::text AS turno_nome,
        ae.nome AS ano_etapa_nome,
        
        -- Presence Data
        dp.id AS id_presenca,
        dp.status,
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
    LEFT JOIN 
        public.classe c ON c.id = t.id_classe
    JOIN
        public.escolas e ON e.id = t.id_escola
    LEFT JOIN
        public.horarios_escola he ON he.id = t.id_horario
    JOIN
        public.ano_etapa ae ON ae.id = t.id_ano_etapa

    -- Left Join Presence
    -- Use LATERAL to get exactly one presence record per student
    LEFT JOIN LATERAL (
        SELECT 
            d.id,
            d.status,
            d.observacao,
            d.data,
            d.registrado_em
        FROM public.diario_presenca d
        WHERE d.id_matricula = m.id
        AND d.id_turma = p_id_turma
        AND d.data = p_data
        AND (p_id_componente IS NULL OR d.id_componente = p_id_componente)
        ORDER BY d.registrado_em DESC -- Get latest or just any
        LIMIT 1
    ) dp ON TRUE

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
