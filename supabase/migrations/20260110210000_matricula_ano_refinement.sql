-- Refinamento de Matrículas: Adição de Ano e Filtros
-- Data: 2026-01-10 18:40

-- 1. Alteração da Tabela
ALTER TABLE public.matriculas ADD COLUMN IF NOT EXISTS ano integer;
-- Se houver dados, definir um padrão (ex: ano atual)
UPDATE public.matriculas SET ano = extract(year from now()) WHERE ano IS NULL;
ALTER TABLE public.matriculas ALTER COLUMN ano SET NOT NULL;

-- 2. Índice para Performance
CREATE INDEX IF NOT EXISTS idx_matriculas_ano ON public.matriculas (ano);

-- 3. Atualização de Funções (DROP e CREATE)

-- matricula_get_paginado
DROP FUNCTION IF EXISTS public.matricula_get_paginado(uuid, integer, integer, text);
CREATE OR REPLACE FUNCTION public.matricula_get_paginado(
	p_id_empresa uuid,
	p_pagina integer DEFAULT 1,
	p_limite_itens_pagina integer DEFAULT 10,
	p_busca text DEFAULT ''::text)
    RETURNS json
    LANGUAGE plpgsql
AS $BODY$
DECLARE
    v_offset integer;
    v_busca_like text := '%' || UPPER(p_busca) || '%';
    v_total_itens integer;
    v_total_paginas integer;
    v_itens json;
BEGIN
    v_offset := (p_pagina - 1) * p_limite_itens_pagina;

    SELECT COUNT(*) INTO v_total_itens
    FROM public.matriculas m
    JOIN public.user_expandido u ON u.id = m.id_aluno
    WHERE 
        m.id_empresa = p_id_empresa
        AND (
            p_busca IS NULL 
            OR TRIM(p_busca) = '' 
            OR UPPER(u.nome_completo) LIKE v_busca_like 
            OR UPPER(m.status) LIKE v_busca_like
            OR m.ano::text LIKE v_busca_like
        );

    IF p_limite_itens_pagina > 0 THEN
        v_total_paginas := CEIL(v_total_itens::numeric / p_limite_itens_pagina);
    ELSE
        v_total_paginas := 0; 
    END IF;

    SELECT COALESCE(json_agg(t), '[]'::json) INTO v_itens
    FROM (
        SELECT 
            m.*,
            u.nome_completo as aluno_nome,
            ae.nome as ano_etapa_nome
        FROM public.matriculas m
        JOIN public.user_expandido u ON u.id = m.id_aluno
        JOIN public.ano_etapa ae ON ae.id = m.id_ano_etapa
        WHERE 
            m.id_empresa = p_id_empresa
            AND (
                p_busca IS NULL 
                OR TRIM(p_busca) = '' 
                OR UPPER(u.nome_completo) LIKE v_busca_like 
                OR UPPER(m.status) LIKE v_busca_like
                OR m.ano::text LIKE v_busca_like
            )
        ORDER BY m.ano DESC, m.criado_em DESC
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

-- matricula_upsert
DROP FUNCTION IF EXISTS public.matricula_upsert(jsonb, uuid);
CREATE OR REPLACE FUNCTION public.matricula_upsert(
    p_data jsonb,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_id uuid;
    v_matricula_salva public.matriculas;
BEGIN
    v_id := coalesce(nullif(p_data ->> 'id', '')::uuid, gen_random_uuid());

    INSERT INTO public.matriculas (
        id, id_empresa, id_aluno, id_ano_etapa, status, ano, observacao
    )
    VALUES (
        v_id,
        p_id_empresa,
        (p_data ->> 'id_aluno')::uuid,
        (p_data ->> 'id_ano_etapa')::uuid,
        (p_data ->> 'status'),
        (p_data ->> 'ano')::integer,
        (p_data ->> 'observacao')
    )
    ON CONFLICT (id) DO UPDATE 
    SET 
        status = EXCLUDED.status,
        observacao = EXCLUDED.observacao,
        id_ano_etapa = EXCLUDED.id_ano_etapa,
        ano = EXCLUDED.ano
    WHERE public.matriculas.id_empresa = p_id_empresa
    RETURNING * INTO v_matricula_salva;

    RETURN to_jsonb(v_matricula_salva);
END;
$$;
