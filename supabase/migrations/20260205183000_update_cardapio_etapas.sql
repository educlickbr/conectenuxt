-- Migration: Update mrd_cardapio_etapa and RPCs
-- Date: 2026-02-05

-- 1. Modify mrd_cardapio_etapa to have a proper ID
-- First check if it exists and modify, or drop and recreate to be clean since it's dev
DROP TABLE IF EXISTS public.mrd_cardapio_etapa CASCADE;

CREATE TABLE public.mrd_cardapio_etapa (
    id uuid NOT NULL DEFAULT gen_random_uuid(), -- New PK
    cardapio_grupo_id uuid NOT NULL,
    ano_etapa_id uuid NOT NULL,
    empresa_id uuid NOT NULL, -- Ensure RLS works
    
    created_at timestamptz DEFAULT now(),
    created_by uuid REFERENCES auth.users(id),

    CONSTRAINT mrd_cardapio_etapa_pkey PRIMARY KEY (id),
    CONSTRAINT mrd_cardapio_etapa_grupo_fkey FOREIGN KEY (cardapio_grupo_id) REFERENCES public.mrd_cardapio_grupo(id) ON DELETE CASCADE,
    CONSTRAINT mrd_cardapio_etapa_ano_etapa_fkey FOREIGN KEY (ano_etapa_id) REFERENCES public.ano_etapa(id),
    CONSTRAINT mrd_cardapio_etapa_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id),
    -- Ensure uniqueness pair
    CONSTRAINT mrd_cardapio_etapa_unique_pair UNIQUE (cardapio_grupo_id, ano_etapa_id)
);

-- Enable RLS
ALTER TABLE public.mrd_cardapio_etapa ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Acesso por empresa" ON public.mrd_cardapio_etapa
    FOR ALL USING (
        (auth.jwt() ->> 'empresa_id')::uuid = empresa_id
        OR
        (auth.jwt() ->> 'papeis_user')::text = 'admin'
    );


-- 2. UPDATE GET RPC to return Etapas IDs and Names
CREATE OR REPLACE FUNCTION public.mrd_cardapio_grupo_get_paginado(
    p_id_empresa uuid,
    p_pagina integer DEFAULT 1,
    p_limite integer DEFAULT 10,
    p_busca text DEFAULT ''
)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_offset integer;
    v_total integer;
    v_itens jsonb;
BEGIN
    v_offset := (p_pagina - 1) * p_limite;

    -- Count Total
    SELECT count(*) INTO v_total
    FROM public.mrd_cardapio_grupo t
    WHERE t.empresa_id = p_id_empresa
      AND t.ativo = true
      AND (p_busca = '' OR t.nome ILIKE '%' || p_busca || '%');

    -- Fetch Items
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', t.id,
            'nome', t.nome,
            'data_inicio', t.data_inicio,
            'data_fim', t.data_fim,
            'etapas', (
                SELECT coalesce(jsonb_agg(ae.nome), '[]'::jsonb)
                FROM public.mrd_cardapio_etapa ce
                JOIN public.ano_etapa ae ON ce.ano_etapa_id = ae.id
                WHERE ce.cardapio_grupo_id = t.id
            ),
             'etapas_ids', (
                SELECT coalesce(jsonb_agg(ce.ano_etapa_id), '[]'::jsonb)
                FROM public.mrd_cardapio_etapa ce
                WHERE ce.cardapio_grupo_id = t.id
            )
        )
    )
    INTO v_itens
    FROM (
        SELECT *
        FROM public.mrd_cardapio_grupo t
        WHERE t.empresa_id = p_id_empresa
          AND t.ativo = true
          AND (p_busca = '' OR t.nome ILIKE '%' || p_busca || '%')
        ORDER BY t.data_inicio DESC
        LIMIT p_limite OFFSET v_offset
    ) t;

    RETURN jsonb_build_object(
        'data', coalesce(v_itens, '[]'::jsonb),
        'total', v_total,
        'pagina', p_pagina,
        'limite', p_limite
    );
END;
$function$;


-- 3. UPDATE UPSERT RPC to handle Etapas Relations
CREATE OR REPLACE FUNCTION public.mrd_cardapio_grupo_upsert(
    p_data jsonb, 
    p_id_empresa uuid,
    p_etapas_ids uuid[] DEFAULT NULL
)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_id uuid;
    v_record public.mrd_cardapio_grupo;
    v_etapa_id uuid;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.empresa WHERE id = p_id_empresa) THEN
         RETURN jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada.');
    END IF;

    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());

    -- 1. Upsert Group
    INSERT INTO public.mrd_cardapio_grupo (
        id, empresa_id, nome, data_inicio, data_fim,
        created_by, updated_by
    )
    VALUES (
        v_id,
        p_id_empresa,
        p_data ->> 'nome',
        (p_data ->> 'data_inicio')::timestamptz,
        (p_data ->> 'data_fim')::timestamptz,
        auth.uid(), auth.uid()
    )
    ON CONFLICT (id) DO UPDATE SET
        nome = excluded.nome,
        data_inicio = excluded.data_inicio,
        data_fim = excluded.data_fim,
        updated_at = now(),
        updated_by = auth.uid()
    WHERE mrd_cardapio_grupo.empresa_id = p_id_empresa
    RETURNING * INTO v_record;

    -- 2. Handle Etapas (Sync) if parameter provided
    IF p_etapas_ids IS NOT NULL THEN
        -- Delete existing not in new list
        DELETE FROM public.mrd_cardapio_etapa
        WHERE cardapio_grupo_id = v_id
          AND ano_etapa_id NOT IN (SELECT unnest(p_etapas_ids));
          
        -- Insert new ones
        FOREACH v_etapa_id IN ARRAY p_etapas_ids
        LOOP
            INSERT INTO public.mrd_cardapio_etapa (id, cardapio_grupo_id, ano_etapa_id, empresa_id, created_by)
            VALUES (gen_random_uuid(), v_id, v_etapa_id, p_id_empresa, auth.uid())
            ON CONFLICT (cardapio_grupo_id, ano_etapa_id) DO NOTHING;
        END LOOP;
    END IF;

    RETURN to_jsonb(v_record);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$function$;
