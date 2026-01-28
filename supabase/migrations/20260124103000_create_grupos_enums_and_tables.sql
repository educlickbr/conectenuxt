-- Migration: Create Study Groups Schema
-- Description: Creates enum status_grp and tables grp_grupos, grp_tutores, grp_integrantes

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_grp') THEN
        CREATE TYPE status_grp AS ENUM ('ATIVO', 'INATIVO');
    END IF;
END $$;

-- Table: grp_grupos
CREATE TABLE IF NOT EXISTS public.grp_grupos (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    nome_grupo text NOT NULL,
    descricao text,
    status status_grp NOT NULL DEFAULT 'ATIVO',
    soft_delete boolean DEFAULT false,
    
    criado_em timestamptz DEFAULT now(),
    criado_por uuid REFERENCES public.user_expandido(id),
    modificado_em timestamptz,
    modificado_por uuid REFERENCES public.user_expandido(id),
    
    CONSTRAINT grp_grupos_pkey PRIMARY KEY (id)
);

-- Table: grp_tutores
CREATE TABLE IF NOT EXISTS public.grp_tutores (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_grupo uuid NOT NULL REFERENCES public.grp_grupos(id) ON DELETE CASCADE,
    id_user uuid NOT NULL REFERENCES public.user_expandido(id),
    
    status status_grp NOT NULL DEFAULT 'ATIVO',
    ano integer,
    
    criado_em timestamptz DEFAULT now(),
    criado_por uuid REFERENCES public.user_expandido(id),
    modificado_em timestamptz,
    modificado_por uuid REFERENCES public.user_expandido(id),
    
    CONSTRAINT grp_tutores_pkey PRIMARY KEY (id),
    CONSTRAINT grp_tutores_unique_user_grupo UNIQUE (id_grupo, id_user)
);

-- Table: grp_integrantes
CREATE TABLE IF NOT EXISTS public.grp_integrantes (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_grupo uuid NOT NULL REFERENCES public.grp_grupos(id) ON DELETE CASCADE,
    id_user uuid NOT NULL REFERENCES public.user_expandido(id),
    
    status status_grp NOT NULL DEFAULT 'ATIVO',
    ano integer,
    
    criado_em timestamptz DEFAULT now(),
    criado_por uuid REFERENCES public.user_expandido(id),
    modificado_em timestamptz,
    modificado_por uuid REFERENCES public.user_expandido(id),
    
    CONSTRAINT grp_integrantes_pkey PRIMARY KEY (id),
    CONSTRAINT grp_integrantes_unique_user_grupo UNIQUE (id_grupo, id_user)
);

-- RLS Policies (Optional but Recommended - Keeping it open for RPC access mainly, but good practice)
ALTER TABLE public.grp_grupos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grp_tutores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grp_integrantes ENABLE ROW LEVEL SECURITY;

-- Grant permissions needed for RPC usage (usually Authenticated or Service Role)
GRANT ALL ON TABLE public.grp_grupos TO authenticated;
GRANT ALL ON TABLE public.grp_tutores TO authenticated;
GRANT ALL ON TABLE public.grp_integrantes TO authenticated;
GRANT ALL ON TABLE public.grp_grupos TO service_role;
GRANT ALL ON TABLE public.grp_tutores TO service_role;
GRANT ALL ON TABLE public.grp_integrantes TO service_role;
