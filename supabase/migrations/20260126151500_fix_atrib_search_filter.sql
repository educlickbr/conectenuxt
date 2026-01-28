-- Migration: Fix Attribution GET RPCs - Fix search filter to allow NULL professors
-- The issue: when p_busca is empty string, it tries to match NULL professor names

DROP FUNCTION IF EXISTS public.atrib_turmas_get_paginado;
DROP FUNCTION IF EXISTS public.atrib_componentes_get_paginado;

-- ============================================================================
-- 1. ATRIB_TURMAS_GET_PAGINADO (Show all Turmas, LEFT JOIN attributions)
-- ============================================================================
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
    v_offset int;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- Calculate Total Count (based on Turmas, not attributions)
    SELECT COUNT(*) INTO v_total
    FROM public.turmas t
    LEFT JOIN public.atrib_atribuicao_turmas a ON a.id_turma = t.id AND a.id_empresa = t.id_empresa
    LEFT JOIN public.user_expandido u ON u.id = a.id_professor
    WHERE t.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR t.id = p_id_turma)
      AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
      AND (p_ano IS NULL OR CAST(t.ano AS smallint) = p_ano)
      AND (p_busca IS NULL OR p_busca = '' OR u.nome_completo ILIKE '%' || p_busca || '%');

    -- Fetch Data
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            -- Turma info (always present)
            t.id as id_turma,
            t.ano as turma_ano,
            ae.nome as ano_etapa_nome,
            c.nome as classe_nome,
            e.nome as escola_nome,
            -- Attribution info (may be NULL if no attribution exists)
            a.id as atribuicao_id,
            a.id_professor,
            a.ano as atribuicao_ano,
            a.data_inicio,
            a.data_fim,
            a.motivo_substituicao,
            a.nivel_substituicao,
            a.created_at,
            -- Professor info (may be NULL)
            u.nome_completo as professor_nome,
            u.email as professor_email
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
        'pages', CEIL(v_total::float / p_limite_itens_pagina::float)
    );
END;
$function$;


-- ============================================================================
-- 2. ATRIB_COMPONENTES_GET_PAGINADO (Show all Carga Horária, LEFT JOIN attributions)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.atrib_componentes_get_paginado(
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
    v_offset int;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- Calculate Total Count (based on Carga Horária, not attributions)
    SELECT COUNT(*) INTO v_total
    FROM public.carga_horaria ch
    JOIN public.turmas t ON t.id_ano_etapa = ch.id_ano_etapa AND t.id_empresa = ch.id_empresa
    LEFT JOIN public.atrib_atribuicao_componentes a ON a.id_carga_horaria = ch.uuid AND a.id_turma = t.id AND a.id_empresa = ch.id_empresa
    LEFT JOIN public.user_expandido u ON u.id = a.id_professor
    WHERE ch.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR t.id = p_id_turma)
      AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
      AND (p_ano IS NULL OR CAST(t.ano AS smallint) = p_ano)
      AND (p_busca IS NULL OR p_busca = '' OR u.nome_completo ILIKE '%' || p_busca || '%');

    -- Fetch Data
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            -- Turma info (always present)
            t.id as id_turma,
            t.ano as turma_ano,
            ae.nome as ano_etapa_nome,
            c.nome as classe_nome,
            e.nome as escola_nome,
            -- Carga Horária / Componente info (always present)
            ch.uuid as id_carga_horaria,
            ch.carga_horaria,
            comp.nome as componente_nome,
            -- Attribution info (may be NULL if no attribution exists)
            a.id as atribuicao_id,
            a.id_professor,
            a.ano as atribuicao_ano,
            a.data_inicio,
            a.data_fim,
            a.motivo_substituicao,
            a.nivel_substituicao,
            a.created_at,
            -- Professor info (may be NULL)
            u.nome_completo as professor_nome,
            u.email as professor_email
        FROM public.carga_horaria ch
        JOIN public.componente comp ON comp.uuid = ch.id_componente
        JOIN public.turmas t ON t.id_ano_etapa = ch.id_ano_etapa AND t.id_empresa = ch.id_empresa
        JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        JOIN public.classe c ON c.id = t.id_classe
        JOIN public.escolas e ON e.id = t.id_escola
        LEFT JOIN public.atrib_atribuicao_componentes a ON a.id_carga_horaria = ch.uuid AND a.id_turma = t.id AND a.id_empresa = ch.id_empresa
        LEFT JOIN public.user_expandido u ON u.id = a.id_professor
        WHERE ch.id_empresa = p_id_empresa
          AND (p_id_turma IS NULL OR t.id = p_id_turma)
          AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
          AND (p_ano IS NULL OR CAST(t.ano AS smallint) = p_ano)
          AND (p_busca IS NULL OR p_busca = '' OR u.nome_completo ILIKE '%' || p_busca || '%')
        ORDER BY t.ano DESC, ae.nome, c.nome, comp.nome
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
