CREATE TABLE IF NOT EXISTS public.mtz_feriados (
    id uuid NOT NULL DEFAULT gen_random_uuid (),
    id_empresa uuid NOT NULL,
    nome_feriado text COLLATE pg_catalog."default" NOT NULL,
    tipo text COLLATE pg_catalog."default" NOT NULL, -- 'Feriado' ou 'Emenda'
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
        CONSTRAINT mtz_feriados_pkey PRIMARY KEY (id),
        CONSTRAINT mtz_feriados_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_feriados_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
        CONSTRAINT mtz_feriados_modificado_por_fkey FOREIGN KEY (modificado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
) TABLESPACE pg_default;

ALTER TABLE public.mtz_feriados OWNER to postgres;

CREATE INDEX IF NOT EXISTS idx_mtz_feriados_id_empresa ON public.mtz_feriados (id_empresa);

CREATE INDEX IF NOT EXISTS idx_mtz_feriados_data ON public.mtz_feriados (data_inicio);