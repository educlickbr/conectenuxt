-- Relax constraint to allow Global scope without Component ID (Company Wide)
ALTER TABLE public.lms_conteudo
    DROP CONSTRAINT IF EXISTS lms_conteudo_escopo_check;

ALTER TABLE public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_escopo_check CHECK (
        (escopo = 'Turma' AND id_turma IS NOT NULL) OR
        (escopo = 'Aluno' AND id_aluno IS NOT NULL) OR
        (escopo = 'Grupo' AND id_meta_turma IS NOT NULL) OR
        (escopo = 'Global') -- Allows Global without specific ID (School Wide)
    );
