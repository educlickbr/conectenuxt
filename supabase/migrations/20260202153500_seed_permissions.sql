-- Seed Permission Data

DO $$
DECLARE
    v_admin uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
    v_professor uuid := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
    v_aluno uuid := 'b7f53d6e-70b5-453b-b564-728aeb4635d5';
    v_company uuid := 'db5a4c52-074f-47c2-9aba-ac89111039d9';
    v_all_companies jsonb;
BEGIN
    -- Get allowed companies (or just the main one)
    v_all_companies := jsonb_build_array(v_company);

    -- 1. Administrativo (Ilha)
    INSERT INTO public.app_permissoes (ilha, escopo, empresas, papeis)
    VALUES ('administrativo', 'ilha', v_all_companies, jsonb_build_array(v_admin));

    -- Administrativo Items (Botao)
    INSERT INTO public.app_permissoes (ilha, botao, escopo, entidade_pai, empresas, papeis)
    VALUES 
    ('administrativo', 'infraestrutura', 'botao', 'administrativo', v_all_companies, jsonb_build_array(v_admin)),
    ('administrativo', 'estrutura_academica', 'botao', 'administrativo', v_all_companies, jsonb_build_array(v_admin)),
    ('administrativo', 'grupos_estudo', 'botao', 'administrativo', v_all_companies, jsonb_build_array(v_admin)),
    ('administrativo', 'usuarios', 'botao', 'administrativo', v_all_companies, jsonb_build_array(v_admin)),
    ('administrativo', 'parametrizar_avaliacao', 'botao', 'administrativo', v_all_companies, jsonb_build_array(v_admin));

    -- 2. Secretaria (Ilha)
    INSERT INTO public.app_permissoes (ilha, escopo, empresas, papeis)
    VALUES ('secretaria', 'ilha', v_all_companies, jsonb_build_array(v_admin, v_professor));

    -- Secretaria Items
    INSERT INTO public.app_permissoes (ilha, botao, escopo, entidade_pai, empresas, papeis)
    VALUES 
    ('secretaria', 'matricula', 'botao', 'secretaria', v_all_companies, jsonb_build_array(v_admin, v_professor)),
    ('secretaria', 'diario_classe', 'botao', 'secretaria', v_all_companies, jsonb_build_array(v_admin, v_professor)),
    ('secretaria', 'matriz_curricular', 'botao', 'secretaria', v_all_companies, jsonb_build_array(v_admin, v_professor)),
    ('secretaria', 'atribuicao', 'botao', 'secretaria', v_all_companies, jsonb_build_array(v_admin, v_professor)),
    ('secretaria', 'lancamento_avaliacao', 'botao', 'secretaria', v_all_companies, jsonb_build_array(v_admin, v_professor));

    -- 3. Biblioteca (Ilha)
    INSERT INTO public.app_permissoes (ilha, escopo, empresas, papeis)
    VALUES ('biblioteca', 'ilha', v_all_companies, jsonb_build_array(v_admin));

    -- Biblioteca Items
    INSERT INTO public.app_permissoes (ilha, botao, escopo, entidade_pai, empresas, papeis)
    VALUES 
    ('biblioteca', 'catalogo', 'botao', 'biblioteca', v_all_companies, jsonb_build_array(v_admin)),
    ('biblioteca', 'gestao_livros', 'botao', 'biblioteca', v_all_companies, jsonb_build_array(v_admin)),
    ('biblioteca', 'inventario', 'botao', 'biblioteca', v_all_companies, jsonb_build_array(v_admin)),
    ('biblioteca', 'reservas', 'botao', 'biblioteca', v_all_companies, jsonb_build_array(v_admin));

    -- 4. Aprendizado (Ilha)
    INSERT INTO public.app_permissoes (ilha, escopo, empresas, papeis)
    VALUES ('aprendizado', 'ilha', v_all_companies, jsonb_build_array(v_admin, v_professor, v_aluno));

    -- Aprendizado Items
    INSERT INTO public.app_permissoes (ilha, botao, escopo, entidade_pai, empresas, papeis)
    VALUES 
    ('aprendizado', 'gestao_atividades', 'botao', 'aprendizado', v_all_companies, jsonb_build_array(v_admin, v_professor)),
    ('aprendizado', 'conteudo_digital', 'botao', 'aprendizado', v_all_companies, jsonb_build_array(v_admin, v_professor, v_aluno)),
    ('aprendizado', 'biblioteca_digital', 'botao', 'aprendizado', v_all_companies, jsonb_build_array(v_admin, v_professor, v_aluno));
    
END $$;
