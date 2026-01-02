CREATE TABLE IF NOT EXISTS public.bbtk_dim_estante
(
    uuid uuid NOT NULL,
    nome character varying(255) COLLATE pg_catalog."default" NOT NULL,
    sala_uuid uuid,
    CONSTRAINT bbtk_dim_estante_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_dim_estante_sala_uuid_fkey FOREIGN KEY (sala_uuid)
        REFERENCES public.bbtk_dim_sala (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_dim_estante
    OWNER to postgres;
