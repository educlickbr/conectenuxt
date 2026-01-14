-- 1. Alter Tables to change DATE to TIMESTAMP WITH TIME ZONE
-- We use '::timestamp at time zone 'America/Sao_Paulo'' logic if we want to default to that, 
-- but usually just casting DATE to TIMESTAMPTZ treats it as 00:00 local database time (UTC usually).
-- The user asked to "upsert para America/Sao_Paulo", implying input handling.
-- For existing data, we can cast them directly.

ALTER TABLE public.mtz_eventos
    ALTER COLUMN data_inicio TYPE timestamp with time zone USING data_inicio::timestamp with time zone,
    ALTER COLUMN data_fim TYPE timestamp with time zone USING data_fim::timestamp with time zone;

ALTER TABLE public.mtz_feriados
    ALTER COLUMN data_inicio TYPE timestamp with time zone USING data_inicio::timestamp with time zone,
    ALTER COLUMN data_fim TYPE timestamp with time zone USING data_fim::timestamp with time zone;


-- 2. Update Functions

-- mtz_feriados_upsert
DROP FUNCTION IF EXISTS public.mtz_feriados_upsert;
CREATE OR REPLACE FUNCTION public.mtz_feriados_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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

    -- Note: Parsing input string to specific timezone if it lacks offset.
    -- If p_data ->> 'data_inicio' is '2025-01-01', casting to timestamptz usually assumes UTC or Session TZ.
    -- To force America/Sao_Paulo interpretation for a plain date string:
    -- ((p_data ->> 'data_inicio')::timestamp AT TIME ZONE 'America/Sao_Paulo')
    
    insert into public.mtz_feriados as t (
        id, id_empresa, nome_feriado, tipo, data_inicio, data_fim, criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        p_data ->> 'nome_feriado', 
        p_data ->> 'tipo', 
        ((p_data ->> 'data_inicio')::timestamp AT TIME ZONE 'America/Sao_Paulo'), -- Force interpretation as SP
        ((p_data ->> 'data_fim')::timestamp AT TIME ZONE 'America/Sao_Paulo'), 
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
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
$function$;
ALTER FUNCTION public.mtz_feriados_upsert(jsonb, uuid) OWNER TO postgres;


-- mtz_eventos_upsert
-- Must include 'matriz_sobrepor' from previous migration
DROP FUNCTION IF EXISTS public.mtz_eventos_upsert;
CREATE OR REPLACE FUNCTION public.mtz_eventos_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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

    insert into public.mtz_eventos as t (
        id, 
        id_empresa, 
        nome_evento, 
        escopo, 
        id_ano_etapa, 
        data_inicio, 
        data_fim, 
        matriz_sobrepor,
        criado_por, 
        criado_em, 
        modificado_por, 
        modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        p_data ->> 'nome_evento', 
        (p_data ->> 'escopo')::tipo_escopo_evento, 
        (p_data ->> 'id_ano_etapa')::uuid, 
        ((p_data ->> 'data_inicio')::timestamp AT TIME ZONE 'America/Sao_Paulo'), -- Force SP Timezone
        ((p_data ->> 'data_fim')::timestamp AT TIME ZONE 'America/Sao_Paulo'), 
        coalesce((p_data ->> 'matriz_sobrepor')::boolean, false),
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
    on conflict (id) do update 
    set nome_evento = coalesce(excluded.nome_evento, t.nome_evento),
        escopo = coalesce(excluded.escopo, t.escopo),
        id_ano_etapa = excluded.id_ano_etapa,
        data_inicio = coalesce(excluded.data_inicio, t.data_inicio),
        data_fim = coalesce(excluded.data_fim, t.data_fim),
        matriz_sobrepor = coalesce(excluded.matriz_sobrepor, t.matriz_sobrepor),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$function$;
ALTER FUNCTION public.mtz_eventos_upsert(jsonb, uuid) OWNER TO postgres;

-- Recreate Get Paginado (Signature unchanged, but internal logic for search might need casting if searching dates)
-- Actually, the signature doesn't filter by date ranges in the current version, so it's mostly fine.
-- But we can update them just to be safe if types mismatch in return (though JSON auto handles it).
-- The main change is the underlying table column type, so SELECT * will return text representation of timestamp.

-- Let's update them to be explicit if needed, but the previous CREATE OR REPLACE should handle the column change fine dynamically?
-- Functions in PG are compiled. Changed table column type MIGHT invalidate function plan or require re-creation if it depends on specific type.
-- Safest to re-run CREATE OR REPLACE.

DROP FUNCTION IF EXISTS public.mtz_eventos_get_paginado;
CREATE OR REPLACE FUNCTION public.mtz_eventos_get_paginado(
    p_id_empresa uuid, 
    p_pagina integer DEFAULT 1, 
    p_limite_itens_pagina integer DEFAULT 10, 
    p_busca text DEFAULT ''::text, 
    p_id_ano_etapa uuid DEFAULT NULL::uuid)
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
$function$;
ALTER FUNCTION public.mtz_eventos_get_paginado(uuid, integer, integer, text, uuid) OWNER TO postgres;

DROP FUNCTION IF EXISTS public.mtz_feriados_get_paginado;
CREATE OR REPLACE FUNCTION public.mtz_feriados_get_paginado(
    p_id_empresa uuid, 
    p_pagina integer DEFAULT 1, 
    p_limite_itens_pagina integer DEFAULT 10, 
    p_busca text DEFAULT ''::text)
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
    SELECT COUNT(*) INTO v_total_itens FROM public.mtz_feriados
    WHERE id_empresa = p_id_empresa
      AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(nome_feriado) LIKE v_busca_like);

    IF p_limite_itens_pagina > 0 THEN v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina); ELSE v_total_paginas := 0; END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens FROM (
        SELECT * FROM public.mtz_feriados
        WHERE id_empresa = p_id_empresa
          AND (p_busca IS NULL OR TRIM(p_busca) = '' OR UPPER(nome_feriado) LIKE v_busca_like)
        ORDER BY data_inicio ASC LIMIT p_limite_itens_pagina OFFSET v_offset
    ) t;

    RETURN json_build_object('qtd_itens', v_total_itens, 'qtd_paginas', v_total_paginas, 'itens', v_itens);
END;
$function$;
ALTER FUNCTION public.mtz_feriados_get_paginado(uuid, integer, integer, text) OWNER TO postgres;
