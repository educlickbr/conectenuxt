CREATE TABLE IF NOT EXISTS public.empresa
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    nome text COLLATE pg_catalog."default" NOT NULL,
    logo_fechado text COLLATE pg_catalog."default",
    logo_aberto text COLLATE pg_catalog."default",
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    dominio text COLLATE pg_catalog."default",
    CONSTRAINT empresa_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.empresa
    OWNER to postgres;
