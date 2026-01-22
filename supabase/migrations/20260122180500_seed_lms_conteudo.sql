-- Seed Data for Global Folders
-- Company: db5a4c52-074f-47c2-9aba-ac89111039d9
-- User: c46ba15a-e62a-4616-a19e-ebd6426cd998 (Admin/Teacher from logs)

INSERT INTO public.lms_conteudo (
    id_empresa,
    titulo,
    descricao,
    escopo,
    visivel_para_alunos,
    criado_por,
    liberar_por
)
VALUES 
(
    'db5a4c52-074f-47c2-9aba-ac89111039d9',
    'Matemática Fundamental - Global',
    'Conteúdo global de matemática para todos os alunos.',
    'Global',
    true,
    '33ba35d9-e5af-42e3-a729-a58cbc3e9dc9',
    'Conteúdo'
),
(
    'db5a4c52-074f-47c2-9aba-ac89111039d9',
    'História da Arte - Global',
    'Material de apoio sobre história da arte disponível para toda a escola.',
    'Global',
    true,
    '33ba35d9-e5af-42e3-a729-a58cbc3e9dc9',
    'Conteúdo'
);
