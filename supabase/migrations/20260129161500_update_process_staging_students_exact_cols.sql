DROP FUNCTION public.migrate_staging_students;

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
            WHERE nome = r."Nome da escola"
              AND id_empresa = v_empresa_id
            LIMIT 1;

            -- 2. Map Responsavel Logic
            IF r."Tipo de responsável" = 'Filiação 1' THEN
                v_tipo_responsavel := 'Mãe';
                v_nome_responsavel := r."Filiação 1";
            ELSIF r."Tipo de responsável" = 'Filiação 2' THEN
                v_tipo_responsavel := 'Pai';
                v_nome_responsavel := r."Filiação 2";
            ELSIF r."Tipo de responsável" = 'Próprio aluno' THEN
                v_tipo_responsavel := 'Outro';
                v_nome_responsavel := r."Nome civil do aluno";
            ELSE
                v_tipo_responsavel := 'Outro';
                v_nome_responsavel := r."Nome do responsável";
            END IF;

            -- 3. Upsert User Expandido
            -- Deterministic UUID based on Matricula + Empresa
            v_user_expandido_id := uuid_generate_v5(uuid_ns_dns(), r."Matrícula do aluno" || v_empresa_id::text);

            INSERT INTO public.user_expandido (
                id, matricula, nome_completo, email, telefone, id_escola, id_empresa, papel_id, status_contrato, criado_em, modificado_em
            ) VALUES (
                v_user_expandido_id,
                r."Matrícula do aluno",
                r."Nome civil do aluno",
                NULLIF(r."Endereço eletrônico do aluno", ''),
                NULLIF(r."Telefones de contato", ''),
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
            
            -- RA
            PERFORM insert_student_answer(v_user_expandido_id, '49cf4a6a-63a7-47c9-8f89-725fce5d9523', 'texto', r."Matrícula do aluno", v_empresa_id);
            -- RG
            PERFORM insert_student_answer(v_user_expandido_id, '7e92353a-3e0e-4de1-be97-8e1acdbddbd5', 'texto', r."RG do aluno", v_empresa_id);
            -- CPF
            PERFORM insert_student_answer(v_user_expandido_id, 'bec8701a-c56e-47c2-82d3-3123ad26bc2f', 'texto', r."CPF do aluno", v_empresa_id);

            -- Endereco
            PERFORM insert_student_answer(v_user_expandido_id, '2eadfa35-ecc8-4915-b43f-7b3df3662136', 'texto', r."Logradouro", v_empresa_id);
            -- Numero
            PERFORM insert_student_answer(v_user_expandido_id, '5a4cccba-1323-472f-972a-456c1ffa98bf', 'texto', r."Número do logradouro", v_empresa_id);
             -- Complemento
            PERFORM insert_student_answer(v_user_expandido_id, '574dcec7-22df-458c-a4bc-6f948dd1e881', 'texto', r."Complemento do logradouro", v_empresa_id);
            -- Bairro
            PERFORM insert_student_answer(v_user_expandido_id, '13240545-4f4f-462c-988f-124e192c9233', 'texto', r."Bairro do logradouro", v_empresa_id);
            -- CEP
            PERFORM insert_student_answer(v_user_expandido_id, 'abbc6e4f-cb2a-49d5-b9d9-9caf7f9fc74a', 'texto', r."CEP do logradouro", v_empresa_id);
            -- Cidade
            PERFORM insert_student_answer(v_user_expandido_id, '5ea73ecd-41b6-482e-bf7f-8ea6108f53a9', 'texto', r."Município do logradouro", v_empresa_id);
            -- Genero
            PERFORM insert_student_answer(v_user_expandido_id, 'e02c0e5b-b656-43b9-928c-bda1175fdb61', 'texto', r."Sexo", v_empresa_id);
            
            -- Data Nascimento
            IF r."Data de nascimento do aluno" ~ '^\d{2}/\d{2}/\d{4}$' THEN
                v_formatted_date := to_char(to_date(r."Data de nascimento do aluno", 'DD/MM/YYYY'), 'YYYY-MM-DD');
                PERFORM insert_student_answer(v_user_expandido_id, '9f012032-e5f9-49c1-aff3-fb9527913cd0', 'data', v_formatted_date, v_empresa_id);
            ELSE 
                PERFORM insert_student_answer(v_user_expandido_id, '9f012032-e5f9-49c1-aff3-fb9527913cd0', 'data', r."Data de nascimento do aluno", v_empresa_id);
            END IF;

            -- Etnia
            PERFORM insert_student_answer(v_user_expandido_id, '93dc6d86-6e25-431d-b4a1-f078fdaf9fc2', 'opcao', r."Raça/Cor", v_empresa_id);
            -- Mae
            PERFORM insert_student_answer(v_user_expandido_id, '46062b05-620c-4126-9cd8-723f59d4933e', 'texto', r."Filiação 1", v_empresa_id);
            -- Pai
            PERFORM insert_student_answer(v_user_expandido_id, '479eb72d-99c8-45fa-8e9f-e0e67ecc7071', 'texto', r."Filiação 2", v_empresa_id);
            
            -- Responsavel (Calculated)
            PERFORM insert_student_answer(v_user_expandido_id, 'c17cf5a4-b5ea-42b7-9515-34eb23444c4d', 'texto', v_nome_responsavel, v_empresa_id);
            -- Tipo Responsavel (Calculated)
            PERFORM insert_student_answer(v_user_expandido_id, '47539fe6-7df3-40a6-9b68-d5691f2be951', 'opcao', v_tipo_responsavel, v_empresa_id);
            
            -- Bolsa Familia
            PERFORM insert_student_answer(v_user_expandido_id, '49ea5213-6ff0-4f91-b8f7-d865ec0cc4d9', 'opcao', r."Recebe Bolsa Família", v_empresa_id);
            -- NIS
            PERFORM insert_student_answer(v_user_expandido_id, '83754e32-08a8-471f-884c-9878682e9724', 'numero', r."NIS do aluno", v_empresa_id);
            -- Necessidades Especiais
            PERFORM insert_student_answer(v_user_expandido_id, 'a4fb962a-0d85-4eb8-8603-73675cb27dba', 'opcao', r."Possui deficiência", v_empresa_id);
            -- Descricao Necessidades
            PERFORM insert_student_answer(v_user_expandido_id, '903c8ea4-602f-442a-a16e-35d5e35d0ae3', 'texto_longo', r."Tipo de deficiência", v_empresa_id);
            -- Celular
            PERFORM insert_student_answer(v_user_expandido_id, '7d69d2db-bc42-4a00-a606-26b59aa2e1e6', 'texto', r."Telefones de contato", v_empresa_id);
            -- Orgao Emissor RG
            PERFORM insert_student_answer(v_user_expandido_id, '696ea9e2-9457-45e9-88bd-5841b4bcf863', 'texto', r."RG do aluno - Órgão expedidor", v_empresa_id);
            -- Data Emissao RG
             IF r."RG do aluno - Data de emissão" ~ '^\d{2}/\d{2}/\d{4}$' THEN
                v_formatted_date := to_char(to_date(r."RG do aluno - Data de emissão", 'DD/MM/YYYY'), 'YYYY-MM-DD');
                 PERFORM insert_student_answer(v_user_expandido_id, '16509b32-f927-4610-8121-b143850bfdfe', 'data', v_formatted_date, v_empresa_id);
            ELSE 
                 PERFORM insert_student_answer(v_user_expandido_id, '16509b32-f927-4610-8121-b143850bfdfe', 'data', r."RG do aluno - Data de emissão", v_empresa_id);
            END IF;
           
            -- Cidade Origem
            PERFORM insert_student_answer(v_user_expandido_id, 'b5162a58-1d91-4aa6-abb2-3dc2354c4299', 'texto', r."Município de nascimento", v_empresa_id);
            -- Quilombola
            PERFORM insert_student_answer(v_user_expandido_id, '8c9a75f3-3cb6-4109-814e-7fea2a30215f', 'opcao', r."Remanescente de quilombo", v_empresa_id);
            -- Distrito
            PERFORM insert_student_answer(v_user_expandido_id, 'c617c53b-2bda-4a85-afae-d339a8430906', 'texto', r."Distrito do logradouro", v_empresa_id);


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
