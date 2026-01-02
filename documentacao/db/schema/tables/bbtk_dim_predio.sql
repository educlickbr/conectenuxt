CREATE TABLE IF NOT EXISTS public.bbtk_dim_predio
(
    uuid uuid NOT NULL,
    nome character varying(255) COLLATE pg_catalog."default" NOT NULL,
    id_empresa uuid,
    id_escola uuid,
    CONSTRAINT bbtk_dim_predio_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_dim_predio_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_dim_predio_id_escola_fkey FOREIGN KEY (id_escola)
        REFERENCES public.escolas (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_dim_predio
    OWNER to postgres;
