DROP FUNCTION public.turmas_get_paginado;
CREATE OR REPLACE FUNCTION public.turmas_get_paginado(
    p_id_empresa uuid,
    p_pagina integer DEFAULT 1,
    p_limite_itens_pagina integer DEFAULT 10,
    p_busca text DEFAULT NULL::text
)
RETURNS TABLE(
    id uuid,
    id_escola uuid,
    id_ano_etapa uuid,
    id_classe uuid,
    id_horario uuid,
    ano text,
    nome_escola text,
    nome_turma text,
    periodo text,
    hora_inicio text,
    hora_fim text,
    hora_completo text,
    total_registros bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_offset integer;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    RETURN QUERY
    WITH turmas_filtradas AS (
        SELECT
            t.id,
            t.id_escola,
            t.id_ano_etapa,
            t.id_classe,
            t.id_horario,
            t.ano,
            e.nome as nome_escola,
            (ae.nome || ' ' || c.nome) as nome_turma,
            h.periodo::text as periodo,
            h.hora_inicio,
            h.hora_fim,
            h.hora_completo
        FROM
            public.turmas t
        JOIN public.escolas e ON t.id_escola = e.id
        JOIN public.ano_etapa ae ON t.id_ano_etapa = ae.id
        JOIN public.classe c ON t.id_classe = c.id
        JOIN public.horarios_escola h ON t.id_horario = h.id
        WHERE
            t.id_empresa = p_id_empresa
            AND (
                p_busca IS NULL OR 
                e.nome ILIKE '%' || p_busca || '%' OR
                ae.nome ILIKE '%' || p_busca || '%' OR
                c.nome ILIKE '%' || p_busca || '%' OR
                t.ano ILIKE '%' || p_busca || '%'
            )
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM turmas_filtradas
    )
    SELECT
        tf.id,
        tf.id_escola,
        tf.id_ano_etapa,
        tf.id_classe,
        tf.id_horario,
        tf.ano,
        tf.nome_escola,
        tf.nome_turma,
        tf.periodo,
        tf.hora_inicio,
        tf.hora_fim,
        tf.hora_completo,
        tc.total as total_registros
    FROM
        turmas_filtradas tf
    CROSS JOIN
        total_count tc
    ORDER BY
        tf.nome_escola ASC, tf.ano DESC, tf.nome_turma ASC
    LIMIT
        p_limite_itens_pagina
    OFFSET
        v_offset;
END;
$$;
