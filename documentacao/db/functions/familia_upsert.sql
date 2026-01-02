CREATE OR REPLACE FUNCTION public.familia_upsert(
    p_id_empresa uuid,
    p_data jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_id_familia uuid;
    v_item_resp jsonb;
    v_id_resp uuid;
    v_id_aluno uuid;
    v_alunos_array jsonb;
    v_papel_responsavel uuid := '3ecbe197-4c01-4b25-8e8a-04f9adaff801';
    v_id_pergunta_cpf uuid := 'bec8701a-c56e-47c2-82d3-3123ad26bc2f';
BEGIN
    -- 1. Family Upsert
    v_id_familia := (p_data->>'id')::uuid;
    
    IF v_id_familia IS NULL THEN
        INSERT INTO public.user_familia (id_empresa, nome_familia)
        VALUES (p_id_empresa, p_data->>'nome_familia')
        RETURNING id INTO v_id_familia;
    ELSE
        UPDATE public.user_familia
        SET nome_familia = p_data->>'nome_familia'
        WHERE id = v_id_familia AND id_empresa = p_id_empresa;
    END IF;

    -- 2. Clear existing links for this family to ensure full sync
    DELETE FROM public.user_responsavel_aluno WHERE id_familia = v_id_familia;

    -- 3. Responsibles Loop
    v_alunos_array := p_data->'alunos';
    
    FOR v_item_resp IN SELECT * FROM jsonb_array_elements(p_data->'responsaveis')
    LOOP
        v_id_resp := (v_item_resp->>'id')::uuid;
        
        -- Upsert User Expandido (Responsable)
        IF v_id_resp IS NULL THEN
            INSERT INTO public.user_expandido (
                id_empresa, 
                nome_completo, 
                email, 
                telefone,
                matricula,
                papel_id
            ) VALUES (
                p_id_empresa,
                v_item_resp->>'nome_completo',
                v_item_resp->>'email',
                v_item_resp->>'telefone',
                'TEMP-RESP-' || floor(extract(epoch from now()) * 1000)::text || '-' || floor(random() * 1000)::text,
                v_papel_responsavel
            ) RETURNING id INTO v_id_resp;
        ELSE
            UPDATE public.user_expandido
            SET 
                nome_completo = v_item_resp->>'nome_completo',
                email = v_item_resp->>'email',
                telefone = v_item_resp->>'telefone'
            WHERE id = v_id_resp;
        END IF;

        -- Update Principal if flagged
        IF (v_item_resp->>'principal')::boolean IS TRUE THEN
            UPDATE public.user_familia 
            SET id_responsavel_principal = v_id_resp
            WHERE id = v_id_familia;
        END IF;

        -- Upsert CPF (respostas_user)
        IF v_item_resp->>'cpf' IS NOT NULL AND v_item_resp->>'cpf' <> '' THEN
             INSERT INTO public.respostas_user (id_empresa, id_user, id_pergunta, resposta, tipo)
             VALUES (p_id_empresa, v_id_resp, v_id_pergunta_cpf, v_item_resp->>'cpf', 'texto')
             ON CONFLICT (id_user, id_pergunta)
             DO UPDATE SET resposta = EXCLUDED.resposta;
        END IF;

        -- Link Students to this Responsible
        IF v_alunos_array IS NOT NULL THEN
             FOR v_id_aluno IN SELECT * FROM jsonb_array_elements_text(v_alunos_array)
             LOOP
                 INSERT INTO public.user_responsavel_aluno (id_aluno, id_responsavel, id_familia, papel)
                 VALUES (v_id_aluno::uuid, v_id_resp, v_id_familia, v_item_resp->>'papel')
                 ON CONFLICT (id_aluno, id_responsavel) 
                 DO UPDATE SET 
                    id_familia = EXCLUDED.id_familia,
                    papel = EXCLUDED.papel;
             END LOOP;
        END IF;

    END LOOP;
    
    RETURN jsonb_build_object('id', v_id_familia);
END;
$$;

ALTER FUNCTION public.familia_upsert(uuid, jsonb)
    OWNER TO postgres;
