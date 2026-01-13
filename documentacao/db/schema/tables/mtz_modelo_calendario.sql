CREATE TABLE IF NOT EXISTS public.mtz_modelo_calendario (
    id uuid NOT NULL DEFAULT gen_random_uuid (),
    nome text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT mtz_modelo_calendario_pkey PRIMARY KEY (id)
) TABLESPACE pg_default;

ALTER TABLE public.mtz_modelo_calendario OWNER to postgres;

-- Seed Data (as requested to be done "first")
INSERT INTO
    public.mtz_modelo_calendario (nome)
VALUES
    ('Bimestral'),
    ('Trimestral'),
    ('Semestral') ON CONFLICT DO NOTHING;