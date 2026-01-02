CREATE TABLE IF NOT EXISTS public.bbtk_edicao
(
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    obra_uuid uuid NOT NULL,
    isbn character varying(30) COLLATE pg_catalog."default",
    ano_lancamento date,
    edicao text COLLATE pg_catalog."default",
    arquivo_pdf text COLLATE pg_catalog."default",
    arquivo_capa text COLLATE pg_catalog."default",
    tipo_livro bbtk_tipo_livro NOT NULL,
    livro_retiravel boolean DEFAULT true,
    livro_recomendado boolean DEFAULT false,
    editora_uuid uuid,
    doador_uuid uuid,
    id_empresa uuid,
    pdf_bubble text COLLATE pg_catalog."default",
    capa_bubble text COLLATE pg_catalog."default",
    CONSTRAINT bbtk_edicao_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_edicao_isbn_key UNIQUE (isbn),
    CONSTRAINT bbtk_edicao_doador_uuid_fkey FOREIGN KEY (doador_uuid)
        REFERENCES public.bbtk_dim_doador (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_edicao_editora_uuid_fkey FOREIGN KEY (editora_uuid)
        REFERENCES public.bbtk_dim_editora (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_edicao_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_edicao_obra_uuid_fkey FOREIGN KEY (obra_uuid)
        REFERENCES public.bbtk_obra (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_edicao
    OWNER to postgres;
