-- 1. Updates for lms_conteudo

-- Add new columns
ALTER TABLE public.lms_conteudo
    ADD COLUMN IF NOT EXISTS id_aluno uuid,
    ADD COLUMN IF NOT EXISTS id_meta_turma uuid,
    ADD COLUMN IF NOT EXISTS escopo text;

-- Add Foreign Keys
ALTER TABLE public.lms_conteudo
    DROP CONSTRAINT IF EXISTS lms_conteudo_id_aluno_fkey;
ALTER TABLE public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_id_aluno_fkey FOREIGN KEY (id_aluno)
    REFERENCES public.user_expandido (id) ON DELETE CASCADE;

ALTER TABLE public.lms_conteudo
    DROP CONSTRAINT IF EXISTS lms_conteudo_id_meta_turma_fkey;
ALTER TABLE public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_id_meta_turma_fkey FOREIGN KEY (id_meta_turma)
    REFERENCES public.meta_turma (id) ON DELETE CASCADE;

-- Data Migration for 'escopo' based on existing data
-- Logic: If id_turma exists, it's 'Turma'. If it was global/component based, map to 'Global'.
UPDATE public.lms_conteudo
SET escopo = CASE
    WHEN id_turma IS NOT NULL THEN 'Turma'
    ELSE 'Global'
END
WHERE escopo IS NULL;

-- Now enforce NOT NULL on escopo
ALTER TABLE public.lms_conteudo
    ALTER COLUMN escopo SET NOT NULL;

-- Add check constraint for valid scopes
ALTER TABLE public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_escopo_enum_check CHECK (escopo IN ('Turma', 'Aluno', 'Grupo', 'Global'));

-- Drop old logical constraint
ALTER TABLE public.lms_conteudo
    DROP CONSTRAINT IF EXISTS lms_conteudo_contexto_check;

-- Add new logical constraint
ALTER TABLE public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_escopo_check CHECK (
        (escopo = 'Turma' AND id_turma IS NOT NULL) OR
        (escopo = 'Aluno' AND id_aluno IS NOT NULL) OR
        (escopo = 'Grupo' AND id_meta_turma IS NOT NULL) OR
        (escopo = 'Global' AND id_componente IS NOT NULL)
    );
    
-- Update Index for better performance with new fields
DROP INDEX IF EXISTS idx_lms_conteudo_id_empresa_turma;
CREATE INDEX IF NOT EXISTS idx_lms_conteudo_escopo_ids
    ON public.lms_conteudo (escopo, id_turma, id_aluno, id_meta_turma);


-- 2. Updates for lms_item_conteudo

ALTER TABLE public.lms_item_conteudo
    ADD COLUMN IF NOT EXISTS pontuacao_maxima numeric(5,2),
    ADD COLUMN IF NOT EXISTS video_link text,
    ADD COLUMN IF NOT EXISTS id_bbtk_edicao uuid;

ALTER TABLE public.lms_item_conteudo
    DROP CONSTRAINT IF EXISTS lms_item_id_bbtk_edicao_fkey;

ALTER TABLE public.lms_item_conteudo
    ADD CONSTRAINT lms_item_id_bbtk_edicao_fkey FOREIGN KEY (id_bbtk_edicao)
    REFERENCES public.bbtk_edicao (uuid) ON DELETE SET NULL;


-- 3. Updates for lms_pergunta

ALTER TABLE public.lms_pergunta
    ADD COLUMN IF NOT EXISTS caminho_imagem text;
