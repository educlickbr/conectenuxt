-- Fix RPC: Allow ANY user to be an Integrante (Group Member), except excluded ones if any (none for now)
-- Previous migration: 20260126094500_fix_grp_list_avatar.sql

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
            matricula
        FROM public.user_expandido
        WHERE id_empresa = p_id_empresa
          AND soft_delete IS FALSE
          -- Removed 'papel_id' filter to allow any user (Student, Teacher, etc.)
          AND (p_busca IS NULL OR nome_completo ILIKE '%' || p_busca || '%' OR matricula ILIKE '%' || p_busca || '%')
        ORDER BY nome_completo ASC
        LIMIT p_limit
    ) sub;

    RETURN COALESCE(v_result, '[]'::json);
END;
$function$;
