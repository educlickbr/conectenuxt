create or replace function public.escolas_com_predio_get(
    p_id_empresa uuid
)
returns table (id uuid, nome text)
language plpgsql
security definer
set search_path to public
as $$
begin
    return query
    select distinct e.id, e.nome
    from public.escolas e
    join public.bbtk_dim_predio p on p.id_escola = e.id
    where e.id_empresa = p_id_empresa
    order by e.nome;
end;
$$;
