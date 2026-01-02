CREATE TABLE IF NOT EXISTS public.bbtk_dim_categoria
(
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    nome text COLLATE pg_catalog."default" NOT NULL,
    descricao text COLLATE pg_catalog."default",
    id_empresa uuid NOT NULL,
    id_bubble text COLLATE pg_catalog."default",
    CONSTRAINT bbtk_dim_categoria_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_dim_categoria_nome_empresa_unique UNIQUE (nome, id_empresa),
    CONSTRAINT bbtk_dim_categoria_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_dim_categoria
    OWNER to postgres;
