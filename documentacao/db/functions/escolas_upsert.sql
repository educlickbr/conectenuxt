create or replace function public.escolas_upsert(
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
    v_user_id uuid := current_setting('request.jwt.claim.sub', true)::uuid;
    v_escola_salva public.escolas;
begin
    -- Tenta obter o ID, se não existir, um novo ID será gerado
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());

    -- Verifica se a operação é permitida para a empresa
    -- (O RLS deve reforçar isso, mas a verificação explícita é boa prática)
    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    -- Executa o UPSERT (INSERT/UPDATE)
    insert into public.escolas as t (
        id, nome, endereco, numero, complemento, bairro, cep, email, telefone_1, telefone_2,
        horario_htpc, horario_htpc_hora, horario_htpc_minuto, dia_semana_htpc, 
        id_empresa
    )
    values (
        v_id,
        p_data ->> 'nome',
        p_data ->> 'endereco',
        p_data ->> 'numero',
        p_data ->> 'complemento',
        p_data ->> 'bairro',
        p_data ->> 'cep',
        p_data ->> 'email',
        p_data ->> 'telefone_1',
        p_data ->> 'telefone_2',
        p_data ->> 'horario_htpc',
        (p_data ->> 'horario_htpc_hora')::integer,
        (p_data ->> 'horario_htpc_minuto')::integer,
        p_data ->> 'dia_semana_htpc',
        p_id_empresa
    )
    on conflict (id) do update 
    set 
        nome = coalesce(excluded.nome, t.nome),
        endereco = coalesce(excluded.endereco, t.endereco),
        numero = coalesce(excluded.numero, t.numero),
        complemento = coalesce(excluded.complemento, t.complemento),
        bairro = coalesce(excluded.bairro, t.bairro),
        cep = coalesce(excluded.cep, t.cep),
        email = coalesce(excluded.email, t.email),
        telefone_1 = coalesce(excluded.telefone_1, t.telefone_1),
        telefone_2 = coalesce(excluded.telefone_2, t.telefone_2),
        horario_htpc = coalesce(excluded.horario_htpc, t.horario_htpc),
        horario_htpc_hora = coalesce(excluded.horario_htpc_hora, t.horario_htpc_hora),
        horario_htpc_minuto = coalesce(excluded.horario_htpc_minuto, t.horario_htpc_minuto),
        dia_semana_htpc = coalesce(excluded.dia_semana_htpc, t.dia_semana_htpc)
    where t.id_empresa = p_id_empresa -- Garante que o UPDATE só ocorra dentro da empresa correta
    returning * into v_escola_salva;

    -- Retorna o registro salvo em formato JSON
    return to_jsonb(v_escola_salva);

exception when others then
    -- Em caso de erro, retorna um JSON de erro estruturado
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;