-- Drop existing functions to avoid conflicts
DROP FUNCTION IF EXISTS public.lms_conteudo_upsert;
DROP FUNCTION IF EXISTS public.lms_conteudo_delete;
DROP FUNCTION IF EXISTS public.lms_conteudo_get_paginado;

-- 1. UPSERT (Create/Update)
CREATE OR REPLACE FUNCTION public.lms_conteudo_upsert(
    p_id uuid,
    p_id_empresa uuid,
    p_titulo text,
    p_descricao text,
    p_escopo text,
    p_id_ano_etapa uuid DEFAULT NULL,
    p_id_turma uuid DEFAULT NULL,
    p_id_meta_turma uuid DEFAULT NULL,
    p_id_componente uuid DEFAULT NULL,
    p_id_aluno uuid DEFAULT NULL,
    p_data_referencia date DEFAULT NULL,
    p_visivel_para_alunos boolean DEFAULT true,
    p_criado_por uuid DEFAULT NULL 
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_id uuid;
    v_result json;
    v_user_id uuid;
BEGIN
    -- Get Current User if not provided (fallback)
    v_user_id := coalesce(p_criado_por, auth.uid()); -- Note: auth.uid() is usually auth.users id, not user_expandido. Best to pass explicit p_criado_por from BFF.

    IF p_id IS NULL THEN
        -- Insert
        INSERT INTO public.lms_conteudo (
            id_empresa,
            titulo,
            descricao,
            escopo,
            id_ano_etapa,
            id_turma,
            id_meta_turma,
            id_componente,
            id_aluno,
            data_referencia,
            visivel_para_alunos,
            criado_por
        ) VALUES (
            p_id_empresa,
            p_titulo,
            p_descricao,
            p_escopo,
            p_id_ano_etapa,
            p_id_turma,
            p_id_meta_turma,
            p_id_componente,
            p_id_aluno,
            p_data_referencia,
            p_visivel_para_alunos,
            v_user_id
        ) RETURNING id INTO v_id;
    ELSE
        -- Update
        UPDATE public.lms_conteudo SET
            titulo = p_titulo,
            descricao = p_descricao,
            escopo = p_escopo,
            id_ano_etapa = p_id_ano_etapa,
            id_turma = p_id_turma,
            id_meta_turma = p_id_meta_turma,
            id_componente = p_id_componente,
            id_aluno = p_id_aluno,
            data_referencia = p_data_referencia,
            visivel_para_alunos = p_visivel_para_alunos
        WHERE id = p_id AND id_empresa = p_id_empresa
        RETURNING id INTO v_id;
    END IF;

    SELECT json_build_object(
        'success', true,
        'id', v_id
    ) INTO v_result;

    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'message', SQLERRM,
        'detail', SQLSTATE
    );
END;
$function$;

-- 2. DELETE
CREATE OR REPLACE FUNCTION public.lms_conteudo_delete(
    p_id uuid,
    p_id_empresa uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_deleted boolean;
BEGIN
    DELETE FROM public.lms_conteudo
    WHERE id = p_id AND id_empresa = p_id_empresa;
    
    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    
    RETURN json_build_object(
        'success', (v_deleted > 0)
    );
END;
$function$;

-- 3. GET PAGINADO
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
