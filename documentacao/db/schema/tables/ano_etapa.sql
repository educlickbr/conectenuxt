CREATE TABLE IF NOT EXISTS public.ano_etapa
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    nome text COLLATE pg_catalog."default" NOT NULL,
    tipo tipo_ano_etapa NOT NULL,
    carg_horaria integer,
    title_sharepoint text COLLATE pg_catalog."default",
    id_sharepoint text COLLATE pg_catalog."default",
    criado_em timestamp with time zone DEFAULT now(),
    atualizado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT ano_etapa_pkey PRIMARY KEY (id),
    CONSTRAINT ano_etapa_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.ano_etapa
    OWNER to postgres;
