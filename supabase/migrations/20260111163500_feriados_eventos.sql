-- Migration: Create Feriados and Eventos Tables and Functions
-- Date: 2026-01-11
-- Description: Adds tables for holidays and events (mtz_feriados, mtz_eventos), their lookup enum, associated functions, and permissions.

BEGIN;

-- 1. Create Enum
DROP TYPE IF EXISTS public.tipo_escopo_evento;
CREATE TYPE public.tipo_escopo_evento AS ENUM ('Rede', 'Ano_Etapa');
ALTER TYPE public.tipo_escopo_evento OWNER TO postgres;

-- 2. Create Tables

-- mtz_feriados
CREATE TABLE IF NOT EXISTS public.mtz_feriados
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    nome_feriado text COLLATE pg_catalog."default" NOT NULL,
    tipo text COLLATE pg_catalog."default" NOT NULL,
    data_inicio date NOT NULL,
    data_fim date NOT NULL,
    criado_por uuid,
    criado_em timestamp with time zone DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT mtz_feriados_pkey PRIMARY KEY (id),
    CONSTRAINT mtz_feriados_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT mtz_feriados_criado_por_fkey FOREIGN KEY (criado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT mtz_feriados_modificado_por_fkey FOREIGN KEY (modificado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
) TABLESPACE pg_default;
ALTER TABLE public.mtz_feriados OWNER to postgres;
CREATE INDEX IF NOT EXISTS idx_mtz_feriados_id_empresa ON public.mtz_feriados (id_empresa);
CREATE INDEX IF NOT EXISTS idx_mtz_feriados_data ON public.mtz_feriados (data_inicio);

-- mtz_eventos
CREATE TABLE IF NOT EXISTS public.mtz_eventos
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    nome_evento text COLLATE pg_catalog."default" NOT NULL,
    escopo tipo_escopo_evento NOT NULL,
    id_ano_etapa uuid,
    data_inicio date NOT NULL,
    data_fim date NOT NULL,
    criado_por uuid,
    criado_em timestamp with time zone DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT mtz_eventos_pkey PRIMARY KEY (id),
    CONSTRAINT mtz_eventos_empresa_fkey FOREIGN KEY (id_empresa)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT mtz_eventos_ano_etapa_fkey FOREIGN KEY (id_ano_etapa)
        REFERENCES public.ano_etapa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT mtz_eventos_criado_por_fkey FOREIGN KEY (criado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT mtz_eventos_modificado_por_fkey FOREIGN KEY (modificado_por)
        REFERENCES public.user_expandido (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
) TABLESPACE pg_default;
ALTER TABLE public.mtz_eventos OWNER to postgres;
CREATE INDEX IF NOT EXISTS idx_mtz_eventos_id_empresa ON public.mtz_eventos (id_empresa);
CREATE INDEX IF NOT EXISTS idx_mtz_eventos_id_ano_etapa ON public.mtz_eventos (id_ano_etapa);
CREATE INDEX IF NOT EXISTS idx_mtz_eventos_data ON public.mtz_eventos (data_inicio);

-- 3. Create Functions

-- mtz_feriados_upsert
CREATE OR REPLACE FUNCTION public.mtz_feriados_upsert(p_data jsonb, p_id_empresa uuid)
returns jsonb language plpgsql security definer set search_path to public as $$
declare
    v_id uuid;
    v_registro_salvo public.mtz_feriados;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.mtz_feriados as t (id, id_empresa, nome_feriado, tipo, data_inicio, data_fim, criado_por, criado_em, modificado_por, modificado_em)
    values (v_id, p_id_empresa, p_data ->> 'nome_feriado', p_data ->> 'tipo', (p_data ->> 'data_inicio')::date, (p_data ->> 'data_fim')::date, v_user_id, now(), v_user_id, now())
    on conflict (id) do update 
    set nome_feriado = coalesce(excluded.nome_feriado, t.nome_feriado),
        tipo = coalesce(excluded.tipo, t.tipo),
        data_inicio = coalesce(excluded.data_inicio, t.data_inicio),
        data_fim = coalesce(excluded.data_fim, t.data_fim),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;
ALTER FUNCTION public.mtz_feriados_upsert(jsonb, uuid) OWNER TO postgres;

-- mtz_feriados_delete
CREATE OR REPLACE FUNCTION public.mtz_feriados_delete(p_id uuid, p_id_empresa uuid)
returns jsonb language plpgsql security definer set search_path to public as $$
declare
    v_deleted_count integer;
begin
    delete from public.mtz_feriados where id = p_id and id_empresa = p_id_empresa;
    get diagnostics v_deleted_count = ROW_COUNT;
    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Feriado deletado com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Feriado não encontrado ou não pertence à empresa.', 'id', p_id);
    end if;
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;
ALTER FUNCTION public.mtz_feriados_delete(uuid, uuid) OWNER TO postgres;

-- mtz_feriados_get_paginado
CREATE OR REPLACE FUNCTION public.mtz_feriados_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text)
    RETURNS json LANGUAGE plpgsql COST 100 VOLATILE PARALLEL UNSAFE AS $BODY$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;
    SELECT COUNT(*) INTO v_total_itens FROM public.mtz_feriados
    WHERE id_empresa = p_id_empresa AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(nome_feriado) LIKE v_busca_like);
    IF p_limite_itens_pagina > 0 THEN v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina); ELSE v_total_paginas := 0; END IF;
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens FROM (
        SELECT * FROM public.mtz_feriados
        WHERE id_empresa = p_id_empresa AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(nome_feriado) LIKE v_busca_like)
        ORDER BY data_inicio ASC LIMIT p_limite_itens_pagina OFFSET v_offset
    ) t;
    RETURN json_build_object('qtd_itens', v_total_itens, 'qtd_paginas', v_total_paginas, 'itens', v_itens);
END;
$BODY$;
ALTER FUNCTION public.mtz_feriados_get_paginado(uuid, integer, integer, text) OWNER TO postgres;

-- mtz_eventos_upsert
CREATE OR REPLACE FUNCTION public.mtz_eventos_upsert(p_data jsonb, p_id_empresa uuid)
returns jsonb language plpgsql security definer set search_path to public as $$
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

    insert into public.mtz_eventos as t (id, id_empresa, nome_evento, escopo, id_ano_etapa, data_inicio, data_fim, criado_por, criado_em, modificado_por, modificado_em)
    values (v_id, p_id_empresa, p_data ->> 'nome_evento', (p_data ->> 'escopo')::tipo_escopo_evento, (p_data ->> 'id_ano_etapa')::uuid, (p_data ->> 'data_inicio')::date, (p_data ->> 'data_fim')::date, v_user_id, now(), v_user_id, now())
    on conflict (id) do update 
    set nome_evento = coalesce(excluded.nome_evento, t.nome_evento),
        escopo = coalesce(excluded.escopo, t.escopo),
        id_ano_etapa = excluded.id_ano_etapa,
        data_inicio = coalesce(excluded.data_inicio, t.data_inicio),
        data_fim = coalesce(excluded.data_fim, t.data_fim),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;
ALTER FUNCTION public.mtz_eventos_upsert(jsonb, uuid) OWNER TO postgres;

-- mtz_eventos_delete
CREATE OR REPLACE FUNCTION public.mtz_eventos_delete(p_id uuid, p_id_empresa uuid)
returns jsonb language plpgsql security definer set search_path to public as $$
declare
    v_deleted_count integer;
begin
    delete from public.mtz_eventos where id = p_id and id_empresa = p_id_empresa;
    get diagnostics v_deleted_count = ROW_COUNT;
    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Evento deletado com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Evento não encontrado ou não pertence à empresa.', 'id', p_id);
    end if;
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$$;
ALTER FUNCTION public.mtz_eventos_delete(uuid, uuid) OWNER TO postgres;

-- mtz_eventos_get_paginado
CREATE OR REPLACE FUNCTION public.mtz_eventos_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text,
    p_id_ano_etapa uuid DEFAULT NULL)
    RETURNS json LANGUAGE plpgsql COST 100 VOLATILE PARALLEL UNSAFE AS $BODY$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;
    SELECT COUNT(*) INTO v_total_itens FROM public.mtz_eventos
    WHERE id_empresa = p_id_empresa
      AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(nome_evento) LIKE v_busca_like)
      AND (p_id_ano_etapa IS NULL OR id_ano_etapa = p_id_ano_etapa OR escopo = 'Rede');

    IF p_limite_itens_pagina > 0 THEN v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina); ELSE v_total_paginas := 0; END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens FROM (
        SELECT * FROM public.mtz_eventos
        WHERE id_empresa = p_id_empresa
          AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(nome_evento) LIKE v_busca_like)
          AND (p_id_ano_etapa IS NULL OR id_ano_etapa = p_id_ano_etapa OR escopo = 'Rede')
        ORDER BY data_inicio ASC LIMIT p_limite_itens_pagina OFFSET v_offset
    ) t;

    RETURN json_build_object('qtd_itens', v_total_itens, 'qtd_paginas', v_total_paginas, 'itens', v_itens);
END;
$BODY$;
ALTER FUNCTION public.mtz_eventos_get_paginado(uuid, integer, integer, text, uuid) OWNER TO postgres;

-- 4. Permissions

-- Tables
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.mtz_feriados TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.mtz_feriados TO service_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.mtz_eventos TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.mtz_eventos TO service_role;

-- Functions
GRANT EXECUTE ON FUNCTION public.mtz_feriados_upsert(jsonb, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mtz_feriados_upsert(jsonb, uuid) TO service_role;

GRANT EXECUTE ON FUNCTION public.mtz_feriados_delete(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mtz_feriados_delete(uuid, uuid) TO service_role;

GRANT EXECUTE ON FUNCTION public.mtz_feriados_get_paginado(uuid, integer, integer, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mtz_feriados_get_paginado(uuid, integer, integer, text) TO service_role;

GRANT EXECUTE ON FUNCTION public.mtz_eventos_upsert(jsonb, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mtz_eventos_upsert(jsonb, uuid) TO service_role;

GRANT EXECUTE ON FUNCTION public.mtz_eventos_delete(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mtz_eventos_delete(uuid, uuid) TO service_role;

GRANT EXECUTE ON FUNCTION public.mtz_eventos_get_paginado(uuid, integer, integer, text, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mtz_eventos_get_paginado(uuid, integer, integer, text, uuid) TO service_role;

COMMIT;
