create or replace function public.bbtk_dim_doador_upsert(
    p_data jsonb,
    p_id_empresa uuid
)
returns jsonb
language plpgsql
security definer
set search_path to public
as $$
declare
    v_id uuid;
    v_user_id uuid := current_setting('request.jwt.claim.sub', true)::uuid;
    v_registro_salvo public.bbtk_dim_doador;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.bbtk_dim_doador as t (
        uuid, nome, email, telefone, id_empresa
    )
    values (
        v_id,
        p_data ->> 'nome',
        p_data ->> 'email',
        p_data ->> 'telefone',
        p_id_empresa
    )
    on conflict (uuid) do update 
    set 
        nome = coalesce(excluded.nome, t.nome),
        email = coalesce(excluded.email, t.email),
        telefone = coalesce(excluded.telefone, t.telefone)
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);

exception when others then
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;
