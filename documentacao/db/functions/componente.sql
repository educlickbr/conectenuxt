CREATE TABLE IF NOT EXISTS public.componente
(
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    nome text COLLATE pg_catalog."default" NOT NULL,
    id_empresa uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    title_sharepoint text COLLATE pg_catalog."default",
    id_sharepoint integer,
    cor text COLLATE pg_catalog."default",
    CONSTRAINT componente_pkey PRIMARY KEY (uuid),
    CONSTRAINT componente_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.componente
    OWNER to postgres;
