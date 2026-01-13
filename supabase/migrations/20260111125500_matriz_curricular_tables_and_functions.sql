-- Migration: Matriz Curricular Tables and Functions
-- Date: 2026-01-11
-- Description: Creates tables for mtz_modelo_calendario, mtz_calendario_anual, mtz_matriz_curricular and their associated CRUD functions.

-- 1. Tables

-- 1.1 mtz_modelo_calendario
CREATE TABLE IF NOT EXISTS public.mtz_modelo_calendario (
    id uuid NOT NULL DEFAULT gen_random_uuid (),
    nome text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT mtz_modelo_calendario_pkey PRIMARY KEY (id)
) TABLESPACE pg_default;

ALTER TABLE public.mtz_modelo_calendario OWNER to postgres;

-- Seed Data
INSERT INTO
    public.mtz_modelo_calendario (nome)
VALUES
    ('Bimestral'),
    ('Trimestral'),
    ('Semestral') ON CONFLICT DO NOTHING;

-- 1.2 mtz_calendario_anual
CREATE TABLE IF NOT EXISTS public.mtz_calendario_anual (
    id uuid NOT NULL DEFAULT gen_random_uuid (),
    id_empresa uuid NOT NULL,
    id_ano_etapa uuid NOT NULL,
    id_modelo_calendario uuid NOT NULL,
    ano integer NOT NULL,
    numero_periodo integer NOT NULL,
    data_inicio date,
    data_fim date,
    criado_por uuid,
    criado_em timestamp
    with
        time zone DEFAULT now (),
        modificado_por uuid,
        modificado_em timestamp
    with
        time zone DEFAULT now (),
        CONSTRAINT mtz_calendario_anual_pkey PRIMARY KEY (id),
        CONSTRAINT mtz_calendario_anual_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_calendario_anual_ano_etapa_fkey FOREIGN KEY (id_ano_etapa) REFERENCES public.ano_etapa (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_calendario_anual_modelo_fkey FOREIGN KEY (id_modelo_calendario) REFERENCES public.mtz_modelo_calendario (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE RESTRICT,
        CONSTRAINT mtz_calendario_anual_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
        CONSTRAINT mtz_calendario_anual_modificado_por_fkey FOREIGN KEY (modificado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
) TABLESPACE pg_default;

ALTER TABLE public.mtz_calendario_anual OWNER to postgres;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_mtz_calendario_anual_id_empresa ON public.mtz_calendario_anual (id_empresa);

CREATE INDEX IF NOT EXISTS idx_mtz_calendario_anual_id_ano_etapa ON public.mtz_calendario_anual (id_ano_etapa);

-- 1.3 mtz_matriz_curricular
CREATE TABLE IF NOT EXISTS public.mtz_matriz_curricular (
    id uuid NOT NULL DEFAULT gen_random_uuid (),
    id_empresa uuid NOT NULL,
    id_ano_etapa uuid NOT NULL,
    ano integer NOT NULL,
    dia_semana integer NOT NULL,
    aula integer NOT NULL,
    id_componente uuid NOT NULL,
    criado_por uuid,
    criado_em timestamp
    with
        time zone DEFAULT now (),
        modificado_por uuid,
        modificado_em timestamp
    with
        time zone DEFAULT now (),
        CONSTRAINT mtz_matriz_curricular_pkey PRIMARY KEY (id),
        CONSTRAINT mtz_matriz_curricular_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_matriz_curricular_ano_etapa_fkey FOREIGN KEY (id_ano_etapa) REFERENCES public.ano_etapa (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_matriz_curricular_componente_fkey FOREIGN KEY (id_componente) REFERENCES public.componente (uuid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
        CONSTRAINT mtz_matriz_curricular_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
        CONSTRAINT mtz_matriz_curricular_modificado_por_fkey FOREIGN KEY (modificado_por) REFERENCES public.user_expandido (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
) TABLESPACE pg_default;

ALTER TABLE public.mtz_matriz_curricular OWNER to postgres;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_mtz_matriz_curr_id_empresa ON public.mtz_matriz_curricular (id_empresa);

CREATE INDEX IF NOT EXISTS idx_mtz_matriz_curr_id_ano_etapa ON public.mtz_matriz_curricular (id_ano_etapa);


-- 2. Functions

-- 2.1 mtz_modelo_calendario_get
CREATE OR REPLACE FUNCTION public.mtz_modelo_calendario_get()
RETURNS json
LANGUAGE plpgsql
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_itens json;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT id, nome
        FROM public.mtz_modelo_calendario
        ORDER BY nome ASC
    ) t;

    RETURN v_itens;
END;
$BODY$;

ALTER FUNCTION public.mtz_modelo_calendario_get() OWNER TO postgres;

-- 2.2 mtz_calendario_anual_get_paginado
CREATE OR REPLACE FUNCTION public.mtz_calendario_anual_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text)
    RETURNS json
    LANGUAGE plpgsql
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    -- 1. Calcular Offset
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- 2. Calcular Total de Itens
    SELECT COUNT(*) INTO v_total_itens
    FROM public.mtz_calendario_anual
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR CAST(ano AS TEXT) LIKE v_busca_like
        );

    -- 3. Calcular Total de Páginas
    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    -- 4. Buscar Itens Paginados
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT *
        FROM public.mtz_calendario_anual
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR CAST(ano AS TEXT) LIKE v_busca_like
            )
        ORDER BY ano DESC, numero_periodo ASC
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
$BODY$;

ALTER FUNCTION public.mtz_calendario_anual_get_paginado(uuid, integer, integer, text) OWNER TO postgres;

-- 2.3 mtz_calendario_anual_upsert
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
    v_user_id := (p_data ->> 'id_usuario')::uuid; -- Expecting user ID in payload for audit

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.mtz_calendario_anual as t (
        id, 
        id_empresa, 
        id_ano_etapa,
        id_modelo_calendario,
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

-- 2.4 mtz_calendario_anual_delete
CREATE OR REPLACE FUNCTION public.mtz_calendario_anual_delete(
    p_id uuid,
    p_id_empresa uuid
)
returns jsonb
language plpgsql
security definer
set search_path to public
as $$
declare
    v_deleted_count integer;
begin
    delete from public.mtz_calendario_anual
    where id = p_id
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
ALTER FUNCTION public.mtz_calendario_anual_delete(uuid, uuid) OWNER TO postgres;

-- 2.5 mtz_matriz_curricular_get_paginado
CREATE OR REPLACE FUNCTION public.mtz_matriz_curricular_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text)
    RETURNS json
    LANGUAGE plpgsql
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    SELECT COUNT(*) INTO v_total_itens
    FROM public.mtz_matriz_curricular
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR CAST(ano AS TEXT) LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT *
        FROM public.mtz_matriz_curricular
        WHERE 
            id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR CAST(ano AS TEXT) LIKE v_busca_like
            )
        ORDER BY ano DESC, dia_semana ASC, aula ASC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$BODY$;

ALTER FUNCTION public.mtz_matriz_curricular_get_paginado(uuid, integer, integer, text) OWNER TO postgres;

-- 2.6 mtz_matriz_curricular_upsert
CREATE OR REPLACE FUNCTION public.mtz_matriz_curricular_upsert(
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
    v_registro_salvo public.mtz_matriz_curricular;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.mtz_matriz_curricular as t (
        id, 
        id_empresa, 
        id_ano_etapa,
        ano,
        dia_semana,
        aula,
        id_componente,
        criado_por,
        criado_em,
        modificado_por,
        modificado_em
    )
    values (
        v_id,
        p_id_empresa,
        (p_data ->> 'id_ano_etapa')::uuid,
        (p_data ->> 'ano')::integer,
        (p_data ->> 'dia_semana')::integer,
        (p_data ->> 'aula')::integer,
        (p_data ->> 'id_componente')::uuid,
        v_user_id,
        now(),
        v_user_id,
        now()
    )
    on conflict (id) do update 
    set 
        id_ano_etapa = coalesce((excluded.id_ano_etapa), t.id_ano_etapa),
        ano = coalesce((excluded.ano), t.ano),
        dia_semana = coalesce((excluded.dia_semana), t.dia_semana),
        aula = coalesce((excluded.aula), t.aula),
        id_componente = coalesce((excluded.id_componente), t.id_componente),
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
ALTER FUNCTION public.mtz_matriz_curricular_upsert(jsonb, uuid) OWNER TO postgres;

-- 2.7 mtz_matriz_curricular_delete
CREATE OR REPLACE FUNCTION public.mtz_matriz_curricular_delete(
    p_id uuid,
    p_id_empresa uuid
)
returns jsonb
language plpgsql
security definer
set search_path to public
as $$
declare
    v_deleted_count integer;
begin
    -- Verificacao de dependencias (Placeholder - adicione constraints especificas se houver)
    -- Exemplo: IF EXISTS (SELECT 1 FROM tabela_filha WHERE pai_id = p_id) THEN ...
    
    delete from public.mtz_matriz_curricular
    where id = p_id
      and id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Registro deletado com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Registro não encontrado, não pertence à empresa ou possui dependências.', 'id', p_id);
    end if;

exception when others then
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;
ALTER FUNCTION public.mtz_matriz_curricular_delete(uuid, uuid) OWNER TO postgres;
