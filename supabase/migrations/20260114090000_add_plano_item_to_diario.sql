-- Migration: Add id_plano_aula_item to diario_aula
-- Date: 2026-01-14

-- 1. Add Column
ALTER TABLE public.diario_aula 
ADD COLUMN IF NOT EXISTS id_plano_aula_item UUID REFERENCES public.pl_plano_de_aulas_itens(id) ON DELETE SET NULL;

-- 2. Update diario_aula_upsert
CREATE OR REPLACE FUNCTION public.diario_aula_upsert(
    p_data jsonb,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_id uuid;
    v_registro_salvo public.diario_aula;
    v_user_id uuid;
BEGIN
    v_id := coalesce(nullif(p_data ->> 'id', '')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    INSERT INTO public.diario_aula (
        id, 
        id_empresa, 
        id_turma, 
        id_componente, 
        data, 
        conteudo, 
        metodologia, 
        tarefa_casa, 
        id_plano_aula_item, -- NEW FIELD
        registrado_por, 
        registrado_em
    )
    VALUES (
        v_id,
        p_id_empresa,
        (p_data ->> 'id_turma')::uuid,
        (p_data ->> 'id_componente')::uuid,
        (p_data ->> 'data')::date,
        (p_data ->> 'conteudo'),
        (p_data ->> 'metodologia'),
        (p_data ->> 'tarefa_casa'),
        (p_data ->> 'id_plano_aula_item')::uuid, -- NEW FIELD
        v_user_id,
        now()
    )
    ON CONFLICT (id) DO UPDATE 
    SET 
        id_turma = EXCLUDED.id_turma,
        id_componente = EXCLUDED.id_componente,
        data = EXCLUDED.data,
        conteudo = EXCLUDED.conteudo,
        metodologia = EXCLUDED.metodologia,
        tarefa_casa = EXCLUDED.tarefa_casa,
        id_plano_aula_item = EXCLUDED.id_plano_aula_item, -- NEW FIELD
        registrado_por = v_user_id
    WHERE public.diario_aula.id_empresa = p_id_empresa
    RETURNING * INTO v_registro_salvo;

    RETURN to_jsonb(v_registro_salvo);
END;
$$;

-- 3. Update diario_aula_get_paginado to include plan info (optional but good for read)
-- Recreating function with new join
CREATE OR REPLACE FUNCTION public.diario_aula_get_paginado(
    p_id_empresa uuid,
    p_pagina integer DEFAULT 1,
    p_limite_itens_pagina integer DEFAULT 10,
    p_id_turma uuid DEFAULT NULL,
    p_id_componente uuid DEFAULT NULL,
    p_data_inicio date DEFAULT NULL,
    p_data_fim date DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_offset integer;
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    SELECT COUNT(*) INTO v_total_itens
    FROM public.diario_aula d
    WHERE d.id_empresa = p_id_empresa
      AND (p_id_turma IS NULL OR d.id_turma = p_id_turma)
      AND (p_id_componente IS NULL OR d.id_componente = p_id_componente)
      AND (p_data_inicio IS NULL OR d.data >= p_data_inicio)
      AND (p_data_fim IS NULL OR d.data <= p_data_fim);

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(t), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            d.*,
            u.nome_completo as professor_nome,
            c.nome as componente_nome,
            -- Plan Info
            p.titulo as plano_titulo,
            pi.aula_numero as plano_aula_numero
        FROM public.diario_aula d
        LEFT JOIN public.user_expandido u ON u.id = d.registrado_por
        LEFT JOIN public.componente c ON c.uuid = d.id_componente
        LEFT JOIN public.pl_plano_de_aulas_itens pi ON pi.id = d.id_plano_aula_item
        LEFT JOIN public.pl_plano_de_aulas p ON p.id = pi.id_plano_de_aula
        WHERE d.id_empresa = p_id_empresa
          AND (p_id_turma IS NULL OR d.id_turma = p_id_turma)
          AND (p_id_componente IS NULL OR d.id_componente = p_id_componente)
          AND (p_data_inicio IS NULL OR d.data >= p_data_inicio)
          AND (p_data_fim IS NULL OR d.data <= p_data_fim)
        ORDER BY d.data DESC, d.registrado_em DESC
        LIMIT p_limite_itens_pagina
        OFFSET v_offset
    ) t;

    RETURN json_build_object(
        'qtd_itens', v_total_itens,
        'qtd_paginas', v_total_paginas,
        'itens', v_itens
    );
END;
$$;


-- 4. New Helper RPC: pl_plano_itens_get_by_contexto
-- Fetch items for dropdown
CREATE OR REPLACE FUNCTION public.pl_plano_itens_get_by_contexto(
    p_id_empresa uuid,
    p_id_componente uuid,
    p_id_ano_etapa uuid
)
RETURNS json
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_itens json;
BEGIN
    SELECT COALESCE(json_agg(t), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            pi.id,
            pi.aula_numero,
            pi.conteudo,
            pi.metodologia,
            pi.tarefa,
            p.titulo as plano_titulo
        FROM public.pl_plano_de_aulas_itens pi
        JOIN public.pl_plano_de_aulas p ON p.id = pi.id_plano_de_aula
        WHERE p.id_empresa = p_id_empresa
          AND p.id_componente = p_id_componente
          AND (p.id_ano_etapa = p_id_ano_etapa OR p_id_ano_etapa IS NULL) -- Allow fetching without year/stage strictly if needed, but usually strictly.
        ORDER BY p.titulo ASC, pi.aula_numero ASC
    ) t;

    RETURN v_itens;
END;
$$;
