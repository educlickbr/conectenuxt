-- Migration: Avaliação Secretaria (Grades & Grid)

-- 1. Ensure Table for Student Responses Exists
CREATE TABLE IF NOT EXISTS public.avaliacao_resposta (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    id_empresa uuid NOT NULL,
    id_turma uuid NOT NULL,
    id_aluno uuid NOT NULL, -- Link to user_expandido or matricula? Using user_expandido ID as common User Identifier.
    id_modelo uuid NOT NULL, -- Optimization to filter by model
    id_item uuid NOT NULL, -- The specific question/criteria being graded
    conceito numeric, -- Use numeric for flexible grading. If conceptual, map via backend/frontend logic.
    observacao text,
    criado_em timestamp with time zone DEFAULT now(),
    modificado_em timestamp with time zone DEFAULT now(),
    criado_por uuid,
    modificado_por uuid,
    CONSTRAINT avaliacao_resposta_unique_entry UNIQUE (id_turma, id_aluno, id_item)
);

-- Index for Grid Performance
CREATE INDEX IF NOT EXISTS idx_avaliacao_resposta_lookup ON public.avaliacao_resposta (id_turma, id_modelo);

-- 2. RPC: Get Grid (Students + Assessments)
-- Returns list of students in the class with their current grades for the model.
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
            u.avatar_url AS foto_aluno,
            m.status AS status_matricula,
            -- Aggregated Responses for this Student & Model
            (
                SELECT jsonb_agg(jsonb_build_object(
                    'id_item', ar.id_item,
                    'conceito', ar.conceito,
                    'observacao', ar.observacao,
                    'id_resposta', ar.id
                ))
                FROM public.avaliacao_resposta ar
                WHERE ar.id_empresa = p_id_empresa
                  AND ar.id_turma = p_id_turma
                  AND ar.id_modelo = p_id_modelo
                  AND ar.id_aluno = u.id
            ) AS respostas,
            -- Optional: Student level observation for this model?
            (
                 SELECT ar.observacao 
                 FROM public.avaliacao_resposta ar
                 WHERE ar.id_empresa = p_id_empresa
                  AND ar.id_turma = p_id_turma
                  AND ar.id_modelo = p_id_modelo
                  AND ar.id_aluno = u.id
                 LIMIT 1 -- Just creating a loose placeholder if needed, mostly redundant with item obs
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
            AND mt.status = 'ativa' -- Show active only? Or all? Usually active for grading.
            AND m.status = 'ativa'
            AND u.soft_delete IS FALSE
        ORDER BY
            u.nome_completo ASC
    ) sub;

    RETURN COALESCE(v_result, '[]'::jsonb);
END;
$function$;

-- 3. RPC: Batch Register Grades (Wrapper)
-- Receives a generic "payload" (p_data) from BFF and processes it.
-- Expected p_data structure:
-- {
--    "id_turma": "...",
--    "id_aluno": "...",
--    "id_modelo_avaliacao": "...",
--    "respostas": [ { "id_item_avaliacao": "...", "conceito": 10 }, ... ]
-- }
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
BEGIN
    -- Extract Context
    v_id_turma := (p_data->>'id_turma')::uuid;
    v_id_aluno := (p_data->>'id_aluno')::uuid;
    v_id_modelo := (p_data->>'id_modelo_avaliacao')::uuid;

    IF v_id_turma IS NULL OR v_id_aluno IS NULL OR v_id_modelo IS NULL THEN
        RAISE EXCEPTION 'Dados incompletos para registro de avaliação.';
    END IF;

    -- Loop through responses
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_data->'respostas')
    LOOP
        INSERT INTO public.avaliacao_resposta (
            id_empresa,
            id_turma,
            id_aluno,
            id_modelo,
            id_item,
            conceito,
            modificado_em
        ) VALUES (
            p_id_empresa,
            v_id_turma,
            v_id_aluno,
            v_id_modelo,
            (v_item->>'id_item_avaliacao')::uuid,
            (v_item->>'conceito')::numeric,
            now()
        )
        ON CONFLICT (id_turma, id_aluno, id_item)
        DO UPDATE SET
            conceito = EXCLUDED.conceito,
            modificado_em = now();
    END LOOP;

    RETURN jsonb_build_object('success', true, 'message', 'Notas salvas com sucesso.');
END;
$function$;
