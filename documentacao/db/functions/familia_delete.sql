create or replace function public.familia_delete(
    p_id uuid,
    p_id_empresa uuid
)
returns void
language plpgsql
security definer
set search_path to public
as $$
begin
    delete from public.user_familia
    where id = p_id
    and id_empresa = p_id_empresa;
end;
$$;

ALTER FUNCTION public.familia_delete(uuid, uuid)
    OWNER TO postgres;
