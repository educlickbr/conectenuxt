CREATE TABLE IF NOT EXISTS public.user_expandido
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid,
    id_empresa uuid NOT NULL,
    id_escola uuid,
    matricula text COLLATE pg_catalog."default" NOT NULL,
    nome_completo text COLLATE pg_catalog."default" NOT NULL,
    email text COLLATE pg_catalog."default",
    telefone text COLLATE pg_catalog."default",
    papel_id uuid NOT NULL DEFAULT gen_random_uuid(),
    criado_por uuid,
    criado_em timestamp with time zone,
    modificado_por uuid,
    modificado_em timestamp with time zone,
    status_contrato status_contrato NOT NULL DEFAULT 'Ativo'::status_contrato,
    soft_delete boolean DEFAULT false,
    CONSTRAINT user_expandido_professor_pkey PRIMARY KEY (id),
    CONSTRAINT unique_matricula_empresa UNIQUE (matricula, id_empresa),
    CONSTRAINT user_expandido_professor_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_expandido_professor_escola_fkey FOREIGN KEY (id_escola)
        REFERENCES public.escolas (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT user_expandido_professor_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES auth.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)

TABLESPACE pg_default;

ALTER TABLE public.user_expandido
    OWNER to postgres;

-- Index: public.idx_uep_id_empresa
CREATE INDEX IF NOT EXISTS idx_uep_id_empresa
    ON public.user_expandido USING btree
    (id_empresa ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.idx_uep_id_escola
CREATE INDEX IF NOT EXISTS idx_uep_id_escola
    ON public.user_expandido USING btree
    (id_escola ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.idx_user_expandido_user_id
CREATE INDEX IF NOT EXISTS idx_user_expandido_user_id
    ON public.user_expandido USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.user_expandido_user_id_idx
CREATE INDEX IF NOT EXISTS user_expandido_user_id_idx
    ON public.user_expandido USING btree
    (user_id ASC NULLS LAST)
    TABLESPACE pg_default;