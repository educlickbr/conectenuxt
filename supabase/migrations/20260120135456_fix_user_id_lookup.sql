-- Fix: Resolve user_expandido.id from auth.uid()
-- Corrects FK violation for criado_por/modificado_por

CREATE OR REPLACE FUNCTION public.avaliacao_aluno_registrar_completa_wrapper(
    p_id_empresa uuid,
    p_data jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    v_item jsonb;
    v_id_turma uuid;
    v_id_aluno uuid;
    v_id_modelo uuid;
    v_id_ano_etapa uuid;
    
    v_id_header uuid;
    v_user_id uuid; -- This will be user_expandido.id
    v_auth_id uuid; -- This is auth.uid()
BEGIN
    -- Extract Context
    v_id_turma := (p_data->>'id_turma')::uuid;
    v_id_aluno := (p_data->>'id_aluno')::uuid;
    v_id_modelo := (p_data->>'id_modelo_avaliacao')::uuid;
    v_id_ano_etapa := (p_data->>'id_ano_etapa')::uuid;

    IF v_id_turma IS NULL OR v_id_aluno IS NULL OR v_id_modelo IS NULL OR v_id_ano_etapa IS NULL THEN
        RAISE EXCEPTION 'Dados incompletos para registro de avaliação (Falha Ano/Etapa?).';
    END IF;

    -- Resolve ID for user_expandido (FK target)
    v_auth_id := auth.uid();
    SELECT id INTO v_user_id FROM public.user_expandido WHERE user_id = v_auth_id LIMIT 1;

    -- Check if user exists
    IF v_user_id IS NULL THEN
        -- Fallback: Check if p_data provides id_usuario (trusted source if admin context?)
        -- Or just fail. Let's try to see if auth.uid() *matches* an id in user_expandido directly (rare but possible in some setups)
        SELECT id INTO v_user_id FROM public.user_expandido WHERE id = v_auth_id LIMIT 1;
        
        IF v_user_id IS NULL THEN
            RAISE EXCEPTION 'Usuário logado não encontrado na tabela user_expandido.';
        END IF;
    END IF;

    -- 1. Upsert Header (avaliacao_aluno)
    INSERT INTO public.avaliacao_aluno (
        id_empresa, id_turma, id_aluno, id_modelo_avaliacao, id_ano_etapa, 
        status, observacao, criado_por, criado_em, modificado_por, modificado_em
    ) VALUES (
        p_id_empresa, v_id_turma, v_id_aluno, v_id_modelo, v_id_ano_etapa,
        'CONCLUIDA', NULL, v_user_id, now(), v_user_id, now()
    )
    ON CONFLICT (id_aluno, id_modelo_avaliacao, id_ano_etapa)
    DO UPDATE SET 
        status = 'CONCLUIDA',
        modificado_por = v_user_id,
        modificado_em = now()
    RETURNING id INTO v_id_header;

    -- 2. Process Items (avaliacao_aluno_resposta)
    IF p_data->'respostas' IS NOT NULL AND jsonb_typeof(p_data->'respostas') = 'array' THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_data->'respostas')
        LOOP
            INSERT INTO public.avaliacao_aluno_resposta (
                id_empresa,
                id_avaliacao_aluno,
                id_item_avaliacao,
                conceito,
                criado_por, criado_em, modificado_por, modificado_em
            ) VALUES (
                p_id_empresa,
                v_id_header,
                (v_item->>'id_item_avaliacao')::uuid,
                (v_item->>'conceito')::int,
                v_user_id, now(), v_user_id, now()
            )
            ON CONFLICT (id_avaliacao_aluno, id_item_avaliacao)
            DO UPDATE SET
                conceito = EXCLUDED.conceito,
                modificado_por = v_user_id,
                modificado_em = now();
        END LOOP;
    END IF;

    RETURN jsonb_build_object('success', true, 'message', 'Notas salvas com sucesso.');
END;
$function$;
