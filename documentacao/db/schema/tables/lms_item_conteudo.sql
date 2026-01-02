CREATE TABLE IF NOT EXISTS public.lms_item_conteudo
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_lms_conteudo uuid NOT NULL,
    tipo lms_tipo_item DEFAULT 'Material'::lms_tipo_item,
    titulo text COLLATE pg_catalog."default" NOT NULL,
    caminho_arquivo text COLLATE pg_catalog."default",
    url_externa text COLLATE pg_catalog."default",
    video_link text COLLATE pg_catalog."default",
    rich_text text COLLATE pg_catalog."default",
    data_disponivel timestamp with time zone,
    data_entrega_limite timestamp with time zone,
    tempo_questionario integer,
    pontuacao_maxima numeric(5,2),
    ordem integer DEFAULT 0,
    criado_por uuid NOT NULL,
    criado_em timestamp with time zone DEFAULT now(),
    id_empresa uuid,
    id_bbtk_edicao uuid,
    CONSTRAINT lms_item_conteudo_pkey PRIMARY KEY (id),
    CONSTRAINT lms_item_id_bbtk_edicao_fkey FOREIGN KEY (id_bbtk_edicao)
        REFERENCES public.bbtk_edicao (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT lms_item_conteudo_criado_por_fkey FOREIGN KEY (criado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lms_item_conteudo_id_lms_conteudo_fkey FOREIGN KEY (id_lms_conteudo)
        REFERENCES public.lms_conteudo (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.lms_item_conteudo
    OWNER to postgres;

-- Index: public.lms_item_conteudo_id_conteudo_idx
CREATE INDEX IF NOT EXISTS lms_item_conteudo_id_conteudo_idx
    ON public.lms_item_conteudo USING btree
    (id_lms_conteudo ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.lms_item_conteudo_id_empresa_idx
CREATE INDEX IF NOT EXISTS lms_item_conteudo_id_empresa_idx
    ON public.lms_item_conteudo USING btree
    (id_empresa ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.lms_item_conteudo_id_lms_conteudo_idx
CREATE INDEX IF NOT EXISTS lms_item_conteudo_id_lms_conteudo_idx
    ON public.lms_item_conteudo USING btree
    (id_lms_conteudo ASC NULLS LAST)
    TABLESPACE pg_default;