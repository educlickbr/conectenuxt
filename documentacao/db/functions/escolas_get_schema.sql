create or replace function public.escolas_get_schema(
    p_id_empresa uuid
)
returns setof jsonb
language sql
security definer
set search_path to public
as $$
    -- Reutiliza a função genérica get_table_schema para a tabela 'escolas'
    select public.get_table_schema(p_id_empresa, 'escolas');
$$;
