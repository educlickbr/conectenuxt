CREATE TABLE IF NOT EXISTS public.user_responsavel_aluno
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_aluno uuid NOT NULL,
    id_responsavel uuid NOT NULL,
    id_familia uuid NOT NULL,
    papel text COLLATE pg_catalog."default",
    criado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT user_responsavel_aluno_pkey PRIMARY KEY (id),
    CONSTRAINT user_responsavel_aluno_unique UNIQUE (id_aluno, id_responsavel),
    CONSTRAINT user_responsavel_aluno_id_aluno_fkey FOREIGN KEY (id_aluno)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_responsavel_aluno_id_familia_fkey FOREIGN KEY (id_familia)
        REFERENCES public.user_familia (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_responsavel_aluno_id_responsavel_fkey FOREIGN KEY (id_responsavel)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.user_responsavel_aluno
    OWNER to postgres;

-- Index: public.idx_user_responsavel_aluno_aluno
CREATE INDEX IF NOT EXISTS idx_user_responsavel_aluno_aluno
    ON public.user_responsavel_aluno USING btree
    (id_aluno ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.idx_user_responsavel_aluno_familia
CREATE INDEX IF NOT EXISTS idx_user_responsavel_aluno_familia
    ON public.user_responsavel_aluno USING btree
    (id_familia ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.idx_user_responsavel_aluno_responsavel
CREATE INDEX IF NOT EXISTS idx_user_responsavel_aluno_responsavel
    ON public.user_responsavel_aluno USING btree
    (id_responsavel ASC NULLS LAST)
    TABLESPACE pg_default;