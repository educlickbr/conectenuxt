-- Add id_escola to mtz_calendario_anual
ALTER TABLE public.mtz_calendario_anual 
ADD COLUMN IF NOT EXISTS id_escola uuid REFERENCES public.escolas(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_mtz_calendario_anual_id_escola ON public.mtz_calendario_anual (id_escola);

-- Update Upsert Function
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
        id_escola, -- NEW
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
        (p_data ->> 'id_escola')::uuid, -- NEW
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
        id_escola = excluded.id_escola, -- Allow updating school (nullable)
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

-- Update Get Paginado Function with View Logic
DROP FUNCTION public.mtz_calendario_anual_get_paginado;
CREATE OR REPLACE FUNCTION public.mtz_calendario_anual_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text,
    p_id_ano_etapa uuid DEFAULT NULL, -- Existing filter
    p_id_escola uuid DEFAULT NULL,    -- New filter
    p_modo_visualizacao text DEFAULT 'Tudo' -- 'Tudo', 'Rede', 'Segmentado'
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

    -- CTE to build the base query with Joined tables for better display names if needed
    -- (Actually sticking to simple SELECT * for now and letting frontend group or join in another layer if needed, 
    -- but usually we need names. The original did SELECT * from table. 
    -- TabCalendario.vue mentions `ano_etapa_nome` and `modelo_nome`. 
    -- The original view was just the table? 
    -- Wait, the original function previously viewed selected `*` from `mtz_calendario_anual`.
    -- The frontend code `TabCalendario.vue` had: `ano_etapa_nome: item.ano_etapa_nome,`
    -- This implies the PREVIOUS version of `mtz_calendario_anual_get_paginado` might have been selecting from a VIEW or doing joins.
    -- Let's CHECK exactly what was in the previous file.
    -- Step 93 showed `SELECT * FROM public.mtz_calendario_anual`. 
    -- It did NOT join.
    -- So `ano_etapa_nome` must have been missing or the frontend logic was flawed/hoping for it?
    -- Actually, user said "TabCalendario.vue mentions `ano_etapa_nome`".
    -- Let's ADD the joins now to be safe and useful.)

    WITH data_source AS (
        SELECT 
            c.*,
            ae.nome as ano_etapa_nome,
            mc.nome as modelo_nome,
            e.nome as escola_nome
        FROM public.mtz_calendario_anual c
        LEFT JOIN public.ano_etapa ae ON c.id_ano_etapa = ae.id
        LEFT JOIN public.mtz_modelo_calendario mc ON c.id_modelo_calendario = mc.id
        LEFT JOIN public.escolas e ON c.id_escola = e.id
        WHERE c.id_empresa = p_id_empresa
    )
    SELECT COUNT(*) INTO v_total_itens
    FROM data_source c
    WHERE 
        (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR CAST(c.ano AS TEXT) LIKE v_busca_like
        )
        AND (
            CASE 
                WHEN p_modo_visualizacao = 'Rede' THEN c.escopo = 'Rede'
                WHEN p_modo_visualizacao = 'Segmentado' THEN c.escopo = 'Ano_Etapa'
                ELSE TRUE -- 'Tudo'
            END
        )
        AND (
            -- If Segmentado, obey filters if provided. 
            -- User: "se filtrar um ano etapa aío sim ele traz só aquilo"
            -- Logic: If filter is NULL, bring all (ignore). If NOT NULL, must match.
            (p_id_ano_etapa IS NULL OR c.id_ano_etapa = p_id_ano_etapa)
            AND
            (p_id_escola IS NULL OR c.id_escola = p_id_escola)
        );

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT *
        FROM (
            SELECT 
                c.*,
                ae.nome as ano_etapa_nome,
                mc.nome as modelo_nome,
                e.nome as escola_nome
            FROM public.mtz_calendario_anual c
            LEFT JOIN public.ano_etapa ae ON c.id_ano_etapa = ae.id
            LEFT JOIN public.mtz_modelo_calendario mc ON c.id_modelo_calendario = mc.id
            LEFT JOIN public.escolas e ON c.id_escola = e.id
            WHERE c.id_empresa = p_id_empresa
        ) c
        WHERE 
            (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR CAST(c.ano AS TEXT) LIKE v_busca_like
            )
            AND (
                CASE 
                    WHEN p_modo_visualizacao = 'Rede' THEN c.escopo = 'Rede'
                    WHEN p_modo_visualizacao = 'Segmentado' THEN c.escopo = 'Ano_Etapa'
                    ELSE TRUE -- 'Tudo'
                END
            )
            AND (
                (p_id_ano_etapa IS NULL OR c.id_ano_etapa = p_id_ano_etapa)
                AND
                (p_id_escola IS NULL OR c.id_escola = p_id_escola)
            )
        ORDER BY c.ano DESC, c.numero_periodo ASC
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
ALTER FUNCTION public.mtz_calendario_anual_get_paginado(uuid, integer, integer, text, uuid, uuid, text) OWNER TO postgres;
