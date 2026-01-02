CREATE TABLE IF NOT EXISTS public.horarios_escola
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    hora_inicio text COLLATE pg_catalog."default" NOT NULL,
    hora_fim text COLLATE pg_catalog."default" NOT NULL,
    hora_completo text COLLATE pg_catalog."default",
    periodo periodo_escolar NOT NULL,
    criado_em timestamp with time zone DEFAULT now(),
    atualizado_em timestamp with time zone DEFAULT now(),
    nome text COLLATE pg_catalog."default",
    descricao text COLLATE pg_catalog."default",
    CONSTRAINT horarios_escola_pkey PRIMARY KEY (id),
    CONSTRAINT horarios_escola_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.horarios_escola
    OWNER to postgres;
