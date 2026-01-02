create or replace function public.professor_upsert(
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
    v_user_expandido_salvo public.user_expandido;
    v_papel_professor uuid := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
    v_item_resposta jsonb;
    v_item_componente jsonb;
    v_comp_id uuid;
begin
    -- 1. Obter ID do Professor (ou gerar novo)
    -- Tenta pegar 'user_expandido_id' ou 'id' do JSON
    v_id := coalesce(
        (p_data ->> 'user_expandido_id')::uuid, 
        (p_data ->> 'id')::uuid, 
        gen_random_uuid()
    );

    -- 2. Upsert em user_expandido
    insert into public.user_expandido (
        id,
        id_empresa,
        nome_completo,
        email,
        telefone,
        matricula,
        papel_id,
        status_contrato,
        id_escola -- Caso venha no JSON, embora o prompt diga que escola tem tratamento especial, se vier aqui salvamos
    ) values (
        v_id,
        p_id_empresa,
        p_data ->> 'nome_completo',
        p_data ->> 'email',
        p_data ->> 'telefone',
        coalesce(p_data ->> 'matricula', 'TEMP-' || extract(epoch from now())::text), -- Garante matricula se nula (fallback)
        coalesce((p_data ->> 'papel_id')::uuid, v_papel_professor),
        coalesce((p_data ->> 'status')::status_contrato, 'Ativo'::status_contrato),
        (p_data ->> 'id_escola')::uuid
    )
    on conflict (id) do update
    set
        nome_completo = coalesce(excluded.nome_completo, user_expandido.nome_completo),
        email = coalesce(excluded.email, user_expandido.email),
        telefone = coalesce(excluded.telefone, user_expandido.telefone),
        matricula = coalesce(excluded.matricula, user_expandido.matricula),
        status_contrato = coalesce(excluded.status_contrato, user_expandido.status_contrato),
        id_escola = coalesce(excluded.id_escola, user_expandido.id_escola)
    returning * into v_user_expandido_salvo;

    -- 3. Upsert em respostas_user
    if p_data ? 'respostas' then
        for v_item_resposta in select * from jsonb_array_elements(p_data -> 'respostas')
        loop
            -- Só insere se tiver id_pergunta
            if (v_item_resposta ->> 'id_pergunta') is not null then
                insert into public.respostas_user (
                    id_pergunta,
                    id_user,
                    id_empresa,
                    resposta,
                    tipo
                ) values (
                    (v_item_resposta ->> 'id_pergunta')::uuid,
                    v_id,
                    p_id_empresa,
                    v_item_resposta ->> 'resposta',
                    coalesce(v_item_resposta ->> 'tipo', 'text')
                )
                on conflict (id_user, id_pergunta) do update
                set
                    resposta = excluded.resposta,
                    tipo = excluded.tipo,
                    atualizado_em = now();
            end if;
        end loop;
    end if;

    -- 4. Upsert em professor_componente
    if p_data ? 'componentes' then
        for v_item_componente in select * from jsonb_array_elements(p_data -> 'componentes')
        loop
            -- Se tiver ID do vinculo, é edição
            if (v_item_componente ->> 'id_professor_componente') is not null then
                update public.professor_componente
                set
                    id_componente = (v_item_componente ->> 'id_componente')::uuid,
                    ano_referencia = v_item_componente ->> 'ano_referencia',
                    atualizado_em = now()
                where id = (v_item_componente ->> 'id_professor_componente')::uuid;
            else
                -- Senão é inserção
                insert into public.professor_componente (
                    id_professor,
                    id_componente,
                    id_empresa,
                    ano_referencia
                ) values (
                    v_id,
                    (v_item_componente ->> 'id_componente')::uuid,
                    p_id_empresa,
                    coalesce(v_item_componente ->> 'ano_referencia', extract(year from now())::text)
                );
            end if;
        end loop;
    end if;

    return to_jsonb(v_user_expandido_salvo);

exception when others then
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;

ALTER FUNCTION public.professor_upsert(jsonb, uuid)
    OWNER TO postgres;
