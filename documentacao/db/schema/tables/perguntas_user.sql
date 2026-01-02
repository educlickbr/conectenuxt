CREATE TABLE IF NOT EXISTS public.perguntas_user
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    pergunta text COLLATE pg_catalog."default" NOT NULL,
    label text COLLATE pg_catalog."default" NOT NULL,
    obrigatorio boolean DEFAULT false,
    ordem integer,
    tipo text COLLATE pg_catalog."default" NOT NULL,
    opcoes jsonb,
    paginada boolean DEFAULT false,
    numero_pagina integer,
    nome_pagina text COLLATE pg_catalog."default",
    altura integer,
    largura integer,
    arquivos_permitidos boolean DEFAULT false,
    tipo_arquivo text COLLATE pg_catalog."default",
    contexto text COLLATE pg_catalog."default",
    id_papel uuid,
    papel jsonb DEFAULT '[]'::jsonb,
    CONSTRAINT perguntas_user_pkey PRIMARY KEY (id),
    CONSTRAINT perguntas_user_pergunta_key UNIQUE (pergunta),
    CONSTRAINT perguntas_user_id_papel_fkey FOREIGN KEY (id_papel)
        REFERENCES public.papeis_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)

TABLESPACE pg_default;

ALTER TABLE public.perguntas_user
    OWNER to postgres;
