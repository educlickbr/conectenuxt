-- 1. Tabela diario_aula
CREATE TABLE IF NOT EXISTS public.diario_aula (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_turma uuid NOT NULL,
    id_componente uuid, -- Pode ser nulo em contexto de educação infantil ou polivalente? Geralmente não, mas vamos deixar nullable por segurança se o plano não especificou constraint. Mas componente é essencial. Vamos deixar NULLABLE pois o user questionou (nullable?) no plano.
    data date NOT NULL,
    conteudo text,
    metodologia text,
    tarefa_casa text,
    registrado_por uuid,
    registrado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT diario_aula_pkey PRIMARY KEY (id),
    CONSTRAINT diario_aula_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa (id) ON DELETE CASCADE,
    CONSTRAINT diario_aula_turma_fkey FOREIGN KEY (id_turma) REFERENCES public.turmas (id) ON DELETE CASCADE,
    CONSTRAINT diario_aula_componente_fkey FOREIGN KEY (id_componente) REFERENCES public.componente (uuid) ON DELETE SET NULL,
    CONSTRAINT diario_aula_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES public.user_expandido (id) ON DELETE SET NULL
) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_diario_aula_turma ON public.diario_aula (id_turma);
CREATE INDEX IF NOT EXISTS idx_diario_aula_data ON public.diario_aula (data);
CREATE INDEX IF NOT EXISTS idx_diario_aula_empresa ON public.diario_aula (id_empresa);


-- 2. Tabela diario_presenca
CREATE TABLE IF NOT EXISTS public.diario_presenca (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_matricula uuid NOT NULL,
    id_turma uuid NOT NULL, -- Added for context
    id_componente uuid,
    data date NOT NULL,
    presente boolean NOT NULL DEFAULT false,
    observacao text,
    registrado_por uuid,
    registrado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT diario_presenca_pkey PRIMARY KEY (id),
    CONSTRAINT diario_presenca_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa (id) ON DELETE CASCADE,
    CONSTRAINT diario_presenca_matricula_fkey FOREIGN KEY (id_matricula) REFERENCES public.matriculas (id) ON DELETE CASCADE,
    CONSTRAINT diario_presenca_turma_fkey FOREIGN KEY (id_turma) REFERENCES public.turmas (id) ON DELETE CASCADE,
    CONSTRAINT diario_presenca_componente_fkey FOREIGN KEY (id_componente) REFERENCES public.componente (uuid) ON DELETE SET NULL,
    CONSTRAINT diario_presenca_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES public.user_expandido (id) ON DELETE SET NULL
) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_diario_presenca_empresa ON public.diario_presenca (id_empresa);
CREATE INDEX IF NOT EXISTS idx_diario_presenca_turma ON public.diario_presenca (id_turma);
CREATE INDEX IF NOT EXISTS idx_diario_presenca_data ON public.diario_presenca (data);
CREATE INDEX IF NOT EXISTS idx_diario_presenca_matricula ON public.diario_presenca (id_matricula);

-- Unique constraint para evitar duplicidade de chamada para o mesmo aluno/turma/componente/dia
CREATE UNIQUE INDEX IF NOT EXISTS idx_diario_presenca_unique 
ON public.diario_presenca (id_matricula, id_turma, data, COALESCE(id_componente, '00000000-0000-0000-0000-000000000000'));


-- 3. Functions

-- 3.1 diario_aula_upsert
CREATE OR REPLACE FUNCTION public.diario_aula_upsert(
    p_data jsonb,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_id uuid;
    v_registro_salvo public.diario_aula;
    v_user_id uuid;
BEGIN
    v_id := coalesce(nullif(p_data ->> 'id', '')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid; -- Assuming frontend sends id_usuario or we deduce it. Usually passed in logic.

    INSERT INTO public.diario_aula (
        id, 
        id_empresa, 
        id_turma, 
        id_componente, 
        data, 
        conteudo, 
        metodologia, 
        tarefa_casa, 
        registrado_por, 
        registrado_em
    )
    VALUES (
        v_id,
        p_id_empresa,
        (p_data ->> 'id_turma')::uuid,
        (p_data ->> 'id_componente')::uuid,
        (p_data ->> 'data')::date,
        (p_data ->> 'conteudo'),
        (p_data ->> 'metodologia'),
        (p_data ->> 'tarefa_casa'),
        v_user_id,
        now()
    )
    ON CONFLICT (id) DO UPDATE 
    SET 
        id_turma = EXCLUDED.id_turma,
        id_componente = EXCLUDED.id_componente,
        data = EXCLUDED.data,
        conteudo = EXCLUDED.conteudo,
        metodologia = EXCLUDED.metodologia,
        tarefa_casa = EXCLUDED.tarefa_casa,
        registrado_por = v_user_id
        -- registrado_em mantemos o original ou atualizamos? Normalmente mantemos a criação e temos um modificado_em, mas a tabela não tem modificado_em. Vamos manter registrado_em original.
    WHERE public.diario_aula.id_empresa = p_id_empresa
    RETURNING * INTO v_registro_salvo;

    RETURN to_jsonb(v_registro_salvo);
END;
$$;


-- 3.2 diario_aula_get_paginado
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
            u.nome_completo as professor_nome,
            c.nome as componente_nome
        FROM public.diario_aula d
        LEFT JOIN public.user_expandido u ON u.id = d.registrado_por
        LEFT JOIN public.componente c ON c.uuid = d.id_componente
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


-- 3.3 diario_presenca_upsert_batch
CREATE OR REPLACE FUNCTION public.diario_presenca_upsert_batch(
    p_payload jsonb, -- Expects array of objects
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_item jsonb;
    v_count integer := 0;
    v_user_id uuid;
BEGIN
    -- Iterate over the array
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_payload)
    LOOP
        v_user_id := (v_item ->> 'id_usuario')::uuid;

        INSERT INTO public.diario_presenca (
            id,
            id_empresa,
            id_matricula,
            id_turma,
            id_componente,
            data,
            presente,
            observacao,
            registrado_por,
            registrado_em
        )
        VALUES (
            coalesce(nullif(v_item ->> 'id', '')::uuid, gen_random_uuid()),
            p_id_empresa,
            (v_item ->> 'id_matricula')::uuid,
            (v_item ->> 'id_turma')::uuid,
            (v_item ->> 'id_componente')::uuid,
            (v_item ->> 'data')::date,
            coalesce((v_item ->> 'presente')::boolean, false),
            (v_item ->> 'observacao'),
            v_user_id,
            now()
        )
        ON CONFLICT (id) DO UPDATE
        SET
            presente = EXCLUDED.presente,
            observacao = EXCLUDED.observacao,
            registrado_por = v_user_id
        WHERE public.diario_presenca.id_empresa = p_id_empresa;

        -- Alternatively we could conflict on unique index (matricula, turma, date, componente) 
        -- but ID logic is safer if provided by frontend.
        
        v_count := v_count + 1;
    END LOOP;

    RETURN jsonb_build_object('status', 'success', 'processed_count', v_count);
END;
$$;


-- 3.4 diario_presenca_get_por_turma
CREATE OR REPLACE FUNCTION public.diario_presenca_get_por_turma(
    p_id_empresa uuid,
    p_id_turma uuid,
    p_data date,
    p_id_componente uuid DEFAULT NULL -- Componente context for filters
)
RETURNS json
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_itens json;
BEGIN
    -- Logic: Get students with ACTIVE matricula_turma on p_data
    -- Join with diario_presenca for that day/componente
    
    SELECT COALESCE(json_agg(t), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            m.id as id_matricula,
            u.nome_completo as aluno_nome,
            m.status as status_matricula,
            dp.id as id_presenca,
            dp.presente,
            dp.observacao,
            dp.registrado_em
        FROM public.matricula_turma mt
        JOIN public.matriculas m ON m.id = mt.id_matricula
        JOIN public.user_expandido u ON u.id = m.id_aluno
        LEFT JOIN public.diario_presenca dp ON 
            dp.id_matricula = m.id 
            AND dp.id_turma = p_id_turma -- Ensures we match the presence for THIS class context
            AND dp.data = p_data
            AND (
                (p_id_componente IS NULL AND dp.id_componente IS NULL) OR
                (dp.id_componente = p_id_componente)
            )
        WHERE 
            mt.id_empresa = p_id_empresa
            AND mt.id_turma = p_id_turma
            AND mt.data_entrada <= p_data
            AND (mt.data_saida IS NULL OR mt.data_saida >= p_data)
            AND mt.status != 'removida' -- Check canceled/removed status logic
        ORDER BY u.nome_completo
    ) t;

    RETURN json_build_object(
        'data', p_data,
        'turma_id', p_id_turma,
        'alunos', v_itens
    );
END;
$$;
