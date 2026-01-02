CREATE TABLE IF NOT EXISTS public.escolas
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    nome text COLLATE pg_catalog."default" NOT NULL,
    endereco text COLLATE pg_catalog."default",
    numero text COLLATE pg_catalog."default",
    complemento text COLLATE pg_catalog."default",
    bairro text COLLATE pg_catalog."default",
    cep text COLLATE pg_catalog."default",
    email text COLLATE pg_catalog."default",
    telefone_1 text COLLATE pg_catalog."default",
    telefone_2 text COLLATE pg_catalog."default",
    horario_htpc text COLLATE pg_catalog."default",
    horario_htpc_hora integer,
    horario_htpc_minuto integer,
    dia_semana_htpc text COLLATE pg_catalog."default",
    id_empresa uuid NOT NULL,
    id_sharepoint_apagar_depois integer,
    uuid_sharepoint_apagar_depois text COLLATE pg_catalog."default",
    CONSTRAINT escolas_pkey PRIMARY KEY (id),
    CONSTRAINT escolas_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.escolas
    OWNER to postgres;
