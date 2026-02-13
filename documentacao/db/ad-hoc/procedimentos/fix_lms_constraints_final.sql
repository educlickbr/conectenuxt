-- Drop ALL potential conflicting constraints to be sure
ALTER TABLE public.lms_conteudo DROP CONSTRAINT IF EXISTS lms_conteudo_contexto_check;
ALTER TABLE public.lms_conteudo DROP CONSTRAINT IF EXISTS lms_conteudo_escopo_check;

-- Add the definitive constraint
ALTER TABLE public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_escopo_check CHECK (
        (escopo = 'Turma' AND id_turma IS NOT NULL) OR
        (escopo = 'Aluno' AND id_aluno IS NOT NULL) OR
        (escopo = 'Grupo' AND id_meta_turma IS NOT NULL) OR
        (escopo = 'Global') -- No ID required for Global
    );
