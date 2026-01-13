-- Fix Allocation Logic, Cleanup Data, and Ensure RPCs (All-in-One)
-- Data: 2026-01-11 10:00

-- 1. CLEANUP: Garantir apenas uma alocação ativa por matrícula (a mais recente)
WITH duplicadas AS (
    SELECT id,
           ROW_NUMBER() OVER (PARTITION BY id_matricula ORDER BY criado_em DESC) as rn
    FROM public.matricula_turma
    WHERE status = 'ativa'
)
UPDATE public.matricula_turma
SET status = 'substituida',
    data_saida = CURRENT_DATE
WHERE id IN (
    SELECT id FROM duplicadas WHERE rn > 1
);

-- 2. CONSTRAINT: Impedir duplicidade física de alocação ativa
DROP INDEX IF EXISTS idx_matricula_turma_unica_ativa;
CREATE UNIQUE INDEX idx_matricula_turma_unica_ativa 
ON public.matricula_turma (id_matricula) 
WHERE status = 'ativa';

-- 3. RPC: matricula_turma_get_por_matricula (History)
CREATE OR REPLACE FUNCTION public.matricula_turma_get_por_matricula(
    p_id_empresa uuid,
    p_id_matricula uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_itens json;
BEGIN
    SELECT COALESCE(json_agg(t), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            mt.id,
            mt.id_matricula,
            mt.id_turma,
            mt.data_entrada,
            mt.data_saida,
            mt.status,
            t.nome as turma_nome,
            -- Tentar pegar ano da matricula, ou da turma, ou ano_etapa
            coalesce(t.ano, '') as turma_ano
        FROM public.matricula_turma mt
        JOIN public.turmas t ON t.id = mt.id_turma
        WHERE mt.id_empresa = p_id_empresa
          AND mt.id_matricula = p_id_matricula
        ORDER BY mt.data_entrada DESC, mt.criado_em DESC
    ) t;

    RETURN json_build_object(
        'itens', v_itens
    );
END;
$$;

GRANT ALL ON FUNCTION public.matricula_turma_get_por_matricula(uuid, uuid) TO anon;
GRANT ALL ON FUNCTION public.matricula_turma_get_por_matricula(uuid, uuid) TO authenticated;
GRANT ALL ON FUNCTION public.matricula_turma_get_por_matricula(uuid, uuid) TO service_role;


-- 4. RPC: matricula_alocar_turma (Allocation Logic)
-- Nota: Security Definer para garantir acesso
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
    v_current_active_id uuid;
    v_current_active_turma uuid;
BEGIN
    v_id_matricula := (p_data ->> 'id_matricula')::uuid;
    v_id_turma := (p_data ->> 'id_turma')::uuid;
    v_id := coalesce(nullif(p_data ->> 'id', '')::uuid, gen_random_uuid());

    -- Verifica se já existe ATIVA
    SELECT id, id_turma INTO v_current_active_id, v_current_active_turma
    FROM public.matricula_turma
    WHERE id_matricula = v_id_matricula
      AND status = 'ativa'
    LIMIT 1;

    -- Se já está na mesma turma, retorna sucesso sem fazer nada
    IF v_current_active_turma = v_id_turma THEN
        SELECT * INTO v_ch_salva FROM public.matricula_turma WHERE id = v_current_active_id;
        RETURN to_jsonb(v_ch_salva);
    END IF;

    -- Se está em outra turma, encerra a anterior
    IF v_current_active_id IS NOT NULL THEN
        UPDATE public.matricula_turma
        SET data_saida = CURRENT_DATE,
            status = 'substituida'
        WHERE id = v_current_active_id;
    END IF;

    -- Insere a nova
    -- Se houver violação de constraint por race condition, o banco lança erro, o que é correto.
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
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Erro ao alocar turma: %', SQLERRM;
END;
$$;

GRANT ALL ON FUNCTION public.matricula_alocar_turma(jsonb, uuid) TO anon;
GRANT ALL ON FUNCTION public.matricula_alocar_turma(jsonb, uuid) TO authenticated;
GRANT ALL ON FUNCTION public.matricula_alocar_turma(jsonb, uuid) TO service_role;


-- 5. RPC: turmas_get_paginado (Fix Permissions / Signature)
-- Reforçar a definição para garantir que existe e tem permissão
CREATE OR REPLACE FUNCTION public.turmas_get_paginado(
    p_id_empresa uuid, 
    p_pagina integer DEFAULT 1, 
    p_limite_itens_pagina integer DEFAULT 10, 
    p_busca text DEFAULT NULL::text,
    p_id_ano_etapa uuid DEFAULT NULL::uuid,
    p_ano integer DEFAULT NULL::integer
) RETURNS TABLE(
    id uuid, 
    id_escola uuid, 
    id_ano_etapa uuid, 
    id_classe uuid, 
    id_horario uuid, 
    ano text, 
    nome_escola text, 
    nome_turma text, 
    periodo text, 
    hora_inicio text, 
    hora_fim text, 
    hora_completo text, 
    total_registros bigint
)
LANGUAGE plpgsql SECURITY DEFINER
SET "search_path" TO 'public'
AS $$
DECLARE
    v_offset integer;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    RETURN QUERY
    WITH turmas_filtradas AS (
        SELECT
            t.id,
            t.id_escola,
            t.id_ano_etapa,
            t.id_classe,
            t.id_horario,
            t.ano,
            e.nome as nome_escola,
            (ae.nome || ' ' || c.nome) as nome_turma,
            h.periodo::text as periodo,
            h.hora_inicio,
            h.hora_fim,
            h.hora_completo
        FROM
            public.turmas t
        JOIN public.escolas e ON t.id_escola = e.id
        JOIN public.ano_etapa ae ON t.id_ano_etapa = ae.id
        JOIN public.classe c ON t.id_classe = c.id
        JOIN public.horarios_escola h ON t.id_horario = h.id
        WHERE
            t.id_empresa = p_id_empresa
            AND (p_id_ano_etapa IS NULL OR t.id_ano_etapa = p_id_ano_etapa)
            AND (p_ano IS NULL OR t.ano = p_ano::text)
            AND (
                p_busca IS NULL 
                OR e.nome ILIKE '%' || p_busca || '%' 
                OR ae.nome ILIKE '%' || p_busca || '%' 
                OR c.nome ILIKE '%' || p_busca || '%' 
                OR t.ano ILIKE '%' || p_busca || '%'
            )
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM turmas_filtradas
    )
    SELECT
        tf.id,
        tf.id_escola,
        tf.id_ano_etapa,
        tf.id_classe,
        tf.id_horario,
        tf.ano,
        tf.nome_escola,
        tf.nome_turma,
        tf.periodo,
        tf.hora_inicio,
        tf.hora_fim,
        tf.hora_completo,
        tc.total as total_registros
    FROM
        turmas_filtradas tf
    CROSS JOIN
        total_count tc
    ORDER BY
        tf.nome_escola ASC, tf.ano DESC, tf.nome_turma ASC
    LIMIT
        p_limite_itens_pagina
    OFFSET
        v_offset;
END;
$$;

GRANT ALL ON FUNCTION public.turmas_get_paginado(uuid, integer, integer, text, uuid, integer) TO anon;
GRANT ALL ON FUNCTION public.turmas_get_paginado(uuid, integer, integer, text, uuid, integer) TO authenticated;
GRANT ALL ON FUNCTION public.turmas_get_paginado(uuid, integer, integer, text, uuid, integer) TO service_role;
