CREATE TABLE IF NOT EXISTS public.app_permissoes (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    ilha text NOT NULL,
    botao text,
    escopo text NOT NULL, -- 'ilha' or 'botao'
    entidade_pai text,
    empresas jsonb DEFAULT '[]'::jsonb, -- Array of Company IDs
    papeis jsonb DEFAULT '[]'::jsonb,   -- Array of Role IDs
    criado_em timestamp with time zone DEFAULT now(),
    modificado_em timestamp with time zone DEFAULT now()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_app_permissoes_ilha ON public.app_permissoes(ilha);
CREATE INDEX IF NOT EXISTS idx_app_permissoes_escopo ON public.app_permissoes(escopo);

-- RLS (Enable but allow read for authenticated for now, or open)
ALTER TABLE public.app_permissoes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read for authenticated users" ON public.app_permissoes
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Function to update modified_at
CREATE OR REPLACE FUNCTION public.handle_modificado_em_app_permissoes()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modificado_em = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_modificado_em_app_permissoes
    BEFORE UPDATE ON public.app_permissoes
    FOR EACH ROW
    EXECUTE PROCEDURE public.handle_modificado_em_app_permissoes();
