-- 1. Drop existing functions to ensure clean recreation and handle any signature nuances (as requested)
DROP FUNCTION IF EXISTS "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid");
DROP FUNCTION IF EXISTS "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid");
DROP FUNCTION IF EXISTS "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid");
DROP FUNCTION IF EXISTS "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid");

-- 2. Recreate escolas_delete with dependency check (Escola -> Predio)
CREATE OR REPLACE FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    -- Check for dependencies: Predios
    if exists (
        select 1 from public.bbtk_dim_predio
        where id_escola = p_id
          and id_empresa = p_id_empresa
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Não é possível excluir a escola pois existem prédios associados a ela. Exclua os prédios primeiro.', 'id', p_id);
    end if;

    -- Deleta a escola, garantindo que pertença à empresa correta
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
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;

ALTER FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";


-- 3. Recreate bbtk_dim_predio_delete with dependency check (Predio -> Sala)
CREATE OR REPLACE FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    -- Check for dependencies: Salas
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
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;

ALTER FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";


-- 4. Recreate bbtk_dim_sala_delete with dependency check (Sala -> Estante)
CREATE OR REPLACE FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    -- Check for dependencies: Estantes
    if exists (
        select 1 from public.bbtk_dim_estante
        where sala_uuid = p_id
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Não é possível excluir a sala pois existem estantes associadas a ela. Exclua as estantes primeiro.', 'id', p_id);
    end if;

    -- Delete com JOIN implícito via USING para validar empresa através do prédio
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
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;

ALTER FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";


-- 5. Recreate bbtk_dim_estante_delete with dependency check (Estante -> Livro/Copia)
CREATE OR REPLACE FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    -- Check for dependencies: Livros (Cópias)
    if exists (
        select 1 from public.bbtk_inventario_copia
        where estante_uuid = p_id
          and soft_delete is false
    ) then
        return jsonb_build_object('status', 'error', 'message', 'Não é possível excluir a estante pois existem livros (cópias) associados a ela. Remova ou mova os livros primeiro.', 'id', p_id);
    end if;

    -- Delete com JOIN implícito para validar empresa
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
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;

ALTER FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";
