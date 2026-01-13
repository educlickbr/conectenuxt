-- Refinamento da Lógica de Alocação de Turmas
-- Data: 2026-01-11 09:00

-- matricula_alocar_turma
-- Lógica: 
-- 1. Verifica se já existe alocação ATIVA na MESMA turma. Se sim, ignora.
-- 2. Se existe alocação ATIVA em OUTRA turma, encerra (data_saida = hoje, status = substituida).
-- 3. Cria nova alocação ATIVA na nova turma.

CREATE OR REPLACE FUNCTION public.matricula_alocar_turma(
    p_data jsonb,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_id uuid;
    v_id_matricula uuid;
    v_id_turma uuid;
    v_ch_salva public.matricula_turma;
    v_current_active public.matricula_turma;
BEGIN
    v_id_matricula := (p_data ->> 'id_matricula')::uuid;
    v_id_turma := (p_data ->> 'id_turma')::uuid;
    v_id := coalesce(nullif(p_data ->> 'id', '')::uuid, gen_random_uuid());

    -- 1. Busca alocação ativa atual para esta matrícula
    SELECT * INTO v_current_active
    FROM public.matricula_turma
    WHERE id_matricula = v_id_matricula
      AND status = 'ativa'
      AND id_empresa = p_id_empresa
    LIMIT 1;

    -- 2. Verifica duplicidade na MESMA turma
    IF v_current_active.id_turma = v_id_turma THEN
        -- Já está ativo nesta turma. Retorna o registro atual sem alterações.
        RETURN to_jsonb(v_current_active);
    END IF;

    -- 3. Encerra alocação anterior se existir (troca de turma)
    IF v_current_active.id IS NOT NULL THEN
        UPDATE public.matricula_turma
        SET data_saida = CURRENT_DATE,
            status = 'substituida'
        WHERE id = v_current_active.id;
    END IF;

    -- 4. Insere nova alocação
    INSERT INTO public.matricula_turma (
        id, id_matricula, id_turma, id_empresa, data_entrada, status
    )
    VALUES (
        v_id,
        v_id_matricula,
        v_id_turma,
        p_id_empresa,
        coalesce((p_data ->> 'data_entrada')::date, CURRENT_DATE),
        'ativa'
    )
    RETURNING * INTO v_ch_salva;

    RETURN to_jsonb(v_ch_salva);
END;
$$;
