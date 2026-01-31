-- Remove escopo column from diario_presenca (no longer needed)
ALTER TABLE public.diario_presenca DROP COLUMN IF EXISTS escopo;
