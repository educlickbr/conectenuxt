-- Migration to move 'doacao_ou_compra' from bbtk_edicao to bbtk_inventario_copia

-- 1. Add column to bbtk_inventario_copia (representing the physical copy/acervo)
ALTER TABLE public.bbtk_inventario_copia
ADD COLUMN IF NOT EXISTS doacao_ou_compra text CHECK (doacao_ou_compra IN ('Doação', 'Compra'));

-- 2. Drop column from bbtk_edicao (representing the edition metadata)
ALTER TABLE public.bbtk_edicao
DROP COLUMN IF EXISTS doacao_ou_compra;
