CREATE OR REPLACE FUNCTION diario_validar_dia(
    p_id_empresa UUID,
    p_id_turma UUID,
    p_data DATE
)
RETURNS TABLE (
    valido BOOLEAN,
    motivo TEXT,
    detalhes JSONB,
    componentes JSONB
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_id_ano_etapa UUID;
    v_id_escola UUID;
    v_ano INTEGER;
    v_dia_semana INTEGER;
    v_calendario_count INTEGER;
    v_periodo_count INTEGER;
    v_feriado RECORD;
    v_evento RECORD;
    v_componentes JSONB;
BEGIN
    -- Get ano_etapa and escola from turma
    SELECT t.id_ano_etapa, t.id_escola, EXTRACT(YEAR FROM p_data)::INTEGER, EXTRACT(ISODOW FROM p_data)::INTEGER
    INTO v_id_ano_etapa, v_id_escola, v_ano, v_dia_semana
    FROM turmas t
    WHERE t.id = p_id_turma AND t.id_empresa = p_id_empresa;

    IF v_id_ano_etapa IS NULL THEN
        RETURN QUERY SELECT false, 'turma_invalida'::TEXT, 
            jsonb_build_object('mensagem', 'Turma não encontrada')::JSONB,
            '[]'::JSONB;
        RETURN;
    END IF;

    -- 1. Validate Calendar (ano_etapa > escola)
    SELECT COUNT(*) INTO v_calendario_count
    FROM mtz_calendario_anual
    WHERE id_empresa = p_id_empresa
    AND ano = v_ano
    AND (id_ano_etapa = v_id_ano_etapa OR id_escola = v_id_escola);

    IF v_calendario_count = 0 THEN
        RETURN QUERY SELECT false, 'sem_calendario'::TEXT,
            jsonb_build_object(
                'mensagem', 'Não há calendário configurado para esta turma',
                'ano', v_ano
            )::JSONB,
            '[]'::JSONB;
        RETURN;
    END IF;

    -- 2. Validate if date is within a school period
    SELECT COUNT(*) INTO v_periodo_count
    FROM mtz_calendario_anual
    WHERE id_empresa = p_id_empresa
    AND ano = v_ano
    AND (id_ano_etapa = v_id_ano_etapa OR id_escola = v_id_escola)
    AND p_data BETWEEN data_inicio AND data_fim;

    IF v_periodo_count = 0 THEN
        RETURN QUERY SELECT false, 'fora_periodo'::TEXT,
            jsonb_build_object(
                'mensagem', 'Esta data está fora do período letivo',
                'data', p_data
            )::JSONB,
            '[]'::JSONB;
        RETURN;
    END IF;

    -- 3. Check for holidays
    SELECT * INTO v_feriado
    FROM mtz_feriados
    WHERE id_empresa = p_id_empresa
    AND p_data BETWEEN data_inicio AND data_fim
    LIMIT 1;

    IF FOUND THEN
        RETURN QUERY SELECT false, 'feriado'::TEXT,
            jsonb_build_object(
                'mensagem', 'Não há aula neste dia',
                'nome', v_feriado.nome_feriado,
                'tipo', v_feriado.tipo
            )::JSONB,
            '[]'::JSONB;
        RETURN;
    END IF;

    -- 4. Check for events (ano_etapa > rede)
    SELECT * INTO v_evento
    FROM mtz_eventos
    WHERE id_empresa = p_id_empresa
    AND p_data BETWEEN data_inicio AND data_fim
    AND (id_ano_etapa = v_id_ano_etapa OR escopo = 'Rede')
    ORDER BY CASE WHEN id_ano_etapa = v_id_ano_etapa THEN 1 ELSE 2 END
    LIMIT 1;

    IF FOUND THEN
        RETURN QUERY SELECT false, 'evento'::TEXT,
            jsonb_build_object(
                'mensagem', 'Há um evento programado para este dia',
                'nome', v_evento.nome_evento,
                'escopo', v_evento.escopo
            )::JSONB,
            '[]'::JSONB;
        RETURN;
    END IF;

    -- 5. Get components from curriculum matrix (turma > ano_etapa)
    -- Fixed: Removed outer ORDER BY clause that was causing aggregation error.
    -- Added logic to handle prioritization (turma > ano_etapa) properly using CTE if needed, 
    -- but for now simplified to just aggregation with correct ordering within the array.
    
    WITH ranked_components AS (
        SELECT 
            mc.id_componente,
            c.nome,
            c.cor,
            mc.aula,
            ROW_NUMBER() OVER (
                PARTITION BY mc.aula 
                ORDER BY CASE WHEN mc.escopo = 'turma' THEN 1 ELSE 2 END
            ) as rn
        FROM mtz_matriz_curricular mc
        JOIN componente c ON c.uuid = mc.id_componente
        WHERE mc.id_empresa = p_id_empresa
        AND mc.ano = v_ano
        AND mc.dia_semana = v_dia_semana
        AND (
            (mc.escopo = 'turma' AND mc.id_turma = p_id_turma) OR
            (mc.escopo = 'ano_etapa' AND mc.id_ano_etapa = v_id_ano_etapa AND mc.id_turma IS NULL)
        )
    )
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', id_componente,
            'nome', nome,
            'cor', cor,
            'aula', aula
        ) ORDER BY aula
    ), '[]'::jsonb) INTO v_componentes
    FROM ranked_components
    WHERE rn = 1;

    IF v_componentes = '[]'::jsonb THEN
        RETURN QUERY SELECT false, 'sem_matriz'::TEXT,
            jsonb_build_object(
                'mensagem', 'Não há matriz curricular configurada para este dia',
                'dia_semana', v_dia_semana
            )::JSONB,
            '[]'::JSONB;
        RETURN;
    END IF;

    -- 6. All validations passed
    RETURN QUERY SELECT true, 'ok'::TEXT,
        jsonb_build_object(
            'mensagem', 'Dia válido para registro de presença',
            'data', p_data,
            'dia_semana', v_dia_semana
        )::JSONB,
        v_componentes;
END;
$$;
