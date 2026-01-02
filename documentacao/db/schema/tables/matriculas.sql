CREATE TABLE IF NOT EXISTS public.matriculas
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_aluno uuid NOT NULL,
    id_turma uuid NOT NULL,
    status text COLLATE pg_catalog."default" NOT NULL,
    data_entrada date NOT NULL DEFAULT CURRENT_DATE,
    data_saida date,
    observacao text COLLATE pg_catalog."default",
    criado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT matriculas_pkey PRIMARY KEY (id),
    CONSTRAINT matriculas_id_aluno_fkey FOREIGN KEY (id_aluno)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT matriculas_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT matriculas_id_turma_fkey FOREIGN KEY (id_turma)
        REFERENCES public.turmas (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT matriculas_status_check CHECK (status = ANY (ARRAY['ativa'::text, 'transferida'::text, 'cancelada'::text, 'evadida'::text, 'concluida'::text]))
)

TABLESPACE pg_default;

ALTER TABLE public.matriculas
    OWNER to postgres;

-- Index: public.idx_matriculas_aluno
CREATE INDEX IF NOT EXISTS idx_matriculas_aluno
    ON public.matriculas USING btree
    (id_aluno ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.idx_matriculas_empresa
CREATE INDEX IF NOT EXISTS idx_matriculas_empresa
    ON public.matriculas USING btree
    (id_empresa ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.idx_matriculas_status
CREATE INDEX IF NOT EXISTS idx_matriculas_status
    ON public.matriculas USING btree
    (status COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.idx_matriculas_turma
CREATE INDEX IF NOT EXISTS idx_matriculas_turma
    ON public.matriculas USING btree
    (id_turma ASC NULLS LAST)
    TABLESPACE pg_default;