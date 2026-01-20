-- Refactor: Link Answers to Criterion Items (Dynamic Values)
-- 1. Add Column
ALTER TABLE public.avaliacao_aluno_resposta 
ADD COLUMN IF NOT EXISTS id_item_criterio uuid REFERENCES public.itens_criterio(id);

-- 2. Update Wrapper (Save id_item_criterio)
DROP FUNCTION IF EXISTS public.avaliacao_aluno_registrar_completa_wrapper(uuid, jsonb);

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
    v_auth_id uuid;
BEGIN
    -- Extract Context
    v_id_turma := (p_data->>'id_turma')::uuid;
    v_id_aluno := (p_data->>'id_aluno')::uuid;
    v_id_modelo := (p_data->>'id_modelo_avaliacao')::uuid;
    v_id_ano_etapa := (p_data->>'id_ano_etapa')::uuid;

    IF v_id_turma IS NULL OR v_id_aluno IS NULL OR v_id_modelo IS NULL OR v_id_ano_etapa IS NULL THEN
        RAISE EXCEPTION 'Dados incompletos para registro de avaliação.';
    END IF;

    -- Resolve ID for user_expandido
    v_auth_id := auth.uid();
    SELECT id INTO v_user_id FROM public.user_expandido WHERE user_id = v_auth_id LIMIT 1;
    IF v_user_id IS NULL THEN
         SELECT id INTO v_user_id FROM public.user_expandido WHERE id = v_auth_id LIMIT 1;
         IF v_user_id IS NULL THEN
            RAISE EXCEPTION 'Usuário logado não encontrado na tabela user_expandido.';
         END IF;
    END IF;

    -- 1. Upsert Header
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

    -- 2. Process Items
    IF p_data->'respostas' IS NOT NULL AND jsonb_typeof(p_data->'respostas') = 'array' THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_data->'respostas')
        LOOP
            INSERT INTO public.avaliacao_aluno_resposta (
                id_empresa,
                id_avaliacao_aluno,
                id_item_avaliacao,
                id_item_criterio, -- New Foreign Key
                conceito, -- Optional: Can be NULL if we rely only on reference, or snapshot. User said "esquecer multiply", maybe implies deriving. 
                          -- But keeping logic flexible: if frontend sends explicit numeric, save it. 
                          -- IF frontend sends id_item_criterio, we save it.
                criado_por, criado_em, modificado_por, modificado_em
            ) VALUES (
                p_id_empresa,
                v_id_header,
                (v_item->>'id_item_avaliacao')::uuid,
                (v_item->>'id_item_criterio')::uuid, 
                NULL, -- We stop saving numeric 'conceito' directly from frontend if relying on id_item_criterio, OR we could fetch it.
                      -- User said: "assim quando eel mudar mudar em todos os lugares".
                      -- This implies we should NOT store the snapshot value. We should read it dynamically.
                      -- So I'm setting conceito to NULL or we can leave it.
                v_user_id, now(), v_user_id, now()
            )
            ON CONFLICT (id_avaliacao_aluno, id_item_avaliacao)
            DO UPDATE SET
                id_item_criterio = EXCLUDED.id_item_criterio,
                conceito = EXCLUDED.conceito,
                modificado_por = v_user_id,
                modificado_em = now();
        END LOOP;
    END IF;

    RETURN jsonb_build_object('success', true, 'message', 'Notas salvas com sucesso.');
END;
$function$;

-- 3. Update Grid to return id_item_criterio and resolve calculated grade
DROP FUNCTION IF EXISTS public.avaliacao_diario_get_grid(uuid, uuid, uuid);

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
            -- Aggregated Responses
            (
                SELECT jsonb_agg(jsonb_build_object(
                    'id_item', ar.id_item_avaliacao,
                    'id_item_criterio', ar.id_item_criterio,
                    'id_resposta', ar.id,
                    -- Dynamic value resolution
                    'conceito', COALESCE(ic.valor_numerico, ar.conceito) 
                ))
                FROM public.avaliacao_aluno aa_inner
                JOIN public.avaliacao_aluno_resposta ar ON ar.id_avaliacao_aluno = aa_inner.id
                LEFT JOIN public.itens_criterio ic ON ic.id = ar.id_item_criterio -- Join to get current value
                WHERE aa_inner.id_empresa = p_id_empresa
                  AND aa_inner.id_turma = p_id_turma
                  AND aa_inner.id_modelo_avaliacao = p_id_modelo
                  AND aa_inner.id_aluno = u.id
            ) AS respostas
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
