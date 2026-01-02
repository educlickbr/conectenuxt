CREATE TABLE IF NOT EXISTS public.bbtk_juncao_edicao_autoria
(
    edicao_uuid uuid NOT NULL,
    autoria_uuid uuid NOT NULL,
    funcao bbtk_funcao_autoria NOT NULL,
    id_empresa uuid,
    CONSTRAINT bbtk_juncao_edicao_autoria_pkey PRIMARY KEY (edicao_uuid, autoria_uuid),
    CONSTRAINT bbtk_juncao_edicao_autoria_autoria_uuid_fkey FOREIGN KEY (autoria_uuid)
        REFERENCES public.bbtk_dim_autoria (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_juncao_edicao_autoria_edicao_uuid_fkey FOREIGN KEY (edicao_uuid)
        REFERENCES public.bbtk_edicao (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_juncao_edicao_autoria_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_juncao_edicao_autoria
    OWNER to postgres;
