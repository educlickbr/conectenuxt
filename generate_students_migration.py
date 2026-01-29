import csv
import uuid
import datetime

# Configuration
csv_path = '/home/eikmeier/Documentos/dev/nuxt/conectenuxt/documentacao/refolinda/Dados dos alunos - 2026 (19010710).csv'
output_path = '/home/eikmeier/Documentos/dev/nuxt/conectenuxt/supabase/migrations/20260129130000_seed_students.sql'
empresa_id = '3cdb36bf-bede-46f2-8f17-1a975f6f1151'
papel_id = 'b7f53d6e-70b5-453b-b564-728aeb4635d5'

# Questions Definition
questions = [
    {"id": "49cf4a6a-63a7-47c9-8f89-725fce5d9523", "pergunta": "ra", "col": "Matrícula do aluno", "tipo": "texto"},
    {"id": "7e92353a-3e0e-4de1-be97-8e1acdbddbd5", "pergunta": "rg", "col": "RG do aluno", "tipo": "texto"},
    {"id": "bec8701a-c56e-47c2-82d3-3123ad26bc2f", "pergunta": "cpf", "col": "CPF do aluno", "tipo": "texto"},
    {"id": "2eadfa35-ecc8-4915-b43f-7b3df3662136", "pergunta": "endereco", "col": "Logradouro", "tipo": "texto"},
    {"id": "5a4cccba-1323-472f-972a-456c1ffa98bf", "pergunta": "numero", "col": "Número do logradouro", "tipo": "texto"},
    {"id": "574dcec7-22df-458c-a4bc-6f948dd1e881", "pergunta": "complemento", "col": "Complemento do logradouro", "tipo": "texto"},
    {"id": "13240545-4f4f-462c-988f-124e192c9233", "pergunta": "bairro", "col": "Bairro do logradouro", "tipo": "texto"},
    {"id": "abbc6e4f-cb2a-49d5-b9d9-9caf7f9fc74a", "pergunta": "cep", "col": "CEP do logradouro", "tipo": "texto"},
    {"id": "e02c0e5b-b656-43b9-928c-bda1175fdb61", "pergunta": "genero", "col": "Sexo", "tipo": "texto"},
    {"id": "9f012032-e5f9-49c1-aff3-fb9527913cd0", "pergunta": "data_nascimento", "col": "Data de nascimento do aluno", "tipo": "data"},
    {"id": "93dc6d86-6e25-431d-b4a1-f078fdaf9fc2", "pergunta": "etnia", "col": "Raça/Cor", "tipo": "opcao"},
    {"id": "46062b05-620c-4126-9cd8-723f59d4933e", "pergunta": "mae", "col": "Filiação 1", "tipo": "texto"},
    {"id": "479eb72d-99c8-45fa-8e9f-e0e67ecc7071", "pergunta": "pai", "col": "Filiação 2", "tipo": "texto"},
    {"id": "c17cf5a4-b5ea-42b7-9515-34eb23444c4d", "pergunta": "responsavel", "col": "Nome do responsável", "tipo": "texto"},
    {"id": "47539fe6-7df3-40a6-9b68-d5691f2be951", "pergunta": "tipo_responsavel", "col": "Tipo de responsável", "tipo": "opcao"},
    {"id": "49ea5213-6ff0-4f91-b8f7-d865ec0cc4d9", "pergunta": "bolsa_familia", "col": "Recebe Bolsa Família", "tipo": "opcao"},
    {"id": "83754e32-08a8-471f-884c-9878682e9724", "pergunta": "nis", "col": "NIS do aluno", "tipo": "numero"},
    {"id": "a4fb962a-0d85-4eb8-8603-73675cb27dba", "pergunta": "necessidades_especiais", "col": "Possui deficiência", "tipo": "opcao"},
    {"id": "903c8ea4-602f-442a-a16e-35d5e35d0ae3", "pergunta": "desc_necessidades_especiais", "col": "Tipo de deficiência", "tipo": "texto_longo"},
    {"id": "7d69d2db-bc42-4a00-a606-26b59aa2e1e6", "pergunta": "celular", "col": "Telefones de contato", "tipo": "texto"},
    {"id": "696ea9e2-9457-45e9-88bd-5841b4bcf863", "pergunta": "orgao_emissor_rg", "col": "RG do aluno - Órgão expedidor", "tipo": "texto"},
    {"id": "16509b32-f927-4610-8121-b143850bfdfe", "pergunta": "data_emissao_rg", "col": "RG do aluno - Data de emissão", "tipo": "data"},
    {"id": "b5162a58-1d91-4aa6-abb2-3dc2354c4299", "pergunta": "cidade_origem", "col": "Município de nascimento", "tipo": "texto"},
    {"id": "5ea73ecd-41b6-482e-bf7f-8ea6108f53a9", "pergunta": "cidade", "col": "Município do logradouro", "tipo": "texto"},
]

def escape_sql(val):
    if not val:
        return 'NULL'
    # Escape single quotes
    return "'" + str(val).replace("'", "''") + "'"

def format_date(val):
    if not val:
        return 'NULL'
    try:
        # Assuming DD/MM/YYYY
        parts = val.split('/')
        if len(parts) == 3:
            return f"'{parts[2]}-{parts[1]}-{parts[0]}'"
        return escape_sql(val) # Fallback
    except:
        return 'NULL'

try:
    with open(csv_path, 'r', encoding='utf-8') as f_in, open(output_path, 'w', encoding='utf-8') as f_out:
        reader = csv.DictReader(f_in)
        
        f_out.write("-- Migration generated automatically\n")
        f_out.write("-- Seeding user_expandido and respostas_user for students\n\n")
        
        count = 0
        for row in reader:
            count += 1
            
            # Generate ID for user_expandido
            user_id = str(uuid.uuid4())
            
            # Map user_expandido fields
            matricula = escape_sql(row.get("Matrícula do aluno"))
            nome = escape_sql(row.get("Nome civil do aluno"))
            email = escape_sql(row.get("Endereço eletrônico do aluno"))
            telefone = escape_sql(row.get("Telefones de contato"))
            escola_nome = row.get("Nome da escola", "").replace("'", "''")
            
            # Subquery for escola_id
            escola_subquery = f"(SELECT id FROM public.escolas WHERE nome = '{escola_nome}' AND id_empresa = '{empresa_id}' LIMIT 1)"
            
            # Insert user_expandido
            sql_user = f"""
INSERT INTO public.user_expandido (
    id, matricula, nome_completo, email, telefone, id_escola, id_empresa, papel_id, status_contrato, criado_em
) VALUES (
    '{user_id}', {matricula}, {nome}, {email}, {telefone}, {escola_subquery}, '{empresa_id}', '{papel_id}', 'Ativo', NOW()
) ON CONFLICT (matricula, id_empresa) DO NOTHING;
"""
            f_out.write(sql_user)
            
            # Insert answers
            # We strictly only insert answers if the user was inserted.
            # However, in SQL script, if ON CONFLICT DO NOTHING triggers, the user wasn't inserted.
            # Ideally we should use CTE or lookup, but for a seed script on empty DB, this is fine.
            # If re-running, answers might duplicate if we don't handle conflicts there too?
            # respostas_user has unique (id_user, id_pergunta).
            
            # Since we generate a NEW uuid every run, if we re-run this script, we will try to insert new users.
            # If matricula conflicts, user insert fails (DO NOTHING).
            # The following answer inserts will reference the NEW random UUID, which DOES NOT EXIST in the DB (since insert failed).
            # This will cause FK violation error if we proceed.
            
            # BETTER APPROACH:
            # use a function or CTE? Or just assume clean state?
            # Given constraints, let's look up the user ID by matricula if we think we are updating?
            # But the requirement is "seed". Assuming clean state for these users is standard.
            # OR make the user_id deterministic based on matricula?
            # uuid.uuid5(uuid.NAMESPACE_DNS, matricula)?
            # That way if we re-run, we get same UUID.
            
            deterministic_uuid = str(uuid.uuid5(uuid.NAMESPACE_DNS, row.get("Matrícula do aluno") + empresa_id))
            
            # Rewrite user SQL with deterministic UUID
            # And ON CONFLICT (matricula, id_empresa) DO UPDATE SET id=EXCLUDED.id ? No, keep existing ID.
            # If existing, we need to know the EXISTING ID to insert answers.
            # If we make ID deterministic, we know the ID!
            
            sql_user = f"""
INSERT INTO public.user_expandido (
    id, matricula, nome_completo, email, telefone, id_escola, id_empresa, papel_id, status_contrato, criado_em, modificado_em
) VALUES (
    '{deterministic_uuid}', {matricula}, {nome}, {email}, {telefone}, {escola_subquery}, '{empresa_id}', '{papel_id}', 'Ativo', NOW(), NOW()
) ON CONFLICT (matricula, id_empresa) 
DO UPDATE SET 
    nome_completo = EXCLUDED.nome_completo,
    email = EXCLUDED.email,
    telefone = EXCLUDED.telefone,
    id_escola = EXCLUDED.id_escola,
    modificado_em = NOW();
"""
            f_out.write(sql_user)
            
            for q in questions:
                val = row.get(q['col'])
                if val: # Only insert if value exists
                    formatted_val = escape_sql(val)
                    if q['tipo'] == 'data':
                        # Special handling if needed, but 'resposta' col is text usually?
                        # schema says: resposta text
                        # But question definition says type 'data'.
                        # Usually we store ISO string or formatted date string in text column.
                        # Let's try to format it nicely YYYY-MM-DD for consistency if it parses
                        date_val = format_date(val)
                        if date_val != 'NULL':
                             formatted_val = date_val
                    
                    sql_ans = f"""
INSERT INTO public.respostas_user (
    id_user, id_pergunta, tipo, resposta, id_empresa, criado_em
) VALUES (
    '{deterministic_uuid}', '{q['id']}', '{q['tipo']}', {formatted_val}, '{empresa_id}', NOW()
) ON CONFLICT (id_user, id_pergunta) 
DO UPDATE SET 
    resposta = EXCLUDED.resposta,
    atualizado_em = NOW();
"""
                    f_out.write(sql_ans)

    print(f"Migration script generated: {output_path} with {count} students.")

except Exception as e:
    print(f"Error: {e}")
