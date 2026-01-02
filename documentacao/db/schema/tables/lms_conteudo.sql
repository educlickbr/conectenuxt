CREATE TABLE IF NOT EXISTS public.lms_conteudo
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_turma uuid,
    id_aluno uuid,
    id_meta_turma uuid,
    id_componente uuid,
    escopo text NOT NULL CHECK (escopo IN ('Turma', 'Aluno', 'Grupo', 'Global')),
    global_componente boolean NOT NULL DEFAULT false,
    titulo text COLLATE pg_catalog."default" NOT NULL,
    descricao text COLLATE pg_catalog."default",
    data_referencia date,
    visivel_para_alunos boolean NOT NULL DEFAULT true,
    criado_por uuid NOT NULL,
    criado_em timestamp with time zone DEFAULT now(),
    ordem integer,
    id_empresa uuid NOT NULL,
    data_disponivel timestamp with time zone,
    liberar_por liberacao_conteudo_enum NOT NULL DEFAULT 'Conteúdo'::liberacao_conteudo_enum,
    CONSTRAINT lms_conteudo_pkey PRIMARY KEY (id),
    CONSTRAINT lms_conteudo_criado_por_fkey FOREIGN KEY (criado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lms_conteudo_id_componente_fkey FOREIGN KEY (id_componente)
        REFERENCES public.componente (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT lms_conteudo_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lms_conteudo_id_turma_fkey FOREIGN KEY (id_turma)
        REFERENCES public.turmas (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT lms_conteudo_id_aluno_fkey FOREIGN KEY (id_aluno)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT lms_conteudo_id_meta_turma_fkey FOREIGN KEY (id_meta_turma)
        REFERENCES public.meta_turma (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT lms_conteudo_escopo_check CHECK (
        (escopo = 'Turma' AND id_turma IS NOT NULL) OR
        (escopo = 'Aluno' AND id_aluno IS NOT NULL) OR
        (escopo = 'Grupo' AND id_meta_turma IS NOT NULL) OR
        (escopo = 'Global' AND id_componente IS NOT NULL)
    )
)

TABLESPACE pg_default;

ALTER TABLE public.lms_conteudo
    OWNER to postgres;

-- Index: public.idx_lms_conteudo_id_empresa_turma
CREATE INDEX IF NOT EXISTS idx_lms_conteudo_id_empresa_turma
    ON public.lms_conteudo USING btree
    ON public.lms_conteudo USING btree
    (escopo ASC, id_turma ASC, id_aluno ASC, id_meta_turma ASC)
    TABLESPACE pg_default;
-- Index: public.lms_conteudo_id_turma_idx
CREATE INDEX IF NOT EXISTS lms_conteudo_id_turma_idx
    ON public.lms_conteudo USING btree
    (id_turma ASC NULLS LAST)
    TABLESPACE pg_default;