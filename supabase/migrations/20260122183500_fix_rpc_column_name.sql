-- Fix RPC lms_conteudo_get_paginado to correctly join tables for names
-- Previous version failed because 'nome_turma' is in 'classe' table, not 'turmas'

CREATE OR REPLACE FUNCTION public.lms_conteudo_get_paginado(
    p_id_empresa uuid,
    p_page integer DEFAULT 1,
    p_limit integer DEFAULT 10,
    p_search text DEFAULT NULL,
    p_escopo text DEFAULT NULL,
    p_id_turma uuid DEFAULT NULL,
    p_id_aluno uuid DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_offset integer;
    v_total integer;
    v_items json;
BEGIN
    v_offset := (p_page - 1) * p_limit;

    -- Count
    SELECT COUNT(*) INTO v_total
    FROM public.lms_conteudo c
    WHERE c.id_empresa = p_id_empresa
    AND (p_search IS NULL OR c.titulo ILIKE '%' || p_search || '%')
    AND (p_escopo IS NULL OR c.escopo = p_escopo)
    AND (p_id_turma IS NULL OR c.id_turma = p_id_turma)
    AND (p_id_aluno IS NULL OR c.id_aluno = p_id_aluno);

    -- Fetch
    SELECT json_agg(t) INTO v_items
    FROM (
        SELECT 
            c.*,
            -- Joins for names
            cl.nome as nome_turma, -- Joined from classe via turmas
            ae.nome as nome_ano_etapa,
            u.nome_completo as nome_aluno
        FROM public.lms_conteudo c
        LEFT JOIN public.turmas t ON c.id_turma = t.id
        LEFT JOIN public.classe cl ON t.id_classe = cl.id -- JOIN CLASSE
        LEFT JOIN public.ano_etapa ae ON c.id_ano_etapa = ae.id
        LEFT JOIN public.user_expandido u ON c.id_aluno = u.id
        WHERE c.id_empresa = p_id_empresa
        AND (p_search IS NULL OR c.titulo ILIKE '%' || p_search || '%')
        AND (p_escopo IS NULL OR c.escopo = p_escopo)
        AND (p_id_turma IS NULL OR c.id_turma = p_id_turma)
        AND (p_id_aluno IS NULL OR c.id_aluno = p_id_aluno)
        ORDER BY c.criado_em DESC
        LIMIT p_limit
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'items', coalesce(v_items, '[]'::json),
        'total', v_total,
        'page', p_page,
        'pages', CEIL(v_total::float / p_limit)
    );
END;
$function$;
