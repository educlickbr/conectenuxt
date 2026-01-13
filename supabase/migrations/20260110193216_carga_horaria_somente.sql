-- 1. Criação da Tabela
create table public.carga_horaria (
    uuid uuid not null default gen_random_uuid (),
    id_componente uuid not null,
    id_ano_etapa uuid not null,
    carga_horaria integer not null,
    id_empresa uuid not null,
    -- Campos de Auditoria
    criado_por uuid null,
    modifica_por uuid null,
    criado_em timestamp
    with
        time zone null default now (),
        modificado_em timestamp
    with
        time zone null default now (), -- Default now ajuda na criação
        -- Constraints
        constraint carga_horaria_pkey primary key (uuid),
        -- Foreign Keys
        constraint carga_horaria_criado_por_fkey foreign KEY (criado_por) references user_expandido (id) on delete set null,
        constraint carga_horaria_modifica_por_fkey foreign KEY (modifica_por) references user_expandido (id) on delete set null,
        constraint carga_horaria_id_ano_etapa_fkey foreign KEY (id_ano_etapa) references ano_etapa (id) on delete CASCADE,
        constraint carga_horaria_id_componente_fkey foreign KEY (id_componente) references componente (uuid) on delete CASCADE,
        constraint carga_horaria_id_empresa_fkey foreign KEY (id_empresa) references empresa (id) on delete CASCADE,
        -- [NOVO] Evita duplicidade: Um componente só pode ter uma carga horária por ano/etapa na mesma empresa
        constraint carga_horaria_unicidade unique (id_empresa, id_ano_etapa, id_componente)
) TABLESPACE pg_default;

-- 2. Índices (Otimizados)
-- O índice 'ix_ch_uuid' foi removido pois a PK já cobre isso.
create index IF not exists ix_ch_ano on public.carga_horaria using btree (id_ano_etapa) TABLESPACE pg_default;

create index IF not exists ix_ch_comp on public.carga_horaria using btree (id_componente) TABLESPACE pg_default;

create index IF not exists ix_ch_empresa on public.carga_horaria using btree (id_empresa) TABLESPACE pg_default;

-- 3. Segurança (RLS)
alter table public.carga_horaria enable row level security;