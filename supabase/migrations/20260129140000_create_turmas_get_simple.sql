-- Function 1: turmas_get_simple
CREATE OR REPLACE FUNCTION public.turmas_get_simple(
    p_id_empresa uuid, 
    p_id_escola uuid DEFAULT NULL::uuid, 
    p_id_ano_etapa uuid DEFAULT NULL::uuid,
    p_busca text DEFAULT NULL::text
)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_items jsonb;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', t.id,
            'nome', ae.nome || ' - ' || c.nome || ' - ' || h.periodo, -- Customized name
            'nome_composto', ae.nome || ' - ' || c.nome || ' - ' || h.periodo,
            'ano', t.ano,
            'id_ano_etapa', t.id_ano_etapa,
            'id_escola', t.id_escola,
            'escola_nome', e.nome, -- Added for consistency
            'horario_completo', h.hora_completo,
            'periodo', h.periodo,
            'turno', h.periodo
        ) ORDER BY t.ano, ae.nome, c.nome
    ) INTO v_items
    FROM public.turmas t
    JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
    JOIN public.classe c ON c.id = t.id_classe
    JOIN public.escolas e ON e.id = t.id_escola
    LEFT JOIN public.horarios_escola h ON h.id = t.id_horario
    WHERE t.id_empresa = p_id_empresa
      AND (p_id_escola IS NULL OR t.id_escola = p_id_escola)
      AND (p_id_ano_etapa IS NULL OR t.id_ano_etapa = p_id_ano_etapa)
      AND (p_busca IS NULL OR ae.nome ILIKE '%' || p_busca || '%' OR c.nome ILIKE '%' || p_busca || '%');

    RETURN jsonb_build_object('status', 'success', 'items', COALESCE(v_items, '[]'::jsonb));
END;
$function$;

-- Function 2: atrib_componentes_get_paginado
CREATE OR REPLACE FUNCTION public.atrib_componentes_get_paginado(p_id_empresa uuid, p_busca text DEFAULT NULL::text, p_pagina integer DEFAULT 1, p_limite_itens_pagina integer DEFAULT 10, p_id_turma uuid DEFAULT NULL::uuid, p_id_professor uuid DEFAULT NULL::uuid, p_ano integer DEFAULT NULL::integer, p_id_escola uuid DEFAULT NULL::uuid, p_id_ano_etapa uuid DEFAULT NULL::uuid, p_id_classe uuid DEFAULT NULL::uuid, p_id_componente uuid DEFAULT NULL::uuid)
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
            
            -- Joined Schedule Info
            h.hora_completo as horario_completo,
            h.periodo as periodo,
            
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
                        h_at.id as atribuicao_id,
                        h_at.id_professor,
                        h_at.nivel_substituicao,
                        h_at.data_inicio,
                        h_at.data_fim,
                        h_at.motivo_substituicao,
                        hu.nome_completo as professor_nome,
                        hu.matricula as professor_matricula,
                        (h_at.data_fim IS NULL) as is_ativo,
                        h_at.ano
                    FROM public.atrib_atribuicao_componentes h_at
                    JOIN public.user_expandido hu ON hu.id = h_at.id_professor
                    WHERE h_at.id_carga_horaria = ch.uuid 
                      AND h_at.id_turma = t.id
                      AND h_at.id_empresa = p_id_empresa
                      AND (p_ano IS NULL OR h_at.ano = p_ano)
                ) hist
            ), '[]'::json) as historico

        FROM public.carga_horaria ch
        JOIN public.componente comp ON comp.uuid = ch.id_componente
        JOIN public.turmas t ON t.id_ano_etapa = ch.id_ano_etapa AND t.id_empresa = ch.id_empresa
        JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        JOIN public.classe c ON c.id = t.id_classe
        JOIN public.escolas e ON e.id = t.id_escola
        LEFT JOIN public.horarios_escola h ON h.id = t.id_horario  -- Join Schedule
        
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
