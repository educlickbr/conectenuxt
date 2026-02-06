create table public.global_arquivos (
  id uuid not null default gen_random_uuid (),
  empresa_id uuid null,
  path text not null,
  bucket text null default 'r2'::text,
  tamanho_bytes bigint null,
  mimetype text null,
  nome_original text null,
  criado_por uuid null,
  criado_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint global_arquivos_pkey primary key (id),
  constraint global_arquivos_criado_por_fkey foreign KEY (criado_por) references auth.users (id),
  constraint global_arquivos_empresa_id_fkey foreign KEY (empresa_id) references public.empresa (id)
) TABLESPACE pg_default;
