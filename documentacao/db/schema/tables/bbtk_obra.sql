CREATE TABLE IF NOT EXISTS public.bbtk_obra
(
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    titulo_principal text COLLATE pg_catalog."default" NOT NULL,
    sub_titulo_principal text COLLATE pg_catalog."default",
    descricao text COLLATE pg_catalog."default",
    tipo_publicacao bbtk_tipo_publicacao NOT NULL,
    cdu_uuid uuid,
    categoria_uuid uuid,
    id_empresa uuid NOT NULL,
    id_autoria uuid,
    soft_delete boolean NOT NULL DEFAULT false,
    CONSTRAINT bbtk_obra_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_obra_categoria_uuid_fkey FOREIGN KEY (categoria_uuid)
        REFERENCES public.bbtk_dim_categoria (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_obra_cdu_uuid_fkey FOREIGN KEY (cdu_uuid)
        REFERENCES public.bbtk_dim_cdu (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_obra_id_autoria_fkey FOREIGN KEY (id_autoria)
        REFERENCES public.bbtk_dim_autoria (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_obra_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_obra
    OWNER to postgres;
