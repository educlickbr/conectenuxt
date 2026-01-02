CREATE TABLE IF NOT EXISTS public.professor_componente
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_componente uuid NOT NULL,
    id_professor uuid NOT NULL,
    ano_referencia text COLLATE pg_catalog."default" NOT NULL,
    criado_por uuid,
    criado_em timestamp with time zone DEFAULT now(),
    atualizado_por uuid,
    atualizado_em timestamp with time zone,
    id_empresa uuid NOT NULL DEFAULT '0a9d8682-4da9-4e02-9022-fd293a9b0704'::uuid,
    CONSTRAINT professor_componente_pkey PRIMARY KEY (id),
    CONSTRAINT professor_componente_atualizado_por_fkey FOREIGN KEY (atualizado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT professor_componente_criado_por_fkey FOREIGN KEY (criado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT professor_componente_id_componente_fkey FOREIGN KEY (id_componente)
        REFERENCES public.componente (uuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT professor_componente_id_professor_fkey FOREIGN KEY (id_professor)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.professor_componente
    OWNER to postgres;
