
DROP FUNCTION public.lms_item_upsert;
CREATE OR REPLACE FUNCTION public.lms_item_upsert(
    p_id uuid,
    p_id_empresa uuid,
    p_criado_por uuid,
    p_id_lms_conteudo uuid,
    p_tipo text,
    p_titulo text,
    p_caminho_arquivo text,
    p_url_externa text,
    p_video_link text,
    p_rich_text text,
    p_pontuacao_maxima numeric,
    p_id_bbtk_edicao uuid,
    p_ordem integer,
    p_data_disponivel timestamp with time zone,
    p_data_entrega_limite timestamp with time zone,
    p_tempo_questionario integer DEFAULT NULL, -- New param
    p_perguntas jsonb DEFAULT NULL -- Array of questions
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_id uuid;
    v_perg jsonb;
    v_opcao jsonb;
    v_id_pergunta uuid;
    v_real_criado_por uuid;
BEGIN
    -- Traduzir o ID do Auth (p_criado_por) para o ID da tabela user_expandido
    SELECT id INTO v_real_criado_por
    FROM public.user_expandido
    WHERE user_id = p_criado_por
    LIMIT 1;

    -- Fallback: Se não achar pelo user_id, tenta ver se o ID passado JÁ É um user_expandido
    IF v_real_criado_por IS NULL THEN
        PERFORM id FROM public.user_expandido WHERE id = p_criado_por;
        IF FOUND THEN
            v_real_criado_por := p_criado_por;
        ELSE
            v_real_criado_por := p_criado_por; 
        END IF;
    END IF;

    -- 1. Upsert do Item
    INSERT INTO public.lms_item_conteudo (
        id,
        id_empresa,
        criado_por,
        id_lms_conteudo,
        tipo,
        titulo,
        caminho_arquivo,
        url_externa,
        video_link,
        rich_text,
        pontuacao_maxima,
        id_bbtk_edicao,
        ordem,
        data_disponivel,
        data_entrega_limite,
        tempo_questionario
    ) VALUES (
        COALESCE(p_id, gen_random_uuid()),
        p_id_empresa,
        v_real_criado_por,
        p_id_lms_conteudo,
        p_tipo::lms_tipo_item,
        p_titulo,
        p_caminho_arquivo,
        p_url_externa,
        p_video_link,
        p_rich_text,
        p_pontuacao_maxima,
        p_id_bbtk_edicao,
        p_ordem,
        p_data_disponivel,
        p_data_entrega_limite,
        p_tempo_questionario
    )
    ON CONFLICT (id) DO UPDATE SET
        titulo = EXCLUDED.titulo,
        caminho_arquivo = EXCLUDED.caminho_arquivo,
        url_externa = EXCLUDED.url_externa,
        video_link = EXCLUDED.video_link,
        rich_text = EXCLUDED.rich_text,
        pontuacao_maxima = EXCLUDED.pontuacao_maxima,
        id_bbtk_edicao = EXCLUDED.id_bbtk_edicao,
        ordem = EXCLUDED.ordem,
        data_disponivel = EXCLUDED.data_disponivel,
        data_entrega_limite = EXCLUDED.data_entrega_limite,
        tempo_questionario = EXCLUDED.tempo_questionario,
        tipo = EXCLUDED.tipo
    RETURNING id INTO v_id;

    -- 2. Manipulação das Perguntas (Se for Questionário e JSON fornecido)
    IF p_perguntas IS NOT NULL THEN
        -- Opcional: Remover perguntas que não estão no JSON? 
        -- Por enquanto vamos fazer upsert. Se o usuário deletou na UI, o front deve mandar ID se existir.
        -- Se quisermos sync perfeito (apagar removidos), precisaríamos de lógica extra.
        -- Vamos assumir que perguntas não enviadas no JSON mas existentes no DB devem ser removidas? 
        -- Sim, para garantir integridade do form visual.
        
        DELETE FROM public.lms_pergunta 
        WHERE id_item_conteudo = v_id 
        AND id NOT IN (
            SELECT (val->>'id')::uuid 
            FROM jsonb_array_elements(p_perguntas) val 
            WHERE val->>'id' IS NOT NULL
        );

        FOR v_perg IN SELECT * FROM jsonb_array_elements(p_perguntas)
        LOOP
            INSERT INTO public.lms_pergunta (
                id,
                id_empresa,
                id_item_conteudo,
                tipo,
                enunciado,
                caminho_imagem,
                obrigatoria,
                ordem
            ) VALUES (
                COALESCE((v_perg->>'id')::uuid, gen_random_uuid()),
                p_id_empresa,
                v_id,
                (v_perg->>'tipo')::lms_tipo_pergunta,
                v_perg->>'enunciado',
                v_perg->>'caminho_imagem',
                COALESCE((v_perg->>'obrigatoria')::boolean, true),
                (v_perg->>'ordem')::integer
            )
            ON CONFLICT (id) DO UPDATE SET
                enunciado = EXCLUDED.enunciado,
                caminho_imagem = EXCLUDED.caminho_imagem,
                tipo = EXCLUDED.tipo,
                obrigatoria = EXCLUDED.obrigatoria,
                ordem = EXCLUDED.ordem
            RETURNING id INTO v_id_pergunta;

            -- 3. Manipular Respostas Possiveis (Se houver 'opcoes' no JSON da pergunta)
            IF v_perg->>'opcoes' IS NOT NULL THEN
                
                -- Limpar opções removidas
                DELETE FROM public.lms_resposta_possivel
                WHERE id_pergunta = v_id_pergunta
                AND id NOT IN (
                    SELECT (opt->>'id')::uuid
                    FROM jsonb_array_elements(v_perg->'opcoes') opt
                    WHERE opt->>'id' IS NOT NULL
                );

                FOR v_opcao IN SELECT * FROM jsonb_array_elements(v_perg->'opcoes')
                LOOP
                    INSERT INTO public.lms_resposta_possivel (
                        id,
                        id_empresa,
                        id_pergunta,
                        texto,
                        correta,
                        ordem
                    ) VALUES (
                        COALESCE((v_opcao->>'id')::uuid, gen_random_uuid()),
                        p_id_empresa,
                        v_id_pergunta,
                        v_opcao->>'texto',
                        COALESCE((v_opcao->>'correta')::boolean, false),
                        (v_opcao->>'ordem')::integer
                    )
                    ON CONFLICT (id) DO UPDATE SET
                        texto = EXCLUDED.texto,
                        correta = EXCLUDED.correta,
                        ordem = EXCLUDED.ordem;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    RETURN v_id;
END;
$function$;
