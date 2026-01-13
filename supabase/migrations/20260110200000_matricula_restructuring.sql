-- 1. Redefinição da Tabela de Matrículas (Simplificada para Vínculo Ano/Etapa)
DROP TABLE IF EXISTS public.matriculas CASCADE;

CREATE TABLE public.matriculas (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_aluno uuid NOT NULL,
    id_ano_etapa uuid NOT NULL,
    status text NOT NULL, -- 'ativa', 'transferida', 'cancelada', 'evadida', 'concluida'
    observacao text NULL,
    criado_em timestamp with time zone NULL DEFAULT now(),
    CONSTRAINT matriculas_pkey PRIMARY KEY (id),
    CONSTRAINT matriculas_id_aluno_fkey FOREIGN KEY (id_aluno) REFERENCES user_expandido (id) ON DELETE CASCADE,
    CONSTRAINT matriculas_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE CASCADE,
    CONSTRAINT matriculas_id_ano_etapa_fkey FOREIGN KEY (id_ano_etapa) REFERENCES ano_etapa (id) ON DELETE CASCADE,
    CONSTRAINT matriculas_status_check CHECK (
        status = ANY (ARRAY['ativa'::text, 'transferida'::text, 'cancelada'::text, 'evadida'::text, 'concluida'::text])
    )
) TABLESPACE pg_default;

CREATE INDEX idx_matriculas_empresa ON public.matriculas (id_empresa);
CREATE INDEX idx_matriculas_aluno ON public.matriculas (id_aluno);
CREATE INDEX idx_matriculas_ano_etapa ON public.matriculas (id_ano_etapa);
CREATE INDEX idx_matriculas_status ON public.matriculas (status);

-- 2. Tabela de Histórico de Turmas (Matrícula x Turma)
CREATE TABLE public.matricula_turma (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_matricula uuid NOT NULL,
    id_turma uuid NOT NULL,
    id_empresa uuid NOT NULL,
    data_entrada date NOT NULL DEFAULT CURRENT_DATE,
    data_saida date NULL,
    status text NOT NULL DEFAULT 'ativa', -- 'ativa', 'concluida', 'removida'
    criado_em timestamp with time zone NULL DEFAULT now(),
    CONSTRAINT matricula_turma_pkey PRIMARY KEY (id),
    CONSTRAINT matricula_turma_id_matricula_fkey FOREIGN KEY (id_matricula) REFERENCES public.matriculas (id) ON DELETE CASCADE,
    CONSTRAINT matricula_turma_id_turma_fkey FOREIGN KEY (id_turma) REFERENCES public.turmas (id) ON DELETE CASCADE,
    CONSTRAINT matricula_turma_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE CASCADE
) TABLESPACE pg_default;

CREATE INDEX idx_matricula_turma_matricula ON public.matricula_turma (id_matricula);
CREATE INDEX idx_matricula_turma_turma ON public.matricula_turma (id_turma);
CREATE INDEX idx_matricula_turma_empresa ON public.matricula_turma (id_empresa);

-- 3. RPCs para Gestão

-- matricula_get_paginado
CREATE OR REPLACE FUNCTION public.matricula_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text)
    RETURNS json
    LANGUAGE plpgsql
AS $BODY$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    SELECT COUNT(*) INTO v_total_itens
    FROM public.matriculas m
    JOIN public.user_expandido u ON u.id = m.id_aluno
    WHERE 
        m.id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(u.nome_completo) LIKE v_busca_like 
            OR UPPER(m.status) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(t), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            m.*,
            u.nome_completo as aluno_nome,
            ae.nome as ano_etapa_nome
        FROM public.matriculas m
        JOIN public.user_expandido u ON u.id = m.id_aluno
        JOIN public.ano_etapa ae ON ae.id = m.id_ano_etapa
        WHERE 
            m.id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(u.nome_completo) LIKE v_busca_like 
                OR UPPER(m.status) LIKE v_busca_like
            )
        ORDER BY m.criado_em DESC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$BODY$;

-- matricula_upsert
CREATE OR REPLACE FUNCTION public.matricula_upsert(
    p_data jsonb,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_id uuid;
    v_matricula_salva public.matriculas;
BEGIN
    v_id := coalesce(nullif(p_data ->> 'id', '')::uuid, gen_random_uuid());

    INSERT INTO public.matriculas (
        id, id_empresa, id_aluno, id_ano_etapa, status, observacao
    )
    VALUES (
        v_id,
        p_id_empresa,
        (p_data ->> 'id_aluno')::uuid,
        (p_data ->> 'id_ano_etapa')::uuid,
        (p_data ->> 'status'),
        (p_data ->> 'observacao')
    )
    ON CONFLICT (id) DO UPDATE 
    SET 
        status = EXCLUDED.status,
        observacao = EXCLUDED.observacao,
        id_ano_etapa = EXCLUDED.id_ano_etapa
    WHERE public.matriculas.id_empresa = p_id_empresa
    RETURNING * INTO v_matricula_salva;

    RETURN to_jsonb(v_matricula_salva);
END;
$$;

-- matricula_delete
CREATE OR REPLACE FUNCTION public.matricula_delete(
    p_id uuid,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_deleted_count integer;
BEGIN
    DELETE FROM public.matriculas
    WHERE id = p_id
      AND id_empresa = p_id_empresa;
      
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN jsonb_build_object('status', 'success', 'message', 'Matrícula removida com sucesso.', 'id', p_id);
    ELSE
        RETURN jsonb_build_object('status', 'error', 'message', 'Matrícula não encontrada.', 'id', p_id);
    END IF;
END;
$$;

-- matricula_alocar_turma
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
    v_ch_salva public.matricula_turma;
BEGIN
    v_id := coalesce(nullif(p_data ->> 'id', '')::uuid, gen_random_uuid());

    -- Se já houver uma alocação ativa para esta matrícula, opcionalmente 'fechar' a anterior
    UPDATE public.matricula_turma
    SET data_saida = CURRENT_DATE,
        status = 'substituida'
    WHERE id_matricula = (p_data ->> 'id_matricula')::uuid
      AND status = 'ativa'
      AND id != v_id;

    INSERT INTO public.matricula_turma (
        id, id_matricula, id_turma, id_empresa, data_entrada, status
    )
    VALUES (
        v_id,
        (p_data ->> 'id_matricula')::uuid,
        (p_data ->> 'id_turma')::uuid,
        p_id_empresa,
        coalesce((p_data ->> 'data_entrada')::date, CURRENT_DATE),
        'ativa'
    )
    ON CONFLICT (id) DO UPDATE 
    SET 
        id_turma = EXCLUDED.id_turma,
        data_entrada = EXCLUDED.data_entrada,
        status = EXCLUDED.status
    RETURNING * INTO v_ch_salva;

    RETURN to_jsonb(v_ch_salva);
END;
$$;

-- matricula_turma_get_por_matricula
CREATE OR REPLACE FUNCTION public.matricula_turma_get_por_matricula(
    p_id_empresa uuid,
    p_id_matricula uuid
)
RETURNS json
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_itens json;
BEGIN
    SELECT COALESCE(json_agg(t), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            mt.*,
            t.nome as turma_nome
        FROM public.matricula_turma mt
        JOIN public.turmas t ON t.id = mt.id_turma
        WHERE mt.id_empresa = p_id_empresa
          AND mt.id_matricula = p_id_matricula
        ORDER BY mt.data_entrada DESC
    ) t;

    RETURN json_build_object(
        'itens', v_itens
    );
END;
$$;
