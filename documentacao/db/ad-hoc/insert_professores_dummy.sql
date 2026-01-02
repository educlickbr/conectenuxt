DO $$
DECLARE
    v_empresa_id UUID := '0709fe87-3b42-4f1d-9919-51dea9228cfd';
    v_papel_professor_id UUID := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
    v_new_user_id UUID;
    v_professor RECORD;
    
    -- Question IDs derived from db/ad-hoc/JSONS/perguntas_professor.json
    v_q_data_admissao UUID := '2cbcdcf0-a615-49a3-b563-e6c9e8e9f393';
    v_q_habilitacao_infantil UUID := '81dfaafe-cd70-4b52-ad01-6c9224634b9a';
    v_q_acumulo UUID := '9eb11085-240c-454c-a73e-7f33d94c3447';
    v_q_afastamento UUID := '2a26c9b7-9bff-41d6-be39-ad7c7b52c53c';
    v_q_tempo_afastamento UUID := '7929c74b-84ef-4444-9b46-fc104c3fcb4d';
    v_q_horas_trabalho UUID := 'bf97ceb1-26e1-4d6c-959f-4151e91f36fb';
    v_q_rg UUID := '7e92353a-3e0e-4de1-be97-8e1acdbddbd5';
    v_q_cpf UUID := 'bec8701a-c56e-47c2-82d3-3123ad26bc2f';
    v_q_endereco UUID := '2eadfa35-ecc8-4915-b43f-7b3df3662136';
    v_q_numero UUID := '5a4cccba-1323-472f-972a-456c1ffa98bf';
    v_q_complemento UUID := '574dcec7-22df-458c-a4bc-6f948dd1e881';
    v_q_bairro UUID := '13240545-4f4f-462c-988f-124e192c9233';
    v_q_cep UUID := 'abbc6e4f-cb2a-49d5-b9d9-9caf7f9fc74a';
    v_q_genero UUID := 'e02c0e5b-b656-43b9-928c-bda1175fdb61';
    v_q_data_nascimento UUID := '9f012032-e5f9-49c1-aff3-fb9527913cd0';
    v_q_tipo_contrato UUID := '467b29b5-8236-4f5c-a3ac-3e135bcf5601';

BEGIN
    -- Temporary table to hold our dummy data
    CREATE TEMP TABLE temp_professores (
        nome text,
        matricula text,
        email text,
        cpf text,
        rg text,
        data_nascimento date,
        genero text,
        endereco text,
        numero text,
        bairro text,
        cep text,
        data_admissao date,
        habilitacao_infantil text,
        acumulo text,
        afastamento text,
        tempo_afastamento text,
        horas_trabalho text,
        tipo_contrato text
    );

    INSERT INTO temp_professores VALUES
    (
        'Paulo Freire', 
        'PROF001', 
        'paulo.freire@educacao.pe.gov.br', 
        '111.111.111-11', 
        '1234567 PE', 
        '1921-09-19', 
        'Masculino',
        'Rua do Patrono',
        '100',
        'Centro',
        '55000-000',
        '2023-01-01',
        'Não',
        'Não',
        'Não se Aplica',
        'Não se aplica',
        '40',
        'Efetivo'
    ),
    (
        'Clarice Lispector', 
        'PROF002', 
        'clarice.lispector@educacao.pe.gov.br', 
        '222.222.222-22', 
        '2345678 PE', 
        '1920-12-10', 
        'Feminino',
        'Avenida da Literatura',
        '202',
        'Maurício de Nassau',
        '55012-345',
        '2023-02-15',
        'Sim',
        'Não',
        'Não se Aplica',
        'Não se aplica',
        '20',
        'CLT/Substituto'
    ),
    (
        'Ariano Suassuna', 
        'PROF003', 
        'ariano.suassuna@educacao.pe.gov.br', 
        '333.333.333-33', 
        '3456789 PE', 
        '1927-06-16', 
        'Masculino',
        'Praça do Auto da Compadecida',
        '33',
        'Universitário',
        '55016-789',
        '2023-03-01',
        'Não',
        'Sim',
        'Não se Aplica',
        'Não se aplica',
        '40',
        'Efetivo'
    ),
    (
        'Luiz Gonzaga', 
        'PROF004', 
        'luiz.gonzaga@educacao.pe.gov.br', 
        '444.444.444-44', 
        '4567890 PE', 
        '1912-12-13', 
        'Masculino',
        'Estrada do Baião',
        '404',
        'Salgado',
        '55020-000',
        '2023-01-20',
        'Não',
        'Não',
        'Não se Aplica',
        'Não se aplica',
        '30',
        'Substituto/Suporte Pedagógico'
    ),
    (
        'Gilberto Freyre', 
        'PROF005', 
        'gilberto.freyre@educacao.pe.gov.br', 
        '555.555.555-55', 
        '5678901 PE', 
        '1900-03-15', 
        'Masculino',
        'Rua Casa Grande',
        '50',
        'Indianópolis',
        '55024-123',
        '2023-04-10',
        'Não',
        'Não',
        'Licença Saúde',
        'De 15 dias à 1 mês',
        '40',
        'Efetivo'
    );

    -- Iterate and Insert
    FOR v_professor IN SELECT * FROM temp_professores LOOP
        
        -- 1. Insert into user_expandido
        INSERT INTO public.user_expandido (
            id,
            id_empresa,
            matricula,
            nome_completo,
            email,
            papel_id,
            status_contrato,
            criado_em,
            modificado_em
        ) VALUES (
            gen_random_uuid(),
            v_empresa_id,
            v_professor.matricula,
            v_professor.nome,
            v_professor.email,
            v_papel_professor_id,
            'Ativo',
            NOW(),
            NOW()
        ) RETURNING id INTO v_new_user_id;

        -- 2. Insert Answers (respostas_user)

        -- Data Admissão
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_data_admissao, 'data', v_professor.data_admissao::text, v_empresa_id);

        -- Habilitação Infantil
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_habilitacao_infantil, 'opcao', v_professor.habilitacao_infantil, v_empresa_id);

        -- Acúmulo
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_acumulo, 'opcao', v_professor.acumulo, v_empresa_id);

        -- Afastamento
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_afastamento, 'opcao', v_professor.afastamento, v_empresa_id);

        -- Tempo Afastamento
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_tempo_afastamento, 'opcao', v_professor.tempo_afastamento, v_empresa_id);

        -- Horas Trabalho
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_horas_trabalho, 'numero', v_professor.horas_trabalho, v_empresa_id);

        -- RG
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_rg, 'texto', v_professor.rg, v_empresa_id);

        -- CPF
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_cpf, 'texto', v_professor.cpf, v_empresa_id);

        -- Endereço
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_endereco, 'texto', v_professor.endereco, v_empresa_id);
 
        -- Número
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_numero, 'texto', v_professor.numero, v_empresa_id);

        -- Complemento (setting empty string if none, but reusing number here as placeholder if needed? No, just empty or 'Casa'?)
        -- Using 'Casa' or empty.
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_complemento, 'texto', '', v_empresa_id);

        -- Bairro
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_bairro, 'texto', v_professor.bairro, v_empresa_id);

        -- CEP
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_cep, 'texto', v_professor.cep, v_empresa_id);

        -- Gênero
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_genero, 'texto', v_professor.genero, v_empresa_id);

        -- Data Nascimento
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_data_nascimento, 'data', v_professor.data_nascimento::text, v_empresa_id);

        -- Tipo Contrato
        INSERT INTO public.respostas_user (id_user, id_pergunta, tipo, resposta, id_empresa)
        VALUES (v_new_user_id, v_q_tipo_contrato, 'opcao', v_professor.tipo_contrato, v_empresa_id);
        
    END LOOP;

    DROP TABLE temp_professores;
    
    RAISE NOTICE '5 Professores inseridos com sucesso!';
END $$;
