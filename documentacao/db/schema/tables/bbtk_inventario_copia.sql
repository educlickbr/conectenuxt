CREATE TABLE IF NOT EXISTS public.bbtk_inventario_copia
(
    uuid uuid NOT NULL,
    edicao_uuid uuid NOT NULL,
    registro_bibliotecario character varying(100) COLLATE pg_catalog."default" NOT NULL,
    status_copia bbtk_status_copia NOT NULL,
    avaria_flag boolean DEFAULT false,
    descricao_avaria text COLLATE pg_catalog."default",
    estante_uuid uuid,
    id_empresa uuid,
    CONSTRAINT bbtk_inventario_copia_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_inventario_copia_registro_bibliotecario_key UNIQUE (registro_bibliotecario),
    CONSTRAINT bbtk_inventario_copia_edicao_uuid_fkey FOREIGN KEY (edicao_uuid)
        REFERENCES public.bbtk_edicao (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_inventario_copia_estante_uuid_fkey FOREIGN KEY (estante_uuid)
        REFERENCES public.bbtk_dim_estante (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_inventario_copia_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_inventario_copia
    OWNER to postgres;
