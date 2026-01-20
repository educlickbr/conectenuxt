-- Refactor: Switch to User's Schema (Header + Detail)
-- 1. Drop temporary table
DROP TABLE IF EXISTS public.avaliacao_resposta CASCADE;

-- 2. Ensure Schema Exists (Header)
-- user_expandido references must match existing DB
CREATE TABLE IF NOT EXISTS public.avaliacao_aluno (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_turma uuid NOT NULL,
    id_aluno uuid NOT NULL,
    id_modelo_avaliacao uuid NOT NULL,
    id_ano_etapa uuid NOT NULL,
    data_realizacao timestamptz DEFAULT now(),
    status text NOT NULL DEFAULT 'PENDENTE',
    observacao text,
    criado_por uuid DEFAULT auth.uid(),
    criado_em timestamptz DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamptz,
    CONSTRAINT avaliacao_aluno_pkey PRIMARY KEY (id),
    CONSTRAINT avaliacao_aluno_unique UNIQUE (id_aluno, id_modelo_avaliacao, id_ano_etapa)
);

-- 3. Ensure Schema Exists (Detail)
CREATE TABLE IF NOT EXISTS public.avaliacao_aluno_resposta (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_avaliacao_aluno uuid NOT NULL,
    id_item_avaliacao uuid NOT NULL,
    conceito int,
    criado_por uuid DEFAULT auth.uid(),
    criado_em timestamptz DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamptz,
    CONSTRAINT avaliacao_aluno_resposta_pkey PRIMARY KEY (id),
    CONSTRAINT avaliacao_aluno_resposta_unique UNIQUE (id_avaliacao_aluno, id_item_avaliacao)
);

-- 4. Update GET Grid Function
CREATE OR REPLACE FUNCTION public.avaliacao_diario_get_grid(
    p_id_empresa uuid,
    p_id_turma uuid,
    p_id_modelo uuid
)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    v_result jsonb;
BEGIN
    SELECT jsonb_agg(sub)
    INTO v_result
    FROM (
        SELECT
            u.id AS id_aluno,
            u.nome_completo AS nome_aluno,
            NULL::text AS foto_aluno, 
            m.status AS status_matricula,
            -- Aggregated Responses for this Student & Model
            (
                SELECT jsonb_agg(jsonb_build_object(
                    'id_item', ar.id_item_avaliacao,
                    'conceito', ar.conceito,
                    'id_resposta', ar.id
                ))
                FROM public.avaliacao_aluno aa_inner
                JOIN public.avaliacao_aluno_resposta ar ON ar.id_avaliacao_aluno = aa_inner.id
                WHERE aa_inner.id_empresa = p_id_empresa
                  AND aa_inner.id_turma = p_id_turma
                  AND aa_inner.id_modelo_avaliacao = p_id_modelo
                  AND aa_inner.id_aluno = u.id
            ) AS respostas,
            -- Student level observation
             (
                 SELECT aa_inner.observacao 
                 FROM public.avaliacao_aluno aa_inner
                 WHERE aa_inner.id_empresa = p_id_empresa
                  AND aa_inner.id_turma = p_id_turma
                  AND aa_inner.id_modelo_avaliacao = p_id_modelo
                  AND aa_inner.id_aluno = u.id
                 LIMIT 1 
            ) AS observacao_avaliacao
        FROM
            public.matricula_turma mt
        JOIN
            public.matriculas m ON m.id = mt.id_matricula
        JOIN
            public.user_expandido u ON u.id = m.id_aluno
        WHERE
            mt.id_empresa = p_id_empresa
            AND mt.id_turma = p_id_turma
            AND mt.status = 'ativa'
            AND m.status = 'ativa'
            AND u.soft_delete IS FALSE
        ORDER BY
            u.nome_completo ASC
    ) sub;

    RETURN COALESCE(v_result, '[]'::jsonb);
END;
$function$;


-- 5. Update Wrapper Function (Upsert Header -> Upsert Items)
CREATE OR REPLACE FUNCTION public.avaliacao_aluno_registrar_completa_wrapper(
    p_id_empresa uuid,
    p_data jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    v_item jsonb;
    v_id_turma uuid;
    v_id_aluno uuid;
    v_id_modelo uuid;
    v_id_ano_etapa uuid;
    
    v_id_header uuid;
    v_user_id uuid;
BEGIN
    -- Extract Context
    v_id_turma := (p_data->>'id_turma')::uuid;
    v_id_aluno := (p_data->>'id_aluno')::uuid;
    v_id_modelo := (p_data->>'id_modelo_avaliacao')::uuid;
    v_id_ano_etapa := (p_data->>'id_ano_etapa')::uuid; -- IMPORTANT
    v_user_id := auth.uid();

    IF v_id_turma IS NULL OR v_id_aluno IS NULL OR v_id_modelo IS NULL OR v_id_ano_etapa IS NULL THEN
        RAISE EXCEPTION 'Dados incompletos para registro de avaliação (Falha Ano/Etapa?).';
    END IF;

    -- 1. Upsert Header (avaliacao_aluno)
    INSERT INTO public.avaliacao_aluno (
        id_empresa, id_turma, id_aluno, id_modelo_avaliacao, id_ano_etapa, 
        status, observacao, criado_por, criado_em, modificado_por, modificado_em
    ) VALUES (
        p_id_empresa, v_id_turma, v_id_aluno, v_id_modelo, v_id_ano_etapa,
        'CONCLUIDA', NULL, v_user_id, now(), v_user_id, now()
    )
    ON CONFLICT (id_aluno, id_modelo_avaliacao, id_ano_etapa)
    DO UPDATE SET 
        status = 'CONCLUIDA',
        modificado_por = v_user_id,
        modificado_em = now()
    RETURNING id INTO v_id_header;

    -- 2. Process Items (avaliacao_aluno_resposta)
    IF p_data->'respostas' IS NOT NULL AND jsonb_typeof(p_data->'respostas') = 'array' THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_data->'respostas')
        LOOP
            INSERT INTO public.avaliacao_aluno_resposta (
                id_empresa,
                id_avaliacao_aluno,
                id_item_avaliacao,
                conceito,
                criado_por, criado_em, modificado_por, modificado_em
            ) VALUES (
                p_id_empresa,
                v_id_header,
                (v_item->>'id_item_avaliacao')::uuid,
                (v_item->>'conceito')::int,
                v_user_id, now(), v_user_id, now()
            )
            ON CONFLICT (id_avaliacao_aluno, id_item_avaliacao)
            DO UPDATE SET
                conceito = EXCLUDED.conceito,
                modificado_por = v_user_id,
                modificado_em = now();
        END LOOP;
    END IF;

    RETURN jsonb_build_object('success', true, 'message', 'Notas salvas com sucesso.');
END;
$function$;
