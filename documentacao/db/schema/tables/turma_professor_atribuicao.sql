CREATE TABLE IF NOT EXISTS public.turma_professor_atribuicao
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_turma uuid NOT NULL,
    id_empresa uuid NOT NULL,
    ano smallint NOT NULL,
    id_professor uuid NOT NULL,
    data_inicio date NOT NULL,
    data_fim date,
    motivo_substituicao text COLLATE pg_catalog."default",
    nivel_substituicao integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    editando_por uuid,
    editando_email text COLLATE pg_catalog."default",
    CONSTRAINT turma_professor_atribuicao_pkey PRIMARY KEY (id),
    CONSTRAINT turma_professor_atribuicao_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT turma_professor_atribuicao_id_professor_fkey FOREIGN KEY (id_professor)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT turma_professor_atribuicao_id_turma_fkey FOREIGN KEY (id_turma)
        REFERENCES public.turmas (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.turma_professor_atribuicao
    OWNER to postgres;

-- Index: public.atp_id_turma_id_empresa_data_fim_idx
CREATE INDEX IF NOT EXISTS atp_id_turma_id_empresa_data_fim_idx
    ON public.turma_professor_atribuicao USING btree
    (id_turma ASC NULLS LAST, id_empresa ASC NULLS LAST, data_fim ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.idx_atp_id_professor
CREATE INDEX IF NOT EXISTS idx_atp_id_professor
    ON public.turma_professor_atribuicao USING btree
    (id_professor ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.idx_atp_id_turma_nivel
CREATE INDEX IF NOT EXISTS idx_atp_id_turma_nivel
    ON public.turma_professor_atribuicao USING btree
    (id_turma ASC NULLS LAST, nivel_substituicao ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.turma_prof_atrib_prof_empresa_idx
CREATE INDEX IF NOT EXISTS turma_prof_atrib_prof_empresa_idx
    ON public.turma_professor_atribuicao USING btree
    (id_professor ASC NULLS LAST, id_empresa ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: public.turma_prof_atrib_turma_empresa_idx
CREATE INDEX IF NOT EXISTS turma_prof_atrib_turma_empresa_idx
    ON public.turma_professor_atribuicao USING btree
    (id_turma ASC NULLS LAST, id_empresa ASC NULLS LAST)
    TABLESPACE pg_default;