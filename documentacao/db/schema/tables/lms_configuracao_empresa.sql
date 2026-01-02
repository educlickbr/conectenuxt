CREATE TABLE IF NOT EXISTS public.lms_configuracao_empresa
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    pode_upload_video boolean NOT NULL DEFAULT false,
    pode_usar_questionarios boolean NOT NULL DEFAULT true,
    pode_usar_tarefas boolean NOT NULL DEFAULT true,
    criado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT lms_configuracao_empresa_pkey PRIMARY KEY (id),
    CONSTRAINT lms_configuracao_empresa_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.lms_configuracao_empresa
    OWNER to postgres;
