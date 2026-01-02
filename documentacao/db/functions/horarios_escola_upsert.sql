create or replace function public.horarios_escola_upsert(
    p_data jsonb,
    p_id_empresa uuid
)
returns jsonb -- Retorna o registro inserido/atualizado como JSON
language plpgsql
security definer
set search_path to public
as $$
declare
    v_id uuid;
    v_horario_salvo public.horarios_escola;
begin
    -- Tenta obter o ID, se não existir, um novo ID será gerado
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());

    -- Verifica se a operação é permitida para a empresa
    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    -- Executa o UPSERT (INSERT/UPDATE)
    insert into public.horarios_escola as t (
        id, id_empresa, hora_inicio, hora_fim, hora_completo, periodo, nome, descricao
    )
    values (
        v_id,
        p_id_empresa,
        p_data ->> 'hora_inicio',
        p_data ->> 'hora_fim',
        p_data ->> 'hora_completo',
        (p_data ->> 'periodo')::periodo_escolar,
        p_data ->> 'nome',
        p_data ->> 'descricao'
    )
    on conflict (id) do update 
    set 
        hora_inicio = coalesce(excluded.hora_inicio, t.hora_inicio),
        hora_fim = coalesce(excluded.hora_fim, t.hora_fim),
        hora_completo = coalesce(excluded.hora_completo, t.hora_completo),
        periodo = coalesce(excluded.periodo, t.periodo),
        nome = coalesce(excluded.nome, t.nome),
        descricao = coalesce(excluded.descricao, t.descricao)
    where t.id_empresa = p_id_empresa -- Garante que o UPDATE só ocorra dentro da empresa correta
    returning * into v_horario_salvo;

    -- Retorna o registro salvo em formato JSON
    return to_jsonb(v_horario_salvo);

exception when others then
    -- Em caso de erro, retorna um JSON de erro estruturado
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;
