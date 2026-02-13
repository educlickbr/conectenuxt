-- 1. Definição dos Nutrientes (Cadastro fixo/global ou por empresa)
CREATE TYPE public.mrd_unidade_nutriente AS ENUM (
  'kcal', 
  'kJ', 
  'g', 
  'mg', 
  'mcg',
  'UI' -- Unidade Internacional (Vitaminas)
);

CREATE TABLE public.mrd_nutriente (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL, -- Ex: 'Proteína', 'Cálcio', 'Sódio'
    unidade public.mrd_unidade_nutriente NOT NULL, -- Ex: 'g', 'mg', 'kcal', 'mcg'
    empresa_id uuid NULL, -- Se NULL, é global. Se preenchido, é personalizado da empresa.
    created_at timestamptz DEFAULT now() NULL,
    updated_at timestamptz DEFAULT now() NULL,
    active boolean DEFAULT true,
    CONSTRAINT mrd_nutriente_pkey PRIMARY KEY (id),
    CONSTRAINT mrd_nutriente_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id)
);

-- 2. Composição do Alimento (Substitui o JSONB por linhas relacionadas)
CREATE TABLE public.mrd_alimento_nutriente (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    empresa_id uuid NOT NULL,
    alimento_id uuid NOT NULL,
    nutriente_id uuid NOT NULL,
    quantidade_100g numeric(10, 4) NOT NULL, -- Valor para cada 100g do alimento
    created_at timestamptz DEFAULT now() NULL,
    updated_at timestamptz DEFAULT now() NULL,
    CONSTRAINT mrd_alimento_nutriente_pkey PRIMARY KEY (id),
    CONSTRAINT mrd_aln_alimento_fkey FOREIGN KEY (alimento_id) REFERENCES public.mrd_alimento(id) ON DELETE CASCADE,
    CONSTRAINT mrd_aln_nutriente_fkey FOREIGN KEY (nutriente_id) REFERENCES public.mrd_nutriente(id),
    CONSTRAINT mrd_aln_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id),
    CONSTRAINT mrd_aln_unique_pair UNIQUE (alimento_id, nutriente_id)
);

-- 3. Referências PNAE (Os valores "fixos" do manual)
-- Relaciona Nutriente + Etapa (Ano Etapa) + Faixa Etária (Opcional) + Qtd Refeições -> Min/Max
CREATE TABLE public.mrd_pnae_referencia (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    empresa_id uuid NOT NULL,
    ano_etapa_id uuid NOT NULL, -- Referência à tabela ano_etapa
    faixa_etaria text NULL, -- Ex: '7-11 meses', '6-10 anos' (Opcional)
    num_refeicoes int4 NOT NULL, -- 1, 2 ou 3 (conforme páginas 9/10 do manual)
    nutriente_id uuid NOT NULL,
    valor_min numeric(12, 4) DEFAULT 0,
    valor_max numeric(12, 4) NULL, -- Algumas referências têm teto, outras não
    percentual_vet_min numeric(5, 2) NULL, -- % do VET (se aplicável, como em Proteínas)
    percentual_vet_max numeric(5, 2) NULL,
    created_at timestamptz DEFAULT now() NULL,
    updated_at timestamptz DEFAULT now() NULL,
    CONSTRAINT mrd_pnae_referencia_pkey PRIMARY KEY (id),
    CONSTRAINT mrd_pnae_nutriente_fkey FOREIGN KEY (nutriente_id) REFERENCES public.mrd_nutriente(id),
    CONSTRAINT mrd_pnae_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id),
    CONSTRAINT mrd_pnae_ano_etapa_fkey FOREIGN KEY (ano_etapa_id) REFERENCES public.ano_etapa(id)
);

-- Habilitar RLS
ALTER TABLE public.mrd_nutriente ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mrd_alimento_nutriente ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mrd_pnae_referencia ENABLE ROW LEVEL SECURITY;

-- Políticas RLS (Exemplos genéricos baseados no padrão do projeto - ajustar conforme necessidade real)

-- mrd_nutriente: Leitura pública (ou auth), Escrita restrita a admin/nutricionista
CREATE POLICY "Nutrientes visíveis para usuários autenticados" ON public.mrd_nutriente FOR SELECT TO authenticated USING (true);
CREATE POLICY "Nutrientes editáveis por admin/nutri da empresa ou se for global (admin geral)" ON public.mrd_nutriente FOR ALL TO authenticated USING (
    (empresa_id IS NULL AND (auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['admin'::text])) OR
    (empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid)
);

-- mrd_alimento_nutriente: Acesso por empresa
CREATE POLICY "Alimento Nutriente por empresa" ON public.mrd_alimento_nutriente FOR ALL TO authenticated USING (
    empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid
);

-- mrd_pnae_referencia: Acesso por empresa
CREATE POLICY "PNAE Referencia por empresa" ON public.mrd_pnae_referencia FOR ALL TO authenticated USING (
    empresa_id = ((auth.jwt() ->> 'empresa_id'::text))::uuid
);
