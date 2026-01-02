create or replace function public.bbtk_dim_estante_upsert(
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
    v_registro_salvo public.bbtk_dim_estante;
    v_sala_uuid uuid;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());
    v_sala_uuid := (p_data ->> 'sala_uuid')::uuid;

    -- Validação: A sala deve pertencer a um prédio da empresa
    if not exists (
        select 1 
        from public.bbtk_dim_sala s
        inner join public.bbtk_dim_predio p on s.predio_uuid = p.uuid
        where s.uuid = v_sala_uuid and p.id_empresa = p_id_empresa
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Sala não encontrada ou não pertence à empresa.');
    end if;

    insert into public.bbtk_dim_estante as t (
        uuid, nome, sala_uuid
    )
    values (
        v_id,
        p_data ->> 'nome',
        v_sala_uuid
    )
    on conflict (uuid) do update 
    set 
        nome = coalesce(excluded.nome, t.nome),
        sala_uuid = coalesce(excluded.sala_uuid, t.sala_uuid)
    -- Não precisamos validar novamente a empresa no update pois a constraint valida a sala, e a sala valida o prédio
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
