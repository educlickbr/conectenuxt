CREATE TABLE IF NOT EXISTS public.bbtk_dim_autoria
(
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    nome_completo text COLLATE pg_catalog."default" NOT NULL,
    codigo_cutter character varying(50) COLLATE pg_catalog."default",
    id_empresa uuid,
    id_bubble text COLLATE pg_catalog."default",
    principal boolean DEFAULT false,
    CONSTRAINT bbtk_dim_autoria_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_dim_autoria_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_dim_autoria
    OWNER to postgres;
