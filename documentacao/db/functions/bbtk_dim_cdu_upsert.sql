create or replace function public.bbtk_dim_cdu_upsert(
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
    v_registro_salvo public.bbtk_dim_cdu;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.bbtk_dim_cdu as t (
        uuid, codigo, nome, id_empresa
    )
    values (
        v_id,
        p_data ->> 'codigo',
        p_data ->> 'nome',
        p_id_empresa
    )
    on conflict (uuid) do update 
    set 
        codigo = coalesce(excluded.codigo, t.codigo),
        nome = coalesce(excluded.nome, t.nome)
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
