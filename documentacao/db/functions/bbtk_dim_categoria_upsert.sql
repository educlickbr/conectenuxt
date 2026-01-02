create or replace function public.bbtk_dim_categoria_upsert(
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
    v_registro_salvo public.bbtk_dim_categoria;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.bbtk_dim_categoria as t (
        uuid, nome, descricao, id_empresa, id_bubble
    )
    values (
        v_id,
        p_data ->> 'nome',
        p_data ->> 'descricao',
        p_id_empresa,
        p_data ->> 'id_bubble'
    )
    on conflict (uuid) do update 
    set 
        nome = coalesce(excluded.nome, t.nome),
        descricao = coalesce(excluded.descricao, t.descricao),
        id_bubble = coalesce(excluded.id_bubble, t.id_bubble)
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
