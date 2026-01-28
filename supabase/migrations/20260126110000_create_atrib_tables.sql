-- Migration: Create Attribution Tables
-- Creates: atrib_atribuicao_turmas (Polivalente) & atrib_atribuicao_componentes (Componentes)

-- 1. Tabela: atrib_atribuicao_turmas (Cópia estrutural de turma_professor_atribuicao)
CREATE TABLE public.atrib_atribuicao_turmas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_turma uuid NOT NULL,
    id_empresa uuid NOT NULL,
    ano smallint NOT NULL,
    id_professor uuid NOT NULL,
    data_inicio date NOT NULL,
    data_fim date,
    motivo_substituicao text,
    nivel_substituicao integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    editando_por uuid,
    editando_email text,
    CONSTRAINT atrib_atribuicao_turmas_pkey PRIMARY KEY (id),
    CONSTRAINT atrib_atribuicao_turmas_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa(id) ON DELETE CASCADE,
    CONSTRAINT atrib_atribuicao_turmas_id_professor_fkey FOREIGN KEY (id_professor) REFERENCES public.user_expandido(id) ON DELETE CASCADE,
    CONSTRAINT atrib_atribuicao_turmas_id_turma_fkey FOREIGN KEY (id_turma) REFERENCES public.turmas(id) ON DELETE CASCADE
);

-- Indexes for atrib_atribuicao_turmas
CREATE INDEX atrib_turmas_id_turma_empresa_fim_idx ON public.atrib_atribuicao_turmas USING btree (id_turma, id_empresa, data_fim);
CREATE INDEX atrib_turmas_id_professor_idx ON public.atrib_atribuicao_turmas USING btree (id_professor);
CREATE INDEX atrib_turmas_prof_empresa_idx ON public.atrib_atribuicao_turmas USING btree (id_professor, id_empresa);

-- Policies for atrib_atribuicao_turmas
ALTER TABLE public.atrib_atribuicao_turmas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin pode tudo em atrib_turmas" ON public.atrib_atribuicao_turmas
    TO authenticated
    USING ((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text AND (auth.jwt() ->> 'empresa_id'::text)::uuid = id_empresa)
    WITH CHECK ((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text AND (auth.jwt() ->> 'empresa_id'::text)::uuid = id_empresa);

CREATE POLICY "Professor ve suas atrib_turmas" ON public.atrib_atribuicao_turmas
    FOR SELECT
    TO authenticated
    USING (
        (auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['professor'::text, 'professor_funcao_extra'::text])
        AND (auth.jwt() ->> 'empresa_id'::text)::uuid = id_empresa
        AND id_professor IN (SELECT ue.id FROM public.user_expandido ue WHERE ue.user_id = auth.uid())
    );


-- 2. Tabela: atrib_atribuicao_componentes (Substitui professor_componentes_atribuicao + unidade_atribuicao)
CREATE TABLE public.atrib_atribuicao_componentes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_turma uuid NOT NULL,          -- Direct link to Turma
    id_carga_horaria uuid NOT NULL,  -- Direct link to Carga Horaria (defines Componente)
    id_empresa uuid NOT NULL,
    ano smallint NOT NULL,
    id_professor uuid NOT NULL,
    data_inicio date NOT NULL,
    data_fim date,
    motivo_substituicao text,
    nivel_substituicao integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    editando_por uuid,
    editando_email text,
    CONSTRAINT atrib_atribuicao_componentes_pkey PRIMARY KEY (id),
    CONSTRAINT atrib_atribuicao_componentes_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa(id) ON DELETE CASCADE,
    CONSTRAINT atrib_atribuicao_componentes_id_professor_fkey FOREIGN KEY (id_professor) REFERENCES public.user_expandido(id) ON DELETE CASCADE,
    CONSTRAINT atrib_atribuicao_componentes_id_turma_fkey FOREIGN KEY (id_turma) REFERENCES public.turmas(id) ON DELETE CASCADE,
    CONSTRAINT atrib_atribuicao_componentes_id_ch_fkey FOREIGN KEY (id_carga_horaria) REFERENCES public.carga_horaria(uuid) ON DELETE CASCADE
);

-- Indexes for atrib_atribuicao_componentes
CREATE INDEX atrib_comp_turma_ch_idx ON public.atrib_atribuicao_componentes USING btree (id_turma, id_carga_horaria);
CREATE INDEX atrib_comp_prof_idx ON public.atrib_atribuicao_componentes USING btree (id_professor);
CREATE INDEX atrib_comp_prof_empresa_idx ON public.atrib_atribuicao_componentes USING btree (id_professor, id_empresa);

-- Policies for atrib_atribuicao_componentes
ALTER TABLE public.atrib_atribuicao_componentes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin pode tudo em atrib_componentes" ON public.atrib_atribuicao_componentes
    TO authenticated
    USING ((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text AND (auth.jwt() ->> 'empresa_id'::text)::uuid = id_empresa)
    WITH CHECK ((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text AND (auth.jwt() ->> 'empresa_id'::text)::uuid = id_empresa);

CREATE POLICY "Professor ve suas atrib_componentes" ON public.atrib_atribuicao_componentes
    FOR SELECT
    TO authenticated
    USING (
        (auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['professor'::text, 'professor_funcao_extra'::text])
        AND (auth.jwt() ->> 'empresa_id'::text)::uuid = id_empresa
        AND id_professor IN (SELECT ue.id FROM public.user_expandido ue WHERE ue.user_id = auth.uid())
    );
