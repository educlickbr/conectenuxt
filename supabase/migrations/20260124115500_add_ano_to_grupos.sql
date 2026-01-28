-- Migration: Add 'ano' column to grp_grupos and update RPCs

-- 1. Alter Table
ALTER TABLE public.grp_grupos
ADD COLUMN IF NOT EXISTS ano integer DEFAULT extract(year from now())::integer;

-- 2. Update Upsert RPC
DROP FUNCTION IF EXISTS public.grp_grupo_upsert;

CREATE OR REPLACE FUNCTION public.grp_grupo_upsert(
    p_id uuid,
    p_id_empresa uuid,
    p_nome_grupo text,
    p_descricao text,
    p_status text DEFAULT 'ATIVO',
    p_ano int DEFAULT extract(year from now())::integer
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_id uuid;
    v_result json;
    v_user_id uuid;
BEGIN
    -- Resolve user_expandido.id
    SELECT id INTO v_user_id
    FROM public.user_expandido
    WHERE user_id = auth.uid()
    LIMIT 1;

    IF v_user_id IS NULL THEN
         RETURN json_build_object(
            'success', false,
            'message', 'Usuário não encontrado.'
        );
    END IF;

    IF p_id IS NULL THEN
        -- Insert
        INSERT INTO public.grp_grupos (
            id_empresa,
            nome_grupo,
            descricao,
            status,
            ano,
            criado_por,
            criado_em,
            modificado_por,
            modificado_em
        ) VALUES (
            p_id_empresa,
            p_nome_grupo,
            p_descricao,
            p_status::status_grp,
            p_ano,
            v_user_id,
            now(),
            v_user_id,
            now()
        ) RETURNING id INTO v_id;
    ELSE
        -- Update
        UPDATE public.grp_grupos SET
            nome_grupo = p_nome_grupo,
            descricao = p_descricao,
            status = p_status::status_grp,
            ano = p_ano,
            modificado_por = v_user_id,
            modificado_em = now()
        WHERE id = p_id AND id_empresa = p_id_empresa
        RETURNING id INTO v_id;
    END IF;

    SELECT json_build_object(
        'success', true,
        'id', v_id
    ) INTO v_result;

    RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'message', SQLERRM
    );
END;
$function$;

-- 3. Update Get Paginado RPC (Optional if we filter by year, but definitely to return it if select * doesn't suffice)
-- Note: select g.* ALREADY handles the new column naturally in Postgres if the view/query uses *
-- But if we want to add filtering by year later, we should update it.
-- For now, let's just make sure it's valid. The previous migration used 'g.*' so it will return 'ano' automatically.
-- We might want to add p_ano filtering though? 
-- The user didn't explicitly ask for filtering by year in the list, just "ter o ano".
-- But typically lists filter by year.
-- Let's update Get Paginado to allow filtering by Year.

DROP FUNCTION IF EXISTS public.grp_grupo_get_paginado(uuid, text, text, int, int);

CREATE OR REPLACE FUNCTION public.grp_grupo_get_paginado(
    p_id_empresa uuid,
    p_busca text DEFAULT NULL,
    p_status text DEFAULT NULL,
    p_pagina int DEFAULT 1,
    p_limite_itens_pagina int DEFAULT 10,
    p_ano int DEFAULT NULL -- Filter by year
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_result json;
    v_total int;
    v_offset int;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    -- Calculate Total Count
    SELECT COUNT(*) INTO v_total
    FROM public.grp_grupos g
    WHERE g.id_empresa = p_id_empresa
      AND g.soft_delete IS FALSE
      AND (p_busca IS NULL OR g.nome_grupo ILIKE '%' || p_busca || '%')
      AND (p_status IS NULL OR g.status::text = p_status)
      AND (p_ano IS NULL OR g.ano = p_ano);

    -- Fetch Data
    SELECT json_agg(t) INTO v_result
    FROM (
        SELECT 
            g.*,
            uc.nome_completo as nome_criado_por,
            um.nome_completo as nome_modificado_por,
            (SELECT COUNT(*) FROM public.grp_tutores t WHERE t.id_grupo = g.id) as total_tutores,
            (SELECT COUNT(*) FROM public.grp_integrantes i WHERE i.id_grupo = g.id) as total_integrantes
        FROM public.grp_grupos g
        LEFT JOIN public.user_expandido uc ON uc.id = g.criado_por
        LEFT JOIN public.user_expandido um ON um.id = g.modificado_por
        WHERE g.id_empresa = p_id_empresa
          AND g.soft_delete IS FALSE
          AND (p_busca IS NULL OR g.nome_grupo ILIKE '%' || p_busca || '%')
          AND (p_status IS NULL OR g.status::text = p_status)
          AND (p_ano IS NULL OR g.ano = p_ano)
        ORDER BY g.criado_em DESC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'items', COALESCE(v_result, '[]'::json), 
        'total', v_total,
        'pages', CEIL(v_total::float / p_limite_itens_pagina::float)
    );
END;
$function$;
