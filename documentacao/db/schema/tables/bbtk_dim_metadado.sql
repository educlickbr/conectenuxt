CREATE TABLE IF NOT EXISTS public.bbtk_dim_metadado
(
    uuid uuid NOT NULL,
    nome text COLLATE pg_catalog."default" NOT NULL,
    id_empresa uuid,
    CONSTRAINT bbtk_dim_metadado_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_dim_metadado_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_dim_metadado
    OWNER to postgres;
