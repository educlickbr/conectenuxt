-- Migration: Add Escopo to Calendario Anual
-- Date: 2026-01-12
-- Description: Adds 'escopo' column to mtz_calendario_anual, makes id_ano_etapa nullable, and updates functions.

BEGIN;

-- 1. Alter Table
ALTER TABLE public.mtz_calendario_anual
    ADD COLUMN IF NOT EXISTS escopo tipo_escopo_evento NOT NULL DEFAULT 'Ano_Etapa';

ALTER TABLE public.mtz_calendario_anual
    ALTER COLUMN id_ano_etapa DROP NOT NULL;

-- 2. Update Functions

-- 2.1 mtz_calendario_anual_upsert (Updated for escopo)
DROP FUNCTION public.mtz_calendario_anual_upsert;
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
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    insert into public.mtz_calendario_anual as t (
        id, 
        id_empresa, 
        id_ano_etapa,
        id_modelo_calendario,
        escopo,
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
        (p_data ->> 'escopo')::tipo_escopo_evento,
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
        id_ano_etapa = excluded.id_ano_etapa, -- Allow setting to null if switching scope
        id_modelo_calendario = coalesce((excluded.id_modelo_calendario), t.id_modelo_calendario),
        escopo = coalesce((excluded.escopo), t.escopo),
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
GRANT EXECUTE ON FUNCTION public.mtz_calendario_anual_upsert(jsonb, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mtz_calendario_anual_upsert(jsonb, uuid) TO service_role;


-- 2.2 mtz_calendario_anual_get_paginado (Updated for filtering)
DROP FUNCTION public.mtz_calendario_anual_get_paginado;
CREATE OR REPLACE FUNCTION public.mtz_calendario_anual_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text,
    p_id_ano_etapa uuid DEFAULT NULL
)
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

    -- Update count query to include Logic:
    -- Show calendars that match search AND (are Rede OR belong to the specific id_ano_etapa if provided)
    -- If p_id_ano_etapa is NULL, maybe show all? Or just Rede? 
    -- Usually: Show Rede + if p_id_ano_etapa provided, show that one too.
    -- Or if p_id_ano_etapa is NULL, show ALL (Rede + all stages)? Let's assume Show ALL if filter is empty.

    SELECT COUNT(*) INTO v_total_itens
    FROM public.mtz_calendario_anual
    WHERE 
        id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR CAST(ano AS TEXT) LIKE v_busca_like
        )
        AND (
            p_id_ano_etapa IS NULL 
            OR id_ano_etapa = p_id_ano_etapa 
            OR escopo = 'Rede'
        );

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            c.*,
            ae.nome as ano_etapa_nome,
            mc.nome as modelo_nome
        FROM public.mtz_calendario_anual c
        LEFT JOIN public.ano_etapa ae ON c.id_ano_etapa = ae.id
        LEFT JOIN public.mtz_modelo_calendario mc ON c.id_modelo_calendario = mc.id
        WHERE 
            c.id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR CAST(c.ano AS TEXT) LIKE v_busca_like
            )
            AND (
                p_id_ano_etapa IS NULL 
                OR c.id_ano_etapa = p_id_ano_etapa 
                OR c.escopo = 'Rede'
            )
        ORDER BY c.ano DESC, c.escopo DESC, ae.nome ASC, c.numero_periodo ASC
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

ALTER FUNCTION public.mtz_calendario_anual_get_paginado(uuid, integer, integer, text, uuid) OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.mtz_calendario_anual_get_paginado(uuid, integer, integer, text, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mtz_calendario_anual_get_paginado(uuid, integer, integer, text, uuid) TO service_role;

-- Drop old signature if needed or keep overloaded (better to drop to avoid confusion if signature changed significantly in usage)
-- The old one had 4 params. The new one adds p_id_ano_etapa. PostgreSQL allows overloading.
-- But we want to ensure we call the new one.
DROP FUNCTION IF EXISTS public.mtz_calendario_anual_get_paginado(uuid, integer, integer, text);

COMMIT;
