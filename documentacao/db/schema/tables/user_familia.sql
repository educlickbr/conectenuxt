CREATE TABLE IF NOT EXISTS public.user_familia
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    nome_familia text COLLATE pg_catalog."default",
    id_responsavel_principal uuid,
    criado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT user_familia_pkey PRIMARY KEY (id),
    CONSTRAINT user_familia_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_familia_id_responsavel_principal_fkey FOREIGN KEY (id_responsavel_principal)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)

TABLESPACE pg_default;

ALTER TABLE public.user_familia
    OWNER to postgres;

-- Index: public.idx_user_familia_empresa
CREATE INDEX IF NOT EXISTS idx_user_familia_empresa
    ON public.user_familia USING btree
    (id_empresa ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.idx_user_familia_responsavel
CREATE INDEX IF NOT EXISTS idx_user_familia_responsavel
    ON public.user_familia USING btree
    (id_responsavel_principal ASC NULLS LAST)
    TABLESPACE pg_default;