-- Migration: Verbose Debug Attribution GET RPC
-- Returns internal calculations in the response to diagnose specific issues

DROP FUNCTION IF EXISTS public.atrib_turmas_get_paginado;

CREATE OR REPLACE FUNCTION public.atrib_turmas_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10,
    p_id_turma uuid DEFAULT NULL,
    p_id_professor uuid DEFAULT NULL,
    p_ano smallint DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_result json;
    v_total int;
    v_count_simple int;
    v_count_filtered int;
    v_offset int;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- 1. Check simple count for this company
    SELECT COUNT(*) INTO v_count_simple
    FROM public.turmas t
    WHERE t.id_empresa = p_id_empresa;

    -- 2. Check filtered count
    SELECT COUNT(*) INTO v_count_filtered
    FROM public.turmas t
    LEFT JOIN public.atrib_atribuicao_turmas a ON a.id_turma = t.id AND a.id_empresa = t.id_empresa
    LEFT JOIN public.user_expandido u ON u.id = a.id_professor
    WHERE t.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR t.id = p_id_turma)
      AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
      AND (p_ano IS NULL OR CAST(t.ano AS smallint) = p_ano)
      AND (p_busca IS NULL OR p_busca = '' OR u.nome_completo ILIKE '%' || p_busca || '%');

    -- Use the filtered count for the official 'total'
    v_total := v_count_filtered;

    -- 3. Check what happens if we remove the Year cast/check
    -- Sometimes casting text '2026' to smallint causes issues if there's bad data?
    -- (Though unlikely to cause 0 count in simple query if simple query doesn't filter by year)

    -- Fetch Data
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            t.id as id_turma,
            t.ano as turma_ano,
            ae.nome as ano_etapa_nome,
            c.nome as classe_nome,
            e.nome as escola_nome,
            -- Attribution
            a.id as atribuicao_id,
            a.id_professor,
            a.ano as atribuicao_ano,
            u.nome_completo as professor_nome
        FROM public.turmas t
        JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        JOIN public.classe c ON c.id = t.id_classe
        JOIN public.escolas e ON e.id = t.id_escola
        LEFT JOIN public.atrib_atribuicao_turmas a ON a.id_turma = t.id AND a.id_empresa = t.id_empresa
        LEFT JOIN public.user_expandido u ON u.id = a.id_professor
        WHERE t.id_empresa = p_id_empresa
          AND (p_id_turma IS NULL OR t.id = p_id_turma)
          AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
          AND (p_ano IS NULL OR CAST(t.ano AS smallint) = p_ano)
          AND (p_busca IS NULL OR p_busca = '' OR u.nome_completo ILIKE '%' || p_busca || '%')
        ORDER BY t.ano DESC, ae.nome, c.nome
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) sub;

    RETURN json_build_object(
        'items', COALESCE(v_result, '[]'::json), 
        'total', v_total,
        'pages', CEIL(v_total::float / p_limite_itens_pagina::float),
        'debug', json_build_object(
            'p_id_empresa', p_id_empresa,
            'count_simple', v_count_simple,
            'count_filtered', v_count_filtered,
            'p_busca', p_busca
        )
    );
END;
$function$;
