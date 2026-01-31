CREATE OR REPLACE FUNCTION public.migrate_staging_students(batch_size integer DEFAULT 100)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    r RECORD;
    v_user_expandido_id uuid;
    v_empresa_id uuid := '3cdb36bf-bede-46f2-8f17-1a975f6f1151';
    v_papel_id uuid := 'b7f53d6e-70b5-453b-b564-728aeb4635d5';
    v_escola_id uuid;
    v_nome_responsavel text;
    v_tipo_responsavel text;
    v_formatted_date text;
BEGIN
    FOR r IN
        SELECT * FROM public.staging_alunos_2026
        WHERE verificado = false
        LIMIT batch_size
    LOOP
        BEGIN
            -- 1. Find Escola ID
            SELECT id INTO v_escola_id
            FROM public.escolas
            WHERE nome = r.nome_da_escola
              AND id_empresa = v_empresa_id
            LIMIT 1;

            -- 2. Map Responsavel Logic
            IF r.tipo_de_responsavel = 'Filiação 1' THEN
                v_tipo_responsavel := 'Mãe';
                v_nome_responsavel := r.filiacao_1; -- Assuming Filiação 1 is Mom
            ELSIF r.tipo_de_responsavel = 'Filiação 2' THEN
                v_tipo_responsavel := 'Pai';
                v_nome_responsavel := r.filiacao_2;
            ELSIF r.tipo_de_responsavel = 'Próprio aluno' THEN
                v_tipo_responsavel := 'Outro'; -- As requested
                v_nome_responsavel := r.nome_civil_do_aluno;
            ELSE
                v_tipo_responsavel := 'Outro';
                v_nome_responsavel := r.nome_do_responsavel;
            END IF;

            -- 3. Upsert User Expandido
            -- Deterministic UUID based on Matricula + Empresa
            v_user_expandido_id := uuid_generate_v5(uuid_ns_dns(), r.matricula_do_aluno || v_empresa_id::text);

            INSERT INTO public.user_expandido (
                id, matricula, nome_completo, email, telefone, id_escola, id_empresa, papel_id, status_contrato, criado_em, modificado_em
            ) VALUES (
                v_user_expandido_id,
                r.matricula_do_aluno,
                r.nome_civil_do_aluno,
                NULLIF(r.endereco_eletronico_do_aluno, ''),
                NULLIF(r.telefones_de_contato, ''),
                v_escola_id,
                v_empresa_id,
                v_papel_id,
                'Ativo',
                NOW(),
                NOW()
            )
            ON CONFLICT (matricula, id_empresa) DO UPDATE SET
                nome_completo = EXCLUDED.nome_completo,
                email = EXCLUDED.email,
                telefone = EXCLUDED.telefone,
                id_escola = EXCLUDED.id_escola,
                modificado_em = NOW();

            -- 4. Helper to insert Answer
            -- We do this for each mapped field
            
            -- RA
            PERFORM insert_student_answer(v_user_expandido_id, '49cf4a6a-63a7-47c9-8f89-725fce5d9523', 'texto', r.matricula_do_aluno, v_empresa_id);
            -- RG
            PERFORM insert_student_answer(v_user_expandido_id, '7e92353a-3e0e-4de1-be97-8e1acdbddbd5', 'texto', r.rg_do_aluno, v_empresa_id);
            -- CPF
            PERFORM insert_student_answer(v_user_expandido_id, 'bec8701a-c56e-47c2-82d3-3123ad26bc2f', 'texto', r.cpf_do_aluno, v_empresa_id);
             -- CPF Responsável ? Check question list... not strictly requested in mapping list but available? No, sticking to approved list.

            -- Endereco
            PERFORM insert_student_answer(v_user_expandido_id, '2eadfa35-ecc8-4915-b43f-7b3df3662136', 'texto', r.logradouro, v_empresa_id);
            -- Numero
            PERFORM insert_student_answer(v_user_expandido_id, '5a4cccba-1323-472f-972a-456c1ffa98bf', 'texto', r.numero_do_logradouro, v_empresa_id);
             -- Complemento
            PERFORM insert_student_answer(v_user_expandido_id, '574dcec7-22df-458c-a4bc-6f948dd1e881', 'texto', r.complemento_do_logradouro, v_empresa_id);
            -- Bairro
            PERFORM insert_student_answer(v_user_expandido_id, '13240545-4f4f-462c-988f-124e192c9233', 'texto', r.bairro_do_logradouro, v_empresa_id);
            -- CEP
            PERFORM insert_student_answer(v_user_expandido_id, 'abbc6e4f-cb2a-49d5-b9d9-9caf7f9fc74a', 'texto', r.cep_do_logradouro, v_empresa_id);
            -- Cidade
            PERFORM insert_student_answer(v_user_expandido_id, '5ea73ecd-41b6-482e-bf7f-8ea6108f53a9', 'texto', r.municipio_do_logradouro, v_empresa_id);
            -- Genero
            PERFORM insert_student_answer(v_user_expandido_id, 'e02c0e5b-b656-43b9-928c-bda1175fdb61', 'texto', r.sexo, v_empresa_id);
            
            -- Data Nascimento (Convert text to date string 'YYYY-MM-DD' if possible)
            -- Input format dd/mm/yyyy usually.
            IF r.data_de_nascimento_do_aluno ~ '^\d{2}/\d{2}/\d{4}$' THEN
                v_formatted_date := to_char(to_date(r.data_de_nascimento_do_aluno, 'DD/MM/YYYY'), 'YYYY-MM-DD');
                PERFORM insert_student_answer(v_user_expandido_id, '9f012032-e5f9-49c1-aff3-fb9527913cd0', 'data', v_formatted_date, v_empresa_id);
            ELSE 
                PERFORM insert_student_answer(v_user_expandido_id, '9f012032-e5f9-49c1-aff3-fb9527913cd0', 'data', r.data_de_nascimento_do_aluno, v_empresa_id);
            END IF;

            -- Etnia
            PERFORM insert_student_answer(v_user_expandido_id, '93dc6d86-6e25-431d-b4a1-f078fdaf9fc2', 'opcao', r.raca_cor, v_empresa_id);
            -- Mae
            PERFORM insert_student_answer(v_user_expandido_id, '46062b05-620c-4126-9cd8-723f59d4933e', 'texto', r.filiacao_1, v_empresa_id);
            -- Pai
            PERFORM insert_student_answer(v_user_expandido_id, '479eb72d-99c8-45fa-8e9f-e0e67ecc7071', 'texto', r.filiacao_2, v_empresa_id);
            
            -- Responsavel (Calculated)
            PERFORM insert_student_answer(v_user_expandido_id, 'c17cf5a4-b5ea-42b7-9515-34eb23444c4d', 'texto', v_nome_responsavel, v_empresa_id);
            -- Tipo Responsavel (Calculated)
            PERFORM insert_student_answer(v_user_expandido_id, '47539fe6-7df3-40a6-9b68-d5691f2be951', 'opcao', v_tipo_responsavel, v_empresa_id);
            
            -- Bolsa Familia
            PERFORM insert_student_answer(v_user_expandido_id, '49ea5213-6ff0-4f91-b8f7-d865ec0cc4d9', 'opcao', r.recebe_bolsa_familia, v_empresa_id);
            -- NIS
            PERFORM insert_student_answer(v_user_expandido_id, '83754e32-08a8-471f-884c-9878682e9724', 'numero', r.nis_do_aluno, v_empresa_id);
            -- Necessidades Especiais
            PERFORM insert_student_answer(v_user_expandido_id, 'a4fb962a-0d85-4eb8-8603-73675cb27dba', 'opcao', r.possui_deficiencia, v_empresa_id);
            -- Descricao Necessidades
            PERFORM insert_student_answer(v_user_expandido_id, '903c8ea4-602f-442a-a16e-35d5e35d0ae3', 'texto_longo', r.tipo_de_deficiencia, v_empresa_id);
            -- Celular
            PERFORM insert_student_answer(v_user_expandido_id, '7d69d2db-bc42-4a00-a606-26b59aa2e1e6', 'texto', r.telefones_de_contato, v_empresa_id);
            -- Orgao Emissor RG
            PERFORM insert_student_answer(v_user_expandido_id, '696ea9e2-9457-45e9-88bd-5841b4bcf863', 'texto', r.rg_do_aluno_orgao_expedidor, v_empresa_id);
            -- Data Emissao RG
             IF r.rg_do_aluno_data_de_emissao ~ '^\d{2}/\d{2}/\d{4}$' THEN
                v_formatted_date := to_char(to_date(r.rg_do_aluno_data_de_emissao, 'DD/MM/YYYY'), 'YYYY-MM-DD');
                 PERFORM insert_student_answer(v_user_expandido_id, '16509b32-f927-4610-8121-b143850bfdfe', 'data', v_formatted_date, v_empresa_id);
            ELSE 
                 PERFORM insert_student_answer(v_user_expandido_id, '16509b32-f927-4610-8121-b143850bfdfe', 'data', r.rg_do_aluno_data_de_emissao, v_empresa_id);
            END IF;
           
            -- Cidade Origem
            PERFORM insert_student_answer(v_user_expandido_id, 'b5162a58-1d91-4aa6-abb2-3dc2354c4299', 'texto', r.municipio_de_nascimento, v_empresa_id);
            
            -- NEW: Quilombola & Distrito (requested)
            -- Quilombola
            PERFORM insert_student_answer(v_user_expandido_id, '8c9a75f3-3cb6-4109-814e-7fea2a30215f', 'opcao', r.remanescente_de_quilombo, v_empresa_id);
            -- Distrito
            PERFORM insert_student_answer(v_user_expandido_id, 'c617c53b-2bda-4a85-afae-d339a8430906', 'texto', r.distrito_do_logradouro, v_empresa_id);


            -- 5. Mark Staging as Verified
            UPDATE public.staging_alunos_2026
            SET verificado = true
            WHERE id = r.id;

        EXCEPTION WHEN OTHERS THEN
            -- Log error in staging
            UPDATE public.staging_alunos_2026
            SET erro_importacao = SQLERRM
            WHERE id = r.id;
        END;
    END LOOP;
END;
$function$;

-- Helper function to keep code clean
CREATE OR REPLACE FUNCTION public.insert_student_answer(
    p_user_id uuid,
    p_pergunta_id uuid,
    p_tipo text,
    p_resposta text,
    p_empresa_id uuid
) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    IF p_resposta IS NOT NULL AND p_resposta <> '' THEN
        INSERT INTO public.respostas_user (
            id_user, id_pergunta, tipo, resposta, id_empresa, criado_em, atualizado_em
        ) VALUES (
            p_user_id, p_pergunta_id, p_tipo, p_resposta, p_empresa_id, NOW(), NOW()
        )
        ON CONFLICT (id_user, id_pergunta) DO UPDATE SET
            resposta = EXCLUDED.resposta,
            atualizado_em = NOW();
    END IF;
END;
$$;
