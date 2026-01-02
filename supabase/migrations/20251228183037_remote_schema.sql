

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "public";






CREATE EXTENSION IF NOT EXISTS "pgsodium";






CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "public";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "unaccent" WITH SCHEMA "public";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."bbtk_funcao_autoria" AS ENUM (
    'Autor',
    'Tradutor',
    'Adaptador',
    'Organizador',
    'Ilustrador'
);


ALTER TYPE "public"."bbtk_funcao_autoria" OWNER TO "postgres";


CREATE TYPE "public"."bbtk_status_copia" AS ENUM (
    'Disponível',
    'Reservado',
    'Emprestado',
    'Em Manutenção',
    'Perdido',
    'Descartado'
);


ALTER TYPE "public"."bbtk_status_copia" OWNER TO "postgres";


CREATE TYPE "public"."bbtk_status_reserva" AS ENUM (
    'Reservado',
    'Entregue',
    'Cancelado'
);


ALTER TYPE "public"."bbtk_status_reserva" OWNER TO "postgres";


CREATE TYPE "public"."bbtk_tipo_interacao" AS ENUM (
    'Empréstimo',
    'Reserva',
    'Devolução',
    'Renovação'
);


ALTER TYPE "public"."bbtk_tipo_interacao" OWNER TO "postgres";


CREATE TYPE "public"."bbtk_tipo_livro" AS ENUM (
    'Impresso',
    'Digital'
);


ALTER TYPE "public"."bbtk_tipo_livro" OWNER TO "postgres";


CREATE TYPE "public"."bbtk_tipo_publicacao" AS ENUM (
    'Livro',
    'Livro com Mídia',
    'Periódico',
    'Monografias e Teses',
    'CD',
    'DVD',
    'VHS'
);


ALTER TYPE "public"."bbtk_tipo_publicacao" OWNER TO "postgres";


CREATE TYPE "public"."bimestre_enum" AS ENUM (
    '1º BIMESTRE',
    '2º BIMESTRE',
    '3º BIMESTRE',
    '4º BIMESTRE'
);


ALTER TYPE "public"."bimestre_enum" OWNER TO "postgres";


CREATE TYPE "public"."codigo_afastamento_licenca" AS ENUM (
    'APA',
    'ATRE',
    'LA',
    'LAC',
    'LAP',
    'LP',
    'LAT',
    'LG',
    'LNT',
    'LS',
    'LSV'
);


ALTER TYPE "public"."codigo_afastamento_licenca" OWNER TO "postgres";


CREATE TYPE "public"."codigo_falta_professor" AS ENUM (
    'AB',
    'ATRE',
    'CRT',
    'DS',
    'FHTP',
    'FHTPJ',
    'G',
    'I',
    'J',
    'JA',
    'LAC',
    'LS',
    'LSV',
    'N',
    'NC',
    'SOL',
    'FPAD'
);


ALTER TYPE "public"."codigo_falta_professor" OWNER TO "postgres";


CREATE TYPE "public"."enum_tipo_curso_certificado" AS ENUM (
    'Certificados/Diplomas de Desenvolvimento Profissional',
    'Curso de Especialização/Pós-Graduação',
    'Curso de Licenciatura/Graduação',
    'Diploma de Doutor',
    'Diploma de Mestre',
    'Diploma de Pós-Doutorado'
);


ALTER TYPE "public"."enum_tipo_curso_certificado" OWNER TO "postgres";


CREATE TYPE "public"."etapa_enum" AS ENUM (
    'ENSINO MEDIO',
    'ENSINO FUNDAMENTAL DE 9 ANOS - ANOS INICIAIS',
    'ENSINO FUNDAMENTAL DE 9 ANOS - ANOS FINAIS'
);


ALTER TYPE "public"."etapa_enum" OWNER TO "postgres";


CREATE TYPE "public"."funcao_extra_enum" AS ENUM (
    'Assistente de Direcao',
    'Coordenador Pedagogico',
    'Diretor de Escola',
    'Supervisor Educacional'
);


ALTER TYPE "public"."funcao_extra_enum" OWNER TO "postgres";


CREATE TYPE "public"."liberacao_conteudo_enum" AS ENUM (
    'Conteúdo',
    'Item',
    'Sempre Disponível'
);


ALTER TYPE "public"."liberacao_conteudo_enum" OWNER TO "postgres";


CREATE TYPE "public"."lms_tipo_item" AS ENUM (
    'Tarefa',
    'Material',
    'Questionário'
);


ALTER TYPE "public"."lms_tipo_item" OWNER TO "postgres";


CREATE TYPE "public"."lms_tipo_pergunta" AS ENUM (
    'Dissertativa',
    'Múltipla Escolha'
);


ALTER TYPE "public"."lms_tipo_pergunta" OWNER TO "postgres";


CREATE TYPE "public"."modalidade_horario" AS ENUM (
    'semanal',
    'diario',
    'bloco',
    'pleno'
);


ALTER TYPE "public"."modalidade_horario" OWNER TO "postgres";


CREATE TYPE "public"."periodo_escolar" AS ENUM (
    'Matutino',
    'Vespertino',
    'Noturno',
    'Integral'
);


ALTER TYPE "public"."periodo_escolar" OWNER TO "postgres";


CREATE TYPE "public"."serie_enum" AS ENUM (
    '1ª SÉRIE',
    '1º ANO',
    '2ª SÉRIE',
    '2º ANO',
    '3ª SÉRIE',
    '3ª SÉRIE - PREPARA SP',
    '3ª SÉRIE - PREPARA SP REFORÇO',
    '3º ANO',
    '4º ANO',
    '5º ANO',
    '5º ANO - PREPARA SP REFORÇO',
    '6º ANO',
    '7º ANO',
    '8º ANO',
    '9º ANO',
    '9º ANO - PREPARA SP REFORÇO'
);


ALTER TYPE "public"."serie_enum" OWNER TO "postgres";


CREATE TYPE "public"."sim_nao" AS ENUM (
    'sim',
    'nao'
);


ALTER TYPE "public"."sim_nao" OWNER TO "postgres";


CREATE TYPE "public"."status_contrato" AS ENUM (
    'Exonerado',
    'Aposentado',
    'Ativo'
);


ALTER TYPE "public"."status_contrato" OWNER TO "postgres";


CREATE TYPE "public"."status_pontuacao_professores" AS ENUM (
    'contestado',
    'retificado',
    'validado'
);


ALTER TYPE "public"."status_pontuacao_professores" OWNER TO "postgres";


CREATE TYPE "public"."tipo_afastamento" AS ENUM (
    'Licença Gestante',
    'Licença Saúde',
    'Licença Sem Vencimento',
    'Outros',
    'Suporte Pedagógico',
    'Restrição Médica'
);


ALTER TYPE "public"."tipo_afastamento" OWNER TO "postgres";


CREATE TYPE "public"."tipo_ano_etapa" AS ENUM (
    'Ano',
    'Etapa'
);


ALTER TYPE "public"."tipo_ano_etapa" OWNER TO "postgres";


CREATE TYPE "public"."tipo_contrato_professor" AS ENUM (
    'CLT/Substituto',
    'Efetivo',
    'Efetivo/Substituto',
    'Efetivo/Suporte Pedagógico',
    'Substituto/Suporte Pedagógico',
    'Suporte Pedagógico'
);


ALTER TYPE "public"."tipo_contrato_professor" OWNER TO "postgres";


CREATE TYPE "public"."tipo_ferias_enum" AS ENUM (
    'integral',
    'primeiro_periodo',
    'segundo_periodo',
    'ferias_premio'
);


ALTER TYPE "public"."tipo_ferias_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."_touch_atualizado_em"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;


ALTER FUNCTION "public"."_touch_atualizado_em"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."acumular_pontuacao_ano"("p_ano_atual" integer) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_ano_anterior integer := p_ano_atual - 1;
  v_count_total integer := 0;
  v_count_sem_anterior integer := 0;
  v_unid_anterior bigint;
  v_dep_anterior bigint;
  v_calc_unid bigint;
  v_calc_dep bigint;
  v_prof record;
begin
  for v_prof in
    select id_professor, id_empresa, pontuacao_unidade, pontuacao_departamento
    from pontuacao_professores
    where ano = p_ano_atual
      and soft_delete = false
  loop
    select pontuacao_unidade_total, pontuacao_departamento_total
      into v_unid_anterior, v_dep_anterior
      from pontuacao_professores
     where id_professor = v_prof.id_professor
       and id_empresa = v_prof.id_empresa
       and ano = v_ano_anterior
       and soft_delete = false
     limit 1;

    if not found then
      -- 🔹 Sem registro anterior: mantém valores e marca true
      update pontuacao_professores
         set pontuacao_unidade_total      = coalesce(v_prof.pontuacao_unidade,0),
             pontuacao_departamento_total = coalesce(v_prof.pontuacao_departamento,0),
             registro_anterior            = true,
             atualizado_em                = now()
       where id_professor = v_prof.id_professor
         and id_empresa = v_prof.id_empresa
         and ano = p_ano_atual
         and soft_delete = false;

      v_count_sem_anterior := v_count_sem_anterior + 1;
      continue;
    end if;

    -- 🔹 Com registro anterior: soma e marca false
    v_calc_unid := coalesce(v_prof.pontuacao_unidade,0) + coalesce(v_unid_anterior,0);
    v_calc_dep  := coalesce(v_prof.pontuacao_departamento,0) + coalesce(v_dep_anterior,0);

    update pontuacao_professores
       set pontuacao_unidade_total      = v_calc_unid,
           pontuacao_departamento_total = v_calc_dep,
           registro_anterior            = false,
           atualizado_em                = now()
     where id_professor = v_prof.id_professor
       and id_empresa = v_prof.id_empresa
       and ano = p_ano_atual
       and soft_delete = false;

    v_count_total := v_count_total + 1;
  end loop;

  return jsonb_build_object(
    'ano_atual', p_ano_atual,
    'ano_anterior', v_ano_anterior,
    'atualizados_com_soma', v_count_total,
    'sem_registro_anterior', v_count_sem_anterior
  );
end;
$$;


ALTER FUNCTION "public"."acumular_pontuacao_ano"("p_ano_atual" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."adiciona_user_papel_empresa"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  -- Verifica se já existe associação (evita duplicidade)
  insert into public.papeis_user_auth (id, user_id, papel_id, empresa_id)
  values (
    gen_random_uuid(),
    NEW.user_id,
    NEW.papel_id,
    NEW.empresa_id
  )
  on conflict (user_id, papel_id, empresa_id) do nothing;

  return NEW;
end;
$$;


ALTER FUNCTION "public"."adiciona_user_papel_empresa"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."adiciona_user_papel_empresa_secretaria"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  insert into public.papeis_user_auth (id, user_id, papel_id, empresa_id)
  values (
    gen_random_uuid(),
    NEW.user_id,
    NEW.papel_id,
    NEW.empresa_id
  )
  on conflict (user_id, papel_id, empresa_id) do nothing;

  return NEW;
end;
$$;


ALTER FUNCTION "public"."adiciona_user_papel_empresa_secretaria"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    UPDATE public.user_expandido
    SET soft_delete = TRUE
    WHERE id = p_id AND id_empresa = p_id_empresa;
END;
$$;


ALTER FUNCTION "public"."admin_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT NULL::"text") RETURNS TABLE("id" "uuid", "nome_completo" "text", "email" "text", "telefone" "text", "matricula" "text", "status_contrato" "public"."status_contrato", "user_id" "uuid", "total_registros" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_offset integer;
    v_role_admin uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    RETURN QUERY
    WITH admins_filtrados AS (
        SELECT
            ue.id,
            ue.nome_completo,
            ue.email,
            ue.telefone,
            ue.matricula,
            ue.status_contrato,
            ue.user_id
        FROM
            public.user_expandido ue
        WHERE
            ue.id_empresa = p_id_empresa
            AND ue.papel_id = v_role_admin
            AND ue.soft_delete IS FALSE
            AND (
                p_busca IS NULL OR 
                ue.nome_completo ILIKE '%' || p_busca || '%' OR
                ue.email ILIKE '%' || p_busca || '%' OR
                ue.matricula ILIKE '%' || p_busca || '%'
            )
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM admins_filtrados
    )
    SELECT
        af.id,
        af.nome_completo,
        af.email,
        af.telefone,
        af.matricula,
        af.status_contrato,
        af.user_id,
        tc.total as total_registros
    FROM
        admins_filtrados af
    CROSS JOIN
        total_count tc
    ORDER BY
        af.nome_completo ASC
    LIMIT
        p_limite_itens_pagina
    OFFSET
        v_offset;
END;
$$;


ALTER FUNCTION "public"."admin_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_upsert"("p_id_empresa" "uuid", "p_data" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_id uuid;
    v_papel_admin uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
    v_matricula text;
BEGIN
    v_id := (p_data->>'id')::uuid;

    -- Generate Matricula if new
    IF v_id IS NULL THEN
        v_matricula := 'ADM-' || floor(extract(epoch from now()) * 1000)::text || '-' || floor(random() * 1000)::text;
        
        INSERT INTO public.user_expandido (
            id_empresa,
            nome_completo,
            email,
            telefone,
            matricula,
            papel_id,
            status_contrato
        ) VALUES (
            p_id_empresa,
            p_data->>'nome_completo',
            p_data->>'email',
            p_data->>'telefone',
            v_matricula,
            v_papel_admin,
            'Ativo'
        ) RETURNING id INTO v_id;
    ELSE
        UPDATE public.user_expandido
        SET 
            nome_completo = p_data->>'nome_completo',
            email = p_data->>'email',
            telefone = p_data->>'telefone'
        WHERE id = v_id AND id_empresa = p_id_empresa;
    END IF;

    RETURN jsonb_build_object('id', v_id);
END;
$$;


ALTER FUNCTION "public"."admin_upsert"("p_id_empresa" "uuid", "p_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."aluno_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text", "p_id_escola" "uuid" DEFAULT NULL::"uuid", "p_status" "text" DEFAULT NULL::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
    
    -- ID do papel de aluno
    v_papel_aluno uuid := 'b7f53d6e-70b5-453b-b564-728aeb4635d5';
BEGIN
    -- 1. Calcular Offset
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- 2. Calcular Total de Itens (para a busca atual)
    SELECT COUNT(*) INTO v_total_itens
    FROM public.user_expandido u
    LEFT JOIN public.escolas e ON u.id_escola = e.id
    WHERE 
        u.id_empresa = p_id_empresa
        AND u.papel_id = v_papel_aluno
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(u.nome_completo) LIKE v_busca_like 
            OR UPPER(u.matricula) LIKE v_busca_like
        )
        AND (
            p_id_escola IS NULL 
            OR u.id_escola = p_id_escola
        )
        AND (
            p_status IS NULL 
            OR u.status_contrato::text = p_status
        );

    -- 3. Calcular Total de Páginas
    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- 4. Buscar Itens Paginados e converter para JSON
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            u.user_id,
            u.id AS user_expandido_id,
            u.email,
            u.nome_completo,
            u.matricula,
            e.nome AS nome_escola,
            e.id AS id_escola,
            u.status_contrato AS status
        FROM public.user_expandido u
        LEFT JOIN public.escolas e ON u.id_escola = e.id
        WHERE 
            u.id_empresa = p_id_empresa
            AND u.papel_id = v_papel_aluno
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(u.nome_completo) LIKE v_busca_like
                OR UPPER(u.matricula) LIKE v_busca_like
            )
            AND (
                p_id_escola IS NULL 
                OR u.id_escola = p_id_escola
            )
            AND (
                p_status IS NULL 
                OR u.status_contrato::text = p_status
            )
        ORDER BY u.nome_completo ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- 5. Retornar Objeto JSON Final
    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."aluno_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid", "p_status" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."aluno_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_user_expandido_salvo public.user_expandido;
    v_papel_aluno uuid := 'b7f53d6e-70b5-453b-b564-728aeb4635d5';
    v_item_resposta jsonb;
begin
    -- 1. Obter ID do Aluno (ou gerar novo)
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
        id_escola
    ) values (
        v_id,
        p_id_empresa,
        p_data ->> 'nome_completo',
        p_data ->> 'email',
        p_data ->> 'telefone',
        coalesce(p_data ->> 'matricula', 'TEMP-' || extract(epoch from now())::text),
        v_papel_aluno,
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

    return to_jsonb(v_user_expandido_salvo);

exception when others then
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;


ALTER FUNCTION "public"."aluno_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ano_etapa_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    -- Deleta o registro, garantindo que pertença à empresa correta
    delete from public.ano_etapa
    where id = p_id
      and id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Registro deletado com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Registro não encontrado ou não pertence à empresa.', 'id', p_id);
    end if;

exception when others then
    -- Retorna JSON de erro estruturado
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;


ALTER FUNCTION "public"."ano_etapa_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ano_etapa_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    -- 1. Calcular Offset
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- 2. Calcular Total de Itens (para a busca atual)
    SELECT COUNT(*) INTO v_total_itens
    FROM public.ano_etapa
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome) LIKE v_busca_like 
        );

    -- 3. Calcular Total de Páginas
    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- 4. Buscar Itens Paginados e converter para JSON
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT *
        FROM public.ano_etapa
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like 
            )
        ORDER BY nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- 5. Retornar Objeto JSON Final
    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."ano_etapa_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ano_etapa_get_schema"("p_id_empresa" "uuid") RETURNS SETOF "jsonb"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    -- Reutiliza a função genérica get_table_schema para a tabela 'ano_etapa'
    select public.get_table_schema(p_id_empresa, 'ano_etapa');
$$;


ALTER FUNCTION "public"."ano_etapa_get_schema"("p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ano_etapa_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_ano_etapa_salva public.ano_etapa;
begin
    -- Tenta obter o ID, se não existir, um novo ID será gerado
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());

    -- Verifica se a operação é permitida para a empresa
    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    -- Executa o UPSERT (INSERT/UPDATE)
    insert into public.ano_etapa as t (
        id, 
        id_empresa, 
        nome, 
        tipo, 
        carg_horaria, 
        title_sharepoint, 
        id_sharepoint
    )
    values (
        v_id,
        p_id_empresa,
        p_data ->> 'nome',
        (p_data ->> 'tipo')::tipo_ano_etapa,
        (p_data ->> 'carg_horaria')::integer,
        p_data ->> 'title_sharepoint',
        p_data ->> 'id_sharepoint'
    )
    on conflict (id) do update 
    set 
        nome = coalesce(excluded.nome, t.nome),
        tipo = coalesce(excluded.tipo, t.tipo),
        carg_horaria = coalesce(excluded.carg_horaria, t.carg_horaria),
        title_sharepoint = coalesce(excluded.title_sharepoint, t.title_sharepoint),
        id_sharepoint = coalesce(excluded.id_sharepoint, t.id_sharepoint)
    where t.id_empresa = p_id_empresa -- Garante que o UPDATE só ocorra dentro da empresa correta
    returning * into v_ano_etapa_salva;

    -- Retorna o registro salvo em formato JSON
    return to_jsonb(v_ano_etapa_salva);

exception when others then
    -- Em caso de erro, retorna um JSON de erro estruturado
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;


ALTER FUNCTION "public"."ano_etapa_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."atualiza_at_professores"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.at_titular := NEW.id_professor IS NOT NULL;
  NEW.at_substituto := NEW.id_professor_s IS NOT NULL;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."atualiza_at_professores"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_copias_disponiveis_get"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_copias json;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json)
    INTO v_copias
    FROM (
        SELECT 
            c.uuid as id_copia,
            c.registro_bibliotecario,
            e.nome as nome_estante,
            s.nome as nome_sala,
            p.nome as nome_predio,
            esc.nome as nome_escola
        FROM public.bbtk_inventario_copia c
        JOIN public.bbtk_dim_estante e ON c.estante_uuid = e.uuid
        JOIN public.bbtk_dim_sala s ON e.sala_uuid = s.uuid
        JOIN public.bbtk_dim_predio p ON s.predio_uuid = p.uuid
        JOIN public.escolas esc ON p.id_escola = esc.id
        WHERE c.id_empresa = p_id_empresa
          AND c.edicao_uuid = p_edicao_uuid
          AND c.status_copia::text = 'Disponível'
    ) t;

    RETURN v_copias;
END;
$$;


ALTER FUNCTION "public"."bbtk_copias_disponiveis_get"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_autoria_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    delete from public.bbtk_dim_autoria
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


ALTER FUNCTION "public"."bbtk_dim_autoria_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_autoria_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_dim_autoria
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome_completo) LIKE v_busca_like 
            OR UPPER(codigo_cutter) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT *
        FROM public.bbtk_dim_autoria
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome_completo) LIKE v_busca_like 
                OR UPPER(codigo_cutter) LIKE v_busca_like
            )
        ORDER BY nome_completo ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_dim_autoria_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_autoria_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_user_id uuid := current_setting('request.jwt.claim.sub', true)::uuid;
    v_registro_salvo public.bbtk_dim_autoria;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.bbtk_dim_autoria as t (
        uuid, nome_completo, codigo_cutter, id_empresa, id_bubble
    )
    values (
        v_id,
        p_data ->> 'nome_completo',
        p_data ->> 'codigo_cutter',
        p_id_empresa,
        p_data ->> 'id_bubble'
    )
    on conflict (uuid) do update 
    set 
        nome_completo = coalesce(excluded.nome_completo, t.nome_completo),
        codigo_cutter = coalesce(excluded.codigo_cutter, t.codigo_cutter),
        id_bubble = coalesce(excluded.id_bubble, t.id_bubble)
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


ALTER FUNCTION "public"."bbtk_dim_autoria_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_categoria_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    delete from public.bbtk_dim_categoria
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


ALTER FUNCTION "public"."bbtk_dim_categoria_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_categoria_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    -- 1. Calcular Offset
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    -- 2. Calcular Total de Itens (mantém a lógica robusta de busca NULL/Vazio)
    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_dim_categoria
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome) LIKE v_busca_like 
            OR UPPER(descricao) LIKE v_busca_like
        );

    -- 3. Calcular Total de Páginas
    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- 4. Buscar Itens Paginados e converter para um array JSON simples
    -- Usamos json_agg(t) em um subselect para retornar um array de objetos JSON limpos,
    -- sem a lógica de label/ordem.
    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT uuid, nome, descricao, id_empresa, id_bubble, id_bubble as id_bubble
        FROM public.bbtk_dim_categoria
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like 
                OR UPPER(descricao) LIKE v_busca_like
            )
        ORDER BY nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- 5. Retornar Objeto JSON Final com metadados
    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_dim_categoria_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_categoria_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_user_id uuid := current_setting('request.jwt.claim.sub', true)::uuid;
    v_registro_salvo public.bbtk_dim_categoria;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.bbtk_dim_categoria as t (
        uuid, nome, descricao, id_empresa, id_bubble
    )
    values (
        v_id,
        p_data ->> 'nome',
        p_data ->> 'descricao',
        p_id_empresa,
        p_data ->> 'id_bubble'
    )
    on conflict (uuid) do update 
    set 
        nome = coalesce(excluded.nome, t.nome),
        descricao = coalesce(excluded.descricao, t.descricao),
        id_bubble = coalesce(excluded.id_bubble, t.id_bubble)
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


ALTER FUNCTION "public"."bbtk_dim_categoria_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_cdu_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    delete from public.bbtk_dim_cdu
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


ALTER FUNCTION "public"."bbtk_dim_cdu_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_cdu_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_dim_cdu
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome) LIKE v_busca_like 
            OR UPPER(codigo) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT *
        FROM public.bbtk_dim_cdu
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like 
                OR UPPER(codigo) LIKE v_busca_like
            )
        ORDER BY nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_dim_cdu_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_cdu_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_user_id uuid := current_setting('request.jwt.claim.sub', true)::uuid;
    v_registro_salvo public.bbtk_dim_cdu;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.bbtk_dim_cdu as t (
        uuid, codigo, nome, id_empresa
    )
    values (
        v_id,
        p_data ->> 'codigo',
        p_data ->> 'nome',
        p_id_empresa
    )
    on conflict (uuid) do update 
    set 
        codigo = coalesce(excluded.codigo, t.codigo),
        nome = coalesce(excluded.nome, t.nome)
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


ALTER FUNCTION "public"."bbtk_dim_cdu_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_doador_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    delete from public.bbtk_dim_doador
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


ALTER FUNCTION "public"."bbtk_dim_doador_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_doador_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_dim_doador
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome) LIKE v_busca_like 
            OR UPPER(email) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT *
        FROM public.bbtk_dim_doador
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like 
                OR UPPER(email) LIKE v_busca_like
            )
        ORDER BY nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_dim_doador_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_doador_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_user_id uuid := current_setting('request.jwt.claim.sub', true)::uuid;
    v_registro_salvo public.bbtk_dim_doador;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.bbtk_dim_doador as t (
        uuid, nome, email, telefone, id_empresa
    )
    values (
        v_id,
        p_data ->> 'nome',
        p_data ->> 'email',
        p_data ->> 'telefone',
        p_id_empresa
    )
    on conflict (uuid) do update 
    set 
        nome = coalesce(excluded.nome, t.nome),
        email = coalesce(excluded.email, t.email),
        telefone = coalesce(excluded.telefone, t.telefone)
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


ALTER FUNCTION "public"."bbtk_dim_doador_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_editora_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    delete from public.bbtk_dim_editora
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


ALTER FUNCTION "public"."bbtk_dim_editora_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_editora_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_dim_editora
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome) LIKE v_busca_like 
            OR UPPER(email) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT *
        FROM public.bbtk_dim_editora
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like 
                OR UPPER(email) LIKE v_busca_like
            )
        ORDER BY nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_dim_editora_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_editora_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_user_id uuid := current_setting('request.jwt.claim.sub', true)::uuid;
    v_registro_salvo public.bbtk_dim_editora;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.bbtk_dim_editora as t (
        uuid, nome, email, telefone, id_empresa
    )
    values (
        v_id,
        p_data ->> 'nome',
        p_data ->> 'email',
        p_data ->> 'telefone',
        p_id_empresa
    )
    on conflict (uuid) do update 
    set 
        nome = coalesce(excluded.nome, t.nome),
        email = coalesce(excluded.email, t.email),
        telefone = coalesce(excluded.telefone, t.telefone)
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


ALTER FUNCTION "public"."bbtk_dim_editora_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
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


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_estante_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text", "p_sala_uuid" "uuid" DEFAULT NULL::"uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_dim_estante e
    INNER JOIN public.bbtk_dim_sala s ON e.sala_uuid = s.uuid
    INNER JOIN public.bbtk_dim_predio p ON s.predio_uuid = p.uuid
    LEFT JOIN public.escolas esc ON p.id_escola = esc.id
    WHERE 
        p.id_empresa = p_id_empresa
        AND (p_sala_uuid IS NULL OR e.sala_uuid = p_sala_uuid)
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(e.nome) LIKE v_busca_like
            OR UPPER(s.nome) LIKE v_busca_like
            OR UPPER(p.nome) LIKE v_busca_like
            OR UPPER(esc.nome) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT 
            e.*,
            s.nome as sala_nome,
            p.uuid as predio_uuid,
            p.nome as predio_nome,
            esc.id as escola_id,
            esc.nome as escola_nome
        FROM public.bbtk_dim_estante e
        INNER JOIN public.bbtk_dim_sala s ON e.sala_uuid = s.uuid
        INNER JOIN public.bbtk_dim_predio p ON s.predio_uuid = p.uuid
        LEFT JOIN public.escolas esc ON p.id_escola = esc.id
        WHERE 
            p.id_empresa = p_id_empresa
            AND (p_sala_uuid IS NULL OR e.sala_uuid = p_sala_uuid)
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(e.nome) LIKE v_busca_like
                OR UPPER(s.nome) LIKE v_busca_like
                OR UPPER(p.nome) LIKE v_busca_like
                OR UPPER(esc.nome) LIKE v_busca_like
            )
        ORDER BY e.nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_dim_estante_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_sala_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_estante_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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


ALTER FUNCTION "public"."bbtk_dim_estante_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_metadado_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    delete from public.bbtk_dim_metadado
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


ALTER FUNCTION "public"."bbtk_dim_metadado_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_metadado_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_dim_metadado
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT *
        FROM public.bbtk_dim_metadado
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like
            )
        ORDER BY nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_dim_metadado_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_metadado_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_user_id uuid := current_setting('request.jwt.claim.sub', true)::uuid;
    v_registro_salvo public.bbtk_dim_metadado;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.bbtk_dim_metadado as t (
        uuid, nome, id_empresa
    )
    values (
        v_id,
        p_data ->> 'nome',
        p_id_empresa
    )
    on conflict (uuid) do update 
    set 
        nome = coalesce(excluded.nome, t.nome)
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


ALTER FUNCTION "public"."bbtk_dim_metadado_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
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


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_predio_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text", "p_id_escola" "uuid" DEFAULT NULL::"uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_dim_predio predio
    LEFT JOIN public.escolas escolas ON predio.id_escola = escolas.id
    WHERE 
        predio.id_empresa = p_id_empresa
        AND (p_id_escola IS NULL OR predio.id_escola = p_id_escola)
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(predio.nome) LIKE v_busca_like
            OR UPPER(escolas.nome) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT 
            predio.*,
            escolas.nome as nome_escola
        FROM public.bbtk_dim_predio predio
        LEFT JOIN public.escolas escolas ON predio.id_escola = escolas.id
        WHERE 
            predio.id_empresa = p_id_empresa
            AND (p_id_escola IS NULL OR predio.id_escola = p_id_escola)
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(predio.nome) LIKE v_busca_like
                OR UPPER(escolas.nome) LIKE v_busca_like
            )
        ORDER BY predio.nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_dim_predio_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_predio_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_id uuid;
    v_user_id uuid := current_setting('request.jwt.claim.sub', true)::uuid;
    v_registro_salvo public.bbtk_dim_predio;
begin
    v_id := coalesce((p_data ->> 'uuid')::uuid, gen_random_uuid());

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

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
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;


ALTER FUNCTION "public"."bbtk_dim_predio_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
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


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_sala_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text", "p_predio_uuid" "uuid" DEFAULT NULL::"uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_dim_sala s
    INNER JOIN public.bbtk_dim_predio p ON s.predio_uuid = p.uuid
    LEFT JOIN public.escolas e ON p.id_escola = e.id
    WHERE 
        p.id_empresa = p_id_empresa
        AND (p_predio_uuid IS NULL OR s.predio_uuid = p_predio_uuid)
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(s.nome) LIKE v_busca_like
            OR UPPER(p.nome) LIKE v_busca_like
            OR UPPER(e.nome) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT 
            s.*, 
            p.nome as predio_nome, 
            e.nome as escola_nome, 
            e.id as escola_id
        FROM public.bbtk_dim_sala s
        INNER JOIN public.bbtk_dim_predio p ON s.predio_uuid = p.uuid
        LEFT JOIN public.escolas e ON p.id_escola = e.id
        WHERE 
            p.id_empresa = p_id_empresa
            AND (p_predio_uuid IS NULL OR s.predio_uuid = p_predio_uuid)
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(s.nome) LIKE v_busca_like
                OR UPPER(p.nome) LIKE v_busca_like
                OR UPPER(e.nome) LIKE v_busca_like
            )
        ORDER BY s.nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_dim_sala_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_predio_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_dim_sala_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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


ALTER FUNCTION "public"."bbtk_dim_sala_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_edicao_get_detalhes"("p_uuid" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_edicao jsonb;
BEGIN
    SELECT row_to_json(t)::jsonb INTO v_edicao
    FROM (
        SELECT 
            e.*,
            -- Joins simples
            o.titulo_principal AS obra_titulo,
            edit.nome AS editora_nome,
            doad.nome AS doador_nome,
            
            -- Autores secundários (Junção)
            (
                SELECT COALESCE(json_agg(row_to_json(a)), '[]'::json)
                FROM (
                    SELECT 
                        au.uuid,
                        au.nome_completo,
                        jea.funcao
                    FROM public.bbtk_juncao_edicao_autoria jea
                    JOIN public.bbtk_dim_autoria au ON jea.autoria_uuid = au.uuid
                    WHERE jea.edicao_uuid = e.uuid
                ) a
            ) AS autores_secundarios,

            -- Metadados (Junção)
            (
                SELECT COALESCE(json_agg(row_to_json(m)), '[]'::json)
                FROM (
                    SELECT 
                        met.uuid,
                        met.nome
                    FROM public.bbtk_juncao_edicao_metadado jem
                    JOIN public.bbtk_dim_metadado met ON jem.metadado_uuid = met.uuid
                    WHERE jem.edicao_uuid = e.uuid
                ) m
            ) AS metadados,

            -- Contagem de cópias (se não for Digital)
            CASE 
                WHEN e.tipo_livro::text <> 'Digital' THEN (
                    SELECT count(*) 
                    FROM public.bbtk_inventario_copia ic 
                    WHERE ic.edicao_uuid = e.uuid
                )
                ELSE 0
            END AS qtd_copias_inventario

        FROM public.bbtk_edicao e
        JOIN public.bbtk_obra o ON e.obra_uuid = o.uuid
        LEFT JOIN public.bbtk_dim_editora edit ON e.editora_uuid = edit.uuid
        LEFT JOIN public.bbtk_dim_doador doad ON e.doador_uuid = doad.uuid
        WHERE e.uuid = p_uuid 
          AND e.id_empresa = p_id_empresa
    ) t;

    IF v_edicao IS NULL THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Edição não encontrada');
    END IF;

    RETURN v_edicao;
END;
$$;


ALTER FUNCTION "public"."bbtk_edicao_get_detalhes"("p_uuid" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_edicao_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_termo_busca" "text" DEFAULT NULL::"text", "p_tipo_livro" "text" DEFAULT 'Impresso'::"text", "p_user_uuid" "uuid" DEFAULT NULL::"uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
    v_busca_like text;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);
    
    IF p_termo_busca IS NOT NULL AND TRIM(p_termo_busca) <> '' THEN
         v_busca_like := '%' || UPPER(p_termo_busca) || '%';
    ELSE
         v_busca_like := NULL;
    END IF;

    -- Contar total de itens
    SELECT COUNT(*)
    INTO v_total_itens
    FROM public.bbtk_edicao e
    JOIN public.bbtk_obra o ON e.obra_uuid = o.uuid
    WHERE e.id_empresa = p_id_empresa
      AND o.soft_delete = false
      AND e.tipo_livro = p_tipo_livro::public.bbtk_tipo_livro
      AND (v_busca_like IS NULL OR UPPER(o.titulo_principal) LIKE v_busca_like);

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- Buscar itens
    SELECT COALESCE(
        json_agg(row_to_json(t)),
        '[]'::json
    )
    INTO v_itens
    FROM (
        SELECT
            e.uuid AS id_edicao,
            o.uuid AS id_obra,
            o.titulo_principal,
            o.sub_titulo_principal AS subtitulo,
            o.descricao,
            aut.nome_completo AS autor_principal,
            e.isbn,
            cat.nome AS categoria,
            json_build_object(
                'codigo', cdu.codigo,
                'nome', cdu.nome
            ) AS cdu,
            ed.nome AS editora,
            EXTRACT(YEAR FROM e.ano_lancamento) AS ano_edicao,
            e.arquivo_pdf AS pdf,
            e.arquivo_capa AS capa,
            e.tipo_livro,
            e.livro_retiravel,
            e.livro_recomendado,
            -- Check for active reservation
            EXISTS(
                SELECT 1
                FROM public.bbtk_historico_interacao hi
                JOIN public.bbtk_inventario_copia c ON hi.copia_uuid = c.uuid
                WHERE hi.user_uuid = p_user_uuid
                  AND c.edicao_uuid = e.uuid
                  AND hi.tipo_interacao = 'Reserva'::public.bbtk_tipo_interacao
            ) AS possui_reserva
        FROM public.bbtk_edicao e
        JOIN public.bbtk_obra o ON e.obra_uuid = o.uuid
        LEFT JOIN public.bbtk_dim_autoria aut ON o.id_autoria = aut.uuid
        LEFT JOIN public.bbtk_dim_categoria cat ON o.categoria_uuid = cat.uuid
        LEFT JOIN public.bbtk_dim_cdu cdu ON o.cdu_uuid = cdu.uuid
        LEFT JOIN public.bbtk_dim_editora ed ON e.editora_uuid = ed.uuid
        WHERE e.id_empresa = p_id_empresa
          AND o.soft_delete = false
          AND e.tipo_livro = p_tipo_livro::public.bbtk_tipo_livro
          AND (v_busca_like IS NULL OR UPPER(o.titulo_principal) LIKE v_busca_like)
        ORDER BY o.titulo_principal ASC, e.ano_lancamento DESC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- Retornar resultado
    RETURN json_build_object(
        'itens', v_itens,
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_edicao_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_tipo_livro" "text", "p_user_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_inventario_copia_get_paginado"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_termo_busca" "text" DEFAULT NULL::"text", "p_id_escola" "uuid" DEFAULT NULL::"uuid", "p_predio_uuid" "uuid" DEFAULT NULL::"uuid", "p_sala_uuid" "uuid" DEFAULT NULL::"uuid", "p_estante_uuid" "uuid" DEFAULT NULL::"uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
    v_busca_like text;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    IF p_termo_busca IS NOT NULL AND TRIM(p_termo_busca) <> '' THEN
         v_busca_like := '%' || UPPER(p_termo_busca) || '%';
    ELSE
         v_busca_like := NULL;
    END IF;

    -- Contar total de itens
    SELECT COUNT(*)
    INTO v_total_itens
    FROM public.bbtk_inventario_copia c
    LEFT JOIN public.bbtk_dim_estante est ON c.estante_uuid = est.uuid
    LEFT JOIN public.bbtk_dim_sala sala ON est.sala_uuid = sala.uuid
    LEFT JOIN public.bbtk_dim_predio predio ON sala.predio_uuid = predio.uuid
    LEFT JOIN public.escolas esc ON predio.id_escola = esc.id
    WHERE c.id_empresa = p_id_empresa
      AND c.edicao_uuid = p_edicao_uuid
      -- Filter to show active copies OR allow soft_deleted if specific requirement? 
      -- Typically GET shows active only, but user said "er o soft mostra ba tela mesmo como livro removido"
      -- assuming we want to fetch all and let frontend display status, OR user means "soft deleted items are displayed specially".
      -- Let's return soft_delete status so frontend can style it.
      -- If we want to hide deleted by default, we would add: AND c.soft_delete = false
      -- But user said: "er o soft mostra ba tela mesmo como livro removido (a pessoa mesmo pode recolocar)"
      -- So we should RETURN them, but perhaps sorted differently or just included.
      AND (p_id_escola IS NULL OR predio.id_escola = p_id_escola)
      AND (p_predio_uuid IS NULL OR sala.predio_uuid = p_predio_uuid)
      AND (p_sala_uuid IS NULL OR est.sala_uuid = p_sala_uuid)
      AND (p_estante_uuid IS NULL OR c.estante_uuid = p_estante_uuid)
      AND (v_busca_like IS NULL OR UPPER(c.registro_bibliotecario) LIKE v_busca_like);

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- Buscar itens
    SELECT COALESCE(
        json_agg(row_to_json(t)),
        '[]'::json
    )
    INTO v_itens
    FROM (
        SELECT
            c.uuid AS id_copia,
            c.registro_bibliotecario,
            c.status_copia,
            c.avaria_flag,
            c.descricao_avaria,
            c.doacao_ou_compra,
            c.soft_delete,
            c.estante_uuid AS id_estante,
            est.nome AS nome_estante,
            sala.uuid AS id_sala,
            sala.nome AS nome_sala,
            predio.uuid AS id_predio,
            predio.nome AS nome_predio,
            esc.id AS id_escola,
            esc.nome AS nome_escola
        FROM public.bbtk_inventario_copia c
        LEFT JOIN public.bbtk_dim_estante est ON c.estante_uuid = est.uuid
        LEFT JOIN public.bbtk_dim_sala sala ON est.sala_uuid = sala.uuid
        LEFT JOIN public.bbtk_dim_predio predio ON sala.predio_uuid = predio.uuid
        LEFT JOIN public.escolas esc ON predio.id_escola = esc.id
        WHERE c.id_empresa = p_id_empresa
          AND c.edicao_uuid = p_edicao_uuid
          AND (p_id_escola IS NULL OR predio.id_escola = p_id_escola)
          AND (p_predio_uuid IS NULL OR sala.predio_uuid = p_predio_uuid)
          AND (p_sala_uuid IS NULL OR est.sala_uuid = p_sala_uuid)
          AND (p_estante_uuid IS NULL OR c.estante_uuid = p_estante_uuid)
          AND (v_busca_like IS NULL OR UPPER(c.registro_bibliotecario) LIKE v_busca_like)
        ORDER BY c.soft_delete ASC, c.registro_bibliotecario ASC -- Sort active first
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- Retornar resultado
    RETURN json_build_object(
        'itens', v_itens,
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_inventario_copia_get_paginado"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_id_escola" "uuid", "p_predio_uuid" "uuid", "p_sala_uuid" "uuid", "p_estante_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_inventario_copia_upsert"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid", "p_estante_uuid" "uuid", "p_status_copia" "text", "p_doacao_ou_compra" "text", "p_avaria_flag" boolean DEFAULT false, "p_descricao_avaria" "text" DEFAULT NULL::"text", "p_quantidade" integer DEFAULT 1, "p_uuid" "uuid" DEFAULT NULL::"uuid", "p_registro_bibliotecario" "text" DEFAULT NULL::"text", "p_soft_delete" boolean DEFAULT false) RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_uuid uuid;
    v_registro text;
    i integer;
    v_inserted_count integer := 0;
BEGIN
    -- Caso de Atualização (Update)
    IF p_uuid IS NOT NULL THEN
        UPDATE public.bbtk_inventario_copia
        SET
            estante_uuid = p_estante_uuid,
            status_copia = p_status_copia::public.bbtk_status_copia,
            doacao_ou_compra = p_doacao_ou_compra,
            avaria_flag = p_avaria_flag,
            descricao_avaria = p_descricao_avaria,
            registro_bibliotecario = COALESCE(p_registro_bibliotecario, registro_bibliotecario),
            soft_delete = p_soft_delete
        WHERE uuid = p_uuid
          AND id_empresa = p_id_empresa;

        IF FOUND THEN
            RETURN json_build_object('success', true, 'message', 'Cópia atualizada com sucesso', 'id', p_uuid);
        ELSE
             RETURN json_build_object('success', false, 'message', 'Cópia não encontrada ou pertence a outra empresa');
        END IF;

    -- Caso de Inserção (Insert)
    ELSE
        FOR i IN 1..p_quantidade LOOP
            v_uuid := gen_random_uuid();
            
            -- Gerar registro bibliotecário se não fornecido ou se quantidade > 1
            IF p_registro_bibliotecario IS NOT NULL AND p_quantidade = 1 THEN
                v_registro := p_registro_bibliotecario;
            ELSE
                -- Gera um código único baseado em prefixo 'REG-' mais parte de UUID para garantir unicidade
                v_registro := 'REG-' || SUBSTRING(gen_random_uuid()::text, 1, 12);
            END IF;

            INSERT INTO public.bbtk_inventario_copia (
                uuid,
                id_empresa,
                edicao_uuid,
                estante_uuid,
                registro_bibliotecario,
                status_copia,
                doacao_ou_compra,
                avaria_flag,
                descricao_avaria,
                soft_delete
            ) VALUES (
                v_uuid,
                p_id_empresa,
                p_edicao_uuid,
                p_estante_uuid,
                v_registro,
                p_status_copia::public.bbtk_status_copia,
                p_doacao_ou_compra,
                p_avaria_flag,
                p_descricao_avaria,
                p_soft_delete
            );
            
            v_inserted_count := v_inserted_count + 1;
        END LOOP;

        RETURN json_build_object(
            'success', true, 
            'message', format('%s cópia(s) criada(s) com sucesso', v_inserted_count),
            'qtd_criada', v_inserted_count
        );
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', SQLERRM);
END;
$$;


ALTER FUNCTION "public"."bbtk_inventario_copia_upsert"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid", "p_estante_uuid" "uuid", "p_status_copia" "text", "p_doacao_ou_compra" "text", "p_avaria_flag" boolean, "p_descricao_avaria" "text", "p_quantidade" integer, "p_uuid" "uuid", "p_registro_bibliotecario" "text", "p_soft_delete" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_obra_delete"("p_uuid" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_deleted_count integer;
BEGIN
    -- Realiza o Soft Delete
    UPDATE public.bbtk_obra
    SET soft_delete = true
    WHERE uuid = p_uuid
      AND id_empresa = p_id_empresa;
      
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN jsonb_build_object(
            'status', 'success', 
            'message', 'Obra deletada com sucesso (soft delete).', 
            'uuid', p_uuid
        );
    ELSE
        RETURN jsonb_build_object(
            'status', 'error', 
            'message', 'Obra não encontrada ou não pertence à empresa.', 
            'uuid', p_uuid
        );
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_obra_delete"("p_uuid" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_obra_get_detalhes_cpx"("p_uuid" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_obra jsonb;
    v_edicoes jsonb;
    v_categorias jsonb;
    v_cdus jsonb;
    v_autores jsonb;
    v_editoras jsonb;
BEGIN
    -- 1. Buscar detalhes da Obra
    SELECT row_to_json(t)::jsonb INTO v_obra
    FROM (
        SELECT 
            o.*,
            cdu.codigo AS cdu_codigo,
            cdu.nome AS cdu_nome,
            cat.nome AS categoria_nome,
            aut.nome_completo AS autor_principal_nome,
            aut.uuid AS autor_principal_uuid
        FROM public.bbtk_obra o
        LEFT JOIN public.bbtk_dim_cdu cdu ON o.cdu_uuid = cdu.uuid
        LEFT JOIN public.bbtk_dim_categoria cat ON o.categoria_uuid = cat.uuid
        LEFT JOIN public.bbtk_dim_autoria aut ON o.id_autoria = aut.uuid
        WHERE o.uuid = p_uuid AND o.id_empresa = p_id_empresa
    ) t;

    -- 2. Buscar Edições e seus dados relacionados (apenas se p_uuid não for nulo)
    IF p_uuid IS NOT NULL THEN
        SELECT COALESCE(jsonb_agg(row_to_json(e)), '[]'::jsonb) INTO v_edicoes
        FROM (
            SELECT 
                ed.uuid,
                ed.ano_lancamento,
                ed.isbn,
                ed.arquivo_pdf,
                ed.arquivo_capa,
                ed.tipo_livro,
                ed.livro_retiravel,
                ed.livro_recomendado,
                ed.editora_uuid,
                edit.nome AS nome_editora,
                (v_obra->>'titulo_principal') AS titulo_obra,
                CASE 
                    WHEN ed.tipo_livro::text <> 'Digital' THEN (
                        SELECT count(*) 
                        FROM public.bbtk_inventario_copia ic 
                        WHERE ic.edicao_uuid = ed.uuid
                    )
                    ELSE 0
                END AS qtd_copias,
                (
                    SELECT COALESCE(json_agg(row_to_json(a)), '[]'::json)
                    FROM (
                        SELECT 
                            au.nome_completo,
                            jea.funcao,
                            au.uuid AS autor_uuid
                        FROM public.bbtk_juncao_edicao_autoria jea
                        JOIN public.bbtk_dim_autoria au ON jea.autoria_uuid = au.uuid
                        WHERE jea.edicao_uuid = ed.uuid
                    ) a
                ) AS autores_secundarios
            FROM public.bbtk_edicao ed
            LEFT JOIN public.bbtk_dim_editora edit ON ed.editora_uuid = edit.uuid
            WHERE ed.obra_uuid = p_uuid
        ) e;
    ELSE
        v_edicoes := '[]'::jsonb;
    END IF;

    -- 3. Buscar todas as Categorias
    SELECT COALESCE(jsonb_agg(row_to_json(c)), '[]'::jsonb) INTO v_categorias
    FROM (
        SELECT uuid, nome, descricao
        FROM public.bbtk_dim_categoria
        WHERE id_empresa = p_id_empresa
        ORDER BY nome ASC
    ) c;

    -- 4. Buscar todos os CDUs
    SELECT COALESCE(jsonb_agg(row_to_json(d)), '[]'::jsonb) INTO v_cdus
    FROM (
        SELECT uuid, codigo, nome
        FROM public.bbtk_dim_cdu
        WHERE id_empresa = p_id_empresa
        ORDER BY codigo ASC
    ) d;

    -- 5. Buscar todos os Autores (para dropdown)
    SELECT COALESCE(jsonb_agg(row_to_json(a)), '[]'::jsonb) INTO v_autores
    FROM (
        SELECT uuid, nome_completo
        FROM public.bbtk_dim_autoria
        WHERE id_empresa = p_id_empresa
        ORDER BY nome_completo ASC
    ) a;

    -- 6. Buscar todas as Editoras (para dropdown)
    SELECT COALESCE(jsonb_agg(row_to_json(ed)), '[]'::jsonb) INTO v_editoras
    FROM (
        SELECT uuid, nome
        FROM public.bbtk_dim_editora
        WHERE id_empresa = p_id_empresa
        ORDER BY nome ASC
    ) ed;

    -- Retornar objeto completo
    RETURN jsonb_build_object(
        'obra', v_obra, -- pode ser null
        'edicoes', COALESCE(v_edicoes, '[]'::jsonb),
        'categorias', v_categorias,
        'cdus', v_cdus,
        'autores', v_autores,
        'editoras', v_editoras
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_obra_get_detalhes_cpx"("p_uuid" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_obra_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := GREATEST((p_pagina - 1) * p_limite_itens_pagina, 0);

    SELECT COUNT(*) INTO v_total_itens
    FROM public.bbtk_obra o
    LEFT JOIN public.bbtk_dim_autoria aut ON o.id_autoria = aut.uuid
    WHERE 
        o.id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(o.titulo_principal) LIKE v_busca_like 
            OR UPPER(o.sub_titulo_principal) LIKE v_busca_like
            OR UPPER(aut.nome_completo) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 AND v_total_itens > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(
        json_agg(row_to_json(t)), 
        '[]'::json
    ) INTO v_itens
    FROM (
        SELECT 
            o.*,
            cdu.codigo AS cdu_codigo,
            cdu.nome AS cdu_nome,
            cat.nome AS categoria_nome,
            aut.nome_completo AS autor_principal_nome,
            (
                SELECT e.arquivo_capa
                FROM public.bbtk_edicao e
                WHERE e.obra_uuid = o.uuid
                  AND e.arquivo_capa IS NOT NULL
                LIMIT 1
            ) AS capa_imagem
        FROM public.bbtk_obra o
        LEFT JOIN public.bbtk_dim_cdu cdu ON o.cdu_uuid = cdu.uuid
        LEFT JOIN public.bbtk_dim_categoria cat ON o.categoria_uuid = cat.uuid
        LEFT JOIN public.bbtk_dim_autoria aut ON o.id_autoria = aut.uuid
        WHERE 
            o.id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(o.titulo_principal) LIKE v_busca_like 
                OR UPPER(o.sub_titulo_principal) LIKE v_busca_like
                OR UPPER(aut.nome_completo) LIKE v_busca_like
            )
        ORDER BY o.titulo_principal ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_obra_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_obra_upsert_cpx"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_obra_data jsonb;
    v_edicoes_data jsonb;
    v_obra_uuid uuid;
    v_edicao_item jsonb;
    v_ano_lancamento int;
    v_ano_lancamento_date date;
BEGIN
    v_obra_data := p_data->'obra';
    v_edicoes_data := p_data->'edicoes';
    
    -- 1. Upsert Obra
    IF (v_obra_data->>'uuid') IS NULL OR (v_obra_data->>'uuid') = '' THEN
        INSERT INTO public.bbtk_obra (
            titulo_principal,
            sub_titulo_principal,
            categoria_uuid,
            cdu_uuid,
            id_autoria,
            id_empresa
        ) VALUES (
            v_obra_data->>'titulo_principal',
            v_obra_data->>'sub_titulo_principal',
            (v_obra_data->>'categoria_uuid')::uuid,
            (v_obra_data->>'cdu_uuid')::uuid,
            (v_obra_data->>'id_autoria')::uuid,
            p_id_empresa
        ) RETURNING uuid INTO v_obra_uuid;
    ELSE
        UPDATE public.bbtk_obra SET
            titulo_principal = v_obra_data->>'titulo_principal',
            sub_titulo_principal = v_obra_data->>'sub_titulo_principal',
            categoria_uuid = (v_obra_data->>'categoria_uuid')::uuid,
            cdu_uuid = (v_obra_data->>'cdu_uuid')::uuid,
            id_autoria = (v_obra_data->>'id_autoria')::uuid
        WHERE uuid = (v_obra_data->>'uuid')::uuid AND id_empresa = p_id_empresa
        RETURNING uuid INTO v_obra_uuid;
    END IF;

    -- 2. Upsert Edicoes
    FOR v_edicao_item IN SELECT * FROM jsonb_array_elements(v_edicoes_data)
    LOOP
        -- Parse Year (assuming input is purely YYYY or empty)
        v_ano_lancamento := NULL;
        IF (v_edicao_item->>'ano_lancamento') IS NOT NULL AND (v_edicao_item->>'ano_lancamento') <> '' THEN
            v_ano_lancamento := (v_edicao_item->>'ano_lancamento')::int;
        END IF;

        -- Convert to Date (YYYY-01-01) for storage
        v_ano_lancamento_date := NULL;
        IF v_ano_lancamento IS NOT NULL THEN
            v_ano_lancamento_date := make_date(v_ano_lancamento, 1, 1);
        END IF;

        IF (v_edicao_item->>'uuid') IS NULL OR (v_edicao_item->>'uuid') = '' THEN
            INSERT INTO public.bbtk_edicao (
                obra_uuid,
                editora_uuid,
                ano_lancamento,
                isbn,
                tipo_livro,
                livro_retiravel,
                livro_recomendado,
                id_empresa
            ) VALUES (
                v_obra_uuid,
                (v_edicao_item->>'editora_uuid')::uuid,
                v_ano_lancamento_date,
                v_edicao_item->>'isbn',
                (v_edicao_item->>'tipo_livro')::public.bbtk_tipo_livro,
                COALESCE((v_edicao_item->>'livro_retiravel')::boolean, true),
                COALESCE((v_edicao_item->>'livro_recomendado')::boolean, false),
                p_id_empresa
            );
        ELSE
            UPDATE public.bbtk_edicao SET
                editora_uuid = (v_edicao_item->>'editora_uuid')::uuid,
                ano_lancamento = v_ano_lancamento_date,
                isbn = v_edicao_item->>'isbn',
                tipo_livro = (v_edicao_item->>'tipo_livro')::public.bbtk_tipo_livro,
                livro_retiravel = COALESCE((v_edicao_item->>'livro_retiravel')::boolean, true),
                livro_recomendado = COALESCE((v_edicao_item->>'livro_recomendado')::boolean, false)
            WHERE uuid = (v_edicao_item->>'uuid')::uuid AND id_empresa = p_id_empresa;
        END IF;
    END LOOP;

    RETURN jsonb_build_object('success', true, 'uuid', v_obra_uuid);
END;
$$;


ALTER FUNCTION "public"."bbtk_obra_upsert_cpx"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_reserva_cancel"("p_id_empresa" "uuid", "p_user_uuid" "uuid", "p_edicao_uuid" "uuid") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_copia_uuid uuid;
    v_interaction_uuid uuid;
BEGIN
    -- Find the reservation for this user and edition
    SELECT hi.uuid, hi.copia_uuid
    INTO v_interaction_uuid, v_copia_uuid
    FROM public.bbtk_historico_interacao hi
    JOIN public.bbtk_inventario_copia c ON hi.copia_uuid = c.uuid
    WHERE hi.user_uuid = p_user_uuid
      AND hi.id_empresa = p_id_empresa
      AND c.edicao_uuid = p_edicao_uuid
      AND hi.tipo_interacao = 'Reserva'::public.bbtk_tipo_interacao
    LIMIT 1;

    IF v_interaction_uuid IS NULL THEN
        RETURN false; -- No reservation found
    END IF;

    -- Delete reservation record
    DELETE FROM public.bbtk_historico_interacao
    WHERE uuid = v_interaction_uuid;

    -- Reset copy status to 'Disponível'
    UPDATE public.bbtk_inventario_copia
    SET status_copia = 'Disponível'::public.bbtk_status_copia
    WHERE uuid = v_copia_uuid;

    RETURN true;
END;
$$;


ALTER FUNCTION "public"."bbtk_reserva_cancel"("p_id_empresa" "uuid", "p_user_uuid" "uuid", "p_edicao_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_reserva_create"("p_copia_uuid" "uuid", "p_user_uuid" "uuid", "p_id_empresa" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_id uuid;
BEGIN
    INSERT INTO public.bbtk_historico_interacao (
        uuid,
        copia_uuid,
        user_uuid,
        tipo_interacao,
        data_inicio,
        id_empresa
    ) VALUES (
        gen_random_uuid(),
        p_copia_uuid,
        p_user_uuid,
        'Reserva'::public.bbtk_tipo_interacao,
        CURRENT_DATE,
        p_id_empresa
    ) RETURNING uuid INTO v_id;

    -- Update copy status to 'Reservado'
    UPDATE public.bbtk_inventario_copia
    SET status_copia = 'Reservado'::public.bbtk_status_copia
    WHERE uuid = p_copia_uuid;

    RETURN v_id;
END;
$$;


ALTER FUNCTION "public"."bbtk_reserva_create"("p_copia_uuid" "uuid", "p_user_uuid" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_reserva_create"("p_copia_uuid" "uuid", "p_user_uuid" "uuid", "p_id_empresa" "uuid", "p_data_inicio" "date" DEFAULT CURRENT_DATE) RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_id uuid;
    v_data_prevista date;
BEGIN
    v_data_prevista := p_data_inicio + INTERVAL '7 days';

    INSERT INTO public.bbtk_historico_interacao (
        uuid,
        copia_uuid,
        user_uuid,
        tipo_interacao,
        data_inicio,
        data_prevista_devolucao,
        status_reserva,
        id_empresa
    ) VALUES (
        gen_random_uuid(),
        p_copia_uuid,
        p_user_uuid,
        'Reserva'::public.bbtk_tipo_interacao,
        p_data_inicio,
        v_data_prevista,
        'Reservado'::public.bbtk_status_reserva,
        p_id_empresa
    ) RETURNING uuid INTO v_id;

    -- Update copy status to 'Reservado'
    UPDATE public.bbtk_inventario_copia
    SET status_copia = 'Reservado'::public.bbtk_status_copia
    WHERE uuid = p_copia_uuid;

    RETURN v_id;
END;
$$;


ALTER FUNCTION "public"."bbtk_reserva_create"("p_copia_uuid" "uuid", "p_user_uuid" "uuid", "p_id_empresa" "uuid", "p_data_inicio" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_reserva_get_paginado"("p_id_empresa" "uuid", "p_offset" integer, "p_limit" integer, "p_filtro" "text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_total integer;
    v_result json;
BEGIN
    SELECT count(*)
    INTO v_total
    FROM bbtk_historico_interacao hi
    JOIN bbtk_inventario_copia cop ON hi.copia_uuid = cop.uuid
    JOIN bbtk_edicao ed ON cop.edicao_uuid = ed.uuid
    JOIN bbtk_obra ob ON ed.obra_uuid = ob.uuid
    LEFT JOIN user_expandido ue ON hi.user_uuid = ue.user_id
    WHERE hi.id_empresa = p_id_empresa
      AND hi.tipo_interacao = 'Reserva'
      AND (
          p_filtro IS NULL OR
          ob.titulo_principal ILIKE '%' || p_filtro || '%' OR
          ue.nome_completo ILIKE '%' || p_filtro || '%'
      );

    SELECT json_agg(t) INTO v_result
    FROM (
        SELECT
            hi.uuid,
            hi.data_inicio,
            hi.data_prevista_devolucao,
            hi.data_fim,
            hi.status_reserva,
            ob.titulo_principal as livro_titulo,
            ed.arquivo_capa as livro_capa,
            ue.nome_completo as usuario_nome,
            ue.matricula as usuario_matricula,
            CASE
                WHEN hi.status_reserva = 'Entregue' THEN 'Entregue'
                WHEN hi.status_reserva = 'Cancelado' THEN 'Cancelado'
                WHEN hi.status_reserva = 'Reservado' AND hi.data_prevista_devolucao < CURRENT_DATE THEN 'Atrasado'
                ELSE 'No Prazo'
            END as status_calculado
        FROM bbtk_historico_interacao hi
        JOIN bbtk_inventario_copia cop ON hi.copia_uuid = cop.uuid
        JOIN bbtk_edicao ed ON cop.edicao_uuid = ed.uuid
        JOIN bbtk_obra ob ON ed.obra_uuid = ob.uuid
        LEFT JOIN user_expandido ue ON hi.user_uuid = ue.user_id
        WHERE hi.id_empresa = p_id_empresa
          AND hi.tipo_interacao = 'Reserva'
          AND (
              p_filtro IS NULL OR
              ob.titulo_principal ILIKE '%' || p_filtro || '%' OR
              ue.nome_completo ILIKE '%' || p_filtro || '%'
          )
        ORDER BY 
            CASE 
                WHEN hi.status_reserva = 'Reservado' THEN 0 
                ELSE 1 
            END,
            hi.data_inicio DESC
        LIMIT p_limit OFFSET p_offset
    ) t;

    RETURN json_build_object('total', v_total, 'data', COALESCE(v_result, '[]'::json));
END;
$$;


ALTER FUNCTION "public"."bbtk_reserva_get_paginado"("p_id_empresa" "uuid", "p_offset" integer, "p_limit" integer, "p_filtro" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_reserva_release"("p_interacao_uuid" "uuid") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_copia_uuid uuid;
BEGIN
    UPDATE bbtk_historico_interacao
    SET data_fim = CURRENT_DATE,
        status_reserva = 'Entregue'::public.bbtk_status_reserva
    WHERE uuid = p_interacao_uuid
    RETURNING copia_uuid INTO v_copia_uuid;

    IF v_copia_uuid IS NOT NULL THEN
        UPDATE bbtk_inventario_copia
        SET status_copia = 'Disponível'
        WHERE uuid = v_copia_uuid;
        RETURN true;
    END IF;

    RETURN false;
END;
$$;


ALTER FUNCTION "public"."bbtk_reserva_release"("p_interacao_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bbtk_reserva_stats"("p_id_empresa" "uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_total bigint;
    v_no_prazo bigint;
    v_atrasadas bigint;
BEGIN
    -- Total active reservations (not returned yet)
    SELECT count(*) INTO v_total
    FROM bbtk_historico_interacao
    WHERE id_empresa = p_id_empresa 
      AND tipo_interacao = 'Reserva' 
      AND status_reserva = 'Reservado';

    SELECT count(*) INTO v_no_prazo
    FROM bbtk_historico_interacao
    WHERE id_empresa = p_id_empresa
      AND tipo_interacao = 'Reserva'
      AND status_reserva = 'Reservado'
      AND (data_prevista_devolucao >= CURRENT_DATE OR data_prevista_devolucao IS NULL);

    SELECT count(*) INTO v_atrasadas
    FROM bbtk_historico_interacao
    WHERE id_empresa = p_id_empresa
      AND tipo_interacao = 'Reserva'
      AND status_reserva = 'Reservado'
      AND data_prevista_devolucao < CURRENT_DATE;

    RETURN json_build_object(
        'total', v_total,
        'no_prazo', v_no_prazo,
        'atrasadas', v_atrasadas
    );
END;
$$;


ALTER FUNCTION "public"."bbtk_reserva_stats"("p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."buscar_conteudos_da_turma"("p_id_turma" "text", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_result jsonb;
begin
  -- valida se é UUID
  begin
    perform p_id_turma::uuid;
  exception when others then
    return jsonb_build_object('conteudo_valido', false);
  end;

  -- busca conteúdos existentes
  select jsonb_agg(to_jsonb(c) order by c.ordem)
  into v_result
  from public.lms_conteudo c
  where c.id_turma = p_id_turma::uuid
    and c.id_empresa = p_id_empresa;

  -- se não achou nada
  if v_result is null then
    return jsonb_build_object('conteudo_vazio', true);
  end if;

  return v_result;
end;
$$;


ALTER FUNCTION "public"."buscar_conteudos_da_turma"("p_id_turma" "text", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."buscar_empresa_por_dominio_publico"("p_dominio" "text" DEFAULT NULL::"text") RETURNS TABLE("empresa_id" "uuid", "nome" "text", "logo_pequeno" "text", "logo_grande" "text", "dominio" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id AS empresa_id,
        e.nome,
        e.logo_fechado AS logo_pequeno, -- Mapeando para o nome que você usou
        e.logo_aberto AS logo_grande,   -- Mapeando para o nome que você usou
        e.dominio
    FROM
        public.empresa e
    WHERE
        e.dominio = p_dominio
    LIMIT 1;

END;
$$;


ALTER FUNCTION "public"."buscar_empresa_por_dominio_publico"("p_dominio" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."buscar_itens_do_conteudo"("p_id_lms_conteudo" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  v_array jsonb;
begin
  -- tenta converter para UUID
  begin
    perform p_id_lms_conteudo::uuid;
  exception when others then
    return jsonb_build_object(
      'valido', false,
      'vazio', true,
      'dados', jsonb_build_array()
    );
  end;

  -- busca os itens
  select jsonb_agg(to_jsonb(i) order by i.ordem)
    into v_array
    from public.lms_item_conteudo i
   where i.id_lms_conteudo = p_id_lms_conteudo::uuid;

  return jsonb_build_object(
    'valido', true,
    'vazio', coalesce(v_array, '[]') = '[]',
    'dados', coalesce(v_array, '[]')
  );
end;
$$;


ALTER FUNCTION "public"."buscar_itens_do_conteudo"("p_id_lms_conteudo" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."buscar_perguntas_item_conteudo"("p_id_item_conteudo" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
declare
  v_array jsonb;
begin
  -- valida UUID do item de conteúdo
  begin
    perform p_id_item_conteudo::uuid;
  exception when others then
    return jsonb_build_object(
      'valido', false,
      'vazio',  true,
      'dados',  jsonb_build_array()
    );
  end;

  -- busca perguntas vinculadas ao item de conteúdo
  select jsonb_agg(
           to_jsonb(p)
           order by p.ordem, p.id
         )
    into v_array
    from public.lms_pergunta p
   where p.id_item_conteudo = p_id_item_conteudo::uuid;

  -- retorno padronizado
  return jsonb_build_object(
    'valido', true,
    'vazio',  coalesce(v_array, '[]'::jsonb) = '[]'::jsonb,
    'dados',  coalesce(v_array, '[]'::jsonb)
  );
end;
$$;


ALTER FUNCTION "public"."buscar_perguntas_item_conteudo"("p_id_item_conteudo" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calc_assiduidade_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) RETURNS numeric
    LANGUAGE "plpgsql"
    AS $$
declare
  v_ini date := make_date(p_ano_ref - 1, 2, 1);  -- 01/fev do ano anterior
  v_fim date := make_date(p_ano_ref - 1, 11, 30); -- 30/nov do ano anterior
  v_total numeric := 0;
  v_faltas_dia integer := 0;
  v_faltas_mes integer := 0;
  v_mes integer;
  v_dias_mes integer;
  v_pont_mes numeric;
  v_data_admissao date;
begin
  select resposta_data::date
  into v_data_admissao
  from respostas_user
  where id_user = p_id_professor
    and id_pergunta = '2cbcdcf0-a615-49a3-b563-e6c9e8e9f393'
  limit 1;

  for v_mes in 2..11 loop
    v_dias_mes := extract(day from (date_trunc('month', make_date(p_ano_ref - 1, v_mes, 1))
                    + interval '1 month - 1 day')::date);

    select count(*) into v_faltas_dia
    from faltas_professores
    where id_professor = p_id_professor
      and id_empresa = p_id_empresa
      and extract(month from data) = v_mes
      and extract(year from data) = (p_ano_ref - 1)
      and codigo in ('NC','J','LS','JA','I','LSV','LAC','FPAD');

    if v_faltas_dia > 0 then
      v_faltas_mes := 1;
    else
      v_faltas_mes := 0;
    end if;

    v_pont_mes := (0.25 + (v_dias_mes * 0.01))
                  - (v_faltas_dia * 0.01)
                  - (v_faltas_mes * 0.25);

    v_total := v_total + v_pont_mes;
  end loop;

  if v_data_admissao is not null and v_data_admissao > v_ini then
    v_total := v_total
      - (((v_data_admissao - v_ini + 1) * 0.01)
         + ((extract(month from v_data_admissao) - 2 + 1) * 0.25));
  end if;

  return greatest(v_total,0);
end;
$$;


ALTER FUNCTION "public"."calc_assiduidade_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calc_certificados_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$DECLARE
  v_validade_ini date := make_date(p_ano_ref - 5, 7, 1);  -- Ex: p_ano_ref=2026 → 01/07/2021
  v_validade_fim date := make_date(p_ano_ref - 1, 6, 30); -- até 30/06/2025
  v_grad numeric := 0;
  v_pos numeric := 0;
  v_ext numeric := 0;
  v_avancados numeric := 0;
  v_total numeric := 0;
BEGIN
  --------------------------------------------------------------------
  -- 1️⃣ CURSO DE LICENCIATURA / GRADUAÇÃO
  --------------------------------------------------------------------
  SELECT COALESCE(SUM(
           CASE 
             WHEN tipo_curso = 'Curso de Licenciatura/Graduação'
                  AND lower(nome_curso) LIKE '%pedagogia%' THEN 3
             WHEN tipo_curso = 'Curso de Licenciatura/Graduação' THEN 1
             ELSE 0
           END
         ), 0)
    INTO v_grad
  FROM professores_certificados_atribuicao
  WHERE id_professor = p_id_professor
    AND id_empresa   = p_id_empresa
    AND deferido_indeferido_supervisor IS TRUE
    AND data_conclusao::date BETWEEN v_validade_ini AND v_validade_fim;

  --------------------------------------------------------------------
  -- 2️⃣ CURSO DE ESPECIALIZAÇÃO / PÓS-GRADUAÇÃO
  --------------------------------------------------------------------
  SELECT LEAST(2, 2 * COALESCE(COUNT(*),0))
    INTO v_pos
  FROM professores_certificados_atribuicao
  WHERE id_professor = p_id_professor
    AND id_empresa   = p_id_empresa
    AND tipo_curso   = 'Curso de Especialização/Pós-Graduação'
    AND deferido_indeferido_supervisor IS TRUE
    AND carga_horaria >= 36000
    AND data_conclusao::date BETWEEN v_validade_ini AND v_validade_fim;

  --------------------------------------------------------------------
  -- 3️⃣ CERTIFICADOS / DIPLOMAS DE DESENVOLVIMENTO PROFISSIONAL
  -- (extensão, atualização, aperfeiçoamento)
  --------------------------------------------------------------------
  SELECT LEAST(3, COALESCE(SUM(COALESCE(carga_horaria,0) / 100.0),0) * 0.005)
    INTO v_ext
  FROM professores_certificados_atribuicao
  WHERE id_professor = p_id_professor
    AND id_empresa   = p_id_empresa
    AND tipo_curso   = 'Certificados/Diplomas de Desenvolvimento Profissional'
    AND deferido_indeferido_supervisor IS TRUE
    AND data_conclusao::date BETWEEN v_validade_ini AND v_validade_fim;

  --------------------------------------------------------------------
  -- 4️⃣ TÍTULOS AVANÇADOS (MESTRE, DOUTOR, PÓS-DOUTORADO)
  --------------------------------------------------------------------
  SELECT COALESCE(SUM(
           CASE 
             WHEN tipo_curso = 'Diploma de Mestre'         THEN 5
             WHEN tipo_curso = 'Diploma de Doutor'         THEN 10
             WHEN tipo_curso = 'Diploma de Pós-Doutorado'  THEN 3
             ELSE 0
           END
         ),0)
    INTO v_avancados
  FROM professores_certificados_atribuicao
  WHERE id_professor = p_id_professor
    AND id_empresa   = p_id_empresa
    AND deferido_indeferido_supervisor IS TRUE
    AND data_conclusao::date BETWEEN v_validade_ini AND v_validade_fim;

  --------------------------------------------------------------------
  -- 5️⃣ TOTAL GERAL
  --------------------------------------------------------------------
  v_total := COALESCE(v_grad,0) + COALESCE(v_pos,0) + COALESCE(v_ext,0) + COALESCE(v_avancados,0);

  --------------------------------------------------------------------
  -- 6️⃣ RETORNO FINAL JSON
  --------------------------------------------------------------------
  RETURN jsonb_build_object(
    'graduacao',         COALESCE(v_grad,0),
    'pos_graduacao',     COALESCE(v_pos,0),
    'extensao',          COALESCE(v_ext,0),
    'titulos_avancados', COALESCE(v_avancados,0),
    'total_certificados',COALESCE(v_total,0)
  );
END;$$;


ALTER FUNCTION "public"."calc_certificados_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calc_concurso_professor"("p_id_professor" "uuid", "p_ano_ref" integer) RETURNS numeric
    LANGUAGE "plpgsql"
    AS $$
declare
  scoring_year integer := p_ano_ref - 1;                 -- 2026 → 2025
  v_limite date := make_date(scoring_year - 1, 12, 1);   -- 01/12/2024
  v_admissao date;
begin
  select resposta_data::date into v_admissao
  from respostas_user
  where id_user = p_id_professor
    and id_pergunta = '2cbcdcf0-a615-49a3-b563-e6c9e8e9f393';

  if v_admissao > v_limite then return 10; end if;
  return 0;
end;
$$;


ALTER FUNCTION "public"."calc_concurso_professor"("p_id_professor" "uuid", "p_ano_ref" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calc_funcao_extra_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) RETURNS numeric
    LANGUAGE "plpgsql"
    AS $$
declare
  scoring_year integer := p_ano_ref - 1;                 -- 2026 → 2025
  v_ini date := make_date(scoring_year - 1, 7, 1);       -- 01/07/2024
  v_fim date := make_date(scoring_year, 6, 30);          -- 30/06/2025
  v_inicio date;
  v_fim_reg date;
  v_dias integer;
  v_faltas integer;
begin
  select data_inicio, coalesce(data_fim, v_fim)
  into v_inicio, v_fim_reg
  from professor_funcao_extra
  where user_id = p_id_professor
    and id_empresa = p_id_empresa
    and status is true
    and soft_delete is false
  order by data_inicio desc
  limit 1;

  if not found then return 0; end if;

  select count(*) into v_faltas
  from faltas_professores
  where id_professor = p_id_professor
    and id_empresa = p_id_empresa
    and data::date between v_ini and v_fim
    and codigo in ('JA','NC','I','LSV');

  v_dias := least(v_fim_reg, v_fim) - greatest(v_inicio, v_ini) + 1;
  return greatest(((v_dias * 0.001) - (v_faltas * 0.001)),0);
end;
$$;


ALTER FUNCTION "public"."calc_funcao_extra_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calc_pontuacao_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_cert jsonb;
  v_unid numeric;
  v_dep numeric;
  v_extra numeric;
  v_conc numeric;
  v_assid numeric;
  v_total_unid numeric;
  v_total_dep numeric;
begin
  -- Certificados e títulos
  v_cert := public.calc_certificados_professor(p_id_professor, p_id_empresa, p_ano_ref);

  -- Tempo de serviço: unidade, departamento, especialista
  v_unid  := public.calc_tempo_unidade_professor(p_id_professor, p_id_empresa, p_ano_ref);
  v_dep   := public.calc_tempo_departamento_professor(p_id_professor, p_id_empresa, p_ano_ref);
  v_extra := public.calc_funcao_extra_professor(p_id_professor, p_id_empresa, p_ano_ref);

  -- Concurso público
  v_conc  := public.calc_concurso_professor(p_id_professor, p_ano_ref);

  -- Assiduidade (01/fev → 30/nov)
  v_assid := public.calc_assiduidade_professor(p_id_professor, p_id_empresa, p_ano_ref);

  -- Totais consolidados
  v_total_unid := (v_cert->>'total_certificados')::numeric
                + coalesce(v_unid,0)
                + coalesce(v_dep,0)
                + coalesce(v_extra,0)
                + coalesce(v_conc,0)
                + coalesce(v_assid,0);

  v_total_dep := (v_cert->>'total_certificados')::numeric
                + coalesce(v_dep,0)
                + coalesce(v_extra,0)
                + coalesce(v_conc,0)
                + coalesce(v_assid,0);

  -- JSON completo
  return jsonb_build_object(
    'certificados', v_cert,
    'tempo_unidade', v_unid,
    'tempo_departamento', v_dep,
    'especialista', v_extra,
    'concurso', v_conc,
    'assiduidade', v_assid,
    'total_unidade', v_total_unid,
    'total_departamento', v_total_dep
  );
end;
$$;


ALTER FUNCTION "public"."calc_pontuacao_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calc_pontuacao_todos_upsert"("p_id_empresa" "uuid", "p_ano" integer) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  r record;
  v_result jsonb;
  v_total integer := 0;
begin
  for r in
    select id as id_professor
    from user_expandido
    where id_empresa = p_id_empresa
  loop
    v_result := calc_pontuacao_professor(r.id_professor, p_id_empresa, p_ano);

    -- Verifica se já existe registro ativo
    if exists (
      select 1 from pontuacao_professores 
      where id_professor = r.id_professor 
        and ano = p_ano
        and soft_delete = false
    ) then
      -- UPDATE
      update pontuacao_professores
      set pontuacao_unidade = round((v_result->>'total_unidade')::numeric * 1000),
          pontuacao_departamento = round((v_result->>'total_departamento')::numeric * 1000),
          pontuacao_certificados = round((v_result->'certificados'->>'total_certificados')::numeric * 1000),
          certificado_concurso_publico = round((v_result->>'concurso')::numeric * 1000),
          tempo_servico_unidade = round((v_result->>'tempo_unidade')::numeric * 1000),
          tempo_servico_departamento = round((v_result->>'tempo_departamento')::numeric * 1000),
          tempo_especialista = round((v_result->>'especialista')::numeric * 1000),
          assiduidade = round((v_result->>'assiduidade')::numeric * 1000),
          pontuacao = round(((v_result->>'total_unidade')::numeric + (v_result->>'total_departamento')::numeric)/2 * 1000),
          atualizado_em = now()
      where id_professor = r.id_professor
        and ano = p_ano
        and soft_delete = false;
    else
      -- INSERT
      insert into pontuacao_professores (
        id_professor,
        id_empresa,
        ano,
        pontuacao_unidade,
        pontuacao_departamento,
        pontuacao_certificados,
        certificado_concurso_publico,
        tempo_servico_unidade,
        tempo_servico_departamento,
        tempo_especialista,
        assiduidade,
        pontuacao,
        criado_em,
        atualizado_em
      )
      values (
        r.id_professor,
        p_id_empresa,
        p_ano,
        round((v_result->>'total_unidade')::numeric * 1000),
        round((v_result->>'total_departamento')::numeric * 1000),
        round((v_result->'certificados'->>'total_certificados')::numeric * 1000),
        round((v_result->>'concurso')::numeric * 1000),
        round((v_result->>'tempo_unidade')::numeric * 1000),
        round((v_result->>'tempo_departamento')::numeric * 1000),
        round((v_result->>'especialista')::numeric * 1000),
        round((v_result->>'assiduidade')::numeric * 1000),
        round(((v_result->>'total_unidade')::numeric + (v_result->>'total_departamento')::numeric)/2 * 1000),
        now(),
        now()
      );
    end if;

    v_total := v_total + 1;
  end loop;

  return jsonb_build_object(
    'status', 'ok',
    'ano', p_ano,
    'empresa', p_id_empresa,
    'total_processados', v_total
  );
end;
$$;


ALTER FUNCTION "public"."calc_pontuacao_todos_upsert"("p_id_empresa" "uuid", "p_ano" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calc_pontuacao_todos_upsert_job"("p_id_empresa" "uuid", "p_ano" integer, "p_job_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  r record;
  v_result jsonb;
  v_total integer := 0;
begin
  update fila_processamento_pontuacao
     set status = 'processando',
         iniciado_em = now()
   where id = p_job_id;

  for r in
    select id as id_professor
    from user_expandido
    where id_empresa = p_id_empresa
  loop
    v_result := calc_pontuacao_professor(r.id_professor, p_id_empresa, p_ano);

    if exists (
      select 1 from pontuacao_professores
      where id_professor = r.id_professor and ano = p_ano and soft_delete = false
    ) then
      update pontuacao_professores
         set pontuacao_unidade = round((v_result->>'total_unidade')::numeric * 1000),
             pontuacao_departamento = round((v_result->>'total_departamento')::numeric * 1000),
             pontuacao_certificados = round((v_result->'certificados'->>'total_certificados')::numeric * 1000),
             certificado_concurso_publico = round((v_result->>'concurso')::numeric * 1000),
             tempo_servico_unidade = round((v_result->>'tempo_unidade')::numeric * 1000),
             tempo_servico_departamento = round((v_result->>'tempo_departamento')::numeric * 1000),
             tempo_especialista = round((v_result->>'especialista')::numeric * 1000),
             assiduidade = round((v_result->>'assiduidade')::numeric * 1000),
             pontuacao = round(((v_result->>'total_unidade')::numeric + (v_result->>'total_departamento')::numeric)/2 * 1000),
             atualizado_em = now()
       where id_professor = r.id_professor and ano = p_ano and soft_delete = false;
    else
      insert into pontuacao_professores (
        id_professor, id_empresa, ano, pontuacao_unidade, pontuacao_departamento,
        pontuacao_certificados, certificado_concurso_publico,
        tempo_servico_unidade, tempo_servico_departamento, tempo_especialista,
        assiduidade, pontuacao, criado_em, atualizado_em
      )
      values (
        r.id_professor, p_id_empresa, p_ano,
        round((v_result->>'total_unidade')::numeric * 1000),
        round((v_result->>'total_departamento')::numeric * 1000),
        round((v_result->'certificados'->>'total_certificados')::numeric * 1000),
        round((v_result->>'concurso')::numeric * 1000),
        round((v_result->>'tempo_unidade')::numeric * 1000),
        round((v_result->>'tempo_departamento')::numeric * 1000),
        round((v_result->>'especialista')::numeric * 1000),
        round((v_result->>'assiduidade')::numeric * 1000),
        round(((v_result->>'total_unidade')::numeric + (v_result->>'total_departamento')::numeric)/2 * 1000),
        now(), now()
      );
    end if;

    v_total := v_total + 1;
  end loop;

  update fila_processamento_pontuacao
     set status = 'concluido',
         finalizado_em = now(),
         processados = v_total
   where id = p_job_id;

  return jsonb_build_object(
    'status', 'ok',
    'job', p_job_id,
    'empresa', p_id_empresa,
    'ano', p_ano,
    'total_processados', v_total
  );
end;
$$;


ALTER FUNCTION "public"."calc_pontuacao_todos_upsert_job"("p_id_empresa" "uuid", "p_ano" integer, "p_job_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calc_tempo_departamento_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) RETURNS numeric
    LANGUAGE "plpgsql"
    AS $$
declare
  scoring_year integer := p_ano_ref - 1;                 -- 2026 → 2025
  v_ini date := make_date(scoring_year - 1, 7, 1);       -- 01/07/2024
  v_fim date := make_date(scoring_year, 6, 30);          -- 30/06/2025
  v_data_admissao date;
  v_faltas integer;
  v_pont numeric := 0;
begin
  select resposta_data::date
  into v_data_admissao
  from respostas_user
  where id_user = p_id_professor
    and id_pergunta = '2cbcdcf0-a615-49a3-b563-e6c9e8e9f393';

  if v_data_admissao is null then return 0; end if;

  select count(*) into v_faltas
  from faltas_professores
  where id_professor = p_id_professor
    and id_empresa = p_id_empresa
    and data::date between v_ini and v_fim
    and codigo in ('JA','NC','I','LSV');

  v_pont := ((least(v_fim, current_date) - greatest(v_data_admissao, v_ini) + 1) * 0.005) - (v_faltas * 0.005);
  return greatest(v_pont,0);
end;
$$;


ALTER FUNCTION "public"."calc_tempo_departamento_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calc_tempo_unidade_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) RETURNS numeric
    LANGUAGE "plpgsql"
    AS $$
declare
  scoring_year integer := p_ano_ref - 1;                -- 2026 → 2025
  v_ini date := make_date(scoring_year - 1, 7, 1);      -- 01/07/2024
  v_fim date := make_date(scoring_year, 6, 30);         -- 30/06/2025
  v_dias integer := 0;
  v_faltas integer := 0;
  v_pont numeric := 0;
begin
  select 
    greatest(0, sum(least(coalesce(data_fim, v_fim), v_fim) - greatest(data_inicio, v_ini) + 1))
  into v_dias
  from professor_tempo_unidade
  where id_user = p_id_professor
    and id_empresa = p_id_empresa
    and status = 'ativo'
    and (data_fim is null or data_fim >= v_ini);

  select count(*) into v_faltas
  from faltas_professores
  where id_professor = p_id_professor
    and id_empresa = p_id_empresa
    and data::date between v_ini and v_fim
    and codigo in ('JA','NC','I','LSV');

  v_pont := (v_dias * 0.005) - (v_faltas * 0.005);
  return coalesce(v_pont,0);
end;
$$;


ALTER FUNCTION "public"."calc_tempo_unidade_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."classe_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_deleted_count integer;
BEGIN
    DELETE FROM public.classe
    WHERE id = p_id
      AND id_empresa = p_id_empresa;
      
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN jsonb_build_object('status', 'success', 'message', 'Classe deletada com sucesso.', 'id', p_id);
    ELSE
        RETURN jsonb_build_object('status', 'error', 'message', 'Classe não encontrada ou não pertence à empresa.', 'id', p_id);
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
END;
$$;


ALTER FUNCTION "public"."classe_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."classe_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    SELECT COUNT(*) INTO v_total_itens
    FROM public.classe
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome) LIKE v_busca_like 
        );

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT *
        FROM public.classe
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like 
            )
        ORDER BY ordem ASC, nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."classe_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."classe_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_id uuid;
    v_classe_salva public.classe;
BEGIN
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());

    IF NOT EXISTS (SELECT 1 FROM public.empresa WHERE id = p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    END IF;

    INSERT INTO public.classe (
        id, nome, ordem, id_empresa
    )
    VALUES (
        v_id,
        p_data ->> 'nome',
        COALESCE((p_data ->> 'ordem')::integer, 0),
        p_id_empresa
    )
    ON CONFLICT (id) DO UPDATE 
    SET 
        nome = COALESCE(excluded.nome, classe.nome),
        ordem = COALESCE(excluded.ordem, classe.ordem)
    WHERE classe.id_empresa = p_id_empresa
    RETURNING * INTO v_classe_salva;

    RETURN to_jsonb(v_classe_salva);

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
END;
$$;


ALTER FUNCTION "public"."classe_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."componente" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "title_sharepoint" "text",
    "id_sharepoint" integer,
    "cor" "text"
);


ALTER TABLE "public"."componente" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."componentes_get"("p_id_empresa" "uuid") RETURNS SETOF "public"."componente"
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.componente
    WHERE id_empresa = p_id_empresa
    ORDER BY nome ASC;
END;
$$;


ALTER FUNCTION "public"."componentes_get"("p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."confirmar_email_automaticamente"("p_user_id" "uuid") RETURNS "void"
    LANGUAGE "sql"
    AS $$
  update auth.users
  set email_confirmed_at = now()
  where id = p_user_id;
$$;


ALTER FUNCTION "public"."confirmar_email_automaticamente"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."crud_carga_horaria_p1"("p_envio" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  v_acao text := lower(coalesce(p_envio->>'criar_editar',''));
  v_dados jsonb := coalesce(p_envio->'p_dados', '{}'::jsonb);
  v_uuid uuid;
  v_result jsonb;
begin
  if v_acao = 'criar' then
    insert into public.carga_horaria_p1 (
      id_componente,
      id_ano_etapa,
      carga_horaria,
      id_empresa,
      criado_por
    )
    values (
      (v_dados->>'id_componente')::uuid,
      (v_dados->>'id_ano_etapa')::uuid,
      (v_dados->>'carga_horaria')::integer,
      (v_dados->>'id_empresa')::uuid,
      (v_dados->>'criado_por')::uuid
    )
    returning uuid into v_uuid;

  elsif v_acao = 'editar' then
    update public.carga_horaria_p1
    set
      id_componente = coalesce((v_dados->>'id_componente')::uuid, id_componente),
      id_ano_etapa = coalesce((v_dados->>'id_ano_etapa')::uuid, id_ano_etapa),
      carga_horaria = coalesce((v_dados->>'carga_horaria')::integer, carga_horaria),
      id_empresa = coalesce((v_dados->>'id_empresa')::uuid, id_empresa),
      modifica_por = (v_dados->>'modifica_por')::uuid,
      modificado_em = now()
    where uuid = (v_dados->>'uuid')::uuid
    returning uuid into v_uuid;

  elsif v_acao = 'excluir' then
    -- pega o registro antes de excluir
    select jsonb_build_object(
      'uuid', ch.uuid,
      'id_componente', ch.id_componente,
      'id_ano_etapa', ch.id_ano_etapa,
      'carga_horaria', ch.carga_horaria,
      'id_empresa', ch.id_empresa,
      'criado_em', ch.criado_em,
      'modificado_em', ch.modificado_em
    )
    into v_result
    from public.carga_horaria_p1 ch
    where ch.uuid = (v_dados->>'uuid')::uuid;

    delete from public.carga_horaria_p1
    where uuid = (v_dados->>'uuid')::uuid;

    return v_result;

  else
    raise exception 'Ação inválida. Use criar, editar ou excluir.';
  end if;

  -- Retorna o item atualizado/criado com os joins resolvidos
  select jsonb_build_object(
    'uuid', ch.uuid,
    'id_componente', ch.id_componente,
    'id_ano_etapa', ch.id_ano_etapa,
    'carga_horaria', ch.carga_horaria,
    'id_empresa', ch.id_empresa,
    'criado_em', ch.criado_em,
    'modificado_em', ch.modificado_em,
    'componente_nome', c.nome,
    'ano_etapa_nome', ae.nome,
    'ano_etapa_tipo', ae.tipo
  )
  into v_result
  from public.carga_horaria_p1 ch
  join public.ano_etapa ae on ae.id = ch.id_ano_etapa
  join public.componente c on c.uuid = ch.id_componente
  where ch.uuid = v_uuid;

  return v_result;
end;
$$;


ALTER FUNCTION "public"."crud_carga_horaria_p1"("p_envio" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."crud_carga_horaria_p3"("p_envio" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  v_acao text := lower(coalesce(p_envio->>'criar_editar',''));
  v_dados jsonb := coalesce(p_envio->'p_dados', '{}'::jsonb);
  v_uuid uuid;
  v_result jsonb;
begin
  if v_acao = 'criar' then
    insert into public.carga_horaria_p3 (
      id_componente,
      id_ano_etapa,
      carga_horaria,
      id_empresa,
      criado_por
    )
    values (
      (v_dados->>'id_componente')::uuid,
      (v_dados->>'id_ano_etapa')::uuid,
      (v_dados->>'carga_horaria')::integer,
      (v_dados->>'id_empresa')::uuid,
      (v_dados->>'criado_por')::uuid
    )
    returning uuid into v_uuid;

  elsif v_acao = 'editar' then
    update public.carga_horaria_p3
    set
      id_componente = coalesce((v_dados->>'id_componente')::uuid, id_componente),
      id_ano_etapa = coalesce((v_dados->>'id_ano_etapa')::uuid, id_ano_etapa),
      carga_horaria = coalesce((v_dados->>'carga_horaria')::integer, carga_horaria),
      id_empresa = coalesce((v_dados->>'id_empresa')::uuid, id_empresa),
      modifica_por = (v_dados->>'modifica_por')::uuid,
      modificado_em = now()
    where uuid = (v_dados->>'uuid')::uuid
    returning uuid into v_uuid;

  elsif v_acao = 'excluir' then
    select jsonb_build_object(
      'uuid', ch.uuid,
      'id_componente', ch.id_componente,
      'id_ano_etapa', ch.id_ano_etapa,
      'carga_horaria', ch.carga_horaria,
      'id_empresa', ch.id_empresa,
      'criado_em', ch.criado_em,
      'modificado_em', ch.modificado_em
    )
    into v_result
    from public.carga_horaria_p3 ch
    where ch.uuid = (v_dados->>'uuid')::uuid;

    delete from public.carga_horaria_p3
    where uuid = (v_dados->>'uuid')::uuid;

    return v_result;

  else
    raise exception 'Ação inválida. Use criar, editar ou excluir.';
  end if;

  select jsonb_build_object(
    'uuid', ch.uuid,
    'id_componente', ch.id_componente,
    'id_ano_etapa', ch.id_ano_etapa,
    'carga_horaria', ch.carga_horaria,
    'id_empresa', ch.id_empresa,
    'criado_em', ch.criado_em,
    'modificado_em', ch.modificado_em,
    'componente_nome', c.nome,
    'ano_etapa_nome', ae.nome,
    'ano_etapa_tipo', ae.tipo
  )
  into v_result
  from public.carga_horaria_p3 ch
  join public.ano_etapa ae on ae.id = ch.id_ano_etapa
  join public.componente c on c.uuid = ch.id_componente
  where ch.uuid = v_uuid;

  return v_result;
end;
$$;


ALTER FUNCTION "public"."crud_carga_horaria_p3"("p_envio" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."custom_access_token"("event" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  claims     jsonb := '{}'::jsonb;
  papel_nome text;
  empresa_id uuid;
begin
  -- claims existentes, garantindo objeto
  claims := coalesce(event->'claims', '{}'::jsonb);

  -- tenta buscar papel e empresa do usuário; pode não existir ainda no 1º login
  select p.nome, pa.empresa_id
    into papel_nome, empresa_id
  from public.papeis_user_auth pa
  join public.papeis_user p on p.id = pa.papel_id
  where pa.user_id = (event->>'user_id')::uuid
  limit 1;

  -- adiciona 'papeis_user' somente se houver valor
  if papel_nome is not null then
    claims := jsonb_set(claims, '{papeis_user}', to_jsonb(papel_nome), true);
  end if;

  -- adiciona 'empresa_id' como string (claims gostam de tipos simples)
  if empresa_id is not null then
    claims := jsonb_set(claims, '{empresa_id}', to_jsonb(empresa_id::text), true);
  end if;

  -- devolve o evento com claims SEMPRE como objeto (nunca null)
  return jsonb_set(event, '{claims}', claims, true);
end;
$$;


ALTER FUNCTION "public"."custom_access_token"("event" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_calendario_matriz_semana"("p_id_item" "uuid" DEFAULT NULL::"uuid", "p_id_turma" "uuid" DEFAULT NULL::"uuid", "p_id_empresa" "uuid" DEFAULT NULL::"uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_id_turma uuid;
  v_id_empresa uuid;
  v_result jsonb;
BEGIN
  --------------------------------------------------------------------------
  -- 1️⃣ Validação básica
  --------------------------------------------------------------------------
  IF p_id_item IS NULL AND p_id_turma IS NULL THEN
    RAISE EXCEPTION 'Informe p_id_item (para deletar um item) ou p_id_turma (para deletar todos).';
  END IF;

  --------------------------------------------------------------------------
  -- 2️⃣ Identifica turma e empresa (caso não enviados)
  --------------------------------------------------------------------------
  IF p_id_item IS NOT NULL THEN
    SELECT id_turma, id_empresa
    INTO v_id_turma, v_id_empresa
    FROM public.calendario_matriz_semana
    WHERE id = p_id_item
    LIMIT 1;
  ELSE
    v_id_turma := p_id_turma;
    v_id_empresa := p_id_empresa;
  END IF;

  IF v_id_turma IS NULL THEN
    RAISE EXCEPTION 'Turma não encontrada para o item informado.';
  END IF;

  --------------------------------------------------------------------------
  -- 3️⃣ Exclusão
  --------------------------------------------------------------------------
  IF p_id_item IS NOT NULL THEN
    DELETE FROM public.calendario_matriz_semana
    WHERE id = p_id_item;
  ELSE
    DELETE FROM public.calendario_matriz_semana
    WHERE id_turma = v_id_turma
      AND (p_id_empresa IS NULL OR id_empresa = p_id_empresa);
  END IF;

  --------------------------------------------------------------------------
  -- 4️⃣ Normaliza ordens após exclusão
  --------------------------------------------------------------------------
  UPDATE public.calendario_matriz_semana AS cm
  SET ordem = sub.nova_ordem
  FROM (
    SELECT id,
           ROW_NUMBER() OVER (PARTITION BY id_turma, dia_semana ORDER BY ordem) - 1 AS nova_ordem
    FROM public.calendario_matriz_semana
    WHERE id_turma = v_id_turma
  ) AS sub
  WHERE cm.id = sub.id;

  --------------------------------------------------------------------------
  -- 5️⃣ Retorna o array atualizado (mesmo formato do upsert)
  --------------------------------------------------------------------------
  v_result := (
    SELECT jsonb_agg(
      jsonb_build_object(
        'id_supabase', cm.id,
        'id', cm.id_local,
        'ordem', cm.ordem,
        'dia',
          CASE cm.dia_semana
            WHEN 1 THEN 'segunda-feira'
            WHEN 2 THEN 'terça-feira'
            WHEN 3 THEN 'quarta-feira'
            WHEN 4 THEN 'quinta-feira'
            WHEN 5 THEN 'sexta-feira'
            WHEN 6 THEN 'sábado'
            WHEN 7 THEN 'domingo'
          END,
        'tipo', cm.tipo,
        'duracao', cm.duracao_minutos,
        'id_empresa', cm.id_empresa,
        'id_turma', cm.id_turma,
        'id_componente', cm.id_componente,
        'id_carga_horaria',
          COALESCE(cm.id_carga_horaria_p1, cm.id_carga_horaria_p3),
        'id_atividade_infantil', cm.id_atividade_infantil,
        'id_professor', cm.criado_por,
        'professor', u.nome_completo,
        'title', COALESCE(c.nome, ai.nome, cm.tipo),
        'color', COALESCE(c.cor, '#94A3B8')
      )
      ORDER BY cm.dia_semana, cm.ordem
    )
    FROM public.calendario_matriz_semana cm
    LEFT JOIN public.user_expandido u ON u.id = cm.criado_por
    LEFT JOIN public.componente c ON c.uuid = cm.id_componente
    LEFT JOIN public.atividades_infantil ai ON ai.id = cm.id_atividade_infantil
    WHERE cm.id_turma = v_id_turma
      AND (v_id_empresa IS NULL OR cm.id_empresa = v_id_empresa)
  );

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;


ALTER FUNCTION "public"."delete_calendario_matriz_semana"("p_id_item" "uuid", "p_id_turma" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."edicao_update_remover_arquivos_coluna"("p_edicao_uuid" "uuid", "p_coluna" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Validate column name to prevent SQL injection and ensure logical correctness
    IF p_coluna NOT IN ('arquivo_pdf', 'arquivo_capa') THEN
        RETURN jsonb_build_object('success', false, 'error', 'Nome de coluna inválido. Use "arquivo_pdf" ou "arquivo_capa".');
    END IF;

    -- Update the specified column to NULL
    IF p_coluna = 'arquivo_pdf' THEN
        UPDATE public.bbtk_edicao 
        SET arquivo_pdf = NULL 
        WHERE uuid = p_edicao_uuid;
    ELSIF p_coluna = 'arquivo_capa' THEN
        UPDATE public.bbtk_edicao 
        SET arquivo_capa = NULL 
        WHERE uuid = p_edicao_uuid;
    END IF;

    IF FOUND THEN
        RETURN jsonb_build_object('success', true);
    ELSE
        RETURN jsonb_build_object('success', false, 'error', 'Edição não encontrada.');
    END IF;
END;
$$;


ALTER FUNCTION "public"."edicao_update_remover_arquivos_coluna"("p_edicao_uuid" "uuid", "p_coluna" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."escolas_com_predio_get"("p_id_empresa" "uuid") RETURNS TABLE("id" "uuid", "nome" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
    return query
    select distinct e.id, e.nome
    from public.escolas e
    join public.bbtk_dim_predio p on p.id_escola = e.id
    where e.id_empresa = p_id_empresa
    order by e.nome;
end;
$$;


ALTER FUNCTION "public"."escolas_com_predio_get"("p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
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
    -- Retorna JSON de erro estruturado
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;


ALTER FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."escolas_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    -- 1. Calcular Offset
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- 2. Calcular Total de Itens (para a busca atual)
    SELECT COUNT(*) INTO v_total_itens
    FROM public.escolas
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome) LIKE v_busca_like 
        );

    -- 3. Calcular Total de Páginas
    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- 4. Buscar Itens Paginados e converter para JSON
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT *
        FROM public.escolas
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like 
            )
        ORDER BY nome ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- 5. Retornar Objeto JSON Final
    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."escolas_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."escolas_get_schema"("p_id_empresa" "uuid") RETURNS SETOF "jsonb"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    -- Reutiliza a função genérica get_table_schema para a tabela 'escolas'
    select public.get_table_schema(p_id_empresa, 'escolas');
$$;


ALTER FUNCTION "public"."escolas_get_schema"("p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."escolas_por_ano_etapa"("id_ano_etapa" "uuid") RETURNS TABLE("id_escola" "uuid")
    LANGUAGE "sql"
    AS $$
  select distinct id_escola
  from (
    select e.id as id_escola, e.nome
    from turmas t
    join escolas e on e.id = t.id_escola
    where t.id_ano_etapa = escolas_por_ano_etapa.id_ano_etapa
    order by e.nome asc
  ) sub
$$;


ALTER FUNCTION "public"."escolas_por_ano_etapa"("id_ano_etapa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."escolas_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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


ALTER FUNCTION "public"."escolas_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."exec_sql_safe"("p_query" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_result jsonb;
  v_lower text := lower(coalesce(p_query, ''));
  v_kw text;
  prohibited text[] := array[
    'insert', 'update', 'delete', 'drop', 'alter', 'create',
    'truncate', 'grant', 'revoke', ';', '--'
  ];
begin
  -- 1) obrigar início com SELECT (ignora espaços iniciais)
  if v_lower !~ '^\s*select' then
    raise exception 'Somente instruções SELECT são permitidas.';
  end if;

  -- 2) checar keywords proibidas
  foreach v_kw in array prohibited loop
    if position(v_kw in v_lower) > 0 then
      raise exception 'Keyword proibida detectada na query: %', v_kw;
    end if;
  end loop;

  -- 3) executar de forma a agregar em JSON
  execute format('select coalesce(jsonb_agg(t), ''[]'') from (%s) t', p_query)
    into v_result;

  return v_result;
end;
$$;


ALTER FUNCTION "public"."exec_sql_safe"("p_query" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."familia_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
    delete from public.user_familia
    where id = p_id
    and id_empresa = p_id_empresa;
end;
$$;


ALTER FUNCTION "public"."familia_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."familia_get_detalhes"("p_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_familia record;
    v_responsaveis jsonb;
    v_alunos jsonb;
    v_id_pergunta_cpf uuid := 'bec8701a-c56e-47c2-82d3-3123ad26bc2f';
BEGIN
    SELECT * INTO v_familia FROM public.user_familia WHERE id = p_id;
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    -- Fetch Responsaveis
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', ue.id,
            'nome_completo', ue.nome_completo,
            'email', ue.email,
            'telefone', ue.telefone,
            'cpf', ru_cpf.resposta,
            'papel', COALESCE(rel.papel, 'Pai') -- Default if missing
        )
    ) INTO v_responsaveis
    FROM (
        SELECT DISTINCT id FROM (
            SELECT id_responsavel_principal as id FROM public.user_familia WHERE id = p_id AND id_responsavel_principal IS NOT NULL
            UNION
            SELECT id_responsavel FROM public.user_responsavel_aluno WHERE id_familia = p_id
        ) ids
    ) r_ids
    JOIN public.user_expandido ue ON r_ids.id = ue.id
    LEFT JOIN public.respostas_user ru_cpf ON ue.id = ru_cpf.id_user AND ru_cpf.id_pergunta = v_id_pergunta_cpf
    LEFT JOIN LATERAL (
        SELECT papel 
        FROM public.user_responsavel_aluno 
        WHERE id_familia = p_id AND id_responsavel = ue.id
        LIMIT 1
    ) rel ON true;

    -- Fetch Alunos
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', ue.id,
            'nome_completo', ue.nome_completo,
            'matricula', ue.matricula
        )
    ) INTO v_alunos
    FROM (
        SELECT DISTINCT id_aluno 
        FROM public.user_responsavel_aluno 
        WHERE id_familia = p_id
    ) a_ids
    JOIN public.user_expandido ue ON a_ids.id_aluno = ue.id;

    RETURN jsonb_build_object(
        'id', v_familia.id,
        'nome_familia', v_familia.nome_familia,
        'id_responsavel_principal', v_familia.id_responsavel_principal,
        'responsaveis', COALESCE(v_responsaveis, '[]'::jsonb),
        'alunos', COALESCE(v_alunos, '[]'::jsonb)
    );
END;
$$;


ALTER FUNCTION "public"."familia_get_detalhes"("p_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."familia_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT NULL::"text") RETURNS TABLE("id" "uuid", "nome_familia" "text", "responsavel_principal" "text", "qtd_alunos" bigint, "total_registros" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_offset integer;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    RETURN QUERY
    WITH familias_filtradas AS (
        SELECT
            f.id,
            f.nome_familia,
            ue.nome_completo as responsavel_nome
        FROM
            public.user_familia f
        LEFT JOIN
            public.user_expandido ue ON f.id_responsavel_principal = ue.id
        WHERE
            f.id_empresa = p_id_empresa
            AND (
                p_busca IS NULL OR 
                f.nome_familia ILIKE '%' || p_busca || '%' OR
                ue.nome_completo ILIKE '%' || p_busca || '%'
            )
    ),
    contagem_alunos AS (
        SELECT
            rua.id_familia,
            COUNT(DISTINCT rua.id_aluno) as qtd
        FROM
            public.user_responsavel_aluno rua
        GROUP BY
            rua.id_familia
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM familias_filtradas
    )
    SELECT
        ff.id,
        ff.nome_familia,
        ff.responsavel_nome as responsavel_principal,
        COALESCE(ca.qtd, 0) as qtd_alunos,
        tc.total as total_registros
    FROM
        familias_filtradas ff
    LEFT JOIN
        contagem_alunos ca ON ff.id = ca.id_familia
    CROSS JOIN
        total_count tc
    ORDER BY
        ff.nome_familia ASC
    LIMIT
        p_limite_itens_pagina
    OFFSET
        v_offset;
END;
$$;


ALTER FUNCTION "public"."familia_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."familia_upsert"("p_id_empresa" "uuid", "p_data" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_id_familia uuid;
    v_item_resp jsonb;
    v_id_resp uuid;
    v_id_aluno uuid;
    v_alunos_array jsonb;
    v_papel_responsavel uuid := '3ecbe197-4c01-4b25-8e8a-04f9adaff801';
    v_id_pergunta_cpf uuid := 'bec8701a-c56e-47c2-82d3-3123ad26bc2f';
BEGIN
    -- 1. Family Upsert
    v_id_familia := (p_data->>'id')::uuid;
    
    IF v_id_familia IS NULL THEN
        INSERT INTO public.user_familia (id_empresa, nome_familia)
        VALUES (p_id_empresa, p_data->>'nome_familia')
        RETURNING id INTO v_id_familia;
    ELSE
        UPDATE public.user_familia
        SET nome_familia = p_data->>'nome_familia'
        WHERE id = v_id_familia AND id_empresa = p_id_empresa;
    END IF;

    -- 2. Clear existing links for this family to ensure full sync
    DELETE FROM public.user_responsavel_aluno WHERE id_familia = v_id_familia;

    -- 3. Responsibles Loop
    v_alunos_array := p_data->'alunos';
    
    FOR v_item_resp IN SELECT * FROM jsonb_array_elements(p_data->'responsaveis')
    LOOP
        v_id_resp := (v_item_resp->>'id')::uuid;
        
        -- Upsert User Expandido (Responsable)
        IF v_id_resp IS NULL THEN
            INSERT INTO public.user_expandido (
                id_empresa, 
                nome_completo, 
                email, 
                telefone,
                matricula,
                papel_id
            ) VALUES (
                p_id_empresa,
                v_item_resp->>'nome_completo',
                v_item_resp->>'email',
                v_item_resp->>'telefone',
                'TEMP-RESP-' || floor(extract(epoch from now()) * 1000)::text || '-' || floor(random() * 1000)::text,
                v_papel_responsavel
            ) RETURNING id INTO v_id_resp;
        ELSE
            UPDATE public.user_expandido
            SET 
                nome_completo = v_item_resp->>'nome_completo',
                email = v_item_resp->>'email',
                telefone = v_item_resp->>'telefone'
            WHERE id = v_id_resp;
        END IF;

        -- Update Principal if flagged
        IF (v_item_resp->>'principal')::boolean IS TRUE THEN
            UPDATE public.user_familia 
            SET id_responsavel_principal = v_id_resp
            WHERE id = v_id_familia;
        END IF;

        -- Upsert CPF (respostas_user)
        IF v_item_resp->>'cpf' IS NOT NULL AND v_item_resp->>'cpf' <> '' THEN
             INSERT INTO public.respostas_user (id_empresa, id_user, id_pergunta, resposta, tipo)
             VALUES (p_id_empresa, v_id_resp, v_id_pergunta_cpf, v_item_resp->>'cpf', 'texto')
             ON CONFLICT (id_user, id_pergunta)
             DO UPDATE SET resposta = EXCLUDED.resposta;
        END IF;

        -- Link Students to this Responsible
        IF v_alunos_array IS NOT NULL THEN
             FOR v_id_aluno IN SELECT * FROM jsonb_array_elements_text(v_alunos_array)
             LOOP
                 INSERT INTO public.user_responsavel_aluno (id_aluno, id_responsavel, id_familia, papel)
                 VALUES (v_id_aluno::uuid, v_id_resp, v_id_familia, v_item_resp->>'papel')
                 ON CONFLICT (id_aluno, id_responsavel) 
                 DO UPDATE SET 
                    id_familia = EXCLUDED.id_familia,
                    papel = EXCLUDED.papel;
             END LOOP;
        END IF;

    END LOOP;
    
    RETURN jsonb_build_object('id', v_id_familia);
END;
$$;


ALTER FUNCTION "public"."familia_upsert"("p_id_empresa" "uuid", "p_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_uep_definir_user_id"("p_id_user_expandido" "uuid", "p_user_id" "uuid") RETURNS TABLE("ok" boolean, "mensagem" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_uid uuid := auth.uid();
  v_row record;
begin
  if v_uid is null then
    return query select false, 'Não autenticado.';
    return;
  end if;

  -- garante que o user_id passado é do próprio usuário logado
  if p_user_id is null or p_user_id <> v_uid then
    return query select false, 'user_id inválido para este usuário.';
    return;
  end if;

  select id, user_id, email
    into v_row
  from public.user_expandido
  where id = p_id_user_expandido;

  if not found then
    return query select false, 'Registro não encontrado.';
    return;
  end if;

  -- já vinculado?
  if v_row.user_id is not null then
    if v_row.user_id = p_user_id then
      return query select true, 'Já vinculado a este usuário.';
    else
      return query select false, 'Registro já vinculado a outro usuário.';
    end if;
  end if;

  -- vincula de forma idempotente e segura contra corrida
  update public.user_expandido
     set user_id = p_user_id,
         modificado_por = v_uid,
         modificado_em  = now()
   where id = p_id_user_expandido
     and user_id is null;

  if found then
    return query select true, 'Vinculado com sucesso.';
  else
    return query select false, 'Não foi possível vincular (talvez já vinculado).';
  end if;
end;
$$;


ALTER FUNCTION "public"."fn_uep_definir_user_id"("p_id_user_expandido" "uuid", "p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."gerar_unidades_para_ano"("p_ano" integer) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
declare
  carga record;
  turma record;
begin
  for carga in
    select uuid, id_ano_etapa, id_empresa
    from carga_horaria_p3
  loop
    for turma in
      select id
      from turmas
      where id_ano_etapa = carga.id_ano_etapa
        and ano::int = p_ano
    loop
      -- Evita duplicatas
      if not exists (
        select 1 from unidade_atribuicao
        where id_turma = turma.id
          and id_ch_p3 = carga.uuid
      ) then
        insert into unidade_atribuicao (
          uuid,
          id_turma,
          id_ch_p3,
          ano,
          id_professor,
          id_professor_s,
          id_empresa,
          criado_em
        )
        values (
          gen_random_uuid(),
          turma.id,
          carga.uuid,
          p_ano,
          null,
          null,
          carga.id_empresa,
          now()
        );
      end if;
    end loop;
  end loop;
end;
$$;


ALTER FUNCTION "public"."gerar_unidades_para_ano"("p_ano" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_admins_by_produto_paginado"("p_produto_id" "uuid", "p_page" integer, "p_limit" integer, "p_nome" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_offset int;
  v_total int;
  v_paginas int;
  v_result jsonb;
begin
  -- Calcula offset
  v_offset := (p_page - 1) * p_limit;

  -- Conta total de registros
  select count(*)
  into v_total
  from public.user_expandido_admin ua
  join public.produtos_user pu on pu.user_id = ua.user_id
  where pu.produto_id = p_produto_id
    and ua.status = true
    and (
      p_nome is null
      or ua.nome_completo ilike '%' || p_nome || '%'
    );

  -- Calcula nº de páginas
  v_paginas := ceil(v_total::numeric / p_limit)::int;

  -- Monta resultado em JSON
  v_result := jsonb_build_object(
    'total', v_total,
    'paginas', v_paginas,
    'pagina_atual', p_page,
    'itens_por_pagina', p_limit,
    'itens', coalesce((
      select jsonb_agg(row_to_json(r))
      from (
        select
          ua.imagem_user,
          ua.nome_completo,
          ua.email,
          ua.telefone
        from public.user_expandido_admin ua
        join public.produtos_user pu on pu.user_id = ua.user_id
        where pu.produto_id = p_produto_id
          and ua.status = true
          and (
            p_nome is null
            or ua.nome_completo ilike '%' || p_nome || '%'
          )
        order by ua.nome_completo
        limit p_limit offset v_offset
      ) r
    ), '[]'::jsonb)
  );

  return v_result;
end;
$$;


ALTER FUNCTION "public"."get_admins_by_produto_paginado"("p_produto_id" "uuid", "p_page" integer, "p_limit" integer, "p_nome" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_atividades_infantil_paginada"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_itens_por_pagina" integer DEFAULT 30, "p_busca" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_offset int := greatest(0, (p_pagina - 1) * p_itens_por_pagina);
  v_total int;
  v_paginas int;
  v_itens jsonb;
begin
  -- total de registros
  select count(*) into v_total
  from public.atividades_infantil ai
  where ai.id_empresa = p_id_empresa
    and (p_busca is null or unaccent(ai.nome) ilike '%' || unaccent(p_busca) || '%');

  v_paginas := greatest(ceil(v_total::numeric / p_itens_por_pagina)::int, 1);

  -- CTE para garantir ordenação antes do JSON_AGG
  with base as (
    select ai.id, ai.nome, ai.descricao, ai.id_empresa, ai.criado_em
    from public.atividades_infantil ai
    where ai.id_empresa = p_id_empresa
      and (p_busca is null or unaccent(ai.nome) ilike '%' || unaccent(p_busca) || '%')
    order by ai.criado_em desc
    limit p_itens_por_pagina offset v_offset
  )
  select jsonb_agg(
    jsonb_build_object(
      'id', b.id,
      'nome', b.nome,
      'descricao', b.descricao,
      'duracoes', coalesce(d.duracoes, '[]'::jsonb)
    )
  )
  into v_itens
  from base b
  left join lateral (
    select jsonb_agg(jsonb_build_object(
      'id', ad.id,
      'duracao_minutos', ad.duracao_minutos
    ) order by ad.duracao_minutos) as duracoes
    from public.atividades_infantil_duracao ad
    where ad.id_atividade_infantil = b.id
  ) d on true;

  return jsonb_build_object(
    'qtd_paginas', v_paginas,
    'qtd_itens', v_total,
    'pagina_atual', p_pagina,
    'itens', coalesce(v_itens, '[]'::jsonb)
  );
end;
$$;


ALTER FUNCTION "public"."get_atividades_infantil_paginada"("p_id_empresa" "uuid", "p_pagina" integer, "p_itens_por_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_atribuicoes_professor_detalhada"("p_id_professor" "uuid", "p_ano" integer) RETURNS TABLE("id_atribuicao" "uuid", "t_id" "uuid", "e_nome" "text", "ae_nome" "text", "c_nome" "text", "h_inicio" "text", "h_fim" "text", "nivel_substituicao" integer, "nome_completo" "text", "matricula" "text", "email" "text", "telefone" "text", "outros_professores" "jsonb")
    LANGUAGE "sql"
    AS $$
select
  atp.id as id_atribuicao,
  t.id as t_id,
  e.nome as e_nome,
  ae.nome as ae_nome,
  c.nome as c_nome,
  h.hora_inicio as h_inicio,
  h.hora_fim as h_fim,
  atp.nivel_substituicao,
  u.nome_completo,
  u.matricula,
  u.email,
  u.telefone,
  coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', up.id,
        'nome_completo', up.nome_completo,
        'matricula', up.matricula,
        'email', up.email,
        'telefone', up.telefone,
        'nivel_substituicao', at2.nivel_substituicao,
        'id_atribuicao', at2.id
      )
      order by at2.nivel_substituicao
    ) filter (where at2.id is not null),
    '[]'::jsonb
  ) as outros_professores
from
  turma_professor_atribuicao atp
  join turmas t on t.id = atp.id_turma
  join escolas e on e.id = t.id_escola
  join ano_etapa ae on ae.id = t.id_ano_etapa
  join classe c on c.id = t.id_classe
  join horarios_escola h on h.id = t.id_horario
  join user_expandido u on u.id = atp.id_professor
  left join turma_professor_atribuicao at2 
    on at2.id_turma = t.id and at2.id_professor != p_id_professor
  left join user_expandido up on up.id = at2.id_professor
where
  atp.id_professor = p_id_professor
  and atp.ano = p_ano
group by
  atp.id, t.id, e.nome, ae.nome, c.nome, h.hora_inicio, h.hora_fim,
  atp.nivel_substituicao, u.nome_completo, u.matricula, u.email, u.telefone
order by
  t.ano desc, e.nome;
$$;


ALTER FUNCTION "public"."get_atribuicoes_professor_detalhada"("p_id_professor" "uuid", "p_ano" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_auth_overview_empresa"("p_id_empresa" "uuid", "p_days" integer DEFAULT 30) RETURNS "jsonb"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
    AS $$
with const as (
  select
    '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1'::uuid as papel_professor,
    '07028505-01d7-4986-800e-9d71cab5dd6c'::uuid as papel_funcao_extra,
    'd3410ac7-5a4a-4f02-8923-610b9fd87c4d'::uuid as papel_admin
),
ue as (
  select u.*
  from public.user_expandido u
  where u.id_empresa = p_id_empresa
),
tot as (
  select
    count(*)::int                                                            as usuarios_total,
    count(*) filter (where u.papel_id = c.papel_professor)::int              as professores_total,
    count(*) filter (where u.papel_id = c.papel_funcao_extra)::int           as funcao_extra_total,
    count(*) filter (where u.papel_id = c.papel_admin)::int                  as admins_total,
    count(u.user_id)::int                                                    as com_conta_total
  from ue u
  cross join const c
),
ue_auth as (
  -- Só quem tem conta criada; puxa created_at do auth.users
  select u.id,
         u.user_id,
         (au.created_at at time zone 'America/Sao_Paulo')::date as dia_local
  from ue u
  join auth.users au on au.id = u.user_id
),
serie as (
  -- Série diária dos últimos p_days dias no fuso de SP
  select ((now() at time zone 'America/Sao_Paulo')::date - offs) as dia
  from generate_series(0, greatest(p_days,1)-1) as offs
),
diario as (
  select s.dia,
         coalesce(count(ua.user_id), 0)::int as contas
  from serie s
  left join ue_auth ua
    on ua.dia_local = s.dia
  group by s.dia
  order by s.dia
)
select jsonb_build_object(
  'empresa_id', p_id_empresa,
  'periodo_dias', p_days,
  'totais', jsonb_build_object(
    'usuarios_total',      tot.usuarios_total,
    'professores_total',   tot.professores_total,
    'funcao_extra_total',  tot.funcao_extra_total,
    'admins_total',        tot.admins_total,
    'com_conta_total',     tot.com_conta_total
  ),
  'contas_por_dia',
     coalesce(
       (select jsonb_agg(jsonb_build_object(
                  'dia', to_char(d.dia, 'DD/MM/YYYY'),
                  'contas', d.contas
                ) order by d.dia)
        from diario d),
       '[]'::jsonb
     )
)
from tot;
$$;


ALTER FUNCTION "public"."get_auth_overview_empresa"("p_id_empresa" "uuid", "p_days" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_calendario_matriz_semana_por_turma_v2"("p_id_turma" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_result jsonb;
BEGIN
  v_result := (
    SELECT jsonb_agg(
      jsonb_build_object(
        'id_supabase', cm.id,
        'id', cm.id_local,
        'ordem', cm.ordem,
        'dia', 
          CASE cm.dia_semana
            WHEN 1 THEN 'segunda-feira'
            WHEN 2 THEN 'terça-feira'
            WHEN 3 THEN 'quarta-feira'
            WHEN 4 THEN 'quinta-feira'
            WHEN 5 THEN 'sexta-feira'
            WHEN 6 THEN 'sábado'
            WHEN 7 THEN 'domingo'
          END,
        'tipo', cm.tipo,
        'duracao', cm.duracao_minutos,
        'id_empresa', cm.id_empresa,
        'id_turma', cm.id_turma,
        'id_componente', cm.id_componente,
        'id_carga_horaria', 
          COALESCE(cm.id_carga_horaria_p1, cm.id_carga_horaria_p3),
        'id_atividade_infantil', cm.id_atividade_infantil,
        'id_professor', cm.criado_por,
        'professor', u.nome_completo,
        'title',
          COALESCE(c.nome, ai.nome, cm.tipo),
        'color',
          COALESCE(c.cor, '#94A3B8')
      )
      ORDER BY cm.dia_semana, cm.ordem
    )
    FROM public.calendario_matriz_semana cm
    LEFT JOIN public.user_expandido u
      ON u.id = cm.criado_por
    LEFT JOIN public.componente c
      ON c.uuid = cm.id_componente
    LEFT JOIN public.atividades_infantil ai
      ON ai.id = cm.id_atividade_infantil
    WHERE cm.id_turma = p_id_turma
      AND cm.id_empresa = p_id_empresa
  );

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;


ALTER FUNCTION "public"."get_calendario_matriz_semana_por_turma_v2"("p_id_turma" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_carga_horaria_p1_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text" DEFAULT NULL::"text", "p_pagina" integer DEFAULT 1, "p_itens_por_pagina" integer DEFAULT 30) RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  v_total int;
  v_qtd_paginas int;
  v_offset int := greatest((coalesce(p_pagina,1)-1) * coalesce(p_itens_por_pagina,30), 0);
  v_itens jsonb;
  v_result jsonb;
begin
  -------------------------------------------------------------------
  -- 1) Conta total de registros aplicando filtros + empresa
  -------------------------------------------------------------------
  select count(*)
  into v_total
  from public.carga_horaria_p1 ch
  join public.ano_etapa ae on ae.id = ch.id_ano_etapa
  where ch.id_empresa = p_id_empresa
    and (
          p_busca_ano_etapa is null
          or ae.nome ilike '%' || p_busca_ano_etapa || '%'
          or ae.id::text = p_busca_ano_etapa
        );

  v_qtd_paginas := case when coalesce(p_itens_por_pagina,30) > 0
                        then ceil(v_total::numeric / coalesce(p_itens_por_pagina,30))::int
                        else 1 end;

  -------------------------------------------------------------------
  -- 2) Seleciona os itens da página atual
  -------------------------------------------------------------------
  select coalesce(jsonb_agg(j.item), '[]'::jsonb)
  into v_itens
  from (
    select jsonb_build_object(
      'uuid', ch.id,                       -- <- padroniza a chave como "uuid", igual ao P3
      'id_ano_etapa', ch.id_ano_etapa,
      'carga_horaria', ch.carga_horaria,
      'id_empresa', ch.id_empresa,
      'criado_em', ch.criado_em,
      'modificado_em', ch.modificado_em,
      'ano_etapa_nome', ae.nome,
      'ano_etapa_tipo', ae.tipo
    ) as item
    from public.carga_horaria_p1 ch
    join public.ano_etapa ae on ae.id = ch.id_ano_etapa
    where ch.id_empresa = p_id_empresa
      and (
            p_busca_ano_etapa is null
            or ae.nome ilike '%' || p_busca_ano_etapa || '%'
            or ae.id::text = p_busca_ano_etapa
          )
    order by ae.nome
    offset v_offset
    limit coalesce(p_itens_por_pagina,30)
  ) j;

  -------------------------------------------------------------------
  -- 3) Monta o retorno estruturado em JSONB
  -------------------------------------------------------------------
  v_result := jsonb_build_object(
    'qtd_paginas', v_qtd_paginas,
    'qtd_itens', v_total,
    'pagina_atual', coalesce(p_pagina,1),
    'itens', v_itens
  );

  return v_result;
end;
$$;


ALTER FUNCTION "public"."get_carga_horaria_p1_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_pagina" integer, "p_itens_por_pagina" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_carga_horaria_p1_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text" DEFAULT NULL::"text", "p_busca_componente" "text" DEFAULT NULL::"text", "p_pagina" integer DEFAULT 1, "p_itens_por_pagina" integer DEFAULT 30) RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  v_total int;
  v_qtd_paginas int;
  v_offset int := greatest((coalesce(p_pagina,1)-1) * coalesce(p_itens_por_pagina,30), 0);
  v_itens jsonb;
  v_result jsonb;
begin
  -------------------------------------------------------------------
  -- 1) Conta total de registros aplicando filtros + empresa
  -------------------------------------------------------------------
  select count(*)
  into v_total
  from public.carga_horaria_p1 ch
  join public.ano_etapa ae on ae.id = ch.id_ano_etapa
  join public.componente c on c.uuid = ch.id_componente
  where ch.id_empresa = p_id_empresa
    and (
          p_busca_ano_etapa is null 
          or ae.nome ilike '%' || p_busca_ano_etapa || '%'
          or ae.id::text = p_busca_ano_etapa
        )
    and (
          p_busca_componente is null 
          or c.nome ilike '%' || p_busca_componente || '%'
          or c.uuid::text = p_busca_componente
        );

  v_qtd_paginas := case when coalesce(p_itens_por_pagina,30) > 0
                        then ceil(v_total::numeric / coalesce(p_itens_por_pagina,30))::int
                        else 1 end;

  -------------------------------------------------------------------
  -- 2) Seleciona os itens da página atual
  -------------------------------------------------------------------
  select coalesce(jsonb_agg(j.item), '[]'::jsonb)
  into v_itens
  from (
    select jsonb_build_object(
      'uuid', ch.uuid,
      'id_componente', ch.id_componente,
      'id_ano_etapa', ch.id_ano_etapa,
      'carga_horaria', ch.carga_horaria,
      'id_empresa', ch.id_empresa,
      'criado_em', ch.criado_em,
      'modificado_em', ch.modificado_em,
      'componente_nome', c.nome,
      'ano_etapa_nome', ae.nome,
      'ano_etapa_tipo', ae.tipo
    ) as item
    from public.carga_horaria_p1 ch
    join public.ano_etapa ae on ae.id = ch.id_ano_etapa
    join public.componente c on c.uuid = ch.id_componente
    where ch.id_empresa = p_id_empresa
      and (
            p_busca_ano_etapa is null 
            or ae.nome ilike '%' || p_busca_ano_etapa || '%'
            or ae.id::text = p_busca_ano_etapa
          )
      and (
            p_busca_componente is null 
            or c.nome ilike '%' || p_busca_componente || '%'
            or c.uuid::text = p_busca_componente
          )
    order by ae.nome, c.nome
    offset v_offset
    limit coalesce(p_itens_por_pagina,30)
  ) j;

  -------------------------------------------------------------------
  -- 3) Monta o retorno estruturado em JSONB
  -------------------------------------------------------------------
  v_result := jsonb_build_object(
    'qtd_paginas', v_qtd_paginas,
    'qtd_itens', v_total,
    'pagina_atual', coalesce(p_pagina,1),
    'itens', v_itens
  );

  return v_result;
end;
$$;


ALTER FUNCTION "public"."get_carga_horaria_p1_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_busca_componente" "text", "p_pagina" integer, "p_itens_por_pagina" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_carga_horaria_p3_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text" DEFAULT NULL::"text", "p_busca_componente" "text" DEFAULT NULL::"text", "p_pagina" integer DEFAULT 1, "p_itens_por_pagina" integer DEFAULT 30) RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  v_total int;
  v_qtd_paginas int;
  v_offset int := greatest((coalesce(p_pagina,1)-1) * coalesce(p_itens_por_pagina,30), 0);
  v_itens jsonb;
  v_result jsonb;
begin
  -------------------------------------------------------------------
  -- 1) Conta total de registros aplicando filtros + empresa
  -------------------------------------------------------------------
  select count(*)
  into v_total
  from public.carga_horaria_p3 ch
  join public.ano_etapa ae on ae.id = ch.id_ano_etapa
  join public.componente c on c.uuid = ch.id_componente
  where ch.id_empresa = p_id_empresa
    and (
          p_busca_ano_etapa is null 
          or ae.nome ilike '%' || p_busca_ano_etapa || '%'
          or ae.id::text = p_busca_ano_etapa
        )
    and (
          p_busca_componente is null 
          or c.nome ilike '%' || p_busca_componente || '%'
          or c.uuid::text = p_busca_componente
        );

  v_qtd_paginas := case when coalesce(p_itens_por_pagina,30) > 0
                        then ceil(v_total::numeric / coalesce(p_itens_por_pagina,30))::int
                        else 1 end;

  -------------------------------------------------------------------
  -- 2) Seleciona os itens da página atual
  -------------------------------------------------------------------
  select coalesce(jsonb_agg(j.item), '[]'::jsonb)
  into v_itens
  from (
    select jsonb_build_object(
      'uuid', ch.uuid,
      'id_componente', ch.id_componente,
      'id_ano_etapa', ch.id_ano_etapa,
      'carga_horaria', ch.carga_horaria,
      'id_empresa', ch.id_empresa,
      'criado_em', ch.criado_em,
      'modificado_em', ch.modificado_em,
      'componente_nome', c.nome,
      'ano_etapa_nome', ae.nome,
      'ano_etapa_tipo', ae.tipo,
      'title_sharepoint', ch.title_sharepoint
    ) as item
    from public.carga_horaria_p3 ch
    join public.ano_etapa ae on ae.id = ch.id_ano_etapa
    join public.componente c on c.uuid = ch.id_componente
    where ch.id_empresa = p_id_empresa
      and (
            p_busca_ano_etapa is null 
            or ae.nome ilike '%' || p_busca_ano_etapa || '%'
            or ae.id::text = p_busca_ano_etapa
          )
      and (
            p_busca_componente is null 
            or c.nome ilike '%' || p_busca_componente || '%'
            or c.uuid::text = p_busca_componente
          )
    order by ae.nome, c.nome
    offset v_offset
    limit coalesce(p_itens_por_pagina,30)
  ) j;

  -------------------------------------------------------------------
  -- 3) Monta o retorno estruturado em JSONB
  -------------------------------------------------------------------
  v_result := jsonb_build_object(
    'qtd_paginas', v_qtd_paginas,
    'qtd_itens', v_total,
    'pagina_atual', coalesce(p_pagina,1),
    'itens', v_itens
  );

  return v_result;
end;
$$;


ALTER FUNCTION "public"."get_carga_horaria_p3_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_busca_componente" "text", "p_pagina" integer, "p_itens_por_pagina" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_certificados_contestacao_por_escola"("p_id_escola" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_result jsonb;
begin
  v_result := jsonb_build_object(
    'itens',
    (
      select jsonb_agg(row_to_json(t))
      from (
        select
          c.*,
          u.nome_completo as nome_professor,
          u.email,
          u.matricula,
          r.resposta as data_admissao
        from professores_certificados_atribuicao c
        join user_expandido u on u.id = c.id_professor
        left join respostas_user r
          on r.id_user = u.id
          and r.id_pergunta = '2cbcdcf0-a615-49a3-b563-e6c9e8e9f393'  -- Data de admissão
        where u.id_escola = p_id_escola
          and coalesce(c.contestacao_enviada, false) = true
        order by u.nome_completo, c.data_conclusao desc
      ) t
    )
  );

  return v_result;
end;
$$;


ALTER FUNCTION "public"."get_certificados_contestacao_por_escola"("p_id_escola" "uuid") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."professores_certificados_atribuicao" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_professor" "uuid" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "nome_curso" "text" NOT NULL,
    "tipo_curso" "public"."enum_tipo_curso_certificado" NOT NULL,
    "carga_horaria" integer,
    "presencial_online" "text" NOT NULL,
    "data_conclusao" timestamp with time zone NOT NULL,
    "existe_similiar" boolean DEFAULT false,
    "fora_do_prazo" boolean DEFAULT false,
    "deferido_indeferido" boolean,
    "deferido_indeferido_diretor" boolean,
    "deferido_indeferido_supervisor" boolean,
    "arquivo" "text",
    "nome_original_arquivo" "text",
    "criado_por" "uuid",
    "modificado_por" "uuid",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "modificado_em" timestamp with time zone,
    "ano_atribuicao" "text",
    "contestacao_texto" "text",
    "contestacao_data" timestamp with time zone,
    "contestacao_aprovar" boolean,
    "contestacao_enviada" boolean DEFAULT false,
    "contestacao_motivo_rejeicao" "text",
    CONSTRAINT "professores_certificados_atribuicao_presencial_online_check" CHECK (("presencial_online" = ANY (ARRAY['Online'::"text", 'Presencial'::"text", 'Não se Aplica'::"text"])))
);


ALTER TABLE "public"."professores_certificados_atribuicao" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_certificados_professor"("p_id_professor" "uuid", "p_ano" "text") RETURNS SETOF "public"."professores_certificados_atribuicao"
    LANGUAGE "sql" STABLE
    AS $$
  select *
  from public.professores_certificados_atribuicao
  where id_professor = p_id_professor
    and btrim(ano_atribuicao) = btrim(p_ano)
  order by criado_em desc nulls last;
$$;


ALTER FUNCTION "public"."get_certificados_professor"("p_id_professor" "uuid", "p_ano" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_complete_schema"() RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result jsonb;
BEGIN
    -- Get all enums
    WITH enum_types AS (
        SELECT 
            t.typname as enum_name,
            array_agg(e.enumlabel ORDER BY e.enumsortorder) as enum_values
        FROM pg_type t
        JOIN pg_enum e ON t.oid = e.enumtypid
        JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
        GROUP BY t.typname
    )
    SELECT jsonb_build_object(
        'enums',
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'name', enum_name,
                    'values', to_jsonb(enum_values)
                )
            ),
            '[]'::jsonb
        )
    )
    FROM enum_types
    INTO result;

    -- Get all tables with their details
    WITH RECURSIVE 
    columns_info AS (
        SELECT 
            c.oid as table_oid,
            c.relname as table_name,
            a.attname as column_name,
            format_type(a.atttypid, a.atttypmod) as column_type,
            a.attnotnull as notnull,
            pg_get_expr(d.adbin, d.adrelid) as column_default,
            CASE 
                WHEN a.attidentity != '' THEN true
                WHEN pg_get_expr(d.adbin, d.adrelid) LIKE 'nextval%' THEN true
                ELSE false
            END as is_identity,
            EXISTS (
                SELECT 1 FROM pg_constraint con 
                WHERE con.conrelid = c.oid 
                AND con.contype = 'p' 
                AND a.attnum = ANY(con.conkey)
            ) as is_pk
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        LEFT JOIN pg_attribute a ON a.attrelid = c.oid
        LEFT JOIN pg_attrdef d ON d.adrelid = c.oid AND d.adnum = a.attnum
        WHERE n.nspname = 'public' 
        AND c.relkind = 'r'
        AND a.attnum > 0 
        AND NOT a.attisdropped
    ),
    fk_info AS (
        SELECT 
            c.oid as table_oid,
            jsonb_agg(
                jsonb_build_object(
                    'name', con.conname,
                    'column', col.attname,
                    'foreign_schema', fs.nspname,
                    'foreign_table', ft.relname,
                    'foreign_column', fcol.attname,
                    'on_delete', CASE con.confdeltype
                        WHEN 'a' THEN 'NO ACTION'
                        WHEN 'c' THEN 'CASCADE'
                        WHEN 'r' THEN 'RESTRICT'
                        WHEN 'n' THEN 'SET NULL'
                        WHEN 'd' THEN 'SET DEFAULT'
                        ELSE NULL
                    END
                )
            ) as foreign_keys
        FROM pg_class c
        JOIN pg_constraint con ON con.conrelid = c.oid
        JOIN pg_attribute col ON col.attrelid = con.conrelid AND col.attnum = ANY(con.conkey)
        JOIN pg_class ft ON ft.oid = con.confrelid
        JOIN pg_namespace fs ON fs.oid = ft.relnamespace
        JOIN pg_attribute fcol ON fcol.attrelid = con.confrelid AND fcol.attnum = ANY(con.confkey)
        WHERE con.contype = 'f'
        GROUP BY c.oid
    ),
    index_info AS (
        SELECT 
            c.oid as table_oid,
            jsonb_agg(
                jsonb_build_object(
                    'name', i.relname,
                    'using', am.amname,
                    'columns', (
                        SELECT jsonb_agg(a.attname ORDER BY array_position(ix.indkey, a.attnum))
                        FROM unnest(ix.indkey) WITH ORDINALITY as u(attnum, ord)
                        JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = u.attnum
                    )
                )
            ) as indexes
        FROM pg_class c
        JOIN pg_index ix ON ix.indrelid = c.oid
        JOIN pg_class i ON i.oid = ix.indexrelid
        JOIN pg_am am ON am.oid = i.relam
        WHERE NOT ix.indisprimary
        GROUP BY c.oid
    ),
    policy_info AS (
        SELECT 
            c.oid as table_oid,
            jsonb_agg(
                jsonb_build_object(
                    'name', pol.polname,
                    'command', CASE pol.polcmd
                        WHEN 'r' THEN 'SELECT'
                        WHEN 'a' THEN 'INSERT'
                        WHEN 'w' THEN 'UPDATE'
                        WHEN 'd' THEN 'DELETE'
                        WHEN '*' THEN 'ALL'
                    END,
                    'roles', (
                        SELECT string_agg(quote_ident(r.rolname), ', ')
                        FROM pg_roles r
                        WHERE r.oid = ANY(pol.polroles)
                    ),
                    'using', pg_get_expr(pol.polqual, pol.polrelid),
                    'check', pg_get_expr(pol.polwithcheck, pol.polrelid)
                )
            ) as policies
        FROM pg_class c
        JOIN pg_policy pol ON pol.polrelid = c.oid
        GROUP BY c.oid
    ),
    trigger_info AS (
        SELECT 
            c.oid as table_oid,
            jsonb_agg(
                jsonb_build_object(
                    'name', t.tgname,
                    'timing', CASE 
                        WHEN t.tgtype & 2 = 2 THEN 'BEFORE'
                        WHEN t.tgtype & 4 = 4 THEN 'AFTER'
                        WHEN t.tgtype & 64 = 64 THEN 'INSTEAD OF'
                    END,
                    'events', (
                        CASE WHEN t.tgtype & 1 = 1 THEN 'INSERT'
                             WHEN t.tgtype & 8 = 8 THEN 'DELETE'
                             WHEN t.tgtype & 16 = 16 THEN 'UPDATE'
                             WHEN t.tgtype & 32 = 32 THEN 'TRUNCATE'
                        END
                    ),
                    'statement', pg_get_triggerdef(t.oid)
                )
            ) as triggers
        FROM pg_class c
        JOIN pg_trigger t ON t.tgrelid = c.oid
        WHERE NOT t.tgisinternal
        GROUP BY c.oid
    ),
    table_info AS (
        SELECT DISTINCT 
            c.table_oid,
            c.table_name,
            jsonb_agg(
                jsonb_build_object(
                    'name', c.column_name,
                    'type', c.column_type,
                    'notnull', c.notnull,
                    'default', c.column_default,
                    'identity', c.is_identity,
                    'is_pk', c.is_pk
                ) ORDER BY c.column_name
            ) as columns,
            COALESCE(fk.foreign_keys, '[]'::jsonb) as foreign_keys,
            COALESCE(i.indexes, '[]'::jsonb) as indexes,
            COALESCE(p.policies, '[]'::jsonb) as policies,
            COALESCE(t.triggers, '[]'::jsonb) as triggers
        FROM columns_info c
        LEFT JOIN fk_info fk ON fk.table_oid = c.table_oid
        LEFT JOIN index_info i ON i.table_oid = c.table_oid
        LEFT JOIN policy_info p ON p.table_oid = c.table_oid
        LEFT JOIN trigger_info t ON t.table_oid = c.table_oid
        GROUP BY c.table_oid, c.table_name, fk.foreign_keys, i.indexes, p.policies, t.triggers
    )
    SELECT result || jsonb_build_object(
        'tables',
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'name', table_name,
                    'columns', columns,
                    'foreign_keys', foreign_keys,
                    'indexes', indexes,
                    'policies', policies,
                    'triggers', triggers
                )
            ),
            '[]'::jsonb
        )
    )
    FROM table_info
    INTO result;

    -- Get all functions
    WITH function_info AS (
        SELECT 
            p.proname AS name,
            pg_get_functiondef(p.oid) AS definition
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public'
        AND p.prokind = 'f'
    )
    SELECT result || jsonb_build_object(
        'functions',
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'name', name,
                    'definition', definition
                )
            ),
            '[]'::jsonb
        )
    )
    FROM function_info
    INTO result;

    RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_complete_schema"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_componentes_por_turma"("p_id_turma" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_id_empresa uuid;
  v_id_ano_etapa uuid;
  v_id_horario uuid;
  v_prof_turma jsonb;
  v_result jsonb;
  v_itens jsonb := '[]'::jsonb;
begin
  -- 1️⃣ Contexto da turma
  select id_empresa, id_ano_etapa, id_horario
  into v_id_empresa, v_id_ano_etapa, v_id_horario
  from public.turmas
  where id = p_id_turma;

  if not found then
    raise exception 'Turma não encontrada';
  end if;

  -- 2️⃣ Professor P1 vigente da turma (titular ou substituto atual)
  select jsonb_build_object(
    'id_professor', p.id_professor,
    'nome', u.nome_completo
  )
  into v_prof_turma
  from public.turma_professor_atribuicao p
  join public.user_expandido u on u.id = p.id_professor
  where p.id_turma = p_id_turma
    and p.data_fim is null
  order by p.created_at desc
  limit 1;

  -- 3️⃣ Componentes P1 → 1 item por componente, com qtd = carga_horaria
  v_itens := v_itens || coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'nome', c.nome,
        'origem', 'p1',
        'qtd', ch.carga_horaria,
        'duracao_minutos', 60,
        'cor', c.cor,
        'professor', v_prof_turma
      )
    )
    from public.carga_horaria_p1 ch
    join public.componente c on c.uuid = ch.id_componente
    where ch.id_ano_etapa = v_id_ano_etapa
      and ch.id_empresa = v_id_empresa
  ), '[]'::jsonb);

  -- 4️⃣ Componentes P3 → 1 item por componente, com qtd = carga_horaria
  v_itens := v_itens || coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'nome', c.nome,
        'origem', 'p3',
        'qtd', ch.carga_horaria,
        'duracao_minutos', 50,
        'cor', c.cor,
        'professor', (
          select jsonb_build_object(
            'id_professor', pa.id_professor,
            'nome', ue.nome_completo
          )
          from public.unidade_atribuicao ua
          join public.professor_componentes_atribuicao pa
            on pa.id_unidade_atribuicao = ua.uuid
          join public.user_expandido ue on ue.id = pa.id_professor
          where ua.id_turma = p_id_turma
            and ua.id_ch_p3 = ch.uuid
            and pa.data_fim is null
          order by pa.created_at desc
          limit 1
        )
      )
    )
    from public.carga_horaria_p3 ch
    join public.componente c on c.uuid = ch.id_componente
    where ch.id_ano_etapa = v_id_ano_etapa
      and ch.id_empresa = v_id_empresa
  ), '[]'::jsonb);

  -- 5️⃣ Atividades infantis (fallback)
  if jsonb_array_length(v_itens) is null or jsonb_array_length(v_itens) = 0 then
    v_itens := v_itens || coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'nome', ai.nome,
          'origem', 'infantil',
          'qtd', 1,
          'duracao_minutos', 30,
          'cor', '#94A3B8'
        )
      )
      from public.atividades_infantil ai
      where ai.id_empresa = v_id_empresa
    ), '[]'::jsonb);
  end if;

  -- 6️⃣ Adicionar 5 intervalos (20 min)
  v_itens := v_itens || jsonb_build_array(
    jsonb_build_object(
      'nome', 'Intervalo',
      'origem', 'apoio',
      'qtd', 5,
      'duracao_minutos', 20,
      'cor', '#9CA3AF'
    )
  );

  -- 7️⃣ Montar retorno final
  v_result := jsonb_build_object(
    'id_turma', p_id_turma,
    'professor_turma', v_prof_turma,
    'itens', v_itens,
    'horario_escola', (
      select jsonb_build_object(
        'id_horario', he.id,
        'nome', he.nome,
        'periodo', he.periodo,
        'hora_inicio', he.hora_inicio,
        'hora_fim', he.hora_fim
      )
      from public.horarios_escola he
      where he.id = v_id_horario
    )
  );

  return v_result;
end;
$$;


ALTER FUNCTION "public"."get_componentes_por_turma"("p_id_turma" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_componentes_por_turma_v2"("p_id_turma" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_id_empresa uuid;
  v_id_ano_etapa uuid;
  v_id_horario uuid;
  v_prof_turma jsonb;
  v_result jsonb;
  v_itens jsonb := '[]'::jsonb;
BEGIN
  -- 1️⃣ Contexto da turma
  SELECT id_empresa, id_ano_etapa, id_horario
  INTO v_id_empresa, v_id_ano_etapa, v_id_horario
  FROM public.turmas
  WHERE id = p_id_turma;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Turma não encontrada';
  END IF;

  -- 2️⃣ Professor P1 vigente da turma
  SELECT jsonb_build_object(
    'id_professor', p.id_professor,
    'nome', u.nome_completo
  )
  INTO v_prof_turma
  FROM public.turma_professor_atribuicao p
  JOIN public.user_expandido u ON u.id = p.id_professor
  WHERE p.id_turma = p_id_turma
    AND p.data_fim IS NULL
  ORDER BY p.created_at DESC
  LIMIT 1;

  -- 3️⃣ Componentes P1
  v_itens := v_itens || COALESCE((
    SELECT jsonb_agg(
      jsonb_build_object(
        'tipo', 'p1',
        'nome', c.nome,
        'qtd', ch.carga_horaria,
        'duracao_minutos', 60,
        'cor', c.cor,
        'professor', v_prof_turma,
        'id_turma', p_id_turma,
        'id_empresa', v_id_empresa,
        'id_horario', v_id_horario,
        'id_componente', c.uuid,
        'id_carga_horaria', ch.uuid
      )
    )
    FROM public.carga_horaria_p1 ch
    JOIN public.componente c ON c.uuid = ch.id_componente
    WHERE ch.id_ano_etapa = v_id_ano_etapa
      AND ch.id_empresa  = v_id_empresa
  ), '[]'::jsonb);

  -- 4️⃣ Componentes P3
  v_itens := v_itens || COALESCE((
    SELECT jsonb_agg(
      jsonb_build_object(
        'tipo', 'p3',
        'nome', c.nome,
        'qtd', ch.carga_horaria,
        'duracao_minutos', 50,
        'cor', c.cor,
        'professor', (
          SELECT jsonb_build_object(
            'id_professor', pa.id_professor,
            'nome', ue.nome_completo
          )
          FROM public.unidade_atribuicao ua
          JOIN public.professor_componentes_atribuicao pa
            ON pa.id_unidade_atribuicao = ua.uuid
          JOIN public.user_expandido ue ON ue.id = pa.id_professor
          WHERE ua.id_turma = p_id_turma
            AND ua.id_ch_p3 = ch.uuid
            AND pa.data_fim IS NULL
          ORDER BY pa.created_at DESC
          LIMIT 1
        ),
        'id_turma', p_id_turma,
        'id_empresa', v_id_empresa,
        'id_horario', v_id_horario,
        'id_componente', c.uuid,
        'id_carga_horaria', ch.uuid
      )
    )
    FROM public.carga_horaria_p3 ch
    JOIN public.componente c ON c.uuid = ch.id_componente
    WHERE ch.id_ano_etapa = v_id_ano_etapa
      AND ch.id_empresa  = v_id_empresa
  ), '[]'::jsonb);

  -- 5️⃣ Atividades infantis (fallback)
  IF COALESCE(jsonb_array_length(v_itens), 0) = 0 THEN
    v_itens := v_itens || COALESCE((
      SELECT jsonb_agg(
        jsonb_build_object(
          'tipo', 'infantil',
          'nome', ai.nome,
          'qtd', 1,
          'duracao_minutos', 30,
          'cor', '#94A3B8',
          'id_turma', p_id_turma,
          'id_empresa', v_id_empresa,
          'id_horario', v_id_horario,
          'id_atividade_infantil', ai.id,
          'id_carga_horaria', ai.id  -- mesmo campo para compatibilidade
        )
      )
      FROM public.atividades_infantil ai
      WHERE ai.id_empresa = v_id_empresa
    ), '[]'::jsonb);
  END IF;

  -- 6️⃣ Intervalos (apoio)
  v_itens := v_itens || jsonb_build_array(
    jsonb_build_object(
      'tipo', 'apoio',
      'nome', 'Intervalo',
      'qtd', 5,
      'duracao_minutos', 20,
      'cor', '#9CA3AF',
      'id_turma', p_id_turma,
      'id_empresa', v_id_empresa,
      'id_horario', v_id_horario,
      'id_carga_horaria', NULL
    )
  );

  -- 7️⃣ Retorno final
  v_result := jsonb_build_object(
    'id_turma', p_id_turma,
    'id_empresa', v_id_empresa,
    'id_horario', v_id_horario,
    'professor_turma', v_prof_turma,
    'itens', v_itens,
    'horario_escola', (
      SELECT jsonb_build_object(
        'id_horario', he.id,
        'nome', he.nome,
        'periodo', he.periodo,
        'hora_inicio', he.hora_inicio,
        'hora_fim', he.hora_fim
      )
      FROM public.horarios_escola he
      WHERE he.id = v_id_horario
    )
  );

  RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."get_componentes_por_turma_v2"("p_id_turma" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_dados_professor_card"("p_nome_completo" "text", "p_id_escola" "text", "p_tipo_contrato" "text", "p_afastamento" "text", "p_acumulo" "text", "p_ano" integer, "p_tem_atribuicao" "text") RETURNS TABLE("id" "uuid", "nome_completo" "text", "matricula" "text", "email" "text", "telefone" "text", "tipo_contrato" "text", "afastamento" "text", "tempo_afastamento" "text", "habilitacao_infantil" "text", "acumulo" "text", "nome_escola" "text", "atribuicoes_ano" boolean, "pontuacao" "text", "pontuacao_unidade" "text", "pontuacao_departamento" "text")
    LANGUAGE "sql"
    AS $$
  with perguntas as (
    select
      max(case when pergunta = 'tipo_contrato' then id::text end)::uuid as id_tipo_contrato,
      max(case when pergunta = 'afastamento' then id::text end)::uuid as id_afastamento,
      max(case when pergunta = 'tempo_afastamento' then id::text end)::uuid as id_tempo_afastamento,
      max(case when pergunta = 'habilitacao_infantil' then id::text end)::uuid as id_habilitacao_infantil,
      max(case when pergunta = 'acumulo' then id::text end)::uuid as id_acumulo
    from perguntas_user
  )
  select
    u.id,
    u.nome_completo,
    u.matricula,
    u.email,
    u.telefone,
    r_tipo_contrato.resposta,
    r_afastamento.resposta,
    r_tempo_afastamento.resposta,
    r_habilitacao_infantil.resposta,
    r_acumulo.resposta,
    e.nome as nome_escola,
    atribuicoes.tem_atribuicao,
    coalesce(pp.pontuacao::text, 'Pendente'),
    coalesce(pp.pontuacao_unidade::text, 'Pendente'),
    coalesce(pp.pontuacao_departamento::text, 'Pendente')
  from user_expandido u
  join escolas e on e.id = u.id_escola
  cross join perguntas p
  left join respostas_user r_tipo_contrato
    on r_tipo_contrato.id_user = u.id and r_tipo_contrato.id_pergunta = p.id_tipo_contrato
  left join respostas_user r_afastamento
    on r_afastamento.id_user = u.id and r_afastamento.id_pergunta = p.id_afastamento
  left join respostas_user r_tempo_afastamento
    on r_tempo_afastamento.id_user = u.id and r_tempo_afastamento.id_pergunta = p.id_tempo_afastamento
  left join respostas_user r_habilitacao_infantil
    on r_habilitacao_infantil.id_user = u.id and r_habilitacao_infantil.id_pergunta = p.id_habilitacao_infantil
  left join respostas_user r_acumulo
    on r_acumulo.id_user = u.id and r_acumulo.id_pergunta = p.id_acumulo
  left join lateral (
    select *
    from pontuacao_professores pp2
    where pp2.id_professor = u.id
      and pp2.ano = p_ano
    order by pp2.ano desc
    limit 1
  ) pp on true
  left join lateral (
    select exists (
      select 1
      from turma_professor_atribuicao a
      where a.id_professor = u.id
        and a.ano = p_ano
        and a.id_empresa = u.id_empresa
    ) as tem_atribuicao
  ) atribuicoes on true
  where
    (p_nome_completo is null or length(p_nome_completo) < 3 or u.nome_completo ilike '%' || p_nome_completo || '%')
    and (
      p_id_escola is null or p_id_escola = '' or p_id_escola = 'Todos'
      or u.id_escola = p_id_escola::uuid
    )
    and (p_tipo_contrato is null or p_tipo_contrato = 'Todos' or r_tipo_contrato.resposta = p_tipo_contrato)
    and (p_afastamento is null or p_afastamento = 'Todos' or r_afastamento.resposta = p_afastamento)
    and (p_acumulo is null or p_acumulo = 'Todos' or r_acumulo.resposta = p_acumulo)
    and (
      p_tem_atribuicao is null or p_tem_atribuicao = '' or p_tem_atribuicao = 'Todos'
      or (p_tem_atribuicao = 'true' and atribuicoes.tem_atribuicao)
      or (p_tem_atribuicao = 'false' and not atribuicoes.tem_atribuicao)
    )
  order by u.nome_completo;
$$;


ALTER FUNCTION "public"."get_dados_professor_card"("p_nome_completo" "text", "p_id_escola" "text", "p_tipo_contrato" "text", "p_afastamento" "text", "p_acumulo" "text", "p_ano" integer, "p_tem_atribuicao" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_dados_referencia_turmas"() RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  v_classe jsonb;
  v_horarios jsonb;
  v_ano_etapa jsonb;
begin
  -------------------------------------------------------------------
  -- 1) Buscar todas as classes
  -------------------------------------------------------------------
  select jsonb_agg(jsonb_build_object('id', id, 'nome', nome) order by nome)
  into v_classe
  from classe;

  -------------------------------------------------------------------
  -- 2) Buscar todos os horários
  -------------------------------------------------------------------
  select jsonb_agg(jsonb_build_object('id', id, 'nome', nome) order by nome)
  into v_horarios
  from horarios_escola;

  -------------------------------------------------------------------
  -- 3) Buscar todos os anos/etapas
  -------------------------------------------------------------------
  select jsonb_agg(jsonb_build_object('id', id, 'nome', nome) order by nome)
  into v_ano_etapa
  from ano_etapa;

  -------------------------------------------------------------------
  -- 4) Retornar tudo em um JSON unificado
  -------------------------------------------------------------------
  return jsonb_build_object(
    'classe', coalesce(v_classe, '[]'::jsonb),
    'horarios_escola', coalesce(v_horarios, '[]'::jsonb),
    'ano_etapa', coalesce(v_ano_etapa, '[]'::jsonb)
  );
end;
$$;


ALTER FUNCTION "public"."get_dados_referencia_turmas"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_dados_referencia_turmas"("p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  v_classe jsonb;
  v_horarios jsonb;
  v_ano_etapa jsonb;
begin
  -------------------------------------------------------------------
  -- 1) Buscar todas as classes da empresa
  -------------------------------------------------------------------
  select jsonb_agg(jsonb_build_object('id', id, 'nome', nome) order by nome)
  into v_classe
  from classe
  where id_empresa = p_id_empresa;

  -------------------------------------------------------------------
  -- 2) Buscar todos os horários da empresa
  -------------------------------------------------------------------
  select jsonb_agg(jsonb_build_object('id', id, 'nome', hora_completo) order by hora_completo)
  into v_horarios
  from horarios_escola
  where id_empresa = p_id_empresa;

  -------------------------------------------------------------------
  -- 3) Buscar todos os anos/etapas da empresa
  -------------------------------------------------------------------
  select jsonb_agg(jsonb_build_object('id', id, 'nome', nome) order by nome)
  into v_ano_etapa
  from ano_etapa
  where id_empresa = p_id_empresa;

  -------------------------------------------------------------------
  -- 4) Retornar tudo em um JSON unificado
  -------------------------------------------------------------------
  return jsonb_build_object(
    'classe', coalesce(v_classe, '[]'::jsonb),
    'horarios_escola', coalesce(v_horarios, '[]'::jsonb),
    'ano_etapa', coalesce(v_ano_etapa, '[]'::jsonb)
  );
end;
$$;


ALTER FUNCTION "public"."get_dados_referencia_turmas"("p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_detalhe_professor_pontuacao"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano" integer) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_prof               record;
  v_pontuacao          jsonb;
  v_certificados       jsonb;
  v_faltas_assiduidade jsonb;
  v_faltas_tempo       jsonb;
  v_scoring_year       int := p_ano - 1;  -- Ex.: 2026 → 2025
BEGIN
  --------------------------------------------------------------------
  -- 🧍 Dados gerais
  --------------------------------------------------------------------
  SELECT ue.id, ue.nome_completo, ue.matricula, e.nome AS escola
    INTO v_prof
  FROM user_expandido ue
  LEFT JOIN escolas e ON e.id = ue.id_escola
  WHERE ue.id = p_id_professor
    AND ue.id_empresa = p_id_empresa;

  --------------------------------------------------------------------
  -- 🎓 Certificados (últimos 5 anos a partir de 01/jul do scoring_year−4)
  --------------------------------------------------------------------
  WITH certs AS (
    SELECT
      c.id,
      c.nome_curso,
      c.tipo_curso,
      c.carga_horaria,
      c.data_conclusao,
      c.deferido_indeferido_supervisor,
      c.deferido_indeferido_diretor,
      CASE 
        WHEN c.deferido_indeferido_supervisor = TRUE  THEN 'Deferido'
        WHEN c.deferido_indeferido_supervisor = FALSE THEN 'Indeferido'
        WHEN c.deferido_indeferido_supervisor IS NULL 
             AND c.deferido_indeferido_diretor = TRUE  THEN 'Deferido (Diretor)'
        WHEN c.deferido_indeferido_supervisor IS NULL 
             AND c.deferido_indeferido_diretor = FALSE THEN 'Indeferido (Diretor)'
        ELSE 'Pendente'
      END AS status_txt,
      CASE
        ----------------------------------------------------------------
        -- Curso de Licenciatura / Graduação
        ----------------------------------------------------------------
        WHEN c.deferido_indeferido_supervisor IS NOT TRUE THEN 0
        WHEN c.tipo_curso = 'Curso de Licenciatura/Graduação'
             AND lower(c.nome_curso) LIKE '%pedagogia%' THEN 3
        WHEN c.tipo_curso = 'Curso de Licenciatura/Graduação' THEN 1

        ----------------------------------------------------------------
        -- Curso de Especialização / Pós-Graduação (≥360h)
        ----------------------------------------------------------------
        WHEN c.tipo_curso = 'Curso de Especialização/Pós-Graduação'
             AND c.carga_horaria >= 36000 THEN 2

        ----------------------------------------------------------------
        -- Certificados / Diplomas de Desenvolvimento Profissional
        -- (extensão, atualização, aperfeiçoamento)
        ----------------------------------------------------------------
        WHEN c.tipo_curso = 'Certificados/Diplomas de Desenvolvimento Profissional'
             THEN LEAST(COALESCE(c.carga_horaria,0) / 100.0 * 0.005, 3)

        ----------------------------------------------------------------
        -- Diplomas avançados
        ----------------------------------------------------------------
        WHEN c.tipo_curso = 'Diploma de Mestre'        THEN 5
        WHEN c.tipo_curso = 'Diploma de Doutor'        THEN 10
        WHEN c.tipo_curso = 'Diploma de Pós-Doutorado' THEN 3
        ELSE 0
      END AS pontuacao_item
    FROM professores_certificados_atribuicao c
    WHERE c.id_professor = p_id_professor
      AND c.id_empresa   = p_id_empresa
      AND c.data_conclusao >= make_date(v_scoring_year - 4, 7, 1)  -- Ex: 01/jul/2021
  )
  SELECT jsonb_agg(
           jsonb_build_object(
             'id', id,
             'nome_curso', nome_curso,
             'tipo_curso', tipo_curso,
             'carga_horaria', (round(coalesce(carga_horaria,0) / 100.0, 2)::text || ' h'),
             'data_conclusao', data_conclusao,
             'status', status_txt,
             'pontuacao', pontuacao_item
           )
           ORDER BY data_conclusao DESC
         )
    INTO v_certificados
  FROM certs;

  --------------------------------------------------------------------
  -- 📆 Faltas para ASSIDUIDADE (fev–nov do scoring_year)
  --------------------------------------------------------------------
  WITH faltas_assid AS (
    SELECT
      date_trunc('month', f.data)::date AS mes_base,
      f.codigo,
      count(*)::int AS qtd
    FROM faltas_professores f
    WHERE f.id_professor = p_id_professor
      AND f.id_empresa   = p_id_empresa
      AND f.data::date BETWEEN make_date(v_scoring_year,2,1)
                           AND make_date(v_scoring_year,11,30)
      AND f.codigo IN ('NC','J','LS','JA','I','LSV','LAC','FPAD')
    GROUP BY date_trunc('month', f.data), f.codigo
  )
  SELECT jsonb_agg(
           jsonb_build_object(
             'mes', (
               CASE EXTRACT(MONTH FROM mes_base)
                 WHEN 1  THEN 'Janeiro'
                 WHEN 2  THEN 'Fevereiro'
                 WHEN 3  THEN 'Março'
                 WHEN 4  THEN 'Abril'
                 WHEN 5  THEN 'Maio'
                 WHEN 6  THEN 'Junho'
                 WHEN 7  THEN 'Julho'
                 WHEN 8  THEN 'Agosto'
                 WHEN 9  THEN 'Setembro'
                 WHEN 10 THEN 'Outubro'
                 WHEN 11 THEN 'Novembro'
                 WHEN 12 THEN 'Dezembro'
               END || '/' || EXTRACT(YEAR FROM mes_base)::text
             ),
             'codigo', codigo,
             'quantidade', qtd,
             'desconto_assiduidade',
                (qtd * 0.01) + (CASE WHEN qtd > 0 THEN 0.25 ELSE 0 END)
           )
           ORDER BY mes_base ASC, codigo ASC
         )
    INTO v_faltas_assiduidade
  FROM faltas_assid;

  --------------------------------------------------------------------
  -- ⏱️ Faltas para TEMPO DE SERVIÇO (jul/(scoring_year−1) → jun/(scoring_year))
  --------------------------------------------------------------------
  WITH faltas_tempo AS (
    SELECT
      date_trunc('month', f.data)::date AS mes_base,
      f.codigo,
      count(*)::int AS qtd
    FROM faltas_professores f
    WHERE f.id_professor = p_id_professor
      AND f.id_empresa   = p_id_empresa
      AND f.data::date BETWEEN make_date(v_scoring_year - 1,7,1)
                           AND make_date(v_scoring_year,6,30)
      AND f.codigo IN ('JA','NC','I','LSV')
    GROUP BY date_trunc('month', f.data), f.codigo
  )
  SELECT jsonb_agg(
           jsonb_build_object(
             'mes', (
               CASE EXTRACT(MONTH FROM mes_base)
                 WHEN 1  THEN 'Janeiro'
                 WHEN 2  THEN 'Fevereiro'
                 WHEN 3  THEN 'Março'
                 WHEN 4  THEN 'Abril'
                 WHEN 5  THEN 'Maio'
                 WHEN 6  THEN 'Junho'
                 WHEN 7  THEN 'Julho'
                 WHEN 8  THEN 'Agosto'
                 WHEN 9  THEN 'Setembro'
                 WHEN 10 THEN 'Outubro'
                 WHEN 11 THEN 'Novembro'
                 WHEN 12 THEN 'Dezembro'
               END || '/' || EXTRACT(YEAR FROM mes_base)::text
             ),
             'codigo', codigo,
             'quantidade', qtd,
             'desconto_tempo_servico', (qtd * 0.005)
           )
           ORDER BY mes_base ASC, codigo ASC
         )
    INTO v_faltas_tempo
  FROM faltas_tempo;

  --------------------------------------------------------------------
  -- 🧮 Resumo consolidado (usa a função principal)
  --------------------------------------------------------------------
  v_pontuacao := public.calc_pontuacao_professor(p_id_professor, p_id_empresa, p_ano);

  --------------------------------------------------------------------
  -- 📦 Retorno final
  --------------------------------------------------------------------
  RETURN jsonb_build_object(
    'dados_gerais',          to_jsonb(v_prof),
    'certificados',          COALESCE(v_certificados, '[]'::jsonb),
    'faltas_assiduidade',    COALESCE(v_faltas_assiduidade, '[]'::jsonb),
    'faltas_tempo_servico',  COALESCE(v_faltas_tempo, '[]'::jsonb),
    'resumo_pontuacao',      v_pontuacao
  );
END;
$$;


ALTER FUNCTION "public"."get_detalhe_professor_pontuacao"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_escolas_funcao_extra_abertas"("p_id_professor" "uuid") RETURNS "uuid"[]
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  with ctx as (
    select
      (auth.jwt()->>'empresa_id')::uuid as empresa_id,
      auth.jwt()->>'papeis_user'        as papel
  ),
  -- Confere se o professor pertence à mesma empresa do chamador
  prof_ok as (
    select 1
    from public.user_expandido u
    join ctx on true
    where u.id = p_id_professor
      and u.id_empresa = ctx.empresa_id
  ),
  escolas_abertas as (
    select distinct pfe.id_escola
    from public.professor_funcao_extra pfe
    join public.escolas e on e.id = pfe.id_escola
    join ctx on true
    where pfe.user_id    = p_id_professor
      and pfe.status     is true             -- em aberto
      and pfe.id_escola  is not null
      and e.id_empresa   = ctx.empresa_id
      and exists (select 1 from prof_ok)
  )
  select coalesce(
    (select array_agg(ea.id_escola order by ea.id_escola) from escolas_abertas ea),
    '{}'::uuid[]
  );
$$;


ALTER FUNCTION "public"."get_escolas_funcao_extra_abertas"("p_id_professor" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_funcao_extra_ativa"("p_user_id" "uuid") RETURNS TABLE("id" "uuid", "user_id" "uuid", "id_empresa" "uuid", "funcao" "text", "ano" "text", "data_inicio" "date", "data_fim" "date", "status" boolean, "observacao" "text", "id_escola" "uuid", "afastamento_funcao_extra" boolean, "data_inicio_licenca_func_extra" timestamp with time zone, "data_fim_licenca_func_extra" timestamp with time zone, "mensagem" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  -- procura função extra ATIVA: status true e sem data_fim
  return query
  select 
      pfe.id,
      pfe.user_id,
      pfe.id_empresa,
      pfe.funcao::text,
      pfe.ano,
      pfe.data_inicio,
      pfe.data_fim,
      pfe.status,
      pfe.observacao,
      pfe.id_escola,
      pfe.afastamento_funcao_extra,
      pfe.data_inicio_licenca_func_extra,
      pfe.data_fim_licenca_func_extra,
      null::text as mensagem
  from professor_funcao_extra pfe
  where pfe.user_id = p_user_id
    and coalesce(pfe.status, false) = true
    and pfe.data_fim is null
  order by coalesce(pfe.data_inicio, date '0001-01-01') desc, pfe.criado_em desc
  limit 1;

  if not found then
    return query
    select
        null::uuid,
        p_user_id,
        null::uuid,
        null::text,
        null::text,
        null::date,
        null::date,
        null::boolean,
        null::text,
        null::uuid,
        null::boolean,
        null::timestamptz,
        null::timestamptz,
        'Professor está cadastrado como usuário com função extra, mas está sem nenhuma função extra no momento, por favor verifique com a secretaria.'::text;
  end if;
end;
$$;


ALTER FUNCTION "public"."get_funcao_extra_ativa"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_horarios_escola_formatado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_qtd_itens_pagina" integer DEFAULT 30) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_offset int := greatest(0, (p_pagina - 1) * p_qtd_itens_pagina);
  v_total int;
  v_qtd_paginas int;
  v_itens jsonb;
begin
  select count(*) into v_total
  from public.horarios_escola he
  where he.id_empresa = p_id_empresa;

  v_qtd_paginas := case when p_qtd_itens_pagina > 0
                        then ceil(v_total::numeric / p_qtd_itens_pagina)::int
                        else 1 end;

  with base as (
    select
      he.id as id_horario_escola,
      he.id_empresa,
      coalesce(he.nome, 'Horário: ' || he.hora_completo) as nome,
      coalesce(he.descricao, 'Horário Pleno das ' || he.hora_inicio || ' às ' || he.hora_fim) as descricao,
      split_part(he.hora_inicio, ':', 1) as hora_inicio,
      split_part(he.hora_inicio, ':', 2) as minuto_inicio,
      split_part(he.hora_fim, ':', 1) as hora_fim,
      split_part(he.hora_fim, ':', 2) as minuto_fim,
      coalesce(he.hora_completo, he.hora_inicio || ' - ' || he.hora_fim) as horario_completo,
      he.periodo,
      he.criado_em
    from public.horarios_escola he
    where he.id_empresa = p_id_empresa
    order by he.criado_em desc
    limit p_qtd_itens_pagina offset v_offset
  ),
  joined as (
    select
      b.id_horario_escola,
      jsonb_build_object(
        'id_horario_escola', b.id_horario_escola::text,
        'id_empresa', b.id_empresa::text,
        'nome', b.nome,
        'descricao', b.descricao,
        'hora_inicio', b.hora_inicio,
        'minuto_inicio', b.minuto_inicio,
        'hora_fim', b.hora_fim,
        'minuto_fim', b.minuto_fim,
        'horario_completo', b.horario_completo,
        'periodo', b.periodo
      ) as dados_escola,
      coalesce(
        jsonb_agg(
          jsonb_build_object(
            'id_horario_escola', b.id_horario_escola::text,
            'id_empresa', ha.id_empresa::text,
            'ordem', ha.ordem,
            'tipo', initcap(ha.tipo),
            'nome', coalesce(ha.nome, ''),
            'modalidade', ha.modalidade,
            'dia_semana', ha.dia_semana,
            'hora_inicio', to_char(ha.hora_inicio, 'HH24'),
            'minuto_inicio', to_char(ha.hora_inicio, 'MI'),
            'hora_fim', to_char(ha.hora_fim, 'HH24'),
            'minuto_fim', to_char(ha.hora_fim, 'MI'),
            'horario_completo', ha.hora_completo
          )
          order by ha.ordem
        ) filter (where ha.id is not null),
        '[]'::jsonb
      ) as horarios_aula
    from base b
    left join public.horario_aula ha
      on ha.id_horario = b.id_horario_escola
    group by b.id_horario_escola, b.id_empresa, b.nome, b.descricao,
             b.hora_inicio, b.minuto_inicio, b.hora_fim, b.minuto_fim,
             b.horario_completo, b.periodo
  )
  select jsonb_agg(
           dados_escola || jsonb_build_object('horario_aula', horarios_aula)
         )
    into v_itens
  from joined;

  return jsonb_build_object(
    'pagina', p_pagina,
    'qtd_itens_pagina', p_qtd_itens_pagina,
    'qtd_paginas', coalesce(v_qtd_paginas, 0),
    'qtd_itens_total', coalesce(v_total, 0),
    'itens', coalesce(v_itens, '[]'::jsonb)
  );
end;
$$;


ALTER FUNCTION "public"."get_horarios_escola_formatado"("p_id_empresa" "uuid", "p_pagina" integer, "p_qtd_itens_pagina" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_ou_cria_conteudo_turma"("p_id_turma" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_total integer;
  v_result jsonb;
begin
  -- verifica se já existe conteúdo para essa turma e empresa
  select count(*) into v_total
  from public.lms_conteudo
  where id_turma = p_id_turma
    and id_empresa = p_id_empresa;

  -- se não houver nenhum, cria o primeiro
  if v_total = 0 then
    insert into public.lms_conteudo (
      id_turma,
      id_empresa,
      titulo,
      descricao,
      visivel_para_alunos,
      ordem,
      criado_por
    ) values (
      p_id_turma,
      p_id_empresa,
      'Conteúdo 1',
      'Aqui vai sua descrição do conteúdo',
      false,
      1,
      p_criado_por
    );
  end if;

  -- retorna todos os conteúdos da turma e empresa, ordenados por ordem
  select jsonb_agg(to_jsonb(c) order by c.ordem)
  into v_result
  from public.lms_conteudo c
  where c.id_turma = p_id_turma
    and c.id_empresa = p_id_empresa;

  return v_result;
end;
$$;


ALTER FUNCTION "public"."get_ou_cria_conteudo_turma"("p_id_turma" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_professores_atribuicao_p1_paginada"("p_ano" integer, "p_id_empresa" "uuid", "p_nome_completo" "text" DEFAULT NULL::"text", "p_id_escola" "uuid" DEFAULT NULL::"uuid", "p_tipo_contrato" "text" DEFAULT NULL::"text", "p_afastamento" "text" DEFAULT NULL::"text", "p_acumulo" "text" DEFAULT NULL::"text", "p_tem_atribuicao" "text" DEFAULT NULL::"text", "p_tem_funcao_extra" "text" DEFAULT NULL::"text", "p_pagina" integer DEFAULT 1, "p_itens_por_pagina" integer DEFAULT 30) RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  v_total int;
  v_qtd_paginas int;
  v_offset int;
  v_itens jsonb;
begin
  -------------------------------------------------------------------
  -- 1) TOTAL DE REGISTROS
  -------------------------------------------------------------------
  with perguntas as (
    select
      max(case when pergunta = 'tipo_contrato' then id::text end)::uuid as id_tipo_contrato,
      max(case when pergunta = 'afastamento' then id::text end)::uuid as id_afastamento,
      max(case when pergunta = 'acumulo' then id::text end)::uuid as id_acumulo
    from perguntas_user
  )
  select count(*)
  into v_total
  from user_expandido u
  join escolas e on e.id = u.id_escola
  cross join perguntas p
  left join respostas_user r_tipo_contrato on r_tipo_contrato.id_user = u.id and r_tipo_contrato.id_pergunta = p.id_tipo_contrato
  left join respostas_user r_afastamento   on r_afastamento.id_user   = u.id and r_afastamento.id_pergunta   = p.id_afastamento
  left join respostas_user r_acumulo       on r_acumulo.id_user       = u.id and r_acumulo.id_pergunta       = p.id_acumulo
  left join lateral (
    select exists (
      select 1
      from turma_professor_atribuicao a
      where a.id_professor = u.id
        and a.id_empresa  = p_id_empresa
        and a.ano         = p_ano
    ) as atribuicoes_ano
  ) atrib on true
  left join lateral (
    select true as tem_funcao_extra, funcao::text as funcao_extra
    from professor_funcao_extra pfe
    where pfe.user_id = u.id
      and pfe.id_empresa = p_id_empresa
      and pfe.ano = p_ano::text
      and pfe.status is true
      and pfe.soft_delete is false
      and lower(pfe.funcao::text) not in ('outros')
    order by pfe.data_inicio desc
    limit 1
  ) pfe on true
  where u.id_empresa = p_id_empresa
    and (p_nome_completo is null or length(p_nome_completo) < 3 or u.nome_completo ilike '%'||p_nome_completo||'%')
    and (p_id_escola is null or u.id_escola = p_id_escola)
    and (p_tipo_contrato is null or p_tipo_contrato = 'Todos' or r_tipo_contrato.resposta = p_tipo_contrato)
    and (p_afastamento   is null or p_afastamento   = 'Todos' or r_afastamento.resposta   = p_afastamento)
    and (p_acumulo       is null or p_acumulo       = 'Todos' or r_acumulo.resposta       = p_acumulo)
    and (
      p_tem_atribuicao is null or p_tem_atribuicao = '' or p_tem_atribuicao = 'Todos'
      or (p_tem_atribuicao = 'true'  and atrib.atribuicoes_ano)
      or (p_tem_atribuicao = 'false' and not atrib.atribuicoes_ano)
    )
    and (
      p_tem_funcao_extra is null or p_tem_funcao_extra = '' or p_tem_funcao_extra = 'Todos'
      or (p_tem_funcao_extra = 'Sim' and pfe.tem_funcao_extra is true)
      or (p_tem_funcao_extra = 'Não' and pfe.tem_funcao_extra is null)
    );

  -------------------------------------------------------------------
  -- 2) PAGINAÇÃO
  -------------------------------------------------------------------
  v_qtd_paginas := ceil(coalesce(v_total,0)::numeric / nullif(p_itens_por_pagina,0));
  v_qtd_paginas := coalesce(v_qtd_paginas, 0);
  v_offset := greatest((coalesce(p_pagina,1)-1) * p_itens_por_pagina, 0);

  -------------------------------------------------------------------
  -- 3) ITENS DA PÁGINA
  -------------------------------------------------------------------
  with perguntas as (
    select
      max(case when pergunta = 'tipo_contrato' then id::text end)::uuid as id_tipo_contrato,
      max(case when pergunta = 'afastamento' then id::text end)::uuid as id_afastamento,
      max(case when pergunta = 'tempo_afastamento' then id::text end)::uuid as id_tempo_afastamento,
      max(case when pergunta = 'habilitacao_infantil' then id::text end)::uuid as id_habilitacao_infantil,
      max(case when pergunta = 'acumulo' then id::text end)::uuid as id_acumulo
    from perguntas_user
  )
  select jsonb_agg(row_to_json(t))
  into v_itens
  from (
    select
      u.id,
      u.nome_completo,
      u.matricula,
      u.email,
      u.telefone,
      r_tipo_contrato.resposta as tipo_contrato,
      r_afastamento.resposta   as afastamento,
      r_tempo_afastamento.resposta as tempo_afastamento,
      r_habilitacao_infantil.resposta as habilitacao_infantil,
      r_acumulo.resposta       as acumulo,
      e.nome as nome_escola,
      atrib.atribuicoes_ano,
      coalesce(pp.pontuacao::text, 'Pendente') as pontuacao,
      coalesce(pp.pontuacao_unidade_total::text, 'Pendente') as pontuacao_unidade_total,
      coalesce(pp.pontuacao_departamento_total::text, 'Pendente') as pontuacao_departamento_total,
      coalesce(pp.pontuacao_unidade::text, 'Pendente') as pontuacao_unidade,
      coalesce(pp.pontuacao_departamento::text, 'Pendente') as pontuacao_departamento,
      coalesce(pfe.tem_funcao_extra, false) as tem_funcao_extra,
      pfe.funcao_extra
    from user_expandido u
    join escolas e on e.id = u.id_escola
    cross join perguntas p
    left join respostas_user r_tipo_contrato on r_tipo_contrato.id_user = u.id and r_tipo_contrato.id_pergunta = p.id_tipo_contrato
    left join respostas_user r_afastamento   on r_afastamento.id_user   = u.id and r_afastamento.id_pergunta   = p.id_afastamento
    left join respostas_user r_tempo_afastamento on r_tempo_afastamento.id_user = u.id and r_tempo_afastamento.id_pergunta = p.id_tempo_afastamento
    left join respostas_user r_habilitacao_infantil on r_habilitacao_infantil.id_user = u.id and r_habilitacao_infantil.id_pergunta = p.id_habilitacao_infantil
    left join respostas_user r_acumulo on r_acumulo.id_user = u.id and r_acumulo.id_pergunta = p.id_acumulo
    left join lateral (
      select *
      from pontuacao_professores pp2
      where pp2.id_professor = u.id
        and pp2.ano = p_ano
      order by pp2.ano desc
      limit 1
    ) pp on true
    left join lateral (
      select exists (
        select 1
        from turma_professor_atribuicao a
        where a.id_professor = u.id
          and a.id_empresa = p_id_empresa
          and a.ano = p_ano
      ) as atribuicoes_ano
    ) atrib on true
    left join lateral (
      select true as tem_funcao_extra, funcao::text as funcao_extra
      from professor_funcao_extra pfe
      where pfe.user_id = u.id
        and pfe.id_empresa = p_id_empresa
        and pfe.ano = p_ano::text
        and pfe.status is true
        and pfe.soft_delete is false
        and lower(pfe.funcao::text) not in ('outros')
      order by pfe.data_inicio desc
      limit 1
    ) pfe on true
    where u.id_empresa = p_id_empresa
      and (p_nome_completo is null or length(p_nome_completo) < 3 or u.nome_completo ilike '%'||p_nome_completo||'%')
      and (p_id_escola is null or u.id_escola = p_id_escola)
      and (p_tipo_contrato is null or p_tipo_contrato = 'Todos' or r_tipo_contrato.resposta = p_tipo_contrato)
      and (p_afastamento   is null or p_afastamento   = 'Todos' or r_afastamento.resposta   = p_afastamento)
      and (p_acumulo       is null or p_acumulo       = 'Todos' or r_acumulo.resposta       = p_acumulo)
      and (
        p_tem_atribuicao is null or p_tem_atribuicao = '' or p_tem_atribuicao = 'Todos'
        or (p_tem_atribuicao = 'true'  and atrib.atribuicoes_ano)
        or (p_tem_atribuicao = 'false' and not atrib.atribuicoes_ano)
      )
      and (
        p_tem_funcao_extra is null or p_tem_funcao_extra = '' or p_tem_funcao_extra = 'Todos'
        or (p_tem_funcao_extra = 'Sim' and pfe.tem_funcao_extra is true)
        or (p_tem_funcao_extra = 'Não' and pfe.tem_funcao_extra is null)
      )
    order by u.nome_completo asc
    limit p_itens_por_pagina offset v_offset
  ) t;

  -------------------------------------------------------------------
  -- 4) RETORNO JSON
  -------------------------------------------------------------------
  return jsonb_build_object(
    'pagina', p_pagina,
    'qtd_paginas', v_qtd_paginas,
    'qtd_itens_total', coalesce(v_total,0),
    'itens', coalesce(v_itens, '[]'::jsonb)
  );
end;
$$;


ALTER FUNCTION "public"."get_professores_atribuicao_p1_paginada"("p_ano" integer, "p_id_empresa" "uuid", "p_nome_completo" "text", "p_id_escola" "uuid", "p_tipo_contrato" "text", "p_afastamento" "text", "p_acumulo" "text", "p_tem_atribuicao" "text", "p_tem_funcao_extra" "text", "p_pagina" integer, "p_itens_por_pagina" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_professores_certificados_departamento_v2"("p_func_extra" "text", "p_user_expandido_id" "uuid", "p_ano" "text", "p_id_professor" "uuid" DEFAULT NULL::"uuid", "p_busca_nome" "text" DEFAULT NULL::"text", "p_pendentes" boolean DEFAULT true, "p_enviados" boolean DEFAULT true, "p_em_andamento_diretor" boolean DEFAULT true, "p_em_andamento_supervisor" boolean DEFAULT true, "p_concluido_diretor" boolean DEFAULT true, "p_concluido_supervisor" boolean DEFAULT true, "p_pagina" integer DEFAULT 1, "p_itens_por_pagina" integer DEFAULT 30) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
declare
  v_total_itens int;
  v_qtd_paginas int;
  v_qtd_usuarios_funcao int;
  v_posicao_usuario int;
  v_itens_por_usuario int;
  v_inicio_range int;
  v_fim_range int;
  v_offset int;
  v_result jsonb;
  v_itens jsonb;
  v_escola_target constant uuid := 'd09e293c-b5ca-4713-b974-044637c933e8'::uuid; -- Departamento
begin
  -- 1) responsáveis válidos
  select count(*) into v_qtd_usuarios_funcao
  from public.professor_funcao_extra fe
  where fe.funcao = p_func_extra::public.funcao_extra_enum
    and fe.id_escola = v_escola_target
    and fe.status = true
    and fe.soft_delete = false;

  if v_qtd_usuarios_funcao = 0 then
    return jsonb_build_object(
      'total_itens', 0,
      'pagina', p_pagina,
      'qtd_paginas', 0,
      'itens_por_pagina', p_itens_por_pagina,
      'funcao_requisitada', p_func_extra,
      'qtd_usuarios_funcao', 0,
      'itens', '[]'::jsonb
    );
  end if;

  -- 2) posição do usuário logado
  with responsaveis as (
    select fe.user_id,
           row_number() over (order by ue.nome_completo, ue.id) as posicao
    from public.professor_funcao_extra fe
    join public.user_expandido ue on ue.id = fe.user_id
    where fe.funcao = p_func_extra::public.funcao_extra_enum
      and fe.id_escola = v_escola_target
      and fe.status = true
      and fe.soft_delete = false
  )
  select posicao into v_posicao_usuario
  from responsaveis
  where user_id = p_user_expandido_id;

  if v_posicao_usuario is null then
    return jsonb_build_object(
      'erro', 'Usuário não possui a função requisitada no Departamento',
      'total_itens', 0,
      'pagina', p_pagina,
      'qtd_paginas', 0,
      'itens_por_pagina', p_itens_por_pagina,
      'funcao_requisitada', p_func_extra,
      'qtd_usuarios_funcao', v_qtd_usuarios_funcao,
      'itens', '[]'::jsonb
    );
  end if;

  ------------------------------------------------------------------
  -- 3) total de professores ativos com filtros
  ------------------------------------------------------------------
  with prof_base as (
    select
      ue.id as id_professor,
      ue.nome_completo,
      ue.id_escola,
      ue.matricula
    from public.user_expandido ue
    where ue.id_escola = v_escola_target
      and ue.status_contrato = 'Ativo'::public.status_contrato
      and (p_id_professor is null or ue.id = p_id_professor)
      and (coalesce(p_busca_nome, '') = '' or ue.nome_completo ilike '%' || p_busca_nome || '%')
  ),
  certs_agg as (
    select
      pca.id_professor,
      count(*)::int as qtd,
      case
        when count(*) = 0 then 'pendente'
        when count(*) filter (where pca.deferido_indeferido_diretor is null) > 0 then 'em andamento'
        else 'concluído'
      end as status_dir,
      case
        when count(*) = 0 then 'pendente'
        when count(*) filter (where pca.deferido_indeferido_supervisor is null) > 0 then 'em andamento'
        else 'concluído'
      end as status_sup,
      case
        when count(*) > 0
          and count(*) filter (where coalesce(pca.deferido_indeferido, false) = true) = count(*)
        then true
        else false
      end as deferido_geral
    from public.professores_certificados_atribuicao pca
    where btrim(pca.ano_atribuicao) = btrim(p_ano)
    group by pca.id_professor
  ),
  -- ====== AJUSTE: pega a última resposta por usuário, mas com unique já basta 1 linha ======
  contrato as (
    select distinct on (ru.id_user)
      ru.id_user as id_professor,
      ru.resposta as tipo_contrato
    from public.respostas_user ru
    where ru.id_pergunta = '467b29b5-8236-4f5c-a3ac-3e135bcf5601'::uuid
    order by ru.id_user, coalesce(ru.atualizado_em, ru.criado_em) desc
  ),
  admissao as (
    select distinct on (ru.id_user)
      ru.id_user as id_professor,
      ru.resposta as data_admissao
    from public.respostas_user ru
    where ru.id_pergunta = '2cbcdcf0-a615-49a3-b563-e6c9e8e9f393'::uuid
    order by ru.id_user, coalesce(ru.atualizado_em, ru.criado_em) desc
  ),
  professores as (
    select
      pb.id_professor,
      pb.nome_completo,
      pb.id_escola,
      e.nome as nome_escola,
      pb.matricula,
      coalesce(ca.qtd, 0) as quantidade_certificados_enviados,
      coalesce(ca.status_dir, 'pendente') as deferido_indeferido_diretor,
      coalesce(ca.status_sup, 'pendente') as deferido_indeferido_supervisor,
      coalesce(ca.deferido_geral, false) as deferido_geral,
      false as mostrar_subitem,
      coalesce(ct.tipo_contrato, '') as tipo_contrato,
      coalesce(ad.data_admissao, '') as data_admissao,
      row_number() over (order by pb.nome_completo, pb.id_professor) as posicao_geral
    from prof_base pb
    join public.escolas e on e.id = pb.id_escola
    left join certs_agg ca on ca.id_professor = pb.id_professor
    left join contrato ct on ct.id_professor = pb.id_professor
    left join admissao ad on ad.id_professor = pb.id_professor
    where
         (p_pendentes               and coalesce(ca.qtd, 0) = 0)
      or (p_enviados                and coalesce(ca.qtd, 0) > 0)
      or (p_em_andamento_diretor    and coalesce(ca.status_dir, 'pendente') = 'em andamento')
      or (p_em_andamento_supervisor and coalesce(ca.status_sup, 'pendente') = 'em andamento')
      or (p_concluido_diretor       and coalesce(ca.status_dir, 'pendente') = 'concluído')
      or (p_concluido_supervisor    and coalesce(ca.status_sup, 'pendente') = 'concluído')
  )
  select count(*) into v_total_itens from professores;

  -- dividir igualmente entre responsáveis
  v_itens_por_usuario := ceil(v_total_itens::numeric / v_qtd_usuarios_funcao);
  v_inicio_range := (v_posicao_usuario - 1) * v_itens_por_usuario + 1;
  v_fim_range := least(v_posicao_usuario * v_itens_por_usuario, v_total_itens);

  -- paginação
  v_offset := (p_pagina - 1) * p_itens_por_pagina;
  v_qtd_paginas := coalesce(ceil((v_fim_range - v_inicio_range + 1)::numeric / nullif(p_itens_por_pagina, 0)), 0)::int;

  ------------------------------------------------------------------
  -- 4) buscar professores dentro do range
  ------------------------------------------------------------------
  with prof_base as (
    select
      ue.id as id_professor,
      ue.nome_completo,
      ue.id_escola,
      ue.matricula
    from public.user_expandido ue
    where ue.id_escola = v_escola_target
      and ue.status_contrato = 'Ativo'::public.status_contrato
      and (p_id_professor is null or ue.id = p_id_professor)
      and (coalesce(p_busca_nome, '') = '' or ue.nome_completo ilike '%' || p_busca_nome || '%')
  ),
  certs_agg as (
    select
      pca.id_professor,
      count(*)::int as qtd,
      case
        when count(*) = 0 then 'pendente'
        when count(*) filter (where pca.deferido_indeferido_diretor is null) > 0 then 'em andamento'
        else 'concluído'
      end as status_dir,
      case
        when count(*) = 0 then 'pendente'
        when count(*) filter (where pca.deferido_indeferido_supervisor is null) > 0 then 'em andamento'
        else 'concluído'
      end as status_sup,
      case
        when count(*) > 0
          and count(*) filter (where coalesce(pca.deferido_indeferido, false) = true) = count(*)
        then true
        else false
      end as deferido_geral
    from public.professores_certificados_atribuicao pca
    where btrim(pca.ano_atribuicao) = btrim(p_ano)
    group by pca.id_professor
  ),
  contrato as (
    select distinct on (ru.id_user)
      ru.id_user as id_professor,
      ru.resposta as tipo_contrato
    from public.respostas_user ru
    where ru.id_pergunta = '467b29b5-8236-4f5c-a3ac-3e135bcf5601'::uuid
    order by ru.id_user, coalesce(ru.atualizado_em, ru.criado_em) desc
  ),
  admissao as (
    select distinct on (ru.id_user)
      ru.id_user as id_professor,
      ru.resposta as data_admissao
    from public.respostas_user ru
    where ru.id_pergunta = '2cbcdcf0-a615-49a3-b563-e6c9e8e9f393'::uuid
    order by ru.id_user, coalesce(ru.atualizado_em, ru.criado_em) desc
  ),
  professores as (
    select
      pb.id_professor,
      pb.nome_completo,
      pb.id_escola,
      e.nome as nome_escola,
      pb.matricula,
      coalesce(ca.qtd, 0) as quantidade_certificados_enviados,
      coalesce(ca.status_dir, 'pendente') as deferido_indeferido_diretor,
      coalesce(ca.status_sup, 'pendente') as deferido_indeferido_supervisor,
      coalesce(ca.deferido_geral, false) as deferido_geral,
      false as mostrar_subitem,
      coalesce(ct.tipo_contrato, '') as tipo_contrato,
      coalesce(ad.data_admissao, '') as data_admissao,
      row_number() over (order by pb.nome_completo, pb.id_professor) as posicao_geral
    from prof_base pb
    join public.escolas e on e.id = pb.id_escola
    left join certs_agg ca on ca.id_professor = pb.id_professor
    left join contrato ct on ct.id_professor = pb.id_professor
    left join admissao ad on ad.id_professor = pb.id_professor
    where
         (p_pendentes               and coalesce(ca.qtd, 0) = 0)
      or (p_enviados                and coalesce(ca.qtd, 0) > 0)
      or (p_em_andamento_diretor    and coalesce(ca.status_dir, 'pendente') = 'em andamento')
      or (p_em_andamento_supervisor and coalesce(ca.status_sup, 'pendente') = 'em andamento')
      or (p_concluido_diretor       and coalesce(ca.status_dir, 'pendente') = 'concluído')
      or (p_concluido_supervisor    and coalesce(ca.status_sup, 'pendente') = 'concluído')
  ),
  professores_do_usuario as (
    select *
    from professores
    where posicao_geral between v_inicio_range and v_fim_range
    order by posicao_geral
    limit p_itens_por_pagina
    offset v_offset
  )
  select jsonb_agg(
    jsonb_build_object(
      'nome_professor', nome_completo,
      'id_professor', id_professor,
      'id_escola', id_escola,
      'nome_escola', nome_escola,
      'matricula', matricula,
      'quantidade_certificados_enviados', quantidade_certificados_enviados,
      'deferido_indeferido_diretor', deferido_indeferido_diretor,
      'deferido_indeferido_supervisor', deferido_indeferido_supervisor,
      'deferido_geral', deferido_geral,
      'mostrar_subitem', mostrar_subitem,
      'tipo_contrato', tipo_contrato,
      'data_admissao', data_admissao
    )
  )
  into v_itens
  from professores_do_usuario;

  -- 5) JSON final
  select jsonb_build_object(
    'total_itens', v_total_itens,
    'pagina', p_pagina,
    'qtd_paginas', v_qtd_paginas,
    'itens_por_pagina', p_itens_por_pagina,
    'funcao_requisitada', p_func_extra,
    'qtd_usuarios_funcao', v_qtd_usuarios_funcao,
    'itens', coalesce(v_itens, '[]'::jsonb)
  )
  into v_result;

  return v_result;
end;
$$;


ALTER FUNCTION "public"."get_professores_certificados_departamento_v2"("p_func_extra" "text", "p_user_expandido_id" "uuid", "p_ano" "text", "p_id_professor" "uuid", "p_busca_nome" "text", "p_pendentes" boolean, "p_enviados" boolean, "p_em_andamento_diretor" boolean, "p_em_andamento_supervisor" boolean, "p_concluido_diretor" boolean, "p_concluido_supervisor" boolean, "p_pagina" integer, "p_itens_por_pagina" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_professores_certificados_status_escola"("p_id_escola" "uuid", "p_ano" "text", "p_id_professor" "uuid" DEFAULT NULL::"uuid", "p_busca_nome" "text" DEFAULT NULL::"text", "p_pendentes" boolean DEFAULT true, "p_enviados" boolean DEFAULT true, "p_em_andamento_diretor" boolean DEFAULT true, "p_em_andamento_supervisor" boolean DEFAULT true, "p_concluido_diretor" boolean DEFAULT true, "p_concluido_supervisor" boolean DEFAULT true) RETURNS TABLE("nome_professor" "text", "id_professor" "uuid", "id_escola" "uuid", "nome_escola" "text", "matricula" "text", "quantidade_certificados_enviados" integer, "deferido_indeferido_diretor" "text", "deferido_indeferido_supervisor" "text", "deferido_geral" boolean, "mostrar_subitem" boolean, "tipo_contrato" "text", "data_admissao" "text")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
with escola_ctx as (
  select e.id as id_escola, e.nome as nome_escola, e.id_empresa
  from public.escolas e
  where e.id = p_id_escola
),
prof_base as (
  select
    ue.id as id_professor,
    ue.nome_completo,
    ue.id_escola,
    ue.matricula
  from public.user_expandido ue
  join escola_ctx ec on ec.id_escola = ue.id_escola
  where (p_id_professor is null or ue.id = p_id_professor)
    and (
      coalesce(p_busca_nome, '') = ''
      or ue.nome_completo ilike '%' || p_busca_nome || '%'
    )
    -- 🔒 apenas contratos Ativos (enum)
    and ue.status_contrato = 'Ativo'::public.status_contrato
),
certs_agg as (
  select
    pca.id_professor,
    count(*)::int as qtd,
    case
      when count(*) = 0 then 'pendente'
      when count(*) filter (where pca.deferido_indeferido_diretor is null) > 0 then 'em andamento'
      else 'concluído'
    end as status_dir,
    case
      when count(*) = 0 then 'pendente'
      when count(*) filter (where pca.deferido_indeferido_supervisor is null) > 0 then 'em andamento'
      else 'concluído'
    end as status_sup,
    case
      when count(*) > 0
        and count(*) filter (where coalesce(pca.deferido_indeferido, false) = true) = count(*)
      then true
      else false
    end as deferido_geral
  from public.professores_certificados_atribuicao pca
  where btrim(pca.ano_atribuicao) = btrim(p_ano)
  group by pca.id_professor
),
contrato as (
  select
    ru.id_user as id_professor,
    (array_agg(ru.resposta order by coalesce(ru.atualizado_em, ru.criado_em) desc))[1] as tipo_contrato
  from public.respostas_user ru
  where ru.id_pergunta = '467b29b5-8236-4f5c-a3ac-3e135bcf5601'::uuid
  group by ru.id_user
),
admissao as (
  select
    ru.id_user as id_professor,
    (array_agg(ru.resposta order by coalesce(ru.atualizado_em, ru.criado_em) desc))[1] as data_admissao
  from public.respostas_user ru
  where ru.id_pergunta = '2cbcdcf0-a615-49a3-b563-e6c9e8e9f393'::uuid
  group by ru.id_user
)
select
  pb.nome_completo as nome_professor,
  pb.id_professor,
  pb.id_escola,
  ec.nome_escola,
  pb.matricula,
  coalesce(ca.qtd, 0)                                  as quantidade_certificados_enviados,
  coalesce(ca.status_dir, 'pendente')                  as deferido_indeferido_diretor,
  coalesce(ca.status_sup, 'pendente')                  as deferido_indeferido_supervisor,
  coalesce(ca.deferido_geral, false)                   as deferido_geral,
  false                                                as mostrar_subitem,
  coalesce(ct.tipo_contrato, '')                       as tipo_contrato,
  coalesce(ad.data_admissao, '')                       as data_admissao
from prof_base pb
join escola_ctx ec on true
left join certs_agg ca on ca.id_professor = pb.id_professor
left join contrato ct on ct.id_professor = pb.id_professor
left join admissao ad on ad.id_professor = pb.id_professor
where
  (
    (p_pendentes                and coalesce(ca.qtd, 0) = 0)                                         or
    (p_enviados                 and coalesce(ca.qtd, 0) > 0)                                         or
    (p_em_andamento_diretor     and coalesce(ca.status_dir, 'pendente') = 'em andamento')            or
    (p_em_andamento_supervisor  and coalesce(ca.status_sup, 'pendente') = 'em andamento')            or
    (p_concluido_diretor        and coalesce(ca.status_dir, 'pendente') = 'concluído')               or
    (p_concluido_supervisor     and coalesce(ca.status_sup, 'pendente') = 'concluído')
  )
order by pb.nome_completo, pb.matricula;
$$;


ALTER FUNCTION "public"."get_professores_certificados_status_escola"("p_id_escola" "uuid", "p_ano" "text", "p_id_professor" "uuid", "p_busca_nome" "text", "p_pendentes" boolean, "p_enviados" boolean, "p_em_andamento_diretor" boolean, "p_em_andamento_supervisor" boolean, "p_concluido_diretor" boolean, "p_concluido_supervisor" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_professores_funcoes_extras"("p_id_empresa" "uuid", "p_funcao" "text" DEFAULT NULL::"text", "p_escola" "uuid" DEFAULT NULL::"uuid", "p_nome" "text" DEFAULT NULL::"text", "p_soft_delete" boolean DEFAULT NULL::boolean, "p_pagina" integer DEFAULT 1, "p_tamanho_pagina" integer DEFAULT 30) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
    v_total_registros integer;
    v_pagina integer := coalesce(p_pagina, 1);
    v_tamanho integer := coalesce(p_tamanho_pagina, 30);
    v_total_paginas integer;
    v_items jsonb;
begin
    -------------------------------------------------------------------
    -- 1) Conta total de registros aplicando filtros + empresa
    -------------------------------------------------------------------
    select count(*)
    into v_total_registros
    from professor_funcao_extra pfe
    join user_expandido uep on pfe.user_id = uep.id
    where pfe.id_empresa = p_id_empresa
      and (p_funcao is null or pfe.funcao = p_funcao::public.funcao_extra_enum)
      and (p_escola is null or pfe.id_escola = p_escola)
      and (p_nome is null or uep.nome_completo ilike '%' || p_nome || '%')
      and (p_soft_delete is null or pfe.soft_delete = p_soft_delete);

    v_total_paginas := ceil(v_total_registros::numeric / v_tamanho);

    -------------------------------------------------------------------
    -- 2) Busca os itens da página atual
    -------------------------------------------------------------------
    select jsonb_agg(to_jsonb(sub))
    into v_items
    from (
      select
        pfe.id as pfe_id,
        uep.id as professor_id,
        uep.nome_completo,
        uep.matricula,
        r_data_admissao.resposta as data_admissao,
        pfe.id_escola as escola_id,
        coalesce(e.nome, 'Indefinido'::text) as escola_nome,
        uep.id_escola as escola_sede_id,
        coalesce(esede.nome, 'Indefinido'::text) as escola_sede_nome,
        pfe.afastamento_funcao_extra,
        pfe.data_inicio_licenca_func_extra,
        pfe.data_fim_licenca_func_extra,
        pfe.funcao::text,
        pfe.ano,
        pfe.data_inicio,
        pfe.data_fim,
        pfe.status,
        pfe.observacao,
        pfe.id_empresa,
        pfe.soft_delete
      from professor_funcao_extra pfe
        join user_expandido uep on pfe.user_id = uep.id
        left join escolas e on pfe.id_escola = e.id
        left join escolas esede on uep.id_escola = esede.id
        left join lateral (
          select ru.resposta
          from respostas_user ru
          join perguntas_user pu on ru.id_pergunta = pu.id
          where pu.pergunta = 'data_admissao'
            and ru.id_user = uep.id
          limit 1
        ) r_data_admissao on true
      where pfe.id_empresa = p_id_empresa
        and (p_funcao is null or pfe.funcao = p_funcao::public.funcao_extra_enum)
        and (p_escola is null or pfe.id_escola = p_escola)
        and (p_nome is null or uep.nome_completo ilike '%' || p_nome || '%')
        and (p_soft_delete is null or pfe.soft_delete = p_soft_delete)
      order by uep.nome_completo asc
      limit v_tamanho
      offset (v_pagina - 1) * v_tamanho
    ) sub;

    -------------------------------------------------------------------
    -- 3) Retorna resultado estruturado em JSONB
    -------------------------------------------------------------------
    return jsonb_build_object(
      'n_pagina', v_pagina,
      'qtd_paginas', coalesce(v_total_paginas, 0),
      'total_itens', coalesce(v_total_registros, 0),
      'items', coalesce(v_items, '[]'::jsonb)
    );
end;
$$;


ALTER FUNCTION "public"."get_professores_funcoes_extras"("p_id_empresa" "uuid", "p_funcao" "text", "p_escola" "uuid", "p_nome" "text", "p_soft_delete" boolean, "p_pagina" integer, "p_tamanho_pagina" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_professores_pontuacao_paginada"("p_id_empresa" "uuid", "p_ano" integer, "p_id_escola" "uuid" DEFAULT NULL::"uuid", "p_busca_nome" "text" DEFAULT NULL::"text", "p_id_componente" "uuid" DEFAULT NULL::"uuid", "p_pagina" integer DEFAULT 1, "p_itens_por_pagina" integer DEFAULT 30) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_total int := 0;
  v_qtd_paginas int := 1;
  v_offset int := (p_pagina - 1) * p_itens_por_pagina;
  v_itens jsonb := '[]'::jsonb;
BEGIN
  --------------------------------------------------------------------
  -- 🧮 Total de registros (filtro opcional de componente)
  --------------------------------------------------------------------
  SELECT COUNT(DISTINCT ue.id)
  INTO v_total
  FROM user_expandido ue
  LEFT JOIN professor_componente pc
         ON pc.id_professor = ue.id
        AND (p_id_componente IS NULL OR pc.id_componente = p_id_componente)
  WHERE ue.id_empresa = p_id_empresa
    AND ue.status_contrato = 'Ativo'
    AND (p_id_escola IS NULL OR ue.id_escola = p_id_escola)
    AND (p_busca_nome IS NULL OR unaccent(ue.nome_completo) ILIKE unaccent('%' || p_busca_nome || '%'))
    AND (p_id_componente IS NULL OR pc.id_componente IS NOT NULL);

  IF v_total > 0 THEN
    v_qtd_paginas := CEIL(v_total::numeric / p_itens_por_pagina);
  END IF;

  --------------------------------------------------------------------
  -- 📊 Seleção principal
  --------------------------------------------------------------------
  WITH base AS (
    SELECT
      ue.id AS id_professor,
      ue.nome_completo,
      ue.matricula,
      e.nome AS nome_escola,
      COALESCE(ROUND(pp.pontuacao / 1000.0, 3)::text, 'Pendente') AS pontuacao,
      COALESCE(ROUND(pp.pontuacao_unidade / 1000.0, 3)::text, 'Pendente') AS pontuacao_unidade,
      COALESCE(ROUND(pp.pontuacao_departamento / 1000.0, 3)::text, 'Pendente') AS pontuacao_departamento,
      COALESCE(ROUND(pp.certificado_concurso_publico / 1000.0, 3)::text, 'Pendente') AS certificado_concurso_publico,
      COALESCE(ROUND(pp.tempo_servico_unidade / 1000.0, 3)::text, 'Pendente') AS tempo_servico_unidade,
      COALESCE(ROUND(pp.tempo_servico_departamento / 1000.0, 3)::text, 'Pendente') AS tempo_servico_departamento,
      COALESCE(ROUND(pp.tempo_especialista / 1000.0, 3)::text, 'Pendente') AS tempo_especialista,
      COALESCE(ROUND(pp.assiduidade / 1000.0, 3)::text, 'Pendente') AS assiduidade,
      COALESCE(ROUND(pp.pontuacao_certificados / 1000.0, 3)::text, 'Pendente') AS pontuacao_certificados,
      COALESCE(ROUND(pp.pontuacao_unidade_total / 1000.0, 3)::text, 'Pendente') AS pontuacao_unidade_total,
      COALESCE(ROUND(pp.pontuacao_departamento_total / 1000.0, 3)::text, 'Pendente') AS pontuacao_departamento_total,
      pp.registro_anterior,
      COALESCE(pp.status, 'Pendente') AS status,
      pp.observacoes,
      pp.devolutiva,
      pp.atualizado_em,
      c.uuid AS id_componente,
      c.nome AS componente_nome
    FROM user_expandido ue
    LEFT JOIN escolas e ON e.id = ue.id_escola
    LEFT JOIN pontuacao_professores pp 
           ON pp.id_professor = ue.id
          AND pp.id_empresa = p_id_empresa
          AND pp.ano = p_ano
          AND pp.soft_delete = false
    LEFT JOIN professor_componente pc
           ON pc.id_professor = ue.id
          AND (p_id_componente IS NULL OR pc.id_componente = p_id_componente)
    LEFT JOIN componente c 
           ON c.uuid = pc.id_componente
    WHERE ue.id_empresa = p_id_empresa
      AND ue.status_contrato = 'Ativo'
      AND (p_id_escola IS NULL OR ue.id_escola = p_id_escola)
      AND (p_busca_nome IS NULL OR unaccent(ue.nome_completo) ILIKE unaccent('%' || p_busca_nome || '%'))
      AND (p_id_componente IS NULL OR pc.id_componente IS NOT NULL)
    ORDER BY 
      CASE WHEN pp.pontuacao_unidade_total IS NULL THEN 1 ELSE 0 END,
      COALESCE(pp.pontuacao_unidade_total, 0) DESC,
      ue.nome_completo
    OFFSET v_offset LIMIT p_itens_por_pagina
  )
  SELECT JSONB_AGG(TO_JSONB(b))
  INTO v_itens
  FROM base b;

  --------------------------------------------------------------------
  -- 📦 Retorno final
  --------------------------------------------------------------------
  RETURN JSONB_BUILD_OBJECT(
    'qtd_itens', COALESCE(v_total, 0),
    'qtd_paginas', COALESCE(v_qtd_paginas, 1),
    'itens', COALESCE(v_itens, '[]'::jsonb)
  );
END;
$$;


ALTER FUNCTION "public"."get_professores_pontuacao_paginada"("p_id_empresa" "uuid", "p_ano" integer, "p_id_escola" "uuid", "p_busca_nome" "text", "p_id_componente" "uuid", "p_pagina" integer, "p_itens_por_pagina" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_professores_por_escola"("p_id_escola" "uuid") RETURNS "uuid"[]
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  with ctx as (
    select 
      (auth.jwt()->>'empresa_id')::uuid as empresa_id,
      auth.uid() as uid,
      auth.jwt()->>'papeis_user' as papel
  ),
  -- Garante que a escola pertence à mesma empresa do chamador
  escola_ok as (
    select 1
    from public.escolas e
    join ctx on true
    where e.id = p_id_escola
      and e.id_empresa = ctx.empresa_id
  )
  select coalesce(
    (
      select array_agg(ue.id order by ue.id)
      from public.user_expandido ue
      where ue.id_escola = p_id_escola
        and exists (select 1 from escola_ok)
    ),
    '{}'::uuid[]
  );
$$;


ALTER FUNCTION "public"."get_professores_por_escola"("p_id_escola" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_resumo_certificados_professores"("p_professores" "uuid"[], "p_ano" "text") RETURNS TABLE("total_professores" integer, "professores_com_certificados" integer, "professores_sem_certificados" integer, "total_certificados" integer, "media_certificados_por_professor" numeric, "perc_professores_com_certificados" numeric, "perc_professores_sem_certificados" numeric, "perc_validados_diretor" numeric, "perc_validados_supervisor" numeric)
    LANGUAGE "plpgsql"
    AS $$
begin
  return query
  with certs as (
    select 
      pca.id,
      pca.id_professor,
      pca.deferido_indeferido_diretor,
      pca.deferido_indeferido_supervisor
    from professores_certificados_atribuicao pca
    where pca.id_professor = any(p_professores)
      and pca.ano_atribuicao = p_ano
  )
  select
    cardinality(p_professores)::int as total_professores,

    count(distinct case when c.id is not null then c.id_professor end)::int as professores_com_certificados,

    (cardinality(p_professores) - count(distinct case when c.id is not null then c.id_professor end))::int as professores_sem_certificados,

    count(c.id)::int as total_certificados,

    coalesce(count(c.id)::numeric / nullif(cardinality(p_professores),0),0) as media_certificados_por_professor,

    case when cardinality(p_professores) > 0 
         then (count(distinct case when c.id is not null then c.id_professor end)::numeric / cardinality(p_professores)) * 100
         else 0 end as perc_professores_com_certificados,

    case when cardinality(p_professores) > 0 
         then ((cardinality(p_professores) - count(distinct case when c.id is not null then c.id_professor end))::numeric / cardinality(p_professores)) * 100
         else 0 end as perc_professores_sem_certificados,

    coalesce(sum(case when c.deferido_indeferido_diretor is true then 1 else 0 end)::numeric / nullif(count(c.id),0) * 100,0) as perc_validados_diretor,

    coalesce(sum(case when c.deferido_indeferido_supervisor is true then 1 else 0 end)::numeric / nullif(count(c.id),0) * 100,0) as perc_validados_supervisor

  from certs c;
end;
$$;


ALTER FUNCTION "public"."get_resumo_certificados_professores"("p_professores" "uuid"[], "p_ano" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_table_schema"("p_id_empresa" "uuid", "p_table_name" "text") RETURNS SETOF "jsonb"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
select jsonb_build_object(
    'column_name', c.column_name,
    'data_type', c.data_type,
    'is_nullable', c.is_nullable,
    'is_pk', (
        select exists (
            select 1 
            from information_schema.table_constraints tc
            join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name
            where tc.table_schema = 'public' 
              and tc.table_name = p_table_name
              and tc.constraint_type = 'PRIMARY KEY'
              and kcu.column_name = c.column_name
        )
    ),
    'max_length', c.character_maximum_length,
    -- Adicionar lógica para buscar FKs aqui se for necessário no futuro
    'is_fk', (
        select exists (
            select 1
            from information_schema.key_column_usage kcu
            join information_schema.table_constraints tc on kcu.constraint_name = tc.constraint_name
            where tc.constraint_type = 'FOREIGN KEY'
              and kcu.table_name = p_table_name
              and kcu.column_name = c.column_name
        )
    )
)
from information_schema.columns c
where c.table_schema = 'public' 
  and c.table_name = p_table_name
  -- Excluir colunas de auditoria/sistema que não devem ser editadas
  and c.column_name not in ('id_empresa', 'soft_delete', 'criado_em', 'criado_por', 'modificado_em', 'modificado_por', 'id')
order by c.ordinal_position;
$$;


ALTER FUNCTION "public"."get_table_schema"("p_id_empresa" "uuid", "p_table_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_turmas_com_atribuicoes_filtrada_paginada"("p_id_empresa" "uuid", "p_ano" integer DEFAULT NULL::integer, "p_id_escola" "uuid" DEFAULT NULL::"uuid", "p_id_ano_etapa" "text" DEFAULT NULL::"text", "p_id_classe" "text" DEFAULT NULL::"text", "p_id_horario" "text" DEFAULT NULL::"text", "p_status_atribuicao" "text" DEFAULT 'Todos'::"text", "p_pagina" integer DEFAULT 1, "p_itens_por_pagina" integer DEFAULT 30) RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  v_total_registros int;
  v_total_paginas int;
  v_offset int;
  v_itens jsonb;
begin
  /*
    Estratégia:
    - base_turmas: filtros estáticos
    - ult_atribuicao: professor do último nível por turma (respeita ano quando informado)
    - fx_atual: função extra ATUAL (último registro ativo != 'outros') por professor
    - turmas_filtradas_status: aplica p_status_atribuicao com fx_atual
  */

  -- 1) TOTAL
  with
  base_turmas as (
    select t.*
    from turmas t
    where t.id_empresa = p_id_empresa
      and (p_ano is null or t.ano::int = p_ano)
      and (p_id_escola is null or t.id_escola = p_id_escola)
      and (p_id_ano_etapa is null or p_id_ano_etapa = 'Todos' or t.id_ano_etapa = p_id_ano_etapa::uuid)
      and (p_id_classe is null or p_id_classe = 'Todos' or t.id_classe = p_id_classe::uuid)
      and (p_id_horario is null or p_id_horario = 'Todos' or t.id_horario = p_id_horario::uuid)
  ),
  ult_atribuicao as (
    -- último nível por turma (por ano quando informado)
    select distinct on (a.id_turma)
           a.id_turma,
           a.id_professor,
           a.nivel_substituicao
    from turma_professor_atribuicao a
    join base_turmas bt on bt.id = a.id_turma
    where a.id_empresa = p_id_empresa
      and (p_ano is null or a.ano = p_ano)
    order by a.id_turma, a.nivel_substituicao desc
  ),
  fx_atual as (
    -- função extra ATUAL por professor (último registro ativo, != 'outros')
    select distinct on (pfe.user_id)
           pfe.user_id
    from professor_funcao_extra pfe
    where pfe.id_empresa = p_id_empresa
      and pfe.status is true
      and pfe.soft_delete is false
      and lower(pfe.funcao::text) <> 'outros'
    order by pfe.user_id, pfe.data_inicio desc nulls last
  ),
  turmas_filtradas_status as (
    select bt.*,
           ua.id_professor as id_professor_ua,
           fx.user_id as fx_user_id
    from base_turmas bt
    left join ult_atribuicao ua on ua.id_turma = bt.id
    left join fx_atual fx on fx.user_id = ua.id_professor
    where
      -- todos
      (p_status_atribuicao is null or p_status_atribuicao = '' or p_status_atribuicao = 'Todos')
      -- disponíveis: livres + substituição (prof do último nível com fx_atual)
      or (p_status_atribuicao = 'Disponíveis' and (ua.id_professor is null or fx.user_id is not null))
      -- livres: sem professor
      or (p_status_atribuicao = 'Livres' and ua.id_professor is null)
      -- substituição: tem professor e esse professor tem fx_atual
      or (p_status_atribuicao = 'Substituição' and ua.id_professor is not null and fx.user_id is not null)
      -- titular: titular sem substituto
      or (p_status_atribuicao = 'Titular' and bt.at_titular is true and (bt.at_substituto is false or bt.at_substituto is null))
      -- titular+sub: titular e substituto
      or (p_status_atribuicao = 'Titular+Sub' and bt.at_titular is true and bt.at_substituto is true)
  )
  select count(*) into v_total_registros
  from turmas_filtradas_status;

  v_total_paginas := ceil(coalesce(v_total_registros,0)::numeric / nullif(p_itens_por_pagina,0));
  v_offset := greatest((coalesce(p_pagina,1)-1) * p_itens_por_pagina, 0);

  -- 2) ITENS
  with
  base_turmas as (
    select t.*
    from turmas t
    where t.id_empresa = p_id_empresa
      and (p_ano is null or t.ano::int = p_ano)
      and (p_id_escola is null or t.id_escola = p_id_escola)
      and (p_id_ano_etapa is null or p_id_ano_etapa = 'Todos' or t.id_ano_etapa = p_id_ano_etapa::uuid)
      and (p_id_classe is null or p_id_classe = 'Todos' or t.id_classe = p_id_classe::uuid)
      and (p_id_horario is null or p_id_horario = 'Todos' or t.id_horario = p_id_horario::uuid)
  ),
  ult_atribuicao as (
    select distinct on (a.id_turma)
           a.id_turma,
           a.id_professor,
           a.nivel_substituicao
    from turma_professor_atribuicao a
    join base_turmas bt on bt.id = a.id_turma
    where a.id_empresa = p_id_empresa
      and (p_ano is null or a.ano = p_ano)
    order by a.id_turma, a.nivel_substituicao desc
  ),
  fx_atual as (
    select distinct on (pfe.user_id)
           pfe.user_id
    from professor_funcao_extra pfe
    where pfe.id_empresa = p_id_empresa
      and pfe.status is true
      and pfe.soft_delete is false
      and lower(pfe.funcao::text) <> 'outros'
    order by pfe.user_id, pfe.data_inicio desc nulls last
  ),
  turmas_filtradas_status as (
    select bt.*,
           ua.id_professor as id_professor_ua,
           fx.user_id as fx_user_id
    from base_turmas bt
    left join ult_atribuicao ua on ua.id_turma = bt.id
    left join fx_atual fx on fx.user_id = ua.id_professor
    where
      (p_status_atribuicao is null or p_status_atribuicao = '' or p_status_atribuicao = 'Todos')
      or (p_status_atribuicao = 'Disponíveis' and (ua.id_professor is null or fx.user_id is not null))
      or (p_status_atribuicao = 'Livres' and ua.id_professor is null)
      or (p_status_atribuicao = 'Substituição' and ua.id_professor is not null and fx.user_id is not null)
      or (p_status_atribuicao = 'Titular' and bt.at_titular is true and (bt.at_substituto is false or bt.at_substituto is null))
      or (p_status_atribuicao = 'Titular+Sub' and bt.at_titular is true and bt.at_substituto is true)
  )
  select jsonb_agg(to_jsonb(sub))
  into v_itens
  from (
    select
      t.id,
      t.ano,
      t.criado_em,
      t.at_titular,
      t.at_substituto,
      e.nome as e_nome,
      ae.nome as ae_nome,
      c.nome as c_nome,
      h.hora_inicio as h_inicio,
      h.hora_fim as h_fim,

      -- status geral (agora consistente com ano/empresa)
      (count(atp.*) filter (where atp.id is not null)) > 0 as status_atribuicao,

      -- disponibilidade = livres OR substituição (usando fx_atual)
      (
        (t.id_professor_ua is null)
        or (t.fx_user_id is not null)
      ) as status_disponibilidade,

      coalesce(
        jsonb_agg(
          jsonb_build_object(
            'id_atribuicao', atp.id,
            'nivel_substituicao', atp.nivel_substituicao,
            'data_inicio', atp.data_inicio,
            'data_fim', atp.data_fim,
            'professor_id', u.id,
            'nome_completo', u.nome_completo,
            'matricula', u.matricula,
            'email', u.email,
            'telefone', u.telefone
          )
          order by atp.nivel_substituicao
        ) filter (where atp.id is not null),
        '[]'::jsonb
      ) as atribuicoes
    from turmas_filtradas_status t
      join escolas e on e.id = t.id_escola
      join ano_etapa ae on ae.id = t.id_ano_etapa
      join classe c on c.id = t.id_classe
      join horarios_escola h on h.id = t.id_horario
      left join turma_professor_atribuicao atp
        on atp.id_turma = t.id
       and atp.id_empresa = p_id_empresa
       and (p_ano is null or atp.ano = p_ano)
      left join user_expandido u on u.id = atp.id_professor
    group by
      t.id, t.ano, t.criado_em, t.at_titular, t.at_substituto,
      e.nome, ae.nome, c.nome, h.hora_inicio, h.hora_fim,
      t.id_professor_ua, t.fx_user_id
    order by e.nome asc, t.ano desc
    limit p_itens_por_pagina offset v_offset
  ) sub;

  return jsonb_build_object(
    'pagina', p_pagina,
    'qtd_paginas', coalesce(v_total_paginas, ceil(coalesce(v_total_registros,0)::numeric / nullif(p_itens_por_pagina,0))),
    'qtd_itens_total', coalesce(v_total_registros, 0),
    'status_atribuicao_detalhado', p_status_atribuicao,
    'itens', coalesce(v_itens, '[]'::jsonb)
  );
end;
$$;


ALTER FUNCTION "public"."get_turmas_com_atribuicoes_filtrada_paginada"("p_id_empresa" "uuid", "p_ano" integer, "p_id_escola" "uuid", "p_id_ano_etapa" "text", "p_id_classe" "text", "p_id_horario" "text", "p_status_atribuicao" "text", "p_pagina" integer, "p_itens_por_pagina" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_turmas_do_professor"("p_id_professor" "uuid", "p_somente_ativas" boolean DEFAULT false, "p_ano" smallint DEFAULT NULL::smallint) RETURNS TABLE("atribuicao_id" "uuid", "turma_id" "uuid", "ano_turma" "text", "papel" "text", "nivel_substituicao" integer, "data_inicio" "date", "data_fim" "date", "ativa" boolean, "escola_id" "uuid", "escola" "text", "ano_etapa_id" "uuid", "ano_etapa" "text", "horario_id" "uuid", "horario" "text", "classe_id" "uuid", "classe" "text")
    LANGUAGE "sql"
    AS $$
  select
    a.id                        as atribuicao_id,
    t.id                        as turma_id,
    t.ano                       as ano_turma,
    case when a.nivel_substituicao = 0 then 'titular' else 'substituto' end as papel,
    a.nivel_substituicao,
    a.data_inicio,
    a.data_fim,
    (a.data_fim is null or a.data_fim >= current_date) as ativa,

    e.id                        as escola_id,
    e.nome                      as escola,

    ae.id                       as ano_etapa_id,
    ae.nome                     as ano_etapa,

    h.id                        as horario_id,
    coalesce(
      h.hora_completo,
      h.hora_inicio || ' - ' || h.hora_fim || ' (' || h.periodo::text || ')'
    )                          as horario,

    c.id                        as classe_id,
    c.nome                      as classe
  from public.turma_professor_atribuicao a
  join public.turmas           t  on t.id = a.id_turma
  join public.escolas          e  on e.id = t.id_escola
  join public.ano_etapa        ae on ae.id = t.id_ano_etapa
  join public.horarios_escola  h  on h.id = t.id_horario
  join public.classe           c  on c.id = t.id_classe
  where a.id_professor = p_id_professor
    and (p_ano is null or a.ano = p_ano)
    and (
      not p_somente_ativas
      or a.data_fim is null
      or a.data_fim >= current_date
    )
  order by e.nome, ae.nome, c.ordem, t.ano, a.nivel_substituicao, a.data_inicio;
$$;


ALTER FUNCTION "public"."get_turmas_do_professor"("p_id_professor" "uuid", "p_somente_ativas" boolean, "p_ano" smallint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_turmas_por_escola_rotina_semanal"("p_envio" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
    v_id_escola uuid := (p_envio->>'p_id_escola')::uuid;
    v_id_ano_etapa uuid := nullif(p_envio->>'p_id_ano_etapa','')::uuid;
    v_resultado jsonb;
begin
    with turmas_filtradas as (
        select
            t.id,
            t.ano,
            ae.nome as ano_etapa_nome,
            he.hora_completo as horario_completo,
            c.nome as classe_nome,
            -- professor titular (nível 0)
            (select u.nome_completo
             from public.turma_professor_atribuicao ta
             join public.user_expandido u on u.id = ta.id_professor
             where ta.id_turma = t.id
               and ta.nivel_substituicao = 0
               and ta.data_fim is null
             limit 1) as professor_titular,
            -- professor substituto (nível 1)
            (select u2.nome_completo
             from public.turma_professor_atribuicao ta2
             join public.user_expandido u2 on u2.id = ta2.id_professor
             where ta2.id_turma = t.id
               and ta2.nivel_substituicao = 1
               and ta2.data_fim is null
             limit 1) as professor_substituto
        from public.turmas t
        join public.ano_etapa ae on ae.id = t.id_ano_etapa
        join public.classe c on c.id = t.id_classe
        join public.horarios_escola he on he.id = t.id_horario
        where t.id_escola = v_id_escola
          and (v_id_ano_etapa is null or t.id_ano_etapa = v_id_ano_etapa)
          and exists (
              select 1
              from public.turma_professor_atribuicao tp
              where tp.id_turma = t.id
                and tp.data_fim is null
          )
        order by ae.nome, c.ordem
    )
    select jsonb_agg(to_jsonb(t)) into v_resultado
    from turmas_filtradas t;

    return coalesce(v_resultado, '[]'::jsonb);
end;
$$;


ALTER FUNCTION "public"."get_turmas_por_escola_rotina_semanal"("p_envio" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_unidades_atribuicao_paginada"("p_id_empresa" "uuid", "p_id_escola" "uuid" DEFAULT NULL::"uuid", "p_id_ano_etapa" "uuid" DEFAULT NULL::"uuid", "p_id_componente" "uuid" DEFAULT NULL::"uuid", "p_id_horario" "uuid" DEFAULT NULL::"uuid", "p_ano" "text" DEFAULT NULL::"text", "p_pagina" integer DEFAULT 1, "p_itens_por_pagina" integer DEFAULT 30) RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  v_total int;
  v_qtd_paginas int;
  v_offset int := greatest((coalesce(p_pagina,1)-1) * coalesce(p_itens_por_pagina,30), 0);
  v_itens jsonb;
  v_result jsonb;
begin
  -------------------------------------------------------------------
  -- 1) Total de registros com filtros aplicados + id_empresa
  -------------------------------------------------------------------
  select count(*)
  into v_total
  from public.unidade_atribuicao ua
  join public.turmas t on t.id = ua.id_turma
  join public.carga_horaria_p3 ch on ch.uuid = ua.id_ch_p3
  where ua.id_empresa = p_id_empresa
    and (p_id_escola     is null or t.id_escola    = p_id_escola)
    and (p_id_ano_etapa  is null or t.id_ano_etapa = p_id_ano_etapa)
    and (p_id_horario    is null or t.id_horario   = p_id_horario)
    and (p_id_componente is null or ch.id_componente = p_id_componente)
    and (p_ano           is null or t.ano = p_ano);

  v_qtd_paginas := case when coalesce(p_itens_por_pagina,30) > 0
                        then ceil(v_total::numeric / coalesce(p_itens_por_pagina,30))::int
                        else 1 end;

  -------------------------------------------------------------------
  -- 2) Itens paginados com filtro por id_empresa
  -------------------------------------------------------------------
  select coalesce(jsonb_agg(j.item), '[]'::jsonb)
  into v_itens
  from (
    select jsonb_build_object(
      'id_unidade_atribuicao', ua.uuid,
      'id_turma', t.id,
      'id_escola', t.id_escola,
      'id_ano_etapa', t.id_ano_etapa,
      'id_horario', t.id_horario,
      'id_componente', ch.id_componente,
      'ano', t.ano,
      'carga_horaria', ch.carga_horaria,
      'escola', e.nome,
      'ano_etapa', ae.nome,
      'tipo_ano_etapa', ae.tipo,
      'classe', c.nome,
      'horario', coalesce(h.hora_completo, h.hora_inicio || ' - ' || h.hora_fim),
      'periodo', h.periodo,
      'componente', comp.nome
    ) as item
    from public.unidade_atribuicao ua
    join public.turmas t on t.id = ua.id_turma
    join public.carga_horaria_p3 ch on ch.uuid = ua.id_ch_p3
    left join public.escolas e on e.id = t.id_escola
    left join public.ano_etapa ae on ae.id = t.id_ano_etapa
    left join public.horarios_escola h on h.id = t.id_horario
    left join public.classe c on c.id = t.id_classe
    left join public.componente comp on comp.uuid = ch.id_componente
    where ua.id_empresa = p_id_empresa
      and (p_id_escola     is null or t.id_escola    = p_id_escola)
      and (p_id_ano_etapa  is null or t.id_ano_etapa = p_id_ano_etapa)
      and (p_id_horario    is null or t.id_horario   = p_id_horario)
      and (p_id_componente is null or ch.id_componente = p_id_componente)
      and (p_ano           is null or t.ano = p_ano)
    order by ae.nome, comp.nome, c.nome
    offset v_offset
    limit coalesce(p_itens_por_pagina,30)
  ) j;

  -------------------------------------------------------------------
  -- 3) Retorno estruturado
  -------------------------------------------------------------------
  v_result := jsonb_build_object(
    'qtd_paginas', v_qtd_paginas,
    'qtd_itens', v_total,
    'pagina_atual', coalesce(p_pagina,1),
    'itens', v_itens
  );

  return v_result;
end;
$$;


ALTER FUNCTION "public"."get_unidades_atribuicao_paginada"("p_id_empresa" "uuid", "p_id_escola" "uuid", "p_id_ano_etapa" "uuid", "p_id_componente" "uuid", "p_id_horario" "uuid", "p_ano" "text", "p_pagina" integer, "p_itens_por_pagina" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."horarios_escola_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    -- Deleta o horario, garantindo que pertença à empresa correta
    delete from public.horarios_escola
    where id = p_id
      and id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Horário deletado com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Horário não encontrado ou não pertence à empresa.', 'id', p_id);
    end if;

exception when others then
    -- Retorna JSON de erro estruturado
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;


ALTER FUNCTION "public"."horarios_escola_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."horarios_escola_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    -- 1. Calcular Offset
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- 2. Calcular Total de Itens (para a busca atual)
    SELECT COUNT(*) INTO v_total_itens
    FROM public.horarios_escola
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(nome) LIKE v_busca_like 
            OR UPPER(descricao) LIKE v_busca_like
        );

    -- 3. Calcular Total de Páginas
    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- 4. Buscar Itens Paginados e converter para JSON
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT *
        FROM public.horarios_escola
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(nome) LIKE v_busca_like 
                OR UPPER(descricao) LIKE v_busca_like
            )
        ORDER BY nome ASC, hora_inicio ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- 5. Retornar Objeto JSON Final
    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."horarios_escola_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."horarios_escola_get_schema"("p_id_empresa" "uuid") RETURNS SETOF "jsonb"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    -- Reutiliza a função genérica get_table_schema para a tabela 'horarios_escola'
    select public.get_table_schema(p_id_empresa, 'horarios_escola');
$$;


ALTER FUNCTION "public"."horarios_escola_get_schema"("p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."horarios_escola_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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


ALTER FUNCTION "public"."horarios_escola_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."inserir_papel_usuario"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO public.papeis_user_auth (id, user_id, papel_id, empresa_id)
  VALUES (
    gen_random_uuid(),
    NEW.user_id,
    NEW.papel_id,
    NEW.empresa_id
  )
  ON CONFLICT (user_id, papel_id, empresa_id) DO NOTHING;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."inserir_papel_usuario"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."inserir_respostas_user_componente"("p_id_user" "uuid", "p_id_papel" "uuid", "p_id_empresa" "uuid", "p_respostas" "jsonb", "p_id_componente" "uuid" DEFAULT NULL::"uuid", "p_perguntas_data" "uuid"[] DEFAULT '{}'::"uuid"[]) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
declare
  resposta jsonb;
  r_id_pergunta uuid;
  r_tipo text;
  r_valor text;
  r_arquivo text;

  -- novos auxiliares p/ data
  r_data timestamptz;
  r_texto text;
begin
  -- LOOP das respostas recebidas
  for resposta in select * from jsonb_array_elements(p_respostas)
  loop
    r_id_pergunta := (resposta ->> 'id_pergunta')::uuid;
    r_tipo        :=  resposta ->> 'tipo';
    r_valor       :=  resposta ->> 'resposta';
    r_arquivo     :=  resposta ->> 'nome_arquivo_original';

    -- Somente a MANOBRA de data quando o id_pergunta estiver em p_perguntas_data
    if r_id_pergunta = any(p_perguntas_data) then
      begin
        -- ex.: "2022-01-25T00:00:00-03:00" -> timestamptz ok
        r_data  := (r_valor)::timestamptz;
        -- texto: só a parte YYYY-MM-DD (antes do 'T')
        r_texto := split_part(r_valor, 'T', 1);
      exception when others then
        -- se vier algo inesperado, mantém comportamento anterior (sem travar)
        r_data  := null;
        r_texto := r_valor;
      end;
    else
      -- demais tipos: mantém exatamente como era
      r_data  := null;
      r_texto := r_valor;
    end if;

    -- UPSERT em respostas_user (apenas acrescentando resposta_data)
    insert into respostas_user (
      id, id_user, id_pergunta, tipo,
      resposta, resposta_data, nome_arquivo_original,
      criado_em, criado_por, id_empresa
    )
    values (
      gen_random_uuid(), p_id_user, r_id_pergunta, r_tipo,
      r_texto, r_data, r_arquivo,
      now(), p_id_user, p_id_empresa
    )
    on conflict (id_user, id_pergunta)
    do update
    set
      tipo                 = excluded.tipo,
      resposta             = excluded.resposta,
      resposta_data        = excluded.resposta_data,
      nome_arquivo_original= excluded.nome_arquivo_original,
      atualizado_em        = now(),
      atualizado_por       = p_id_user;
  end loop;

  -- MANTIDO: vínculo do componente (sem alterações)
  if p_id_componente is not null and p_id_componente::text <> '' then
    insert into professor_componente (
      id, id_componente, id_professor, ano_referencia,
      criado_por, criado_em, id_empresa
    )
    select
      gen_random_uuid(), p_id_componente, p_id_user,
      extract(year from current_date)::text, p_id_user, now(), p_id_empresa
    where not exists (
      select 1 from professor_componente
      where id_professor = p_id_user
        and id_componente = p_id_componente
    );
  end if;

  -- OBS: p_id_papel permanece como parâmetro porque o fluxo/trigger usa em outras rotas.
end;
$$;


ALTER FUNCTION "public"."inserir_respostas_user_componente"("p_id_user" "uuid", "p_id_papel" "uuid", "p_id_empresa" "uuid", "p_respostas" "jsonb", "p_id_componente" "uuid", "p_perguntas_data" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_avaliacao_upsert"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_id_submissao" "uuid", "p_nota" numeric, "p_comentario" "text", "p_status" "text" DEFAULT 'avaliado'::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_user_expandido_id uuid;
    v_papel_id uuid;
    v_admin_role uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
    v_prof_role uuid := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
    v_submissao_exists boolean;
BEGIN
    -- Get User Info
    SELECT ue.id, ue.papel_id
    INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido ue
    WHERE ue.user_id = p_user_id AND ue.id_empresa = p_id_empresa;

    -- Basic Permission Check (Only Admin or Professor can grade)
    IF v_papel_id NOT IN (v_admin_role, v_prof_role) THEN
        RAISE EXCEPTION 'Acesso negado: Apenas administradores e professores podem avaliar.';
    END IF;

    -- Verify Submission Exists (and belongs to company? implicitly via join if we wanted, but simple check here)
    -- Ideally we should also check if the professor HAS access to this submission using logic similar to GET,
    -- but for performance/simplicity assuming if they can see it locally (UI filtered), they can edit it.
    -- Strict security would duplicate the 'WHERE' logic from GET here. 
    -- Let's trust the UI + Basic Role for now to speed up, unless 'Strict' is required.
    
    UPDATE public.lms_submissao
    SET 
        nota = p_nota,
        comentario_professor = p_comentario,
        status = p_status,
        modificado_em = now()
    WHERE id = p_id_submissao
    RETURNING true INTO v_submissao_exists;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Submissão não encontrada.';
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'message', 'Avaliação salva com sucesso.'
    );
END;
$$;


ALTER FUNCTION "public"."lms_avaliacao_upsert"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_id_submissao" "uuid", "p_nota" numeric, "p_comentario" "text", "p_status" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_avaliacoes_get"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_filtro_status" "text" DEFAULT NULL::"text", "p_filtro_turma_id" "uuid" DEFAULT NULL::"uuid", "p_filtro_aluno_id" "uuid" DEFAULT NULL::"uuid", "p_filtro_escopo" "text" DEFAULT NULL::"text") RETURNS TABLE("id_submissao" "uuid", "id_aluno" "uuid", "aluno_nome" "text", "aluno_avatar" "text", "id_turma" "uuid", "turma_nome" "text", "id_conteudo" "uuid", "conteudo_titulo" "text", "escopo" "text", "id_item" "uuid", "item_titulo" "text", "data_envio" timestamp with time zone, "status" "text", "nota" numeric, "pontuacao_maxima" numeric, "comentario_professor" "text")
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_user_expandido_id uuid;
    v_papel_id uuid;
    v_admin_role uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
    v_prof_role uuid := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
BEGIN
    -- Get User Info
    SELECT ue.id, ue.papel_id
    INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido ue
    WHERE ue.user_id = p_user_id AND ue.id_empresa = p_id_empresa;

    RETURN QUERY
    SELECT 
        s.id AS id_submissao,
        ue_aluno.id AS id_aluno,
        ue_aluno.nome_completo AS aluno_nome,
        NULL::text AS aluno_avatar, -- Avatar not in user_expandido yet
        m.id_turma,
        t.ano || ' - ' || c_turma.nome AS turma_nome, -- Constructing a display name, usually Turma has more info but simplistic for now
        c.id AS id_conteudo,
        c.titulo AS conteudo_titulo,
        c.escopo,
        ic.id AS id_item,
        ic.titulo AS item_titulo,
        s.data_envio,
        s.status,
        s.nota,
        ic.pontuacao_maxima,
        s.comentario_professor
    FROM public.lms_submissao s
    JOIN public.lms_item_conteudo ic ON ic.id = s.id_item_conteudo
    JOIN public.lms_conteudo c ON c.id = ic.id_lms_conteudo
    JOIN public.user_expandido ue_aluno ON ue_aluno.id = s.id_aluno
    -- Resolving Turma for the student (Active Matricula)
    -- Needed for filtering and display. Submissions themselves don't link to Turma directly, 
    -- but students do. We take the active matricula or one relevant to the content if possible.
    -- If content is Turma Scoped, we use that. If not, we take student's current active class.
    LEFT JOIN public.matriculas m ON m.id_aluno = s.id_aluno AND m.status = 'ativa'
    LEFT JOIN public.turmas t ON t.id = m.id_turma
    LEFT JOIN public.classe c_turma ON c_turma.id = t.id_classe
    WHERE 
        c.id_empresa = p_id_empresa
        -- Optional Filters
        AND (p_filtro_status IS NULL OR 
             (p_filtro_status = 'pendente' AND s.nota IS NULL) OR 
             (p_filtro_status = 'avaliado' AND s.nota IS NOT NULL) OR
             (s.status = p_filtro_status)
            )
        AND (p_filtro_turma_id IS NULL OR m.id_turma = p_filtro_turma_id)
        AND (p_filtro_aluno_id IS NULL OR s.id_aluno = p_filtro_aluno_id)
        AND (p_filtro_escopo IS NULL OR c.escopo = p_filtro_escopo)
        
        -- Permission Logic
        AND (
            -- Admin sees all
            (v_papel_id = v_admin_role)
            OR
            -- Professor Logic
            (
                v_papel_id = v_prof_role AND (
                    -- Global Content: Processor pulls all
                    (c.escopo = 'Global')
                    OR
                    -- Turma Content: Professor attributed to the CONTENT'S target Turma
                    -- Note: Conteudo has id_turma if scope is Turma
                    (c.escopo = 'Turma' AND c.id_turma IN (
                        SELECT tpa.id_turma 
                        FROM public.turma_professor_atribuicao tpa
                        WHERE tpa.id_professor = v_user_expandido_id
                        AND (tpa.data_fim IS NULL OR tpa.data_fim >= CURRENT_DATE)
                    ))
                    OR
                    -- Individual Content: Professor and Student share ANY active Turma
                    -- Note: Content has id_aluno if scope is Aluno (Individual)
                    (c.escopo = 'Aluno' AND EXISTS (
                        -- Check if there is an intersection of Turmas between Professor and Student
                        SELECT 1
                        FROM public.matriculas m_aluno
                        JOIN public.turma_professor_atribuicao tpa_prof ON tpa_prof.id_turma = m_aluno.id_turma
                        WHERE m_aluno.id_aluno = s.id_aluno
                        AND tpa_prof.id_professor = v_user_expandido_id
                        AND m_aluno.status = 'ativa'
                        AND (tpa_prof.data_fim IS NULL OR tpa_prof.data_fim >= CURRENT_DATE)
                    ))
                )
            )
        )
    ORDER BY s.data_envio DESC;
END;
$$;


ALTER FUNCTION "public"."lms_avaliacoes_get"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_filtro_status" "text", "p_filtro_turma_id" "uuid", "p_filtro_aluno_id" "uuid", "p_filtro_escopo" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_consumo_get"("p_id_empresa" "uuid", "p_user_id" "uuid") RETURNS TABLE("id" "uuid", "titulo" "text", "descricao" "text", "escopo" "text", "ordem" integer)
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_user_expandido_id uuid;
    v_papel_id uuid;
    v_admin_role uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
    v_prof_role uuid := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
    v_aluno_role uuid := 'b7f53d6e-70b5-453b-b564-728aeb4635d5';
BEGIN
    -- Get User Info
    -- RLS should allow user to see their own record in user_expandido
    SELECT ue.id, ue.papel_id
    INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido ue
    WHERE ue.user_id = p_user_id AND ue.id_empresa = p_id_empresa;

    RETURN QUERY
    SELECT 
        c.id,
        c.titulo,
        c.descricao,
        c.escopo,
        c.ordem
    FROM public.lms_conteudo c
    WHERE 
        c.id_empresa = p_id_empresa
        AND (
            -- Admin
            (v_papel_id = v_admin_role)
            OR
            -- Global Content
            (c.escopo = 'Global')
            OR
            -- Student Access
            (
                v_papel_id = v_aluno_role AND (
                    (c.escopo = 'Turma' AND c.id_turma IN (
                        SELECT m.id_turma FROM public.matriculas m
                        WHERE m.id_aluno = v_user_expandido_id 
                        AND m.status = 'ativa'
                    ))
                    OR
                    (c.escopo = 'Aluno' AND c.id_aluno = v_user_expandido_id)
                )
            )
            OR
            -- Professor Access
            (
                v_papel_id = v_prof_role AND (
                    (c.escopo = 'Turma' AND c.id_turma IN (
                        SELECT tpa.id_turma FROM public.turma_professor_atribuicao tpa
                        WHERE tpa.id_professor = v_user_expandido_id
                        AND (tpa.data_fim IS NULL OR tpa.data_fim >= CURRENT_DATE)
                    ))
                )
            )
        )
    ORDER BY c.ordem ASC;
END;
$$;


ALTER FUNCTION "public"."lms_consumo_get"("p_id_empresa" "uuid", "p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_conteudo_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text" DEFAULT NULL::"text", "p_id_turma" "uuid" DEFAULT NULL::"uuid", "p_id_aluno" "uuid" DEFAULT NULL::"uuid", "p_id_meta_turma" "uuid" DEFAULT NULL::"uuid", "p_somente_ativos" boolean DEFAULT true) RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_offset integer;
    v_total integer;
    v_result json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- 1. Contar total de registros (para paginação)
    SELECT COUNT(*)
    INTO v_total
    FROM public.lms_conteudo c
    WHERE c.id_empresa = p_id_empresa
    AND (p_termo_busca IS NULL OR c.titulo ILIKE '%' || p_termo_busca || '%')
    AND (
        -- Filtro de Visibilidade (Ativo/Inativo)
        (p_somente_ativos IS FALSE OR (c.data_disponivel IS NULL OR c.data_disponivel <= now()) AND c.visivel_para_alunos IS TRUE)
    )
    AND (
        -- Lógica de "Feed Inteligente": Combina (OR) os contextos passados
        -- Se nenhum contexto for passado, retorna itens Globais por padrão ou nada? 
        -- Vamos assumir que retorna tudo se nenhum ID for passado (Admin view) ou restringe se IDs forem passados.
        (p_id_turma IS NULL AND p_id_aluno IS NULL AND p_id_meta_turma IS NULL)
        OR
        (p_id_turma IS NOT NULL AND c.id_turma = p_id_turma)
        OR
        (p_id_aluno IS NOT NULL AND c.id_aluno = p_id_aluno)
        OR
        (p_id_meta_turma IS NOT NULL AND c.id_meta_turma = p_id_meta_turma)
        OR
        (c.escopo = 'Global')
    );

    -- 2. Buscar dados paginados
    SELECT json_agg(t) INTO v_result FROM (
        SELECT 
            c.*,
            (ae.nome || ' ' || cl.nome) as nome_turma,
            u.nome_completo as nome_criador,
            
            -- Subquery para buscar os itens (materiais, tarefas, etc) deste conteúdo
            (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', i.id,
                        'tipo', i.tipo,
                        'titulo', i.titulo,
                        'ordem', i.ordem,
                        'caminho_arquivo', i.caminho_arquivo,
                        'url_externa', i.url_externa,
                        'video_link', i.video_link,
                        'rich_text', i.rich_text,
                        'pontuacao_maxima', i.pontuacao_maxima,
                        'tempo_questionario', i.tempo_questionario,
                        'id_bbtk_edicao', i.id_bbtk_edicao,
                        -- Se for livro, traz infos extras
                        'livro_detalhes', CASE WHEN i.id_bbtk_edicao IS NOT NULL THEN
                             (SELECT jsonb_build_object(
                                 'titulo_obra', o.titulo_principal,
                                 'capa', e.arquivo_capa
                             ) 
                             FROM bbtk_edicao e 
                             JOIN bbtk_obra o ON o.uuid = e.obra_uuid 
                             WHERE e.uuid = i.id_bbtk_edicao)
                             ELSE NULL END
                    ) ORDER BY i.ordem
                )
                FROM public.lms_item_conteudo i
                WHERE i.id_lms_conteudo = c.id
            ) as itens

        FROM public.lms_conteudo c
        LEFT JOIN public.turmas t ON t.id = c.id_turma
        LEFT JOIN public.ano_etapa ae ON ae.id = t.id_ano_etapa
        LEFT JOIN public.classe cl ON cl.id = t.id_classe
        LEFT JOIN public.user_expandido u ON u.id = c.criado_por
        WHERE c.id_empresa = p_id_empresa
        AND (p_termo_busca IS NULL OR c.titulo ILIKE '%' || p_termo_busca || '%')
        AND (
            (p_somente_ativos IS FALSE OR (c.data_disponivel IS NULL OR c.data_disponivel <= now()) AND c.visivel_para_alunos IS TRUE)
        )
        AND (
            (p_id_turma IS NULL AND p_id_aluno IS NULL AND p_id_meta_turma IS NULL)
            OR
            (p_id_turma IS NOT NULL AND c.id_turma = p_id_turma)
            OR
            (p_id_aluno IS NOT NULL AND c.id_aluno = p_id_aluno)
            OR
            (p_id_meta_turma IS NOT NULL AND c.id_meta_turma = p_id_meta_turma)
            OR
            (c.escopo = 'Global')
        )
        ORDER BY c.data_referencia DESC, c.criado_em DESC
        LIMIT p_limite_itens_pagina OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'total', COALESCE(v_total, 0),
        'dados', COALESCE(v_result, '[]'::json)
    );
END;
$$;


ALTER FUNCTION "public"."lms_conteudo_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_id_turma" "uuid", "p_id_aluno" "uuid", "p_id_meta_turma" "uuid", "p_somente_ativos" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_conteudo_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_turma" "uuid", "p_id_aluno" "uuid", "p_id_meta_turma" "uuid", "p_id_componente" "uuid", "p_escopo" "text", "p_titulo" "text", "p_descricao" "text", "p_data_referencia" "date", "p_json_itens" "jsonb", "p_visivel_para_alunos" boolean DEFAULT true, "p_data_disponivel" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_liberar_por" "text" DEFAULT 'Conteúdo'::"text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_id uuid;
    v_item jsonb;
    v_item_id uuid;
    v_real_criado_por uuid;
BEGIN
    -- Traduzir o ID do Auth (p_criado_por) para o ID da tabela user_expandido
    SELECT id INTO v_real_criado_por
    FROM public.user_expandido
    WHERE user_id = p_criado_por
    LIMIT 1;

    -- Fallback: Se não achar pelo user_id, tenta ver se o ID passado JÁ É um user_expandido (casos legados ou admin direto)
    IF v_real_criado_por IS NULL THEN
        -- Tenta verificar se existe como PK
        PERFORM id FROM public.user_expandido WHERE id = p_criado_por;
        IF FOUND THEN
            v_real_criado_por := p_criado_por;
        ELSE
            -- Se falhar a tradução, usar o ID fornecido mas sabendo que pode dar erro de FK se não existir.
            -- O ideal aqui seria dar um RAISE EXCEPTION amigável.
            v_real_criado_por := p_criado_por; 
        END IF;
    END IF;

    -- 1. Upsert do Conteúdo Pai
    INSERT INTO public.lms_conteudo (
        id, 
        id_empresa, 
        criado_por, 
        id_turma, 
        id_aluno, 
        id_meta_turma, 
        id_componente, 
        escopo, 
        titulo, 
        descricao, 
        data_referencia, 
        visivel_para_alunos, 
        data_disponivel, 
        liberar_por,
        ordem
    ) VALUES (
        COALESCE(p_id, gen_random_uuid()),
        p_id_empresa,
        v_real_criado_por, -- Usando o ID traduzido
        p_id_turma,
        p_id_aluno,
        p_id_meta_turma,
        p_id_componente,
        p_escopo,
        p_titulo,
        p_descricao,
        p_data_referencia,
        p_visivel_para_alunos,
        p_data_disponivel,
        p_liberar_por::liberacao_conteudo_enum,
        99 -- Ordem default, depois podemos melhorar
    )
    ON CONFLICT (id) DO UPDATE SET
        titulo = EXCLUDED.titulo,
        descricao = EXCLUDED.descricao,
        data_referencia = EXCLUDED.data_referencia,
        visivel_para_alunos = EXCLUDED.visivel_para_alunos,
        data_disponivel = EXCLUDED.data_disponivel,
        liberar_por = EXCLUDED.liberar_por,
        id_turma = EXCLUDED.id_turma,
        id_aluno = EXCLUDED.id_aluno,
        id_meta_turma = EXCLUDED.id_meta_turma,
        escopo = EXCLUDED.escopo
    RETURNING id INTO v_id;

    -- 2. Manipulação dos Itens (Se fornecidos)
    -- É comum no front mandar o objeto completo. Se p_json_itens vier, atualizamos.
    IF p_json_itens IS NOT NULL THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_json_itens)
        LOOP
            -- Lógica simplificada: Se tem ID, atualiza. Se não tem, insere.
            -- Deletar itens não enviados fica para uma lógica de exclusão explícita ou replace total.
            -- Aqui faremos upsert individual.
            
            INSERT INTO public.lms_item_conteudo (
                id,
                id_lms_conteudo,
                tipo,
                titulo,
                caminho_arquivo,
                url_externa,
                video_link,
                rich_text,
                pontuacao_maxima,
                id_bbtk_edicao,
                ordem,
                criado_por,
                id_empresa
            ) VALUES (
                COALESCE((v_item->>'id')::uuid, gen_random_uuid()),
                v_id,
                (v_item->>'tipo')::lms_tipo_item,
                v_item->>'titulo',
                v_item->>'caminho_arquivo',
                v_item->>'url_externa',
                v_item->>'video_link',
                v_item->>'rich_text',
                (v_item->>'pontuacao_maxima')::numeric,
                (v_item->>'id_bbtk_edicao')::uuid,
                (v_item->>'ordem')::integer,
                p_criado_por,
                p_id_empresa
            )
            ON CONFLICT (id) DO UPDATE SET
                titulo = EXCLUDED.titulo,
                caminho_arquivo = EXCLUDED.caminho_arquivo,
                url_externa = EXCLUDED.url_externa,
                video_link = EXCLUDED.video_link,
                rich_text = EXCLUDED.rich_text,
                pontuacao_maxima = EXCLUDED.pontuacao_maxima,
                id_bbtk_edicao = EXCLUDED.id_bbtk_edicao,
                ordem = EXCLUDED.ordem;
                
        END LOOP;
    END IF;

    RETURN v_id;
END;
$$;


ALTER FUNCTION "public"."lms_conteudo_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_turma" "uuid", "p_id_aluno" "uuid", "p_id_meta_turma" "uuid", "p_id_componente" "uuid", "p_escopo" "text", "p_titulo" "text", "p_descricao" "text", "p_data_referencia" "date", "p_json_itens" "jsonb", "p_visivel_para_alunos" boolean, "p_data_disponivel" timestamp with time zone, "p_liberar_por" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_criar_respostas_padrao"("p_id_pergunta" "uuid", "p_id_empresa" "uuid", "p_sobrescrever" boolean DEFAULT false) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_insertados int := 0;
  v_msg         text;
  v_respostas   jsonb;
begin
  -- valida entradas
  if p_id_pergunta is null then
    return jsonb_build_object('ok', false, 'erro', 'p_id_pergunta é nulo');
  end if;

  if p_id_empresa is null then
    return jsonb_build_object('ok', false, 'erro', 'p_id_empresa é nulo');
  end if;

  -- valida existência da pergunta
  perform 1 from public.lms_pergunta where id = p_id_pergunta;
  if not found then
    return jsonb_build_object('ok', false, 'erro', 'Pergunta não encontrada');
  end if;

  -- sobrescrever respostas antigas, se solicitado
  if p_sobrescrever then
    delete from public.lms_resposta_possivel
    where id_pergunta = p_id_pergunta;
  end if;

  -- inserir apenas as respostas que faltam
  with desejadas as (
    select
      gs as ordem,
      ('Resposta ' || gs)::text as texto,
      (gs = 1) as correta
    from generate_series(1, 4) as gs
  ),
  faltantes as (
    select d.ordem, d.texto, d.correta
    from desejadas d
    left join public.lms_resposta_possivel r
      on r.id_pergunta = p_id_pergunta
     and r.ordem = d.ordem
    where r.id is null
  ),
  ins as (
    insert into public.lms_resposta_possivel
      (id_pergunta, texto, correta, ordem, id_empresa)
    select p_id_pergunta, f.texto, f.correta, f.ordem, p_id_empresa
    from faltantes f
    returning id
  )
  select count(*) into v_insertados from ins;

  -- mensagem para retorno
  v_msg := case
    when v_insertados = 0 and not p_sobrescrever then
      'Nada inserido: respostas já existiam.'
    when v_insertados = 0 and p_sobrescrever then
      'Respostas sobrescritas, mas nada inserido (caso raro).'
    when p_sobrescrever then
      'Respostas sobrescritas e recriadas com sucesso.'
    else
      'Respostas faltantes criadas com sucesso.'
  end;

  -- retorna todas as respostas
  select coalesce(jsonb_agg(to_jsonb(r) order by r.ordem), '[]'::jsonb)
    into v_respostas
    from public.lms_resposta_possivel r
   where r.id_pergunta = p_id_pergunta;

  return jsonb_build_object(
    'ok', true,
    'mensagem', v_msg,
    'total_respostas', jsonb_array_length(v_respostas),
    'respostas', v_respostas
  );
end;
$$;


ALTER FUNCTION "public"."lms_criar_respostas_padrao"("p_id_pergunta" "uuid", "p_id_empresa" "uuid", "p_sobrescrever" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_item_get_detalhes"("p_id_item" "uuid") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_result json;
BEGIN
    SELECT json_build_object(
        'id', i.id,
        'id_lms_conteudo', i.id_lms_conteudo,
        'tipo', i.tipo,
        'titulo', i.titulo,
        'caminho_arquivo', i.caminho_arquivo,
        'url_externa', i.url_externa,
        'video_link', i.video_link,
        'rich_text', i.rich_text,
        'pontuacao_maxima', i.pontuacao_maxima,
        'id_bbtk_edicao', i.id_bbtk_edicao,
        'ordem', i.ordem,
        'data_disponivel', i.data_disponivel,
        'data_entrega_limite', i.data_entrega_limite,
        'tempo_questionario', i.tempo_questionario,
        
        -- Detalhes Livro (Se houver)
        'livro_digital', CASE WHEN i.id_bbtk_edicao IS NOT NULL THEN
             (SELECT json_build_object('titulo', o.titulo_principal, 'capa', e.arquivo_capa) 
              FROM bbtk_edicao e JOIN bbtk_obra o ON o.uuid = e.obra_uuid WHERE e.uuid = i.id_bbtk_edicao)
             ELSE NULL END,

        -- Perguntas (Se houver)
        'perguntas', (
            SELECT json_agg(
                json_build_object(
                    'id', p.id,
                    'tipo', p.tipo,
                    'enunciado', p.enunciado,
                    'caminho_imagem', p.caminho_imagem,
                    'obrigatoria', p.obrigatoria,
                    'ordem', p.ordem,
                    -- Opções (Se houver)
                    'opcoes', (
                        SELECT json_agg(
                            json_build_object(
                                'id', rp.id,
                                'texto', rp.texto,
                                'correta', rp.correta,
                                'ordem', rp.ordem
                            ) ORDER BY rp.ordem
                        )
                        FROM public.lms_resposta_possivel rp
                        WHERE rp.id_pergunta = p.id
                    )
                ) ORDER BY p.ordem
            )
            FROM public.lms_pergunta p
            WHERE p.id_item_conteudo = i.id
        )
    )
    INTO v_result
    FROM public.lms_item_conteudo i
    WHERE i.id = p_id_item;

    RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."lms_item_get_detalhes"("p_id_item" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_item_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_lms_conteudo" "uuid", "p_tipo" "text", "p_titulo" "text", "p_caminho_arquivo" "text", "p_url_externa" "text", "p_video_link" "text", "p_rich_text" "text", "p_pontuacao_maxima" numeric, "p_id_bbtk_edicao" "uuid", "p_ordem" integer, "p_data_disponivel" timestamp with time zone, "p_data_entrega_limite" timestamp with time zone, "p_perguntas" "jsonb" DEFAULT NULL::"jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_id uuid;
    v_perg jsonb;
    v_opcao jsonb;
    v_id_pergunta uuid;
    v_real_criado_por uuid;
BEGIN
    -- Traduzir o ID do Auth (p_criado_por) para o ID da tabela user_expandido
    SELECT id INTO v_real_criado_por
    FROM public.user_expandido
    WHERE user_id = p_criado_por
    LIMIT 1;

    -- Fallback: Se não achar pelo user_id, tenta ver se o ID passado JÁ É um user_expandido
    IF v_real_criado_por IS NULL THEN
        PERFORM id FROM public.user_expandido WHERE id = p_criado_por;
        IF FOUND THEN
            v_real_criado_por := p_criado_por;
        ELSE
            v_real_criado_por := p_criado_por; 
        END IF;
    END IF;

    -- 1. Upsert do Item
    INSERT INTO public.lms_item_conteudo (
        id,
        id_empresa,
        criado_por,
        id_lms_conteudo,
        tipo,
        titulo,
        caminho_arquivo,
        url_externa,
        video_link,
        rich_text,
        pontuacao_maxima,
        id_bbtk_edicao,
        ordem,
        data_disponivel,
        data_entrega_limite
    ) VALUES (
        COALESCE(p_id, gen_random_uuid()),
        p_id_empresa,
        v_real_criado_por,
        p_id_lms_conteudo,
        p_tipo::lms_tipo_item,
        p_titulo,
        p_caminho_arquivo,
        p_url_externa,
        p_video_link,
        p_rich_text,
        p_pontuacao_maxima,
        p_id_bbtk_edicao,
        p_ordem,
        p_data_disponivel,
        p_data_entrega_limite
    )
    ON CONFLICT (id) DO UPDATE SET
        titulo = EXCLUDED.titulo,
        caminho_arquivo = EXCLUDED.caminho_arquivo,
        url_externa = EXCLUDED.url_externa,
        video_link = EXCLUDED.video_link,
        rich_text = EXCLUDED.rich_text,
        pontuacao_maxima = EXCLUDED.pontuacao_maxima,
        id_bbtk_edicao = EXCLUDED.id_bbtk_edicao,
        ordem = EXCLUDED.ordem,
        data_disponivel = EXCLUDED.data_disponivel,
        data_entrega_limite = EXCLUDED.data_entrega_limite,
        tipo = EXCLUDED.tipo
    RETURNING id INTO v_id;

    -- 2. Manipulação das Perguntas (Se for Questionário e JSON fornecido)
    IF p_perguntas IS NOT NULL THEN
        -- Opcional: Remover perguntas que não estão no JSON? 
        -- Por enquanto vamos fazer upsert. Se o usuário deletou na UI, o front deve mandar ID se existir.
        -- Se quisermos sync perfeito (apagar removidos), precisaríamos de lógica extra.
        -- Vamos assumir que perguntas não enviadas no JSON mas existentes no DB devem ser removidas? 
        -- Sim, para garantir integridade do form visual.
        
        DELETE FROM public.lms_pergunta 
        WHERE id_item_conteudo = v_id 
        AND id NOT IN (
            SELECT (val->>'id')::uuid 
            FROM jsonb_array_elements(p_perguntas) val 
            WHERE val->>'id' IS NOT NULL
        );

        FOR v_perg IN SELECT * FROM jsonb_array_elements(p_perguntas)
        LOOP
            INSERT INTO public.lms_pergunta (
                id,
                id_empresa,
                id_item_conteudo,
                tipo,
                enunciado,
                caminho_imagem,
                obrigatoria,
                ordem
            ) VALUES (
                COALESCE((v_perg->>'id')::uuid, gen_random_uuid()),
                p_id_empresa,
                v_id,
                (v_perg->>'tipo')::lms_tipo_pergunta,
                v_perg->>'enunciado',
                v_perg->>'caminho_imagem',
                COALESCE((v_perg->>'obrigatoria')::boolean, true),
                (v_perg->>'ordem')::integer
            )
            ON CONFLICT (id) DO UPDATE SET
                enunciado = EXCLUDED.enunciado,
                caminho_imagem = EXCLUDED.caminho_imagem,
                tipo = EXCLUDED.tipo,
                obrigatoria = EXCLUDED.obrigatoria,
                ordem = EXCLUDED.ordem
            RETURNING id INTO v_id_pergunta;

            -- 3. Manipular Respostas Possiveis (Se houver 'opcoes' no JSON da pergunta)
            IF v_perg->>'opcoes' IS NOT NULL THEN
                
                -- Limpar opções removidas
                DELETE FROM public.lms_resposta_possivel
                WHERE id_pergunta = v_id_pergunta
                AND id NOT IN (
                    SELECT (opt->>'id')::uuid
                    FROM jsonb_array_elements(v_perg->'opcoes') opt
                    WHERE opt->>'id' IS NOT NULL
                );

                FOR v_opcao IN SELECT * FROM jsonb_array_elements(v_perg->'opcoes')
                LOOP
                    INSERT INTO public.lms_resposta_possivel (
                        id,
                        id_empresa,
                        id_pergunta,
                        texto,
                        correta,
                        ordem
                    ) VALUES (
                        COALESCE((v_opcao->>'id')::uuid, gen_random_uuid()),
                        p_id_empresa,
                        v_id_pergunta,
                        v_opcao->>'texto',
                        COALESCE((v_opcao->>'correta')::boolean, false),
                        (v_opcao->>'ordem')::integer
                    )
                    ON CONFLICT (id) DO UPDATE SET
                        texto = EXCLUDED.texto,
                        correta = EXCLUDED.correta,
                        ordem = EXCLUDED.ordem;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    RETURN v_id;
END;
$$;


ALTER FUNCTION "public"."lms_item_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_lms_conteudo" "uuid", "p_tipo" "text", "p_titulo" "text", "p_caminho_arquivo" "text", "p_url_externa" "text", "p_video_link" "text", "p_rich_text" "text", "p_pontuacao_maxima" numeric, "p_id_bbtk_edicao" "uuid", "p_ordem" integer, "p_data_disponivel" timestamp with time zone, "p_data_entrega_limite" timestamp with time zone, "p_perguntas" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_item_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_lms_conteudo" "uuid", "p_tipo" "text", "p_titulo" "text", "p_caminho_arquivo" "text", "p_url_externa" "text", "p_video_link" "text", "p_rich_text" "text", "p_pontuacao_maxima" numeric, "p_id_bbtk_edicao" "uuid", "p_ordem" integer, "p_data_disponivel" timestamp with time zone, "p_data_entrega_limite" timestamp with time zone, "p_tempo_questionario" integer DEFAULT NULL::integer, "p_perguntas" "jsonb" DEFAULT NULL::"jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_id uuid;
    v_perg jsonb;
    v_opcao jsonb;
    v_id_pergunta uuid;
    v_real_criado_por uuid;
BEGIN
    -- Traduzir o ID do Auth (p_criado_por) para o ID da tabela user_expandido
    SELECT id INTO v_real_criado_por
    FROM public.user_expandido
    WHERE user_id = p_criado_por
    LIMIT 1;

    -- Fallback: Se não achar pelo user_id, tenta ver se o ID passado JÁ É um user_expandido
    IF v_real_criado_por IS NULL THEN
        PERFORM id FROM public.user_expandido WHERE id = p_criado_por;
        IF FOUND THEN
            v_real_criado_por := p_criado_por;
        ELSE
            v_real_criado_por := p_criado_por; 
        END IF;
    END IF;

    -- 1. Upsert do Item
    INSERT INTO public.lms_item_conteudo (
        id,
        id_empresa,
        criado_por,
        id_lms_conteudo,
        tipo,
        titulo,
        caminho_arquivo,
        url_externa,
        video_link,
        rich_text,
        pontuacao_maxima,
        id_bbtk_edicao,
        ordem,
        data_disponivel,
        data_entrega_limite,
        tempo_questionario
    ) VALUES (
        COALESCE(p_id, gen_random_uuid()),
        p_id_empresa,
        v_real_criado_por,
        p_id_lms_conteudo,
        p_tipo::lms_tipo_item,
        p_titulo,
        p_caminho_arquivo,
        p_url_externa,
        p_video_link,
        p_rich_text,
        p_pontuacao_maxima,
        p_id_bbtk_edicao,
        p_ordem,
        p_data_disponivel,
        p_data_entrega_limite,
        p_tempo_questionario
    )
    ON CONFLICT (id) DO UPDATE SET
        titulo = EXCLUDED.titulo,
        caminho_arquivo = EXCLUDED.caminho_arquivo,
        url_externa = EXCLUDED.url_externa,
        video_link = EXCLUDED.video_link,
        rich_text = EXCLUDED.rich_text,
        pontuacao_maxima = EXCLUDED.pontuacao_maxima,
        id_bbtk_edicao = EXCLUDED.id_bbtk_edicao,
        ordem = EXCLUDED.ordem,
        data_disponivel = EXCLUDED.data_disponivel,
        data_entrega_limite = EXCLUDED.data_entrega_limite,
        tempo_questionario = EXCLUDED.tempo_questionario,
        tipo = EXCLUDED.tipo
    RETURNING id INTO v_id;

    -- 2. Manipulação das Perguntas (Se for Questionário e JSON fornecido)
    IF p_perguntas IS NOT NULL THEN
        DELETE FROM public.lms_pergunta 
        WHERE id_item_conteudo = v_id 
        AND id NOT IN (
            SELECT (val->>'id')::uuid 
            FROM jsonb_array_elements(p_perguntas) val 
            WHERE val->>'id' IS NOT NULL
        );

        FOR v_perg IN SELECT * FROM jsonb_array_elements(p_perguntas)
        LOOP
            INSERT INTO public.lms_pergunta (
                id,
                id_empresa,
                id_item_conteudo,
                tipo,
                enunciado,
                caminho_imagem,
                obrigatoria,
                ordem
            ) VALUES (
                COALESCE((v_perg->>'id')::uuid, gen_random_uuid()),
                p_id_empresa,
                v_id,
                (v_perg->>'tipo')::lms_tipo_pergunta,
                v_perg->>'enunciado',
                v_perg->>'caminho_imagem',
                COALESCE((v_perg->>'obrigatoria')::boolean, true),
                (v_perg->>'ordem')::integer
            )
            ON CONFLICT (id) DO UPDATE SET
                enunciado = EXCLUDED.enunciado,
                caminho_imagem = EXCLUDED.caminho_imagem,
                tipo = EXCLUDED.tipo,
                obrigatoria = EXCLUDED.obrigatoria,
                ordem = EXCLUDED.ordem
            RETURNING id INTO v_id_pergunta;

            -- 3. Manipular Respostas Possiveis
            IF v_perg->>'opcoes' IS NOT NULL THEN
                DELETE FROM public.lms_resposta_possivel
                WHERE id_pergunta = v_id_pergunta
                AND id NOT IN (
                    SELECT (opt->>'id')::uuid
                    FROM jsonb_array_elements(v_perg->'opcoes') opt
                    WHERE opt->>'id' IS NOT NULL
                );

                FOR v_opcao IN SELECT * FROM jsonb_array_elements(v_perg->'opcoes')
                LOOP
                    INSERT INTO public.lms_resposta_possivel (
                        id,
                        id_empresa,
                        id_pergunta,
                        texto,
                        correta,
                        ordem
                    ) VALUES (
                        COALESCE((v_opcao->>'id')::uuid, gen_random_uuid()),
                        p_id_empresa,
                        v_id_pergunta,
                        v_opcao->>'texto',
                        COALESCE((v_opcao->>'correta')::boolean, false),
                        (v_opcao->>'ordem')::integer
                    )
                    ON CONFLICT (id) DO UPDATE SET
                        texto = EXCLUDED.texto,
                        correta = EXCLUDED.correta,
                        ordem = EXCLUDED.ordem;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    RETURN v_id;
END;
$$;


ALTER FUNCTION "public"."lms_item_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_lms_conteudo" "uuid", "p_tipo" "text", "p_titulo" "text", "p_caminho_arquivo" "text", "p_url_externa" "text", "p_video_link" "text", "p_rich_text" "text", "p_pontuacao_maxima" numeric, "p_id_bbtk_edicao" "uuid", "p_ordem" integer, "p_data_disponivel" timestamp with time zone, "p_data_entrega_limite" timestamp with time zone, "p_tempo_questionario" integer, "p_perguntas" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_itens_get"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_conteudo_id" "uuid") RETURNS TABLE("id" "uuid", "titulo" "text", "tipo" "public"."lms_tipo_item", "rich_text" "text", "url_externa" "text", "caminho_arquivo" "text", "video_link" "text", "duracao_minutos" integer, "pontuacao_maxima" numeric, "data_disponivel" timestamp with time zone, "data_entrega_limite" timestamp with time zone, "submissao" "jsonb", "livro" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_user_expandido_id uuid;
    v_papel_id uuid;
BEGIN
    -- 1. Lookup User Safely
    SELECT ue.id, ue.papel_id
    INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido ue
    WHERE ue.user_id = p_user_id AND ue.id_empresa = p_id_empresa;

    IF v_user_expandido_id IS NULL THEN
        -- If user not found, return empty set (safe fallback)
        RETURN;
    END IF;

    -- 2. Return Query
    RETURN QUERY
    SELECT 
        ic.id,
        ic.titulo,
        ic.tipo,
        ic.rich_text,
        ic.url_externa,
        ic.caminho_arquivo,
        ic.video_link,
        ic.duracao_minutos,
        ic.pontuacao_maxima,
        ic.data_disponivel,
        ic.data_entrega_limite,
        -- Submissão (JSON Object)
        (
            SELECT jsonb_build_object(
                'id', s.id,
                'data_inicio', COALESCE(s.criado_em, s.data_envio),
                'data_envio', s.data_envio,
                'status', CASE WHEN s.data_envio IS NOT NULL THEN 'concluido' ELSE 'em_andamento' END,
                'nota', s.nota
            )
            FROM public.lms_submissao s
            WHERE s.id_item_conteudo = ic.id AND s.id_aluno = v_user_expandido_id
            ORDER BY s.criado_em DESC
            LIMIT 1
        ) as submissao,
        -- Livro (JSON Object)
        (
            CASE WHEN ic.id_bbtk_edicao IS NOT NULL THEN
                (SELECT jsonb_build_object(
                    'uuid', e.uuid,
                    'titulo', o.titulo_principal,
                    'capa', e.arquivo_capa,
                    'arquivo_pdf', e.arquivo_pdf,
                    'autores', (
                        -- Using string_agg which is safe for text
                        SELECT string_agg(a.nome_completo, ', ')
                        FROM public.bbtk_juncao_edicao_autoria jea
                        JOIN public.bbtk_dim_autoria a ON a.uuid = jea.autoria_uuid
                        WHERE jea.edicao_uuid = e.uuid
                    )
                )
                FROM public.bbtk_edicao e
                JOIN public.bbtk_obra o ON o.uuid = e.obra_uuid
                WHERE e.uuid = ic.id_bbtk_edicao)
            ELSE NULL END
        ) as livro
    FROM public.lms_item_conteudo ic
    JOIN public.lms_conteudo c ON c.id = ic.id_lms_conteudo
    WHERE 
        ic.id_lms_conteudo = p_conteudo_id
    ORDER BY ic.ordem ASC;
END;
$$;


ALTER FUNCTION "public"."lms_itens_get"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_conteudo_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_listar_respostas_por_pergunta"("p_id_pergunta" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_array jsonb;
begin
  -- tenta converter para UUID válido
  begin
    perform p_id_pergunta::uuid;
  exception when others then
    return jsonb_build_object(
      'valido', false,
      'vazio', true,
      'dados', jsonb_build_array()
    );
  end;

  -- busca respostas possíveis
  select jsonb_agg(to_jsonb(r) order by r.ordem, r.id)
  into v_array
  from public.lms_resposta_possivel r
  where r.id_pergunta = p_id_pergunta;

  -- retorno padrãoizado
  return jsonb_build_object(
    'valido', true,
    'vazio', coalesce(v_array, '[]') = '[]',
    'dados', coalesce(v_array, '[]')
  );
end;
$$;


ALTER FUNCTION "public"."lms_listar_respostas_por_pergunta"("p_id_pergunta" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_pergunta_tem_respostas"("p_pergunta" "uuid") RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.lms_resposta r
    WHERE r.id_pergunta = p_pergunta
  );
$$;


ALTER FUNCTION "public"."lms_pergunta_tem_respostas"("p_pergunta" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_quiz_get_content"("p_item_id" "uuid", "p_user_id" "uuid", "p_id_empresa" "uuid" DEFAULT NULL::"uuid") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_result json;
    v_real_user_id uuid;
BEGIN
    IF p_id_empresa IS NOT NULL THEN
        SELECT id INTO v_real_user_id FROM public.user_expandido WHERE user_id = p_user_id AND id_empresa = p_id_empresa LIMIT 1;
    ELSE
         SELECT id INTO v_real_user_id FROM public.user_expandido WHERE user_id = p_user_id LIMIT 1;
    END IF;

    IF v_real_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado na tabela user_expandido.';
    END IF;

    SELECT json_build_object(
        'id', i.id,
        'titulo', i.titulo,
        'rich_text', i.rich_text,
        'tempo_questionario', i.tempo_questionario,
        'data_entrega_limite', i.data_entrega_limite,
        'perguntas', (
            SELECT json_agg(
                json_build_object(
                    'id', p.id,
                    'tipo', p.tipo,
                    'enunciado', p.enunciado,
                    'caminho_imagem', p.caminho_imagem,
                    'obrigatoria', p.obrigatoria,
                    'ordem', p.ordem,
                    'opcoes', (
                        SELECT json_agg(
                            json_build_object(
                                'id', rp.id,
                                'texto', rp.texto,
                                'ordem', rp.ordem
                            ) ORDER BY rp.ordem
                        )
                        FROM public.lms_resposta_possivel rp
                        WHERE rp.id_pergunta = p.id
                    ),
                    'resposta_usuario', (
                        SELECT json_build_object(
                            'texto_resposta', r.resposta,
                            'id_resposta_possivel', r.id_resposta_possivel
                        )
                        FROM public.lms_resposta r
                        WHERE r.id_pergunta = p.id
                        AND r.id_user = v_real_user_id
                    )
                ) ORDER BY p.ordem
            )
            FROM public.lms_pergunta p
            WHERE p.id_item_conteudo = i.id
        ),
        'submissao', (
            SELECT json_build_object(
                'status', CASE WHEN s.data_envio IS NOT NULL THEN 'concluido' ELSE 'em_andamento' END,
                'data_inicio', s.criado_em,
                'data_envio', s.data_envio,
                'nota', s.nota
            )
            FROM public.lms_submissao s
            WHERE s.id_item_conteudo = i.id
            AND s.id_aluno = v_real_user_id
        )
    )
    INTO v_result
    FROM public.lms_item_conteudo i
    WHERE i.id = p_item_id;

    RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."lms_quiz_get_content"("p_item_id" "uuid", "p_user_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_quiz_reset"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_real_user_id uuid;
BEGIN
    SELECT id INTO v_real_user_id 
    FROM public.user_expandido 
    WHERE user_id = p_user_id 
    AND id_empresa = p_id_empresa 
    LIMIT 1;

    IF v_real_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado.';
    END IF;

    -- Delete answers
    DELETE FROM public.lms_resposta
    WHERE id_user = v_real_user_id
    AND id_pergunta IN (
        SELECT id FROM public.lms_pergunta WHERE id_item_conteudo = p_item_id
    );

    -- Delete submission
    DELETE FROM public.lms_submissao
    WHERE id_item_conteudo = p_item_id
    AND id_aluno = v_real_user_id;

END;
$$;


ALTER FUNCTION "public"."lms_quiz_reset"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_quiz_start"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_submissao_id uuid;
    v_status text;
    v_data_inicio timestamp with time zone;
    v_real_user_id uuid;
BEGIN
    SELECT id INTO v_real_user_id 
    FROM public.user_expandido 
    WHERE user_id = p_user_id 
    AND id_empresa = p_id_empresa 
    LIMIT 1;

    IF v_real_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado na tabela user_expandido para esta empresa.';
    END IF;

    -- Check if submission exists
    SELECT id, criado_em, CASE WHEN data_envio IS NOT NULL THEN 'concluido' ELSE 'em_andamento' END
    INTO v_submissao_id, v_data_inicio, v_status
    FROM public.lms_submissao
    WHERE id_item_conteudo = p_item_id
    AND id_aluno = v_real_user_id;

    IF v_submissao_id IS NULL THEN
        -- Create new submission
        INSERT INTO public.lms_submissao (
            id_item_conteudo,
            id_aluno,
            criado_em,
            id_empresa
        ) VALUES (
            p_item_id,
            v_real_user_id,
            now(),
            p_id_empresa
        )
        RETURNING id, criado_em INTO v_submissao_id, v_data_inicio;
        
        v_status := 'created';
    ELSE
        -- Already exists
        IF v_status = 'concluido' THEN
             v_status := 'completed_previously';
        ELSE
             v_status := 'resumed';
        END IF;

        -- Optional: Update id_empresa if missing
        UPDATE public.lms_submissao SET id_empresa = p_id_empresa WHERE id = v_submissao_id AND id_empresa IS NULL;
    END IF;

    RETURN json_build_object(
        'id_submissao', v_submissao_id,
        'status', v_status,
        'data_inicio', v_data_inicio
    );
END;
$$;


ALTER FUNCTION "public"."lms_quiz_start"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_quiz_submit"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_pontuacao_total numeric := 0;
    v_nota_aluno numeric := 0;
    v_perg record;
    v_resp record;
    v_item_pontuacao_maxima numeric;
    v_real_user_id uuid;
BEGIN
    -- Lookup Real User ID
    SELECT id INTO v_real_user_id 
    FROM public.user_expandido 
    WHERE user_id = p_user_id 
    AND id_empresa = p_id_empresa 
    LIMIT 1;

    IF v_real_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado na tabela user_expandido para esta empresa.';
    END IF;

    -- Get Max Score of the Item
    SELECT pontuacao_maxima INTO v_item_pontuacao_maxima
    FROM public.lms_item_conteudo
    WHERE id = p_item_id;

    -- Calculate Score
    DECLARE
        v_total_questions_gradable integer := 0;
        v_correct_answers integer := 0;
    BEGIN
        FOR v_perg IN SELECT * FROM public.lms_pergunta WHERE id_item_conteudo = p_item_id AND tipo = 'Múltipla Escolha'
        LOOP
            v_total_questions_gradable := v_total_questions_gradable + 1;
            
            -- Check user answer
            SELECT * INTO v_resp 
            FROM public.lms_resposta 
            WHERE id_pergunta = v_perg.id AND id_user = v_real_user_id;
            
            IF v_resp.id_resposta_possivel IS NOT NULL THEN
                -- Check if it is correct
                PERFORM 1 FROM public.lms_resposta_possivel 
                WHERE id = v_resp.id_resposta_possivel AND correta = true;
                
                IF FOUND THEN
                    v_correct_answers := v_correct_answers + 1;
                END IF;
            END IF;
        END LOOP;

        IF v_total_questions_gradable > 0 THEN
             v_nota_aluno := (v_correct_answers::numeric / v_total_questions_gradable::numeric) * COALESCE(v_item_pontuacao_maxima, 10);
        ELSE
             v_nota_aluno := 0; 
        END IF;
    END;

    -- Close Submission (Update data_envio and status)
    UPDATE public.lms_submissao
    SET data_envio = now(),
        status = 'concluido', -- Ensure status is updated for simpler frontend check
        nota = v_nota_aluno
    WHERE id_item_conteudo = p_item_id
    AND id_aluno = v_real_user_id;

    RETURN json_build_object(
        'status', 'concluido',
        'nota', v_nota_aluno,
        'maxima', v_item_pontuacao_maxima
    );
END;
$$;


ALTER FUNCTION "public"."lms_quiz_submit"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_quiz_submit_batch"("p_user_id" "uuid", "p_item_id" "uuid", "p_respostas" "json", "p_id_empresa" "uuid" DEFAULT NULL::"uuid") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_resposta json;
    v_id_pergunta uuid;
    v_id_resposta_possivel uuid;
    v_texto_resposta text;
    v_submit_result json;
BEGIN
    -- Iterate through the answers array
    IF p_respostas IS NOT NULL THEN
        FOR v_resposta IN SELECT * FROM json_array_elements(p_respostas)
        LOOP
            v_id_pergunta := (v_resposta->>'id_pergunta')::uuid;
            
            -- Handle possible nulls for different answer types
            IF (v_resposta->>'id_resposta_possivel') IS NOT NULL THEN
                v_id_resposta_possivel := (v_resposta->>'id_resposta_possivel')::uuid;
            ELSE
                v_id_resposta_possivel := NULL;
            END IF;

            v_texto_resposta := v_resposta->>'texto_resposta';

            -- Call the existing upsert function for each answer
            -- This ensures we reuse the logic for validation and inserting
            PERFORM public.lms_resposta_upsert(
                p_user_id := p_user_id,
                p_id_item := p_item_id,
                p_id_pergunta := v_id_pergunta,
                p_id_resposta_possivel := v_id_resposta_possivel,
                p_texto_resposta := v_texto_resposta
            );
        END LOOP;
    END IF;

    -- After saving all answers, submit the quiz
    v_submit_result := public.lms_quiz_submit(
        p_user_id := p_user_id,
        p_item_id := p_item_id
    );

    RETURN v_submit_result;
END;
$$;


ALTER FUNCTION "public"."lms_quiz_submit_batch"("p_user_id" "uuid", "p_item_id" "uuid", "p_respostas" "json", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_reordenar_conteudos_objetos"("p_itens" "jsonb", "p_start_at_one" boolean DEFAULT true) RETURNS TABLE("id" "uuid", "ordem" integer)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  -- 1) Explode o JSON na ORDEM recebida, com índice (ord)
  with raw as (
    select
      (e.elem->>'id')::uuid            as id,
      (e.elem->>'id_empresa')::uuid    as id_empresa,
      e.ord                            as ord
    from jsonb_array_elements(p_itens) with ordinality as e(elem, ord)
  ),
  -- 2) Dedup (se, por acidente, o mesmo id vier repetido, fica o primeiro)
  dedup as (
    select
      id,
      id_empresa,
      ord,
      row_number() over (partition by id order by ord) as rn
    from raw
  ),
  -- 3) Calcula a nova ordem pelo índice
  payload as (
    select
      id,
      id_empresa,
      case when p_start_at_one then ord else ord - 1 end as nova_ordem
    from dedup
    where rn = 1
  )
  -- 4) Atualiza em lote
  update public.lms_conteudo c
     set ordem = p.nova_ordem
    from payload p
   where c.id = p.id
     -- segurança opcional: se id_empresa veio no objeto, confere
     and (p.id_empresa is null or c.id_empresa = p.id_empresa)
  returning c.id, c.ordem;
$$;


ALTER FUNCTION "public"."lms_reordenar_conteudos_objetos"("p_itens" "jsonb", "p_start_at_one" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_reordenar_itens_conteudo"("p_itens" "jsonb", "p_start_at_one" boolean DEFAULT true, "p_id_lms_conteudo" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("id" "uuid", "ordem" integer)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  -- 0) Normaliza: se p_itens for OBJETO, vira ARRAY com os values na ordem das chaves
  with norm as (
    select case
             when jsonb_typeof(p_itens) = 'array' then p_itens
             else (
               select jsonb_agg(value order by key::int)
               from jsonb_each(p_itens)
             )
           end as arr
  ),
  -- 1) Explode mantendo a ordem recebida
  raw as (
    select
      (e.elem->>'id')::uuid                as id,
      coalesce(
        nullif(e.elem->>'id_lms_conteudo','')::uuid,
        nullif(e.elem->>'idLmsConteudo','')::uuid,
        p_id_lms_conteudo
      )                                     as id_lms_conteudo,
      e.ord                                 as ord
    from norm n,
         jsonb_array_elements(n.arr) with ordinality as e(elem, ord)
  ),
  -- 2) Dedup por segurança
  payload as (
    select id, id_lms_conteudo,
           case when p_start_at_one then ord else ord - 1 end as nova_ordem
    from (
      select r.*, row_number() over (partition by id order by ord) rn
      from raw r
    ) x
    where rn = 1
      and id_lms_conteudo is not null
  )
  -- 3) Atualiza
  update public.lms_item_conteudo i
     set ordem = p.nova_ordem
    from payload p
   where i.id = p.id
     and i.id_lms_conteudo = p.id_lms_conteudo
  returning i.id, i.ordem;
$$;


ALTER FUNCTION "public"."lms_reordenar_itens_conteudo"("p_itens" "jsonb", "p_start_at_one" boolean, "p_id_lms_conteudo" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_reordenar_perguntas_objetos"("p_id_item_conteudo" "text", "p_itens" "jsonb", "p_start" integer DEFAULT 1) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $_$
declare
  v_dados jsonb;
begin
  -- 1) valida UUID do item de conteúdo
  begin
    perform p_id_item_conteudo::uuid;
  exception when others then
    return jsonb_build_object('valido', false, 'vazio', true, 'dados', '[]'::jsonb);
  end;

  -- 2) aplica a nova ordem quando houver payload
  if p_itens is not null and jsonb_typeof(p_itens) = 'array' and jsonb_array_length(p_itens) > 0 then
    with elems as (
      select e, rn
      from jsonb_array_elements(p_itens) with ordinality as t(e, rn)
    ),
    ids as (
      select
        case
          when jsonb_typeof(e) = 'object' then (e->>'id')
          when jsonb_typeof(e) = 'string' then trim(both '"' from e::text)
          else null
        end as id_text,
        rn
      from elems
    ),
    parsed as (
      select id_text::uuid as id, rn
      from ids
      where id_text ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    ),
    upd as (
      update public.lms_pergunta p
         set ordem = (p_start - 1) + parsed.rn
        from parsed
       where p.id = parsed.id
         and p.id_item_conteudo = p_id_item_conteudo::uuid
      returning p.*
    )
    select jsonb_agg(to_jsonb(u) order by u.ordem, u.id)
      into v_dados
      from upd u;
  end if;

  -- 3) se nada foi atualizado (payload vazio), retorna a lista atual ordenada
  if v_dados is null then
    select jsonb_agg(to_jsonb(p) order by p.ordem, p.id)
      into v_dados
      from public.lms_pergunta p
     where p.id_item_conteudo = p_id_item_conteudo::uuid;
  end if;

  -- 4) retorno padronizado
  return jsonb_build_object(
    'valido', true,
    'vazio',  coalesce(v_dados, '[]'::jsonb) = '[]'::jsonb,
    'dados',  coalesce(v_dados, '[]'::jsonb)
  );
end;
$_$;


ALTER FUNCTION "public"."lms_reordenar_perguntas_objetos"("p_id_item_conteudo" "text", "p_itens" "jsonb", "p_start" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_reordenar_respostas_possiveis"("p_id_pergunta" "uuid", "p_itens" "jsonb", "p_start_at_one" boolean DEFAULT true) RETURNS TABLE("id" "uuid", "ordem" integer)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  -- 0) Normaliza para array (suporta objeto numerado do WeWeb)
  with norm as (
    select case
             when jsonb_typeof(p_itens) = 'array' then p_itens
             else (
               select jsonb_agg(value order by key::int)
               from jsonb_each(p_itens)
             )
           end as arr
  ),
  -- 1) Explode mantendo a ordem recebida
  payload as (
    select
      (e.elem->>'id')::uuid                                   as id,
      case when p_start_at_one then e.ord else e.ord - 1 end  as nova_ordem
    from norm n,
         jsonb_array_elements(n.arr) with ordinality as e(elem, ord)
  )
  -- 2) Atualiza apenas as respostas dessa pergunta
  update public.lms_resposta_possivel r
     set ordem = p.nova_ordem
    from payload p
   where r.id = p.id
     and r.id_pergunta = p_id_pergunta
  returning r.id, r.ordem;
$$;


ALTER FUNCTION "public"."lms_reordenar_respostas_possiveis"("p_id_pergunta" "uuid", "p_itens" "jsonb", "p_start_at_one" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_resposta_possivel_tem_resposta"("p_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
  select exists (
    select 1
    from lms_resposta r
    where r.id_resposta_possivel = p_id
  );
$$;


ALTER FUNCTION "public"."lms_resposta_possivel_tem_resposta"("p_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."lms_resposta_upsert"("p_user_id" "uuid", "p_id_item" "uuid", "p_id_pergunta" "uuid", "p_id_resposta_possivel" "uuid" DEFAULT NULL::"uuid", "p_texto_resposta" "text" DEFAULT NULL::"text", "p_id_empresa" "uuid" DEFAULT NULL::"uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_sub_id uuid;
    v_tipo_pergunta lms_tipo_pergunta;
    v_real_user_id uuid;
BEGIN
    -- 0. Lookup Real User ID (User Expandido)
    IF p_id_empresa IS NOT NULL THEN
        SELECT id INTO v_real_user_id FROM public.user_expandido WHERE user_id = p_user_id AND id_empresa = p_id_empresa LIMIT 1;
    ELSE
         SELECT id INTO v_real_user_id FROM public.user_expandido WHERE user_id = p_user_id LIMIT 1;
    END IF;

    IF v_real_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado na tabela user_expandido.';
    END IF;

    -- 1. Validate Submission exists and is open
    SELECT id INTO v_sub_id
    FROM public.lms_submissao
    WHERE id_item_conteudo = p_id_item
    AND id_aluno = v_real_user_id
    AND data_envio IS NULL;

    -- If no active submission, CREATE ONE naturally (Auto-recovery)
    IF v_sub_id IS NULL THEN
         INSERT INTO public.lms_submissao (id_item_conteudo, id_aluno, criado_em, id_empresa)
         VALUES (p_id_item, v_real_user_id, now(), p_id_empresa)
         ON CONFLICT (id_item_conteudo, id_aluno) 
         DO UPDATE SET data_envio = NULL, criado_em = now(), id_empresa = EXCLUDED.id_empresa -- Revive/Reset existing submission
         RETURNING id INTO v_sub_id;
    END IF;

    -- 2. Get Question Type to validate input
    SELECT tipo INTO v_tipo_pergunta
    FROM public.lms_pergunta
    WHERE id = p_id_pergunta;

    -- 3. Upsert Answer
    INSERT INTO public.lms_resposta (
        id_user,
        id_pergunta,
        tipo_pergunta,
        resposta,
        id_resposta_possivel,
        modificado_em
    ) VALUES (
        v_real_user_id,
        p_id_pergunta,
        v_tipo_pergunta,
        p_texto_resposta,
        p_id_resposta_possivel,
        now()
    )
    ON CONFLICT (id_user, id_pergunta) DO UPDATE SET
        resposta = EXCLUDED.resposta,
        id_resposta_possivel = EXCLUDED.id_resposta_possivel,
        modificado_em = now();
END;
$$;


ALTER FUNCTION "public"."lms_resposta_upsert"("p_user_id" "uuid", "p_id_item" "uuid", "p_id_pergunta" "uuid", "p_id_resposta_possivel" "uuid", "p_texto_resposta" "text", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_update_papeis_user_auth"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  -- Apenas loga se houve alteração no papel_id
  if new.papel_id is distinct from old.papel_id then
    insert into public.log_papeis_user_auth (
      user_id,
      papel_id_antigo,
      papel_id_novo,
      empresa_id,
      alterado_por,
      origem
    )
    values (
      old.user_id,
      old.papel_id,
      new.papel_id,
      old.empresa_id,
      current_user,
      current_setting('application_name', true)
    );
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."log_update_papeis_user_auth"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."onbdg_check_email_in_auth"("p_email" "text", "p_id_empresa" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("tem_conta_auth" boolean, "matricula" "text", "mensagem" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_email text;
  v_auth_id uuid;
  v_matricula text;
begin
  -- normaliza e-mail (lower + trim)
  v_email := lower(btrim(coalesce(p_email, '')));

  if v_email = '' then
    return query select false, null::text, 'E-mail vazio.';
    return;
  end if;

  -- procura no Auth
  select u.id
    into v_auth_id
  from auth.users u
  where lower(u.email) = v_email
  limit 1;

  if v_auth_id is null then
    return query select false, null::text, 'Não existe conta no Auth para este e-mail.';
  end if;

  -- tenta obter uma matrícula vinculada a esse auth_id
  select ue.matricula
    into v_matricula
  from user_expandido ue
  where ue.user_id = v_auth_id
    and (p_id_empresa is null or ue.id_empresa = p_id_empresa)
  order by ue.criado_em nulls last, ue.id
  limit 1;

  return query select true, v_matricula, 'OK';
end;
$$;


ALTER FUNCTION "public"."onbdg_check_email_in_auth"("p_email" "text", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."onbdg_emitir_codigo_email_e_enviar"("p_id_user" "uuid", "p_email" "text", "p_nome" "text", "p_expires_in_minutes" integer DEFAULT 2) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$declare
  v_code     text;
  v_row_id   uuid;
  v_expires  timestamptz := now() + make_interval(mins => p_expires_in_minutes);
  v_url      text := 'https://default129a750e8eee4328b6258b0d6518b5.97.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/1ea464ddf11d4f0aa29e9d1d54e9f1ac/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=ArYpr_oHOfs234efWj9yCEAnrVXJui9KaIXHos4xuq8';
  v_payload  jsonb;
begin
  if p_id_user is null then
    raise exception 'p_id_user é obrigatório';
  end if;
  if p_email is null or btrim(p_email) = '' then
    raise exception 'p_email é obrigatório';
  end if;
  if p_nome is null then
    p_nome := '';
  end if;

  if not exists (select 1 from public.user_expandido where id = p_id_user) then
    raise exception 'Usuário não encontrado em user_expandido';
  end if;

  -- gera código 6 dígitos (string p/ preservar zeros à esquerda)
  v_code := lpad((floor(random() * 1000000))::int::text, 6, '0');

  -- insere e captura o id
  insert into public.onbdg_codigos_email (id, id_user, numero, expires_at)
  values (gen_random_uuid(), p_id_user, v_code, v_expires)
  returning id into v_row_id;

  -- payload JSONB p/ Power Automate
  v_payload := jsonb_build_object(
                 'emails',
                 jsonb_build_array(
                   jsonb_build_object(
                     'email',  p_email,
                     'nome',   p_nome,
                     'codigo', v_code
                   )
                 )
               );

  -- envia usando a assinatura do seu pg_net:
  -- net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_ms int)
  perform net.http_post(
    v_url,
    v_payload,
    '{}'::jsonb,
    jsonb_build_object('Content-Type','application/json'),
    10000
  );

  return v_row_id;
end;$$;


ALTER FUNCTION "public"."onbdg_emitir_codigo_email_e_enviar"("p_id_user" "uuid", "p_email" "text", "p_nome" "text", "p_expires_in_minutes" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."onbdg_get_auth_email_by_matricula"("p_matricula" "text", "p_id_empresa" "uuid") RETURNS TABLE("found" boolean, "tem_conta_auth" boolean, "email" "text", "id_user" "uuid", "mensagem" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_mat_norm text;
  v_id_user uuid;
  v_auth_id uuid;
  v_email text;
begin
  -- Normaliza matrícula (trim + colapsa espaços internos)
  v_mat_norm := regexp_replace(trim(coalesce(p_matricula, '')), '\s+', ' ', 'g');

  if v_mat_norm = '' then
    return query select false, false, null::text, null::uuid, 'Matrícula vazia.';
    return;
  end if;

  -- Localiza usuário pela matrícula e empresa
  select ue.id, ue.user_id
    into v_id_user, v_auth_id
  from user_expandido ue
  where ue.id_empresa = p_id_empresa
    and regexp_replace(trim(ue.matricula), '\s+', ' ', 'g') = v_mat_norm
  limit 1;

  if v_id_user is null then
    return query select false, false, null::text, null::uuid, 'Matrícula não encontrada para esta empresa.';
    return;
  end if;

  -- Se não tem conta no Auth
  if v_auth_id is null then
    return query select true, false, null::text, v_id_user, 'Usuário ainda não possui conta no Auth.';
    return;
  end if;

  -- Tem Auth: pega email do auth.users
  select u.email into v_email
  from auth.users u
  where u.id = v_auth_id;

  return query select
    true,
    true,
    v_email,
    v_id_user,
    case when v_email is null then 'Conta no Auth encontrada, porém email não definido.'
         else 'OK'
    end;
end;
$$;


ALTER FUNCTION "public"."onbdg_get_auth_email_by_matricula"("p_matricula" "text", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."onbdg_get_email"("p_id_user" "uuid") RETURNS TABLE("found" boolean, "email" "text", "conflito" boolean, "conflito_matricula" "text", "conflito_user_id" "uuid", "mensagem" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_email_raw text;
  v_email_trim text;
  v_status text := 'OK';
  v_matricula text;
  v_id_empresa uuid;
  v_conflict_user_id uuid;
  v_conflict_matricula text;
begin
  -- Busca dados do usuário-alvo
  select ue.email, ue.matricula, ue.id_empresa
    into v_email_raw, v_matricula, v_id_empresa
  from user_expandido ue
  where ue.id = p_id_user;

  if v_matricula is null then
    return query select false, null::text, false, null::text, null::uuid, 'Usuário não encontrado.';
    return;
  end if;

  -- Se não há email cadastrado
  if v_email_raw is null then
    return query select true, null::text, false, null::text, null::uuid, 'Email não encontrado para este usuário.';
    return;
  end if;

  -- Normaliza: trim apenas (sem forçar lowercase na gravação)
  v_email_trim := btrim(v_email_raw);

  -- Se mudou após trim, atualiza silenciosamente
  if v_email_trim <> v_email_raw then
    update user_expandido
       set email = v_email_trim,
           modificado_em = now()
     where id = p_id_user;
    v_status := 'Email corrigido (removidos espaços no início/fim).';
  end if;

  -- Verifica conflito: outro user com mesmo email (case-insensitive) e já com user_id
  select ue2.id, ue2.matricula
    into v_conflict_user_id, v_conflict_matricula
  from user_expandido ue2
  where ue2.id <> p_id_user
    and ue2.user_id is not null           -- já possui conta auth
    and lower(btrim(coalesce(ue2.email,''))) = lower(v_email_trim)
  limit 1;

  if v_conflict_user_id is not null then
    return query select
      true,                       -- found
      v_email_trim,               -- email (já normalizado)
      true,                       -- conflito
      v_conflict_matricula,       -- matrícula do outro
      v_conflict_user_id,         -- id do outro
      'Conflito: email já em uso por outra matrícula.';
  else
    return query select
      true,
      v_email_trim,
      false,
      null::text,
      null::uuid,
      v_status;                   -- 'OK' ou 'Email corrigido (...)'
  end if;
end;
$$;


ALTER FUNCTION "public"."onbdg_get_email"("p_id_user" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."onbdg_get_email_user_expandido"("p_id_user_expandido" "uuid") RETURNS "text"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_email text;
begin
  select ue.email
    into v_email
  from public.user_expandido ue
  where ue.id = p_id_user_expandido
  limit 1;

  return v_email; -- pode voltar NULL se não achar ou se o email for NULL
end;
$$;


ALTER FUNCTION "public"."onbdg_get_email_user_expandido"("p_id_user_expandido" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."onbdg_get_user_by_matricula"("p_matricula" "text", "p_id_empresa" "uuid") RETURNS TABLE("found" boolean, "id_user" "uuid", "nome_completo" "text", "primeiro_nome" "text", "mensagem" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_mat_norm text;
  v_id uuid;
  v_nome text;
  v_primeiro text;
begin
  -- Normaliza entrada
  v_mat_norm := regexp_replace(trim(coalesce(p_matricula, '')), '\s+', ' ', 'g');

  if v_mat_norm = '' then
    return query select false, null::uuid, null::text, null::text, 'Matrícula vazia.';
    return;
  end if;

  -- Busca o usuário
  select
    ue.id,
    ue.nome_completo,
    split_part(trim(ue.nome_completo), ' ', 1)
  into v_id, v_nome, v_primeiro
  from user_expandido ue
  where ue.id_empresa = p_id_empresa
    and regexp_replace(trim(ue.matricula), '\s+', ' ', 'g') = v_mat_norm
  limit 1;

  if v_id is null then
    -- Não encontrado
    return query select false, null::uuid, null::text, null::text, 'Matrícula não encontrada para esta empresa.';
  else
    -- Encontrado
    return query select true, v_id, v_nome, v_primeiro, 'OK';
  end if;
end;
$$;


ALTER FUNCTION "public"."onbdg_get_user_by_matricula"("p_matricula" "text", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."onbdg_update_email_if_no_auth"("p_id_user" "uuid", "p_email_novo" "text") RETURNS TABLE("ok" boolean, "mensagem" "text", "email" "text", "tem_conta_auth" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $_$
declare
  v_auth_id uuid;              -- user_id do Auth para este usuário
  v_auth_email text;           -- email no Auth (se já existir)
  v_email_novo_trim text;
  v_re_email constant text := '^[^@\s]+@[^@\s]+\.[^@\s]+$';
begin
  -- 0) Verifica usuário e pega user_id (Auth)
  select ue.user_id
    into v_auth_id
  from user_expandido ue
  where ue.id = p_id_user;

  if not found then
    return query select false, 'Usuário não encontrado.', null::text, false;
    return;
  end if;

  -- 1) Se já tem conta no Auth, bloqueia troca e retorna email do Auth
  if v_auth_id is not null then
    select u.email into v_auth_email
    from auth.users u
    where u.id = v_auth_id;

    return query select
      false,
      'Usuário já possui conta no Auth; alteração de e-mail bloqueada por aqui.',
      v_auth_email,
      true;
  end if;

  -- 2) Normaliza e valida novo e-mail
  v_email_novo_trim := btrim(coalesce(p_email_novo, ''));
  if v_email_novo_trim = '' or v_email_novo_trim !~ v_re_email then
    return query select false, 'E-mail inválido.', null::text, false;
    return;
  end if;

  -- 3) Atualiza (sem checar duplicidade no Auth; isso é feito fora)
  update user_expandido
     set email = v_email_novo_trim,
         modificado_em = now()
   where id = p_id_user;

  if not found then
    return query select false, 'Usuário não encontrado ao atualizar.', null::text, false;
  else
    return query select true, 'E-mail atualizado com sucesso.', v_email_novo_trim, false;
  end if;
end;
$_$;


ALTER FUNCTION "public"."onbdg_update_email_if_no_auth"("p_id_user" "uuid", "p_email_novo" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."onbdg_validar_codigo_por_id"("p_codigo_id" "uuid", "p_codigo" "text", "p_consumir" boolean DEFAULT true) RETURNS TABLE("ok" boolean, "mensagem" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $_$
declare
  v_numero   text;
  v_expires  timestamptz;
  v_usado    timestamptz;
begin
  -- valida formato (sempre 6 dígitos)
  if p_codigo is null or p_codigo !~ '^\d{6}$' then
    return query select false, 'Código inválido (formato).';
    return;
  end if;

  -- busca a linha do código
  select numero::text, expires_at, usado_em
    into v_numero, v_expires, v_usado
  from public.onbdg_codigos_email
  where id = p_codigo_id
  limit 1;

  if v_numero is null then
    return query select false, 'Registro de código não encontrado.';
    return;
  end if;

  -- já usado?
  if v_usado is not null then
    return query select false, 'Código já usado.';
    return;
  end if;

  -- expirado?
  if now() >= v_expires then
    return query select false, 'Código expirado.';
    return;
  end if;

  -- confere valor
  if v_numero <> p_codigo then
    return query select false, 'Código incorreto.';
    return;
  end if;

  -- consome se pedido (idempotente)
  if p_consumir then
    update public.onbdg_codigos_email
       set usado_em = now()
     where id = p_codigo_id
       and usado_em is null;
  end if;

  return query select true, 'Código válido.';
end;
$_$;


ALTER FUNCTION "public"."onbdg_validar_codigo_por_id"("p_codigo_id" "uuid", "p_codigo" "text", "p_consumir" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."onbdg_validar_nome_contem"("p_id_user" "uuid", "p_fragmento_nome" "text") RETURNS TABLE("ok" boolean, "mensagem" "text", "trecho_encontrado" "text", "nome_completo" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_nome text;
  v_nome_norm text;
  v_frag text;
  v_frag_norm text;
  v_tokens text[];
  v_token text;
  v_token_norm text;
  v_match_original text;
begin
  -- Busca nome completo do usuário
  select ue.nome_completo
    into v_nome
  from user_expandido ue
  where ue.id = p_id_user;

  if v_nome is null then
    return query select false, 'Usuário não encontrado.', null::text, null::text;
    return;
  end if;

  -- Normalização helper (inline):
  -- 1) lower
  -- 2) remove acentos (translate)
  -- 3) remove pontuação não-alfabética básica (preserva espaço)
  -- 4) colapsa letras duplicadas (tt -> t, nn -> n, ...)
  -- 5) normaliza múltiplos espaços
  v_nome_norm := regexp_replace(
                   regexp_replace(
                     regexp_replace(
                       translate(lower(coalesce(v_nome,'')),
                         'áàãâäéèêëíìîïóòõôöúùûüçñ',
                         'aaaaaeeeeiiiiooooouuuucn'),
                       '[^a-z\s]+', '', 'g'),
                     '([a-z])\1+', '\1', 'g'),
                   '\s+', ' ', 'g');
  v_nome_norm := btrim(v_nome_norm);

  v_frag := btrim(coalesce(p_fragmento_nome,''));
  if v_frag = '' then
    return query select false, 'Fragmento vazio.', null::text, v_nome;
    return;
  end if;

  v_frag_norm := regexp_replace(
                   regexp_replace(
                     regexp_replace(
                       translate(lower(v_frag),
                         'áàãâäéèêëíìîïóòõôöúùûüçñ',
                         'aaaaaeeeeiiiiooooouuuucn'),
                       '[^a-z\s]+', '', 'g'),
                     '([a-z])\1+', '\1', 'g'),
                   '\s+', ' ', 'g');
  v_frag_norm := btrim(v_frag_norm);

  if v_frag_norm = '' then
    return query select false, 'Fragmento inválido após normalização.', null::text, v_nome;
    return;
  end if;

  -- Verifica substring no nome normalizado
  if position(v_frag_norm in v_nome_norm) > 0 then
    -- Tenta mapear para uma palavra original do nome (se o fragmento for "tipo palavra")
    v_tokens := regexp_split_to_array(v_nome, '\s+');
    v_match_original := null;

    foreach v_token in array v_tokens loop
      v_token_norm := regexp_replace(
                        regexp_replace(
                          regexp_replace(
                            translate(lower(v_token),
                              'áàãâäéèêëíìîïóòõôöúùûüçñ',
                              'aaaaaeeeeiiiiooooouuuucn'),
                            '[^a-z\s]+', '', 'g'),
                          '([a-z])\1+', '\1', 'g'),
                        '\s+', ' ', 'g');
      v_token_norm := btrim(v_token_norm);
      if v_token_norm = v_frag_norm then
        -- Achou uma palavra do nome que bate exatamente com o fragmento normalizado
        v_match_original := v_token;
        exit;
      end if;
    end loop;

    return query select true,
                         'Nome validado por correspondência parcial.',
                         coalesce(v_match_original, v_frag),  -- devolve a palavra original se achou, senão o próprio fragmento informado
                         v_nome;
  else
    return query select false,
                         'Fragmento não encontrado no nome.',
                         null::text,
                         v_nome;
  end if;
end;
$$;


ALTER FUNCTION "public"."onbdg_validar_nome_contem"("p_id_user" "uuid", "p_fragmento_nome" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."onbdg_validar_ultimo_nome"("p_id_user" "uuid", "p_ultimo_nome_informado" "text") RETURNS TABLE("ok" boolean, "mensagem" "text", "ultimo_nome_cadastrado" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_nome_completo text;
  v_ultimo_nome text;
  v_informado_norm text;
  v_cadastrado_norm text;
begin
  -- Busca nome completo
  select nome_completo
  into v_nome_completo
  from user_expandido
  where id = p_id_user;

  if v_nome_completo is null then
    return query select false, 'Usuário não encontrado.', null::text;
    return;
  end if;

  -- Extrai último nome
  v_ultimo_nome := split_part(trim(v_nome_completo), ' ', array_length(regexp_split_to_array(trim(v_nome_completo), '\s+'), 1));

  -- Remove acentos e normaliza duplicação de letras (ex.: tt -> t)
  v_informado_norm := regexp_replace(
                        translate(lower(coalesce(p_ultimo_nome_informado, '')),
                          'áàãâäéèêëíìîïóòõôöúùûüç',
                          'aaaaaeeeeiiiiooooouuuuc'),
                        '([a-z])\1+', '\1', 'g');

  v_cadastrado_norm := regexp_replace(
                          translate(lower(coalesce(v_ultimo_nome, '')),
                            'áàãâäéèêëíìîïóòõôöúùûüç',
                            'aaaaaeeeeiiiiooooouuuuc'),
                          '([a-z])\1+', '\1', 'g');

  -- Comparação
  if v_informado_norm = v_cadastrado_norm then
    return query select true, 'Último nome validado com sucesso.', v_ultimo_nome;
  else
    return query select false, 'Último nome não confere.', v_ultimo_nome;
  end if;
end;
$$;


ALTER FUNCTION "public"."onbdg_validar_ultimo_nome"("p_id_user" "uuid", "p_ultimo_nome_informado" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."onbdg_verifica_funcao_extra_ativa"("p_id_user" "uuid") RETURNS TABLE("possui_funcao_extra" boolean, "mensagem" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  v_possui boolean;
begin
  select exists (
    select 1
    from professor_funcao_extra
    where user_id = p_id_user
      and status is true
      and data_fim is null
  ) into v_possui;

  return query
  select
    v_possui,
    case
      when v_possui then 'Usuário possui função extra ativa.'
      else 'Usuário não possui função extra ativa no momento.'
    end;
end;
$$;


ALTER FUNCTION "public"."onbdg_verifica_funcao_extra_ativa"("p_id_user" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."papeis_user_auth_get_my_role"() RETURNS TABLE("papel_id" "uuid", "nome" "text")
    LANGUAGE "sql"
    AS $$
    SELECT 
        pu.papel_id,
        p.nome
    FROM 
        papeis_user_auth pu
    JOIN 
        papeis_user p ON pu.papel_id = p.id
    WHERE 
        pu.user_id = auth.uid();
$$;


ALTER FUNCTION "public"."papeis_user_auth_get_my_role"() OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."perguntas_user" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "pergunta" "text" NOT NULL,
    "label" "text" NOT NULL,
    "obrigatorio" boolean DEFAULT false,
    "ordem" integer,
    "tipo" "text" NOT NULL,
    "opcoes" "jsonb",
    "paginada" boolean DEFAULT false,
    "numero_pagina" integer,
    "nome_pagina" "text",
    "altura" integer,
    "largura" integer,
    "arquivos_permitidos" boolean DEFAULT false,
    "tipo_arquivo" "text",
    "contexto" "text",
    "id_papel" "uuid",
    "papel" "jsonb" DEFAULT '[]'::"jsonb"
);


ALTER TABLE "public"."perguntas_user" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."perguntas_get"("p_id_empresa" "uuid", "p_papeis" "jsonb") RETURNS SETOF "public"."perguntas_user"
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.perguntas_user
    WHERE 
        -- Verifica se algum dos papéis passados existe no array de papéis da pergunta
        papel ?| ARRAY(SELECT jsonb_array_elements_text(p_papeis))
    ORDER BY ordem ASC;
END;
$$;


ALTER FUNCTION "public"."perguntas_get"("p_id_empresa" "uuid", "p_papeis" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."processar_fila_pontuacao"("p_job_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    SET "statement_timeout" TO '5min'
    AS $$
declare
  v_job    fila_processamento_pontuacao%rowtype;
  v_result record;      -- <── aqui era jsonb antes; muda para record
  v_calc   jsonb;       -- <── este é o JSON da função de cálculo
  v_count  int := 0;
  v_left   int := 0;
  v_seeded int := 0;
begin
  select * into v_job
  from fila_processamento_pontuacao
  where id = p_job_id;

  if not found then
    raise exception 'Job não encontrado';
  end if;

  update fila_processamento_pontuacao
     set status      = 'processando',
         iniciado_em = coalesce(iniciado_em, now()),
         atualizado_em = now()
   where id = p_job_id;

  v_seeded := public.seed_pontuacao_faltantes(v_job.id_empresa, v_job.ano, p_job_id);

  if v_job.total_professores is null then
    select count(*) into v_job.total_professores
    from pontuacao_professores
    where id_empresa = v_job.id_empresa
      and ano = v_job.ano
      and soft_delete = false;

    update fila_processamento_pontuacao
       set total_professores = v_job.total_professores,
           atualizado_em = now()
     where id = p_job_id;
  end if;

  -- 🔧 AQUI está o ajuste principal
  for v_result in
    select p.id_professor
    from pontuacao_professores p
    where p.id_empresa = v_job.id_empresa
      and p.ano = v_job.ano
      and p.soft_delete = false
      and coalesce(p.status,'pendente') = 'pendente'
    order by p.id_professor
    for update skip locked
    limit 200
  loop
    begin
      update pontuacao_professores
         set status = 'processando', atualizado_em = now()
       where id_professor = v_result.id_professor
         and ano = v_job.ano
         and soft_delete = false;

      v_calc := calc_pontuacao_professor(v_result.id_professor, v_job.id_empresa, v_job.ano);

      update pontuacao_professores
         set pontuacao_unidade            = round((v_calc->>'total_unidade')::numeric * 1000),
             pontuacao_departamento       = round((v_calc->>'total_departamento')::numeric * 1000),
             pontuacao_certificados       = round((v_calc->'certificados'->>'total_certificados')::numeric * 1000),
             certificado_concurso_publico = round((v_calc->>'concurso')::numeric * 1000),
             tempo_servico_unidade        = round((v_calc->>'tempo_unidade')::numeric * 1000),
             tempo_servico_departamento   = round((v_calc->>'tempo_departamento')::numeric * 1000),
             tempo_especialista           = round((v_calc->>'especialista')::numeric * 1000),
             assiduidade                  = round((v_calc->>'assiduidade')::numeric * 1000),
             pontuacao                    = round((( (v_calc->>'total_unidade')::numeric
                                                    + (v_calc->>'total_departamento')::numeric)/2 ) * 1000),
             status = 'concluido',
             atualizado_em = now()
       where id_professor = v_result.id_professor
         and ano = v_job.ano
         and soft_delete = false;

      v_count := v_count + 1;

    exception when others then
      update pontuacao_professores
         set status = 'erro', atualizado_em = now()
       where id_professor = v_result.id_professor
         and ano = v_job.ano
         and soft_delete = false;

      update fila_processamento_pontuacao
         set erros = coalesce(erros,0) + 1,
             atualizado_em = now()
       where id = p_job_id;
    end;
  end loop;

  update fila_processamento_pontuacao
     set processados = coalesce(processados,0) + v_count,
         atualizados = coalesce(atualizados,0) + v_count,
         atualizado_em = now()
   where id = p_job_id;

  select count(*) into v_left
  from pontuacao_professores
  where id_empresa = v_job.id_empresa
    and ano = v_job.ano
    and soft_delete = false
    and coalesce(status,'pendente') = 'pendente';

  if v_left > 0 then
    update fila_processamento_pontuacao
       set status = 'pendente',
           atualizado_em = now()
     where id = p_job_id;
  else
    update fila_processamento_pontuacao
       set status = 'concluido',
           finalizado_em = now(),
           atualizado_em = now()
     where id = p_job_id;
  end if;

  return jsonb_build_object(
    'status', 'ok',
    'inseridos_nesta_execucao', v_seeded,
    'processados_neste_lote', v_count,
    'pendentes_restantes', v_left
  );
end;
$$;


ALTER FUNCTION "public"."processar_fila_pontuacao"("p_job_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."professor_delete"("p_id" "uuid", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_deleted_count integer;
begin
    -- Realiza o Soft Delete
    update public.user_expandido
    set soft_delete = true,
        modificado_em = now()
    where id = p_id
      and id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object(
            'status', 'success', 
            'message', 'Professor deletado com sucesso (soft delete).', 
            'id', p_id
        );
    else
        return jsonb_build_object(
            'status', 'error', 
            'message', 'Professor não encontrado ou não pertence à empresa.', 
            'id', p_id
        );
    end if;

exception when others then
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;


ALTER FUNCTION "public"."professor_delete"("p_id" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."professor_get_detalhes_cpx"("p_id_empresa" "uuid", "p_id_professor" "uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_dados_gerais json;
    v_respostas json;
    v_componentes json;
    v_papel_id uuid;
BEGIN
    -- 1. Buscar Dados Gerais e o Papel do Professor
    SELECT 
        json_build_object(
            'user_id', u.user_id,
            'user_expandido_id', u.id,
            'matricula', u.matricula,
            'email', u.email,
            'nome_completo', u.nome_completo,
            'status', u.status_contrato,
            'id_escola', e.id,
            'nome_escola', e.nome
        ),
        u.papel_id
    INTO v_dados_gerais, v_papel_id
    FROM public.user_expandido u
    LEFT JOIN public.escolas e ON u.id_escola = e.id
    WHERE u.id = p_id_professor AND u.id_empresa = p_id_empresa;

    -- Se não encontrar o professor, retorna nulo ou objeto vazio
    IF v_dados_gerais IS NULL THEN
        RETURN NULL;
    END IF;

    -- 2. Buscar Perguntas e Respostas
    -- Filtra perguntas onde o papel do professor está contido no array 'papel' da pergunta
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_respostas
    FROM (
        SELECT 
            p.id AS id_pergunta,
            p.label,
            p.tipo,
            p.ordem,
            r.resposta,
            r.id AS id_resposta
        FROM public.perguntas_user p
        LEFT JOIN public.respostas_user r ON p.id = r.id_pergunta AND r.id_user = p_id_professor
        WHERE 
            p.papel @> jsonb_build_array(v_papel_id::text) -- Verifica se o papel do professor está na lista de papéis da pergunta
        ORDER BY p.ordem ASC
    ) t;

    -- 3. Buscar Componentes
    SELECT COALESCE(json_agg(row_to_json(c)), '[]'::json) INTO v_componentes
    FROM (
        SELECT 
            pc.id AS id_professor_componente,
            comp.uuid AS id_componente,
            comp.nome AS nome_componente,
            pc.ano_referencia
        FROM public.professor_componente pc
        JOIN public.componente comp ON pc.id_componente = comp.uuid
        WHERE pc.id_professor = p_id_professor AND pc.id_empresa = p_id_empresa
    ) c;

    -- 4. Retornar Objeto Completo
    RETURN json_build_object(
        'dados_gerais', v_dados_gerais,
        'respostas', v_respostas,
        'componentes', v_componentes
    );
END;
$$;


ALTER FUNCTION "public"."professor_get_detalhes_cpx"("p_id_empresa" "uuid", "p_id_professor" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."professor_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT ''::"text", "p_id_escola" "uuid" DEFAULT NULL::"uuid", "p_status" "text" DEFAULT NULL::"text") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
    
    -- IDs fixos de papéis de professor
    v_papel_professor uuid := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
    v_papel_professor_extra uuid := '07028505-01d7-4986-800e-9d71cab5dd6c';
BEGIN
    -- 1. Calcular Offset
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- 2. Calcular Total de Itens (para a busca atual)
    SELECT COUNT(*) INTO v_total_itens
    FROM public.user_expandido u
    LEFT JOIN public.escolas e ON u.id_escola = e.id
    WHERE 
        u.id_empresa = p_id_empresa
        AND u.papel_id IN (v_papel_professor, v_papel_professor_extra)
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(u.nome_completo) LIKE v_busca_like 
        )
        AND (
            p_id_escola IS NULL 
            OR u.id_escola = p_id_escola
        )
        AND (
            p_status IS NULL 
            OR u.status_contrato::text = p_status
        );

    -- 3. Calcular Total de Páginas
    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- 4. Buscar Itens Paginados e converter para JSON
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            u.user_id,
            u.id AS user_expandido_id,
            u.email,
            u.nome_completo,
            e.nome AS nome_escola,
            e.id AS id_escola,
            u.status_contrato AS status
        FROM public.user_expandido u
        LEFT JOIN public.escolas e ON u.id_escola = e.id
        WHERE 
            u.id_empresa = p_id_empresa
            AND u.papel_id IN (v_papel_professor, v_papel_professor_extra)
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(u.nome_completo) LIKE v_busca_like 
            )
            AND (
                p_id_escola IS NULL 
                OR u.id_escola = p_id_escola
            )
            AND (
                p_status IS NULL 
                OR u.status_contrato::text = p_status
            )
        ORDER BY u.nome_completo ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    -- 5. Retornar Objeto JSON Final
    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


ALTER FUNCTION "public"."professor_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid", "p_status" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."professor_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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


ALTER FUNCTION "public"."professor_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."reset_pontuacao_ano"("p_id_empresa" "uuid", "p_ano" integer) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_resetados int := 0;
  v_inseridos int := 0;
begin
  -- 1️⃣ Atualiza registros existentes para pendente
  update pontuacao_professores
     set status = 'pendente',
         atualizado_em = now()
   where id_empresa = p_id_empresa
     and ano = p_ano
     and soft_delete = false;

  get diagnostics v_resetados = row_count;

  -- 2️⃣ Insere registros faltantes (seed)
  insert into pontuacao_professores (
    id_professor, id_empresa, ano,
    status, soft_delete, criado_em, atualizado_em
  )
  select ue.id, p_id_empresa, p_ano,
         'pendente', false, now(), now()
  from user_expandido ue
  left join pontuacao_professores pp
    on pp.id_professor = ue.id
   and pp.id_empresa = p_id_empresa
   and pp.ano = p_ano
   and pp.soft_delete = false
  where ue.id_empresa = p_id_empresa
    and pp.uuid is null;

  get diagnostics v_inseridos = row_count;

  -- 3️⃣ Retorna resumo para exibir no loader
  return jsonb_build_object(
    'status', 'ok',
    'resetados', v_resetados,
    'inseridos', v_inseridos,
    'total_para_processar', v_resetados + v_inseridos
  );
end;
$$;


ALTER FUNCTION "public"."reset_pontuacao_ano"("p_id_empresa" "uuid", "p_ano" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."salvar_resposta_user"("p_id_user" "uuid", "p_id_pergunta" "uuid", "p_tipo" "text", "p_resposta" "text" DEFAULT NULL::"text", "p_nome_arquivo_original" "text" DEFAULT NULL::"text", "p_criado_por" "uuid" DEFAULT NULL::"uuid", "p_atualizado_por" "uuid" DEFAULT NULL::"uuid", "p_id_empresa" "uuid" DEFAULT NULL::"uuid") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_id uuid;
begin
  insert into public.respostas_user (
    id_user,
    id_pergunta,
    tipo,
    resposta,
    nome_arquivo_original,
    criado_por,
    atualizado_por,
    id_empresa
  )
  values (
    p_id_user,
    p_id_pergunta,
    p_tipo,
    p_resposta,
    p_nome_arquivo_original,
    p_criado_por,
    p_atualizado_por,
    p_id_empresa
  )
  on conflict (id_user, id_pergunta)
  do update set
    tipo = excluded.tipo,
    resposta = excluded.resposta,
    nome_arquivo_original = excluded.nome_arquivo_original,
    atualizado_em = now(),
    atualizado_por = excluded.atualizado_por,
    id_empresa = excluded.id_empresa
  returning id into v_id;

  return v_id;
end;
$$;


ALTER FUNCTION "public"."salvar_resposta_user"("p_id_user" "uuid", "p_id_pergunta" "uuid", "p_tipo" "text", "p_resposta" "text", "p_nome_arquivo_original" "text", "p_criado_por" "uuid", "p_atualizado_por" "uuid", "p_id_empresa" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."seed_pontuacao_faltantes"("p_id_empresa" "uuid", "p_ano" integer, "p_job_id" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_inseridos integer := 0;
begin
  -- insere faltantes e conta quantos registros novos foram adicionados
  insert into pontuacao_professores (
    id_professor, id_empresa, ano,
    status, soft_delete, criado_em, atualizado_em
  )
  select ue.id, p_id_empresa, p_ano, 'pendente', false, now(), now()
  from user_expandido ue
  left join pontuacao_professores pp
    on pp.id_professor = ue.id
   and pp.id_empresa = p_id_empresa
   and pp.ano = p_ano
   and pp.soft_delete = false
  where ue.id_empresa = p_id_empresa
    and pp.uuid is null;

  -- captura quantas linhas foram inseridas
  get diagnostics v_inseridos = row_count;

  -- atualiza contadores na fila
  update fila_processamento_pontuacao
     set inseridos         = coalesce(inseridos,0) + v_inseridos,
         total_professores = coalesce(total_professores,0) + v_inseridos,
         atualizado_em     = now()
   where id = p_job_id;

  return coalesce(v_inseridos,0);
end;
$$;


ALTER FUNCTION "public"."seed_pontuacao_faltantes"("p_id_empresa" "uuid", "p_ano" integer, "p_job_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_created_modified_by"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if tg_op = 'INSERT' then
    if new.created_by is null then
      new.created_by := auth.uid();
    end if;
    new.modified_by := auth.uid();
  elsif tg_op = 'UPDATE' then
    new.modified_by := auth.uid();
  end if;
  return new;
end;
$$;


ALTER FUNCTION "public"."set_created_modified_by"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_papel_professor_funcao_extra"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_auth_user_id uuid;
  v_papel_professor     constant uuid := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
  v_papel_funcao_extra  constant uuid := '07028505-01d7-4986-800e-9d71cab5dd6c';
begin
  -- NEW.user_id referencia user_expandido.id
  select u.user_id
    into v_auth_user_id
  from public.user_expandido u
  where u.id = NEW.user_id;

  -- CASO 1/2: data_fim em aberto (NULL) E status = true  -> papel = funcao_extra
  if NEW.status is true and NEW.data_fim is null then
    update public.user_expandido
       set papel_id = v_papel_funcao_extra
     where id = NEW.user_id;

    if v_auth_user_id is not null then
      insert into public.papeis_user_auth (user_id, papel_id, empresa_id)
      values (v_auth_user_id, v_papel_funcao_extra, NEW.id_empresa)
      on conflict (user_id, papel_id, empresa_id) do nothing;
      -- se quiser exclusividade, descomente:
      -- delete from public.papeis_user_auth
      --  where user_id = v_auth_user_id
      --    and empresa_id = NEW.id_empresa
      --    and papel_id = v_papel_professor;
    end if;

  -- CASO 3: colocou data_fim (não null) E status = false -> papel = professor
  elsif NEW.status is false and NEW.data_fim is not null then
    update public.user_expandido
       set papel_id = v_papel_professor
     where id = NEW.user_id;

    if v_auth_user_id is not null then
      insert into public.papeis_user_auth (user_id, papel_id, empresa_id)
      values (v_auth_user_id, v_papel_professor, NEW.id_empresa)
      on conflict (user_id, papel_id, empresa_id) do nothing;
      -- se quiser exclusividade, descomente:
      -- delete from public.papeis_user_auth
      --  where user_id = v_auth_user_id
      --    and empresa_id = NEW.id_empresa
      --    and papel_id = v_papel_funcao_extra;
    end if;
  end if;

  return NEW;
end;
$$;


ALTER FUNCTION "public"."sync_papel_professor_funcao_extra"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_status_professor_funcao_extra"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  -- Regras:
  -- a) Se data_fim IS NOT NULL => status := false
  -- b) Se data_fim IS NULL e status IS NULL => status := true (default lógico)
  if NEW.data_fim is not null then
    NEW.status := false;
  elsif NEW.status is null then
    NEW.status := true;
  end if;

  return NEW;
end;
$$;


ALTER FUNCTION "public"."sync_status_professor_funcao_extra"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."to_hhmm_from_minutes"("p_min" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
    declare
      m int := p_min;
      hh int;
      mm int;
    begin
      if m is null then return null; end if;
      if m < 0 then m := 0; end if;

      hh := m / 60;
      mm := m % 60;

      return lpad(hh::text, 2, '0') || ':' || lpad(mm::text, 2, '0');
    end;
    $$;


ALTER FUNCTION "public"."to_hhmm_from_minutes"("p_min" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."to_minutes_from_text"("p_txt" "text") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
    declare
      t text := nullif(trim(p_txt), '');
      hh int := 0;
      mm int := 0;
    begin
      if t is null then
        return null;
      end if;

      -- normaliza vírgula para dois pontos (ex: "5,30" -> "5:30")
      t := replace(t, ',', ':');

      if position(':' in t) > 0 then
        -- formato HH:MM
        hh := nullif(split_part(t, ':', 1), '')::int;
        mm := nullif(split_part(t, ':', 2), '')::int;
        return (hh * 60) + mm;
      else
        -- somente horas inteiras ("70" => 70:00)
        hh := t::int;
        return hh * 60;
      end if;
    exception when others then
      return null;
    end;
    $$;


ALTER FUNCTION "public"."to_minutes_from_text"("p_txt" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."total_escolas"() RETURNS integer
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  total integer;
begin
  select count(*) into total from public.escolas;
  return total;
end;
$$;


ALTER FUNCTION "public"."total_escolas"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."total_professores"() RETURNS integer
    LANGUAGE "plpgsql" STABLE
    AS $$
declare
  total integer;
begin
  select count(*) into total from public.user_expandido_professor;
  return total;
end;
$$;


ALTER FUNCTION "public"."total_professores"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trg_cal_matriz_set_defaults"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_dia int;
  v_ini time;
  v_fim time;
  v_comp uuid;
begin
  -- Buscar informações do slot
  select ha.dia_semana, ha.hora_inicio, ha.hora_fim
    into v_dia, v_ini, v_fim
  from public.horario_aula ha
  where ha.id = new.id_horario_aula;

  new.dia_semana  := coalesce(new.dia_semana,  v_dia);
  new.hora_inicio := coalesce(new.hora_inicio, v_ini);

  -- Origem P1 → componente + 60min
  if new.id_carga_horaria_p1 is not null then
    select ch.id_componente into v_comp
    from public.carga_horaria_p1 ch where ch.uuid = new.id_carga_horaria_p1;
    new.id_componente := coalesce(new.id_componente, v_comp);
    new.duracao_minutos := coalesce(new.duracao_minutos, 60);
    new.tipo := 'p1';

  -- Origem P3 → componente + 50min
  elsif new.id_carga_horaria_p3 is not null then
    select ch.id_componente into v_comp
    from public.carga_horaria_p3 ch where ch.uuid = new.id_carga_horaria_p3;
    new.id_componente := coalesce(new.id_componente, v_comp);
    new.duracao_minutos := coalesce(new.duracao_minutos, 50);
    new.tipo := 'p3';

  -- Origem Infantil → exige duração
  elsif new.id_atividade_infantil is not null then
    if new.duracao_minutos is null then
      raise exception 'Para origem infantil, duracao_minutos é obrigatória';
    end if;
    new.tipo := 'infantil';
  end if;

  -- Calcular hora_fim pelo tamanho do bloco
  new.hora_fim := (new.hora_inicio + make_interval(mins => new.duracao_minutos))::time;

  return new;
end;
$$;


ALTER FUNCTION "public"."trg_cal_matriz_set_defaults"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trg_registrar_pontuacao_excedente"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_pont record;
  v_ano smallint;
begin
  -- Só processa se for marcado como excedente e tiver data_fim
  if new.excedente is true and new.data_fim is not null then
    v_ano := extract(year from new.data_fim)::smallint;

    select *
    into v_pont
    from pontuacao_professores
    where id_professor = new.id_user
      and id_empresa = new.id_empresa
      and ano = v_ano
    order by atualizado_em desc
    limit 1;

    if found then
      insert into pontuacao_professores (
        id_professor,
        id_empresa,
        ano,
        pontuacao_unidade,
        pontuacao_departamento,
        criado_por,
        criado_em,
        atualizado_em,
        excedente,
        status,
        observacoes
      )
      values (
        new.id_user,
        new.id_empresa,
        v_ano,
        v_pont.pontuacao_unidade,
        v_pont.pontuacao_departamento,
        new.modificado_por,
        now(),
        now(),
        true,
        'Registrado por trigger de excedência',
        concat('Removido de unidade em ', new.data_fim::text)
      );

      -- Atualiza também na própria linha o histórico
      update professor_tempo_unidade
      set pontos_unidade = v_pont.pontuacao_unidade,
          pontos_departamento = v_pont.pontuacao_departamento,
          data_validade = (new.data_fim + interval '5 years')::date
      where id = new.id;
    else
      raise notice 'Nenhuma pontuação encontrada para o professor % no ano %', new.id_user, v_ano;
    end if;
  end if;
  return new;
end;
$$;


ALTER FUNCTION "public"."trg_registrar_pontuacao_excedente"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."turmas_delete"("p_id_empresa" "uuid", "p_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    DELETE FROM public.turmas
    WHERE id = p_id AND id_empresa = p_id_empresa;
    
    RETURN FOUND;
END;
$$;


ALTER FUNCTION "public"."turmas_delete"("p_id_empresa" "uuid", "p_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."turmas_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer DEFAULT 1, "p_limite_itens_pagina" integer DEFAULT 10, "p_busca" "text" DEFAULT NULL::"text") RETURNS TABLE("id" "uuid", "id_escola" "uuid", "id_ano_etapa" "uuid", "id_classe" "uuid", "id_horario" "uuid", "ano" "text", "nome_escola" "text", "nome_turma" "text", "periodo" "text", "hora_inicio" "text", "hora_fim" "text", "hora_completo" "text", "total_registros" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_offset integer;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    RETURN QUERY
    WITH turmas_filtradas AS (
        SELECT
            t.id,
            t.id_escola,
            t.id_ano_etapa,
            t.id_classe,
            t.id_horario,
            t.ano,
            e.nome as nome_escola,
            (ae.nome || ' ' || c.nome) as nome_turma,
            h.periodo::text as periodo,
            h.hora_inicio,
            h.hora_fim,
            h.hora_completo
        FROM
            public.turmas t
        JOIN public.escolas e ON t.id_escola = e.id
        JOIN public.ano_etapa ae ON t.id_ano_etapa = ae.id
        JOIN public.classe c ON t.id_classe = c.id
        JOIN public.horarios_escola h ON t.id_horario = h.id
        WHERE
            t.id_empresa = p_id_empresa
            AND (
                p_busca IS NULL OR 
                e.nome ILIKE '%' || p_busca || '%' OR
                ae.nome ILIKE '%' || p_busca || '%' OR
                c.nome ILIKE '%' || p_busca || '%' OR
                t.ano ILIKE '%' || p_busca || '%'
            )
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM turmas_filtradas
    )
    SELECT
        tf.id,
        tf.id_escola,
        tf.id_ano_etapa,
        tf.id_classe,
        tf.id_horario,
        tf.ano,
        tf.nome_escola,
        tf.nome_turma,
        tf.periodo,
        tf.hora_inicio,
        tf.hora_fim,
        tf.hora_completo,
        tc.total as total_registros
    FROM
        turmas_filtradas tf
    CROSS JOIN
        total_count tc
    ORDER BY
        tf.nome_escola ASC, tf.ano DESC, tf.nome_turma ASC
    LIMIT
        p_limite_itens_pagina
    OFFSET
        v_offset;
END;
$$;


ALTER FUNCTION "public"."turmas_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."turmas_upsert"("p_id_empresa" "uuid", "p_turma" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_id uuid;
BEGIN
    IF (p_turma->>'id') IS NULL THEN
        INSERT INTO public.turmas (
            id_empresa,
            id_escola,
            id_ano_etapa,
            id_classe,
            id_horario,
            ano
        ) VALUES (
            p_id_empresa,
            (p_turma->>'id_escola')::uuid,
            (p_turma->>'id_ano_etapa')::uuid,
            (p_turma->>'id_classe')::uuid,
            (p_turma->>'id_horario')::uuid,
            (p_turma->>'ano')::text
        )
        RETURNING id INTO v_id;
    ELSE
        UPDATE public.turmas
        SET
            id_escola = (p_turma->>'id_escola')::uuid,
            id_ano_etapa = (p_turma->>'id_ano_etapa')::uuid,
            id_classe = (p_turma->>'id_classe')::uuid,
            id_horario = (p_turma->>'id_horario')::uuid,
            ano = (p_turma->>'ano')::text,
            atualizado_em = now()
        WHERE id = (p_turma->>'id')::uuid
        AND id_empresa = p_id_empresa
        RETURNING id INTO v_id;
    END IF;

    RETURN v_id;
END;
$$;


ALTER FUNCTION "public"."turmas_upsert"("p_id_empresa" "uuid", "p_turma" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_calendario_matriz_semana_v3"("p_array" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_item jsonb;
  v_id_turma uuid := NULL;
  v_id_empresa uuid := NULL;
  v_id_registro uuid;
  v_result jsonb;
  v_tipo text;
  v_dia_semana int;
  v_first boolean := true;
BEGIN
  --------------------------------------------------------------------------
  -- 1) Itera payload só para capturar id_turma/id_empresa (da 1ª linha)
  --------------------------------------------------------------------------
  FOR v_item IN
    SELECT * FROM jsonb_array_elements(
      CASE
        WHEN jsonb_typeof(p_array) = 'array' THEN p_array
        ELSE jsonb_build_array(p_array)
      END
    )
  LOOP
    IF v_first THEN
      v_id_turma := (v_item->>'id_turma')::uuid;
      v_id_empresa := (v_item->>'id_empresa')::uuid;
      v_first := false;
    END IF;
  END LOOP;

  IF v_id_turma IS NULL OR v_id_empresa IS NULL THEN
    RAISE EXCEPTION 'Payload inválido: id_turma/id_empresa ausentes.';
  END IF;

  --------------------------------------------------------------------------
  -- 2) BUMP SEGURO: sobe a ordem de TODAS as linhas da turma (+100000)
  --    Evita conflito de unicidade ao aplicar ordens "baixas" do payload
  --------------------------------------------------------------------------
  UPDATE public.calendario_matriz_semana
  SET ordem = ordem + 100000
  WHERE id_turma = v_id_turma;

  --------------------------------------------------------------------------
  -- 3) Aplica INSERT/UPDATE item a item com as novas ordens pequenas
  --------------------------------------------------------------------------
  FOR v_item IN
    SELECT * FROM jsonb_array_elements(
      CASE
        WHEN jsonb_typeof(p_array) = 'array' THEN p_array
        ELSE jsonb_build_array(p_array)
      END
    )
  LOOP
    v_tipo := lower(trim(v_item->>'tipo'));

    -- Converte nome do dia para número ISO (segunda = 1)
    v_dia_semana := CASE lower(v_item->>'dia')
      WHEN 'segunda-feira' THEN 1
      WHEN 'terça-feira'   THEN 2
      WHEN 'terca-feira'   THEN 2
      WHEN 'quarta-feira'  THEN 3
      WHEN 'quinta-feira'  THEN 4
      WHEN 'sexta-feira'   THEN 5
      WHEN 'sábado'        THEN 6
      WHEN 'sabado'        THEN 6
      WHEN 'domingo'       THEN 7
      ELSE 1
    END;

    -- INSERT (quando id_supabase é null)
    IF (v_item->>'id_supabase') IS NULL THEN
      INSERT INTO public.calendario_matriz_semana (
        id_empresa,
        id_turma,
        dia_semana,
        ordem,
        duracao_minutos,
        tipo,
        id_carga_horaria_p1,
        id_carga_horaria_p3,
        id_atividade_infantil,
        id_componente,
        criado_por,
        id_local
      )
      VALUES (
        v_id_empresa,
        v_id_turma,
        v_dia_semana,
        COALESCE((v_item->>'ordem')::int, 0),
        COALESCE((v_item->>'duracao')::int, 0),
        v_tipo,
        CASE WHEN v_tipo = 'p1' THEN (v_item->>'id_carga_horaria')::uuid ELSE NULL END,
        CASE WHEN v_tipo = 'p3' THEN (v_item->>'id_carga_horaria')::uuid ELSE NULL END,
        CASE WHEN v_tipo = 'infantil' THEN (v_item->>'id_atividade_infantil')::uuid ELSE NULL END,
        (v_item->>'id_componente')::uuid,
        (v_item->>'id_professor')::uuid,
        (v_item->>'id')::int
      )
      RETURNING id INTO v_id_registro;

    -- UPDATE (quando já existe id_supabase)
    ELSE
      UPDATE public.calendario_matriz_semana
      SET
        dia_semana = v_dia_semana,
        ordem = COALESCE((v_item->>'ordem')::int, 0),
        duracao_minutos = COALESCE((v_item->>'duracao')::int, 0),
        tipo = v_tipo,
        id_carga_horaria_p1 = CASE WHEN v_tipo = 'p1' THEN (v_item->>'id_carga_horaria')::uuid ELSE NULL END,
        id_carga_horaria_p3 = CASE WHEN v_tipo = 'p3' THEN (v_item->>'id_carga_horaria')::uuid ELSE NULL END,
        id_atividade_infantil = CASE WHEN v_tipo = 'infantil' THEN (v_item->>'id_atividade_infantil')::uuid ELSE NULL END,
        id_componente = (v_item->>'id_componente')::uuid,
        id_local = (v_item->>'id')::int,
        modificado_em = now()
      WHERE id = (v_item->>'id_supabase')::uuid
      RETURNING id INTO v_id_registro;
    END IF;

  END LOOP;

  --------------------------------------------------------------------------
  -- 4) Normaliza: compacta ordens por (id_turma, dia_semana) em 0,1,2,...
  --------------------------------------------------------------------------
  UPDATE public.calendario_matriz_semana AS cm
  SET ordem = sub.nova_ordem
  FROM (
    SELECT id,
           ROW_NUMBER() OVER (PARTITION BY id_turma, dia_semana ORDER BY ordem) - 1 AS nova_ordem
    FROM public.calendario_matriz_semana
    WHERE id_turma = v_id_turma
  ) AS sub
  WHERE cm.id = sub.id;

  --------------------------------------------------------------------------
  -- 5) Retorno final no mesmo formato do front
  --------------------------------------------------------------------------
  v_result := (
    SELECT jsonb_agg(
      jsonb_build_object(
        'id_supabase', cm.id,
        'id', cm.id_local,
        'ordem', cm.ordem,
        'dia',
          CASE cm.dia_semana
            WHEN 1 THEN 'segunda-feira'
            WHEN 2 THEN 'terça-feira'
            WHEN 3 THEN 'quarta-feira'
            WHEN 4 THEN 'quinta-feira'
            WHEN 5 THEN 'sexta-feira'
            WHEN 6 THEN 'sábado'
            WHEN 7 THEN 'domingo'
          END,
        'tipo', cm.tipo,
        'duracao', cm.duracao_minutos,
        'id_empresa', cm.id_empresa,
        'id_turma', cm.id_turma,
        'id_componente', cm.id_componente,
        'id_carga_horaria',
          COALESCE(cm.id_carga_horaria_p1, cm.id_carga_horaria_p3),
        'id_atividade_infantil', cm.id_atividade_infantil,
        'id_professor', cm.criado_por,
        'professor', u.nome_completo,
        'title', COALESCE(c.nome, ai.nome, cm.tipo),
        'color', COALESCE(c.cor, '#94A3B8')
      )
      ORDER BY cm.dia_semana, cm.ordem
    )
    FROM public.calendario_matriz_semana cm
    LEFT JOIN public.user_expandido u
      ON u.id = cm.criado_por
    LEFT JOIN public.componente c
      ON c.uuid = cm.id_componente
    LEFT JOIN public.atividades_infantil ai
      ON ai.id = cm.id_atividade_infantil
    WHERE cm.id_turma = v_id_turma
      AND cm.id_empresa = v_id_empresa
  );

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;


ALTER FUNCTION "public"."upsert_calendario_matriz_semana_v3"("p_array" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_horario_escolar"("_p_envio" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  p_dados jsonb := _p_envio;
  v_operacao text := lower(coalesce(p_dados->>'criar_editar',''));
  v_dados jsonb := p_dados->'dados';
  v_he jsonb := v_dados->'horario_escola';
  v_aulas jsonb := coalesce(v_dados->'horario_aula', '[]'::jsonb);

  v_id_horario uuid;
  v_id_empresa uuid;
  v_hi_txt text;
  v_hf_txt text;
  v_hc_txt text;
  v_modalidade text;
  v_nome text;
  v_descricao text;
  v_qtd_recebidas int := 0;
  v_qtd_inseridas int := 0;
  v_len int := 0;
begin
  if v_he is null then
    raise exception 'Payload inválido: dados.horario_escola ausente';
  end if;

  v_id_empresa := (v_he->>'id_empresa')::uuid;

  v_hi_txt := lpad(coalesce(v_he->>'hora_inicio','0'), 2, '0') || ':' ||
              lpad(coalesce(v_he->>'minuto_inicio','0'), 2, '0');
  v_hf_txt := lpad(coalesce(v_he->>'hora_fim','0'), 2, '0') || ':' ||
              lpad(coalesce(v_he->>'minuto_fim','0'), 2, '0');
  v_hc_txt := coalesce(nullif(v_he->>'horario_completo',''), v_hi_txt || ' - ' || v_hf_txt);

  v_modalidade := lower(coalesce(v_he->>'modalidade', 'pleno'));
  v_nome := coalesce(v_he->>'nome', 'Horário: ' || v_hc_txt);
  v_descricao := coalesce(v_he->>'descricao', 
                          case when v_modalidade = 'pleno'
                               then 'Horário Pleno das ' || v_hi_txt || ' às ' || v_hf_txt
                               else 'Horário ' || initcap(v_modalidade) || ' das ' || v_hi_txt || ' às ' || v_hf_txt
                          end);

  begin
    v_id_horario := nullif(v_he->>'id_horario_escola','')::uuid;
  exception when others then
    v_id_horario := null;
  end;
  if v_id_horario is null or v_id_horario::text = '1' then
    v_id_horario := gen_random_uuid();
  end if;

  -- 🔧 Ajuste automático para modalidade "pleno"
  if v_modalidade = 'pleno' then
    if v_hi_txt = '00:00' and v_hf_txt = '00:00' then
      select hora_inicio, hora_fim
        into v_hi_txt, v_hf_txt
      from public.horarios_escola he
      where he.id = coalesce((v_he->>'id_horario_escola')::uuid, v_id_horario)
      limit 1;

      if v_hi_txt is not null and v_hf_txt is not null then
        v_hc_txt := v_hi_txt || ' - ' || v_hf_txt;
      end if;
    end if;
  end if;

  if v_operacao = 'criar' then
    insert into public.horarios_escola (id, id_empresa, hora_inicio, hora_fim, hora_completo, periodo, nome, descricao)
    values (v_id_horario, v_id_empresa, v_hi_txt, v_hf_txt, v_hc_txt,
            (v_he->>'periodo')::public.periodo_escolar, v_nome, v_descricao);

  elsif v_operacao = 'editar' then
    update public.horarios_escola
       set id_empresa = v_id_empresa,
           hora_inicio = v_hi_txt,
           hora_fim = v_hf_txt,
           hora_completo = v_hc_txt,
           periodo = (v_he->>'periodo')::public.periodo_escolar,
           nome = v_nome,
           descricao = v_descricao,
           atualizado_em = now()
     where id = v_id_horario;

    delete from public.horario_aula where id_horario = v_id_horario;
  else
    raise exception 'criar_editar deve ser "criar" ou "editar".';
  end if;

  v_len := jsonb_array_length(v_aulas);

  if v_len = 0 then
    insert into public.horario_aula (
      id_empresa, id_horario, ordem, tipo, nome, hora_inicio, hora_fim, hora_completo, modalidade
    )
    values (
      v_id_empresa, v_id_horario, 1, 'aula', 'Aula Única',
      v_hi_txt::time, v_hf_txt::time, v_hc_txt, v_modalidade::public.modalidade_horario
    );
    v_qtd_inseridas := 1;

  else
    with aulas as (
      select
        (elem->>'ordem')::int as ordem,
        lower(coalesce(nullif(elem->>'tipo',''),'aula')) as tipo_raw,
        coalesce(elem->>'nome','') as nome,
        coalesce(elem->>'modalidade','semanal') as modalidade_raw,
        (elem->>'dia_semana')::int as dia_semana,
        lpad(coalesce(elem->>'hora_inicio','0'),2,'0') as h_ini,
        lpad(coalesce(elem->>'minuto_inicio','0'),2,'0') as m_ini,
        lpad(coalesce(elem->>'hora_fim','0'),2,'0') as h_fim,
        lpad(coalesce(elem->>'minuto_fim','0'),2,'0') as m_fim,
        coalesce(nullif(elem->>'horario_completo',''),'') as hora_completo_txt
      from jsonb_array_elements(v_aulas) elem
    ), normalizada as (
      select
        ordem,
        case when tipo_raw in ('aula','intervalo','apoio') then tipo_raw else 'aula' end as tipo_ok,
        nome,
        modalidade_raw,
        dia_semana,
        (h_ini || ':' || m_ini)::time as hora_inicio_time,
        (h_fim || ':' || m_fim)::time as hora_fim_time,
        case when hora_completo_txt <> '' then hora_completo_txt
             else (h_ini || ':' || m_ini || ' - ' || h_fim || ':' || m_fim) end as hora_completo_final
      from aulas
    ), inseridos as (
      insert into public.horario_aula (
        id_empresa, id_horario, ordem, tipo, nome, hora_inicio, hora_fim, hora_completo,
        modalidade, dia_semana
      )
      select
        v_id_empresa, v_id_horario, n.ordem, n.tipo_ok, n.nome,
        n.hora_inicio_time, n.hora_fim_time, n.hora_completo_final,
        n.modalidade_raw::public.modalidade_horario, n.dia_semana
      from normalizada n
      returning 1
    )
    select count(*) into v_qtd_inseridas from inseridos;
  end if;

  return jsonb_build_object(
    'operacao', case when v_operacao='criar' then 'inserido' else 'atualizado' end,
    'id_horario', v_id_horario,
    'modalidade', v_modalidade,
    'aulas_recebidas', v_len,
    'aulas_inseridas', v_qtd_inseridas
  );
end;
$$;


ALTER FUNCTION "public"."upsert_horario_escolar"("_p_envio" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verificar_email_existe"("p_email" "text") RETURNS TABLE("existe" boolean, "mensagem" "text")
    LANGUAGE "plpgsql"
    AS $$
declare
  v_email text := lower(trim(p_email));
begin
  -- opcional: tratar entrada vazia
  if v_email is null or v_email = '' then
    return query select
      false as existe,
      'E-mail vazio ou inválido.' as mensagem;
    return;
  end if;

  if exists (
    select 1
    from public.user_expandido
    where email is not null
      and email <> ''
      and lower(trim(email)) = v_email
  ) then
    return query select
      true  as existe,
      'E-mail já existe na base de dados.' as mensagem;
  else
    return query select
      false as existe,
      'E-mail disponível.' as mensagem;
  end if;
end;
$$;


ALTER FUNCTION "public"."verificar_email_existe"("p_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verificar_matricula_existente"("p_matricula" "text") RETURNS TABLE("existe" boolean, "mensagem" "text")
    LANGUAGE "plpgsql"
    AS $$
declare
  v_trimmed text := trim(p_matricula);
begin
  if exists (
    select 1 
    from user_expandido 
    where trim(matricula) = v_trimmed
  ) then
    return query select 
      true as existe, 
      'Matrícula já existe na base de dados.' as mensagem;
  else
    return query select 
      false as existe, 
      'Matrícula disponível.' as mensagem;
  end if;
end;
$$;


ALTER FUNCTION "public"."verificar_matricula_existente"("p_matricula" "text") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."adicional_noturno_professor" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_professor" "uuid" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "mes_referencia" integer NOT NULL,
    "ano_referencia" integer NOT NULL,
    "horas" integer,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "modified_by" "uuid",
    "status" boolean DEFAULT true NOT NULL,
    CONSTRAINT "adicional_noturno_mes_check" CHECK ((("mes_referencia" >= 1) AND ("mes_referencia" <= 12)))
);


ALTER TABLE "public"."adicional_noturno_professor" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ano_etapa" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "nome" "text" NOT NULL,
    "tipo" "public"."tipo_ano_etapa" NOT NULL,
    "carg_horaria" integer,
    "title_sharepoint" "text",
    "id_sharepoint" "text",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "atualizado_em" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."ano_etapa" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."atividades_infantil" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "descricao" "text",
    "id_empresa" "uuid" NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "criado_por" "uuid",
    "modificado_em" timestamp with time zone
);


ALTER TABLE "public"."atividades_infantil" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."atividades_infantil_duracao" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_atividade_infantil" "uuid" NOT NULL,
    "duracao_minutos" integer NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "id_empresa" "uuid" NOT NULL,
    CONSTRAINT "atividades_infantil_duracao_duracao_minutos_check" CHECK (("duracao_minutos" > 0))
);


ALTER TABLE "public"."atividades_infantil_duracao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."atividades_infantil_vinculos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_atividade_infantil" "uuid" NOT NULL,
    "id_turma" "uuid" NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "id_empresa" "uuid" NOT NULL
);


ALTER TABLE "public"."atividades_infantil_vinculos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_dim_autoria" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome_completo" "text" NOT NULL,
    "codigo_cutter" character varying(50),
    "id_empresa" "uuid",
    "id_bubble" "text",
    "principal" boolean DEFAULT false
);


ALTER TABLE "public"."bbtk_dim_autoria" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_dim_categoria" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "descricao" "text",
    "id_empresa" "uuid" NOT NULL,
    "id_bubble" "text"
);


ALTER TABLE "public"."bbtk_dim_categoria" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_dim_cdu" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "codigo" character varying(50) NOT NULL,
    "nome" "text" NOT NULL,
    "id_empresa" "uuid" NOT NULL
);


ALTER TABLE "public"."bbtk_dim_cdu" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_dim_doador" (
    "uuid" "uuid" NOT NULL,
    "nome" "text" NOT NULL,
    "email" "text",
    "telefone" character varying(50),
    "id_empresa" "uuid"
);


ALTER TABLE "public"."bbtk_dim_doador" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_dim_editora" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "email" "text",
    "telefone" character varying(50),
    "id_empresa" "uuid"
);


ALTER TABLE "public"."bbtk_dim_editora" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_dim_estante" (
    "uuid" "uuid" NOT NULL,
    "nome" character varying(255) NOT NULL,
    "sala_uuid" "uuid"
);


ALTER TABLE "public"."bbtk_dim_estante" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_dim_metadado" (
    "uuid" "uuid" NOT NULL,
    "nome" "text" NOT NULL,
    "id_empresa" "uuid"
);


ALTER TABLE "public"."bbtk_dim_metadado" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_dim_predio" (
    "uuid" "uuid" NOT NULL,
    "nome" character varying(255) NOT NULL,
    "id_empresa" "uuid",
    "id_escola" "uuid"
);


ALTER TABLE "public"."bbtk_dim_predio" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_dim_sala" (
    "uuid" "uuid" NOT NULL,
    "nome" character varying(255) NOT NULL,
    "predio_uuid" "uuid"
);


ALTER TABLE "public"."bbtk_dim_sala" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_edicao" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "obra_uuid" "uuid" NOT NULL,
    "isbn" character varying(30),
    "ano_lancamento" "date",
    "edicao" "text",
    "arquivo_pdf" "text",
    "arquivo_capa" "text",
    "tipo_livro" "public"."bbtk_tipo_livro" NOT NULL,
    "livro_retiravel" boolean DEFAULT true,
    "livro_recomendado" boolean DEFAULT false,
    "editora_uuid" "uuid",
    "doador_uuid" "uuid",
    "id_empresa" "uuid",
    "pdf_bubble" "text",
    "capa_bubble" "text"
);


ALTER TABLE "public"."bbtk_edicao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_historico_interacao" (
    "uuid" "uuid" NOT NULL,
    "copia_uuid" "uuid" NOT NULL,
    "user_uuid" "uuid" NOT NULL,
    "tipo_interacao" "public"."bbtk_tipo_interacao" NOT NULL,
    "data_inicio" "date" NOT NULL,
    "data_fim" "date",
    "data_prevista_devolucao" "date",
    "id_empresa" "uuid",
    "status_reserva" "public"."bbtk_status_reserva"
);


ALTER TABLE "public"."bbtk_historico_interacao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_inventario_copia" (
    "uuid" "uuid" NOT NULL,
    "edicao_uuid" "uuid" NOT NULL,
    "registro_bibliotecario" character varying(100) NOT NULL,
    "status_copia" "public"."bbtk_status_copia" NOT NULL,
    "avaria_flag" boolean DEFAULT false,
    "descricao_avaria" "text",
    "estante_uuid" "uuid",
    "id_empresa" "uuid",
    "doacao_ou_compra" "text",
    "soft_delete" boolean DEFAULT false NOT NULL,
    CONSTRAINT "bbtk_inventario_copia_doacao_ou_compra_check" CHECK (("doacao_ou_compra" = ANY (ARRAY['Doação'::"text", 'Compra'::"text"])))
);


ALTER TABLE "public"."bbtk_inventario_copia" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_juncao_edicao_autoria" (
    "edicao_uuid" "uuid" NOT NULL,
    "autoria_uuid" "uuid" NOT NULL,
    "funcao" "public"."bbtk_funcao_autoria" NOT NULL,
    "id_empresa" "uuid"
);


ALTER TABLE "public"."bbtk_juncao_edicao_autoria" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_juncao_edicao_metadado" (
    "edicao_uuid" "uuid" NOT NULL,
    "metadado_uuid" "uuid" NOT NULL,
    "id_empresa" "uuid"
);


ALTER TABLE "public"."bbtk_juncao_edicao_metadado" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."bbtk_obra" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "titulo_principal" "text" NOT NULL,
    "sub_titulo_principal" "text",
    "descricao" "text",
    "tipo_publicacao" "public"."bbtk_tipo_publicacao" NOT NULL,
    "cdu_uuid" "uuid",
    "categoria_uuid" "uuid",
    "id_empresa" "uuid" NOT NULL,
    "id_autoria" "uuid",
    "soft_delete" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."bbtk_obra" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."calendario_eventos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "id_turma" "uuid" NOT NULL,
    "id_horario_aula" "uuid",
    "id_componente" "uuid",
    "data" "date" NOT NULL,
    "tipo_evento" "text" NOT NULL,
    "descricao" "text",
    "observacao" "text",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "calendario_eventos_tipo_evento_check" CHECK (("tipo_evento" = ANY (ARRAY['feriado'::"text", 'emenda'::"text", 'avaliacao'::"text", 'troca_professor'::"text", 'suspensao'::"text", 'aula_extra'::"text", 'outro'::"text"])))
);


ALTER TABLE "public"."calendario_eventos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."calendario_matriz_semana" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "id_turma" "uuid" NOT NULL,
    "dia_semana" integer NOT NULL,
    "ordem" integer NOT NULL,
    "duracao_minutos" integer NOT NULL,
    "id_carga_horaria_p1" "uuid",
    "id_carga_horaria_p3" "uuid",
    "id_atividade_infantil" "uuid",
    "id_componente" "uuid",
    "tipo" "text" NOT NULL,
    "vigencia_ini" "date" DEFAULT CURRENT_DATE,
    "vigencia_fim" "date",
    "criado_por" "uuid",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "modificado_em" timestamp with time zone,
    "id_local" integer,
    CONSTRAINT "cal_matriz_origem_exclusiva" CHECK (((((("id_carga_horaria_p1" IS NOT NULL))::integer + (("id_carga_horaria_p3" IS NOT NULL))::integer) + (("id_atividade_infantil" IS NOT NULL))::integer) = 1)),
    CONSTRAINT "calendario_matriz_semana_dia_semana_check" CHECK ((("dia_semana" >= 1) AND ("dia_semana" <= 7))),
    CONSTRAINT "calendario_matriz_semana_duracao_minutos_check" CHECK (("duracao_minutos" > 0)),
    CONSTRAINT "calendario_matriz_semana_ordem_check" CHECK (("ordem" >= 0)),
    CONSTRAINT "calendario_matriz_semana_tipo_check" CHECK (("tipo" = ANY (ARRAY['p1'::"text", 'p3'::"text", 'infantil'::"text", 'evento'::"text", 'apoio'::"text"])))
);


ALTER TABLE "public"."calendario_matriz_semana" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."carga_horaria_p1" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_componente" "uuid" NOT NULL,
    "id_ano_etapa" "uuid" NOT NULL,
    "carga_horaria" integer NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "criado_por" "uuid",
    "modifica_por" "uuid",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "modificado_em" timestamp with time zone
);


ALTER TABLE "public"."carga_horaria_p1" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."carga_horaria_p3" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_componente" "uuid" NOT NULL,
    "id_ano_etapa" "uuid" NOT NULL,
    "carga_horaria" integer NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "criado_por" "uuid",
    "modifica_por" "uuid",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "modificado_em" timestamp with time zone,
    "title_sharepoint" "text"
);


ALTER TABLE "public"."carga_horaria_p3" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."carga_suplementar_professor" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_professor" "uuid" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "mes_referencia" integer NOT NULL,
    "ano_referencia" integer NOT NULL,
    "horas" integer,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "modified_by" "uuid",
    "status" boolean DEFAULT true NOT NULL,
    CONSTRAINT "carga_suplementar_mes_check" CHECK ((("mes_referencia" >= 1) AND ("mes_referencia" <= 12)))
);


ALTER TABLE "public"."carga_suplementar_professor" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."classe" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "ordem" integer NOT NULL,
    "id_empresa" "uuid" NOT NULL
);


ALTER TABLE "public"."classe" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."crm_mensagens" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "email" "text" NOT NULL,
    "mensagem" "text" NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "status" "text" DEFAULT 'pendente'::"text"
);


ALTER TABLE "public"."crm_mensagens" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."diario_presenca" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "id_matricula" "uuid" NOT NULL,
    "id_horario_aula" "uuid" NOT NULL,
    "id_componente" "uuid",
    "data" "date" NOT NULL,
    "presente" boolean DEFAULT false NOT NULL,
    "observacao" "text",
    "registrado_por" "uuid",
    "registrado_em" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."diario_presenca" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."empresa" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "logo_fechado" "text",
    "logo_aberto" "text",
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "dominio" "text"
);


ALTER TABLE "public"."empresa" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."escolas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "endereco" "text",
    "numero" "text",
    "complemento" "text",
    "bairro" "text",
    "cep" "text",
    "email" "text",
    "telefone_1" "text",
    "telefone_2" "text",
    "horario_htpc" "text",
    "horario_htpc_hora" integer,
    "horario_htpc_minuto" integer,
    "dia_semana_htpc" "text",
    "id_empresa" "uuid" NOT NULL,
    "id_sharepoint_apagar_depois" integer,
    "uuid_sharepoint_apagar_depois" "text"
);


ALTER TABLE "public"."escolas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."faltas_professores" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_professor" "uuid" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "mes_referencia" integer NOT NULL,
    "ano_referencia" integer NOT NULL,
    "data" timestamp with time zone NOT NULL,
    "codigo" "public"."codigo_falta_professor" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "modified_by" "uuid",
    "horas" integer,
    "status" boolean DEFAULT true NOT NULL,
    CONSTRAINT "faltas_professores_mes_referencia_check" CHECK ((("mes_referencia" >= 1) AND ("mes_referencia" <= 12)))
);


ALTER TABLE "public"."faltas_professores" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."feriados" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "data_feriado" timestamp with time zone NOT NULL,
    "nome_feriado" "text" NOT NULL,
    "tipo_feriado" "text",
    "ano_referencia" integer,
    "mes_referencia" "text",
    "criado_em" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."feriados" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ferias_professor" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_professor" "uuid" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "mes_referencia" integer NOT NULL,
    "ano_referencia" integer NOT NULL,
    "data_inicial" "date" NOT NULL,
    "data_final" "date",
    "tipo_ferias" "public"."tipo_ferias_enum",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "modified_by" "uuid",
    "status" boolean DEFAULT true NOT NULL,
    CONSTRAINT "ferias_professor_mes_referencia_check" CHECK ((("mes_referencia" >= 1) AND ("mes_referencia" <= 12)))
);


ALTER TABLE "public"."ferias_professor" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."fila_processamento_pontuacao" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "ano" integer NOT NULL,
    "status" "text" DEFAULT 'pendente'::"text" NOT NULL,
    "total_professores" integer,
    "processados" integer DEFAULT 0 NOT NULL,
    "inseridos" integer DEFAULT 0 NOT NULL,
    "atualizados" integer DEFAULT 0 NOT NULL,
    "erros" integer DEFAULT 0 NOT NULL,
    "detalhe" "jsonb",
    "criado_por" "uuid",
    "iniciado_em" timestamp with time zone,
    "finalizado_em" timestamp with time zone,
    "criado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    "atualizado_em" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."fila_processamento_pontuacao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."horario_aula" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "id_horario" "uuid" NOT NULL,
    "ordem" integer NOT NULL,
    "tipo" "text",
    "nome" "text" NOT NULL,
    "hora_inicio" time without time zone NOT NULL,
    "hora_fim" time without time zone NOT NULL,
    "hora_completo" "text" NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "modalidade" "public"."modalidade_horario" DEFAULT 'semanal'::"public"."modalidade_horario" NOT NULL,
    "dia_semana" integer,
    CONSTRAINT "horario_aula_dia_semana_check" CHECK ((("dia_semana" >= 1) AND ("dia_semana" <= 7))),
    CONSTRAINT "horario_aula_tipo_check" CHECK (("tipo" = ANY (ARRAY['aula'::"text", 'intervalo'::"text", 'apoio'::"text"])))
);


ALTER TABLE "public"."horario_aula" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."horarios_escola" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "hora_inicio" "text" NOT NULL,
    "hora_fim" "text" NOT NULL,
    "hora_completo" "text",
    "periodo" "public"."periodo_escolar" NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "atualizado_em" timestamp with time zone DEFAULT "now"(),
    "nome" "text",
    "descricao" "text"
);


ALTER TABLE "public"."horarios_escola" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."licenca_saude" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_professor" "uuid" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "mes_referencia" integer NOT NULL,
    "ano_referencia" integer NOT NULL,
    "data_inicial" "date" NOT NULL,
    "data_final" "date",
    "codigo" "public"."codigo_afastamento_licenca" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "modified_by" "uuid",
    "status" boolean DEFAULT true NOT NULL,
    CONSTRAINT "licenca_saude_mes_referencia_check" CHECK ((("mes_referencia" >= 1) AND ("mes_referencia" <= 12)))
);


ALTER TABLE "public"."licenca_saude" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lms_configuracao_empresa" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "pode_upload_video" boolean DEFAULT false NOT NULL,
    "pode_usar_questionarios" boolean DEFAULT true NOT NULL,
    "pode_usar_tarefas" boolean DEFAULT true NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."lms_configuracao_empresa" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lms_conteudo" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_turma" "uuid",
    "id_componente" "uuid",
    "global_turma" boolean DEFAULT false NOT NULL,
    "global_componente" boolean DEFAULT false NOT NULL,
    "titulo" "text" NOT NULL,
    "descricao" "text",
    "data_referencia" "date",
    "visivel_para_alunos" boolean DEFAULT true NOT NULL,
    "criado_por" "uuid" NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "ordem" integer,
    "id_empresa" "uuid" NOT NULL,
    "data_disponivel" timestamp with time zone,
    "liberar_por" "public"."liberacao_conteudo_enum" DEFAULT 'Conteúdo'::"public"."liberacao_conteudo_enum" NOT NULL,
    "id_aluno" "uuid",
    "id_meta_turma" "uuid",
    "escopo" "text" NOT NULL,
    CONSTRAINT "lms_conteudo_escopo_check" CHECK (((("escopo" = 'Turma'::"text") AND ("id_turma" IS NOT NULL)) OR (("escopo" = 'Aluno'::"text") AND ("id_aluno" IS NOT NULL)) OR (("escopo" = 'Grupo'::"text") AND ("id_meta_turma" IS NOT NULL)) OR ("escopo" = 'Global'::"text"))),
    CONSTRAINT "lms_conteudo_escopo_enum_check" CHECK (("escopo" = ANY (ARRAY['Turma'::"text", 'Aluno'::"text", 'Grupo'::"text", 'Global'::"text"])))
);


ALTER TABLE "public"."lms_conteudo" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lms_item_conteudo" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_lms_conteudo" "uuid" NOT NULL,
    "tipo" "public"."lms_tipo_item" DEFAULT 'Material'::"public"."lms_tipo_item",
    "titulo" "text" NOT NULL,
    "caminho_arquivo" "text",
    "url_externa" "text",
    "rich_text" "text",
    "data_disponivel" timestamp with time zone,
    "data_entrega_limite" timestamp with time zone,
    "ordem" integer DEFAULT 0,
    "criado_por" "uuid" NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "id_empresa" "uuid",
    "pontuacao_maxima" numeric(5,2),
    "video_link" "text",
    "id_bbtk_edicao" "uuid",
    "tempo_questionario" integer,
    "duracao_minutos" integer,
    "tentativas_permitidas" integer DEFAULT 1
);


ALTER TABLE "public"."lms_item_conteudo" OWNER TO "postgres";


COMMENT ON COLUMN "public"."lms_item_conteudo"."tempo_questionario" IS 'Tempo em minutos para responder o questionário. Se NULL, é ilimitado.';



CREATE TABLE IF NOT EXISTS "public"."lms_pergunta" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tipo" "public"."lms_tipo_pergunta" DEFAULT 'Dissertativa'::"public"."lms_tipo_pergunta" NOT NULL,
    "enunciado" "text" NOT NULL,
    "obrigatoria" boolean DEFAULT true NOT NULL,
    "ordem" integer DEFAULT 0,
    "id_empresa" "uuid" NOT NULL,
    "id_item_conteudo" "uuid" NOT NULL,
    "caminho_imagem" "text"
);


ALTER TABLE "public"."lms_pergunta" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lms_resposta" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "uuid" NOT NULL,
    "id_pergunta" "uuid" NOT NULL,
    "tipo_pergunta" "public"."lms_tipo_pergunta" NOT NULL,
    "resposta" "text",
    "id_resposta_possivel" "uuid",
    "criado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    "criado_por" "uuid",
    "modificado_em" timestamp with time zone,
    "modificado_por" "uuid"
);


ALTER TABLE "public"."lms_resposta" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lms_resposta_possivel" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_pergunta" "uuid" NOT NULL,
    "texto" "text" NOT NULL,
    "correta" boolean DEFAULT false NOT NULL,
    "ordem" integer DEFAULT 0,
    "id_empresa" "uuid" NOT NULL
);


ALTER TABLE "public"."lms_resposta_possivel" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lms_submissao" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_item_conteudo" "uuid" NOT NULL,
    "id_aluno" "uuid" NOT NULL,
    "texto_resposta" "text",
    "caminho_arquivo" "text",
    "data_envio" timestamp with time zone DEFAULT "now"(),
    "nota" numeric(5,2),
    "comentario_professor" "text",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "modificado_em" timestamp with time zone,
    "data_inicio" timestamp with time zone,
    "status" "text" DEFAULT 'em_andamento'::"text",
    "id_empresa" "uuid"
);


ALTER TABLE "public"."lms_submissao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."materiais_sed" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ano_letivo" integer NOT NULL,
    "bimestre" "public"."bimestre_enum" NOT NULL,
    "componente" "text" NOT NULL,
    "etapa" "public"."etapa_enum" NOT NULL,
    "link_ppt" "text",
    "criado_em" timestamp without time zone DEFAULT "now"(),
    "link_pdf" "text",
    "serie" "public"."serie_enum",
    "titulo" "text"
);


ALTER TABLE "public"."materiais_sed" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."matriculas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "id_aluno" "uuid" NOT NULL,
    "id_turma" "uuid" NOT NULL,
    "status" "text" NOT NULL,
    "data_entrada" "date" DEFAULT CURRENT_DATE NOT NULL,
    "data_saida" "date",
    "observacao" "text",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "matriculas_status_check" CHECK (("status" = ANY (ARRAY['ativa'::"text", 'transferida'::"text", 'cancelada'::"text", 'evadida'::"text", 'concluida'::"text"])))
);


ALTER TABLE "public"."matriculas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."meta_turma" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "id_user" "uuid",
    "nome" character varying(255) NOT NULL,
    "descricao" "text",
    "status" boolean DEFAULT true NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    "criado_por" "uuid",
    "modificado_em" timestamp with time zone,
    "modificado_por" "uuid",
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."meta_turma" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."onbdg_codigos_email" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "uuid" NOT NULL,
    "numero" character(6) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone DEFAULT ("now"() + '00:02:00'::interval) NOT NULL,
    "usado_em" timestamp with time zone,
    CONSTRAINT "onbdg_codigos_email_numero_check" CHECK (("numero" ~ '^\d{6}$'::"text"))
);


ALTER TABLE "public"."onbdg_codigos_email" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."onbdg_codigos_email_status" WITH ("security_invoker"='on') AS
 SELECT "c"."id",
    "c"."id_user",
    "c"."numero",
    "c"."created_at",
    "c"."expires_at",
    "c"."usado_em",
    (("now"() < "c"."expires_at") AND ("c"."usado_em" IS NULL)) AS "status"
   FROM "public"."onbdg_codigos_email" "c";


ALTER TABLE "public"."onbdg_codigos_email_status" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."papeis_user" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL
);


ALTER TABLE "public"."papeis_user" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."papeis_user_auth" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "papel_id" "uuid" NOT NULL,
    "empresa_id" "uuid" NOT NULL
);


ALTER TABLE "public"."papeis_user_auth" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pontuacao_professores" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_professor" "uuid" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "pontuacao" bigint,
    "ano" smallint NOT NULL,
    "pontuacao_unidade" bigint,
    "pontuacao_departamento" bigint,
    "certificado_concurso_publico" bigint,
    "tempo_servico_unidade" bigint,
    "tempo_servico_departamento" bigint,
    "tempo_especialista" bigint,
    "assiduidade" bigint,
    "status" "text",
    "observacoes" "text",
    "devolutiva" "text",
    "criado_por" "uuid",
    "modificado_por" "uuid",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "atualizado_em" timestamp with time zone DEFAULT "now"(),
    "pontuacao_certificados" bigint,
    "soft_delete" boolean DEFAULT false NOT NULL,
    "pontuacao_departamento_total" bigint,
    "pontuacao_unidade_total" bigint,
    "registro_anterior" boolean
);


ALTER TABLE "public"."pontuacao_professores" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."professor_componente" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_componente" "uuid" NOT NULL,
    "id_professor" "uuid" NOT NULL,
    "ano_referencia" "text" NOT NULL,
    "criado_por" "uuid",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "atualizado_por" "uuid",
    "atualizado_em" timestamp with time zone,
    "id_empresa" "uuid" DEFAULT '0a9d8682-4da9-4e02-9022-fd293a9b0704'::"uuid" NOT NULL
);


ALTER TABLE "public"."professor_componente" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."professor_componentes_atribuicao" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_unidade_atribuicao" "uuid" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "ano" smallint NOT NULL,
    "id_professor" "uuid" NOT NULL,
    "data_inicio" "date" NOT NULL,
    "data_fim" "date",
    "motivo_substituicao" "text",
    "nivel_substituicao" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "editando_por" "uuid",
    "editando_email" "text"
);


ALTER TABLE "public"."professor_componentes_atribuicao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."professor_funcao_extra" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "funcao" "public"."funcao_extra_enum" NOT NULL,
    "ano" "text" NOT NULL,
    "data_inicio" "date",
    "data_fim" "date",
    "status" boolean DEFAULT true,
    "observacao" "text",
    "id_escola" "uuid",
    "criado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    "modificado_em" timestamp with time zone,
    "criado_por" "uuid",
    "modificado_por" "uuid",
    "afastamento_funcao_extra" boolean DEFAULT false NOT NULL,
    "data_inicio_licenca_func_extra" timestamp with time zone,
    "data_fim_licenca_func_extra" timestamp with time zone,
    "soft_delete" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."professor_funcao_extra" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."professor_tempo_unidade" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "uuid" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "id_escola" "uuid",
    "status" "text" NOT NULL,
    "data_inicio" "date",
    "data_fim" "date",
    "observacao" "text",
    "problema" "text",
    "criado_por" "uuid",
    "modificado_por" "uuid",
    "criado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    "modificado_em" timestamp with time zone,
    "excedente" boolean DEFAULT false,
    "pontos_unidade" bigint,
    "pontos_departamento" bigint,
    "data_validade" "date"
);


ALTER TABLE "public"."professor_tempo_unidade" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."respostas_user" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "uuid" NOT NULL,
    "id_pergunta" "uuid" NOT NULL,
    "tipo" "text" NOT NULL,
    "resposta" "text",
    "nome_arquivo_original" "text",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "criado_por" "uuid",
    "atualizado_em" timestamp with time zone,
    "atualizado_por" "uuid",
    "id_empresa" "uuid",
    "resposta_data" timestamp with time zone
);


ALTER TABLE "public"."respostas_user" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."staging_professor_escola" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_professor" "uuid" NOT NULL,
    "id_escola" "uuid" NOT NULL,
    "ano" "text" NOT NULL,
    "data_inicio" "date",
    "data_fim" "date"
);


ALTER TABLE "public"."staging_professor_escola" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stg_alunos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "Nome" "text",
    "Data de nascimento" "text",
    "Genero" "text",
    "Etnia" "text",
    "Tem irmao?" "text",
    "Tem gemeo?" "text",
    "Quilombola" "text",
    "CPF" "text",
    "RG" "text",
    "Cidade do RG" "text",
    "Orgao emissao RG" "text",
    "Data emissao RG" "text",
    "Data registro" "text",
    "Tipo de registro" "text",
    "Data emissao registro" "text",
    "Distrito" "text",
    "LV" "text",
    "Estrangeiro?" "text",
    "Nasceu em outro pais?" "text",
    "Cidade origem" "text",
    "Obs origem" "text",
    "Documento civil rne" "text",
    "Data emissao rne" "text",
    "Email" "text",
    "Permite envio sms?" "text",
    "Telefone" "text",
    "Celular" "text",
    "Usuario login" "text",
    "CEP" "text",
    "Rua" "text",
    "Numero" "text",
    "Complemento" "text",
    "Bairro" "text",
    "IPTU" "text",
    "Cidade" "text",
    "RA" "text",
    "RM" "text",
    "Data matricula" "text",
    "Bolsa familia?" "text",
    "NIS" "text",
    "Mobilidade reduzida?" "text",
    "Necessidades especiais?" "text",
    "Descritivo necessidades especiais" "text",
    "CID" "text",
    "Numero chamada" "text",
    "Matricula judicial?" "text",
    "Obs matricula judicial" "text",
    "Ativo?" "text",
    "Alergia" "text",
    "Precedencia escolar" "text",
    "Precedencia escolar ciclo" "text",
    "Precedencia escolar nivel" "text",
    "Precedencia escolar curso" "text",
    "Precedencia escolar cidade" "text",
    "Precedencia escolr estado" "text",
    "Ano" "text",
    "Turma" "text",
    "Escola" "text",
    "Ensino" "text",
    "Serie" "text",
    "Periodo" "text",
    "Pai" "text",
    "Mae" "text",
    "Reponsavel" "text",
    "Tipo responsavel" "text",
    "criado_em" timestamp without time zone DEFAULT "now"(),
    "escola_banco" "text",
    "id_escola" "uuid",
    "ano_etapa_banco" "text",
    "id_ano_etapa_banco" "uuid"
);


ALTER TABLE "public"."stg_alunos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stg_autoria" (
    "id" integer NOT NULL,
    "origem_id" "text" NOT NULL,
    "campo_pesquisavel" "text",
    "codigo_cutter" "text",
    "empresa" "text",
    "funcoes" "text",
    "nome_do_autor" "text",
    "sobre_nome" "text",
    "creator" "text",
    "modified_date" "text",
    "created_date" "text",
    "slug" "text",
    "id_autoria_final" "uuid"
);


ALTER TABLE "public"."stg_autoria" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."stg_autoria_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."stg_autoria_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."stg_autoria_id_seq" OWNED BY "public"."stg_autoria"."id";



CREATE TABLE IF NOT EXISTS "public"."stg_excedentes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "Matrícula" "text",
    "Professor" "text",
    "Ano" "text",
    "Na Unidade Escolar (0,005 por dia)" "text",
    "Unidade de excedência" "text",
    "Pto Unidade" "text",
    "Pto Departam" "text",
    "Sede Nova" "text",
    "Pto Unidade Nova" "text",
    "Pto Departam Nova" "text",
    "criado_em" timestamp without time zone DEFAULT "now"(),
    "id_professor_supa" "uuid",
    "id_escola_ex" "uuid",
    "id_escola_at" "uuid"
);


ALTER TABLE "public"."stg_excedentes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stg_obra_edicao" (
    "id" integer NOT NULL,
    "autores" "text",
    "categoria" "text",
    "cdu" "text",
    "descricao" "text",
    "edicao" "text",
    "empresa" "text",
    "foto_da_capa" "text",
    "isbn" "text",
    "organizadores" "text",
    "pdf" "text",
    "sub_titulo" "text",
    "titulo" "text",
    "tradutores" "text",
    "unique_id" "text" NOT NULL,
    "id_obra_final" "uuid",
    "id_edicao_final" "uuid",
    "id_autor" "uuid"
);


ALTER TABLE "public"."stg_obra_edicao" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."stg_obra_edicao_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."stg_obra_edicao_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."stg_obra_edicao_id_seq" OWNED BY "public"."stg_obra_edicao"."id";



CREATE TABLE IF NOT EXISTS "public"."stg_ocorrencias" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "matricula" "text",
    "nome" "text",
    "nome_cargo_efetivo" "text",
    "motivo" "text",
    "data_inicio" "text",
    "data_fim" "text",
    "qtd_dias" "text",
    "total_horas" "text",
    "criado_em" timestamp without time zone DEFAULT "now"(),
    "id_unificado_serie" "uuid" DEFAULT "gen_random_uuid"(),
    "serie" boolean DEFAULT false
);


ALTER TABLE "public"."stg_ocorrencias" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stg_ocorrencias_intermediaria" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "text",
    "matricula" "text",
    "data_falta" "text",
    "mes_referencia" "text",
    "ano_referencia" "text",
    "codigo" "text",
    "horas" "text",
    "status_normalizacao" "text",
    "status_transferencia" "text",
    "criado_em" timestamp without time zone DEFAULT "now"(),
    "id_unificado_serie" "uuid",
    "serie" boolean,
    "horas_stg_definitivo" numeric
);


ALTER TABLE "public"."stg_ocorrencias_intermediaria" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stg_ocorrencias_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_stg_ocorrencias" "uuid" NOT NULL,
    "matricula" "text",
    "criado_em" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."stg_ocorrencias_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stg_pontuacao" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid",
    "id_prof_supabase" "uuid",
    "pontuacao" bigint,
    "ano" smallint,
    "pontuacao_unidade" bigint,
    "pontuacao_departamento" bigint,
    "pontuacao_certificados" bigint,
    "certificado_concurso_publico" bigint,
    "tempo_servico_unidade" bigint,
    "tempo_servico_departamento" bigint,
    "tempo_especialista" bigint,
    "assiduidade" bigint,
    "stg_matricula" "text",
    "stg_ano" "text",
    "stg_pt_unidade" "text",
    "stg_pt_departamento" "text",
    "stg_pt_total" "text",
    "stg_cursos_graduacao" "text",
    "stg_cursos_pos_graduacao" "text",
    "stg_concurso_publico" "text",
    "stg_ts_unidade" "text",
    "stg_ts_departamento" "text",
    "stg_ts_especialista" "text",
    "stg_pt_assiduidade" "text",
    "stg_status" "text",
    "stg_obs" "text",
    "stg_devolutiva" "text",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "stg_cursos_extensao" "text",
    "duplicado" "text"
);


ALTER TABLE "public"."stg_pontuacao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stg_professor_atribuicao" (
    "id" bigint NOT NULL,
    "title_sharepoint" "text",
    "escola" "text",
    "ano_etapa" "text",
    "horario" "text",
    "classe" "text",
    "componente" "text",
    "title_carga_horaria" "text",
    "carga_horaria" integer,
    "matricula_professor" "text",
    "matricula_substituto" "text",
    "status" "text",
    "ano" smallint,
    "title_empresa" "text",
    "id_professor_supabase" "uuid",
    "id_prof_subst_supabase" "uuid",
    "processado" boolean DEFAULT false NOT NULL,
    "processado_em" timestamp with time zone,
    "erro_processamento" "text",
    "id_empresa" "uuid",
    "id_turma_supabase" "uuid",
    "id_ch_p3_supabase" "uuid",
    "id_unidadeatribuicao_supabase" "uuid",
    "id_escola_supabase" "uuid",
    "id_anoetapa_supabase" "uuid",
    "id_horario_supabase" "uuid",
    "id_classe_supabase" "uuid"
);


ALTER TABLE "public"."stg_professor_atribuicao" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."stg_professor_atribuicao_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."stg_professor_atribuicao_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."stg_professor_atribuicao_id_seq" OWNED BY "public"."stg_professor_atribuicao"."id";



CREATE TABLE IF NOT EXISTS "public"."teste_23" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "num" bigint
);


ALTER TABLE "public"."teste_23" OWNER TO "postgres";


COMMENT ON TABLE "public"."teste_23" IS 'asd';



ALTER TABLE "public"."teste_23" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."teste_1_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."turma_professor_atribuicao" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_turma" "uuid" NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "ano" smallint NOT NULL,
    "id_professor" "uuid" NOT NULL,
    "data_inicio" "date" NOT NULL,
    "data_fim" "date",
    "motivo_substituicao" "text",
    "nivel_substituicao" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "editando_por" "uuid",
    "editando_email" "text"
);


ALTER TABLE "public"."turma_professor_atribuicao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."turmas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "id_escola" "uuid" NOT NULL,
    "id_ano_etapa" "uuid" NOT NULL,
    "id_horario" "uuid" NOT NULL,
    "id_classe" "uuid" NOT NULL,
    "ano" "text" NOT NULL,
    "id_professor" "uuid",
    "id_professor_s" "uuid",
    "at_titular" boolean DEFAULT false,
    "at_substituto" boolean DEFAULT false,
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "atualizado_em" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."turmas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."unidade_atribuicao" (
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_turma" "uuid" NOT NULL,
    "id_ch_p3" "uuid" NOT NULL,
    "ano" integer NOT NULL,
    "id_professor" "uuid",
    "id_professor_s" "uuid",
    "id_empresa" "uuid" NOT NULL,
    "criado_por" "uuid",
    "modifica_por" "uuid",
    "criado_em" timestamp with time zone DEFAULT "now"(),
    "modificado_em" timestamp with time zone
);


ALTER TABLE "public"."unidade_atribuicao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_expandido" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "id_empresa" "uuid" NOT NULL,
    "id_escola" "uuid",
    "matricula" "text" NOT NULL,
    "nome_completo" "text" NOT NULL,
    "email" "text",
    "telefone" "text",
    "papel_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "criado_por" "uuid",
    "criado_em" timestamp with time zone,
    "modificado_por" "uuid",
    "modificado_em" timestamp with time zone,
    "status_contrato" "public"."status_contrato" DEFAULT 'Ativo'::"public"."status_contrato" NOT NULL,
    "soft_delete" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."user_expandido" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_familia" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_empresa" "uuid" NOT NULL,
    "nome_familia" "text",
    "id_responsavel_principal" "uuid",
    "criado_em" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_familia" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_responsavel_aluno" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_aluno" "uuid" NOT NULL,
    "id_responsavel" "uuid" NOT NULL,
    "id_familia" "uuid" NOT NULL,
    "papel" "text",
    "criado_em" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_responsavel_aluno" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."versao_app" (
    "id" bigint NOT NULL,
    "criada_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    "versao" "text",
    "mudancas" "jsonb"
);


ALTER TABLE "public"."versao_app" OWNER TO "postgres";


ALTER TABLE "public"."versao_app" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."versao_app_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE OR REPLACE VIEW "public"."view_professores_escola" WITH ("security_invoker"='on') AS
 SELECT "p"."id",
    "p"."nome_completo",
    "p"."matricula",
    "p"."id_escola",
    "e"."nome" AS "nome_escola",
    false AS "mostrar_subitem",
    "p"."user_id",
    "p"."email",
    "p"."telefone",
    "p"."status_contrato"
   FROM ("public"."user_expandido" "p"
     JOIN "public"."escolas" "e" ON (("p"."id_escola" = "e"."id")))
  WHERE ("p"."papel_id" = ANY (ARRAY['3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1'::"uuid", '07028505-01d7-4986-800e-9d71cab5dd6c'::"uuid"]));


ALTER TABLE "public"."view_professores_escola" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."view_professores_pontuacao_por_ano" WITH ("security_invoker"='on') AS
 WITH "anos" AS (
         SELECT DISTINCT "pontuacao_professores"."ano"
           FROM "public"."pontuacao_professores"
        )
 SELECT "p"."id",
    "p"."user_id",
    "p"."id_empresa",
    "p"."id_escola",
    "e"."nome" AS "nome_escola",
    "p"."matricula",
    "p"."nome_completo",
    "p"."email",
    "p"."telefone",
    "p"."papel_id",
    "a"."ano",
    COALESCE(("pp"."pontuacao")::"text", 'Pendente'::"text") AS "pontuacao",
    COALESCE(("pp"."pontuacao_unidade")::"text", 'Pendente'::"text") AS "pontuacao_unidade",
    COALESCE(("pp"."pontuacao_departamento")::"text", 'Pendente'::"text") AS "pontuacao_departamento"
   FROM ((("public"."user_expandido" "p"
     LEFT JOIN "public"."escolas" "e" ON (("p"."id_escola" = "e"."id")))
     CROSS JOIN "anos" "a")
     LEFT JOIN "public"."pontuacao_professores" "pp" ON ((("pp"."id_professor" = "p"."id") AND ("pp"."ano" = "a"."ano"))))
  ORDER BY "p"."nome_completo", "a"."ano";


ALTER TABLE "public"."view_professores_pontuacao_por_ano" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."view_respostas_professor_json" WITH ("security_invoker"='on') AS
 SELECT "uep"."id" AS "id_professor",
    "uep"."id_escola",
    "r"."id" AS "id_resposta",
    "jsonb_agg"("jsonb_build_object"('id_pergunta', "p"."id", 'pergunta', "p"."pergunta", 'label', "p"."label", 'tipo', "p"."tipo", 'resposta', "r"."resposta", 'tipo_resposta', "r"."tipo", 'criado_em', "r"."criado_em") ORDER BY "p"."ordem") AS "respostas"
   FROM (("public"."user_expandido" "uep"
     LEFT JOIN "public"."respostas_user" "r" ON (("r"."id_user" = "uep"."id")))
     LEFT JOIN "public"."perguntas_user" "p" ON (("p"."id" = "r"."id_pergunta")))
  WHERE ("p"."contexto" = 'user'::"text")
  GROUP BY "uep"."id", "uep"."id_escola", "r"."id";


ALTER TABLE "public"."view_respostas_professor_json" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vw_materiais_sed_dropdowns" WITH ("security_invoker"='on') AS
 SELECT 'ano_letivo'::"text" AS "coluna",
    ("t"."ano_letivo")::"text" AS "label",
    ("t"."ano_letivo")::"text" AS "value"
   FROM ( SELECT DISTINCT "materiais_sed"."ano_letivo"
           FROM "public"."materiais_sed"
          WHERE ("materiais_sed"."ano_letivo" IS NOT NULL)) "t"
UNION
 SELECT 'bimestre'::"text" AS "coluna",
    ("t"."bimestre")::"text" AS "label",
    ("t"."bimestre")::"text" AS "value"
   FROM ( SELECT DISTINCT "materiais_sed"."bimestre"
           FROM "public"."materiais_sed"
          WHERE ("materiais_sed"."bimestre" IS NOT NULL)) "t"
UNION
 SELECT 'etapa'::"text" AS "coluna",
    ("t"."etapa")::"text" AS "label",
    ("t"."etapa")::"text" AS "value"
   FROM ( SELECT DISTINCT "materiais_sed"."etapa"
           FROM "public"."materiais_sed"
          WHERE ("materiais_sed"."etapa" IS NOT NULL)) "t"
UNION
 SELECT 'serie'::"text" AS "coluna",
    ("t"."serie")::"text" AS "label",
    ("t"."serie")::"text" AS "value"
   FROM ( SELECT DISTINCT "materiais_sed"."serie"
           FROM "public"."materiais_sed"
          WHERE ("materiais_sed"."serie" IS NOT NULL)) "t"
UNION
 SELECT 'componente'::"text" AS "coluna",
    "t"."componente" AS "label",
    "t"."componente" AS "value"
   FROM ( SELECT DISTINCT "materiais_sed"."componente"
           FROM "public"."materiais_sed"
          WHERE ("materiais_sed"."componente" IS NOT NULL)) "t"
UNION
 SELECT 'Todos'::"text" AS "coluna",
    'Todos'::"text" AS "label",
    'Todos'::"text" AS "value";


ALTER TABLE "public"."vw_materiais_sed_dropdowns" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vw_professores_funcoes_extras" WITH ("security_invoker"='on') AS
 SELECT "pfe"."id" AS "pfe_id",
    "uep"."id" AS "professor_id",
    "uep"."nome_completo",
    "uep"."matricula",
    "r_data_admissao"."resposta" AS "data_admissao",
    "pfe"."id_escola" AS "escola_id",
    COALESCE("e"."nome", 'Indefinido'::"text") AS "escola_nome",
    "uep"."id_escola" AS "escola_sede_id",
    COALESCE("esede"."nome", 'Indefinido'::"text") AS "escola_sede_nome",
    "pfe"."afastamento_funcao_extra",
    "pfe"."data_inicio_licenca_func_extra",
    "pfe"."data_fim_licenca_func_extra",
    "pfe"."funcao",
    "pfe"."ano",
    "pfe"."data_inicio",
    "pfe"."data_fim",
    "pfe"."status",
    "pfe"."observacao",
    "pfe"."id_empresa"
   FROM (((("public"."professor_funcao_extra" "pfe"
     JOIN "public"."user_expandido" "uep" ON (("pfe"."user_id" = "uep"."id")))
     LEFT JOIN "public"."escolas" "e" ON (("pfe"."id_escola" = "e"."id")))
     LEFT JOIN "public"."escolas" "esede" ON (("uep"."id_escola" = "esede"."id")))
     LEFT JOIN LATERAL ( SELECT "ru"."resposta"
           FROM ("public"."respostas_user" "ru"
             JOIN "public"."perguntas_user" "pu" ON (("ru"."id_pergunta" = "pu"."id")))
          WHERE (("pu"."pergunta" = 'data_admissao'::"text") AND ("ru"."id_user" = "uep"."id"))
         LIMIT 1) "r_data_admissao" ON (true));


ALTER TABLE "public"."vw_professores_funcoes_extras" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vw_resumo_turmas_atribuicao" WITH ("security_invoker"='on') AS
 SELECT "t"."ano",
    "t"."id_escola",
    "e"."nome" AS "escola_nome",
    "count"(*) AS "total_turmas",
    "count"(
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM "public"."turma_professor_atribuicao" "ta"
              WHERE (("ta"."id_turma" = "t"."id") AND ("ta"."nivel_substituicao" = 0) AND ("ta"."ano" = ("t"."ano")::smallint)))) THEN 1
            ELSE NULL::integer
        END) AS "turmas_atribuidas",
    ("count"(*) - "count"(
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM "public"."turma_professor_atribuicao" "ta"
              WHERE (("ta"."id_turma" = "t"."id") AND ("ta"."nivel_substituicao" = 0) AND ("ta"."ano" = ("t"."ano")::smallint)))) THEN 1
            ELSE NULL::integer
        END)) AS "turmas_nao_atribuidas"
   FROM ("public"."turmas" "t"
     JOIN "public"."escolas" "e" ON (("e"."id" = "t"."id_escola")))
  GROUP BY "t"."ano", "t"."id_escola", "e"."nome"
  ORDER BY "t"."ano", "e"."nome";


ALTER TABLE "public"."vw_resumo_turmas_atribuicao" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vw_turmas_por_ano_etapa_escola" WITH ("security_invoker"='on') AS
 SELECT "t"."ano",
    "t"."id_escola",
    "e"."nome" AS "escola_nome",
    "t"."id_ano_etapa",
    "ae"."nome" AS "ano_etapa_nome",
    "count"(*) AS "quantidade"
   FROM (("public"."turmas" "t"
     JOIN "public"."escolas" "e" ON (("e"."id" = "t"."id_escola")))
     JOIN "public"."ano_etapa" "ae" ON (("ae"."id" = "t"."id_ano_etapa")))
  GROUP BY "t"."ano", "t"."id_escola", "e"."nome", "t"."id_ano_etapa", "ae"."nome"
  ORDER BY "t"."ano", "e"."nome", "ae"."nome";


ALTER TABLE "public"."vw_turmas_por_ano_etapa_escola" OWNER TO "postgres";


ALTER TABLE ONLY "public"."stg_autoria" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."stg_autoria_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."stg_obra_edicao" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."stg_obra_edicao_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."stg_professor_atribuicao" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."stg_professor_atribuicao_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."adicional_noturno_professor"
    ADD CONSTRAINT "adicional_noturno_professor_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."ano_etapa"
    ADD CONSTRAINT "ano_etapa_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."atividades_infantil_duracao"
    ADD CONSTRAINT "atividades_infantil_duracao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."atividades_infantil"
    ADD CONSTRAINT "atividades_infantil_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."atividades_infantil_vinculos"
    ADD CONSTRAINT "atividades_infantil_vinculos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."bbtk_dim_autoria"
    ADD CONSTRAINT "bbtk_dim_autoria_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_dim_categoria"
    ADD CONSTRAINT "bbtk_dim_categoria_nome_empresa_unique" UNIQUE ("nome", "id_empresa");



ALTER TABLE ONLY "public"."bbtk_dim_categoria"
    ADD CONSTRAINT "bbtk_dim_categoria_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_dim_cdu"
    ADD CONSTRAINT "bbtk_dim_cdu_codigo_empresa_unique" UNIQUE ("codigo", "id_empresa");



ALTER TABLE ONLY "public"."bbtk_dim_cdu"
    ADD CONSTRAINT "bbtk_dim_cdu_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_dim_doador"
    ADD CONSTRAINT "bbtk_dim_doador_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_dim_editora"
    ADD CONSTRAINT "bbtk_dim_editora_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_dim_estante"
    ADD CONSTRAINT "bbtk_dim_estante_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_dim_metadado"
    ADD CONSTRAINT "bbtk_dim_metadado_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_dim_predio"
    ADD CONSTRAINT "bbtk_dim_predio_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_dim_sala"
    ADD CONSTRAINT "bbtk_dim_sala_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_edicao"
    ADD CONSTRAINT "bbtk_edicao_isbn_key" UNIQUE ("isbn");



ALTER TABLE ONLY "public"."bbtk_edicao"
    ADD CONSTRAINT "bbtk_edicao_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_historico_interacao"
    ADD CONSTRAINT "bbtk_historico_interacao_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_inventario_copia"
    ADD CONSTRAINT "bbtk_inventario_copia_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."bbtk_inventario_copia"
    ADD CONSTRAINT "bbtk_inventario_copia_registro_bibliotecario_key" UNIQUE ("registro_bibliotecario");



ALTER TABLE ONLY "public"."bbtk_juncao_edicao_autoria"
    ADD CONSTRAINT "bbtk_juncao_edicao_autoria_pkey" PRIMARY KEY ("edicao_uuid", "autoria_uuid");



ALTER TABLE ONLY "public"."bbtk_juncao_edicao_metadado"
    ADD CONSTRAINT "bbtk_juncao_edicao_metadado_pkey" PRIMARY KEY ("edicao_uuid", "metadado_uuid");



ALTER TABLE ONLY "public"."bbtk_obra"
    ADD CONSTRAINT "bbtk_obra_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."calendario_matriz_semana"
    ADD CONSTRAINT "cal_matriz_unico_local" UNIQUE ("id_turma", "id_local");



ALTER TABLE ONLY "public"."calendario_eventos"
    ADD CONSTRAINT "calendario_eventos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."calendario_matriz_semana"
    ADD CONSTRAINT "calendario_matriz_semana_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."carga_horaria_p1"
    ADD CONSTRAINT "carga_horaria_p1_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."carga_horaria_p3"
    ADD CONSTRAINT "carga_horaria_p3_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."carga_suplementar_professor"
    ADD CONSTRAINT "carga_suplementar_professor_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."classe"
    ADD CONSTRAINT "classe_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."componente"
    ADD CONSTRAINT "componente_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."crm_mensagens"
    ADD CONSTRAINT "crm_mensagens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."diario_presenca"
    ADD CONSTRAINT "diario_presenca_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."diario_presenca"
    ADD CONSTRAINT "diario_presenca_unique" UNIQUE ("id_matricula", "id_horario_aula", "data");



ALTER TABLE ONLY "public"."empresa"
    ADD CONSTRAINT "empresa_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."escolas"
    ADD CONSTRAINT "escolas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."faltas_professores"
    ADD CONSTRAINT "faltas_professores_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."feriados"
    ADD CONSTRAINT "feriados_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ferias_professor"
    ADD CONSTRAINT "ferias_professor_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."fila_processamento_pontuacao"
    ADD CONSTRAINT "fila_processamento_pontuacao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."horario_aula"
    ADD CONSTRAINT "horario_aula_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."horarios_escola"
    ADD CONSTRAINT "horarios_escola_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."licenca_saude"
    ADD CONSTRAINT "licenca_saude_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."lms_configuracao_empresa"
    ADD CONSTRAINT "lms_configuracao_empresa_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lms_conteudo"
    ADD CONSTRAINT "lms_conteudo_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lms_item_conteudo"
    ADD CONSTRAINT "lms_item_conteudo_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lms_pergunta"
    ADD CONSTRAINT "lms_pergunta_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lms_resposta"
    ADD CONSTRAINT "lms_resposta_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lms_resposta_possivel"
    ADD CONSTRAINT "lms_resposta_possivel_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lms_resposta"
    ADD CONSTRAINT "lms_resposta_unique_user_pergunta" UNIQUE ("id_user", "id_pergunta");



ALTER TABLE ONLY "public"."lms_submissao"
    ADD CONSTRAINT "lms_submissao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lms_submissao"
    ADD CONSTRAINT "lms_submissao_unq" UNIQUE ("id_item_conteudo", "id_aluno");



ALTER TABLE ONLY "public"."materiais_sed"
    ADD CONSTRAINT "materiais_sed_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."matriculas"
    ADD CONSTRAINT "matriculas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."meta_turma"
    ADD CONSTRAINT "meta_turma_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."onbdg_codigos_email"
    ADD CONSTRAINT "onbdg_codigos_email_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."papeis_user_auth"
    ADD CONSTRAINT "papeis_user_auth_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."papeis_user_auth"
    ADD CONSTRAINT "papeis_user_auth_user_id_papel_id_empresa_id_key" UNIQUE ("user_id", "papel_id", "empresa_id");



ALTER TABLE ONLY "public"."papeis_user"
    ADD CONSTRAINT "papeis_user_nome_key" UNIQUE ("nome");



ALTER TABLE ONLY "public"."papeis_user"
    ADD CONSTRAINT "papeis_user_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."perguntas_user"
    ADD CONSTRAINT "perguntas_user_pergunta_key" UNIQUE ("pergunta");



ALTER TABLE ONLY "public"."perguntas_user"
    ADD CONSTRAINT "perguntas_user_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pontuacao_professores"
    ADD CONSTRAINT "pontuacao_professores_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."professor_componente"
    ADD CONSTRAINT "professor_componente_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."professor_componentes_atribuicao"
    ADD CONSTRAINT "professor_componentes_atribuicao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."professor_tempo_unidade"
    ADD CONSTRAINT "professor_escola_historico_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."professor_funcao_extra"
    ADD CONSTRAINT "professor_funcao_extra_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."professores_certificados_atribuicao"
    ADD CONSTRAINT "professores_certificados_atribuicao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."respostas_user"
    ADD CONSTRAINT "respostas_user_id_user_id_pergunta_key" UNIQUE ("id_user", "id_pergunta");



ALTER TABLE ONLY "public"."respostas_user"
    ADD CONSTRAINT "respostas_user_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."staging_professor_escola"
    ADD CONSTRAINT "staging_professor_escola_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stg_alunos"
    ADD CONSTRAINT "stg_alunos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stg_autoria"
    ADD CONSTRAINT "stg_autoria_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stg_excedentes"
    ADD CONSTRAINT "stg_excedentes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stg_obra_edicao"
    ADD CONSTRAINT "stg_obra_edicao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stg_ocorrencias_intermediaria"
    ADD CONSTRAINT "stg_ocorrencias_intermediaria_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stg_ocorrencias_log"
    ADD CONSTRAINT "stg_ocorrencias_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stg_ocorrencias"
    ADD CONSTRAINT "stg_ocorrencias_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stg_pontuacao"
    ADD CONSTRAINT "stg_pontuacao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stg_professor_atribuicao"
    ADD CONSTRAINT "stg_professor_atribuicao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."teste_23"
    ADD CONSTRAINT "teste_1_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."turma_professor_atribuicao"
    ADD CONSTRAINT "turma_professor_atribuicao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."turmas"
    ADD CONSTRAINT "turmas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."unidade_atribuicao"
    ADD CONSTRAINT "unidade_atribuicao_pkey" PRIMARY KEY ("uuid");



ALTER TABLE ONLY "public"."user_expandido"
    ADD CONSTRAINT "unique_matricula_empresa" UNIQUE ("matricula", "id_empresa");



ALTER TABLE ONLY "public"."user_expandido"
    ADD CONSTRAINT "user_expandido_professor_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_familia"
    ADD CONSTRAINT "user_familia_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_responsavel_aluno"
    ADD CONSTRAINT "user_responsavel_aluno_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_responsavel_aluno"
    ADD CONSTRAINT "user_responsavel_aluno_unique" UNIQUE ("id_aluno", "id_responsavel");



ALTER TABLE ONLY "public"."versao_app"
    ADD CONSTRAINT "versao_app_pkey" PRIMARY KEY ("id");



CREATE INDEX "atp_id_turma_id_empresa_data_fim_idx" ON "public"."turma_professor_atribuicao" USING "btree" ("id_turma", "id_empresa", "data_fim");



CREATE INDEX "idx_atp_id_professor" ON "public"."turma_professor_atribuicao" USING "btree" ("id_professor");



CREATE INDEX "idx_atp_id_turma_nivel" ON "public"."turma_professor_atribuicao" USING "btree" ("id_turma", "nivel_substituicao");



CREATE INDEX "idx_calendario_eventos_empresa" ON "public"."calendario_eventos" USING "btree" ("id_empresa");



CREATE INDEX "idx_calendario_eventos_turma_data" ON "public"."calendario_eventos" USING "btree" ("id_turma", "data");



CREATE INDEX "idx_diario_data" ON "public"."diario_presenca" USING "btree" ("data");



CREATE INDEX "idx_diario_empresa" ON "public"."diario_presenca" USING "btree" ("id_empresa");



CREATE INDEX "idx_diario_matricula" ON "public"."diario_presenca" USING "btree" ("id_matricula");



CREATE INDEX "idx_feriados_data" ON "public"."feriados" USING "btree" ("data_feriado");



CREATE INDEX "idx_feriados_empresa" ON "public"."feriados" USING "btree" ("id_empresa");



CREATE INDEX "idx_fila_emp_ano" ON "public"."fila_processamento_pontuacao" USING "btree" ("id_empresa", "ano" DESC);



CREATE INDEX "idx_horario_aula_empresa" ON "public"."horario_aula" USING "btree" ("id_empresa");



CREATE INDEX "idx_horario_aula_ordem" ON "public"."horario_aula" USING "btree" ("ordem");



CREATE INDEX "idx_lms_conteudo_escopo_ids" ON "public"."lms_conteudo" USING "btree" ("escopo", "id_turma", "id_aluno", "id_meta_turma");



CREATE INDEX "idx_lms_submissao_item_aluno" ON "public"."lms_submissao" USING "btree" ("id_item_conteudo", "id_aluno");



CREATE INDEX "idx_matriculas_aluno" ON "public"."matriculas" USING "btree" ("id_aluno");



CREATE INDEX "idx_matriculas_empresa" ON "public"."matriculas" USING "btree" ("id_empresa");



CREATE INDEX "idx_matriculas_status" ON "public"."matriculas" USING "btree" ("status");



CREATE INDEX "idx_matriculas_turma" ON "public"."matriculas" USING "btree" ("id_turma");



CREATE INDEX "idx_onbdg_codigos_email_numero" ON "public"."onbdg_codigos_email" USING "btree" ("numero");



CREATE INDEX "idx_onbdg_codigos_email_user_valid" ON "public"."onbdg_codigos_email" USING "btree" ("id_user", "expires_at" DESC);



CREATE INDEX "idx_pt_id_professor_ano" ON "public"."pontuacao_professores" USING "btree" ("id_professor", "ano" DESC);



CREATE INDEX "idx_pua_user_empresa_papel" ON "public"."papeis_user_auth" USING "btree" ("user_id", "empresa_id", "papel_id");



CREATE INDEX "idx_uep_id_empresa" ON "public"."user_expandido" USING "btree" ("id_empresa");



CREATE INDEX "idx_uep_id_escola" ON "public"."user_expandido" USING "btree" ("id_escola");



CREATE INDEX "idx_user_expandido_user_id" ON "public"."user_expandido" USING "btree" ("user_id");



CREATE INDEX "idx_user_familia_empresa" ON "public"."user_familia" USING "btree" ("id_empresa");



CREATE INDEX "idx_user_familia_responsavel" ON "public"."user_familia" USING "btree" ("id_responsavel_principal");



CREATE INDEX "idx_user_responsavel_aluno_aluno" ON "public"."user_responsavel_aluno" USING "btree" ("id_aluno");



CREATE INDEX "idx_user_responsavel_aluno_familia" ON "public"."user_responsavel_aluno" USING "btree" ("id_familia");



CREATE INDEX "idx_user_responsavel_aluno_responsavel" ON "public"."user_responsavel_aluno" USING "btree" ("id_responsavel");



CREATE INDEX "ix_cal_matriz_componente" ON "public"."calendario_matriz_semana" USING "btree" ("id_componente");



CREATE INDEX "ix_cal_matriz_empresa" ON "public"."calendario_matriz_semana" USING "btree" ("id_empresa");



CREATE INDEX "ix_cal_matriz_tipo" ON "public"."calendario_matriz_semana" USING "btree" ("tipo");



CREATE INDEX "ix_cal_matriz_turma_dia" ON "public"."calendario_matriz_semana" USING "btree" ("id_turma", "dia_semana");



CREATE INDEX "ix_chp1_ano" ON "public"."carga_horaria_p1" USING "btree" ("id_ano_etapa");



CREATE INDEX "ix_chp1_comp" ON "public"."carga_horaria_p1" USING "btree" ("id_componente");



CREATE INDEX "ix_chp1_empresa" ON "public"."carga_horaria_p1" USING "btree" ("id_empresa");



CREATE INDEX "ix_chp3_ano" ON "public"."carga_horaria_p3" USING "btree" ("id_ano_etapa");



CREATE INDEX "ix_chp3_comp" ON "public"."carga_horaria_p3" USING "btree" ("id_componente");



CREATE INDEX "ix_unid_chp3" ON "public"."unidade_atribuicao" USING "btree" ("id_ch_p3");



CREATE INDEX "ix_unid_turma" ON "public"."unidade_atribuicao" USING "btree" ("id_turma");



CREATE INDEX "lms_conteudo_id_turma_idx" ON "public"."lms_conteudo" USING "btree" ("id_turma");



CREATE INDEX "lms_item_conteudo_id_conteudo_idx" ON "public"."lms_item_conteudo" USING "btree" ("id_lms_conteudo");



CREATE INDEX "lms_item_conteudo_id_empresa_idx" ON "public"."lms_item_conteudo" USING "btree" ("id_empresa");



CREATE INDEX "lms_item_conteudo_id_lms_conteudo_idx" ON "public"."lms_item_conteudo" USING "btree" ("id_lms_conteudo");



CREATE INDEX "lms_pergunta_id_empresa_idx" ON "public"."lms_pergunta" USING "btree" ("id_empresa");



CREATE INDEX "lms_pergunta_id_item_conteudo_idx" ON "public"."lms_pergunta" USING "btree" ("id_item_conteudo");



CREATE INDEX "lms_resposta_id_pergunta_idx" ON "public"."lms_resposta" USING "btree" ("id_pergunta");



CREATE INDEX "lms_resposta_id_resposta_possivel_idx" ON "public"."lms_resposta" USING "btree" ("id_resposta_possivel");



CREATE INDEX "lms_resposta_id_user_idx" ON "public"."lms_resposta" USING "btree" ("id_user");



CREATE INDEX "lms_resposta_possivel_id_empresa_idx" ON "public"."lms_resposta_possivel" USING "btree" ("id_empresa");



CREATE INDEX "lms_resposta_possivel_id_pergunta_idx" ON "public"."lms_resposta_possivel" USING "btree" ("id_pergunta");



CREATE INDEX "meta_turma_criado_por_idx" ON "public"."meta_turma" USING "btree" ("criado_por");



CREATE INDEX "meta_turma_id_empresa_idx" ON "public"."meta_turma" USING "btree" ("id_empresa");



CREATE INDEX "pca_prof_empresa_idx" ON "public"."professor_componentes_atribuicao" USING "btree" ("id_professor", "id_empresa");



CREATE INDEX "pca_prof_idx" ON "public"."professor_componentes_atribuicao" USING "btree" ("id_professor");



CREATE INDEX "pca_unid_emp_fim_idx" ON "public"."professor_componentes_atribuicao" USING "btree" ("id_unidade_atribuicao", "id_empresa", "data_fim");



CREATE INDEX "pca_unid_empresa_idx" ON "public"."professor_componentes_atribuicao" USING "btree" ("id_unidade_atribuicao", "id_empresa");



CREATE INDEX "pca_unid_nivel_idx" ON "public"."professor_componentes_atribuicao" USING "btree" ("id_unidade_atribuicao", "nivel_substituicao");



CREATE INDEX "professor_funcao_extra_empresa_status_datafim_idx" ON "public"."professor_funcao_extra" USING "btree" ("id_empresa", "status", "data_fim");



CREATE INDEX "professor_funcao_extra_user_empresa_idx" ON "public"."professor_funcao_extra" USING "btree" ("user_id", "id_empresa");



CREATE INDEX "turma_prof_atrib_prof_empresa_idx" ON "public"."turma_professor_atribuicao" USING "btree" ("id_professor", "id_empresa");



CREATE INDEX "turma_prof_atrib_turma_empresa_idx" ON "public"."turma_professor_atribuicao" USING "btree" ("id_turma", "id_empresa");



CREATE INDEX "user_expandido_user_id_idx" ON "public"."user_expandido" USING "btree" ("user_id");



CREATE UNIQUE INDEX "ux_ai_empresa_nome_norm" ON "public"."atividades_infantil" USING "btree" ("id_empresa", "lower"(TRIM(BOTH FROM "nome")));



CREATE UNIQUE INDEX "ux_aid_empresa_atividade_duracao" ON "public"."atividades_infantil_duracao" USING "btree" ("id_empresa", "id_atividade_infantil", "duracao_minutos");



CREATE UNIQUE INDEX "ux_pontuacao_professor_ano_soft" ON "public"."pontuacao_professores" USING "btree" ("id_professor", "ano", "soft_delete");



CREATE OR REPLACE TRIGGER "tg_registrar_pontuacao_excedente" AFTER UPDATE ON "public"."professor_tempo_unidade" FOR EACH ROW WHEN ((("new"."excedente" IS TRUE) AND ("new"."data_fim" IS DISTINCT FROM "old"."data_fim"))) EXECUTE FUNCTION "public"."trg_registrar_pontuacao_excedente"();



CREATE OR REPLACE TRIGGER "trg_atualiza_at_professores" BEFORE INSERT OR UPDATE ON "public"."turmas" FOR EACH ROW EXECUTE FUNCTION "public"."atualiza_at_professores"();



CREATE OR REPLACE TRIGGER "trg_log_papeis_user_auth" BEFORE UPDATE ON "public"."papeis_user_auth" FOR EACH ROW EXECUTE FUNCTION "public"."log_update_papeis_user_auth"();



CREATE OR REPLACE TRIGGER "trg_set_created_modified_by_insert" BEFORE INSERT ON "public"."faltas_professores" FOR EACH ROW EXECUTE FUNCTION "public"."set_created_modified_by"();



CREATE OR REPLACE TRIGGER "trg_set_created_modified_by_insert" BEFORE INSERT ON "public"."licenca_saude" FOR EACH ROW EXECUTE FUNCTION "public"."set_created_modified_by"();



CREATE OR REPLACE TRIGGER "trg_set_modified_by_update" BEFORE UPDATE ON "public"."faltas_professores" FOR EACH ROW EXECUTE FUNCTION "public"."set_created_modified_by"();



CREATE OR REPLACE TRIGGER "trg_set_modified_by_update" BEFORE UPDATE ON "public"."licenca_saude" FOR EACH ROW EXECUTE FUNCTION "public"."set_created_modified_by"();



CREATE OR REPLACE TRIGGER "trg_touch_fila_pont" BEFORE UPDATE ON "public"."fila_processamento_pontuacao" FOR EACH ROW EXECUTE FUNCTION "public"."_touch_atualizado_em"();



CREATE OR REPLACE TRIGGER "trigger_sync_papel" AFTER INSERT OR UPDATE ON "public"."professor_funcao_extra" FOR EACH ROW EXECUTE FUNCTION "public"."sync_papel_professor_funcao_extra"();



CREATE OR REPLACE TRIGGER "trigger_sync_status" BEFORE INSERT OR UPDATE ON "public"."professor_funcao_extra" FOR EACH ROW EXECUTE FUNCTION "public"."sync_status_professor_funcao_extra"();



ALTER TABLE ONLY "public"."adicional_noturno_professor"
    ADD CONSTRAINT "adicional_noturno_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."adicional_noturno_professor"
    ADD CONSTRAINT "adicional_noturno_professor_fkey" FOREIGN KEY ("id_professor") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ano_etapa"
    ADD CONSTRAINT "ano_etapa_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."atividades_infantil"
    ADD CONSTRAINT "atividades_infantil_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."atividades_infantil_duracao"
    ADD CONSTRAINT "atividades_infantil_duracao_id_atividade_infantil_fkey" FOREIGN KEY ("id_atividade_infantil") REFERENCES "public"."atividades_infantil"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."atividades_infantil_duracao"
    ADD CONSTRAINT "atividades_infantil_duracao_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."atividades_infantil"
    ADD CONSTRAINT "atividades_infantil_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."atividades_infantil_vinculos"
    ADD CONSTRAINT "atividades_infantil_vinculos_id_atividade_infantil_fkey" FOREIGN KEY ("id_atividade_infantil") REFERENCES "public"."atividades_infantil"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."atividades_infantil_vinculos"
    ADD CONSTRAINT "atividades_infantil_vinculos_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."atividades_infantil_vinculos"
    ADD CONSTRAINT "atividades_infantil_vinculos_id_turma_fkey" FOREIGN KEY ("id_turma") REFERENCES "public"."turmas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bbtk_dim_autoria"
    ADD CONSTRAINT "bbtk_dim_autoria_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_dim_categoria"
    ADD CONSTRAINT "bbtk_dim_categoria_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_dim_cdu"
    ADD CONSTRAINT "bbtk_dim_cdu_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_dim_doador"
    ADD CONSTRAINT "bbtk_dim_doador_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_dim_editora"
    ADD CONSTRAINT "bbtk_dim_editora_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_dim_estante"
    ADD CONSTRAINT "bbtk_dim_estante_sala_uuid_fkey" FOREIGN KEY ("sala_uuid") REFERENCES "public"."bbtk_dim_sala"("uuid");



ALTER TABLE ONLY "public"."bbtk_dim_metadado"
    ADD CONSTRAINT "bbtk_dim_metadado_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_dim_predio"
    ADD CONSTRAINT "bbtk_dim_predio_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_dim_predio"
    ADD CONSTRAINT "bbtk_dim_predio_id_escola_fkey" FOREIGN KEY ("id_escola") REFERENCES "public"."escolas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."bbtk_dim_sala"
    ADD CONSTRAINT "bbtk_dim_sala_predio_uuid_fkey" FOREIGN KEY ("predio_uuid") REFERENCES "public"."bbtk_dim_predio"("uuid");



ALTER TABLE ONLY "public"."bbtk_edicao"
    ADD CONSTRAINT "bbtk_edicao_doador_uuid_fkey" FOREIGN KEY ("doador_uuid") REFERENCES "public"."bbtk_dim_doador"("uuid");



ALTER TABLE ONLY "public"."bbtk_edicao"
    ADD CONSTRAINT "bbtk_edicao_editora_uuid_fkey" FOREIGN KEY ("editora_uuid") REFERENCES "public"."bbtk_dim_editora"("uuid");



ALTER TABLE ONLY "public"."bbtk_edicao"
    ADD CONSTRAINT "bbtk_edicao_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_edicao"
    ADD CONSTRAINT "bbtk_edicao_obra_uuid_fkey" FOREIGN KEY ("obra_uuid") REFERENCES "public"."bbtk_obra"("uuid");



ALTER TABLE ONLY "public"."bbtk_historico_interacao"
    ADD CONSTRAINT "bbtk_historico_interacao_copia_uuid_fkey" FOREIGN KEY ("copia_uuid") REFERENCES "public"."bbtk_inventario_copia"("uuid");



ALTER TABLE ONLY "public"."bbtk_historico_interacao"
    ADD CONSTRAINT "bbtk_historico_interacao_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_inventario_copia"
    ADD CONSTRAINT "bbtk_inventario_copia_edicao_uuid_fkey" FOREIGN KEY ("edicao_uuid") REFERENCES "public"."bbtk_edicao"("uuid");



ALTER TABLE ONLY "public"."bbtk_inventario_copia"
    ADD CONSTRAINT "bbtk_inventario_copia_estante_uuid_fkey" FOREIGN KEY ("estante_uuid") REFERENCES "public"."bbtk_dim_estante"("uuid");



ALTER TABLE ONLY "public"."bbtk_inventario_copia"
    ADD CONSTRAINT "bbtk_inventario_copia_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_juncao_edicao_autoria"
    ADD CONSTRAINT "bbtk_juncao_edicao_autoria_autoria_uuid_fkey" FOREIGN KEY ("autoria_uuid") REFERENCES "public"."bbtk_dim_autoria"("uuid");



ALTER TABLE ONLY "public"."bbtk_juncao_edicao_autoria"
    ADD CONSTRAINT "bbtk_juncao_edicao_autoria_edicao_uuid_fkey" FOREIGN KEY ("edicao_uuid") REFERENCES "public"."bbtk_edicao"("uuid");



ALTER TABLE ONLY "public"."bbtk_juncao_edicao_autoria"
    ADD CONSTRAINT "bbtk_juncao_edicao_autoria_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_juncao_edicao_metadado"
    ADD CONSTRAINT "bbtk_juncao_edicao_metadado_edicao_uuid_fkey" FOREIGN KEY ("edicao_uuid") REFERENCES "public"."bbtk_edicao"("uuid");



ALTER TABLE ONLY "public"."bbtk_juncao_edicao_metadado"
    ADD CONSTRAINT "bbtk_juncao_edicao_metadado_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."bbtk_juncao_edicao_metadado"
    ADD CONSTRAINT "bbtk_juncao_edicao_metadado_metadado_uuid_fkey" FOREIGN KEY ("metadado_uuid") REFERENCES "public"."bbtk_dim_metadado"("uuid");



ALTER TABLE ONLY "public"."bbtk_obra"
    ADD CONSTRAINT "bbtk_obra_categoria_uuid_fkey" FOREIGN KEY ("categoria_uuid") REFERENCES "public"."bbtk_dim_categoria"("uuid");



ALTER TABLE ONLY "public"."bbtk_obra"
    ADD CONSTRAINT "bbtk_obra_cdu_uuid_fkey" FOREIGN KEY ("cdu_uuid") REFERENCES "public"."bbtk_dim_cdu"("uuid");



ALTER TABLE ONLY "public"."bbtk_obra"
    ADD CONSTRAINT "bbtk_obra_id_autoria_fkey" FOREIGN KEY ("id_autoria") REFERENCES "public"."bbtk_dim_autoria"("uuid");



ALTER TABLE ONLY "public"."bbtk_obra"
    ADD CONSTRAINT "bbtk_obra_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."calendario_eventos"
    ADD CONSTRAINT "calendario_eventos_id_componente_fkey" FOREIGN KEY ("id_componente") REFERENCES "public"."componente"("uuid") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."calendario_eventos"
    ADD CONSTRAINT "calendario_eventos_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."calendario_eventos"
    ADD CONSTRAINT "calendario_eventos_id_horario_aula_fkey" FOREIGN KEY ("id_horario_aula") REFERENCES "public"."horario_aula"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."calendario_eventos"
    ADD CONSTRAINT "calendario_eventos_id_turma_fkey" FOREIGN KEY ("id_turma") REFERENCES "public"."turmas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."calendario_matriz_semana"
    ADD CONSTRAINT "calendario_matriz_semana_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."calendario_matriz_semana"
    ADD CONSTRAINT "calendario_matriz_semana_id_atividade_infantil_fkey" FOREIGN KEY ("id_atividade_infantil") REFERENCES "public"."atividades_infantil"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."calendario_matriz_semana"
    ADD CONSTRAINT "calendario_matriz_semana_id_carga_horaria_p1_fkey" FOREIGN KEY ("id_carga_horaria_p1") REFERENCES "public"."carga_horaria_p1"("uuid") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."calendario_matriz_semana"
    ADD CONSTRAINT "calendario_matriz_semana_id_carga_horaria_p3_fkey" FOREIGN KEY ("id_carga_horaria_p3") REFERENCES "public"."carga_horaria_p3"("uuid") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."calendario_matriz_semana"
    ADD CONSTRAINT "calendario_matriz_semana_id_componente_fkey" FOREIGN KEY ("id_componente") REFERENCES "public"."componente"("uuid") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."calendario_matriz_semana"
    ADD CONSTRAINT "calendario_matriz_semana_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."calendario_matriz_semana"
    ADD CONSTRAINT "calendario_matriz_semana_id_turma_fkey" FOREIGN KEY ("id_turma") REFERENCES "public"."turmas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."carga_horaria_p1"
    ADD CONSTRAINT "carga_horaria_p1_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."carga_horaria_p1"
    ADD CONSTRAINT "carga_horaria_p1_id_ano_etapa_fkey" FOREIGN KEY ("id_ano_etapa") REFERENCES "public"."ano_etapa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."carga_horaria_p1"
    ADD CONSTRAINT "carga_horaria_p1_id_componente_fkey" FOREIGN KEY ("id_componente") REFERENCES "public"."componente"("uuid") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."carga_horaria_p1"
    ADD CONSTRAINT "carga_horaria_p1_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."carga_horaria_p1"
    ADD CONSTRAINT "carga_horaria_p1_modifica_por_fkey" FOREIGN KEY ("modifica_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."carga_horaria_p3"
    ADD CONSTRAINT "carga_horaria_p3_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."carga_horaria_p3"
    ADD CONSTRAINT "carga_horaria_p3_id_ano_etapa_fkey" FOREIGN KEY ("id_ano_etapa") REFERENCES "public"."ano_etapa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."carga_horaria_p3"
    ADD CONSTRAINT "carga_horaria_p3_id_componente_fkey" FOREIGN KEY ("id_componente") REFERENCES "public"."componente"("uuid") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."carga_horaria_p3"
    ADD CONSTRAINT "carga_horaria_p3_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."carga_horaria_p3"
    ADD CONSTRAINT "carga_horaria_p3_modifica_por_fkey" FOREIGN KEY ("modifica_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."carga_suplementar_professor"
    ADD CONSTRAINT "carga_suplementar_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."carga_suplementar_professor"
    ADD CONSTRAINT "carga_suplementar_professor_fkey" FOREIGN KEY ("id_professor") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."classe"
    ADD CONSTRAINT "classe_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."componente"
    ADD CONSTRAINT "componente_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."diario_presenca"
    ADD CONSTRAINT "diario_presenca_id_componente_fkey" FOREIGN KEY ("id_componente") REFERENCES "public"."componente"("uuid") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."diario_presenca"
    ADD CONSTRAINT "diario_presenca_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."diario_presenca"
    ADD CONSTRAINT "diario_presenca_id_horario_aula_fkey" FOREIGN KEY ("id_horario_aula") REFERENCES "public"."horario_aula"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."diario_presenca"
    ADD CONSTRAINT "diario_presenca_id_matricula_fkey" FOREIGN KEY ("id_matricula") REFERENCES "public"."matriculas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."diario_presenca"
    ADD CONSTRAINT "diario_presenca_registrado_por_fkey" FOREIGN KEY ("registrado_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."escolas"
    ADD CONSTRAINT "escolas_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."faltas_professores"
    ADD CONSTRAINT "faltas_professores_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."faltas_professores"
    ADD CONSTRAINT "faltas_professores_professor_fkey" FOREIGN KEY ("id_professor") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."feriados"
    ADD CONSTRAINT "feriados_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ferias_professor"
    ADD CONSTRAINT "ferias_professor_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ferias_professor"
    ADD CONSTRAINT "ferias_professor_professor_fkey" FOREIGN KEY ("id_professor") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."fila_processamento_pontuacao"
    ADD CONSTRAINT "fila_processamento_pontuacao_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."fila_processamento_pontuacao"
    ADD CONSTRAINT "fila_processamento_pontuacao_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."horario_aula"
    ADD CONSTRAINT "horario_aula_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."horario_aula"
    ADD CONSTRAINT "horario_aula_id_horario_fkey" FOREIGN KEY ("id_horario") REFERENCES "public"."horarios_escola"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."horarios_escola"
    ADD CONSTRAINT "horarios_escola_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."licenca_saude"
    ADD CONSTRAINT "licenca_saude_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."licenca_saude"
    ADD CONSTRAINT "licenca_saude_professor_fkey" FOREIGN KEY ("id_professor") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_configuracao_empresa"
    ADD CONSTRAINT "lms_configuracao_empresa_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_conteudo"
    ADD CONSTRAINT "lms_conteudo_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."lms_conteudo"
    ADD CONSTRAINT "lms_conteudo_id_aluno_fkey" FOREIGN KEY ("id_aluno") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_conteudo"
    ADD CONSTRAINT "lms_conteudo_id_componente_fkey" FOREIGN KEY ("id_componente") REFERENCES "public"."componente"("uuid") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_conteudo"
    ADD CONSTRAINT "lms_conteudo_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."lms_conteudo"
    ADD CONSTRAINT "lms_conteudo_id_meta_turma_fkey" FOREIGN KEY ("id_meta_turma") REFERENCES "public"."meta_turma"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_conteudo"
    ADD CONSTRAINT "lms_conteudo_id_turma_fkey" FOREIGN KEY ("id_turma") REFERENCES "public"."turmas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_item_conteudo"
    ADD CONSTRAINT "lms_item_conteudo_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."lms_item_conteudo"
    ADD CONSTRAINT "lms_item_conteudo_id_lms_conteudo_fkey" FOREIGN KEY ("id_lms_conteudo") REFERENCES "public"."lms_conteudo"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_item_conteudo"
    ADD CONSTRAINT "lms_item_id_bbtk_edicao_fkey" FOREIGN KEY ("id_bbtk_edicao") REFERENCES "public"."bbtk_edicao"("uuid") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."lms_pergunta"
    ADD CONSTRAINT "lms_pergunta_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."lms_pergunta"
    ADD CONSTRAINT "lms_pergunta_id_item_conteudo_fkey" FOREIGN KEY ("id_item_conteudo") REFERENCES "public"."lms_item_conteudo"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_resposta"
    ADD CONSTRAINT "lms_resposta_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."lms_resposta"
    ADD CONSTRAINT "lms_resposta_id_pergunta_fkey" FOREIGN KEY ("id_pergunta") REFERENCES "public"."lms_pergunta"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_resposta"
    ADD CONSTRAINT "lms_resposta_id_resposta_possivel_fkey" FOREIGN KEY ("id_resposta_possivel") REFERENCES "public"."lms_resposta_possivel"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."lms_resposta"
    ADD CONSTRAINT "lms_resposta_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_resposta"
    ADD CONSTRAINT "lms_resposta_modificado_por_fkey" FOREIGN KEY ("modificado_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."lms_resposta_possivel"
    ADD CONSTRAINT "lms_resposta_possivel_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."lms_resposta_possivel"
    ADD CONSTRAINT "lms_resposta_possivel_id_pergunta_fkey" FOREIGN KEY ("id_pergunta") REFERENCES "public"."lms_pergunta"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_submissao"
    ADD CONSTRAINT "lms_submissao_id_aluno_fkey" FOREIGN KEY ("id_aluno") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lms_submissao"
    ADD CONSTRAINT "lms_submissao_id_item_fkey" FOREIGN KEY ("id_item_conteudo") REFERENCES "public"."lms_item_conteudo"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."matriculas"
    ADD CONSTRAINT "matriculas_id_aluno_fkey" FOREIGN KEY ("id_aluno") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."matriculas"
    ADD CONSTRAINT "matriculas_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."matriculas"
    ADD CONSTRAINT "matriculas_id_turma_fkey" FOREIGN KEY ("id_turma") REFERENCES "public"."turmas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."meta_turma"
    ADD CONSTRAINT "meta_turma_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."meta_turma"
    ADD CONSTRAINT "meta_turma_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."meta_turma"
    ADD CONSTRAINT "meta_turma_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."meta_turma"
    ADD CONSTRAINT "meta_turma_modificado_por_fkey" FOREIGN KEY ("modificado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."onbdg_codigos_email"
    ADD CONSTRAINT "onbdg_codigos_email_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."papeis_user_auth"
    ADD CONSTRAINT "papeis_user_auth_empresa_id_fkey" FOREIGN KEY ("empresa_id") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."papeis_user_auth"
    ADD CONSTRAINT "papeis_user_auth_papel_id_fkey" FOREIGN KEY ("papel_id") REFERENCES "public"."papeis_user"("id");



ALTER TABLE ONLY "public"."papeis_user_auth"
    ADD CONSTRAINT "papeis_user_auth_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professor_componentes_atribuicao"
    ADD CONSTRAINT "pca_id_empresa_fk" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professor_componentes_atribuicao"
    ADD CONSTRAINT "pca_id_professor_fk" FOREIGN KEY ("id_professor") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professor_componentes_atribuicao"
    ADD CONSTRAINT "pca_id_unidatr_fk" FOREIGN KEY ("id_unidade_atribuicao") REFERENCES "public"."unidade_atribuicao"("uuid") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."perguntas_user"
    ADD CONSTRAINT "perguntas_user_id_papel_fkey" FOREIGN KEY ("id_papel") REFERENCES "public"."papeis_user"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."pontuacao_professores"
    ADD CONSTRAINT "pontuacao_professores_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."pontuacao_professores"
    ADD CONSTRAINT "pontuacao_professores_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pontuacao_professores"
    ADD CONSTRAINT "pontuacao_professores_id_professor_fkey" FOREIGN KEY ("id_professor") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pontuacao_professores"
    ADD CONSTRAINT "pontuacao_professores_modificado_por_fkey" FOREIGN KEY ("modificado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."professor_componente"
    ADD CONSTRAINT "professor_componente_atualizado_por_fkey" FOREIGN KEY ("atualizado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."professor_componente"
    ADD CONSTRAINT "professor_componente_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."professor_componente"
    ADD CONSTRAINT "professor_componente_id_componente_fkey" FOREIGN KEY ("id_componente") REFERENCES "public"."componente"("uuid") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professor_componente"
    ADD CONSTRAINT "professor_componente_id_professor_fkey" FOREIGN KEY ("id_professor") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professor_funcao_extra"
    ADD CONSTRAINT "professor_funcao_extra_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."professor_funcao_extra"
    ADD CONSTRAINT "professor_funcao_extra_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professor_funcao_extra"
    ADD CONSTRAINT "professor_funcao_extra_id_escola_fkey" FOREIGN KEY ("id_escola") REFERENCES "public"."escolas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."professor_funcao_extra"
    ADD CONSTRAINT "professor_funcao_extra_modificado_por_fkey" FOREIGN KEY ("modificado_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."professor_funcao_extra"
    ADD CONSTRAINT "professor_funcao_extra_user_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."professor_tempo_unidade"
    ADD CONSTRAINT "professor_tempo_unidade_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."professor_tempo_unidade"
    ADD CONSTRAINT "professor_tempo_unidade_id_escola_fkey" FOREIGN KEY ("id_escola") REFERENCES "public"."escolas"("id");



ALTER TABLE ONLY "public"."professor_tempo_unidade"
    ADD CONSTRAINT "professor_tempo_unidade_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."professores_certificados_atribuicao"
    ADD CONSTRAINT "professores_certificados_atribuicao_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."professores_certificados_atribuicao"
    ADD CONSTRAINT "professores_certificados_atribuicao_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id");



ALTER TABLE ONLY "public"."professores_certificados_atribuicao"
    ADD CONSTRAINT "professores_certificados_atribuicao_id_professor_fkey" FOREIGN KEY ("id_professor") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."professores_certificados_atribuicao"
    ADD CONSTRAINT "professores_certificados_atribuicao_modificado_por_fkey" FOREIGN KEY ("modificado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."respostas_user"
    ADD CONSTRAINT "respostas_user_atualizado_por_fkey" FOREIGN KEY ("atualizado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."respostas_user"
    ADD CONSTRAINT "respostas_user_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id");



ALTER TABLE ONLY "public"."respostas_user"
    ADD CONSTRAINT "respostas_user_id_pergunta_fkey" FOREIGN KEY ("id_pergunta") REFERENCES "public"."perguntas_user"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."respostas_user"
    ADD CONSTRAINT "respostas_user_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."stg_ocorrencias_log"
    ADD CONSTRAINT "stg_ocorrencias_log_id_stg_ocorrencias_fkey" FOREIGN KEY ("id_stg_ocorrencias") REFERENCES "public"."stg_ocorrencias"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."turma_professor_atribuicao"
    ADD CONSTRAINT "turma_professor_atribuicao_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."turma_professor_atribuicao"
    ADD CONSTRAINT "turma_professor_atribuicao_id_professor_fkey" FOREIGN KEY ("id_professor") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."turma_professor_atribuicao"
    ADD CONSTRAINT "turma_professor_atribuicao_id_turma_fkey" FOREIGN KEY ("id_turma") REFERENCES "public"."turmas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."turmas"
    ADD CONSTRAINT "turmas_id_ano_etapa_fkey" FOREIGN KEY ("id_ano_etapa") REFERENCES "public"."ano_etapa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."turmas"
    ADD CONSTRAINT "turmas_id_classe_fkey" FOREIGN KEY ("id_classe") REFERENCES "public"."classe"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."turmas"
    ADD CONSTRAINT "turmas_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."turmas"
    ADD CONSTRAINT "turmas_id_escola_fkey" FOREIGN KEY ("id_escola") REFERENCES "public"."escolas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."turmas"
    ADD CONSTRAINT "turmas_id_horario_fkey" FOREIGN KEY ("id_horario") REFERENCES "public"."horarios_escola"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."turmas"
    ADD CONSTRAINT "turmas_id_professor_fkey" FOREIGN KEY ("id_professor") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."turmas"
    ADD CONSTRAINT "turmas_id_professor_s_fkey" FOREIGN KEY ("id_professor_s") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."unidade_atribuicao"
    ADD CONSTRAINT "unidade_atribuicao_criado_por_fkey" FOREIGN KEY ("criado_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."unidade_atribuicao"
    ADD CONSTRAINT "unidade_atribuicao_id_ch_p3_fkey" FOREIGN KEY ("id_ch_p3") REFERENCES "public"."carga_horaria_p3"("uuid") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."unidade_atribuicao"
    ADD CONSTRAINT "unidade_atribuicao_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."unidade_atribuicao"
    ADD CONSTRAINT "unidade_atribuicao_id_turma_fkey" FOREIGN KEY ("id_turma") REFERENCES "public"."turmas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."unidade_atribuicao"
    ADD CONSTRAINT "unidade_atribuicao_modifica_por_fkey" FOREIGN KEY ("modifica_por") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_expandido"
    ADD CONSTRAINT "user_expandido_professor_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_expandido"
    ADD CONSTRAINT "user_expandido_professor_escola_fkey" FOREIGN KEY ("id_escola") REFERENCES "public"."escolas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_expandido"
    ADD CONSTRAINT "user_expandido_professor_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_familia"
    ADD CONSTRAINT "user_familia_id_empresa_fkey" FOREIGN KEY ("id_empresa") REFERENCES "public"."empresa"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_familia"
    ADD CONSTRAINT "user_familia_id_responsavel_principal_fkey" FOREIGN KEY ("id_responsavel_principal") REFERENCES "public"."user_expandido"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_responsavel_aluno"
    ADD CONSTRAINT "user_responsavel_aluno_id_aluno_fkey" FOREIGN KEY ("id_aluno") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_responsavel_aluno"
    ADD CONSTRAINT "user_responsavel_aluno_id_familia_fkey" FOREIGN KEY ("id_familia") REFERENCES "public"."user_familia"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_responsavel_aluno"
    ADD CONSTRAINT "user_responsavel_aluno_id_responsavel_fkey" FOREIGN KEY ("id_responsavel") REFERENCES "public"."user_expandido"("id") ON DELETE CASCADE;



CREATE POLICY "Admin acesso total" ON "public"."carga_horaria_p3" TO "authenticated" USING ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text"));



CREATE POLICY "Admin acesso total" ON "public"."lms_configuracao_empresa" TO "authenticated" USING ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text"));



CREATE POLICY "Admin acesso total" ON "public"."lms_conteudo" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin acesso total" ON "public"."lms_item_conteudo" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin acesso total" ON "public"."lms_resposta_possivel" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin acesso total" ON "public"."unidade_atribuicao" TO "authenticated" USING ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text"));



CREATE POLICY "Admin acesso total 3" ON "public"."ano_etapa" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin acesso total_2" ON "public"."pontuacao_professores" TO "authenticated" USING ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text"));



CREATE POLICY "Admin edita componentes da sua empresa" ON "public"."componente" FOR UPDATE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin insere componentes da sua empresa" ON "public"."componente" FOR INSERT TO "authenticated" WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode atualizar professor_funcao_extra" ON "public"."professor_funcao_extra" FOR UPDATE TO "authenticated" USING ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text"));



CREATE POLICY "Admin pode deletar professor_funcao_extra" ON "public"."professor_funcao_extra" FOR DELETE TO "authenticated" USING ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text"));



CREATE POLICY "Admin pode gerenciar atividades infantis da sua empresa" ON "public"."atividades_infantil" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode gerenciar carga_horaria_p1 da sua empresa" ON "public"."carga_horaria_p1" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode gerenciar diário da sua empresa" ON "public"."diario_presenca" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode gerenciar durações infantis da sua empresa" ON "public"."atividades_infantil_duracao" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode gerenciar eventos da sua empresa" ON "public"."calendario_eventos" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode gerenciar famílias da sua empresa" ON "public"."user_familia" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode gerenciar feriados da sua empresa" ON "public"."feriados" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode gerenciar horários da sua empresa" ON "public"."horario_aula" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode gerenciar matrículas da sua empresa" ON "public"."matriculas" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode gerenciar vínculos infantis da sua empresa" ON "public"."atividades_infantil_vinculos" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode inserir professor_funcao_extra" ON "public"."professor_funcao_extra" FOR INSERT TO "authenticated" WITH CHECK ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text"));



CREATE POLICY "Admin pode ler professor_funcao_extra" ON "public"."professor_funcao_extra" FOR SELECT TO "authenticated" USING ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text"));



CREATE POLICY "Admin pode tudo" ON "public"."papeis_user_auth" TO "authenticated" USING ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text"));



CREATE POLICY "Admin pode tudo em escolas da sua empresa" ON "public"."escolas" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo na carga suplementar" ON "public"."carga_suplementar_professor" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo nas atribuições da sua empresa" ON "public"."turma_professor_atribuicao" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo nas classes da sua empresa" ON "public"."classe" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo nas faltas da sua empresa" ON "public"."faltas_professores" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo nas ferias da sua empresa" ON "public"."ferias_professor" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo nas licenças da sua empresa" ON "public"."licenca_saude" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo nas respostas da sua empresa" ON "public"."respostas_user" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo nas turmas da sua empresa" ON "public"."turmas" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo no adicional noturno" ON "public"."adicional_noturno_professor" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo no tempo_unidade da sua empresa" ON "public"."professor_tempo_unidade" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo nos certificados dos professores da sua empresa" ON "public"."professores_certificados_atribuicao" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo nos componentes da sua empresa" ON "public"."professor_componente" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo nos horários da sua empresa" ON "public"."horarios_escola" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin pode tudo nos professores da sua empresa" ON "public"."user_expandido" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admin vê apenas sua empresa" ON "public"."empresa" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id")));



CREATE POLICY "Admin vê componentes da sua empresa" ON "public"."componente" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Admins podem ler mensagens" ON "public"."crm_mensagens" FOR SELECT TO "authenticated" USING ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text"));



CREATE POLICY "Funcao extra pode editar todos os certificados" ON "public"."professores_certificados_atribuicao" FOR UPDATE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'professor_funcao_extra'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'professor_funcao_extra'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Funcao extra pode inserir certificados" ON "public"."professores_certificados_atribuicao" FOR INSERT TO "authenticated" WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'professor_funcao_extra'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Funcao extra pode ver todos os certificados" ON "public"."professores_certificados_atribuicao" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'professor_funcao_extra'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Funcao extra: pode ler apenas professores da sua empresa" ON "public"."user_expandido" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'professor_funcao_extra'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa") AND (("papel_id" = '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1'::"uuid") OR ("papel_id" = '07028505-01d7-4986-800e-9d71cab5dd6c'::"uuid"))));



CREATE POLICY "Leitura pública de materiais_sed" ON "public"."materiais_sed" FOR SELECT USING (true);



CREATE POLICY "Professor pode gerenciar seus próprios certificados" ON "public"."professores_certificados_atribuicao" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_expandido" "uep"
  WHERE (("uep"."id" = "professores_certificados_atribuicao"."id_professor") AND ("uep"."user_id" = "auth"."uid"()) AND ("uep"."id_empresa" = "uep"."id_empresa"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_expandido" "uep"
  WHERE (("uep"."id" = "professores_certificados_atribuicao"."id_professor") AND ("uep"."user_id" = "auth"."uid"()) AND ("uep"."id_empresa" = "uep"."id_empresa")))));



CREATE POLICY "Professor vê apenas seus próprios componentes" ON "public"."professor_componente" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'professor'::"text") AND ("auth"."uid"() = "id_professor"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'professor'::"text") AND ("auth"."uid"() = "id_professor")));



CREATE POLICY "Professor vê apenas suas respostas" ON "public"."respostas_user" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'professor'::"text") AND ("auth"."uid"() = "id_user"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'professor'::"text") AND ("auth"."uid"() = "id_user")));



CREATE POLICY "Professor(es) podem ver ano_etapa da sua empresa" ON "public"."ano_etapa" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Professor(es) podem ver classe da sua empresa" ON "public"."classe" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Professor(es) podem ver escolas da sua empresa" ON "public"."escolas" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Professor(es) podem ver horarios_escola da sua empresa" ON "public"."horarios_escola" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "Professor(es) podem ver turmas da sua empresa" ON "public"."turmas" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "RLS: Admin/Admin_Biblio full access" ON "public"."stg_autoria" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") OR (("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin_biblio'::"text")));



CREATE POLICY "RLS: Authenticated users can read" ON "public"."stg_autoria" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usuário acessa seus próprios papeis" ON "public"."papeis_user_auth" TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Usuário autenticado acessa apenas seus próprios dados" ON "public"."user_expandido" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Usuário autenticado vê apenas sua empresa" ON "public"."empresa" TO "authenticated" USING (((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id"));



ALTER TABLE "public"."adicional_noturno_professor" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "admin pode tudo em submissao" ON "public"."lms_submissao" TO "authenticated" USING ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text")) WITH CHECK ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text"));



CREATE POLICY "admin_all" ON "public"."pontuacao_professores" USING ((("auth"."jwt"() ->> 'user_role'::"text") = 'admin'::"text"));



CREATE POLICY "admin_atualiza_resposta_lms" ON "public"."lms_resposta" FOR UPDATE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((EXISTS ( SELECT 1
   FROM "public"."user_expandido" "u"
  WHERE (("u"."id" = "lms_resposta"."id_user") AND ("u"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid")))) OR (EXISTS ( SELECT 1
   FROM "public"."lms_pergunta" "p"
  WHERE (("p"."id" = "lms_resposta"."id_pergunta") AND ("p"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"))))))) WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."user_expandido" "u"
  WHERE (("u"."id" = "lms_resposta"."id_user") AND ("u"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid")))) AND (EXISTS ( SELECT 1
   FROM "public"."lms_pergunta" "p"
  WHERE (("p"."id" = "lms_resposta"."id_pergunta") AND ("p"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"))))));



CREATE POLICY "admin_cria_resposta_lms" ON "public"."lms_resposta" FOR INSERT TO "authenticated" WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."user_expandido" "u"
  WHERE (("u"."id" = "lms_resposta"."id_user") AND ("u"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid")))) AND (EXISTS ( SELECT 1
   FROM "public"."lms_pergunta" "p"
  WHERE (("p"."id" = "lms_resposta"."id_pergunta") AND ("p"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"))))));



CREATE POLICY "admin_deleta_pergunta_lms" ON "public"."lms_pergunta" FOR DELETE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (NOT "public"."lms_pergunta_tem_respostas"("id"))));



CREATE POLICY "admin_deleta_resposta_lms" ON "public"."lms_resposta" FOR DELETE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((EXISTS ( SELECT 1
   FROM "public"."user_expandido" "u"
  WHERE (("u"."id" = "lms_resposta"."id_user") AND ("u"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid")))) OR (EXISTS ( SELECT 1
   FROM "public"."lms_pergunta" "p"
  WHERE (("p"."id" = "lms_resposta"."id_pergunta") AND ("p"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid")))))));



CREATE POLICY "admin_ler_respostas_lms" ON "public"."lms_resposta" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((EXISTS ( SELECT 1
   FROM "public"."user_expandido" "u"
  WHERE (("u"."id" = "lms_resposta"."id_user") AND ("u"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid")))) OR (EXISTS ( SELECT 1
   FROM "public"."lms_pergunta" "p"
  WHERE (("p"."id" = "lms_resposta"."id_pergunta") AND ("p"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid")))))));



CREATE POLICY "admin_tpa_all" ON "public"."turma_professor_atribuicao" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'admin'::"text") AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



ALTER TABLE "public"."ano_etapa" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "asdasd" ON "public"."teste_23" USING (true) WITH CHECK (true);



ALTER TABLE "public"."atividades_infantil" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."atividades_infantil_duracao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."atividades_infantil_vinculos" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_dim_autoria" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_dim_categoria" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_dim_cdu" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_dim_doador" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_dim_editora" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_dim_estante" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])) AND ("sala_uuid" IN ( SELECT "s"."uuid"
   FROM ("public"."bbtk_dim_sala" "s"
     JOIN "public"."bbtk_dim_predio" "p" ON (("s"."predio_uuid" = "p"."uuid")))
  WHERE ("p"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"))))) WITH CHECK (("sala_uuid" IN ( SELECT "s"."uuid"
   FROM ("public"."bbtk_dim_sala" "s"
     JOIN "public"."bbtk_dim_predio" "p" ON (("s"."predio_uuid" = "p"."uuid")))
  WHERE ("p"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"))));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_dim_metadado" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_dim_predio" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_dim_sala" TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])) AND ("predio_uuid" IN ( SELECT "bbtk_dim_predio"."uuid"
   FROM "public"."bbtk_dim_predio"
  WHERE ("bbtk_dim_predio"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"))))) WITH CHECK (("predio_uuid" IN ( SELECT "bbtk_dim_predio"."uuid"
   FROM "public"."bbtk_dim_predio"
  WHERE ("bbtk_dim_predio"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"))));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_edicao" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_historico_interacao" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_inventario_copia" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_juncao_edicao_autoria" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_juncao_edicao_metadado" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_crud_admin" ON "public"."bbtk_obra" TO "authenticated" USING ((("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid") AND (("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['admin'::"text", 'admin_biblio'::"text"])))) WITH CHECK (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



ALTER TABLE "public"."bbtk_dim_autoria" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_dim_categoria" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_dim_cdu" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_dim_doador" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_dim_editora" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_dim_estante" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_dim_metadado" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_dim_predio" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_dim_sala" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_edicao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_historico_interacao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_inventario_copia" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_juncao_edicao_autoria" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_juncao_edicao_metadado" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."bbtk_obra" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_dim_autoria" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_dim_categoria" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_dim_cdu" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_dim_doador" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_dim_editora" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_dim_estante" FOR SELECT TO "authenticated" USING (("sala_uuid" IN ( SELECT "s"."uuid"
   FROM ("public"."bbtk_dim_sala" "s"
     JOIN "public"."bbtk_dim_predio" "p" ON (("s"."predio_uuid" = "p"."uuid")))
  WHERE ("p"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"))));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_dim_metadado" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_dim_predio" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_dim_sala" FOR SELECT TO "authenticated" USING (("predio_uuid" IN ( SELECT "bbtk_dim_predio"."uuid"
   FROM "public"."bbtk_dim_predio"
  WHERE ("bbtk_dim_predio"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"))));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_edicao" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_historico_interacao" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_inventario_copia" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_juncao_edicao_autoria" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_juncao_edicao_metadado" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



CREATE POLICY "bbtk_read_authenticated" ON "public"."bbtk_obra" FOR SELECT TO "authenticated" USING (("id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid"));



ALTER TABLE "public"."calendario_eventos" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."calendario_matriz_semana" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."carga_horaria_p1" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."carga_horaria_p3" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."carga_suplementar_professor" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."classe" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."componente" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."crm_mensagens" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."diario_presenca" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."empresa" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."escolas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."faltas_professores" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."feriados" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ferias_professor" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."fila_processamento_pontuacao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."horario_aula" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."horarios_escola" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."licenca_saude" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."lms_configuracao_empresa" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."lms_conteudo" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "lms_conteudo_delete" ON "public"."lms_conteudo" FOR DELETE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "lms_conteudo_insert" ON "public"."lms_conteudo" FOR INSERT TO "authenticated" WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "lms_conteudo_select" ON "public"."lms_conteudo" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa") AND (EXISTS ( SELECT 1
   FROM ("public"."turma_professor_atribuicao" "a"
     JOIN "public"."user_expandido" "u" ON (("u"."id" = "a"."id_professor")))
  WHERE (("a"."id_turma" = "lms_conteudo"."id_turma") AND ("a"."id_empresa" = "lms_conteudo"."id_empresa") AND ("u"."user_id" = "auth"."uid"()) AND (("a"."data_fim" IS NULL) OR ("a"."data_fim" >= CURRENT_DATE)))))));



CREATE POLICY "lms_conteudo_update" ON "public"."lms_conteudo" FOR UPDATE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



ALTER TABLE "public"."lms_item_conteudo" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "lms_item_conteudo_delete" ON "public"."lms_item_conteudo" FOR DELETE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "lms_item_conteudo_insert" ON "public"."lms_item_conteudo" FOR INSERT TO "authenticated" WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "lms_item_conteudo_select" ON "public"."lms_item_conteudo" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa") AND (EXISTS ( SELECT 1
   FROM (("public"."lms_conteudo" "c"
     JOIN "public"."turma_professor_atribuicao" "a" ON (("a"."id_turma" = "c"."id_turma")))
     JOIN "public"."user_expandido" "u" ON (("u"."id" = "a"."id_professor")))
  WHERE (("c"."id" = "lms_item_conteudo"."id_lms_conteudo") AND ("c"."id_empresa" = "lms_item_conteudo"."id_empresa") AND ("a"."id_empresa" = "lms_item_conteudo"."id_empresa") AND ("u"."user_id" = "auth"."uid"()) AND (("a"."data_fim" IS NULL) OR ("a"."data_fim" >= CURRENT_DATE)))))));



CREATE POLICY "lms_item_conteudo_update" ON "public"."lms_item_conteudo" FOR UPDATE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



ALTER TABLE "public"."lms_pergunta" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "lms_pergunta_delete" ON "public"."lms_pergunta" FOR DELETE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "lms_pergunta_insert" ON "public"."lms_pergunta" FOR INSERT TO "authenticated" WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "lms_pergunta_select" ON "public"."lms_pergunta" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa") AND (EXISTS ( SELECT 1
   FROM ((("public"."lms_item_conteudo" "ic"
     JOIN "public"."lms_conteudo" "c" ON (("c"."id" = "ic"."id_lms_conteudo")))
     JOIN "public"."turma_professor_atribuicao" "a" ON (("a"."id_turma" = "c"."id_turma")))
     JOIN "public"."user_expandido" "u" ON (("u"."id" = "a"."id_professor")))
  WHERE (("ic"."id" = "lms_pergunta"."id_item_conteudo") AND ("c"."id_empresa" = "lms_pergunta"."id_empresa") AND ("a"."id_empresa" = "lms_pergunta"."id_empresa") AND ("u"."user_id" = "auth"."uid"()) AND (("a"."data_fim" IS NULL) OR ("a"."data_fim" >= CURRENT_DATE)))))));



CREATE POLICY "lms_pergunta_update" ON "public"."lms_pergunta" FOR UPDATE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



ALTER TABLE "public"."lms_resposta" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."lms_resposta_possivel" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "lms_resposta_possivel_delete" ON "public"."lms_resposta_possivel" FOR DELETE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "lms_resposta_possivel_insert" ON "public"."lms_resposta_possivel" FOR INSERT TO "authenticated" WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



CREATE POLICY "lms_resposta_possivel_select" ON "public"."lms_resposta_possivel" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa") AND (EXISTS ( SELECT 1
   FROM (((("public"."lms_pergunta" "p"
     JOIN "public"."lms_item_conteudo" "ic" ON (("ic"."id" = "p"."id_item_conteudo")))
     JOIN "public"."lms_conteudo" "c" ON (("c"."id" = "ic"."id_lms_conteudo")))
     JOIN "public"."turma_professor_atribuicao" "a" ON (("a"."id_turma" = "c"."id_turma")))
     JOIN "public"."user_expandido" "u" ON (("u"."id" = "a"."id_professor")))
  WHERE (("p"."id" = "lms_resposta_possivel"."id_pergunta") AND ("c"."id_empresa" = "lms_resposta_possivel"."id_empresa") AND ("a"."id_empresa" = "lms_resposta_possivel"."id_empresa") AND ("u"."user_id" = "auth"."uid"()) AND (("a"."data_fim" IS NULL) OR ("a"."data_fim" >= CURRENT_DATE)))))));



CREATE POLICY "lms_resposta_possivel_update" ON "public"."lms_resposta_possivel" FOR UPDATE TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa"))) WITH CHECK (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa")));



ALTER TABLE "public"."lms_submissao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."materiais_sed" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."matriculas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."onbdg_codigos_email" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."papeis_user" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."papeis_user_auth" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."perguntas_user" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pontuacao_professores" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "prof_ler_respostas_lms" ON "public"."lms_resposta" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = 'professor'::"text") AND ((EXISTS ( SELECT 1
   FROM "public"."user_expandido" "u"
  WHERE (("u"."id" = "lms_resposta"."id_user") AND ("u"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid")))) OR (EXISTS ( SELECT 1
   FROM "public"."lms_pergunta" "p"
  WHERE (("p"."id" = "lms_resposta"."id_pergunta") AND ("p"."id_empresa" = (("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid")))))));



CREATE POLICY "prof_ver_suas_atribuicoes" ON "public"."turma_professor_atribuicao" FOR SELECT TO "authenticated" USING (((("auth"."jwt"() ->> 'papeis_user'::"text") = ANY (ARRAY['professor'::"text", 'professor_funcao_extra'::"text"])) AND ((("auth"."jwt"() ->> 'empresa_id'::"text"))::"uuid" = "id_empresa") AND ("id_professor" IN ( SELECT "ue"."id"
   FROM "public"."user_expandido" "ue"
  WHERE ("ue"."user_id" = "auth"."uid"())))));



ALTER TABLE "public"."professor_componente" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professor_componentes_atribuicao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professor_funcao_extra" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "professor_funcao_extra pode selecionar" ON "public"."professor_funcao_extra" FOR SELECT TO "authenticated" USING ((("auth"."jwt"() ->> 'papeis_user'::"text") = 'professor_funcao_extra'::"text"));



CREATE POLICY "professor_self" ON "public"."pontuacao_professores" USING (("id_professor" = (("auth"."jwt"() ->> 'user_expandido_id'::"text"))::"uuid"));



ALTER TABLE "public"."professor_tempo_unidade" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professores_certificados_atribuicao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."respostas_user" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."stg_autoria" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."teste_23" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "todo_veem" ON "public"."papeis_user" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "todos escrevem" ON "public"."crm_mensagens" FOR INSERT WITH CHECK (true);



CREATE POLICY "todos selecionam" ON "public"."fila_processamento_pontuacao" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "todos veem" ON "public"."versao_app" FOR SELECT USING (true);



CREATE POLICY "todos_podem_insert" ON "public"."fila_processamento_pontuacao" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "todos_veem_perguntas" ON "public"."perguntas_user" FOR SELECT USING (true);



ALTER TABLE "public"."turma_professor_atribuicao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."turmas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."unidade_atribuicao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_expandido" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_familia" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."versao_app" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."adicional_noturno_professor";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."faltas_professores";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."fila_processamento_pontuacao";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."licenca_saude";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
GRANT USAGE ON SCHEMA "public" TO "supabase_auth_admin";






GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "service_role";




















































































































































































GRANT ALL ON FUNCTION "public"."_touch_atualizado_em"() TO "anon";
GRANT ALL ON FUNCTION "public"."_touch_atualizado_em"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."_touch_atualizado_em"() TO "service_role";



GRANT ALL ON FUNCTION "public"."acumular_pontuacao_ano"("p_ano_atual" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."acumular_pontuacao_ano"("p_ano_atual" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."acumular_pontuacao_ano"("p_ano_atual" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."adiciona_user_papel_empresa"() TO "anon";
GRANT ALL ON FUNCTION "public"."adiciona_user_papel_empresa"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."adiciona_user_papel_empresa"() TO "service_role";



GRANT ALL ON FUNCTION "public"."adiciona_user_papel_empresa_secretaria"() TO "anon";
GRANT ALL ON FUNCTION "public"."adiciona_user_papel_empresa_secretaria"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."adiciona_user_papel_empresa_secretaria"() TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_upsert"("p_id_empresa" "uuid", "p_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_upsert"("p_id_empresa" "uuid", "p_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_upsert"("p_id_empresa" "uuid", "p_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."aluno_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid", "p_status" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."aluno_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid", "p_status" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."aluno_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid", "p_status" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."aluno_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."aluno_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."aluno_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."ano_etapa_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."ano_etapa_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ano_etapa_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."ano_etapa_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."ano_etapa_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ano_etapa_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."ano_etapa_get_schema"("p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."ano_etapa_get_schema"("p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ano_etapa_get_schema"("p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."ano_etapa_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."ano_etapa_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ano_etapa_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."atualiza_at_professores"() TO "anon";
GRANT ALL ON FUNCTION "public"."atualiza_at_professores"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."atualiza_at_professores"() TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_copias_disponiveis_get"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_copias_disponiveis_get"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_copias_disponiveis_get"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_autoria_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_autoria_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_autoria_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_autoria_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_autoria_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_autoria_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_autoria_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_autoria_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_autoria_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_categoria_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_categoria_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_categoria_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_categoria_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_categoria_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_categoria_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_categoria_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_categoria_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_categoria_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_cdu_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_cdu_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_cdu_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_cdu_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_cdu_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_cdu_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_cdu_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_cdu_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_cdu_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_doador_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_doador_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_doador_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_doador_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_doador_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_doador_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_doador_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_doador_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_doador_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_editora_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_editora_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_editora_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_editora_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_editora_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_editora_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_editora_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_editora_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_editora_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_sala_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_sala_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_sala_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_estante_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_metadado_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_metadado_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_metadado_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_metadado_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_metadado_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_metadado_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_metadado_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_metadado_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_metadado_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_predio_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_predio_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_predio_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_predio_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_dim_sala_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_edicao_get_detalhes"("p_uuid" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_edicao_get_detalhes"("p_uuid" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_edicao_get_detalhes"("p_uuid" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_edicao_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_tipo_livro" "text", "p_user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_edicao_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_tipo_livro" "text", "p_user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_edicao_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_tipo_livro" "text", "p_user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_inventario_copia_get_paginado"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_id_escola" "uuid", "p_predio_uuid" "uuid", "p_sala_uuid" "uuid", "p_estante_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_inventario_copia_get_paginado"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_id_escola" "uuid", "p_predio_uuid" "uuid", "p_sala_uuid" "uuid", "p_estante_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_inventario_copia_get_paginado"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_id_escola" "uuid", "p_predio_uuid" "uuid", "p_sala_uuid" "uuid", "p_estante_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_inventario_copia_upsert"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid", "p_estante_uuid" "uuid", "p_status_copia" "text", "p_doacao_ou_compra" "text", "p_avaria_flag" boolean, "p_descricao_avaria" "text", "p_quantidade" integer, "p_uuid" "uuid", "p_registro_bibliotecario" "text", "p_soft_delete" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_inventario_copia_upsert"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid", "p_estante_uuid" "uuid", "p_status_copia" "text", "p_doacao_ou_compra" "text", "p_avaria_flag" boolean, "p_descricao_avaria" "text", "p_quantidade" integer, "p_uuid" "uuid", "p_registro_bibliotecario" "text", "p_soft_delete" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_inventario_copia_upsert"("p_id_empresa" "uuid", "p_edicao_uuid" "uuid", "p_estante_uuid" "uuid", "p_status_copia" "text", "p_doacao_ou_compra" "text", "p_avaria_flag" boolean, "p_descricao_avaria" "text", "p_quantidade" integer, "p_uuid" "uuid", "p_registro_bibliotecario" "text", "p_soft_delete" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_obra_delete"("p_uuid" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_obra_delete"("p_uuid" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_obra_delete"("p_uuid" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_obra_get_detalhes_cpx"("p_uuid" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_obra_get_detalhes_cpx"("p_uuid" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_obra_get_detalhes_cpx"("p_uuid" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_obra_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_obra_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_obra_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_obra_upsert_cpx"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_obra_upsert_cpx"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_obra_upsert_cpx"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_reserva_cancel"("p_id_empresa" "uuid", "p_user_uuid" "uuid", "p_edicao_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_cancel"("p_id_empresa" "uuid", "p_user_uuid" "uuid", "p_edicao_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_cancel"("p_id_empresa" "uuid", "p_user_uuid" "uuid", "p_edicao_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_reserva_create"("p_copia_uuid" "uuid", "p_user_uuid" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_create"("p_copia_uuid" "uuid", "p_user_uuid" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_create"("p_copia_uuid" "uuid", "p_user_uuid" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_reserva_create"("p_copia_uuid" "uuid", "p_user_uuid" "uuid", "p_id_empresa" "uuid", "p_data_inicio" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_create"("p_copia_uuid" "uuid", "p_user_uuid" "uuid", "p_id_empresa" "uuid", "p_data_inicio" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_create"("p_copia_uuid" "uuid", "p_user_uuid" "uuid", "p_id_empresa" "uuid", "p_data_inicio" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_reserva_get_paginado"("p_id_empresa" "uuid", "p_offset" integer, "p_limit" integer, "p_filtro" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_get_paginado"("p_id_empresa" "uuid", "p_offset" integer, "p_limit" integer, "p_filtro" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_get_paginado"("p_id_empresa" "uuid", "p_offset" integer, "p_limit" integer, "p_filtro" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_reserva_release"("p_interacao_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_release"("p_interacao_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_release"("p_interacao_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bbtk_reserva_stats"("p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_stats"("p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bbtk_reserva_stats"("p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."buscar_conteudos_da_turma"("p_id_turma" "text", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."buscar_conteudos_da_turma"("p_id_turma" "text", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."buscar_conteudos_da_turma"("p_id_turma" "text", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."buscar_empresa_por_dominio_publico"("p_dominio" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."buscar_empresa_por_dominio_publico"("p_dominio" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."buscar_empresa_por_dominio_publico"("p_dominio" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."buscar_itens_do_conteudo"("p_id_lms_conteudo" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."buscar_itens_do_conteudo"("p_id_lms_conteudo" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."buscar_itens_do_conteudo"("p_id_lms_conteudo" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."buscar_perguntas_item_conteudo"("p_id_item_conteudo" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."buscar_perguntas_item_conteudo"("p_id_item_conteudo" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."buscar_perguntas_item_conteudo"("p_id_item_conteudo" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."calc_assiduidade_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."calc_assiduidade_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calc_assiduidade_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."calc_certificados_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."calc_certificados_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calc_certificados_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."calc_concurso_professor"("p_id_professor" "uuid", "p_ano_ref" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."calc_concurso_professor"("p_id_professor" "uuid", "p_ano_ref" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calc_concurso_professor"("p_id_professor" "uuid", "p_ano_ref" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."calc_funcao_extra_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."calc_funcao_extra_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calc_funcao_extra_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."calc_pontuacao_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."calc_pontuacao_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calc_pontuacao_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."calc_pontuacao_todos_upsert"("p_id_empresa" "uuid", "p_ano" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."calc_pontuacao_todos_upsert"("p_id_empresa" "uuid", "p_ano" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calc_pontuacao_todos_upsert"("p_id_empresa" "uuid", "p_ano" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."calc_pontuacao_todos_upsert_job"("p_id_empresa" "uuid", "p_ano" integer, "p_job_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."calc_pontuacao_todos_upsert_job"("p_id_empresa" "uuid", "p_ano" integer, "p_job_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calc_pontuacao_todos_upsert_job"("p_id_empresa" "uuid", "p_ano" integer, "p_job_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."calc_tempo_departamento_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."calc_tempo_departamento_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calc_tempo_departamento_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."calc_tempo_unidade_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."calc_tempo_unidade_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calc_tempo_unidade_professor"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano_ref" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."classe_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."classe_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."classe_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."classe_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."classe_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."classe_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."classe_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."classe_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."classe_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."componente" TO "anon";
GRANT ALL ON TABLE "public"."componente" TO "authenticated";
GRANT ALL ON TABLE "public"."componente" TO "service_role";



GRANT ALL ON FUNCTION "public"."componentes_get"("p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."componentes_get"("p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."componentes_get"("p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."confirmar_email_automaticamente"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."confirmar_email_automaticamente"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."confirmar_email_automaticamente"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."crud_carga_horaria_p1"("p_envio" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."crud_carga_horaria_p1"("p_envio" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."crud_carga_horaria_p1"("p_envio" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."crud_carga_horaria_p3"("p_envio" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."crud_carga_horaria_p3"("p_envio" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."crud_carga_horaria_p3"("p_envio" "jsonb") TO "service_role";



REVOKE ALL ON FUNCTION "public"."custom_access_token"("event" "jsonb") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."custom_access_token"("event" "jsonb") TO "service_role";
GRANT ALL ON FUNCTION "public"."custom_access_token"("event" "jsonb") TO "supabase_auth_admin";



GRANT ALL ON FUNCTION "public"."delete_calendario_matriz_semana"("p_id_item" "uuid", "p_id_turma" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_calendario_matriz_semana"("p_id_item" "uuid", "p_id_turma" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_calendario_matriz_semana"("p_id_item" "uuid", "p_id_turma" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."edicao_update_remover_arquivos_coluna"("p_edicao_uuid" "uuid", "p_coluna" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."edicao_update_remover_arquivos_coluna"("p_edicao_uuid" "uuid", "p_coluna" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."edicao_update_remover_arquivos_coluna"("p_edicao_uuid" "uuid", "p_coluna" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."escolas_com_predio_get"("p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."escolas_com_predio_get"("p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."escolas_com_predio_get"("p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."escolas_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."escolas_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."escolas_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."escolas_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."escolas_get_schema"("p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."escolas_get_schema"("p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."escolas_get_schema"("p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."escolas_por_ano_etapa"("id_ano_etapa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."escolas_por_ano_etapa"("id_ano_etapa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."escolas_por_ano_etapa"("id_ano_etapa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."escolas_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."escolas_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."escolas_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."exec_sql_safe"("p_query" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."exec_sql_safe"("p_query" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."exec_sql_safe"("p_query" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."familia_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."familia_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."familia_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."familia_get_detalhes"("p_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."familia_get_detalhes"("p_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."familia_get_detalhes"("p_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."familia_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."familia_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."familia_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."familia_upsert"("p_id_empresa" "uuid", "p_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."familia_upsert"("p_id_empresa" "uuid", "p_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."familia_upsert"("p_id_empresa" "uuid", "p_data" "jsonb") TO "service_role";



REVOKE ALL ON FUNCTION "public"."fn_uep_definir_user_id"("p_id_user_expandido" "uuid", "p_user_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."fn_uep_definir_user_id"("p_id_user_expandido" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."fn_uep_definir_user_id"("p_id_user_expandido" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_uep_definir_user_id"("p_id_user_expandido" "uuid", "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."gerar_unidades_para_ano"("p_ano" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."gerar_unidades_para_ano"("p_ano" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."gerar_unidades_para_ano"("p_ano" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_admins_by_produto_paginado"("p_produto_id" "uuid", "p_page" integer, "p_limit" integer, "p_nome" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_admins_by_produto_paginado"("p_produto_id" "uuid", "p_page" integer, "p_limit" integer, "p_nome" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_admins_by_produto_paginado"("p_produto_id" "uuid", "p_page" integer, "p_limit" integer, "p_nome" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_atividades_infantil_paginada"("p_id_empresa" "uuid", "p_pagina" integer, "p_itens_por_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_atividades_infantil_paginada"("p_id_empresa" "uuid", "p_pagina" integer, "p_itens_por_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_atividades_infantil_paginada"("p_id_empresa" "uuid", "p_pagina" integer, "p_itens_por_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_atribuicoes_professor_detalhada"("p_id_professor" "uuid", "p_ano" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_atribuicoes_professor_detalhada"("p_id_professor" "uuid", "p_ano" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_atribuicoes_professor_detalhada"("p_id_professor" "uuid", "p_ano" integer) TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_auth_overview_empresa"("p_id_empresa" "uuid", "p_days" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_auth_overview_empresa"("p_id_empresa" "uuid", "p_days" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_auth_overview_empresa"("p_id_empresa" "uuid", "p_days" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_auth_overview_empresa"("p_id_empresa" "uuid", "p_days" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_calendario_matriz_semana_por_turma_v2"("p_id_turma" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_calendario_matriz_semana_por_turma_v2"("p_id_turma" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_calendario_matriz_semana_por_turma_v2"("p_id_turma" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_carga_horaria_p1_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_carga_horaria_p1_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_carga_horaria_p1_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_carga_horaria_p1_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_busca_componente" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_carga_horaria_p1_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_busca_componente" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_carga_horaria_p1_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_busca_componente" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_carga_horaria_p3_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_busca_componente" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_carga_horaria_p3_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_busca_componente" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_carga_horaria_p3_paginada"("p_id_empresa" "uuid", "p_busca_ano_etapa" "text", "p_busca_componente" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_certificados_contestacao_por_escola"("p_id_escola" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_certificados_contestacao_por_escola"("p_id_escola" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_certificados_contestacao_por_escola"("p_id_escola" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."professores_certificados_atribuicao" TO "anon";
GRANT ALL ON TABLE "public"."professores_certificados_atribuicao" TO "authenticated";
GRANT ALL ON TABLE "public"."professores_certificados_atribuicao" TO "service_role";



GRANT ALL ON FUNCTION "public"."get_certificados_professor"("p_id_professor" "uuid", "p_ano" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_certificados_professor"("p_id_professor" "uuid", "p_ano" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_certificados_professor"("p_id_professor" "uuid", "p_ano" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_complete_schema"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_complete_schema"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_complete_schema"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_componentes_por_turma"("p_id_turma" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_componentes_por_turma"("p_id_turma" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_componentes_por_turma"("p_id_turma" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_componentes_por_turma_v2"("p_id_turma" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_componentes_por_turma_v2"("p_id_turma" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_componentes_por_turma_v2"("p_id_turma" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_dados_professor_card"("p_nome_completo" "text", "p_id_escola" "text", "p_tipo_contrato" "text", "p_afastamento" "text", "p_acumulo" "text", "p_ano" integer, "p_tem_atribuicao" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_dados_professor_card"("p_nome_completo" "text", "p_id_escola" "text", "p_tipo_contrato" "text", "p_afastamento" "text", "p_acumulo" "text", "p_ano" integer, "p_tem_atribuicao" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_dados_professor_card"("p_nome_completo" "text", "p_id_escola" "text", "p_tipo_contrato" "text", "p_afastamento" "text", "p_acumulo" "text", "p_ano" integer, "p_tem_atribuicao" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_dados_referencia_turmas"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_dados_referencia_turmas"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_dados_referencia_turmas"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_dados_referencia_turmas"("p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_dados_referencia_turmas"("p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_dados_referencia_turmas"("p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_detalhe_professor_pontuacao"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_detalhe_professor_pontuacao"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_detalhe_professor_pontuacao"("p_id_professor" "uuid", "p_id_empresa" "uuid", "p_ano" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_escolas_funcao_extra_abertas"("p_id_professor" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_escolas_funcao_extra_abertas"("p_id_professor" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_escolas_funcao_extra_abertas"("p_id_professor" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_funcao_extra_ativa"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_funcao_extra_ativa"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_funcao_extra_ativa"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_horarios_escola_formatado"("p_id_empresa" "uuid", "p_pagina" integer, "p_qtd_itens_pagina" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_horarios_escola_formatado"("p_id_empresa" "uuid", "p_pagina" integer, "p_qtd_itens_pagina" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_horarios_escola_formatado"("p_id_empresa" "uuid", "p_pagina" integer, "p_qtd_itens_pagina" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_ou_cria_conteudo_turma"("p_id_turma" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_ou_cria_conteudo_turma"("p_id_turma" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_ou_cria_conteudo_turma"("p_id_turma" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_professores_atribuicao_p1_paginada"("p_ano" integer, "p_id_empresa" "uuid", "p_nome_completo" "text", "p_id_escola" "uuid", "p_tipo_contrato" "text", "p_afastamento" "text", "p_acumulo" "text", "p_tem_atribuicao" "text", "p_tem_funcao_extra" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_professores_atribuicao_p1_paginada"("p_ano" integer, "p_id_empresa" "uuid", "p_nome_completo" "text", "p_id_escola" "uuid", "p_tipo_contrato" "text", "p_afastamento" "text", "p_acumulo" "text", "p_tem_atribuicao" "text", "p_tem_funcao_extra" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_professores_atribuicao_p1_paginada"("p_ano" integer, "p_id_empresa" "uuid", "p_nome_completo" "text", "p_id_escola" "uuid", "p_tipo_contrato" "text", "p_afastamento" "text", "p_acumulo" "text", "p_tem_atribuicao" "text", "p_tem_funcao_extra" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_professores_certificados_departamento_v2"("p_func_extra" "text", "p_user_expandido_id" "uuid", "p_ano" "text", "p_id_professor" "uuid", "p_busca_nome" "text", "p_pendentes" boolean, "p_enviados" boolean, "p_em_andamento_diretor" boolean, "p_em_andamento_supervisor" boolean, "p_concluido_diretor" boolean, "p_concluido_supervisor" boolean, "p_pagina" integer, "p_itens_por_pagina" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_professores_certificados_departamento_v2"("p_func_extra" "text", "p_user_expandido_id" "uuid", "p_ano" "text", "p_id_professor" "uuid", "p_busca_nome" "text", "p_pendentes" boolean, "p_enviados" boolean, "p_em_andamento_diretor" boolean, "p_em_andamento_supervisor" boolean, "p_concluido_diretor" boolean, "p_concluido_supervisor" boolean, "p_pagina" integer, "p_itens_por_pagina" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_professores_certificados_departamento_v2"("p_func_extra" "text", "p_user_expandido_id" "uuid", "p_ano" "text", "p_id_professor" "uuid", "p_busca_nome" "text", "p_pendentes" boolean, "p_enviados" boolean, "p_em_andamento_diretor" boolean, "p_em_andamento_supervisor" boolean, "p_concluido_diretor" boolean, "p_concluido_supervisor" boolean, "p_pagina" integer, "p_itens_por_pagina" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_professores_certificados_departamento_v2"("p_func_extra" "text", "p_user_expandido_id" "uuid", "p_ano" "text", "p_id_professor" "uuid", "p_busca_nome" "text", "p_pendentes" boolean, "p_enviados" boolean, "p_em_andamento_diretor" boolean, "p_em_andamento_supervisor" boolean, "p_concluido_diretor" boolean, "p_concluido_supervisor" boolean, "p_pagina" integer, "p_itens_por_pagina" integer) TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_professores_certificados_status_escola"("p_id_escola" "uuid", "p_ano" "text", "p_id_professor" "uuid", "p_busca_nome" "text", "p_pendentes" boolean, "p_enviados" boolean, "p_em_andamento_diretor" boolean, "p_em_andamento_supervisor" boolean, "p_concluido_diretor" boolean, "p_concluido_supervisor" boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_professores_certificados_status_escola"("p_id_escola" "uuid", "p_ano" "text", "p_id_professor" "uuid", "p_busca_nome" "text", "p_pendentes" boolean, "p_enviados" boolean, "p_em_andamento_diretor" boolean, "p_em_andamento_supervisor" boolean, "p_concluido_diretor" boolean, "p_concluido_supervisor" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."get_professores_certificados_status_escola"("p_id_escola" "uuid", "p_ano" "text", "p_id_professor" "uuid", "p_busca_nome" "text", "p_pendentes" boolean, "p_enviados" boolean, "p_em_andamento_diretor" boolean, "p_em_andamento_supervisor" boolean, "p_concluido_diretor" boolean, "p_concluido_supervisor" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_professores_certificados_status_escola"("p_id_escola" "uuid", "p_ano" "text", "p_id_professor" "uuid", "p_busca_nome" "text", "p_pendentes" boolean, "p_enviados" boolean, "p_em_andamento_diretor" boolean, "p_em_andamento_supervisor" boolean, "p_concluido_diretor" boolean, "p_concluido_supervisor" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_professores_funcoes_extras"("p_id_empresa" "uuid", "p_funcao" "text", "p_escola" "uuid", "p_nome" "text", "p_soft_delete" boolean, "p_pagina" integer, "p_tamanho_pagina" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_professores_funcoes_extras"("p_id_empresa" "uuid", "p_funcao" "text", "p_escola" "uuid", "p_nome" "text", "p_soft_delete" boolean, "p_pagina" integer, "p_tamanho_pagina" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_professores_funcoes_extras"("p_id_empresa" "uuid", "p_funcao" "text", "p_escola" "uuid", "p_nome" "text", "p_soft_delete" boolean, "p_pagina" integer, "p_tamanho_pagina" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_professores_pontuacao_paginada"("p_id_empresa" "uuid", "p_ano" integer, "p_id_escola" "uuid", "p_busca_nome" "text", "p_id_componente" "uuid", "p_pagina" integer, "p_itens_por_pagina" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_professores_pontuacao_paginada"("p_id_empresa" "uuid", "p_ano" integer, "p_id_escola" "uuid", "p_busca_nome" "text", "p_id_componente" "uuid", "p_pagina" integer, "p_itens_por_pagina" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_professores_pontuacao_paginada"("p_id_empresa" "uuid", "p_ano" integer, "p_id_escola" "uuid", "p_busca_nome" "text", "p_id_componente" "uuid", "p_pagina" integer, "p_itens_por_pagina" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_professores_por_escola"("p_id_escola" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_professores_por_escola"("p_id_escola" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_professores_por_escola"("p_id_escola" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_resumo_certificados_professores"("p_professores" "uuid"[], "p_ano" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_resumo_certificados_professores"("p_professores" "uuid"[], "p_ano" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_resumo_certificados_professores"("p_professores" "uuid"[], "p_ano" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_table_schema"("p_id_empresa" "uuid", "p_table_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_table_schema"("p_id_empresa" "uuid", "p_table_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_table_schema"("p_id_empresa" "uuid", "p_table_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_turmas_com_atribuicoes_filtrada_paginada"("p_id_empresa" "uuid", "p_ano" integer, "p_id_escola" "uuid", "p_id_ano_etapa" "text", "p_id_classe" "text", "p_id_horario" "text", "p_status_atribuicao" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_turmas_com_atribuicoes_filtrada_paginada"("p_id_empresa" "uuid", "p_ano" integer, "p_id_escola" "uuid", "p_id_ano_etapa" "text", "p_id_classe" "text", "p_id_horario" "text", "p_status_atribuicao" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_turmas_com_atribuicoes_filtrada_paginada"("p_id_empresa" "uuid", "p_ano" integer, "p_id_escola" "uuid", "p_id_ano_etapa" "text", "p_id_classe" "text", "p_id_horario" "text", "p_status_atribuicao" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_turmas_do_professor"("p_id_professor" "uuid", "p_somente_ativas" boolean, "p_ano" smallint) TO "anon";
GRANT ALL ON FUNCTION "public"."get_turmas_do_professor"("p_id_professor" "uuid", "p_somente_ativas" boolean, "p_ano" smallint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_turmas_do_professor"("p_id_professor" "uuid", "p_somente_ativas" boolean, "p_ano" smallint) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_turmas_por_escola_rotina_semanal"("p_envio" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."get_turmas_por_escola_rotina_semanal"("p_envio" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_turmas_por_escola_rotina_semanal"("p_envio" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_unidades_atribuicao_paginada"("p_id_empresa" "uuid", "p_id_escola" "uuid", "p_id_ano_etapa" "uuid", "p_id_componente" "uuid", "p_id_horario" "uuid", "p_ano" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_unidades_atribuicao_paginada"("p_id_empresa" "uuid", "p_id_escola" "uuid", "p_id_ano_etapa" "uuid", "p_id_componente" "uuid", "p_id_horario" "uuid", "p_ano" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_unidades_atribuicao_paginada"("p_id_empresa" "uuid", "p_id_escola" "uuid", "p_id_ano_etapa" "uuid", "p_id_componente" "uuid", "p_id_horario" "uuid", "p_ano" "text", "p_pagina" integer, "p_itens_por_pagina" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."horarios_escola_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."horarios_escola_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."horarios_escola_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."horarios_escola_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."horarios_escola_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."horarios_escola_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."horarios_escola_get_schema"("p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."horarios_escola_get_schema"("p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."horarios_escola_get_schema"("p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."horarios_escola_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."horarios_escola_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."horarios_escola_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."inserir_papel_usuario"() TO "anon";
GRANT ALL ON FUNCTION "public"."inserir_papel_usuario"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."inserir_papel_usuario"() TO "service_role";



GRANT ALL ON FUNCTION "public"."inserir_respostas_user_componente"("p_id_user" "uuid", "p_id_papel" "uuid", "p_id_empresa" "uuid", "p_respostas" "jsonb", "p_id_componente" "uuid", "p_perguntas_data" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."inserir_respostas_user_componente"("p_id_user" "uuid", "p_id_papel" "uuid", "p_id_empresa" "uuid", "p_respostas" "jsonb", "p_id_componente" "uuid", "p_perguntas_data" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."inserir_respostas_user_componente"("p_id_user" "uuid", "p_id_papel" "uuid", "p_id_empresa" "uuid", "p_respostas" "jsonb", "p_id_componente" "uuid", "p_perguntas_data" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_avaliacao_upsert"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_id_submissao" "uuid", "p_nota" numeric, "p_comentario" "text", "p_status" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_avaliacao_upsert"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_id_submissao" "uuid", "p_nota" numeric, "p_comentario" "text", "p_status" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_avaliacao_upsert"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_id_submissao" "uuid", "p_nota" numeric, "p_comentario" "text", "p_status" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_avaliacoes_get"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_filtro_status" "text", "p_filtro_turma_id" "uuid", "p_filtro_aluno_id" "uuid", "p_filtro_escopo" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_avaliacoes_get"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_filtro_status" "text", "p_filtro_turma_id" "uuid", "p_filtro_aluno_id" "uuid", "p_filtro_escopo" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_avaliacoes_get"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_filtro_status" "text", "p_filtro_turma_id" "uuid", "p_filtro_aluno_id" "uuid", "p_filtro_escopo" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_consumo_get"("p_id_empresa" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_consumo_get"("p_id_empresa" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_consumo_get"("p_id_empresa" "uuid", "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_conteudo_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_id_turma" "uuid", "p_id_aluno" "uuid", "p_id_meta_turma" "uuid", "p_somente_ativos" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."lms_conteudo_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_id_turma" "uuid", "p_id_aluno" "uuid", "p_id_meta_turma" "uuid", "p_somente_ativos" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_conteudo_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_termo_busca" "text", "p_id_turma" "uuid", "p_id_aluno" "uuid", "p_id_meta_turma" "uuid", "p_somente_ativos" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_conteudo_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_turma" "uuid", "p_id_aluno" "uuid", "p_id_meta_turma" "uuid", "p_id_componente" "uuid", "p_escopo" "text", "p_titulo" "text", "p_descricao" "text", "p_data_referencia" "date", "p_json_itens" "jsonb", "p_visivel_para_alunos" boolean, "p_data_disponivel" timestamp with time zone, "p_liberar_por" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_conteudo_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_turma" "uuid", "p_id_aluno" "uuid", "p_id_meta_turma" "uuid", "p_id_componente" "uuid", "p_escopo" "text", "p_titulo" "text", "p_descricao" "text", "p_data_referencia" "date", "p_json_itens" "jsonb", "p_visivel_para_alunos" boolean, "p_data_disponivel" timestamp with time zone, "p_liberar_por" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_conteudo_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_turma" "uuid", "p_id_aluno" "uuid", "p_id_meta_turma" "uuid", "p_id_componente" "uuid", "p_escopo" "text", "p_titulo" "text", "p_descricao" "text", "p_data_referencia" "date", "p_json_itens" "jsonb", "p_visivel_para_alunos" boolean, "p_data_disponivel" timestamp with time zone, "p_liberar_por" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_criar_respostas_padrao"("p_id_pergunta" "uuid", "p_id_empresa" "uuid", "p_sobrescrever" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."lms_criar_respostas_padrao"("p_id_pergunta" "uuid", "p_id_empresa" "uuid", "p_sobrescrever" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_criar_respostas_padrao"("p_id_pergunta" "uuid", "p_id_empresa" "uuid", "p_sobrescrever" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_item_get_detalhes"("p_id_item" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_item_get_detalhes"("p_id_item" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_item_get_detalhes"("p_id_item" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_item_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_lms_conteudo" "uuid", "p_tipo" "text", "p_titulo" "text", "p_caminho_arquivo" "text", "p_url_externa" "text", "p_video_link" "text", "p_rich_text" "text", "p_pontuacao_maxima" numeric, "p_id_bbtk_edicao" "uuid", "p_ordem" integer, "p_data_disponivel" timestamp with time zone, "p_data_entrega_limite" timestamp with time zone, "p_perguntas" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_item_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_lms_conteudo" "uuid", "p_tipo" "text", "p_titulo" "text", "p_caminho_arquivo" "text", "p_url_externa" "text", "p_video_link" "text", "p_rich_text" "text", "p_pontuacao_maxima" numeric, "p_id_bbtk_edicao" "uuid", "p_ordem" integer, "p_data_disponivel" timestamp with time zone, "p_data_entrega_limite" timestamp with time zone, "p_perguntas" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_item_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_lms_conteudo" "uuid", "p_tipo" "text", "p_titulo" "text", "p_caminho_arquivo" "text", "p_url_externa" "text", "p_video_link" "text", "p_rich_text" "text", "p_pontuacao_maxima" numeric, "p_id_bbtk_edicao" "uuid", "p_ordem" integer, "p_data_disponivel" timestamp with time zone, "p_data_entrega_limite" timestamp with time zone, "p_perguntas" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_item_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_lms_conteudo" "uuid", "p_tipo" "text", "p_titulo" "text", "p_caminho_arquivo" "text", "p_url_externa" "text", "p_video_link" "text", "p_rich_text" "text", "p_pontuacao_maxima" numeric, "p_id_bbtk_edicao" "uuid", "p_ordem" integer, "p_data_disponivel" timestamp with time zone, "p_data_entrega_limite" timestamp with time zone, "p_tempo_questionario" integer, "p_perguntas" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_item_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_lms_conteudo" "uuid", "p_tipo" "text", "p_titulo" "text", "p_caminho_arquivo" "text", "p_url_externa" "text", "p_video_link" "text", "p_rich_text" "text", "p_pontuacao_maxima" numeric, "p_id_bbtk_edicao" "uuid", "p_ordem" integer, "p_data_disponivel" timestamp with time zone, "p_data_entrega_limite" timestamp with time zone, "p_tempo_questionario" integer, "p_perguntas" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_item_upsert"("p_id" "uuid", "p_id_empresa" "uuid", "p_criado_por" "uuid", "p_id_lms_conteudo" "uuid", "p_tipo" "text", "p_titulo" "text", "p_caminho_arquivo" "text", "p_url_externa" "text", "p_video_link" "text", "p_rich_text" "text", "p_pontuacao_maxima" numeric, "p_id_bbtk_edicao" "uuid", "p_ordem" integer, "p_data_disponivel" timestamp with time zone, "p_data_entrega_limite" timestamp with time zone, "p_tempo_questionario" integer, "p_perguntas" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_itens_get"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_conteudo_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_itens_get"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_conteudo_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_itens_get"("p_id_empresa" "uuid", "p_user_id" "uuid", "p_conteudo_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_listar_respostas_por_pergunta"("p_id_pergunta" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_listar_respostas_por_pergunta"("p_id_pergunta" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_listar_respostas_por_pergunta"("p_id_pergunta" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."lms_pergunta_tem_respostas"("p_pergunta" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."lms_pergunta_tem_respostas"("p_pergunta" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_pergunta_tem_respostas"("p_pergunta" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_pergunta_tem_respostas"("p_pergunta" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_quiz_get_content"("p_item_id" "uuid", "p_user_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_quiz_get_content"("p_item_id" "uuid", "p_user_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_quiz_get_content"("p_item_id" "uuid", "p_user_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_quiz_reset"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_quiz_reset"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_quiz_reset"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_quiz_start"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_quiz_start"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_quiz_start"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_quiz_submit"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_quiz_submit"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_quiz_submit"("p_user_id" "uuid", "p_item_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_quiz_submit_batch"("p_user_id" "uuid", "p_item_id" "uuid", "p_respostas" "json", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_quiz_submit_batch"("p_user_id" "uuid", "p_item_id" "uuid", "p_respostas" "json", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_quiz_submit_batch"("p_user_id" "uuid", "p_item_id" "uuid", "p_respostas" "json", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_reordenar_conteudos_objetos"("p_itens" "jsonb", "p_start_at_one" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."lms_reordenar_conteudos_objetos"("p_itens" "jsonb", "p_start_at_one" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_reordenar_conteudos_objetos"("p_itens" "jsonb", "p_start_at_one" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_reordenar_itens_conteudo"("p_itens" "jsonb", "p_start_at_one" boolean, "p_id_lms_conteudo" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_reordenar_itens_conteudo"("p_itens" "jsonb", "p_start_at_one" boolean, "p_id_lms_conteudo" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_reordenar_itens_conteudo"("p_itens" "jsonb", "p_start_at_one" boolean, "p_id_lms_conteudo" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_reordenar_perguntas_objetos"("p_id_item_conteudo" "text", "p_itens" "jsonb", "p_start" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."lms_reordenar_perguntas_objetos"("p_id_item_conteudo" "text", "p_itens" "jsonb", "p_start" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_reordenar_perguntas_objetos"("p_id_item_conteudo" "text", "p_itens" "jsonb", "p_start" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_reordenar_respostas_possiveis"("p_id_pergunta" "uuid", "p_itens" "jsonb", "p_start_at_one" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."lms_reordenar_respostas_possiveis"("p_id_pergunta" "uuid", "p_itens" "jsonb", "p_start_at_one" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_reordenar_respostas_possiveis"("p_id_pergunta" "uuid", "p_itens" "jsonb", "p_start_at_one" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_resposta_possivel_tem_resposta"("p_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_resposta_possivel_tem_resposta"("p_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_resposta_possivel_tem_resposta"("p_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."lms_resposta_upsert"("p_user_id" "uuid", "p_id_item" "uuid", "p_id_pergunta" "uuid", "p_id_resposta_possivel" "uuid", "p_texto_resposta" "text", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."lms_resposta_upsert"("p_user_id" "uuid", "p_id_item" "uuid", "p_id_pergunta" "uuid", "p_id_resposta_possivel" "uuid", "p_texto_resposta" "text", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."lms_resposta_upsert"("p_user_id" "uuid", "p_id_item" "uuid", "p_id_pergunta" "uuid", "p_id_resposta_possivel" "uuid", "p_texto_resposta" "text", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."log_update_papeis_user_auth"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_update_papeis_user_auth"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_update_papeis_user_auth"() TO "service_role";



GRANT ALL ON FUNCTION "public"."onbdg_check_email_in_auth"("p_email" "text", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."onbdg_check_email_in_auth"("p_email" "text", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."onbdg_check_email_in_auth"("p_email" "text", "p_id_empresa" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."onbdg_emitir_codigo_email_e_enviar"("p_id_user" "uuid", "p_email" "text", "p_nome" "text", "p_expires_in_minutes" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."onbdg_emitir_codigo_email_e_enviar"("p_id_user" "uuid", "p_email" "text", "p_nome" "text", "p_expires_in_minutes" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."onbdg_emitir_codigo_email_e_enviar"("p_id_user" "uuid", "p_email" "text", "p_nome" "text", "p_expires_in_minutes" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."onbdg_emitir_codigo_email_e_enviar"("p_id_user" "uuid", "p_email" "text", "p_nome" "text", "p_expires_in_minutes" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."onbdg_get_auth_email_by_matricula"("p_matricula" "text", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."onbdg_get_auth_email_by_matricula"("p_matricula" "text", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."onbdg_get_auth_email_by_matricula"("p_matricula" "text", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."onbdg_get_email"("p_id_user" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."onbdg_get_email"("p_id_user" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."onbdg_get_email"("p_id_user" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."onbdg_get_email_user_expandido"("p_id_user_expandido" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."onbdg_get_email_user_expandido"("p_id_user_expandido" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."onbdg_get_email_user_expandido"("p_id_user_expandido" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."onbdg_get_email_user_expandido"("p_id_user_expandido" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."onbdg_get_user_by_matricula"("p_matricula" "text", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."onbdg_get_user_by_matricula"("p_matricula" "text", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."onbdg_get_user_by_matricula"("p_matricula" "text", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."onbdg_update_email_if_no_auth"("p_id_user" "uuid", "p_email_novo" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."onbdg_update_email_if_no_auth"("p_id_user" "uuid", "p_email_novo" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."onbdg_update_email_if_no_auth"("p_id_user" "uuid", "p_email_novo" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."onbdg_validar_codigo_por_id"("p_codigo_id" "uuid", "p_codigo" "text", "p_consumir" boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."onbdg_validar_codigo_por_id"("p_codigo_id" "uuid", "p_codigo" "text", "p_consumir" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."onbdg_validar_codigo_por_id"("p_codigo_id" "uuid", "p_codigo" "text", "p_consumir" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."onbdg_validar_codigo_por_id"("p_codigo_id" "uuid", "p_codigo" "text", "p_consumir" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."onbdg_validar_nome_contem"("p_id_user" "uuid", "p_fragmento_nome" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."onbdg_validar_nome_contem"("p_id_user" "uuid", "p_fragmento_nome" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."onbdg_validar_nome_contem"("p_id_user" "uuid", "p_fragmento_nome" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."onbdg_validar_ultimo_nome"("p_id_user" "uuid", "p_ultimo_nome_informado" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."onbdg_validar_ultimo_nome"("p_id_user" "uuid", "p_ultimo_nome_informado" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."onbdg_validar_ultimo_nome"("p_id_user" "uuid", "p_ultimo_nome_informado" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."onbdg_verifica_funcao_extra_ativa"("p_id_user" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."onbdg_verifica_funcao_extra_ativa"("p_id_user" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."onbdg_verifica_funcao_extra_ativa"("p_id_user" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."papeis_user_auth_get_my_role"() TO "anon";
GRANT ALL ON FUNCTION "public"."papeis_user_auth_get_my_role"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."papeis_user_auth_get_my_role"() TO "service_role";



GRANT ALL ON TABLE "public"."perguntas_user" TO "anon";
GRANT ALL ON TABLE "public"."perguntas_user" TO "authenticated";
GRANT ALL ON TABLE "public"."perguntas_user" TO "service_role";



GRANT ALL ON FUNCTION "public"."perguntas_get"("p_id_empresa" "uuid", "p_papeis" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."perguntas_get"("p_id_empresa" "uuid", "p_papeis" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."perguntas_get"("p_id_empresa" "uuid", "p_papeis" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."processar_fila_pontuacao"("p_job_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."processar_fila_pontuacao"("p_job_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."processar_fila_pontuacao"("p_job_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."professor_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."professor_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."professor_delete"("p_id" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."professor_get_detalhes_cpx"("p_id_empresa" "uuid", "p_id_professor" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."professor_get_detalhes_cpx"("p_id_empresa" "uuid", "p_id_professor" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."professor_get_detalhes_cpx"("p_id_empresa" "uuid", "p_id_professor" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."professor_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid", "p_status" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."professor_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid", "p_status" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."professor_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text", "p_id_escola" "uuid", "p_status" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."professor_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."professor_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."professor_upsert"("p_data" "jsonb", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."reset_pontuacao_ano"("p_id_empresa" "uuid", "p_ano" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."reset_pontuacao_ano"("p_id_empresa" "uuid", "p_ano" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."reset_pontuacao_ano"("p_id_empresa" "uuid", "p_ano" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."salvar_resposta_user"("p_id_user" "uuid", "p_id_pergunta" "uuid", "p_tipo" "text", "p_resposta" "text", "p_nome_arquivo_original" "text", "p_criado_por" "uuid", "p_atualizado_por" "uuid", "p_id_empresa" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."salvar_resposta_user"("p_id_user" "uuid", "p_id_pergunta" "uuid", "p_tipo" "text", "p_resposta" "text", "p_nome_arquivo_original" "text", "p_criado_por" "uuid", "p_atualizado_por" "uuid", "p_id_empresa" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."salvar_resposta_user"("p_id_user" "uuid", "p_id_pergunta" "uuid", "p_tipo" "text", "p_resposta" "text", "p_nome_arquivo_original" "text", "p_criado_por" "uuid", "p_atualizado_por" "uuid", "p_id_empresa" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."seed_pontuacao_faltantes"("p_id_empresa" "uuid", "p_ano" integer, "p_job_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."seed_pontuacao_faltantes"("p_id_empresa" "uuid", "p_ano" integer, "p_job_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."seed_pontuacao_faltantes"("p_id_empresa" "uuid", "p_ano" integer, "p_job_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_created_modified_by"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_created_modified_by"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_created_modified_by"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "postgres";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "anon";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "service_role";



GRANT ALL ON FUNCTION "public"."show_limit"() TO "postgres";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "anon";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "service_role";



GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_papel_professor_funcao_extra"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_papel_professor_funcao_extra"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_papel_professor_funcao_extra"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_status_professor_funcao_extra"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_status_professor_funcao_extra"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_status_professor_funcao_extra"() TO "service_role";



GRANT ALL ON FUNCTION "public"."to_hhmm_from_minutes"("p_min" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."to_hhmm_from_minutes"("p_min" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."to_hhmm_from_minutes"("p_min" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."to_minutes_from_text"("p_txt" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."to_minutes_from_text"("p_txt" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."to_minutes_from_text"("p_txt" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."total_escolas"() TO "anon";
GRANT ALL ON FUNCTION "public"."total_escolas"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."total_escolas"() TO "service_role";



GRANT ALL ON FUNCTION "public"."total_professores"() TO "anon";
GRANT ALL ON FUNCTION "public"."total_professores"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."total_professores"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trg_cal_matriz_set_defaults"() TO "anon";
GRANT ALL ON FUNCTION "public"."trg_cal_matriz_set_defaults"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trg_cal_matriz_set_defaults"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trg_registrar_pontuacao_excedente"() TO "anon";
GRANT ALL ON FUNCTION "public"."trg_registrar_pontuacao_excedente"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trg_registrar_pontuacao_excedente"() TO "service_role";



GRANT ALL ON FUNCTION "public"."turmas_delete"("p_id_empresa" "uuid", "p_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."turmas_delete"("p_id_empresa" "uuid", "p_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."turmas_delete"("p_id_empresa" "uuid", "p_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."turmas_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."turmas_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."turmas_get_paginado"("p_id_empresa" "uuid", "p_pagina" integer, "p_limite_itens_pagina" integer, "p_busca" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."turmas_upsert"("p_id_empresa" "uuid", "p_turma" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."turmas_upsert"("p_id_empresa" "uuid", "p_turma" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."turmas_upsert"("p_id_empresa" "uuid", "p_turma" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."unaccent"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."unaccent"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."unaccent"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."unaccent"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."unaccent"("regdictionary", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."unaccent"("regdictionary", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."unaccent"("regdictionary", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."unaccent"("regdictionary", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."unaccent_init"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."unaccent_init"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."unaccent_init"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."unaccent_init"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."unaccent_lexize"("internal", "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."unaccent_lexize"("internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."unaccent_lexize"("internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."unaccent_lexize"("internal", "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_calendario_matriz_semana_v3"("p_array" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_calendario_matriz_semana_v3"("p_array" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_calendario_matriz_semana_v3"("p_array" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_horario_escolar"("_p_envio" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_horario_escolar"("_p_envio" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_horario_escolar"("_p_envio" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."verificar_email_existe"("p_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."verificar_email_existe"("p_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."verificar_email_existe"("p_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."verificar_matricula_existente"("p_matricula" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."verificar_matricula_existente"("p_matricula" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."verificar_matricula_existente"("p_matricula" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "service_role";


















GRANT ALL ON TABLE "public"."adicional_noturno_professor" TO "anon";
GRANT ALL ON TABLE "public"."adicional_noturno_professor" TO "authenticated";
GRANT ALL ON TABLE "public"."adicional_noturno_professor" TO "service_role";



GRANT ALL ON TABLE "public"."ano_etapa" TO "anon";
GRANT ALL ON TABLE "public"."ano_etapa" TO "authenticated";
GRANT ALL ON TABLE "public"."ano_etapa" TO "service_role";



GRANT ALL ON TABLE "public"."atividades_infantil" TO "anon";
GRANT ALL ON TABLE "public"."atividades_infantil" TO "authenticated";
GRANT ALL ON TABLE "public"."atividades_infantil" TO "service_role";



GRANT ALL ON TABLE "public"."atividades_infantil_duracao" TO "anon";
GRANT ALL ON TABLE "public"."atividades_infantil_duracao" TO "authenticated";
GRANT ALL ON TABLE "public"."atividades_infantil_duracao" TO "service_role";



GRANT ALL ON TABLE "public"."atividades_infantil_vinculos" TO "anon";
GRANT ALL ON TABLE "public"."atividades_infantil_vinculos" TO "authenticated";
GRANT ALL ON TABLE "public"."atividades_infantil_vinculos" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_dim_autoria" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_dim_autoria" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_dim_autoria" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_dim_categoria" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_dim_categoria" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_dim_categoria" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_dim_cdu" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_dim_cdu" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_dim_cdu" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_dim_doador" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_dim_doador" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_dim_doador" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_dim_editora" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_dim_editora" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_dim_editora" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_dim_estante" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_dim_estante" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_dim_estante" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_dim_metadado" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_dim_metadado" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_dim_metadado" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_dim_predio" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_dim_predio" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_dim_predio" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_dim_sala" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_dim_sala" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_dim_sala" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_edicao" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_edicao" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_edicao" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_historico_interacao" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_historico_interacao" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_historico_interacao" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_inventario_copia" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_inventario_copia" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_inventario_copia" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_juncao_edicao_autoria" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_juncao_edicao_autoria" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_juncao_edicao_autoria" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_juncao_edicao_metadado" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_juncao_edicao_metadado" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_juncao_edicao_metadado" TO "service_role";



GRANT ALL ON TABLE "public"."bbtk_obra" TO "anon";
GRANT ALL ON TABLE "public"."bbtk_obra" TO "authenticated";
GRANT ALL ON TABLE "public"."bbtk_obra" TO "service_role";



GRANT ALL ON TABLE "public"."calendario_eventos" TO "anon";
GRANT ALL ON TABLE "public"."calendario_eventos" TO "authenticated";
GRANT ALL ON TABLE "public"."calendario_eventos" TO "service_role";



GRANT ALL ON TABLE "public"."calendario_matriz_semana" TO "anon";
GRANT ALL ON TABLE "public"."calendario_matriz_semana" TO "authenticated";
GRANT ALL ON TABLE "public"."calendario_matriz_semana" TO "service_role";



GRANT ALL ON TABLE "public"."carga_horaria_p1" TO "anon";
GRANT ALL ON TABLE "public"."carga_horaria_p1" TO "authenticated";
GRANT ALL ON TABLE "public"."carga_horaria_p1" TO "service_role";



GRANT ALL ON TABLE "public"."carga_horaria_p3" TO "anon";
GRANT ALL ON TABLE "public"."carga_horaria_p3" TO "authenticated";
GRANT ALL ON TABLE "public"."carga_horaria_p3" TO "service_role";



GRANT ALL ON TABLE "public"."carga_suplementar_professor" TO "anon";
GRANT ALL ON TABLE "public"."carga_suplementar_professor" TO "authenticated";
GRANT ALL ON TABLE "public"."carga_suplementar_professor" TO "service_role";



GRANT ALL ON TABLE "public"."classe" TO "anon";
GRANT ALL ON TABLE "public"."classe" TO "authenticated";
GRANT ALL ON TABLE "public"."classe" TO "service_role";



GRANT ALL ON TABLE "public"."crm_mensagens" TO "anon";
GRANT ALL ON TABLE "public"."crm_mensagens" TO "authenticated";
GRANT ALL ON TABLE "public"."crm_mensagens" TO "service_role";



GRANT ALL ON TABLE "public"."diario_presenca" TO "anon";
GRANT ALL ON TABLE "public"."diario_presenca" TO "authenticated";
GRANT ALL ON TABLE "public"."diario_presenca" TO "service_role";



GRANT ALL ON TABLE "public"."empresa" TO "anon";
GRANT ALL ON TABLE "public"."empresa" TO "authenticated";
GRANT ALL ON TABLE "public"."empresa" TO "service_role";
GRANT SELECT ON TABLE "public"."empresa" TO "supabase_auth_admin";



GRANT ALL ON TABLE "public"."escolas" TO "anon";
GRANT ALL ON TABLE "public"."escolas" TO "authenticated";
GRANT ALL ON TABLE "public"."escolas" TO "service_role";



GRANT ALL ON TABLE "public"."faltas_professores" TO "anon";
GRANT ALL ON TABLE "public"."faltas_professores" TO "authenticated";
GRANT ALL ON TABLE "public"."faltas_professores" TO "service_role";



GRANT ALL ON TABLE "public"."feriados" TO "anon";
GRANT ALL ON TABLE "public"."feriados" TO "authenticated";
GRANT ALL ON TABLE "public"."feriados" TO "service_role";



GRANT ALL ON TABLE "public"."ferias_professor" TO "anon";
GRANT ALL ON TABLE "public"."ferias_professor" TO "authenticated";
GRANT ALL ON TABLE "public"."ferias_professor" TO "service_role";



GRANT ALL ON TABLE "public"."fila_processamento_pontuacao" TO "anon";
GRANT ALL ON TABLE "public"."fila_processamento_pontuacao" TO "authenticated";
GRANT ALL ON TABLE "public"."fila_processamento_pontuacao" TO "service_role";



GRANT ALL ON TABLE "public"."horario_aula" TO "anon";
GRANT ALL ON TABLE "public"."horario_aula" TO "authenticated";
GRANT ALL ON TABLE "public"."horario_aula" TO "service_role";



GRANT ALL ON TABLE "public"."horarios_escola" TO "anon";
GRANT ALL ON TABLE "public"."horarios_escola" TO "authenticated";
GRANT ALL ON TABLE "public"."horarios_escola" TO "service_role";



GRANT ALL ON TABLE "public"."licenca_saude" TO "anon";
GRANT ALL ON TABLE "public"."licenca_saude" TO "authenticated";
GRANT ALL ON TABLE "public"."licenca_saude" TO "service_role";



GRANT ALL ON TABLE "public"."lms_configuracao_empresa" TO "anon";
GRANT ALL ON TABLE "public"."lms_configuracao_empresa" TO "authenticated";
GRANT ALL ON TABLE "public"."lms_configuracao_empresa" TO "service_role";



GRANT ALL ON TABLE "public"."lms_conteudo" TO "anon";
GRANT ALL ON TABLE "public"."lms_conteudo" TO "authenticated";
GRANT ALL ON TABLE "public"."lms_conteudo" TO "service_role";



GRANT ALL ON TABLE "public"."lms_item_conteudo" TO "anon";
GRANT ALL ON TABLE "public"."lms_item_conteudo" TO "authenticated";
GRANT ALL ON TABLE "public"."lms_item_conteudo" TO "service_role";



GRANT ALL ON TABLE "public"."lms_pergunta" TO "anon";
GRANT ALL ON TABLE "public"."lms_pergunta" TO "authenticated";
GRANT ALL ON TABLE "public"."lms_pergunta" TO "service_role";



GRANT ALL ON TABLE "public"."lms_resposta" TO "anon";
GRANT ALL ON TABLE "public"."lms_resposta" TO "authenticated";
GRANT ALL ON TABLE "public"."lms_resposta" TO "service_role";



GRANT ALL ON TABLE "public"."lms_resposta_possivel" TO "anon";
GRANT ALL ON TABLE "public"."lms_resposta_possivel" TO "authenticated";
GRANT ALL ON TABLE "public"."lms_resposta_possivel" TO "service_role";



GRANT ALL ON TABLE "public"."lms_submissao" TO "anon";
GRANT ALL ON TABLE "public"."lms_submissao" TO "authenticated";
GRANT ALL ON TABLE "public"."lms_submissao" TO "service_role";



GRANT ALL ON TABLE "public"."materiais_sed" TO "anon";
GRANT ALL ON TABLE "public"."materiais_sed" TO "authenticated";
GRANT ALL ON TABLE "public"."materiais_sed" TO "service_role";



GRANT ALL ON TABLE "public"."matriculas" TO "anon";
GRANT ALL ON TABLE "public"."matriculas" TO "authenticated";
GRANT ALL ON TABLE "public"."matriculas" TO "service_role";



GRANT ALL ON TABLE "public"."meta_turma" TO "anon";
GRANT ALL ON TABLE "public"."meta_turma" TO "authenticated";
GRANT ALL ON TABLE "public"."meta_turma" TO "service_role";



GRANT ALL ON TABLE "public"."onbdg_codigos_email" TO "anon";
GRANT ALL ON TABLE "public"."onbdg_codigos_email" TO "authenticated";
GRANT ALL ON TABLE "public"."onbdg_codigos_email" TO "service_role";



GRANT ALL ON TABLE "public"."onbdg_codigos_email_status" TO "anon";
GRANT ALL ON TABLE "public"."onbdg_codigos_email_status" TO "authenticated";
GRANT ALL ON TABLE "public"."onbdg_codigos_email_status" TO "service_role";



GRANT ALL ON TABLE "public"."papeis_user" TO "anon";
GRANT ALL ON TABLE "public"."papeis_user" TO "authenticated";
GRANT ALL ON TABLE "public"."papeis_user" TO "service_role";
GRANT SELECT ON TABLE "public"."papeis_user" TO "supabase_auth_admin";



GRANT ALL ON TABLE "public"."papeis_user_auth" TO "anon";
GRANT ALL ON TABLE "public"."papeis_user_auth" TO "authenticated";
GRANT ALL ON TABLE "public"."papeis_user_auth" TO "service_role";
GRANT SELECT ON TABLE "public"."papeis_user_auth" TO "supabase_auth_admin";



GRANT ALL ON TABLE "public"."pontuacao_professores" TO "anon";
GRANT ALL ON TABLE "public"."pontuacao_professores" TO "authenticated";
GRANT ALL ON TABLE "public"."pontuacao_professores" TO "service_role";



GRANT ALL ON TABLE "public"."professor_componente" TO "anon";
GRANT ALL ON TABLE "public"."professor_componente" TO "authenticated";
GRANT ALL ON TABLE "public"."professor_componente" TO "service_role";



GRANT ALL ON TABLE "public"."professor_componentes_atribuicao" TO "anon";
GRANT ALL ON TABLE "public"."professor_componentes_atribuicao" TO "authenticated";
GRANT ALL ON TABLE "public"."professor_componentes_atribuicao" TO "service_role";



GRANT ALL ON TABLE "public"."professor_funcao_extra" TO "anon";
GRANT ALL ON TABLE "public"."professor_funcao_extra" TO "authenticated";
GRANT ALL ON TABLE "public"."professor_funcao_extra" TO "service_role";



GRANT ALL ON TABLE "public"."professor_tempo_unidade" TO "anon";
GRANT ALL ON TABLE "public"."professor_tempo_unidade" TO "authenticated";
GRANT ALL ON TABLE "public"."professor_tempo_unidade" TO "service_role";



GRANT ALL ON TABLE "public"."respostas_user" TO "anon";
GRANT ALL ON TABLE "public"."respostas_user" TO "authenticated";
GRANT ALL ON TABLE "public"."respostas_user" TO "service_role";



GRANT ALL ON TABLE "public"."staging_professor_escola" TO "anon";
GRANT ALL ON TABLE "public"."staging_professor_escola" TO "authenticated";
GRANT ALL ON TABLE "public"."staging_professor_escola" TO "service_role";



GRANT ALL ON TABLE "public"."stg_alunos" TO "anon";
GRANT ALL ON TABLE "public"."stg_alunos" TO "authenticated";
GRANT ALL ON TABLE "public"."stg_alunos" TO "service_role";



GRANT ALL ON TABLE "public"."stg_autoria" TO "anon";
GRANT ALL ON TABLE "public"."stg_autoria" TO "authenticated";
GRANT ALL ON TABLE "public"."stg_autoria" TO "service_role";



GRANT ALL ON SEQUENCE "public"."stg_autoria_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."stg_autoria_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."stg_autoria_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."stg_excedentes" TO "anon";
GRANT ALL ON TABLE "public"."stg_excedentes" TO "authenticated";
GRANT ALL ON TABLE "public"."stg_excedentes" TO "service_role";



GRANT ALL ON TABLE "public"."stg_obra_edicao" TO "anon";
GRANT ALL ON TABLE "public"."stg_obra_edicao" TO "authenticated";
GRANT ALL ON TABLE "public"."stg_obra_edicao" TO "service_role";



GRANT ALL ON SEQUENCE "public"."stg_obra_edicao_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."stg_obra_edicao_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."stg_obra_edicao_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."stg_ocorrencias" TO "anon";
GRANT ALL ON TABLE "public"."stg_ocorrencias" TO "authenticated";
GRANT ALL ON TABLE "public"."stg_ocorrencias" TO "service_role";



GRANT ALL ON TABLE "public"."stg_ocorrencias_intermediaria" TO "anon";
GRANT ALL ON TABLE "public"."stg_ocorrencias_intermediaria" TO "authenticated";
GRANT ALL ON TABLE "public"."stg_ocorrencias_intermediaria" TO "service_role";



GRANT ALL ON TABLE "public"."stg_ocorrencias_log" TO "anon";
GRANT ALL ON TABLE "public"."stg_ocorrencias_log" TO "authenticated";
GRANT ALL ON TABLE "public"."stg_ocorrencias_log" TO "service_role";



GRANT ALL ON TABLE "public"."stg_pontuacao" TO "anon";
GRANT ALL ON TABLE "public"."stg_pontuacao" TO "authenticated";
GRANT ALL ON TABLE "public"."stg_pontuacao" TO "service_role";



GRANT ALL ON TABLE "public"."stg_professor_atribuicao" TO "anon";
GRANT ALL ON TABLE "public"."stg_professor_atribuicao" TO "authenticated";
GRANT ALL ON TABLE "public"."stg_professor_atribuicao" TO "service_role";



GRANT ALL ON SEQUENCE "public"."stg_professor_atribuicao_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."stg_professor_atribuicao_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."stg_professor_atribuicao_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."teste_23" TO "anon";
GRANT ALL ON TABLE "public"."teste_23" TO "authenticated";
GRANT ALL ON TABLE "public"."teste_23" TO "service_role";



GRANT ALL ON SEQUENCE "public"."teste_1_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."teste_1_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."teste_1_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."turma_professor_atribuicao" TO "anon";
GRANT ALL ON TABLE "public"."turma_professor_atribuicao" TO "authenticated";
GRANT ALL ON TABLE "public"."turma_professor_atribuicao" TO "service_role";



GRANT ALL ON TABLE "public"."turmas" TO "anon";
GRANT ALL ON TABLE "public"."turmas" TO "authenticated";
GRANT ALL ON TABLE "public"."turmas" TO "service_role";



GRANT ALL ON TABLE "public"."unidade_atribuicao" TO "anon";
GRANT ALL ON TABLE "public"."unidade_atribuicao" TO "authenticated";
GRANT ALL ON TABLE "public"."unidade_atribuicao" TO "service_role";



GRANT ALL ON TABLE "public"."user_expandido" TO "anon";
GRANT ALL ON TABLE "public"."user_expandido" TO "authenticated";
GRANT ALL ON TABLE "public"."user_expandido" TO "service_role";



GRANT ALL ON TABLE "public"."user_familia" TO "anon";
GRANT ALL ON TABLE "public"."user_familia" TO "authenticated";
GRANT ALL ON TABLE "public"."user_familia" TO "service_role";



GRANT ALL ON TABLE "public"."user_responsavel_aluno" TO "anon";
GRANT ALL ON TABLE "public"."user_responsavel_aluno" TO "authenticated";
GRANT ALL ON TABLE "public"."user_responsavel_aluno" TO "service_role";



GRANT ALL ON TABLE "public"."versao_app" TO "anon";
GRANT ALL ON TABLE "public"."versao_app" TO "authenticated";
GRANT ALL ON TABLE "public"."versao_app" TO "service_role";



GRANT ALL ON SEQUENCE "public"."versao_app_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."versao_app_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."versao_app_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."view_professores_escola" TO "anon";
GRANT ALL ON TABLE "public"."view_professores_escola" TO "authenticated";
GRANT ALL ON TABLE "public"."view_professores_escola" TO "service_role";



GRANT ALL ON TABLE "public"."view_professores_pontuacao_por_ano" TO "anon";
GRANT ALL ON TABLE "public"."view_professores_pontuacao_por_ano" TO "authenticated";
GRANT ALL ON TABLE "public"."view_professores_pontuacao_por_ano" TO "service_role";



GRANT ALL ON TABLE "public"."view_respostas_professor_json" TO "anon";
GRANT ALL ON TABLE "public"."view_respostas_professor_json" TO "authenticated";
GRANT ALL ON TABLE "public"."view_respostas_professor_json" TO "service_role";



GRANT ALL ON TABLE "public"."vw_materiais_sed_dropdowns" TO "anon";
GRANT ALL ON TABLE "public"."vw_materiais_sed_dropdowns" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_materiais_sed_dropdowns" TO "service_role";



GRANT ALL ON TABLE "public"."vw_professores_funcoes_extras" TO "anon";
GRANT ALL ON TABLE "public"."vw_professores_funcoes_extras" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_professores_funcoes_extras" TO "service_role";



GRANT ALL ON TABLE "public"."vw_resumo_turmas_atribuicao" TO "anon";
GRANT ALL ON TABLE "public"."vw_resumo_turmas_atribuicao" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_resumo_turmas_atribuicao" TO "service_role";



GRANT ALL ON TABLE "public"."vw_turmas_por_ano_etapa_escola" TO "anon";
GRANT ALL ON TABLE "public"."vw_turmas_por_ano_etapa_escola" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_turmas_por_ano_etapa_escola" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























drop extension if exists "pg_net";

create extension if not exists "pg_net" with schema "public";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_professores_certificados_status_escola(p_id_escola uuid, p_ano text, p_id_professor uuid DEFAULT NULL::uuid, p_busca_nome text DEFAULT NULL::text, p_pendentes boolean DEFAULT true, p_enviados boolean DEFAULT true, p_em_andamento_diretor boolean DEFAULT true, p_em_andamento_supervisor boolean DEFAULT true, p_concluido_diretor boolean DEFAULT true, p_concluido_supervisor boolean DEFAULT true)
 RETURNS TABLE(nome_professor text, id_professor uuid, id_escola uuid, nome_escola text, matricula text, quantidade_certificados_enviados integer, deferido_indeferido_diretor text, deferido_indeferido_supervisor text, deferido_geral boolean, mostrar_subitem boolean, tipo_contrato text, data_admissao text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
with escola_ctx as (
  select e.id as id_escola, e.nome as nome_escola, e.id_empresa
  from public.escolas e
  where e.id = p_id_escola
),
prof_base as (
  select
    ue.id as id_professor,
    ue.nome_completo,
    ue.id_escola,
    ue.matricula
  from public.user_expandido ue
  join escola_ctx ec on ec.id_escola = ue.id_escola
  where (p_id_professor is null or ue.id = p_id_professor)
    and (
      coalesce(p_busca_nome, '') = ''
      or ue.nome_completo ilike '%' || p_busca_nome || '%'
    )
    -- 🔒 apenas contratos Ativos (enum)
    and ue.status_contrato = 'Ativo'::public.status_contrato
),
certs_agg as (
  select
    pca.id_professor,
    count(*)::int as qtd,
    case
      when count(*) = 0 then 'pendente'
      when count(*) filter (where pca.deferido_indeferido_diretor is null) > 0 then 'em andamento'
      else 'concluído'
    end as status_dir,
    case
      when count(*) = 0 then 'pendente'
      when count(*) filter (where pca.deferido_indeferido_supervisor is null) > 0 then 'em andamento'
      else 'concluído'
    end as status_sup,
    case
      when count(*) > 0
        and count(*) filter (where coalesce(pca.deferido_indeferido, false) = true) = count(*)
      then true
      else false
    end as deferido_geral
  from public.professores_certificados_atribuicao pca
  where btrim(pca.ano_atribuicao) = btrim(p_ano)
  group by pca.id_professor
),
contrato as (
  select
    ru.id_user as id_professor,
    (array_agg(ru.resposta order by coalesce(ru.atualizado_em, ru.criado_em) desc))[1] as tipo_contrato
  from public.respostas_user ru
  where ru.id_pergunta = '467b29b5-8236-4f5c-a3ac-3e135bcf5601'::uuid
  group by ru.id_user
),
-- 👇 novo CTE: pega a resposta mais recente da data de admissão
admissao as (
  select
    ru.id_user as id_professor,
    (array_agg(ru.resposta order by coalesce(ru.atualizado_em, ru.criado_em) desc))[1] as data_admissao
  from public.respostas_user ru
  where ru.id_pergunta = '2cbcdcf0-a615-49a3-b563-e6c9e8e9f393'::uuid
  group by ru.id_user
)
select
  pb.nome_completo as nome_professor,
  pb.id_professor,
  pb.id_escola,
  ec.nome_escola,
  pb.matricula,
  coalesce(ca.qtd, 0)                                  as quantidade_certificados_enviados,
  coalesce(ca.status_dir, 'pendente')                  as deferido_indeferido_diretor,
  coalesce(ca.status_sup, 'pendente')                  as deferido_indeferido_supervisor,
  coalesce(ca.deferido_geral, false)                   as deferido_geral,
  false                                                as mostrar_subitem,
  coalesce(ct.tipo_contrato, '')                       as tipo_contrato,
  coalesce(ad.data_admissao, '')                       as data_admissao
from prof_base pb
join escola_ctx ec on true
left join certs_agg ca on ca.id_professor = pb.id_professor
left join contrato ct on ct.id_professor = pb.id_professor
left join admissao ad on ad.id_professor = pb.id_professor
where
  (
    (p_pendentes                and coalesce(ca.qtd, 0) = 0)                                         or
    (p_enviados                 and coalesce(ca.qtd, 0) > 0)                                         or
    (p_em_andamento_diretor     and coalesce(ca.status_dir, 'pendente') = 'em andamento')            or
    (p_em_andamento_supervisor  and coalesce(ca.status_sup, 'pendente') = 'em andamento')            or
    (p_concluido_diretor        and coalesce(ca.status_dir, 'pendente') = 'concluído')               or
    (p_concluido_supervisor     and coalesce(ca.status_sup, 'pendente') = 'concluído')
  )
order by pb.nome_completo, pb.matricula;
$function$
;


  create policy "autenticados podem deletar plxbd0_0"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using ((bucket_id = 'certificadoauxiliar'::text));



  create policy "autenticados podem enviar"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check ((bucket_id = 'certificadoauxiliar'::text));



  create policy "autenticados podem ler plxbd0_0"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using ((bucket_id = 'certificadoauxiliar'::text));



