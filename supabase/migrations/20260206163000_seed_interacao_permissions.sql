-- Migration: Seed Permissions for Interacao Module
-- Date: 2026-02-06
-- Description: Inserts missing permissions for "Interação" section. 
-- Note: "Aprendizado" is intentionally left as Admin-only for the Ilha scope based on user request.

INSERT INTO public.app_permissoes (
    ilha, botao, escopo, entidade_pai, empresas, papeis
) VALUES 
-- Ilha: Interação (Admin, Professor, Aluno)
(
    'interacao', 
    NULL, 
    'ilha', 
    NULL, 
    '["db5a4c52-074f-47c2-9aba-ac89111039d9"]'::jsonb, 
    '["d3410ac7-5a4a-4f02-8923-610b9fd87c4d", "3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1", "b7f53d6e-70b5-453b-b564-728aeb4635d5"]'::jsonb
),
-- Botão: Ambiente 3D (Admin, Professor, Aluno)
(
    'interacao', 
    'ambiente_3d', 
    'botao', 
    'interacao', 
    '["db5a4c52-074f-47c2-9aba-ac89111039d9"]'::jsonb, 
    '["d3410ac7-5a4a-4f02-8923-610b9fd87c4d", "3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1", "b7f53d6e-70b5-453b-b564-728aeb4635d5"]'::jsonb
),
-- Botão: Meeting (Admin, Professor) - Assuming Aluno doesn't host meetings, or maybe they do?
-- Original context didn't specify, but often meetings are for staff. 
-- However, "Ambiente 3D" is for Aluno. Let's give Meeting to Admin/Professor for now.
(
    'interacao', 
    'meeting', 
    'botao', 
    'interacao', 
    '["db5a4c52-074f-47c2-9aba-ac89111039d9"]'::jsonb, 
    '["d3410ac7-5a4a-4f02-8923-610b9fd87c4d", "3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1"]'::jsonb
),
-- Botão: Portal Pedagógico (Admin, Professor) - Matching previous hardcoded logic [ROLES.ADMIN, ROLES.PROFESSOR]
(
    'interacao', 
    'portal_pedagogico', 
    'botao', 
    'interacao', 
    '["db5a4c52-074f-47c2-9aba-ac89111039d9"]'::jsonb, 
    '["d3410ac7-5a4a-4f02-8923-610b9fd87c4d", "3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1"]'::jsonb
);
