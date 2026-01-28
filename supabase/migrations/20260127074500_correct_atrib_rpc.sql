-- Migration: Corrected Attribution RPCs
-- Ensures TURMAS is the master table (LEFT JOIN to Attribution)
-- Fixes Ano type mismatch (Text in Turmas vs Int in Attribution)
-- Removes valid references (no avatar_url)
-- Handles filtering correctly (p_busca against Left Joined tables)

DROP FUNCTION IF EXISTS public.atrib_turmas_get_paginado;
DROP FUNCTION IF EXISTS public.atrib_componentes_get_paginado;

-- ============================================================================
-- 1. ATRIB_TURMAS_GET_PAGINADO
-- ============================================================================
CREATE OR REPLACE FUNCTION public.atrib_turmas_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10,
    p_id_turma uuid DEFAULT NULL,
    p_id_professor uuid DEFAULT NULL,
    p_ano int DEFAULT NULL,
    p_id_escola uuid DEFAULT NULL,
    p_id_ano_etapa uuid DEFAULT NULL,
    p_id_classe uuid DEFAULT NULL
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

    -- Calculate Total Count from TURMAS (Master Table)
    SELECT COUNT(*) INTO v_total
    FROM public.turmas t
    -- Join ACTIVE attribution (if exists)
    LEFT JOIN public.atrib_atribuicao_turmas a ON a.id_turma = t.id AND a.id_empresa = t.id_empresa AND a.data_fim IS NULL
    LEFT JOIN public.user_expandido u ON u.id = a.id_professor
    WHERE t.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR t.id = p_id_turma)
      -- Filters on Turma
      AND (p_id_escola IS NULL OR t.id_escola = p_id_escola)
      AND (p_id_ano_etapa IS NULL OR t.id_ano_etapa = p_id_ano_etapa)
      AND (p_id_classe IS NULL OR t.id_classe = p_id_classe)
      -- Handle Ano Text vs Int
      AND (p_ano IS NULL OR CAST(t.ano AS integer) = p_ano)
      -- Filters on Attribution
      AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
      -- Search
      AND (p_busca IS NULL OR p_busca = '' OR u.nome_completo ILIKE '%' || p_busca || '%');

    -- Fetch Data
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            -- Turma info
            t.id as id_turma,
            t.ano as turma_ano,
            ae.nome as ano_etapa_nome,
            c.nome as classe_nome,
            e.nome as escola_nome,
            
            -- Active Attribution info (can be NULL)
            a.id as atribuicao_id,
            a.id_professor,
            a.ano as atribuicao_ano,
            a.data_inicio,
            a.data_fim,
            a.motivo_substituicao,
            a.nivel_substituicao,
            a.created_at,
            
            -- Active Professor info (can be NULL)
            u.nome_completo as professor_nome,
            u.email as professor_email,
            
            -- History (Substitutions) as JSON
            -- Returns NULL if no history, or empty array
            COALESCE((
                SELECT json_agg(hist)
                FROM (
                    SELECT 
                        h.id, h.id_professor, hu.nome_completo, h.data_inicio, h.data_fim
                    FROM public.atrib_atribuicao_turmas h
                    LEFT JOIN public.user_expandido hu ON hu.id = h.id_professor
                    WHERE h.id_turma = t.id 
                      AND h.id_empresa = p_id_empresa
                      AND h.data_fim IS NOT NULL 
                    ORDER BY h.data_inicio DESC
                ) hist
            ), '[]'::json) as historico

        FROM public.turmas t
        JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        JOIN public.classe c ON c.id = t.id_classe
        JOIN public.escolas e ON e.id = t.id_escola
        
        -- Join ONLY ACTIVE attribution
        LEFT JOIN public.atrib_atribuicao_turmas a ON a.id_turma = t.id AND a.id_empresa = t.id_empresa AND a.data_fim IS NULL
        LEFT JOIN public.user_expandido u ON u.id = a.id_professor
        
        WHERE t.id_empresa = p_id_empresa
          AND (p_id_turma IS NULL OR t.id = p_id_turma)
          AND (p_id_escola IS NULL OR t.id_escola = p_id_escola)
          AND (p_id_ano_etapa IS NULL OR t.id_ano_etapa = p_id_ano_etapa)
          AND (p_id_classe IS NULL OR t.id_classe = p_id_classe)
          AND (p_ano IS NULL OR CAST(t.ano AS integer) = p_ano)
          AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
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
-- 2. ATRIB_COMPONENTES_GET_PAGINADO
-- ============================================================================
CREATE OR REPLACE FUNCTION public.atrib_componentes_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10,
    p_id_turma uuid DEFAULT NULL,
    p_id_professor uuid DEFAULT NULL,
    p_ano int DEFAULT NULL,
    p_id_escola uuid DEFAULT NULL,
    p_id_ano_etapa uuid DEFAULT NULL,
    p_id_classe uuid DEFAULT NULL
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

    -- Calculate Total Count from CARGA_HORARIA (Master Table)
    SELECT COUNT(*) INTO v_total
    FROM public.carga_horaria ch
    JOIN public.turmas t ON t.id_ano_etapa = ch.id_ano_etapa AND t.id_empresa = ch.id_empresa
    -- Join ACTIVE attribution
    LEFT JOIN public.atrib_atribuicao_componentes a ON a.id_carga_horaria = ch.uuid AND a.id_turma = t.id AND a.id_empresa = ch.id_empresa AND a.data_fim IS NULL
    LEFT JOIN public.user_expandido u ON u.id = a.id_professor
    WHERE ch.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR t.id = p_id_turma)
      AND (p_id_escola IS NULL OR t.id_escola = p_id_escola)
      AND (p_id_ano_etapa IS NULL OR t.id_ano_etapa = p_id_ano_etapa)
      AND (p_id_classe IS NULL OR t.id_classe = p_id_classe)
      AND (p_ano IS NULL OR CAST(t.ano AS integer) = p_ano)
      AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
      AND (p_busca IS NULL OR p_busca = '' OR u.nome_completo ILIKE '%' || p_busca || '%');

    -- Fetch Data
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            -- Turma info
            t.id as id_turma,
            t.ano as turma_ano,
            ae.nome as ano_etapa_nome,
            c.nome as classe_nome,
            e.nome as escola_nome,
            
            -- Componente info
            ch.uuid as id_carga_horaria,
            ch.carga_horaria,
            comp.nome as componente_nome,
            
            -- Active Attribution info
            a.id as atribuicao_id,
            a.id_professor,
            a.ano as atribuicao_ano,
            a.data_inicio,
            a.data_fim,
            a.motivo_substituicao,
            a.nivel_substituicao,
            a.created_at,
            
            -- Active Professor info
            u.nome_completo as professor_nome,
            u.email as professor_email,
            
            -- History (Substitutions) as JSON
            COALESCE((
                SELECT json_agg(hist)
                FROM (
                    SELECT 
                        h.id, h.id_professor, hu.nome_completo, h.data_inicio, h.data_fim
                    FROM public.atrib_atribuicao_componentes h
                    LEFT JOIN public.user_expandido hu ON hu.id = h.id_professor
                    WHERE h.id_carga_horaria = ch.uuid 
                      AND h.id_turma = t.id
                      AND h.id_empresa = p_id_empresa
                      AND h.data_fim IS NOT NULL 
                    ORDER BY h.data_inicio DESC
                ) hist
            ), '[]'::json) as historico

        FROM public.carga_horaria ch
        JOIN public.componente comp ON comp.uuid = ch.id_componente
        JOIN public.turmas t ON t.id_ano_etapa = ch.id_ano_etapa AND t.id_empresa = ch.id_empresa
        JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        JOIN public.classe c ON c.id = t.id_classe
        JOIN public.escolas e ON e.id = t.id_escola
        
        -- Join ACTIVE attribution
        LEFT JOIN public.atrib_atribuicao_componentes a ON a.id_carga_horaria = ch.uuid AND a.id_turma = t.id AND a.id_empresa = ch.id_empresa AND a.data_fim IS NULL
        LEFT JOIN public.user_expandido u ON u.id = a.id_professor
        
        WHERE ch.id_empresa = p_id_empresa
          AND (p_id_turma IS NULL OR t.id = p_id_turma)
          AND (p_id_escola IS NULL OR t.id_escola = p_id_escola)
          AND (p_id_ano_etapa IS NULL OR t.id_ano_etapa = p_id_ano_etapa)
          AND (p_id_classe IS NULL OR t.id_classe = p_id_classe)
          AND (p_ano IS NULL OR CAST(t.ano AS integer) = p_ano)
          AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
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
