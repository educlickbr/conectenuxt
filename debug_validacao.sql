-- SQL para Depurar Validação de Dia

DO $$ 
DECLARE
    -- PARÂMETROS DE ENTRADA (Substitua pelos valores reais)
    p_id_empresa UUID := 'db5a4c52-074f-47c2-9aba-ac89111039d9';
    p_id_turma UUID := '68178e03-0dfc-4447-a019-931fcac85324';
    p_data DATE := '2026-02-03';

    -- Variáveis internas
    v_id_ano_etapa UUID;
    v_id_escola UUID;
    v_ano INTEGER;
    v_dia_semana INTEGER;
    v_calendario_json JSONB;
    v_matriz_json JSONB;
BEGIN
    RAISE NOTICE '=== INÍCIO DA DEPURAÇÃO ===';
    RAISE NOTICE 'Dados: Empresa=%, Turma=%, Data=%', p_id_empresa, p_id_turma, p_data;

    -- 1. Buscando dados da turma
    SELECT t.id_ano_etapa, t.id_escola, EXTRACT(YEAR FROM p_data)::INTEGER, EXTRACT(ISODOW FROM p_data)::INTEGER
    INTO v_id_ano_etapa, v_id_escola, v_ano, v_dia_semana
    FROM turmas t
    WHERE t.id = p_id_turma AND t.id_empresa = p_id_empresa;

    RAISE NOTICE 'Turma Encontrada? %', CASE WHEN v_id_ano_etapa IS NOT NULL THEN 'SIM' ELSE 'NÃO' END;
    RAISE NOTICE 'Ano Etapa: %, Escola: %', v_id_ano_etapa, v_id_escola;
    RAISE NOTICE 'Ano: %, Dia da Semana: % (1=Seg, 7=Dom)', v_ano, v_dia_semana;

    -- 2. Buscando Calendário
    SELECT jsonb_agg(to_jsonb(c.*)) INTO v_calendario_json
    FROM mtz_calendario_anual c
    WHERE id_empresa = p_id_empresa
    AND ano = v_ano
    AND (
        id_ano_etapa = v_id_ano_etapa 
        OR 
        id_escola = v_id_escola
    );

    IF v_calendario_json IS NOT NULL THEN
        RAISE NOTICE 'Calendários Encontrados: %', jsonb_pretty(v_calendario_json);
    ELSE
        RAISE NOTICE '!!! NENHUM CALENDÁRIO ENCONTRADO para Ano=% e (AnoEtapa=% OU Escola=%)', v_ano, v_id_ano_etapa, v_id_escola;
    END IF;

    -- 3. Buscando Matriz
    SELECT jsonb_agg(jsonb_build_object(
        'id', mc.id_componente,
        'escopo', mc.escopo,
        'dia', mc.dia_semana,
        'aula', mc.aula,
        'id_turma_matriz', mc.id_turma,
        'id_ano_etapa_matriz', mc.id_ano_etapa
    )) INTO v_matriz_json
    FROM mtz_matriz_curricular mc
    WHERE mc.id_empresa = p_id_empresa
    AND mc.ano = v_ano
    AND mc.dia_semana = v_dia_semana
    AND (
        (mc.escopo = 'turma' AND mc.id_turma = p_id_turma) 
        OR
        (mc.escopo = 'ano_etapa' AND mc.id_ano_etapa = v_id_ano_etapa AND mc.id_turma IS NULL)
    );

    IF v_matriz_json IS NOT NULL THEN
        RAISE NOTICE 'Componentes na Matriz para hoje: %', jsonb_pretty(v_matriz_json);
    ELSE
        RAISE NOTICE '!!! NENHUM COMPONENTE NA MATRIZ para DiaSemana=% e Turma=% ou AnoEtapa=%', v_dia_semana, p_id_turma, v_id_ano_etapa;
    END IF;

END $$;
