-- Fix RPCs: Remove 'avatar' column usage in paginated list functions
-- Previous migration with issue: 20260124114500_fix_rpc_signatures.sql

-- 1. Tutores Paginado
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
            -- u.avatar removed
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

-- 2. Integrantes Paginado
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
            -- u.avatar removed
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
