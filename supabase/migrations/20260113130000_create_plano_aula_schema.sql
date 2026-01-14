-- Migration for Plano de Aula Module
-- Tables: pl_plano_de_aulas, pl_plano_de_aulas_itens, pl_plano_referencias
-- RLS and Functions included

-- 1. Table: pl_plano_de_aulas
CREATE TABLE IF NOT EXISTS public.pl_plano_de_aulas (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_componente uuid NOT NULL,
    id_ano_etapa uuid NOT NULL,
    titulo text NOT NULL,
    descricao text,
    criado_por uuid,
    criado_em timestamp with time zone DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT pl_plano_de_aulas_pkey PRIMARY KEY (id),
    CONSTRAINT pl_plano_de_aulas_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id),
    CONSTRAINT pl_plano_de_aulas_componente_fk FOREIGN KEY (id_componente) REFERENCES public.componente(uuid),
    CONSTRAINT pl_plano_de_aulas_ano_etapa_fk FOREIGN KEY (id_ano_etapa) REFERENCES public.ano_etapa(id),
    CONSTRAINT pl_plano_de_aulas_criado_por_fk FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id),
    CONSTRAINT pl_plano_de_aulas_modificado_por_fk FOREIGN KEY (modificado_por) REFERENCES public.user_expandido(id)
);

-- 2. Table: pl_plano_de_aulas_itens
CREATE TABLE IF NOT EXISTS public.pl_plano_de_aulas_itens (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_plano_de_aula uuid NOT NULL,
    aula_numero integer NOT NULL,
    conteudo text,
    metodologia text,
    tarefa text,
    criado_por uuid,
    criado_em timestamp with time zone DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT pl_plano_de_aulas_itens_pkey PRIMARY KEY (id),
    CONSTRAINT pl_plano_de_aulas_itens_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id),
    CONSTRAINT pl_plano_de_aulas_itens_plano_fk FOREIGN KEY (id_plano_de_aula) REFERENCES public.pl_plano_de_aulas(id) ON DELETE CASCADE,
    CONSTRAINT pl_plano_de_aulas_itens_criado_por_fk FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id),
    CONSTRAINT pl_plano_de_aulas_itens_modificado_por_fk FOREIGN KEY (modificado_por) REFERENCES public.user_expandido(id)
);

-- 3. Table: pl_plano_referencias
CREATE TABLE IF NOT EXISTS public.pl_plano_referencias (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_plano_aula_item uuid NOT NULL,
    id_edicao_biblioteca uuid, -- Link to bbtk_edicao
    usa_biblioteca_rede boolean DEFAULT false,
    descricao_manual text,
    criado_por uuid,
    criado_em timestamp with time zone DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT pl_plano_referencias_pkey PRIMARY KEY (id),
    CONSTRAINT pl_plano_referencias_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id),
    CONSTRAINT pl_plano_referencias_item_fk FOREIGN KEY (id_plano_aula_item) REFERENCES public.pl_plano_de_aulas_itens(id) ON DELETE CASCADE,
    CONSTRAINT pl_plano_referencias_edicao_fk FOREIGN KEY (id_edicao_biblioteca) REFERENCES public.bbtk_edicao(uuid),
    CONSTRAINT pl_plano_referencias_criado_por_fk FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id),
    CONSTRAINT pl_plano_referencias_modificado_por_fk FOREIGN KEY (modificado_por) REFERENCES public.user_expandido(id)
);

-- 4. Enable RLS
ALTER TABLE public.pl_plano_de_aulas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pl_plano_de_aulas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pl_plano_referencias ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS Policies
-- Policy: Admin can do everything if in same company
CREATE POLICY "Admin All Plans" ON public.pl_plano_de_aulas
    FOR ALL
    TO authenticated
    USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa))
    WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa));

CREATE POLICY "Admin All Items" ON public.pl_plano_de_aulas_itens
    FOR ALL
    TO authenticated
    USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa))
    WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa));

CREATE POLICY "Admin All Refs" ON public.pl_plano_referencias
    FOR ALL
    TO authenticated
    USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa))
    WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa));


-- 6. Functions

-- pl_plano_de_aulas_upsert
CREATE OR REPLACE FUNCTION public.pl_plano_de_aulas_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_id uuid;
    v_registro_salvo public.pl_plano_de_aulas;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.pl_plano_de_aulas as t (
        id, id_empresa, id_componente, id_ano_etapa, titulo, descricao, criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        (p_data ->> 'id_componente')::uuid,
        (p_data ->> 'id_ano_etapa')::uuid,
        p_data ->> 'titulo', 
        p_data ->> 'descricao',
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
    on conflict (id) do update 
    set titulo = coalesce(excluded.titulo, t.titulo),
        descricao = coalesce(excluded.descricao, t.descricao),
        id_componente = coalesce(excluded.id_componente, t.id_componente),
        id_ano_etapa = coalesce(excluded.id_ano_etapa, t.id_ano_etapa),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$function$;
ALTER FUNCTION public.pl_plano_de_aulas_upsert(jsonb, uuid) OWNER TO postgres;

-- pl_plano_de_aulas_get_paginado
CREATE OR REPLACE FUNCTION public.pl_plano_de_aulas_get_paginado(
    p_id_empresa uuid, 
    p_pagina integer DEFAULT 1, 
    p_limite_itens_pagina integer DEFAULT 10, 
    p_busca text DEFAULT ''::text,
    p_id_ano_etapa uuid DEFAULT NULL,
    p_id_componente uuid DEFAULT NULL
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
    SELECT COUNT(*) INTO v_total_itens FROM public.pl_plano_de_aulas
    WHERE id_empresa = p_id_empresa
      AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(titulo) LIKE v_busca_like)
      AND (p_id_ano_etapa IS NULL OR id_ano_etapa = p_id_ano_etapa)
      AND (p_id_componente IS NULL OR id_componente = p_id_componente);

    IF p_limite_itens_pagina > 0 THEN v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina); ELSE v_total_paginas := 0; END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens FROM (
        SELECT p.*, 
               ae.nome as ano_etapa_nome,
               c.nome as componente_nome,
               c.cor as componente_cor
        FROM public.pl_plano_de_aulas p
        JOIN public.ano_etapa ae ON ae.id = p.id_ano_etapa
        JOIN public.componente c ON c.uuid = p.id_componente
        WHERE p.id_empresa = p_id_empresa
          AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(p.titulo) LIKE v_busca_like)
          AND (p_id_ano_etapa IS NULL OR p.id_ano_etapa = p_id_ano_etapa)
          AND (p_id_componente IS NULL OR p.id_componente = p_id_componente)
        ORDER BY p.modificado_em DESC 
        LIMIT p_limite_itens_pagina OFFSET v_offset
    ) t;

    RETURN json_build_object('qtd_itens', v_total_itens, 'qtd_paginas', v_total_paginas, 'itens', v_itens);
END;
$function$;
ALTER FUNCTION public.pl_plano_de_aulas_get_paginado(uuid, integer, integer, text, uuid, uuid) OWNER TO postgres;

-- pl_plano_de_aulas_delete
CREATE OR REPLACE FUNCTION public.pl_plano_de_aulas_delete(p_id uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_deleted boolean;
begin
    DELETE FROM public.pl_plano_de_aulas WHERE id = p_id AND id_empresa = p_id_empresa;
    
    if found then
        return jsonb_build_object('status', 'success');
    else
        return jsonb_build_object('status', 'error', 'message', 'Plano não encontrado.');
    end if;
end;
$function$;
ALTER FUNCTION public.pl_plano_de_aulas_delete(uuid, uuid) OWNER TO postgres;

-- pl_plano_itens_upsert
CREATE OR REPLACE FUNCTION public.pl_plano_itens_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_id uuid;
    v_registro_salvo public.pl_plano_de_aulas_itens;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    insert into public.pl_plano_de_aulas_itens as t (
        id, id_empresa, id_plano_de_aula, aula_numero, conteudo, metodologia, tarefa, criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        (p_data ->> 'id_plano_de_aula')::uuid,
        (p_data ->> 'aula_numero')::integer,
        p_data ->> 'conteudo', 
        p_data ->> 'metodologia',
        p_data ->> 'tarefa',
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
    on conflict (id) do update 
    set aula_numero = coalesce(excluded.aula_numero, t.aula_numero),
        conteudo = coalesce(excluded.conteudo, t.conteudo),
        metodologia = coalesce(excluded.metodologia, t.metodologia),
        tarefa = coalesce(excluded.tarefa, t.tarefa),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$function$;
ALTER FUNCTION public.pl_plano_itens_upsert(jsonb, uuid) OWNER TO postgres;

-- pl_plano_itens_get_by_plano
CREATE OR REPLACE FUNCTION public.pl_plano_itens_get_by_plano(p_id_plano uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_itens jsonb;
BEGIN
    SELECT jsonb_agg(t ORDER BY t.aula_numero ASC) INTO v_itens
    FROM public.pl_plano_de_aulas_itens t
    WHERE t.id_plano_de_aula = p_id_plano AND t.id_empresa = p_id_empresa;
    
    RETURN coalesce(v_itens, '[]'::jsonb);
END;
$function$;
ALTER FUNCTION public.pl_plano_itens_get_by_plano(uuid, uuid) OWNER TO postgres;

-- pl_plano_itens_delete
CREATE OR REPLACE FUNCTION public.pl_plano_itens_delete(p_id uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
    DELETE FROM public.pl_plano_de_aulas_itens WHERE id = p_id AND id_empresa = p_id_empresa;
    if found then return jsonb_build_object('status', 'success'); else return jsonb_build_object('status', 'error', 'message', 'Item não encontrado.'); end if;
end;
$function$;
ALTER FUNCTION public.pl_plano_itens_delete(uuid, uuid) OWNER TO postgres;
