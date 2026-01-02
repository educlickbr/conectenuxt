CREATE TABLE IF NOT EXISTS public.lms_submissao
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_item_conteudo uuid NOT NULL,
    id_aluno uuid NOT NULL,
    texto_resposta text COLLATE pg_catalog."default",
    caminho_arquivo text COLLATE pg_catalog."default",
    data_envio timestamp with time zone DEFAULT now(),
    nota numeric(5,2),
    comentario_professor text COLLATE pg_catalog."default",
    criado_em timestamp with time zone DEFAULT now(),
    modificado_em timestamp with time zone,
    data_inicio timestamp with time zone,
    status text COLLATE pg_catalog."default" DEFAULT 'em_andamento'::text,
    id_empresa uuid,
    CONSTRAINT lms_submissao_pkey PRIMARY KEY (id),
    CONSTRAINT lms_submissao_unq UNIQUE (id_item_conteudo, id_aluno),
    CONSTRAINT lms_submissao_id_aluno_fkey FOREIGN KEY (id_aluno)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT lms_submissao_id_item_fkey FOREIGN KEY (id_item_conteudo)
        REFERENCES public.lms_item_conteudo (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.lms_submissao
    OWNER to postgres;

-- Index: public.idx_lms_submissao_item_aluno
CREATE INDEX IF NOT EXISTS idx_lms_submissao_item_aluno
    ON public.lms_submissao USING btree
    (id_item_conteudo ASC NULLS LAST, id_aluno ASC NULLS LAST)
    TABLESPACE pg_default;