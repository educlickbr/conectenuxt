CREATE TABLE IF NOT EXISTS public.respostas_user
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_user uuid NOT NULL,
    id_pergunta uuid NOT NULL,
    tipo text COLLATE pg_catalog."default" NOT NULL,
    resposta text COLLATE pg_catalog."default",
    nome_arquivo_original text COLLATE pg_catalog."default",
    criado_em timestamp with time zone DEFAULT now(),
    criado_por uuid,
    atualizado_em timestamp with time zone,
    atualizado_por uuid,
    id_empresa uuid,
    resposta_data timestamp with time zone,
    CONSTRAINT respostas_user_pkey PRIMARY KEY (id),
    CONSTRAINT respostas_user_id_user_id_pergunta_key UNIQUE (id_user, id_pergunta),
    CONSTRAINT respostas_user_atualizado_por_fkey FOREIGN KEY (atualizado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT respostas_user_criado_por_fkey FOREIGN KEY (criado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT respostas_user_id_pergunta_fkey FOREIGN KEY (id_pergunta)
        REFERENCES public.perguntas_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT respostas_user_id_user_fkey FOREIGN KEY (id_user)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.respostas_user
    OWNER to postgres;
