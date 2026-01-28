-- Migration: Create Attribution CRUD RPCs
-- Creates upsert, get_paginado, and delete functions for both attribution tables

-- ============================================================================
-- 1. ATRIB_ATRIBUICAO_TURMAS (Polivalente Teachers)
-- ============================================================================

-- 1.1 atrib_turmas_upsert
CREATE OR REPLACE FUNCTION public.atrib_turmas_upsert(
    p_id uuid,
    p_id_empresa uuid,
    p_id_turma uuid,
    p_id_professor uuid,
    p_ano smallint,
    p_data_inicio date,
    p_data_fim date DEFAULT NULL,
    p_motivo_substituicao text DEFAULT NULL,
    p_nivel_substituicao int DEFAULT 0
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
    -- Resolve user_expandido.id
    SELECT id INTO v_user_id
    FROM public.user_expandido
    WHERE user_id = auth.uid()
    LIMIT 1;

    IF v_user_id IS NULL THEN
         RETURN json_build_object(
            'success', false,
            'message', 'Usuário não encontrado.'
        );
    END IF;

    IF p_id IS NULL THEN
        -- Insert
        INSERT INTO public.atrib_atribuicao_turmas (
            id_empresa,
            id_turma,
            id_professor,
            ano,
            data_inicio,
            data_fim,
            motivo_substituicao,
            nivel_substituicao,
            created_at
        ) VALUES (
            p_id_empresa,
            p_id_turma,
            p_id_professor,
            p_ano,
            p_data_inicio,
            p_data_fim,
            p_motivo_substituicao,
            p_nivel_substituicao,
            now()
        ) RETURNING id INTO v_id;
    ELSE
        -- Update
        UPDATE public.atrib_atribuicao_turmas SET
            id_turma = p_id_turma,
            id_professor = p_id_professor,
            ano = p_ano,
            data_inicio = p_data_inicio,
            data_fim = p_data_fim,
            motivo_substituicao = p_motivo_substituicao,
            nivel_substituicao = p_nivel_substituicao
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
        'message', SQLERRM
    );
END;
$function$;

-- 1.2 atrib_turmas_get_paginado
CREATE OR REPLACE FUNCTION public.atrib_turmas_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10,
    p_id_turma uuid DEFAULT NULL,
    p_id_professor uuid DEFAULT NULL,
    p_ano smallint DEFAULT NULL
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
    FROM public.atrib_atribuicao_turmas a
    JOIN public.turmas t ON t.id = a.id_turma
    JOIN public.user_expandido u ON u.id = a.id_professor
    WHERE a.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR a.id_turma = p_id_turma)
      AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
      AND (p_ano IS NULL OR a.ano = p_ano)
      AND (p_busca IS NULL OR u.nome_completo ILIKE '%' || p_busca || '%');

    -- Fetch Data
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            a.id,
            a.id_turma,
            a.id_professor,
            a.ano,
            a.data_inicio,
            a.data_fim,
            a.motivo_substituicao,
            a.nivel_substituicao,
            a.created_at,
            -- Turma info
            t.ano as turma_ano,
            ae.nome as ano_etapa_nome,
            c.nome as classe_nome,
            e.nome as escola_nome,
            -- Professor info
            u.nome_completo as professor_nome,
            u.email as professor_email
        FROM public.atrib_atribuicao_turmas a
        JOIN public.turmas t ON t.id = a.id_turma
        JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        JOIN public.classe c ON c.id = t.id_classe
        JOIN public.escolas e ON e.id = t.id_escola
        JOIN public.user_expandido u ON u.id = a.id_professor
        WHERE a.id_empresa = p_id_empresa
          AND (p_id_turma IS NULL OR a.id_turma = p_id_turma)
          AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
          AND (p_ano IS NULL OR a.ano = p_ano)
          AND (p_busca IS NULL OR u.nome_completo ILIKE '%' || p_busca || '%')
        ORDER BY a.created_at DESC
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

-- 1.3 atrib_turmas_delete
CREATE OR REPLACE FUNCTION public.atrib_turmas_delete(
    p_id_empresa uuid,
    p_id uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_deleted_count int;
BEGIN
    DELETE FROM public.atrib_atribuicao_turmas
    WHERE id = p_id AND id_empresa = p_id_empresa;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN json_build_object(
            'success', true,
            'message', 'Atribuição removida com sucesso.'
        );
    ELSE
        RETURN json_build_object(
            'success', false,
            'message', 'Atribuição não encontrada.'
        );
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'message', SQLERRM
    );
END;
$function$;


-- ============================================================================
-- 2. ATRIB_ATRIBUICAO_COMPONENTES (Subject-specific Teachers)
-- ============================================================================

-- 2.1 atrib_componentes_upsert
CREATE OR REPLACE FUNCTION public.atrib_componentes_upsert(
    p_id uuid,
    p_id_empresa uuid,
    p_id_turma uuid,
    p_id_carga_horaria uuid,
    p_id_professor uuid,
    p_ano smallint,
    p_data_inicio date,
    p_data_fim date DEFAULT NULL,
    p_motivo_substituicao text DEFAULT NULL,
    p_nivel_substituicao int DEFAULT 0
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
    -- Resolve user_expandido.id
    SELECT id INTO v_user_id
    FROM public.user_expandido
    WHERE user_id = auth.uid()
    LIMIT 1;

    IF v_user_id IS NULL THEN
         RETURN json_build_object(
            'success', false,
            'message', 'Usuário não encontrado.'
        );
    END IF;

    IF p_id IS NULL THEN
        -- Insert
        INSERT INTO public.atrib_atribuicao_componentes (
            id_empresa,
            id_turma,
            id_carga_horaria,
            id_professor,
            ano,
            data_inicio,
            data_fim,
            motivo_substituicao,
            nivel_substituicao,
            created_at
        ) VALUES (
            p_id_empresa,
            p_id_turma,
            p_id_carga_horaria,
            p_id_professor,
            p_ano,
            p_data_inicio,
            p_data_fim,
            p_motivo_substituicao,
            p_nivel_substituicao,
            now()
        ) RETURNING id INTO v_id;
    ELSE
        -- Update
        UPDATE public.atrib_atribuicao_componentes SET
            id_turma = p_id_turma,
            id_carga_horaria = p_id_carga_horaria,
            id_professor = p_id_professor,
            ano = p_ano,
            data_inicio = p_data_inicio,
            data_fim = p_data_fim,
            motivo_substituicao = p_motivo_substituicao,
            nivel_substituicao = p_nivel_substituicao
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
        'message', SQLERRM
    );
END;
$function$;

-- 2.2 atrib_componentes_get_paginado
CREATE OR REPLACE FUNCTION public.atrib_componentes_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10,
    p_id_turma uuid DEFAULT NULL,
    p_id_professor uuid DEFAULT NULL,
    p_ano smallint DEFAULT NULL
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
    FROM public.atrib_atribuicao_componentes a
    JOIN public.turmas t ON t.id = a.id_turma
    JOIN public.carga_horaria ch ON ch.uuid = a.id_carga_horaria
    JOIN public.user_expandido u ON u.id = a.id_professor
    WHERE a.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR a.id_turma = p_id_turma)
      AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
      AND (p_ano IS NULL OR a.ano = p_ano)
      AND (p_busca IS NULL OR u.nome_completo ILIKE '%' || p_busca || '%');

    -- Fetch Data
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            a.id,
            a.id_turma,
            a.id_carga_horaria,
            a.id_professor,
            a.ano,
            a.data_inicio,
            a.data_fim,
            a.motivo_substituicao,
            a.nivel_substituicao,
            a.created_at,
            -- Turma info
            t.ano as turma_ano,
            ae.nome as ano_etapa_nome,
            c.nome as classe_nome,
            e.nome as escola_nome,
            -- Carga Horária / Componente info
            ch.carga_horaria,
            comp.nome as componente_nome,
            -- Professor info
            u.nome_completo as professor_nome,
            u.email as professor_email
        FROM public.atrib_atribuicao_componentes a
        JOIN public.turmas t ON t.id = a.id_turma
        JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        JOIN public.classe c ON c.id = t.id_classe
        JOIN public.escolas e ON e.id = t.id_escola
        JOIN public.carga_horaria ch ON ch.uuid = a.id_carga_horaria
        JOIN public.componente comp ON comp.uuid = ch.id_componente
        JOIN public.user_expandido u ON u.id = a.id_professor
        WHERE a.id_empresa = p_id_empresa
          AND (p_id_turma IS NULL OR a.id_turma = p_id_turma)
          AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
          AND (p_ano IS NULL OR a.ano = p_ano)
          AND (p_busca IS NULL OR u.nome_completo ILIKE '%' || p_busca || '%')
        ORDER BY a.created_at DESC
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

-- 2.3 atrib_componentes_delete
CREATE OR REPLACE FUNCTION public.atrib_componentes_delete(
    p_id_empresa uuid,
    p_id uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_deleted_count int;
BEGIN
    DELETE FROM public.atrib_atribuicao_componentes
    WHERE id = p_id AND id_empresa = p_id_empresa;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN json_build_object(
            'success', true,
            'message', 'Atribuição removida com sucesso.'
        );
    ELSE
        RETURN json_build_object(
            'success', false,
            'message', 'Atribuição não encontrada.'
        );
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'message', SQLERRM
    );
END;
$function$;
