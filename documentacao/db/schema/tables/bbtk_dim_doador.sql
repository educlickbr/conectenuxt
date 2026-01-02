CREATE TABLE IF NOT EXISTS public.bbtk_dim_doador
(
    uuid uuid NOT NULL,
    nome text COLLATE pg_catalog."default" NOT NULL,
    email text COLLATE pg_catalog."default",
    telefone character varying(50) COLLATE pg_catalog."default",
    id_empresa uuid,
    CONSTRAINT bbtk_dim_doador_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_dim_doador_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_dim_doador
    OWNER to postgres;
