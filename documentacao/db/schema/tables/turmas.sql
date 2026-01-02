CREATE TABLE IF NOT EXISTS public.turmas
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_escola uuid NOT NULL,
    id_ano_etapa uuid NOT NULL,
    id_horario uuid NOT NULL,
    id_classe uuid NOT NULL,
    ano text COLLATE pg_catalog."default" NOT NULL,
    id_professor uuid,
    id_professor_s uuid,
    at_titular boolean DEFAULT false,
    at_substituto boolean DEFAULT false,
    criado_em timestamp with time zone DEFAULT now(),
    atualizado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT turmas_pkey PRIMARY KEY (id),
    CONSTRAINT turmas_id_ano_etapa_fkey FOREIGN KEY (id_ano_etapa)
        REFERENCES public.ano_etapa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT turmas_id_classe_fkey FOREIGN KEY (id_classe)
        REFERENCES public.classe (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT turmas_id_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT turmas_id_escola_fkey FOREIGN KEY (id_escola)
        REFERENCES public.escolas (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT turmas_id_horario_fkey FOREIGN KEY (id_horario)
        REFERENCES public.horarios_escola (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT turmas_id_professor_fkey FOREIGN KEY (id_professor)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT turmas_id_professor_s_fkey FOREIGN KEY (id_professor_s)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)

TABLESPACE pg_default;

ALTER TABLE public.turmas
    OWNER to postgres;

-- Trigger: trg_atualiza_at_professores
CREATE OR REPLACE TRIGGER trg_atualiza_at_professores
    BEFORE INSERT OR UPDATE 
    ON public.turmas
    FOR EACH ROW
    EXECUTE FUNCTION public.atualiza_at_professores();