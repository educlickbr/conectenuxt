-- Migration: Seed Permissions for Merenda Module
-- Date: 2026-02-05

INSERT INTO public.app_permissoes (
    ilha, botao, escopo, entidade_pai, empresas, papeis
) VALUES 
-- Ilha: Merenda
(
    'merenda', 
    NULL, 
    'ilha', 
    NULL, 
    '["db5a4c52-074f-47c2-9aba-ac89111039d9"]'::jsonb, 
    '["d3410ac7-5a4a-4f02-8923-610b9fd87c4d"]'::jsonb
),
-- Botão: Base (Dimensões)
(
    'merenda', 
    'merenda_base', 
    'botao', 
    'merenda', 
    '["db5a4c52-074f-47c2-9aba-ac89111039d9"]'::jsonb, 
    '["d3410ac7-5a4a-4f02-8923-610b9fd87c4d"]'::jsonb
),
-- Botão: Receituário (Fichas Técnicas)
(
    'merenda', 
    'merenda_receituario', 
    'botao', 
    'merenda', 
    '["db5a4c52-074f-47c2-9aba-ac89111039d9"]'::jsonb, 
    '["d3410ac7-5a4a-4f02-8923-610b9fd87c4d"]'::jsonb
),
-- Botão: Matrizes (Vínculos)
(
    'merenda', 
    'merenda_matrizes', 
    'botao', 
    'merenda', 
    '["db5a4c52-074f-47c2-9aba-ac89111039d9"]'::jsonb, 
    '["d3410ac7-5a4a-4f02-8923-610b9fd87c4d"]'::jsonb
),
-- Botão: Cardápio (Operacional)
(
    'merenda', 
    'merenda_cardapio', 
    'botao', 
    'merenda', 
    '["db5a4c52-074f-47c2-9aba-ac89111039d9"]'::jsonb, 
    '["d3410ac7-5a4a-4f02-8923-610b9fd87c4d"]'::jsonb
);
