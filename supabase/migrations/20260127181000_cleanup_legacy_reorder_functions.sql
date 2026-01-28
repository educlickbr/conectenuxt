-- Migration: Cleanup Legacy Reorder Functions
-- Dropping functions that have been replaced by lms_item_reorder and are no longer in use.

DROP FUNCTION IF EXISTS public.lms_reordenar_conteudos_objetos CASCADE;
DROP FUNCTION IF EXISTS public.lms_reordenar_itens_conteudo CASCADE;
DROP FUNCTION IF EXISTS public.lms_reordenar_perguntas_objetos CASCADE;
DROP FUNCTION IF EXISTS public.lms_reordenar_respostas_possiveis CASCADE;
