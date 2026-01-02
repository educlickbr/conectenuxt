CREATE TABLE IF NOT EXISTS public.bbtk_historico_interacao
(
    uuid uuid NOT NULL,
    copia_uuid uuid NOT NULL,
    user_uuid uuid NOT NULL,
    tipo_interacao bbtk_tipo_interacao NOT NULL,
    data_inicio date NOT NULL,
    data_fim date,
    data_prevista_devolucao date,
    id_empresa uuid,
    CONSTRAINT bbtk_historico_interacao_pkey PRIMARY KEY (uuid),
    CONSTRAINT bbtk_historico_interacao_copia_uuid_fkey FOREIGN KEY (copia_uuid)
        REFERENCES public.bbtk_inventario_copia (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT bbtk_historico_interacao_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.bbtk_historico_interacao
    OWNER to postgres;
