CREATE OR REPLACE FUNCTION public.admin_get_paginado(p_id_empresa uuid, p_pagina integer DEFAULT 1, p_limite_itens_pagina integer DEFAULT 10, p_busca text DEFAULT NULL::text)
 RETURNS TABLE(id uuid, nome_completo text, email text, telefone text, matricula text, status_contrato status_contrato, user_id uuid, total_registros bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_offset integer;
    v_role_admin uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    RETURN QUERY
    WITH admins_filtrados AS (
        SELECT
            ue.id,
            ue.nome_completo,
            ue.email,
            ue.telefone,
            ue.matricula,
            ue.status_contrato,
            ue.user_id
        FROM
            public.user_expandido ue
        WHERE
            ue.id_empresa = p_id_empresa
            AND ue.papel_id = v_role_admin
            AND ue.soft_delete IS FALSE
            AND (
                p_busca IS NULL OR 
                ue.nome_completo ILIKE '%' || p_busca || '%' OR
                ue.email ILIKE '%' || p_busca || '%' OR
                ue.matricula ILIKE '%' || p_busca || '%'
            )
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM admins_filtrados
    )
    SELECT
        af.id,
        af.nome_completo,
        af.email,
        af.telefone,
        af.matricula,
        af.status_contrato,
        af.user_id,
        tc.total as total_registros
    FROM
        admins_filtrados af
    CROSS JOIN
        total_count tc
    ORDER BY
        af.nome_completo ASC
    LIMIT
        p_limite_itens_pagina
    OFFSET
        v_offset;
END;
$function$
