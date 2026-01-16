-- Migration for Avaliacao Module
-- Tables: avaliacao_modelo, avaliacao_grupo, avaliacao_criterio, itens_criterio, itens_avaliacao

-- 1. Table: avaliacao_modelo
CREATE TABLE IF NOT EXISTS public.avaliacao_modelo (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    nome_modelo text NOT NULL,
    criado_por uuid DEFAULT auth.uid(),
    criado_em timestamptz DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamptz,
    CONSTRAINT avaliacao_modelo_pkey PRIMARY KEY (id),
    CONSTRAINT avaliacao_modelo_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id),
    CONSTRAINT avaliacao_modelo_criado_por_fk FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id),
    CONSTRAINT avaliacao_modelo_modificado_por_fk FOREIGN KEY (modificado_por) REFERENCES public.user_expandido(id)
);

-- 2. Table: avaliacao_grupo
CREATE TABLE IF NOT EXISTS public.avaliacao_grupo (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_modelo_avaliacao uuid NOT NULL,
    nome_grupo text NOT NULL,
    peso_grupo int,
    criado_por uuid,
    criado_em timestamptz DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamptz,
    CONSTRAINT avaliacao_grupo_pkey PRIMARY KEY (id),
    CONSTRAINT avaliacao_grupo_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id),
    CONSTRAINT avaliacao_grupo_modelo_fk FOREIGN KEY (id_modelo_avaliacao) REFERENCES public.avaliacao_modelo(id) ON DELETE CASCADE,
    CONSTRAINT avaliacao_grupo_criado_por_fk FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id),
    CONSTRAINT avaliacao_grupo_modificado_por_fk FOREIGN KEY (modificado_por) REFERENCES public.user_expandido(id)
);

-- 3. Table: avaliacao_criterio
CREATE TABLE IF NOT EXISTS public.avaliacao_criterio (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    nome_modelo_criterio text NOT NULL,
    tipo_modelo_criterio text NOT NULL, -- 'CONCEITUAL' or 'NUMERICO'
    criado_por uuid,
    criado_em timestamptz DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamptz,
    CONSTRAINT avaliacao_criterio_pkey PRIMARY KEY (id),
    CONSTRAINT avaliacao_criterio_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id),
    CONSTRAINT avaliacao_criterio_criado_por_fk FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id),
    CONSTRAINT avaliacao_criterio_modificado_por_fk FOREIGN KEY (modificado_por) REFERENCES public.user_expandido(id)
);

-- 4. Table: itens_criterio
CREATE TABLE IF NOT EXISTS public.itens_criterio (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_modelo_criterio uuid NOT NULL,
    rotulo text NOT NULL,
    valor_numerico numeric,
    criado_por uuid,
    criado_em timestamptz DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamptz,
    CONSTRAINT itens_criterio_pkey PRIMARY KEY (id),
    CONSTRAINT itens_criterio_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id),
    CONSTRAINT itens_criterio_criterio_fk FOREIGN KEY (id_modelo_criterio) REFERENCES public.avaliacao_criterio(id) ON DELETE CASCADE,
    CONSTRAINT itens_criterio_criado_por_fk FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id),
    CONSTRAINT itens_criterio_modificado_por_fk FOREIGN KEY (modificado_por) REFERENCES public.user_expandido(id)
);

-- 5. Table: itens_avaliacao
CREATE TABLE IF NOT EXISTS public.itens_avaliacao (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_grupo uuid NOT NULL,
    id_modelo_criterio uuid NOT NULL,
    texto_pergunta text NOT NULL,
    peso_item int,
    criado_por uuid,
    criado_em timestamptz DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamptz,
    CONSTRAINT itens_avaliacao_pkey PRIMARY KEY (id),
    CONSTRAINT itens_avaliacao_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id),
    CONSTRAINT itens_avaliacao_grupo_fk FOREIGN KEY (id_grupo) REFERENCES public.avaliacao_grupo(id) ON DELETE CASCADE,
    CONSTRAINT itens_avaliacao_criterio_fk FOREIGN KEY (id_modelo_criterio) REFERENCES public.avaliacao_criterio(id),
    CONSTRAINT itens_avaliacao_criado_por_fk FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id),
    CONSTRAINT itens_avaliacao_modificado_por_fk FOREIGN KEY (modificado_por) REFERENCES public.user_expandido(id)
);

-- Enable RLS
ALTER TABLE public.avaliacao_modelo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.avaliacao_grupo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.avaliacao_criterio ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_criterio ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_avaliacao ENABLE ROW LEVEL SECURITY;

-- RLS Policies (Admin All)
CREATE POLICY "Admin All Modelo" ON public.avaliacao_modelo FOR ALL TO authenticated USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)) WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa));
CREATE POLICY "Admin All Grupo" ON public.avaliacao_grupo FOR ALL TO authenticated USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)) WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa));
CREATE POLICY "Admin All Criterio" ON public.avaliacao_criterio FOR ALL TO authenticated USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)) WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa));
CREATE POLICY "Admin All Itens Criterio" ON public.itens_criterio FOR ALL TO authenticated USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)) WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa));
CREATE POLICY "Admin All Itens Avaliacao" ON public.itens_avaliacao FOR ALL TO authenticated USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)) WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa));

-- Functions

-- 1. avaliacao_modelo
CREATE OR REPLACE FUNCTION public.avaliacao_modelo_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_id uuid;
    v_registro_salvo public.avaliacao_modelo;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    insert into public.avaliacao_modelo as t (
        id, id_empresa, nome_modelo, criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        p_data ->> 'nome_modelo',
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
    on conflict (id) do update 
    set nome_modelo = coalesce(excluded.nome_modelo, t.nome_modelo),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$function$;
ALTER FUNCTION public.avaliacao_modelo_upsert(jsonb, uuid) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.avaliacao_modelo_get_paginado(
    p_id_empresa uuid, 
    p_pagina integer DEFAULT 1, 
    p_limite_itens_pagina integer DEFAULT 10, 
    p_busca text DEFAULT ''::text
)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;
    SELECT COUNT(*) INTO v_total_itens FROM public.avaliacao_modelo
    WHERE id_empresa = p_id_empresa
      AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(nome_modelo) LIKE v_busca_like);

    IF p_limite_itens_pagina > 0 THEN v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina); ELSE v_total_paginas := 0; END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens FROM (
        SELECT p.*
        FROM public.avaliacao_modelo p
        WHERE p.id_empresa = p_id_empresa
          AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(p.nome_modelo) LIKE v_busca_like)
        ORDER BY p.modificado_em DESC 
        LIMIT p_limite_itens_pagina OFFSET v_offset
    ) t;

    RETURN json_build_object('qtd_itens', v_total_itens, 'qtd_paginas', v_total_paginas, 'itens', v_itens);
END;
$function$;
ALTER FUNCTION public.avaliacao_modelo_get_paginado(uuid, integer, integer, text) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.avaliacao_modelo_delete(p_id uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
    DELETE FROM public.avaliacao_modelo WHERE id = p_id AND id_empresa = p_id_empresa;
    if found then return jsonb_build_object('status', 'success'); else return jsonb_build_object('status', 'error', 'message', 'Modelo não encontrado.'); end if;
end;
$function$;
ALTER FUNCTION public.avaliacao_modelo_delete(uuid, uuid) OWNER TO postgres;

-- 2. avaliacao_grupo
CREATE OR REPLACE FUNCTION public.avaliacao_grupo_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_id uuid;
    v_registro_salvo public.avaliacao_grupo;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    insert into public.avaliacao_grupo as t (
        id, id_empresa, id_modelo_avaliacao, nome_grupo, peso_grupo, criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        (p_data ->> 'id_modelo_avaliacao')::uuid,
        p_data ->> 'nome_grupo',
        (p_data ->> 'peso_grupo')::int,
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
    on conflict (id) do update 
    set nome_grupo = coalesce(excluded.nome_grupo, t.nome_grupo),
        peso_grupo = coalesce(excluded.peso_grupo, t.peso_grupo),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$function$;
ALTER FUNCTION public.avaliacao_grupo_upsert(jsonb, uuid) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.avaliacao_grupo_get_by_modelo(p_id_modelo uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_itens jsonb;
BEGIN
    SELECT jsonb_agg(t ORDER BY t.criado_em ASC) INTO v_itens
    FROM public.avaliacao_grupo t
    WHERE t.id_modelo_avaliacao = p_id_modelo AND t.id_empresa = p_id_empresa;
    RETURN coalesce(v_itens, '[]'::jsonb);
END;
$function$;
ALTER FUNCTION public.avaliacao_grupo_get_by_modelo(uuid, uuid) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.avaliacao_grupo_delete(p_id uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
    DELETE FROM public.avaliacao_grupo WHERE id = p_id AND id_empresa = p_id_empresa;
    if found then return jsonb_build_object('status', 'success'); else return jsonb_build_object('status', 'error', 'message', 'Grupo não encontrado.'); end if;
end;
$function$;
ALTER FUNCTION public.avaliacao_grupo_delete(uuid, uuid) OWNER TO postgres;

-- 3. avaliacao_criterio
CREATE OR REPLACE FUNCTION public.avaliacao_criterio_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_id uuid;
    v_registro_salvo public.avaliacao_criterio;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    insert into public.avaliacao_criterio as t (
        id, id_empresa, nome_modelo_criterio, tipo_modelo_criterio, criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        p_data ->> 'nome_modelo_criterio',
        p_data ->> 'tipo_modelo_criterio',
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
    on conflict (id) do update 
    set nome_modelo_criterio = coalesce(excluded.nome_modelo_criterio, t.nome_modelo_criterio),
        tipo_modelo_criterio = coalesce(excluded.tipo_modelo_criterio, t.tipo_modelo_criterio),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$function$;
ALTER FUNCTION public.avaliacao_criterio_upsert(jsonb, uuid) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.avaliacao_criterio_get_paginado(
    p_id_empresa uuid, 
    p_pagina integer DEFAULT 1, 
    p_limite_itens_pagina integer DEFAULT 10, 
    p_busca text DEFAULT ''::text,
    p_tipo text DEFAULT NULL
)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;
    SELECT COUNT(*) INTO v_total_itens FROM public.avaliacao_criterio
    WHERE id_empresa = p_id_empresa
      AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(nome_modelo_criterio) LIKE v_busca_like)
      AND (p_tipo IS NULL OR tipo_modelo_criterio = p_tipo);

    IF p_limite_itens_pagina > 0 THEN v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina); ELSE v_total_paginas := 0; END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens FROM (
        SELECT p.*
        FROM public.avaliacao_criterio p
        WHERE p.id_empresa = p_id_empresa
          AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(p.nome_modelo_criterio) LIKE v_busca_like)
          AND (p_tipo IS NULL OR p.tipo_modelo_criterio = p_tipo)
        ORDER BY p.modificado_em DESC 
        LIMIT p_limite_itens_pagina OFFSET v_offset
    ) t;

    RETURN json_build_object('qtd_itens', v_total_itens, 'qtd_paginas', v_total_paginas, 'itens', v_itens);
END;
$function$;
ALTER FUNCTION public.avaliacao_criterio_get_paginado(uuid, integer, integer, text, text) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.avaliacao_criterio_delete(p_id uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
    DELETE FROM public.avaliacao_criterio WHERE id = p_id AND id_empresa = p_id_empresa;
    if found then return jsonb_build_object('status', 'success'); else return jsonb_build_object('status', 'error', 'message', 'Criterio não encontrado.'); end if;
end;
$function$;
ALTER FUNCTION public.avaliacao_criterio_delete(uuid, uuid) OWNER TO postgres;

-- 4. itens_criterio
CREATE OR REPLACE FUNCTION public.itens_criterio_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_id uuid;
    v_registro_salvo public.itens_criterio;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    insert into public.itens_criterio as t (
        id, id_empresa, id_modelo_criterio, rotulo, valor_numerico, criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        (p_data ->> 'id_modelo_criterio')::uuid,
        p_data ->> 'rotulo',
        (p_data ->> 'valor_numerico')::numeric,
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
    on conflict (id) do update 
    set rotulo = coalesce(excluded.rotulo, t.rotulo),
        valor_numerico = coalesce(excluded.valor_numerico, t.valor_numerico),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$function$;
ALTER FUNCTION public.itens_criterio_upsert(jsonb, uuid) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.itens_criterio_get_by_criterio(p_id_criterio uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_itens jsonb;
BEGIN
    SELECT jsonb_agg(t ORDER BY t.valor_numerico DESC, t.rotulo ASC) INTO v_itens
    FROM public.itens_criterio t
    WHERE t.id_modelo_criterio = p_id_criterio AND t.id_empresa = p_id_empresa;
    RETURN coalesce(v_itens, '[]'::jsonb);
END;
$function$;
ALTER FUNCTION public.itens_criterio_get_by_criterio(uuid, uuid) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.itens_criterio_delete(p_id uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
    DELETE FROM public.itens_criterio WHERE id = p_id AND id_empresa = p_id_empresa;
    if found then return jsonb_build_object('status', 'success'); else return jsonb_build_object('status', 'error', 'message', 'Item não encontrado.'); end if;
end;
$function$;
ALTER FUNCTION public.itens_criterio_delete(uuid, uuid) OWNER TO postgres;

-- 5. itens_avaliacao
CREATE OR REPLACE FUNCTION public.itens_avaliacao_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_id uuid;
    v_registro_salvo public.itens_avaliacao;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    insert into public.itens_avaliacao as t (
        id, id_empresa, id_grupo, id_modelo_criterio, texto_pergunta, peso_item, criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        (p_data ->> 'id_grupo')::uuid,
        (p_data ->> 'id_modelo_criterio')::uuid,
        p_data ->> 'texto_pergunta',
        (p_data ->> 'peso_item')::int,
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
    on conflict (id) do update 
    set texto_pergunta = coalesce(excluded.texto_pergunta, t.texto_pergunta),
        peso_item = coalesce(excluded.peso_item, t.peso_item),
        id_modelo_criterio = coalesce(excluded.id_modelo_criterio, t.id_modelo_criterio),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$function$;
ALTER FUNCTION public.itens_avaliacao_upsert(jsonb, uuid) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.itens_avaliacao_get_by_grupo(p_id_grupo uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_itens jsonb;
BEGIN
    SELECT jsonb_agg(row_to_json(t) ORDER BY t.criado_em ASC) INTO v_itens
    FROM (
        SELECT i.*, c.nome_modelo_criterio
        FROM public.itens_avaliacao i
        JOIN public.avaliacao_criterio c ON c.id = i.id_modelo_criterio
        WHERE i.id_grupo = p_id_grupo AND i.id_empresa = p_id_empresa
    ) t;
    RETURN coalesce(v_itens, '[]'::jsonb);
END;
$function$;
ALTER FUNCTION public.itens_avaliacao_get_by_grupo(uuid, uuid) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.itens_avaliacao_delete(p_id uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
    DELETE FROM public.itens_avaliacao WHERE id = p_id AND id_empresa = p_id_empresa;
    if found then return jsonb_build_object('status', 'success'); else return jsonb_build_object('status', 'error', 'message', 'Questão não encontrada.'); end if;
end;
$function$;
ALTER FUNCTION public.itens_avaliacao_delete(uuid, uuid) OWNER TO postgres;
