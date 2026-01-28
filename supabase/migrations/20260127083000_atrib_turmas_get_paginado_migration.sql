DROP function public.atrib_turmas_get_paginado;
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

            -- Histórico Completo (Array)
            COALESCE((
                SELECT json_agg(hist ORDER BY hist.nivel_substituicao ASC)
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
                        (h.data_fim IS NULL) as is_ativo
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
          -- Filtro de Busca (considera qualquer professor que passou pela turma)
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
