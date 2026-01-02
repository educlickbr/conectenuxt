CREATE TABLE IF NOT EXISTS public.bbtk_dim_cdu
(
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    codigo character varying(50) COLLATE pg_catalog."default" NOT NULL,
    nome text COLLATE pg_catalog."default" NOT NULL,
    id_empresa uuid NOT NULL,
    CONSTRAINT bbtk_dim_cdu_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_dim_cdu_codigo_empresa_unique UNIQUE (codigo, id_empresa),
    CONSTRAINT bbtk_dim_cdu_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_dim_cdu
    OWNER to postgres;
