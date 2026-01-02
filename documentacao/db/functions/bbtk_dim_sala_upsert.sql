create or replace function public.bbtk_dim_sala_upsert(
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
    v_registro_salvo public.bbtk_dim_sala;
    v_predio_uuid uuid;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());
    v_predio_uuid := (p_data ->> 'predio_uuid')::uuid;

    -- Validação: O prédio deve pertencer à empresa
    if not exists (select 1 from public.bbtk_dim_predio where uuid = v_predio_uuid and id_empresa = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Prédio não encontrado ou não pertence à empresa.');
    end if;

    insert into public.bbtk_dim_sala as t (
        uuid, nome, predio_uuid
    )
    values (
        v_id,
        p_data ->> 'nome',
        v_predio_uuid
    )
    on conflict (uuid) do update 
    set 
        nome = coalesce(excluded.nome, t.nome),
        predio_uuid = coalesce(excluded.predio_uuid, t.predio_uuid)
    where exists (
        select 1 from public.bbtk_dim_predio p 
        where p.uuid = excluded.predio_uuid and p.id_empresa = p_id_empresa
    ) -- Check redundante mas seguro no update
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
