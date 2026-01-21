-- Migration to update bbtk_historico_interacao schema
-- 1. Alter existing date columns to timestamptz
-- 2. Add audit columns (criado_por, criado_em, modificado_por, modificado_em, recebido_por, recebido_em)

-- Alter existing columns to timestamptz
ALTER TABLE public.bbtk_historico_interacao
    ALTER COLUMN data_inicio TYPE timestamptz USING data_inicio::timestamptz,
    ALTER COLUMN data_fim TYPE timestamptz USING data_fim::timestamptz,
    ALTER COLUMN data_prevista_devolucao TYPE timestamptz USING data_prevista_devolucao::timestamptz;

-- Add new audit columns
ALTER TABLE public.bbtk_historico_interacao
    ADD COLUMN IF NOT EXISTS criado_por uuid REFERENCES public.user_expandido(id),
    ADD COLUMN IF NOT EXISTS criado_em timestamptz DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS modificado_por uuid REFERENCES public.user_expandido(id),
    ADD COLUMN IF NOT EXISTS modificado_em timestamptz DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS recebido_por uuid REFERENCES public.user_expandido(id),
    ADD COLUMN IF NOT EXISTS recebido_em timestamptz;
