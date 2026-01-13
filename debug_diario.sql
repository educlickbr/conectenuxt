-- Query 1: Check raw Matricula Turma entries for the specific Turma
SELECT
    mt.id as id_mt,
    mt.id_turma,
    mt.id_matricula,
    mt.status as status_mt,
    mt.data_entrada,
    mt.data_saida,
    mt.id_empresa as mt_empresa
FROM
    public.matricula_turma mt
WHERE
    mt.id_turma = 'a174897e-1e84-4fb8-9a6a-6c896aae0d02';

-- Query 2: Check Matricula Status and Company Match
SELECT
    m.id as id_matricula,
    m.status as status_m,
    m.id_empresa as m_empresa,
    m.id_aluno
FROM
    public.matriculas m
WHERE
    m.id IN (
        SELECT
            id_matricula
        FROM
            public.matricula_turma
        WHERE
            id_turma = 'a174897e-1e84-4fb8-9a6a-6c896aae0d02'
    );

-- Query 3: Check User Status and Company Match
SELECT
    u.id as id_aluno,
    u.nome_completo,
    u.soft_delete,
    u.id_empresa as u_empresa
FROM
    public.user_expandido u
WHERE
    u.id IN (
        SELECT
            id_aluno
        FROM
            public.matriculas
        WHERE
            id IN (
                SELECT
                    id_matricula
                FROM
                    public.matricula_turma
                WHERE
                    id_turma = 'a174897e-1e84-4fb8-9a6a-6c896aae0d02'
            )
    );

-- Query 4: Simulate the Function Logic Step-by-Step with Columns to Identifiy Mismatch
SELECT
    mt.id as id_mt,
    mt.status as mt_status_is_ativa,
    (mt.status = 'ativa') as pass_mt_status,
    m.status as m_status_is_ativa,
    (m.status = 'ativa') as pass_m_status,
    u.soft_delete as u_soft_delete,
    (u.soft_delete IS FALSE) as pass_soft_delete,
    mt.id_empresa,
    (
        mt.id_empresa = '0709fe87-3b42-4f1d-9919-51dea9228cfd'
    ) as pass_empresa_check
FROM
    public.matricula_turma mt
    JOIN public.matriculas m ON m.id = mt.id_matricula
    JOIN public.user_expandido u ON u.id = m.id_aluno
WHERE
    mt.id_turma = 'a174897e-1e84-4fb8-9a6a-6c896aae0d02';