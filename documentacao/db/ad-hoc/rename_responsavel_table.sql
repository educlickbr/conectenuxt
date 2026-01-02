-- Rename table
ALTER TABLE IF EXISTS public.user_responsavel_aluno
    RENAME TO relacionamento_user_aluno;

-- Rename indexes (optional but good for consistency)
ALTER INDEX IF EXISTS idx_user_responsavel_aluno_aluno
    RENAME TO idx_relacionamento_user_aluno_aluno;

ALTER INDEX IF EXISTS idx_user_responsavel_aluno_familia
    RENAME TO idx_relacionamento_user_aluno_familia;

ALTER INDEX IF EXISTS idx_user_responsavel_aluno_responsavel
    RENAME TO idx_relacionamento_user_aluno_responsavel;

-- Rename constraints (optional)
ALTER TABLE public.relacionamento_user_aluno
    RENAME CONSTRAINT user_responsavel_aluno_pkey TO relacionamento_user_aluno_pkey;

ALTER TABLE public.relacionamento_user_aluno
    RENAME CONSTRAINT user_responsavel_aluno_unique TO relacionamento_user_aluno_unique;

ALTER TABLE public.relacionamento_user_aluno
    RENAME CONSTRAINT user_responsavel_aluno_id_aluno_fkey TO relacionamento_user_aluno_id_aluno_fkey;

ALTER TABLE public.relacionamento_user_aluno
    RENAME CONSTRAINT user_responsavel_aluno_id_familia_fkey TO relacionamento_user_aluno_id_familia_fkey;

ALTER TABLE public.relacionamento_user_aluno
    RENAME CONSTRAINT user_responsavel_aluno_id_responsavel_fkey TO relacionamento_user_aluno_id_responsavel_fkey;
