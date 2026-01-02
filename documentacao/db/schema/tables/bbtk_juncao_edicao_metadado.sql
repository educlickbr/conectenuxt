CREATE TABLE IF NOT EXISTS public.bbtk_juncao_edicao_metadado
(
    edicao_uuid uuid NOT NULL,
    metadado_uuid uuid NOT NULL,
    id_empresa uuid,
    CONSTRAINT bbtk_juncao_edicao_metadado_pkey PRIMARY KEY (edicao_uuid, metadado_uuid),
    CONSTRAINT bbtk_juncao_edicao_metadado_edicao_uuid_fkey FOREIGN KEY (edicao_uuid)
        REFERENCES public.bbtk_edicao (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_juncao_edicao_metadado_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_juncao_edicao_metadado_metadado_uuid_fkey FOREIGN KEY (metadado_uuid)
        REFERENCES public.bbtk_dim_metadado (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_juncao_edicao_metadado
    OWNER to postgres;
