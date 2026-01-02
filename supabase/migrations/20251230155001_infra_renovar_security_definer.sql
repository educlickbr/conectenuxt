-- Migration: Implement "Bouncer" Security Pattern for Infrastructure RPCs
-- Goal: Use SECURITY DEFINER for robust integrity checks, but explicitly validate
-- that the caller has 'admin' role for the specific company at the start of execution.

-- ==============================================================================
-- 1. ESCOLAS
-- ==============================================================================

DROP FUNCTION IF EXISTS "public"."escolas_upsert"("p_data" "jsonb", "p_id_empresa" "uuid");
DROP FUNCTION IF EXISTS "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid");

CREATE OR REPLACE FUNCTION "public"."escolas_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_escola_salva public.escolas;
begin
    -- 🛡️ BOUNCER: Validação Explícita de Segurança
    if not exists (
        select 1 
        from public.papeis_user_auth pua
        join public.papeis_user pu on pua.papel_id = pu.id
        where pua.user_id = auth.uid()
          and pua.empresa_id = p_id_empresa
          and pu.nome = 'admin' -- Apenas Admin
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Acesso negado: Você não tem permissão de administrador nesta empresa.');
    end if;
    -- Fim do Bouncer 🛡️

    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());

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
    where t.id_empresa = p_id_empresa
    returning * into v_escola_salva;

    return to_jsonb(v_escola_salva);

exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;

ALTER FUNCTION "public"."escolas_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."escolas_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."escolas_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";


CREATE OR REPLACE FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    -- 🛡️ BOUNCER: Validação Explícita de Segurança
    if not exists (
        select 1 
        from public.papeis_user_auth pua
        join public.papeis_user pu on pua.papel_id = pu.id
        where pua.user_id = auth.uid()
          and pua.empresa_id = p_id_empresa
          and pu.nome = 'admin'
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Acesso negado: Você não tem permissão de administrador nesta empresa.');
    end if;
    -- Fim do Bouncer 🛡️

    -- Logica de Integridade
    if exists (
        select 1 from public.bbtk_dim_predio
        where id_escola = p_id
          and id_empresa = p_id_empresa
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Não é possível excluir a escola pois existem prédios associados a ela. Exclua os prédios primeiro.', 'id', p_id);
    end if;

    delete from public.escolas
    where id = p_id
      and id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Escola deletada com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Escola não encontrada ou não pertence à empresa.', 'id', p_id);
    end if;

exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;

ALTER FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";


-- ==============================================================================
-- 2. PREDIOS
-- ==============================================================================

DROP FUNCTION IF EXISTS "public"."bbtk_dim_predio_upsert"("p_data" "jsonb", "p_id_empresa" "uuid");
DROP FUNCTION IF EXISTS "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid");

CREATE OR REPLACE FUNCTION "public"."bbtk_dim_predio_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_registro_salvo public.bbtk_dim_predio;
begin
    -- 🛡️ BOUNCER
    if not exists (
        select 1 
        from public.papeis_user_auth pua
        join public.papeis_user pu on pua.papel_id = pu.id
        where pua.user_id = auth.uid()
          and pua.empresa_id = p_id_empresa
          and pu.nome = 'admin'
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Acesso negado: Você não tem permissão de administrador nesta empresa.');
    end if;
    -- Fim Bouncer

    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());

    insert into public.bbtk_dim_predio as t (
        uuid, nome, id_empresa, id_escola
    )
    values (
        v_id,
        p_data ->> 'nome',
        p_id_empresa,
        NULLIF(p_data ->> 'id_escola', '')::uuid
    )
    on conflict (uuid) do update 
    set 
        nome = coalesce(excluded.nome, t.nome),
        id_escola = excluded.id_escola
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);

exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;

ALTER FUNCTION "public"."bbtk_dim_predio_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";

CREATE OR REPLACE FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    -- 🛡️ BOUNCER
    if not exists (
        select 1 
        from public.papeis_user_auth pua
        join public.papeis_user pu on pua.papel_id = pu.id
        where pua.user_id = auth.uid()
          and pua.empresa_id = p_id_empresa
          and pu.nome = 'admin'
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Acesso negado: Você não tem permissão de administrador nesta empresa.');
    end if;
    -- Fim Bouncer

    if exists (
        select 1 from public.bbtk_dim_sala
        where predio_uuid = p_id
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Não é possível excluir o prédio pois existem salas associadas a ele. Exclua as salas primeiro.', 'id', p_id);
    end if;

    delete from public.bbtk_dim_predio
    where uuid = p_id
      and id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Registro deletado com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Registro não encontrado ou não pertence à empresa.', 'id', p_id);
    end if;

exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;

ALTER FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";


-- ==============================================================================
-- 3. SALAS
-- ==============================================================================

DROP FUNCTION IF EXISTS "public"."bbtk_dim_sala_upsert"("p_data" "jsonb", "p_id_empresa" "uuid");
DROP FUNCTION IF EXISTS "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid");

CREATE OR REPLACE FUNCTION "public"."bbtk_dim_sala_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_registro_salvo public.bbtk_dim_sala;
    v_predio_uuid uuid;
begin
    -- 🛡️ BOUNCER
    if not exists (
        select 1 
        from public.papeis_user_auth pua
        join public.papeis_user pu on pua.papel_id = pu.id
        where pua.user_id = auth.uid()
          and pua.empresa_id = p_id_empresa
          and pu.nome = 'admin'
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Acesso negado: Você não tem permissão de administrador nesta empresa.');
    end if;
    -- Fim Bouncer

    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());
    v_predio_uuid := (p_data ->> 'predio_uuid')::uuid;

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
    ) 
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);

exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;

ALTER FUNCTION "public"."bbtk_dim_sala_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";

CREATE OR REPLACE FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    -- 🛡️ BOUNCER
    if not exists (
        select 1 
        from public.papeis_user_auth pua
        join public.papeis_user pu on pua.papel_id = pu.id
        where pua.user_id = auth.uid()
          and pua.empresa_id = p_id_empresa
          and pu.nome = 'admin'
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Acesso negado: Você não tem permissão de administrador nesta empresa.');
    end if;
    -- Fim Bouncer

    if exists (
        select 1 from public.bbtk_dim_estante
        where sala_uuid = p_id
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Não é possível excluir a sala pois existem estantes associadas a ela. Exclua as estantes primeiro.', 'id', p_id);
    end if;

    delete from public.bbtk_dim_sala s
    using public.bbtk_dim_predio p
    where s.predio_uuid = p.uuid
      and s.uuid = p_id
      and p.id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Registro deletado com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Registro não encontrado ou não pertence à empresa.', 'id', p_id);
    end if;

exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;

ALTER FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";


-- ==============================================================================
-- 4. ESTANTES
-- ==============================================================================

DROP FUNCTION IF EXISTS "public"."bbtk_dim_estante_upsert"("p_data" "jsonb", "p_id_empresa" "uuid");
DROP FUNCTION IF EXISTS "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid");

CREATE OR REPLACE FUNCTION "public"."bbtk_dim_estante_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_registro_salvo public.bbtk_dim_estante;
    v_sala_uuid uuid;
begin
    -- 🛡️ BOUNCER
    if not exists (
        select 1 
        from public.papeis_user_auth pua
        join public.papeis_user pu on pua.papel_id = pu.id
        where pua.user_id = auth.uid()
          and pua.empresa_id = p_id_empresa
          and pu.nome = 'admin'
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Acesso negado: Você não tem permissão de administrador nesta empresa.');
    end if;
    -- Fim Bouncer

    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());
    v_sala_uuid := (p_data ->> 'sala_uuid')::uuid;

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
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);

exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;

ALTER FUNCTION "public"."bbtk_dim_estante_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";

CREATE OR REPLACE FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    -- 🛡️ BOUNCER
    if not exists (
        select 1 
        from public.papeis_user_auth pua
        join public.papeis_user pu on pua.papel_id = pu.id
        where pua.user_id = auth.uid()
          and pua.empresa_id = p_id_empresa
          and pu.nome = 'admin'
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Acesso negado: Você não tem permissão de administrador nesta empresa.');
    end if;
    -- Fim Bouncer

    if exists (
        select 1 from public.bbtk_inventario_copia
        where estante_uuid = p_id
          and soft_delete is false
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Não é possível excluir a estante pois existem livros (cópias) associados a ela. Remova ou mova os livros primeiro.', 'id', p_id);
    end if;

    delete from public.bbtk_dim_estante e
    using public.bbtk_dim_sala s, public.bbtk_dim_predio p
    where e.sala_uuid = s.uuid
      and s.predio_uuid = p.uuid
      and e.uuid = p_id
      and p.id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Registro deletado com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Registro não encontrado ou não pertence à empresa.', 'id', p_id);
    end if;

exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;

ALTER FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";
