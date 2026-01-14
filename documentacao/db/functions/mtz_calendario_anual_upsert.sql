CREATE OR REPLACE FUNCTION public.mtz_calendario_anual_upsert(
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
    v_registro_salvo public.mtz_calendario_anual;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.mtz_calendario_anual as t (
        id, 
        id_empresa, 
        id_ano_etapa,
        id_modelo_calendario,
        id_escola,
        ano,
        numero_periodo,
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
        (p_data ->> 'id_ano_etapa')::uuid,
        (p_data ->> 'id_modelo_calendario')::uuid,
        (p_data ->> 'id_escola')::uuid,
        (p_data ->> 'ano')::integer,
        (p_data ->> 'numero_periodo')::integer,
        (p_data ->> 'data_inicio')::date,
        (p_data ->> 'data_fim')::date,
        v_user_id,
        now(),
        v_user_id,
        now()
    )
    on conflict (id) do update 
    set 
        id_ano_etapa = coalesce((excluded.id_ano_etapa), t.id_ano_etapa),
        id_modelo_calendario = coalesce((excluded.id_modelo_calendario), t.id_modelo_calendario),
        id_escola = excluded.id_escola,
        ano = coalesce((excluded.ano), t.ano),
        numero_periodo = coalesce((excluded.numero_periodo), t.numero_periodo),
        data_inicio = coalesce((excluded.data_inicio), t.data_inicio),
        data_fim = coalesce((excluded.data_fim), t.data_fim),
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
ALTER FUNCTION public.mtz_calendario_anual_upsert(jsonb, uuid) OWNER TO postgres;
