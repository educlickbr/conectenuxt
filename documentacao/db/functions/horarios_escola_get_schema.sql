create or replace function public.horarios_escola_get_schema(
    p_id_empresa uuid
)
returns setof jsonb
language sql
security definer
set search_path to public
as $$
    -- Reutiliza a função genérica get_table_schema para a tabela 'horarios_escola'
    select public.get_table_schema(p_id_empresa, 'horarios_escola');
$$;
