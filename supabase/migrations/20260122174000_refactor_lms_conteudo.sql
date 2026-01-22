-- Drop existing table
DROP TABLE IF EXISTS public.lms_conteudo CASCADE;

-- Create Table
CREATE TABLE public.lms_conteudo (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL REFERENCES public.empresa(id),
    
    -- Scope IDs
    id_ano_etapa uuid REFERENCES public.ano_etapa(id),
    id_turma uuid REFERENCES public.turmas(id) ON DELETE CASCADE,
    id_meta_turma uuid REFERENCES public.meta_turma(id) ON DELETE CASCADE,
    id_componente uuid REFERENCES public.componente(uuid) ON DELETE CASCADE,
    id_aluno uuid REFERENCES public.user_expandido(id) ON DELETE CASCADE,
    
    -- Content
    titulo text NOT NULL,
    descricao text,
    
    -- Settings
    liberar_por public.liberacao_conteudo_enum NOT NULL DEFAULT 'Conteúdo'::public.liberacao_conteudo_enum,
    escopo text NOT NULL,
    visivel_para_alunos boolean NOT NULL DEFAULT true,
    data_disponivel timestamp with time zone,
    
    -- Audit
    criado_por uuid NOT NULL REFERENCES public.user_expandido(id),
    criado_em timestamp with time zone DEFAULT now(),
    
    CONSTRAINT lms_conteudo_pkey PRIMARY KEY (id),
    
    -- Scope Validation
    CONSTRAINT lms_conteudo_escopo_check CHECK (
        (escopo = 'Global') OR
        (escopo = 'AnoEtapa' AND id_ano_etapa IS NOT NULL) OR
        (escopo = 'Turma' AND id_turma IS NOT NULL) OR
        (escopo = 'Grupo' AND id_meta_turma IS NOT NULL) OR
        (escopo = 'Componente' AND id_componente IS NOT NULL) OR
        (escopo = 'Aluno' AND id_aluno IS NOT NULL)
    ),
    
    -- Enum Check (Optional but good for documentation)
    CONSTRAINT lms_conteudo_escopo_enum_check CHECK (
        escopo IN ('Global', 'AnoEtapa', 'Turma', 'Grupo', 'Componente', 'Aluno')
    )
);

-- Indexes
CREATE INDEX lms_conteudo_id_empresa_idx ON public.lms_conteudo(id_empresa);
CREATE INDEX lms_conteudo_criado_por_idx ON public.lms_conteudo(criado_por);
CREATE INDEX lms_conteudo_escopo_idx ON public.lms_conteudo(escopo);
CREATE INDEX lms_conteudo_ids_idx ON public.lms_conteudo(id_turma, id_aluno, id_meta_turma, id_componente, id_ano_etapa);

-- Enable RLS
ALTER TABLE public.lms_conteudo ENABLE ROW LEVEL SECURITY;

-- Policy (Basic Policy for Testing - Adjust as needed)
CREATE POLICY "Enable all for authenticated users based on company" ON public.lms_conteudo
    USING (id_empresa = (auth.jwt() ->> 'empresa_id')::uuid)
    WITH CHECK (id_empresa = (auth.jwt() ->> 'empresa_id')::uuid);
