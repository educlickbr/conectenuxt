CREATE TABLE IF NOT EXISTS public.mtz_matriz_curricular (
    id uuid NOT NULL DEFAULT gen_random_uuid (),
    id_empresa uuid NOT NULL,
    id_ano_etapa uuid NOT NULL,
    ano integer NOT NULL,
    dia_semana integer NOT NULL,
    aula integer NOT NULL,
    id_componente uuid NOT NULL,
    criado_por uuid,
    criado_em timestamp
    with
        time zone DEFAULT now (),
        modificado_por uuid,
        modificado_em timestamp
    with
        time zone DEFAULT now (),
        CONSTRAINT mtz_matriz_curricular_pkey PRIMARY KEY (id),
        CONSTRAINT mtz_matriz_curricular_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_matriz_curricular_ano_etapa_fkey FOREIGN KEY (id_ano_etapa) REFERENCES public.ano_etapa (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_matriz_curricular_componente_fkey FOREIGN KEY (id_componente) REFERENCES public.componente (uuid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_matriz_curricular_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
        CONSTRAINT mtz_matriz_curricular_modificado_por_fkey FOREIGN KEY (modificado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
) TABLESPACE pg_default;

ALTER TABLE public.mtz_matriz_curricular OWNER to postgres;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_mtz_matriz_curr_id_empresa ON public.mtz_matriz_curricular (id_empresa);

CREATE INDEX IF NOT EXISTS idx_mtz_matriz_curr_id_ano_etapa ON public.mtz_matriz_curricular (id_ano_etapa);