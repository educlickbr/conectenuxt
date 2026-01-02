CREATE TABLE IF NOT EXISTS public.lms_resposta_possivel
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_pergunta uuid NOT NULL,
    texto text COLLATE pg_catalog."default" NOT NULL,
    correta boolean NOT NULL DEFAULT false,
    ordem integer DEFAULT 0,
    id_empresa uuid NOT NULL,
    CONSTRAINT lms_resposta_possivel_pkey PRIMARY KEY (id),
    CONSTRAINT lms_resposta_possivel_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lms_resposta_possivel_id_pergunta_fkey FOREIGN KEY (id_pergunta)
        REFERENCES public.lms_pergunta (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.lms_resposta_possivel
    OWNER to postgres;

-- Index: public.lms_resposta_possivel_id_empresa_idx
CREATE INDEX IF NOT EXISTS lms_resposta_possivel_id_empresa_idx
    ON public.lms_resposta_possivel USING btree
    (id_empresa ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.lms_resposta_possivel_id_pergunta_idx
CREATE INDEX IF NOT EXISTS lms_resposta_possivel_id_pergunta_idx
    ON public.lms_resposta_possivel USING btree
    (id_pergunta ASC NULLS LAST)
    TABLESPACE pg_default;