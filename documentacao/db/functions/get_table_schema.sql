create or replace function public.get_table_schema(
    p_id_empresa uuid,
    p_table_name text
)
returns setof jsonb
language sql
security definer
set search_path to public
as $$
select jsonb_build_object(
    'column_name', c.column_name,
    'data_type', c.data_type,
    'is_nullable', c.is_nullable,
    'is_pk', (
        select exists (
            select 1 
            from information_schema.table_constraints tc
            join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name
            where tc.table_schema = 'public' 
              and tc.table_name = p_table_name
              and tc.constraint_type = 'PRIMARY KEY'
              and kcu.column_name = c.column_name
        )
    ),
    'max_length', c.character_maximum_length,
    -- Adicionar lógica para buscar FKs aqui se for necessário no futuro
    'is_fk', (
        select exists (
            select 1
            from information_schema.key_column_usage kcu
            join information_schema.table_constraints tc on kcu.constraint_name = tc.constraint_name
            where tc.constraint_type = 'FOREIGN KEY'
              and kcu.table_name = p_table_name
              and kcu.column_name = c.column_name
        )
    )
)
from information_schema.columns c
where c.table_schema = 'public' 
  and c.table_name = p_table_name
  -- Excluir colunas de auditoria/sistema que não devem ser editadas
  and c.column_name not in ('id_empresa', 'soft_delete', 'criado_em', 'criado_por', 'modificado_em', 'modificado_por', 'id')
order by c.ordinal_position;
$$;