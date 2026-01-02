CREATE TABLE IF NOT EXISTS public.lms_resposta
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_user uuid NOT NULL,
    id_pergunta uuid NOT NULL,
    tipo_pergunta lms_tipo_pergunta NOT NULL,
    resposta text COLLATE pg_catalog."default",
    id_resposta_possivel uuid,
    criado_em timestamp with time zone NOT NULL DEFAULT now(),
    criado_por uuid,
    modificado_em timestamp with time zone,
    modificado_por uuid,
    CONSTRAINT lms_resposta_pkey PRIMARY KEY (id),
    CONSTRAINT lms_resposta_unique_user_pergunta UNIQUE (id_user, id_pergunta),
    CONSTRAINT lms_resposta_criado_por_fkey FOREIGN KEY (criado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT lms_resposta_id_pergunta_fkey FOREIGN KEY (id_pergunta)
        REFERENCES public.lms_pergunta (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT lms_resposta_id_resposta_possivel_fkey FOREIGN KEY (id_resposta_possivel)
        REFERENCES public.lms_resposta_possivel (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT lms_resposta_id_user_fkey FOREIGN KEY (id_user)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT lms_resposta_modificado_por_fkey FOREIGN KEY (modificado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)

TABLESPACE pg_default;

ALTER TABLE public.lms_resposta
    OWNER to postgres;

-- Index: public.lms_resposta_id_pergunta_idx
CREATE INDEX IF NOT EXISTS lms_resposta_id_pergunta_idx
    ON public.lms_resposta USING btree
    (id_pergunta ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.lms_resposta_id_resposta_possivel_idx
CREATE INDEX IF NOT EXISTS lms_resposta_id_resposta_possivel_idx
    ON public.lms_resposta USING btree
    (id_resposta_possivel ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.lms_resposta_id_user_idx
CREATE INDEX IF NOT EXISTS lms_resposta_id_user_idx
    ON public.lms_resposta USING btree
    (id_user ASC NULLS LAST)
    TABLESPACE pg_default;