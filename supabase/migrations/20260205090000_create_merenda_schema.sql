-- Migration: Create Merenda Module Schema (mrd_*)
-- Date: 2026-02-05
-- Access: Restricted to specific companies through RLS (to be implemented) or application logic.

-- Common columns function (optional, but for now explicitly adding columns to each table for clarity)

--------------------------------------------------------------------------------
-- 1. mrd_refeicao_tipo
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.mrd_refeicao_tipo (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    empresa_id uuid NOT NULL,
    nome text NOT NULL,
    ordem integer NOT NULL DEFAULT 0,
    
    -- Audit
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    updated_by uuid REFERENCES auth.users(id),
    ativo boolean DEFAULT true,

    CONSTRAINT mrd_refeicao_tipo_pkey PRIMARY KEY (id),
    CONSTRAINT mrd_refeicao_tipo_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id)
);

--------------------------------------------------------------------------------
-- 2. mrd_alimento (Catálogo de Itens)
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.mrd_alimento (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    empresa_id uuid NOT NULL,
    nome text NOT NULL,
    unidade_medida text NOT NULL, -- 'KG', 'LITRO', 'FARDO', 'UNIDADE'
    ata_registro_ref text, -- Referência à Ata
    categoria text, -- 'PROTEÍNA', 'CARBOIDRATO', 'VEGETAL'
    valor_nutricional_100g jsonb, -- { calorias: ..., proteinas: ... }
    preco_medio numeric(10,2),
    fornecedor_preferencial text,

    -- Audit
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    updated_by uuid REFERENCES auth.users(id),
    ativo boolean DEFAULT true,

    CONSTRAINT mrd_alimento_pkey PRIMARY KEY (id),
    CONSTRAINT mrd_alimento_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id)
);

--------------------------------------------------------------------------------
-- 3. mrd_prato (Catálogo de Pratos)
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.mrd_prato (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    empresa_id uuid NOT NULL,
    nome text NOT NULL,
    modo_preparo text,

    -- Audit
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    updated_by uuid REFERENCES auth.users(id),
    ativo boolean DEFAULT true,

    CONSTRAINT mrd_prato_pkey PRIMARY KEY (id),
    CONSTRAINT mrd_prato_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id)
);

--------------------------------------------------------------------------------
-- 4. mrd_ficha_tecnica (Motor de Cálculo)
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.mrd_ficha_tecnica (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    prato_id uuid NOT NULL,
    alimento_id uuid NOT NULL,
    gramagem_per_capita numeric(10,4) NOT NULL, -- Precision for small amounts
    modo_preparo_complementar text,
    ordem_adicao integer DEFAULT 1,
    opcional boolean DEFAULT false,
    substituivel_por uuid, -- FK Self (Alimento)

    -- Audit
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    updated_by uuid REFERENCES auth.users(id),
    ativo boolean DEFAULT true,

    CONSTRAINT mrd_ficha_tecnica_pkey PRIMARY KEY (id),
    CONSTRAINT mrd_ficha_tecnica_prato_fkey FOREIGN KEY (prato_id) REFERENCES public.mrd_prato(id),
    CONSTRAINT mrd_ficha_tecnica_alimento_fkey FOREIGN KEY (alimento_id) REFERENCES public.mrd_alimento(id),
    CONSTRAINT mrd_ficha_tecnica_subst_fkey FOREIGN KEY (substituivel_por) REFERENCES public.mrd_alimento(id)
);

--------------------------------------------------------------------------------
-- 5. mrd_cardapio_grupo (Vigência Estratégica)
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.mrd_cardapio_grupo (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    empresa_id uuid NOT NULL,
    nome text NOT NULL,
    data_inicio timestamptz NOT NULL,
    data_fim timestamptz NOT NULL,

    -- Audit
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    updated_by uuid REFERENCES auth.users(id),
    ativo boolean DEFAULT true,

    CONSTRAINT mrd_cardapio_grupo_pkey PRIMARY KEY (id),
    CONSTRAINT mrd_cardapio_grupo_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id)
);

--------------------------------------------------------------------------------
-- 6. mrd_cardapio_etapa (Público-Alvo)
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.mrd_cardapio_etapa (
    cardapio_grupo_id uuid NOT NULL,
    ano_etapa_id uuid NOT NULL,
    
    -- Audit (Simpler for join tables, but good to have)
    created_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),

    CONSTRAINT mrd_cardapio_etapa_pkey PRIMARY KEY (cardapio_grupo_id, ano_etapa_id),
    CONSTRAINT mrd_cardapio_etapa_grupo_fkey FOREIGN KEY (cardapio_grupo_id) REFERENCES public.mrd_cardapio_grupo(id) ON DELETE CASCADE,
    CONSTRAINT mrd_cardapio_etapa_ano_etapa_fkey FOREIGN KEY (ano_etapa_id) REFERENCES public.ano_etapa(id)
);

--------------------------------------------------------------------------------
-- 7. mrd_cardapio_semanal (A Operação)
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.mrd_cardapio_semanal (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    cardapio_grupo_id uuid NOT NULL,
    
    -- Time reference
    ano integer NOT NULL,
    semana_iso integer NOT NULL,
    p_dia_semana timestamptz NOT NULL,
    u_dia_semana timestamptz NOT NULL,
    dia_semana_indice integer NOT NULL, -- 1=Seg, 7=Dom
    
    -- Content
    refeicao_tipo_id uuid NOT NULL,
    prato_id uuid NOT NULL,
    prato_alternativo_id uuid, -- Opção B
    observacoes text,
    
    -- Workflow
    status text DEFAULT 'PLANEJADO', -- 'PLANEJADO', 'APROVADO', 'EXECUTADO', 'CANCELADO'
    aprovado_por uuid REFERENCES auth.users(id),
    aprovado_em timestamptz,

    -- Audit
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),
    updated_by uuid REFERENCES auth.users(id),
    ativo boolean DEFAULT true,

    CONSTRAINT mrd_cardapio_semanal_pkey PRIMARY KEY (id),
    CONSTRAINT mrd_cardapio_semanal_grupo_fkey FOREIGN KEY (cardapio_grupo_id) REFERENCES public.mrd_cardapio_grupo(id),
    CONSTRAINT mrd_cardapio_semanal_tipo_fkey FOREIGN KEY (refeicao_tipo_id) REFERENCES public.mrd_refeicao_tipo(id),
    CONSTRAINT mrd_cardapio_semanal_prato_fkey FOREIGN KEY (prato_id) REFERENCES public.mrd_prato(id),
    CONSTRAINT mrd_cardapio_semanal_prato_alt_fkey FOREIGN KEY (prato_alternativo_id) REFERENCES public.mrd_prato(id)
);
