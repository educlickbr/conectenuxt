-- Migration: Fix RPC Signatures for Groups, Tutors, and Integrantes
-- Issue: Previous signatures used p_offset/p_limit but BFF calls with p_pagina/p_limite_itens_pagina.

-- 1. DROP Old Functions (to avoid ambiguity or stale overloads)
DROP FUNCTION IF EXISTS public.grp_grupo_get_paginado(uuid, text, text, int, int);
DROP FUNCTION IF EXISTS public.grp_tutores_get_paginado(uuid, text, uuid, int, int);
DROP FUNCTION IF EXISTS public.grp_integrantes_get_paginado(uuid, text, uuid, int, int);

-- 2. CREATE Functions with Correct Signature (p_pagina, p_limite_itens_pagina)

-- 2.1 Groups Paginado
CREATE OR REPLACE FUNCTION public.grp_grupo_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_status text DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10
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
    FROM public.grp_grupos g
    WHERE g.id_empresa = p_id_empresa
      AND g.soft_delete IS FALSE
      AND (p_busca IS NULL OR g.nome_grupo ILIKE '%' || p_busca || '%')
      AND (p_status IS NULL OR g.status::text = p_status);

    -- Fetch Data
    SELECT json_agg(t) INTO v_result
    FROM (
        SELECT 
            g.*,
            uc.nome_completo as nome_criado_por,
            um.nome_completo as nome_modificado_por,
            (SELECT COUNT(*) FROM public.grp_tutores t WHERE t.id_grupo = g.id) as total_tutores,
            (SELECT COUNT(*) FROM public.grp_integrantes i WHERE i.id_grupo = g.id) as total_integrantes
        FROM public.grp_grupos g
        LEFT JOIN public.user_expandido uc ON uc.id = g.criado_por
        LEFT JOIN public.user_expandido um ON um.id = g.modificado_por
        WHERE g.id_empresa = p_id_empresa
          AND g.soft_delete IS FALSE
          AND (p_busca IS NULL OR g.nome_grupo ILIKE '%' || p_busca || '%')
          AND (p_status IS NULL OR g.status::text = p_status)
        ORDER BY g.criado_em DESC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'items', COALESCE(v_result, '[]'::json), -- Changed key from 'data' to 'items' to match generic handler preference
        'total', v_total,
        'pages', CEIL(v_total::float / p_limite_itens_pagina::float)
    );
END;
$function$;

-- 2.2 Tutores Paginado
CREATE OR REPLACE FUNCTION public.grp_tutores_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_id_grupo uuid DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10
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

    SELECT COUNT(*) INTO v_total
    FROM public.grp_tutores t
    JOIN public.user_expandido u ON u.id = t.id_user
    JOIN public.grp_grupos g ON g.id = t.id_grupo
    WHERE t.id_empresa = p_id_empresa
      AND (p_id_grupo IS NULL OR t.id_grupo = p_id_grupo)
      AND (p_busca IS NULL OR u.nome_completo ILIKE '%' || p_busca || '%' OR g.nome_grupo ILIKE '%' || p_busca || '%');

    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            t.id,
            t.id_grupo,
            g.nome_grupo,
            t.id_user,
            u.nome_completo,
            u.email,
            u.avatar,
            t.status,
            t.ano,
            t.criado_em
        FROM public.grp_tutores t
        JOIN public.user_expandido u ON u.id = t.id_user
        JOIN public.grp_grupos g ON g.id = t.id_grupo
        WHERE t.id_empresa = p_id_empresa
          AND (p_id_grupo IS NULL OR t.id_grupo = p_id_grupo)
          AND (p_busca IS NULL OR u.nome_completo ILIKE '%' || p_busca || '%' OR g.nome_grupo ILIKE '%' || p_busca || '%')
        ORDER BY t.criado_em DESC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) sub;

    RETURN json_build_object('items', COALESCE(v_result, '[]'::json), 'total', v_total);
END;
$function$;

-- 2.3 Integrantes Paginado
CREATE OR REPLACE FUNCTION public.grp_integrantes_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_id_grupo uuid DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10
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

    SELECT COUNT(*) INTO v_total
    FROM public.grp_integrantes i
    JOIN public.user_expandido u ON u.id = i.id_user
    JOIN public.grp_grupos g ON g.id = i.id_grupo
    WHERE i.id_empresa = p_id_empresa
      AND (p_id_grupo IS NULL OR i.id_grupo = p_id_grupo)
      AND (p_busca IS NULL OR u.nome_completo ILIKE '%' || p_busca || '%' OR g.nome_grupo ILIKE '%' || p_busca || '%');

    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            i.id,
            i.id_grupo,
            g.nome_grupo,
            i.id_user,
            u.nome_completo,
            u.email,
            u.avatar,
            i.status,
            i.ano,
            i.criado_em
        FROM public.grp_integrantes i
        JOIN public.user_expandido u ON u.id = i.id_user
        JOIN public.grp_grupos g ON g.id = i.id_grupo
        WHERE i.id_empresa = p_id_empresa
          AND (p_id_grupo IS NULL OR i.id_grupo = p_id_grupo)
          AND (p_busca IS NULL OR u.nome_completo ILIKE '%' || p_busca || '%' OR g.nome_grupo ILIKE '%' || p_busca || '%')
        ORDER BY i.criado_em DESC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) sub;

    RETURN json_build_object('items', COALESCE(v_result, '[]'::json), 'total', v_total);
END;
$function$;
