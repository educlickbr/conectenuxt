-- Fix RPCs: Remove 'avatar' column which does not exist in user_expandido table
-- Previous migration: 20260124113500_rpc_grp_candidates.sql

-- 1. Get Candidates for Tutor
CREATE OR REPLACE FUNCTION public.grp_candidatos_tutores_get(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_limit int DEFAULT 20
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_result json;
BEGIN
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            id,
            nome_completo,
            email,
            -- avatar has been removed
            matricula
        FROM public.user_expandido
        WHERE id_empresa = p_id_empresa
          AND soft_delete IS FALSE
          AND papel_id NOT IN (
              'b7f53d6e-70b5-453b-b564-728aeb4635d5'::uuid, -- Aluno
              '3ecbe197-4c01-4b25-8e8a-04f9adaff801'::uuid  -- Responsavel
          )
          AND (p_busca IS NULL OR nome_completo ILIKE '%' || p_busca || '%' OR matricula ILIKE '%' || p_busca || '%')
        ORDER BY nome_completo ASC
        LIMIT p_limit
    ) sub;

    RETURN COALESCE(v_result, '[]'::json);
END;
$function$;

-- 2. Get Candidates for Integrante (Aluno)
CREATE OR REPLACE FUNCTION public.grp_candidatos_integrantes_get(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_limit int DEFAULT 20
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_result json;
BEGIN
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            id,
            nome_completo,
            email,
            -- avatar has been removed
            matricula
        FROM public.user_expandido
        WHERE id_empresa = p_id_empresa
          AND soft_delete IS FALSE
          AND papel_id = 'b7f53d6e-70b5-453b-b564-728aeb4635d5'::uuid -- Aluno Only
          AND (p_busca IS NULL OR nome_completo ILIKE '%' || p_busca || '%' OR matricula ILIKE '%' || p_busca || '%')
        ORDER BY nome_completo ASC
        LIMIT p_limit
    ) sub;

    RETURN COALESCE(v_result, '[]'::json);
END;
$function$;
