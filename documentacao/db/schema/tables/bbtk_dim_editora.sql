CREATE TABLE IF NOT EXISTS public.bbtk_dim_editora
(
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    nome text COLLATE pg_catalog."default" NOT NULL,
    email text COLLATE pg_catalog."default",
    telefone character varying(50) COLLATE pg_catalog."default",
    id_empresa uuid,
    CONSTRAINT bbtk_dim_editora_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_dim_editora_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_dim_editora
    OWNER to postgres;
