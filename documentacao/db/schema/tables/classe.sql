CREATE TABLE IF NOT EXISTS public.classe
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    nome text COLLATE pg_catalog."default" NOT NULL,
    ordem integer NOT NULL,
    id_empresa uuid NOT NULL,
    CONSTRAINT classe_pkey PRIMARY KEY (id),
    CONSTRAINT classe_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.classe
    OWNER to postgres;
