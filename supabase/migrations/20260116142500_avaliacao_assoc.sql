-- Migration for Avaliacao Association Table
-- Table: avaliacao_assoc_ano_etapa_modelo

CREATE TABLE IF NOT EXISTS public.avaliacao_assoc_ano_etapa_modelo (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    id_empresa uuid NOT NULL,
    id_ano_etapa uuid NOT NULL,
    id_modelo_avaliacao uuid NOT NULL,
    criado_por uuid DEFAULT auth.uid(),
    criado_em timestamptz DEFAULT now(),
    modificado_por uuid,
    modificado_em timestamptz,
    CONSTRAINT avaliacao_assoc_pkey PRIMARY KEY (id),
    CONSTRAINT avaliacao_assoc_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id),
    CONSTRAINT avaliacao_assoc_ano_etapa_fk FOREIGN KEY (id_ano_etapa) REFERENCES public.ano_etapa(id) ON DELETE CASCADE,
    CONSTRAINT avaliacao_assoc_modelo_fk FOREIGN KEY (id_modelo_avaliacao) REFERENCES public.avaliacao_modelo(id) ON DELETE CASCADE,
    CONSTRAINT avaliacao_assoc_criado_por_fk FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id),
    CONSTRAINT avaliacao_assoc_modificado_por_fk FOREIGN KEY (modificado_por) REFERENCES public.user_expandido(id),
    -- Prevent duplicate assignments for the same pair
    CONSTRAINT avaliacao_assoc_unique UNIQUE (id_ano_etapa, id_modelo_avaliacao)
);

-- Enable RLS
ALTER TABLE public.avaliacao_assoc_ano_etapa_modelo ENABLE ROW LEVEL SECURITY;

-- RLS Policies (Admin All)
CREATE POLICY "Admin All Assoc" ON public.avaliacao_assoc_ano_etapa_modelo FOR ALL TO authenticated USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)) WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa));


-- FLUSH and REFILL function (Alternative to single Upsert for assoc tables) or Single Upsert?
-- User asked for Upsert, Delete, Get.

-- 1. Upsert
CREATE OR REPLACE FUNCTION public.avaliacao_assoc_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_id uuid;
    v_registro_salvo public.avaliacao_assoc_ano_etapa_modelo;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    insert into public.avaliacao_assoc_ano_etapa_modelo as t (
        id, id_empresa, id_ano_etapa, id_modelo_avaliacao, criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        (p_data ->> 'id_ano_etapa')::uuid,
        (p_data ->> 'id_modelo_avaliacao')::uuid,
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
    on conflict (id) do update 
    set id_ano_etapa = coalesce((p_data ->> 'id_ano_etapa')::uuid, t.id_ano_etapa),
        id_modelo_avaliacao = coalesce((p_data ->> 'id_modelo_avaliacao')::uuid, t.id_modelo_avaliacao),
        modificado_por = v_user_id,
        modificado_em = now()
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$function$;
ALTER FUNCTION public.avaliacao_assoc_upsert(jsonb, uuid) OWNER TO postgres;

-- 2. Delete
CREATE OR REPLACE FUNCTION public.avaliacao_assoc_delete(p_id uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
    DELETE FROM public.avaliacao_assoc_ano_etapa_modelo WHERE id = p_id AND id_empresa = p_id_empresa;
    if found then return jsonb_build_object('status', 'success'); else return jsonb_build_object('status', 'error', 'message', 'Associação não encontrada.'); end if;
end;
$function$;
ALTER FUNCTION public.avaliacao_assoc_delete(uuid, uuid) OWNER TO postgres;

-- 3. Get by Ano/Etapa
-- We want to return the assoc ID, but also details about the Model so the frontend can check boxes or display names.
CREATE OR REPLACE FUNCTION public.avaliacao_assoc_get_by_ano_etapa(p_id_ano_etapa uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_itens jsonb;
BEGIN
    SELECT jsonb_agg(row_to_json(t) ORDER BY t.nome_modelo ASC) INTO v_itens
    FROM (
        SELECT 
            assoc.id as id_assoc,
            assoc.id_ano_etapa,
            assoc.id_modelo_avaliacao,
            modelo.nome_modelo,
            modelo.criado_em,
            modelo.modificado_em
        FROM public.avaliacao_assoc_ano_etapa_modelo assoc
        JOIN public.avaliacao_modelo modelo ON modelo.id = assoc.id_modelo_avaliacao
        WHERE assoc.id_ano_etapa = p_id_ano_etapa AND assoc.id_empresa = p_id_empresa
    ) t;
    RETURN coalesce(v_itens, '[]'::jsonb);
END;
$function$;
ALTER FUNCTION public.avaliacao_assoc_get_by_ano_etapa(uuid, uuid) OWNER TO postgres;

-- 4. Get by Modelo (Inverse lookup)
CREATE OR REPLACE FUNCTION public.avaliacao_assoc_get_by_modelo(p_id_modelo uuid, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_itens jsonb;
BEGIN
    SELECT jsonb_agg(row_to_json(t)) INTO v_itens
    FROM (
        SELECT 
            assoc.id as id_assoc,
            assoc.id_ano_etapa,
            ae.nome as nome_ano_etapa
        FROM public.avaliacao_assoc_ano_etapa_modelo assoc
        JOIN public.ano_etapa ae ON ae.id = assoc.id_ano_etapa
        WHERE assoc.id_modelo_avaliacao = p_id_modelo AND assoc.id_empresa = p_id_empresa
    ) t;
    RETURN coalesce(v_itens, '[]'::jsonb);
END;
$function$;
ALTER FUNCTION public.avaliacao_assoc_get_by_modelo(uuid, uuid) OWNER TO postgres;
