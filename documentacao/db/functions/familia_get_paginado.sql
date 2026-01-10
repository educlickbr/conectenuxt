CREATE OR REPLACE FUNCTION public.familia_get_paginado(p_id_empresa uuid, p_pagina integer DEFAULT 1, p_limite_itens_pagina integer DEFAULT 10, p_busca text DEFAULT NULL::text)
 RETURNS TABLE(id uuid, nome_familia text, responsavel_principal text, qtd_alunos bigint, total_registros bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_offset integer;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    RETURN QUERY
    WITH familias_filtradas AS (
        SELECT
            f.id,
            f.nome_familia,
            ue.nome_completo as responsavel_nome
        FROM
            public.user_familia f
        LEFT JOIN
            public.user_expandido ue ON f.id_responsavel_principal = ue.id
        WHERE
            f.id_empresa = p_id_empresa
            AND (
                p_busca IS NULL OR 
                f.nome_familia ILIKE '%' || p_busca || '%' OR
                ue.nome_completo ILIKE '%' || p_busca || '%'
            )
    ),
    contagem_alunos AS (
        SELECT
            rua.id_familia,
            COUNT(DISTINCT rua.id_aluno) as qtd
        FROM
            public.user_responsavel_aluno rua
        GROUP BY
            rua.id_familia
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM familias_filtradas
    )
    SELECT
        ff.id,
        ff.nome_familia,
        ff.responsavel_nome as responsavel_principal,
        COALESCE(ca.qtd, 0) as qtd_alunos,
        tc.total as total_registros
    FROM
        familias_filtradas ff
    LEFT JOIN
        contagem_alunos ca ON ff.id = ca.id_familia
    CROSS JOIN
        total_count tc
    ORDER BY
        ff.nome_familia ASC
    LIMIT
        p_limite_itens_pagina
    OFFSET
        v_offset;
END;
$function$
