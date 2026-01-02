CREATE TABLE IF NOT EXISTS public.bbtk_dim_sala
(
    uuid uuid NOT NULL,
    nome character varying(255) COLLATE pg_catalog."default" NOT NULL,
    predio_uuid uuid,
    CONSTRAINT bbtk_dim_sala_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_dim_sala_predio_uuid_fkey FOREIGN KEY (predio_uuid)
        REFERENCES public.bbtk_dim_predio (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_dim_sala
    OWNER to postgres;
