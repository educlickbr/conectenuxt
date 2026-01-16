-- Migration for Student Evaluation Recording
-- Tables: avaliacao_aluno, avaliacao_aluno_resposta

-- 1. Table: avaliacao_aluno (Header)
CREATE TABLE IF NOT EXISTS public.avaliacao_aluno (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_turma uuid NOT NULL, -- Context of application
    id_aluno uuid NOT NULL, -- Student (user_expandido)
    id_modelo_avaliacao uuid NOT NULL, -- Model applied
    id_ano_etapa uuid NOT NULL, -- Period
    data_realizacao timestamptz DEFAULT now(),
    status text NOT NULL DEFAULT 'PENDENTE', -- 'PENDENTE', 'CONCLUIDA', etc.
    observacao text,
    
    criado_por uuid DEFAULT auth.uid(),
    criado_em timestamptz DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamptz,

    CONSTRAINT avaliacao_aluno_pkey PRIMARY KEY (id),
    CONSTRAINT avaliacao_aluno_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id),
    CONSTRAINT avaliacao_aluno_turma_fk FOREIGN KEY (id_turma) REFERENCES public.turmas(id),
    CONSTRAINT avaliacao_aluno_aluno_fk FOREIGN KEY (id_aluno) REFERENCES public.user_expandido(id),
    CONSTRAINT avaliacao_aluno_modelo_fk FOREIGN KEY (id_modelo_avaliacao) REFERENCES public.avaliacao_modelo(id),
    CONSTRAINT avaliacao_aluno_ano_etapa_fk FOREIGN KEY (id_ano_etapa) REFERENCES public.ano_etapa(id),
    CONSTRAINT avaliacao_aluno_criado_por_fk FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id),
    CONSTRAINT avaliacao_aluno_modificado_por_fk FOREIGN KEY (modificado_por) REFERENCES public.user_expandido(id),
    
    -- Ensure one evaluation per student per model (?) - Optional constraint, but safe to assume for now.
    -- If reassessment is needed, maybe allow duplicates or handle via status/version. 
    -- User didn't specify, but usually you want unique (aluno, modelo, ano_etapa).
    CONSTRAINT avaliacao_aluno_unique UNIQUE (id_aluno, id_modelo_avaliacao, id_ano_etapa)
);

-- 2. Table: avaliacao_aluno_resposta (Detail)
CREATE TABLE IF NOT EXISTS public.avaliacao_aluno_resposta (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_avaliacao_aluno uuid NOT NULL,
    id_item_avaliacao uuid NOT NULL,
    conceito int, -- Grade/Concept (Integer x100) or raw score
    
    criado_por uuid DEFAULT auth.uid(),
    criado_em timestamptz DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamptz,

    CONSTRAINT avaliacao_aluno_resposta_pkey PRIMARY KEY (id),
    CONSTRAINT avaliacao_aluno_resposta_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id),
    CONSTRAINT avaliacao_aluno_resposta_header_fk FOREIGN KEY (id_avaliacao_aluno) REFERENCES public.avaliacao_aluno(id) ON DELETE CASCADE,
    CONSTRAINT avaliacao_aluno_resposta_item_fk FOREIGN KEY (id_item_avaliacao) REFERENCES public.itens_avaliacao(id),
    CONSTRAINT avaliacao_aluno_resposta_criado_por_fk FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id),
    CONSTRAINT avaliacao_aluno_resposta_modificado_por_fk FOREIGN KEY (modificado_por) REFERENCES public.user_expandido(id),
    
    CONSTRAINT avaliacao_aluno_resposta_unique UNIQUE (id_avaliacao_aluno, id_item_avaliacao)
);

-- Enable RLS
ALTER TABLE public.avaliacao_aluno ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.avaliacao_aluno_resposta ENABLE ROW LEVEL SECURITY;

-- RLS Policies (Admin All)
CREATE POLICY "Admin All Avaliacao Aluno" ON public.avaliacao_aluno FOR ALL TO authenticated USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)) WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa));
CREATE POLICY "Admin All Avaliacao Resposta" ON public.avaliacao_aluno_resposta FOR ALL TO authenticated USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)) WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa));


-- FUNCTIONS

-- 1. Transactional Upsert (Header + Details)
CREATE OR REPLACE FUNCTION public.avaliacao_aluno_registrar_completa(
    p_id_empresa uuid,
    p_header jsonb,       -- { id, id_turma, id_aluno, id_modelo_avaliacao, id_ano_etapa, status, observacao }
    p_respostas jsonb     -- [{ id_item_avaliacao, conceito }, ...]
)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_id_header uuid;
    v_registro_header public.avaliacao_aluno;
    v_user_id uuid;
    v_resposta jsonb;
    v_item RECORD;
BEGIN
    v_id_header := coalesce((p_header ->> 'id')::uuid, gen_random_uuid());
    -- Fallback for user_id from p_header if present, else auth.uid() (but function is Security Definer, so auth.uid() works if called via RPC)
    -- Actually better to trust data payload if we are in admin context or use auth.uid() 
    -- We'll use auth.uid() for audit if not passed.
    v_user_id := auth.uid(); 
    
    -- 1. Upsert Header
    insert into public.avaliacao_aluno as t (
        id, id_empresa, id_turma, id_aluno, id_modelo_avaliacao, id_ano_etapa, status, observacao,
        criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id_header,
        p_id_empresa,
        (p_header ->> 'id_turma')::uuid,
        (p_header ->> 'id_aluno')::uuid,
        (p_header ->> 'id_modelo_avaliacao')::uuid,
        (p_header ->> 'id_ano_etapa')::uuid,
        coalesce(p_header ->> 'status', 'PENDENTE'),
        p_header ->> 'observacao',
        v_user_id, now(), v_user_id, now()
    )
    on conflict (id) do update
    set status = excluded.status,
        observacao = excluded.observacao,
        modificado_por = v_user_id,
        modificado_em = now()
    returning * into v_registro_header;

    -- 2. Process Answers
    -- Strategy: We use upsert for each item. 
    -- If p_respostas is null, we do nothing (maybe just header update).
    
    IF p_respostas IS NOT NULL AND jsonb_array_length(p_respostas) > 0 THEN
        FOR v_resposta IN SELECT * FROM jsonb_array_elements(p_respostas)
        LOOP
            INSERT INTO public.avaliacao_aluno_resposta (
                id_empresa, id_avaliacao_aluno, id_item_avaliacao, conceito, 
                criado_por, criado_em, modificado_por, modificado_em
            )
            VALUES (
                p_id_empresa,
                v_id_header,
                (v_resposta ->> 'id_item_avaliacao')::uuid,
                (v_resposta ->> 'conceito')::int,
                v_user_id, now(), v_user_id, now()
            )
            ON CONFLICT (id_avaliacao_aluno, id_item_avaliacao) DO UPDATE
            SET conceito = excluded.conceito,
                modificado_por = v_user_id,
                modificado_em = now();
        END LOOP;
    END IF;

    return to_jsonb(v_registro_header);

EXCEPTION WHEN OTHERS THEN
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
END;
$function$;
ALTER FUNCTION public.avaliacao_aluno_registrar_completa(uuid, jsonb, jsonb) OWNER TO postgres;

-- 2. Delete Evaluation
CREATE OR REPLACE FUNCTION public.avaliacao_aluno_delete(p_id uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
    -- Cascade deletes answers
    DELETE FROM public.avaliacao_aluno WHERE id = p_id AND id_empresa = p_id_empresa;
    if found then return jsonb_build_object('status', 'success'); else return jsonb_build_object('status', 'error', 'message', 'Avaliação não encontrada.'); end if;
end;
$function$;
ALTER FUNCTION public.avaliacao_aluno_delete(uuid, uuid) OWNER TO postgres;

-- 3. Get By Turma (Gradebook view)
-- Returns list of Headers with summary? Or just headers? 
-- Let's return Headers + Respostas as nested json?
-- Keeping it simple: Headers only, or Headers with total score?
-- For now, returning Headers. The Frontend can fetch details individually or we aggregate.
-- Ideally we want to load all data for the gradebook.
CREATE OR REPLACE FUNCTION public.avaliacao_aluno_get_by_turma(
    p_id_empresa uuid,
    p_id_turma uuid,
    p_id_modelo uuid DEFAULT NULL -- Optional filter
)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_itens jsonb;
BEGIN
    SELECT jsonb_agg(row_to_json(t)) INTO v_itens
    FROM (
        SELECT 
            aa.*,
            ue.nome_completo as nome_aluno,
            -- Aggregated answers
            (
                SELECT jsonb_agg(row_to_json(aar))
                FROM public.avaliacao_aluno_resposta aar
                WHERE aar.id_avaliacao_aluno = aa.id
            ) as respostas
        FROM public.avaliacao_aluno aa
        JOIN public.user_expandido ue ON ue.id = aa.id_aluno
        WHERE aa.id_empresa = p_id_empresa
          AND aa.id_turma = p_id_turma
          AND (p_id_modelo IS NULL OR aa.id_modelo_avaliacao = p_id_modelo)
        ORDER BY ue.nome_completo ASC
    ) t;
    return coalesce(v_itens, '[]'::jsonb);
END;
$function$;
ALTER FUNCTION public.avaliacao_aluno_get_by_turma(uuid, uuid, uuid) OWNER TO postgres;
