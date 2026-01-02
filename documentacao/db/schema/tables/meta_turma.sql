create table public.meta_turma (
    id uuid not null primary key default uuid_generate_v4(),
    id_empresa uuid not null references public.empresa(id),
    -- Coluna principal para identificar o usuário responsável pela Meta-Turma (ex: Coordenador, Professor)
    id_user uuid references public.user_expandido(id),
    nome character varying(255) not null,
    descricao text,
    status boolean not null default true, -- Para ativar/desativar o grupo
    criado_em timestamp with time zone not null default now(),
    -- Quem criou o registro (para auditoria)
    criado_por uuid references public.user_expandido(id),
    modificado_em timestamp with time zone,
    -- Quem modificou o registro por último
    modificado_por uuid references public.user_expandido(id),
    deleted_at timestamp with time zone -- Campo para Soft Delete
);

-- Indexação para performance de busca e RLS
create index meta_turma_id_empresa_idx on public.meta_turma (id_empresa);
create index meta_turma_criado_por_idx on public.meta_turma (criado_por);