DROP TYPE IF EXISTS public.tipo_escopo_evento;

CREATE TYPE public.tipo_escopo_evento AS ENUM ('Rede', 'Ano_Etapa');

ALTER TYPE public.tipo_escopo_evento OWNER TO postgres;

CREATE TABLE IF NOT EXISTS public.mtz_eventos (
    id uuid NOT NULL DEFAULT gen_random_uuid (),
    id_empresa uuid NOT NULL,
    nome_evento text COLLATE pg_catalog."default" NOT NULL,
    escopo tipo_escopo_evento NOT NULL,
    id_ano_etapa uuid, -- Nullable se escopo for Rede
    data_inicio date NOT NULL,
    data_fim date NOT NULL,
    criado_por uuid,
    criado_em timestamp
    with
        time zone DEFAULT now (),
        modificado_por uuid,
        modificado_em timestamp
    with
        time zone DEFAULT now (),
        CONSTRAINT mtz_eventos_pkey PRIMARY KEY (id),
        CONSTRAINT mtz_eventos_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_eventos_ano_etapa_fkey FOREIGN KEY (id_ano_etapa) REFERENCES public.ano_etapa (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_eventos_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
        CONSTRAINT mtz_eventos_modificado_por_fkey FOREIGN KEY (modificado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
) TABLESPACE pg_default;

ALTER TABLE public.mtz_eventos OWNER to postgres;

CREATE INDEX IF NOT EXISTS idx_mtz_eventos_id_empresa ON public.mtz_eventos (id_empresa);

CREATE INDEX IF NOT EXISTS idx_mtz_eventos_id_ano_etapa ON public.mtz_eventos (id_ano_etapa);

CREATE INDEX IF NOT EXISTS idx_mtz_eventos_data ON public.mtz_eventos (data_inicio);