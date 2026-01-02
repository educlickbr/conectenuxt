create or replace function public.ano_etapa_get_schema(
    p_id_empresa uuid
)
returns setof jsonb
language sql
security definer
set search_path to public
as $$
    -- Reutiliza a função genérica get_table_schema para a tabela 'ano_etapa'
    select public.get_table_schema(p_id_empresa, 'ano_etapa');
$$;
