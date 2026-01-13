-- Updating diario_aula_get_paginado to return full turma context (School, Stage, Class, Shift)
DROP FUNCTION public.diario_aula_get_paginado;
CREATE OR REPLACE FUNCTION public.diario_aula_get_paginado(
    p_id_empresa uuid,
    p_pagina integer DEFAULT 1,
    p_limite_itens_pagina integer DEFAULT 10,
    p_id_turma uuid DEFAULT NULL,
    p_id_componente uuid DEFAULT NULL,
    p_data_inicio date DEFAULT NULL,
    p_data_fim date DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_offset integer;
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- Count total items
    SELECT COUNT(*) INTO v_total_itens
    FROM public.diario_aula d
    WHERE d.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR d.id_turma = p_id_turma)
      AND (p_id_componente IS NULL OR d.id_componente = p_id_componente)
      AND (p_data_inicio IS NULL OR d.data >= p_data_inicio)
      AND (p_data_fim IS NULL OR d.data <= p_data_fim);

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(t), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            d.*,
            -- Teacher info
            u.nome_completo as professor_nome,
            -- Subject info
            comp.nome as componente_nome,
            -- Turma detailed Context
            e.nome as nome_escola,
            ae.nome as nome_ano_etapa,
            c.nome as nome_classe,
            h.periodo as turno,
            tur.ano as ano_calendario
        FROM public.diario_aula d
        LEFT JOIN public.user_expandido u ON u.id = d.registrado_por
        LEFT JOIN public.componente comp ON comp.uuid = d.id_componente
        -- Join Turma -> Escola, AnoEtapa, Classe, Horario
        JOIN public.turmas tur ON tur.id = d.id_turma
        JOIN public.escolas e ON e.id = tur.id_escola
        JOIN public.ano_etapa ae ON ae.id = tur.id_ano_etapa
        JOIN public.classe c ON c.id = tur.id_classe
        JOIN public.horarios_escola h ON h.id = tur.id_horario
        WHERE d.id_empresa = p_id_empresa
          AND (p_id_turma IS NULL OR d.id_turma = p_id_turma)
          AND (p_id_componente IS NULL OR d.id_componente = p_id_componente)
          AND (p_data_inicio IS NULL OR d.data >= p_data_inicio)
          AND (p_data_fim IS NULL OR d.data <= p_data_fim)
        ORDER BY d.data DESC, d.registrado_em DESC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;
