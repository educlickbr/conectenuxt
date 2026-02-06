-- Migration: Add RLS to Merenda Module (mrd_*)
-- Date: 2026-02-05

--------------------------------------------------------------------------------
-- 1. Add empresa_id to tables that were missing it for uniform RLS
--------------------------------------------------------------------------------

-- mrd_ficha_tecnica
ALTER TABLE public.mrd_ficha_tecnica 
ADD COLUMN IF NOT EXISTS empresa_id uuid REFERENCES public.empresa(id);

-- mrd_cardapio_etapa
ALTER TABLE public.mrd_cardapio_etapa 
ADD COLUMN IF NOT EXISTS empresa_id uuid REFERENCES public.empresa(id);

-- mrd_cardapio_semanal
ALTER TABLE public.mrd_cardapio_semanal 
ADD COLUMN IF NOT EXISTS empresa_id uuid REFERENCES public.empresa(id);


--------------------------------------------------------------------------------
-- 2. Enable RLS on all mrd_ tables
--------------------------------------------------------------------------------

ALTER TABLE public.mrd_refeicao_tipo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mrd_alimento ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mrd_prato ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mrd_ficha_tecnica ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mrd_cardapio_grupo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mrd_cardapio_etapa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mrd_cardapio_semanal ENABLE ROW LEVEL SECURITY;

--------------------------------------------------------------------------------
-- 3. Create RLS Policies
-- Format: ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
--------------------------------------------------------------------------------

-- Helper macro not available in standard SQL, so we repeat the policy definition for safety and clarity.

-- mrd_refeicao_tipo
DROP POLICY IF EXISTS "Politica de Merenda - Admin" ON public.mrd_refeicao_tipo;
CREATE POLICY "Politica de Merenda - Admin" ON public.mrd_refeicao_tipo
AS PERMISSIVE FOR ALL
TO public
USING (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
)
WITH CHECK (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
);

-- mrd_alimento
DROP POLICY IF EXISTS "Politica de Merenda - Admin" ON public.mrd_alimento;
CREATE POLICY "Politica de Merenda - Admin" ON public.mrd_alimento
AS PERMISSIVE FOR ALL
TO public
USING (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
)
WITH CHECK (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
);

-- mrd_prato
DROP POLICY IF EXISTS "Politica de Merenda - Admin" ON public.mrd_prato;
CREATE POLICY "Politica de Merenda - Admin" ON public.mrd_prato
AS PERMISSIVE FOR ALL
TO public
USING (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
)
WITH CHECK (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
);

-- mrd_ficha_tecnica
DROP POLICY IF EXISTS "Politica de Merenda - Admin" ON public.mrd_ficha_tecnica;
CREATE POLICY "Politica de Merenda - Admin" ON public.mrd_ficha_tecnica
AS PERMISSIVE FOR ALL
TO public
USING (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
)
WITH CHECK (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
);

-- mrd_cardapio_grupo
DROP POLICY IF EXISTS "Politica de Merenda - Admin" ON public.mrd_cardapio_grupo;
CREATE POLICY "Politica de Merenda - Admin" ON public.mrd_cardapio_grupo
AS PERMISSIVE FOR ALL
TO public
USING (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
)
WITH CHECK (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
);

-- mrd_cardapio_etapa
DROP POLICY IF EXISTS "Politica de Merenda - Admin" ON public.mrd_cardapio_etapa;
CREATE POLICY "Politica de Merenda - Admin" ON public.mrd_cardapio_etapa
AS PERMISSIVE FOR ALL
TO public
USING (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
)
WITH CHECK (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
);

-- mrd_cardapio_semanal
DROP POLICY IF EXISTS "Politica de Merenda - Admin" ON public.mrd_cardapio_semanal;
CREATE POLICY "Politica de Merenda - Admin" ON public.mrd_cardapio_semanal
AS PERMISSIVE FOR ALL
TO public
USING (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
)
WITH CHECK (
  ((empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid) AND ((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text, 'admin_merenda'::text])))
);
