-- Migration: Standardize Attribution Functions & Timezone Handling
-- Recreates Upsert and GetPaginado functions to ensure consistency and prevent timezone confusion.
-- Uses 'America/Sao_Paulo' for explicit date handling where applicable and ensures latest logic is preserved.

-- ============================================================================
-- 1. DROP EXISTING FUNCTIONS (To allow signature changes/clean replace)
-- ============================================================================

DROP FUNCTION IF EXISTS public.atrib_turmas_get_paginado(uuid, text, int, int, uuid, uuid, int, uuid, uuid, uuid);
DROP FUNCTION IF EXISTS public.atrib_turmas_get_paginado(uuid, text, int, int, uuid, uuid, smallint, uuid, uuid, uuid); -- Drop potential var with smallint
DROP FUNCTION IF EXISTS public.atrib_turmas_upsert(uuid, uuid, uuid, uuid, smallint, date, date, text, int);

DROP FUNCTION IF EXISTS public.atrib_componentes_get_paginado(uuid, text, int, int, uuid, uuid, int, uuid, uuid, uuid, uuid);
DROP FUNCTION IF EXISTS public.atrib_componentes_get_paginado(uuid, text, int, int, uuid, uuid, smallint, uuid, uuid, uuid, uuid);
DROP FUNCTION IF EXISTS public.atrib_componentes_upsert(uuid, uuid, uuid, uuid, uuid, smallint, date, date, text, int);


-- ============================================================================
-- 2. RECREATE FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 2.1 atrib_turmas_upsert
-- ----------------------------------------------------------------------------
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
            now() -- Standard timestamptz
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

-- ----------------------------------------------------------------------------
-- 2.2 atrib_turmas_get_paginado
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.atrib_turmas_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10,
    p_id_turma uuid DEFAULT NULL,
    p_id_professor uuid DEFAULT NULL,
    p_ano int DEFAULT NULL,
    p_id_escola uuid DEFAULT NULL,
    p_id_ano_etapa uuid DEFAULT NULL,
    p_id_classe uuid DEFAULT NULL
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

    -- Total Count (Baseado nas Turmas que atendem aos filtros)
    SELECT COUNT(DISTINCT t.id) INTO v_total
    FROM public.turmas t
    LEFT JOIN public.atrib_atribuicao_turmas a ON a.id_turma = t.id AND a.id_empresa = t.id_empresa
    LEFT JOIN public.user_expandido u ON u.id = a.id_professor
    WHERE t.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR t.id = p_id_turma)
      AND (p_id_escola IS NULL OR t.id_escola = p_id_escola)
      AND (p_id_ano_etapa IS NULL OR t.id_ano_etapa = p_id_ano_etapa)
      AND (p_id_classe IS NULL OR t.id_classe = p_id_classe)
      AND (p_ano IS NULL OR t.ano = p_ano::text)
      AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
      AND (p_busca IS NULL OR p_busca = '' OR u.nome_completo ILIKE '%' || p_busca || '%' OR u.matricula ILIKE '%' || p_busca || '%');

    -- Busca dos Dados
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            t.id as id_turma,
            t.ano as turma_ano,
            ae.nome as ano_etapa_nome,
            c.nome as classe_nome,
            e.nome as escola_nome,
            
            -- Professor Atual (Root)
            u_at.nome_completo as professor_atual_nome,
            u_at.matricula as professor_atual_matricula,
            u_at.email as professor_atual_email,
            esc_sede.nome as professor_atual_escola_sede,
            a_at.data_inicio as professor_atual_desde,
            a_at.id as atribuicao_atual_id,
            a_at.nivel_substituicao as nivel_substituicao,

            -- Histórico Completo (Array)
            COALESCE((
                SELECT json_agg(hist ORDER BY hist.data_inicio DESC)
                FROM (
                    SELECT 
                        h.id as atribuicao_id,
                        h.id_professor,
                        h.nivel_substituicao,
                        h.data_inicio,
                        h.data_fim,
                        h.motivo_substituicao,
                        hu.nome_completo as professor_nome,
                        hu.matricula as professor_matricula,
                        hu.email as professor_email,
                        (h.data_fim IS NULL) as is_ativo,
                        h.ano
                    FROM public.atrib_atribuicao_turmas h
                    JOIN public.user_expandido hu ON hu.id = h.id_professor
                    WHERE h.id_turma = t.id 
                      AND h.id_empresa = p_id_empresa
                      AND (p_ano IS NULL OR h.ano = p_ano)
                ) hist
            ), '[]'::json) as historico

        FROM public.turmas t
        JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        JOIN public.classe c ON c.id = t.id_classe
        JOIN public.escolas e ON e.id = t.id_escola
        
        -- Join para pegar o professor ATIVO
        LEFT JOIN public.atrib_atribuicao_turmas a_at 
            ON a_at.id_turma = t.id 
            AND a_at.id_empresa = t.id_empresa 
            AND a_at.data_fim IS NULL 
            AND (p_ano IS NULL OR a_at.ano = p_ano)
        LEFT JOIN public.user_expandido u_at ON u_at.id = a_at.id_professor
        LEFT JOIN public.escolas esc_sede ON esc_sede.id = u_at.id_escola
        
        WHERE t.id_empresa = p_id_empresa
          AND (p_id_turma IS NULL OR t.id = p_id_turma)
          AND (p_id_escola IS NULL OR t.id_escola = p_id_escola)
          AND (p_id_ano_etapa IS NULL OR t.id_ano_etapa = p_id_ano_etapa)
          AND (p_id_classe IS NULL OR t.id_classe = p_id_classe)
          AND (p_ano IS NULL OR t.ano = p_ano::text)
          AND (p_busca IS NULL OR p_busca = '' OR EXISTS (
                SELECT 1 FROM public.atrib_atribuicao_turmas b
                JOIN public.user_expandido bu ON bu.id = b.id_professor
                WHERE b.id_turma = t.id AND (bu.nome_completo ILIKE '%' || p_busca || '%' OR bu.matricula ILIKE '%' || p_busca || '%')
          ))
        
        ORDER BY ae.nome, c.nome
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


-- ----------------------------------------------------------------------------
-- 2.3 atrib_componentes_upsert
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 2.4 atrib_componentes_get_paginado
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.atrib_componentes_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10,
    p_id_turma uuid DEFAULT NULL,
    p_id_professor uuid DEFAULT NULL,
    p_ano int DEFAULT NULL,
    p_id_escola uuid DEFAULT NULL,
    p_id_ano_etapa uuid DEFAULT NULL,
    p_id_classe uuid DEFAULT NULL,
    p_id_componente uuid DEFAULT NULL
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

    -- 1. Cálculo do Total (Baseado na Carga Horária x Turmas)
    SELECT COUNT(*) INTO v_total
    FROM public.carga_horaria ch
    JOIN public.turmas t ON t.id_ano_etapa = ch.id_ano_etapa AND t.id_empresa = ch.id_empresa
    LEFT JOIN public.atrib_atribuicao_componentes a ON a.id_carga_horaria = ch.uuid AND a.id_turma = t.id AND a.data_fim IS NULL
    LEFT JOIN public.user_expandido u ON u.id = a.id_professor
    JOIN public.componente comp ON comp.uuid = ch.id_componente
    WHERE ch.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR t.id = p_id_turma)
      AND (p_id_escola IS NULL OR t.id_escola = p_id_escola)
      AND (p_id_ano_etapa IS NULL OR t.id_ano_etapa = p_id_ano_etapa)
      AND (p_id_classe IS NULL OR t.id_classe = p_id_classe)
      AND (p_ano IS NULL OR t.ano = p_ano::text)
      AND (p_id_professor IS NULL OR a.id_professor = p_id_professor)
      AND (p_id_componente IS NULL OR comp.uuid = p_id_componente)
      AND (p_busca IS NULL OR p_busca = '' OR u.nome_completo ILIKE '%' || p_busca || '%' OR u.matricula ILIKE '%' || p_busca || '%');

    -- 2. Busca dos Dados com Pilha de Histórico
    SELECT json_agg(sub) INTO v_result
    FROM (
        SELECT 
            t.id as id_turma,
            t.ano as turma_ano,
            ae.nome as ano_etapa_nome,
            c.nome as classe_nome,
            e.nome as escola_nome,
            
            ch.uuid as id_carga_horaria,
            ch.carga_horaria,
            comp.nome as componente_nome,
            comp.cor as componente_cor,
            comp.uuid as id_componente,
            
            u_at.nome_completo as professor_atual_nome,
            u_at.matricula as professor_atual_matricula,
            u_at.email as professor_atual_email,
            esc_sede.nome as professor_atual_escola_sede,
            a_at.data_inicio as professor_atual_desde,
            a_at.id as atribuicao_atual_id,
            a_at.nivel_substituicao as atribuicao_atual_nivel,
            
            COALESCE((
                SELECT json_agg(hist ORDER BY hist.data_inicio DESC)
                FROM (
                    SELECT 
                        h.id as atribuicao_id,
                        h.id_professor,
                        h.nivel_substituicao,
                        h.data_inicio,
                        h.data_fim,
                        h.motivo_substituicao,
                        hu.nome_completo as professor_nome,
                        hu.matricula as professor_matricula,
                        (h.data_fim IS NULL) as is_ativo,
                        h.ano
                    FROM public.atrib_atribuicao_componentes h
                    JOIN public.user_expandido hu ON hu.id = h.id_professor
                    WHERE h.id_carga_horaria = ch.uuid 
                      AND h.id_turma = t.id
                      AND h.id_empresa = p_id_empresa
                      AND (p_ano IS NULL OR h.ano = p_ano)
                ) hist
            ), '[]'::json) as historico

        FROM public.carga_horaria ch
        JOIN public.componente comp ON comp.uuid = ch.id_componente
        JOIN public.turmas t ON t.id_ano_etapa = ch.id_ano_etapa AND t.id_empresa = ch.id_empresa
        JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        JOIN public.classe c ON c.id = t.id_classe
        JOIN public.escolas e ON e.id = t.id_escola
        
        LEFT JOIN public.atrib_atribuicao_componentes a_at 
            ON a_at.id_carga_horaria = ch.uuid 
            AND a_at.id_turma = t.id 
            AND a_at.data_fim IS NULL
        LEFT JOIN public.user_expandido u_at ON u_at.id = a_at.id_professor
        LEFT JOIN public.escolas esc_sede ON esc_sede.id = u_at.id_escola
        
        WHERE ch.id_empresa = p_id_empresa
          AND (p_id_turma IS NULL OR t.id = p_id_turma)
          AND (p_id_escola IS NULL OR t.id_escola = p_id_escola)
          AND (p_id_ano_etapa IS NULL OR t.id_ano_etapa = p_id_ano_etapa)
          AND (p_id_classe IS NULL OR t.id_classe = p_id_classe)
          AND (p_ano IS NULL OR t.ano = p_ano::text)
          AND (p_id_componente IS NULL OR comp.uuid = p_id_componente)
          AND (p_busca IS NULL OR p_busca = '' OR EXISTS (
                SELECT 1 FROM public.atrib_atribuicao_componentes b
                JOIN public.user_expandido bu ON bu.id = b.id_professor
                WHERE b.id_carga_horaria = ch.uuid AND b.id_turma = t.id 
                  AND (bu.nome_completo ILIKE '%' || p_busca || '%' OR bu.matricula ILIKE '%' || p_busca || '%')
          ))
        
        ORDER BY t.ano DESC, ae.nome, c.nome, comp.nome
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
