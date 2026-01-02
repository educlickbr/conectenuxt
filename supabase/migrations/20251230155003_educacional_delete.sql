-- 1. Drop existing functions to ensure clean recreation
DROP FUNCTION IF EXISTS "public"."classe_delete"("p_id" "uuid", "p_id_empresa" "uuid");
DROP FUNCTION IF EXISTS "public"."ano_etapa_delete"("p_id" "uuid", "p_id_empresa" "uuid");
DROP FUNCTION IF EXISTS "public"."horarios_escola_delete"("p_id" "uuid", "p_id_empresa" "uuid");
DROP FUNCTION IF EXISTS "public"."turmas_delete"("p_id_empresa" "uuid", "p_id" "uuid");

-- Helper function to check admin permission securely (Bouncer Pattern)
-- This encapsulates the logic to avoid repetition and ensure consistency
CREATE OR REPLACE FUNCTION "public"."check_admin_permission"("p_id_empresa" "uuid") 
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_is_admin boolean;
BEGIN
    -- Verifica se o usuário autenticado tem papel de admin na empresa solicitada
    -- A tabela user_expandido é a fonte da verdade para o Bouncer neste projeto
    SELECT EXISTS (
        SELECT 1 
        FROM public.user_expandido ue
        WHERE ue.user_id = auth.uid()
          AND ue.id_empresa = p_id_empresa
          AND (auth.jwt() ->> 'papeis_user')::text = 'admin'
    ) INTO v_is_admin;
    
    RETURN v_is_admin;
END;
$$;


-- 2. Recreate classe_delete
CREATE OR REPLACE FUNCTION "public"."classe_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_deleted_count integer;
BEGIN
    -- Security Check (Bouncer)
    IF NOT public.check_admin_permission(p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Acesso negado. Apenas administradores podem excluir registros.');
    END IF;

    -- Dependency Check: Turmas
    IF EXISTS (SELECT 1 FROM public.turmas WHERE id_classe = p_id AND id_empresa = p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Não é possível excluir a classe pois existem turmas vinculadas a ela.');
    END IF;

    -- Delete
    DELETE FROM public.classe
    WHERE id = p_id AND id_empresa = p_id_empresa;
      
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN jsonb_build_object('status', 'success', 'message', 'Classe deletada com sucesso.', 'id', p_id);
    ELSE
        RETURN jsonb_build_object('status', 'error', 'message', 'Classe não encontrada ou não pertence à empresa.', 'id', p_id);
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
END;
$$;


-- 3. Recreate ano_etapa_delete
CREATE OR REPLACE FUNCTION "public"."ano_etapa_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_deleted_count integer;
BEGIN
    -- Security Check
    IF NOT public.check_admin_permission(p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Acesso negado. Apenas administradores podem excluir registros.');
    END IF;

    -- Dependency Check: Turmas
    IF EXISTS (SELECT 1 FROM public.turmas WHERE id_ano_etapa = p_id AND id_empresa = p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Não é possível excluir o ano/etapa pois existem turmas vinculadas a ele.');
    END IF;

    -- Delete
    DELETE FROM public.ano_etapa
    WHERE id = p_id AND id_empresa = p_id_empresa;
      
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN jsonb_build_object('status', 'success', 'message', 'Ano/Etapa deletado com sucesso.', 'id', p_id);
    ELSE
        RETURN jsonb_build_object('status', 'error', 'message', 'Registro não encontrado ou não pertence à empresa.', 'id', p_id);
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
END;
$$;


-- 4. Recreate horarios_escola_delete
CREATE OR REPLACE FUNCTION "public"."horarios_escola_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_deleted_count integer;
BEGIN
    -- Security Check
     IF NOT public.check_admin_permission(p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Acesso negado. Apenas administradores podem excluir registros.');
    END IF;

    -- Dependency Check: Turmas
    IF EXISTS (SELECT 1 FROM public.turmas WHERE id_horario = p_id AND id_empresa = p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Não é possível excluir o horário pois existem turmas vinculadas a ele.');
    END IF;

    -- Delete
    DELETE FROM public.horarios_escola
    WHERE id = p_id AND id_empresa = p_id_empresa;
      
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN jsonb_build_object('status', 'success', 'message', 'Horário deletado com sucesso.', 'id', p_id);
    ELSE
        RETURN jsonb_build_object('status', 'error', 'message', 'Horário não encontrado ou não pertence à empresa.', 'id', p_id);
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
END;
$$;


-- 5. Recreate turmas_delete
-- Changed return type to jsonb for consistency with others and better error reporting in BFF
CREATE OR REPLACE FUNCTION "public"."turmas_delete"("p_id_empresa" "uuid", "p_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_deleted_count integer;
BEGIN
    -- Security Check
     IF NOT public.check_admin_permission(p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Acesso negado. Apenas administradores podem excluir registros.');
    END IF;

    -- Dependency Check: Matriculas (Alunos na turma)
    IF EXISTS (SELECT 1 FROM public.matriculas WHERE id_turma = p_id AND id_empresa = p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Não é possível excluir a turma pois existem alunos matriculados nela.');
    END IF;

     -- Dependency Check: Diarios (Already implied by matriculas often, but checking direct attendance logs)
    IF EXISTS (SELECT 1 FROM public.diario_presenca WHERE id_turma = p_id AND id_empresa = p_id_empresa) THEN
         RETURN jsonb_build_object('status', 'error', 'message', 'Não é possível excluir a turma pois existem registros de diário/presença.');
    END IF;

    -- Delete
    DELETE FROM public.turmas
    WHERE id = p_id AND id_empresa = p_id_empresa;
      
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN jsonb_build_object('status', 'success', 'message', 'Turma deletada com sucesso.', 'id', p_id);
    ELSE
        RETURN jsonb_build_object('status', 'error', 'message', 'Turma não encontrada ou não pertence à empresa.', 'id', p_id);
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
END;
$$;

-- Grant permissions
ALTER FUNCTION "public"."check_admin_permission"("p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."check_admin_permission"("p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_admin_permission"("p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_admin_permission"("p_id_empresa" "uuid") TO "service_role";

ALTER FUNCTION "public"."classe_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."classe_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."classe_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."classe_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";

ALTER FUNCTION "public"."ano_etapa_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."ano_etapa_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."ano_etapa_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ano_etapa_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";

ALTER FUNCTION "public"."horarios_escola_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."horarios_escola_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."horarios_escola_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."horarios_escola_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";

ALTER FUNCTION "public"."turmas_delete"("p_id_empresa" "uuid", "p_id" "uuid") OWNER TO "postgres";
GRANT ALL ON FUNCTION "public"."turmas_delete"("p_id_empresa" "uuid", "p_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."turmas_delete"("p_id_empresa" "uuid", "p_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."turmas_delete"("p_id_empresa" "uuid", "p_id" "uuid") TO "service_role";
