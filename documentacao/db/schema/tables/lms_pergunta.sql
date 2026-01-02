
CREATE TABLE IF NOT EXISTS public.lms_pergunta
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    tipo lms_tipo_pergunta NOT NULL DEFAULT 'Dissertativa'::lms_tipo_pergunta,
    enunciado text COLLATE pg_catalog."default" NOT NULL,
    caminho_imagem text COLLATE pg_catalog."default",
    obrigatoria boolean NOT NULL DEFAULT true,
    ordem integer DEFAULT 0,
    id_empresa uuid NOT NULL,
    id_item_conteudo uuid NOT NULL,
    CONSTRAINT lms_pergunta_pkey PRIMARY KEY (id),
    CONSTRAINT lms_pergunta_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lms_pergunta_id_item_conteudo_fkey FOREIGN KEY (id_item_conteudo)
        REFERENCES public.lms_item_conteudo (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.lms_pergunta
    OWNER to postgres;

-- Index: public.lms_pergunta_id_empresa_idx
CREATE INDEX IF NOT EXISTS lms_pergunta_id_empresa_idx
    ON public.lms_pergunta USING btree
    (id_empresa ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.lms_pergunta_id_item_conteudo_idx
CREATE INDEX IF NOT EXISTS lms_pergunta_id_item_conteudo_idx
    ON public.lms_pergunta USING btree
    (id_item_conteudo ASC NULLS LAST)
    TABLESPACE pg_default;