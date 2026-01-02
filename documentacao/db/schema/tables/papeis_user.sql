CREATE TABLE IF NOT EXISTS public.papeis_user
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    nome text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT papeis_user_pkey PRIMARY KEY (id),
    CONSTRAINT papeis_user_nome_key UNIQUE (nome)
)

TABLESPACE pg_default;

ALTER TABLE public.papeis_user
    OWNER to postgres;
