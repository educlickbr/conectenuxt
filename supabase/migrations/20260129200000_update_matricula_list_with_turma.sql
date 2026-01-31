-- Migration: Update matricula_get_paginado to include Active Class info
-- Reason: User requested to see the current class (Turma) in the main enrollment list.
-- We LEFT JOIN with matricula_turma (status='ativa') and related structure tables.

CREATE OR REPLACE FUNCTION public.matricula_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text)
    RETURNS json
    LANGUAGE plpgsql
AS $BODY$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    SELECT COUNT(*) INTO v_total_itens
    FROM public.matriculas m
    JOIN public.user_expandido u ON u.id = m.id_aluno
    -- Note: We don't necessarily need to join the heavy turma structure for the count, 
    -- unless we want to allow searching BY class name in the future. 
    -- For now, keeping count simple for performance.
    WHERE 
        m.id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(u.nome_completo) LIKE v_busca_like 
            OR UPPER(m.status) LIKE v_busca_like
            OR m.ano::text LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(t), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            m.*,
            u.nome_completo as aluno_nome,
            ae.nome as ano_etapa_nome,
            -- New Columns for Active Class
            mt.id_turma as id_turma_atual,
            mt.status as status_alocacao,
            COALESCE(c.nome, '?') || ' - ' || COALESCE(h.periodo || '', '?') as turma_nome_composto,
            e.nome as escola_nome,
            h.periodo as turno
        FROM public.matriculas m
        JOIN public.user_expandido u ON u.id = m.id_aluno
        JOIN public.ano_etapa ae ON ae.id = m.id_ano_etapa
        -- JOIN for Active Class
        LEFT JOIN public.matricula_turma mt ON mt.id_matricula = m.id AND mt.status = 'ativa'
        LEFT JOIN public.turmas tu ON tu.id = mt.id_turma
        LEFT JOIN public.classe c ON c.id = tu.id_classe
        LEFT JOIN public.horarios_escola h ON h.id = tu.id_horario
        LEFT JOIN public.escolas e ON e.id = tu.id_escola
        WHERE 
            m.id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(u.nome_completo) LIKE v_busca_like 
                OR UPPER(m.status) LIKE v_busca_like
                OR m.ano::text LIKE v_busca_like
            )
        ORDER BY m.ano DESC, m.criado_em DESC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$BODY$;
