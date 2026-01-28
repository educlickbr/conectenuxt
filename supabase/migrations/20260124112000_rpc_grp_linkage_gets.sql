-- RPCs for Listing Tutors and Integrantes

-- 1. Get Tutores Paginado
CREATE OR REPLACE FUNCTION public.grp_tutores_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_id_grupo uuid DEFAULT NULL,
    p_offset int DEFAULT 0,
    p_limit int DEFAULT 10
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_result json;
    v_total int;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM public.grp_tutores t
    JOIN public.user_expandido u ON u.id = t.id_user
    JOIN public.grp_grupos g ON g.id = t.id_grupo
    WHERE t.id_empresa = p_id_empresa
      AND (p_id_grupo IS NULL OR t.id_grupo = p_id_grupo)
      -- AND t.status = 'ATIVO' -- Optional, usually we want to see all
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
        LIMIT p_limit
        OFFSET p_offset
    ) sub;

    RETURN json_build_object('data', COALESCE(v_result, '[]'::json), 'total', v_total);
END;
$function$;

-- 2. Get Integrantes Paginado
CREATE OR REPLACE FUNCTION public.grp_integrantes_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_id_grupo uuid DEFAULT NULL,
    p_offset int DEFAULT 0,
    p_limit int DEFAULT 10
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_result json;
    v_total int;
BEGIN
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
        LIMIT p_limit
        OFFSET p_offset
    ) sub;

    RETURN json_build_object('data', COALESCE(v_result, '[]'::json), 'total', v_total);
END;
$function$;
