-- Migration: Add p_id_componente filter to atrib_componentes_get_paginado

CREATE OR REPLACE FUNCTION public.atrib_componentes_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10,
    p_id_turma uuid DEFAULT NULL,
    p_id_professor uuid DEFAULT NULL,
    p_ano smallint DEFAULT NULL,
    p_id_componente uuid DEFAULT NULL -- New Parameter
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_result json;
    v_total int;
    v_offset int;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- Calculate Total Count
    SELECT COUNT(*) INTO v_total
    FROM public.atrib_atribuicao_componentes a
    JOIN public.turmas t ON t.id = a.id_turma
    JOIN public.carga_horaria ch ON ch.uuid = a.id_carga_horaria
    JOIN public.componente comp ON comp.uuid = ch.id_componente
    JOIN public.user_expandido u ON u.id = a.id_professor
    WHERE a.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR a.id_turma = p_id_turma)
      AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
      AND (p_ano IS NULL OR a.ano = p_ano)
      AND (p_id_componente IS NULL OR comp.uuid = p_id_componente) -- New Filter
      AND (p_busca IS NULL OR u.nome_completo ILIKE '%' || p_busca || '%');

    -- Fetch Data
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            a.id,
            a.id_turma,
            a.id_carga_horaria,
            a.id_professor,
            a.ano,
            a.data_inicio,
            a.data_fim,
            a.motivo_substituicao,
            a.nivel_substituicao,
            a.created_at,
            -- Turma info
            t.ano as turma_ano,
            ae.nome as ano_etapa_nome,
            c.nome as classe_nome,
            e.nome as escola_nome,
            -- Carga Horária / Componente info
            ch.carga_horaria,
            comp.nome as componente_nome,
            comp.uuid as componente_id,
            -- Professor info
            u.nome_completo as professor_nome,
            u.email as professor_email,
            -- RPC History Logic (Similar to Turmas)
            (
                SELECT json_agg(h ORDER BY h.data_inicio DESC)
                FROM public.atrib_atribuicao_componentes h
                JOIN public.user_expandido hu ON hu.id = h.id_professor
                WHERE h.id_turma = a.id_turma 
                  AND h.id_carga_horaria = a.id_carga_horaria
                  AND h.ano = a.ano
                  AND h.id_empresa = p_id_empresa
            ) as historico
        FROM public.atrib_atribuicao_componentes a
        JOIN public.turmas t ON t.id = a.id_turma
        JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        JOIN public.classe c ON c.id = t.id_classe
        JOIN public.escolas e ON e.id = t.id_escola
        JOIN public.carga_horaria ch ON ch.uuid = a.id_carga_horaria
        JOIN public.componente comp ON comp.uuid = ch.id_componente
        JOIN public.user_expandido u ON u.id = a.id_professor
        WHERE a.id_empresa = p_id_empresa
          AND (p_id_turma IS NULL OR a.id_turma = p_id_turma)
          AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
          AND (p_ano IS NULL OR a.ano = p_ano)
          AND (p_id_componente IS NULL OR comp.uuid = p_id_componente) -- New Filter
          AND (p_busca IS NULL OR u.nome_completo ILIKE '%' || p_busca || '%')
          -- Active only filter? Usually for lists we want distinct active ones.
          -- But for now respecting existing logic (all rows).
          -- Ideally we should filter `data_fim IS NULL` if we want "Active List", but standard CRUD usually lists all.
          -- However, user sees "Active" and "History".
          
        ORDER BY a.created_at DESC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) sub;

    RETURN json_build_object(
        'items', COALESCE(v_result, '[]'::json), 
        'total', v_total,
        'pages', CEIL(v_total::float / p_limite_itens_pagina::float)
    );
END;
$function$;
