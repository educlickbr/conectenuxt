DROP FUNCTION public.lms_conteudo_upsert;
CREATE OR REPLACE FUNCTION public.lms_conteudo_upsert(
    p_id uuid,
    p_id_empresa uuid,
    p_criado_por uuid,
    p_id_turma uuid,
    p_id_aluno uuid,
    p_id_meta_turma uuid,
    p_id_componente uuid,
    p_escopo text,
    p_titulo text,
    p_descricao text,
    p_data_referencia date,
    p_json_itens jsonb, -- Recebe itens para criar/atualizar junto
    p_visivel_para_alunos boolean DEFAULT true,
    p_data_disponivel timestamp with time zone DEFAULT NULL,
    p_liberar_por text DEFAULT 'Conteúdo'
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_id uuid;
    v_item jsonb;
    v_item_id uuid;
    v_real_criado_por uuid;
BEGIN
    -- Traduzir o ID do Auth (p_criado_por) para o ID da tabela user_expandido
    SELECT id INTO v_real_criado_por
    FROM public.user_expandido
    WHERE user_id = p_criado_por
    LIMIT 1;

    -- Fallback: Se não achar pelo user_id, tenta ver se o ID passado JÁ É um user_expandido (casos legados ou admin direto)
    IF v_real_criado_por IS NULL THEN
        -- Tenta verificar se existe como PK
        PERFORM id FROM public.user_expandido WHERE id = p_criado_por;
        IF FOUND THEN
            v_real_criado_por := p_criado_por;
        ELSE
            -- Se falhar a tradução, usar o ID fornecido mas sabendo que pode dar erro de FK se não existir.
            -- O ideal aqui seria dar um RAISE EXCEPTION amigável.
            v_real_criado_por := p_criado_por; 
        END IF;
    END IF;

    -- 1. Upsert do Conteúdo Pai
    INSERT INTO public.lms_conteudo (
        id, 
        id_empresa, 
        criado_por, 
        id_turma, 
        id_aluno, 
        id_meta_turma, 
        id_componente, 
        escopo, 
        titulo, 
        descricao, 
        data_referencia, 
        visivel_para_alunos, 
        data_disponivel, 
        liberar_por,
        ordem
    ) VALUES (
        COALESCE(p_id, gen_random_uuid()),
        p_id_empresa,
        v_real_criado_por, -- Usando o ID traduzido
        p_id_turma,
        p_id_aluno,
        p_id_meta_turma,
        p_id_componente,
        p_escopo,
        p_titulo,
        p_descricao,
        p_data_referencia,
        p_visivel_para_alunos,
        p_data_disponivel,
        p_liberar_por::liberacao_conteudo_enum,
        99 -- Ordem default, depois podemos melhorar
    )
    ON CONFLICT (id) DO UPDATE SET
        titulo = EXCLUDED.titulo,
        descricao = EXCLUDED.descricao,
        data_referencia = EXCLUDED.data_referencia,
        visivel_para_alunos = EXCLUDED.visivel_para_alunos,
        data_disponivel = EXCLUDED.data_disponivel,
        liberar_por = EXCLUDED.liberar_por,
        id_turma = EXCLUDED.id_turma,
        id_aluno = EXCLUDED.id_aluno,
        id_meta_turma = EXCLUDED.id_meta_turma,
        escopo = EXCLUDED.escopo
    RETURNING id INTO v_id;

    -- 2. Manipulação dos Itens (Se fornecidos)
    -- É comum no front mandar o objeto completo. Se p_json_itens vier, atualizamos.
    IF p_json_itens IS NOT NULL THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_json_itens)
        LOOP
            -- Lógica simplificada: Se tem ID, atualiza. Se não tem, insere.
            -- Deletar itens não enviados fica para uma lógica de exclusão explícita ou replace total.
            -- Aqui faremos upsert individual.
            
            INSERT INTO public.lms_item_conteudo (
                id,
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
                criado_por,
                id_empresa
            ) VALUES (
                COALESCE((v_item->>'id')::uuid, gen_random_uuid()),
                v_id,
                (v_item->>'tipo')::lms_tipo_item,
                v_item->>'titulo',
                v_item->>'caminho_arquivo',
                v_item->>'url_externa',
                v_item->>'video_link',
                v_item->>'rich_text',
                (v_item->>'pontuacao_maxima')::numeric,
                (v_item->>'id_bbtk_edicao')::uuid,
                (v_item->>'ordem')::integer,
                p_criado_por,
                p_id_empresa
            )
            ON CONFLICT (id) DO UPDATE SET
                titulo = EXCLUDED.titulo,
                caminho_arquivo = EXCLUDED.caminho_arquivo,
                url_externa = EXCLUDED.url_externa,
                video_link = EXCLUDED.video_link,
                rich_text = EXCLUDED.rich_text,
                pontuacao_maxima = EXCLUDED.pontuacao_maxima,
                id_bbtk_edicao = EXCLUDED.id_bbtk_edicao,
                ordem = EXCLUDED.ordem;
                
        END LOOP;
    END IF;

    RETURN v_id;
END;
$function$;
