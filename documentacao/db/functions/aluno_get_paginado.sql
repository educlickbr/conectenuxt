CREATE OR REPLACE FUNCTION public.aluno_get_paginado(p_id_empresa uuid, p_pagina integer DEFAULT 1, p_limite_itens_pagina integer DEFAULT 10, p_busca text DEFAULT ''::text, p_id_escola uuid DEFAULT NULL::uuid, p_status text DEFAULT NULL::text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
    
    -- ID do papel de aluno
    v_papel_aluno uuid := 'b7f53d6e-70b5-453b-b564-728aeb4635d5';
BEGIN
    -- 1. Calcular Offset
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- 2. Calcular Total de Itens (para a busca atual)
    SELECT COUNT(*) INTO v_total_itens
    FROM public.user_expandido u
    LEFT JOIN public.escolas e ON u.id_escola = e.id
    WHERE 
        u.id_empresa = p_id_empresa
        AND u.papel_id = v_papel_aluno
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(u.nome_completo) LIKE v_busca_like 
            OR UPPER(u.matricula) LIKE v_busca_like
        )
        AND (
            p_id_escola IS NULL 
            OR u.id_escola = p_id_escola
        )
        AND (
            p_status IS NULL 
            OR u.status_contrato::text = p_status
        );

    -- 3. Calcular Total de Páginas
    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- 4. Buscar Itens Paginados e converter para JSON
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            u.user_id,
            u.id AS user_expandido_id,
            u.email,
            u.nome_completo,
            u.matricula,
            e.nome AS nome_escola,
            e.id AS id_escola,
            u.status_contrato AS status
        FROM public.user_expandido u
        LEFT JOIN public.escolas e ON u.id_escola = e.id
        WHERE 
            u.id_empresa = p_id_empresa
            AND u.papel_id = v_papel_aluno
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(u.nome_completo) LIKE v_busca_like
                OR UPPER(u.matricula) LIKE v_busca_like
            )
            AND (
                p_id_escola IS NULL 
                OR u.id_escola = p_id_escola
            )
            AND (
                p_status IS NULL 
                OR u.status_contrato::text = p_status
            )
        ORDER BY u.nome_completo ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- 5. Retornar Objeto JSON Final
    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$function$
