CREATE TABLE IF NOT EXISTS public.mtz_calendario_anual (
    id uuid NOT NULL DEFAULT gen_random_uuid (),
    id_empresa uuid NOT NULL,
    id_ano_etapa uuid NOT NULL,
    id_modelo_calendario uuid NOT NULL,
    ano integer NOT NULL,
    numero_periodo integer NOT NULL,
    data_inicio date,
    data_fim date,
    criado_por uuid,
    criado_em timestamp
    with
        time zone DEFAULT now (),
        modificado_por uuid,
        modificado_em timestamp
    with
        time zone DEFAULT now (),
        CONSTRAINT mtz_calendario_anual_pkey PRIMARY KEY (id),
        CONSTRAINT mtz_calendario_anual_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_calendario_anual_ano_etapa_fkey FOREIGN KEY (id_ano_etapa) REFERENCES public.ano_etapa (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_calendario_anual_modelo_fkey FOREIGN KEY (id_modelo_calendario) REFERENCES public.mtz_modelo_calendario (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE RESTRICT,
        CONSTRAINT mtz_calendario_anual_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
        CONSTRAINT mtz_calendario_anual_modificado_por_fkey FOREIGN KEY (modificado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
) TABLESPACE pg_default;

ALTER TABLE public.mtz_calendario_anual OWNER to postgres;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_mtz_calendario_anual_id_empresa ON public.mtz_calendario_anual (id_empresa);

CREATE INDEX IF NOT EXISTS idx_mtz_calendario_anual_id_ano_etapa ON public.mtz_calendario_anual (id_ano_etapa);