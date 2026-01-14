-- Migration: Add polivalente to carga_horaria
-- Date: 2026-01-14

-- 1. Add Column
ALTER TABLE public.carga_horaria 
ADD COLUMN IF NOT EXISTS polivalente BOOLEAN DEFAULT false;

-- 2. Update carga_horaria_get
DROP FUNCTION IF EXISTS public.carga_horaria_get;
CREATE OR REPLACE FUNCTION public.carga_horaria_get(
    p_id_empresa uuid,
    p_id_ano_etapa uuid
)
RETURNS json
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_itens json;
BEGIN
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            ch.*,
            c.nome as componente_nome,
            c.cor as componente_cor
        FROM public.carga_horaria ch
        JOIN public.componente c ON c.uuid = ch.id_componente
        WHERE ch.id_empresa = p_id_empresa
          AND ch.id_ano_etapa = p_id_ano_etapa
        ORDER BY c.nome ASC
    ) t;

    RETURN json_build_object(
        'itens', v_itens
    );
END;
$$;

-- 3. Update upsert_carga_horaria
DROP FUNCTION public.upsert_carga_horaria;
CREATE OR REPLACE FUNCTION public.upsert_carga_horaria(
    p_data jsonb,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_uuid uuid;
    v_ch_salva public.carga_horaria;
BEGIN
    v_uuid := coalesce(nullif(p_data ->> 'uuid', '')::uuid, gen_random_uuid());

    IF NOT EXISTS (SELECT 1 FROM public.empresa WHERE id = p_id_empresa) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    END IF;

    -- Security: Ensure the year/stage and component belong to the same company
    IF NOT EXISTS (SELECT 1 FROM public.ano_etapa WHERE id = (p_data ->> 'id_ano_etapa')::uuid AND id_empresa = p_id_empresa) THEN
         RETURN jsonb_build_object('status', 'error', 'message', 'Ano/Etapa inválido ou não pertence à empresa.');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.componente WHERE uuid = (p_data ->> 'id_componente')::uuid AND id_empresa = p_id_empresa) THEN
         RETURN jsonb_build_object('status', 'error', 'message', 'Componente inválido ou não pertence à empresa.');
    END IF;

    INSERT INTO public.carga_horaria (
        uuid, 
        id_componente, 
        id_ano_etapa, 
        carga_horaria, 
        id_empresa,
        polivalente, -- NEW FIELD
        modificado_em
    )
    VALUES (
        v_uuid,
        (p_data ->> 'id_componente')::uuid,
        (p_data ->> 'id_ano_etapa')::uuid,
        (p_data ->> 'carga_horaria')::integer,
        p_id_empresa,
        coalesce((p_data ->> 'polivalente')::boolean, false), -- NEW FIELD
        now()
    )
    ON CONFLICT (uuid) DO UPDATE 
    SET 
        id_componente = EXCLUDED.id_componente,
        id_ano_etapa = EXCLUDED.id_ano_etapa,
        carga_horaria = EXCLUDED.carga_horaria,
        polivalente = EXCLUDED.polivalente, -- NEW FIELD
        modificado_em = now()
    WHERE carga_horaria.id_empresa = p_id_empresa
    RETURNING * INTO v_ch_salva;

    RETURN to_jsonb(v_ch_salva);

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
END;
$$;
