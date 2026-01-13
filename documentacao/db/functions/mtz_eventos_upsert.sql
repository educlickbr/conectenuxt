CREATE OR REPLACE FUNCTION public.mtz_eventos_upsert(
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
    v_registro_salvo public.mtz_eventos;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.mtz_eventos as t (
        id, 
        id_empresa, 
        nome_evento, 
        escopo,
        id_ano_etapa,
        data_inicio,
        data_fim,
        criado_por,
        criado_em,
        modificado_por,
        modificado_em
    )
    values (
        v_id,
        p_id_empresa,
        p_data ->> 'nome_evento',
        (p_data ->> 'escopo')::tipo_escopo_evento,
        (p_data ->> 'id_ano_etapa')::uuid,
        (p_data ->> 'data_inicio')::date,
        (p_data ->> 'data_fim')::date,
        v_user_id,
        now(),
        v_user_id,
        now()
    )
    on conflict (id) do update 
    set 
        nome_evento = coalesce(excluded.nome_evento, t.nome_evento),
        escopo = coalesce(excluded.escopo, t.escopo),
        id_ano_etapa = excluded.id_ano_etapa, -- Permite anular ou mudar
        data_inicio = coalesce(excluded.data_inicio, t.data_inicio),
        data_fim = coalesce(excluded.data_fim, t.data_fim),
        modificado_por = v_user_id,
        modificado_em = now()
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
ALTER FUNCTION public.mtz_eventos_upsert(jsonb, uuid) OWNER TO postgres;
