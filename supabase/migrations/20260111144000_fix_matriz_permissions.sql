-- Migration: Fix Permissions for Matriz Curricular
-- Date: 2026-01-11
-- Description: Grants necessary permissions for tables and functions created in previous migration.
-- 1. Tables Permissions
-- mtz_modelo_calendario needs SELECT for 'authenticated' because mtz_modelo_calendario_get is not SECURITY DEFINER
GRANT
SELECT
    ON TABLE public.mtz_modelo_calendario TO authenticated;

GRANT
SELECT
    ON TABLE public.mtz_modelo_calendario TO service_role;

-- Grant permissions for other tables just in case, though they are accessed via SECURITY DEFINER functions mostly
GRANT
SELECT
,
    INSERT,
UPDATE,
DELETE ON TABLE public.mtz_calendario_anual TO authenticated;

GRANT
SELECT
,
    INSERT,
UPDATE,
DELETE ON TABLE public.mtz_calendario_anual TO service_role;

GRANT
SELECT
,
    INSERT,
UPDATE,
DELETE ON TABLE public.mtz_matriz_curricular TO authenticated;

GRANT
SELECT
,
    INSERT,
UPDATE,
DELETE ON TABLE public.mtz_matriz_curricular TO service_role;

-- 2. Functions Permissions
-- Grant execute on all new functions
GRANT EXECUTE ON FUNCTION public.mtz_modelo_calendario_get () TO authenticated;

GRANT EXECUTE ON FUNCTION public.mtz_modelo_calendario_get () TO service_role;

GRANT EXECUTE ON FUNCTION public.mtz_calendario_anual_get_paginado (uuid, integer, integer, text) TO authenticated;

GRANT EXECUTE ON FUNCTION public.mtz_calendario_anual_get_paginado (uuid, integer, integer, text) TO service_role;

GRANT EXECUTE ON FUNCTION public.mtz_calendario_anual_upsert (jsonb, uuid) TO authenticated;

GRANT EXECUTE ON FUNCTION public.mtz_calendario_anual_upsert (jsonb, uuid) TO service_role;

GRANT EXECUTE ON FUNCTION public.mtz_calendario_anual_delete (uuid, uuid) TO authenticated;

GRANT EXECUTE ON FUNCTION public.mtz_calendario_anual_delete (uuid, uuid) TO service_role;

GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_get_paginado (uuid, integer, integer, text) TO authenticated;

GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_get_paginado (uuid, integer, integer, text) TO service_role;

GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_upsert (jsonb, uuid) TO authenticated;

GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_upsert (jsonb, uuid) TO service_role;

GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_delete (uuid, uuid) TO authenticated;

GRANT EXECUTE ON FUNCTION public.mtz_matriz_curricular_delete (uuid, uuid) TO service_role;

-- Update ano_etapa_upsert permissions as well just to be safe
GRANT EXECUTE ON FUNCTION public.ano_etapa_upsert (jsonb, uuid) TO authenticated;

GRANT EXECUTE ON FUNCTION public.ano_etapa_upsert (jsonb, uuid) TO service_role;