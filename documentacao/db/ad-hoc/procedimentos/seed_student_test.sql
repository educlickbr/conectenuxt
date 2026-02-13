-- Migration generated automatically (SINGLE STUDENT TEST)
-- Seeding user_expandido and respostas_user for 1 student


INSERT INTO public.user_expandido (
    id, matricula, nome_completo, email, telefone, id_escola, id_empresa, papel_id, status_contrato, criado_em, modificado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', '53964', 'ANA LUCIA ALVES DE SOUZA', NULL, '(81) 981021560', (SELECT id FROM public.escolas WHERE nome = 'ESCOLA MUNICIPAL MIZAEL MONTENEGRO FILHO' AND id_empresa = '3cdb36bf-bede-46f2-8f17-1a975f6f1151' LIMIT 1), '3cdb36bf-bede-46f2-8f17-1a975f6f1151', 'b7f53d6e-70b5-453b-b564-728aeb4635d5', 'Ativo', NOW(), NOW()
) ON CONFLICT (matricula, id_empresa) 
DO UPDATE SET 
    nome_completo = EXCLUDED.nome_completo,
    email = EXCLUDED.email,
    telefone = EXCLUDED.telefone,
    id_escola = EXCLUDED.id_escola,
    modificado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', '49cf4a6a-63a7-47c9-8f89-725fce5d9523', 'texto', '53964', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', 'bec8701a-c56e-47c2-82d3-3123ad26bc2f', 'texto', '033.309.544-85', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', '2eadfa35-ecc8-4915-b43f-7b3df3662136', 'texto', 'Rua Professor Diógenes Fernandes Távora', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', '5a4cccba-1323-472f-972a-456c1ffa98bf', 'texto', '16', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', '13240545-4f4f-462c-988f-124e192c9233', 'texto', 'Casa Caiada', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', 'abbc6e4f-cb2a-49d5-b9d9-9caf7f9fc74a', 'texto', '53130-230', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', 'e02c0e5b-b656-43b9-928c-bda1175fdb61', 'texto', 'F', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', '9f012032-e5f9-49c1-aff3-fb9527913cd0', 'data', '1973-06-23', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', '93dc6d86-6e25-431d-b4a1-f078fdaf9fc2', 'opcao', 'Parda', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', '46062b05-620c-4126-9cd8-723f59d4933e', 'texto', 'MARIA ALVES DOS SANTOS', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', 'c17cf5a4-b5ea-42b7-9515-34eb23444c4d', 'texto', 'ANA LUCIA ALVES DE SOUZA', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', 'a4fb962a-0d85-4eb8-8603-73675cb27dba', 'opcao', 'Não', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', '7d69d2db-bc42-4a00-a606-26b59aa2e1e6', 'texto', '(81) 981021560', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', 'b5162a58-1d91-4aa6-abb2-3dc2354c4299', 'texto', 'Maravilha', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();

INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    'dc6d44a0-1c9c-5d83-9cc9-bd8c30ba8854', '5ea73ecd-41b6-482e-bf7f-8ea6108f53a9', 'texto', 'Olinda', '3cdb36bf-bede-46f2-8f17-1a975f6f1151', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();
