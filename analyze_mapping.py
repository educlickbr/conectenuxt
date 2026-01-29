import csv
import json

# Load CSV
csv_path = '/home/eikmeier/Documentos/dev/nuxt/conectenuxt/documentacao/refolinda/Dados dos alunos - 2026 (19010710).csv'

# Questions Def
questions = [
  {"id": "49cf4a6a-63a7-47c9-8f89-725fce5d9523", "pergunta": "ra", "label": "RA"},
  {"id": "7e92353a-3e0e-4de1-be97-8e1acdbddbd5", "pergunta": "rg", "label": "RG"},
  {"id": "bec8701a-c56e-47c2-82d3-3123ad26bc2f", "pergunta": "cpf", "label": "CPF"},
  {"id": "2eadfa35-ecc8-4915-b43f-7b3df3662136", "pergunta": "endereco", "label": "Endereço"},
  {"id": "5a4cccba-1323-472f-972a-456c1ffa98bf", "pergunta": "numero", "label": "Número"},
  {"id": "574dcec7-22df-458c-a4bc-6f948dd1e881", "pergunta": "complemento", "label": "Complemento"},
  {"id": "13240545-4f4f-462c-988f-124e192c9233", "pergunta": "bairro", "label": "Bairro"},
  {"id": "abbc6e4f-cb2a-49d5-b9d9-9caf7f9fc74a", "pergunta": "cep", "label": "CEP"},
  {"id": "e02c0e5b-b656-43b9-928c-bda1175fdb61", "pergunta": "genero", "label": "Gênero"},
  {"id": "9f012032-e5f9-49c1-aff3-fb9527913cd0", "pergunta": "data_nascimento", "label": "Data de Nascimento"},
  {"id": "93dc6d86-6e25-431d-b4a1-f078fdaf9fc2", "pergunta": "etnia", "label": "Etnia"},
  {"id": "46062b05-620c-4126-9cd8-723f59d4933e", "pergunta": "mae", "label": "Mãe"},
  {"id": "479eb72d-99c8-45fa-8e9f-e0e67ecc7071", "pergunta": "pai", "label": "Pai"},
  {"id": "c17cf5a4-b5ea-42b7-9515-34eb23444c4d", "pergunta": "responsavel", "label": "Responsável"},
  {"id": "47539fe6-7df3-40a6-9b68-d5691f2be951", "pergunta": "tipo_responsavel", "label": "Tipo de Responsável"},
  {"id": "49ea5213-6ff0-4f91-b8f7-d865ec0cc4d9", "pergunta": "bolsa_familia", "label": "Bolsa Família?"},
  {"id": "83754e32-08a8-471f-884c-9878682e9724", "pergunta": "nis", "label": "NIS"},
  {"id": "a4fb962a-0d85-4eb8-8603-73675cb27dba", "pergunta": "necessidades_especiais", "label": "Necessidades Especiais?"},
  {"id": "903c8ea4-602f-442a-a16e-35d5e35d0ae3", "pergunta": "desc_necessidades_especiais", "label": "Descrição das Necessidades Especiais"},
  {"id": "7d69d2db-bc42-4a00-a606-26b59aa2e1e6", "pergunta": "celular", "label": "Celular"},
  {"id": "696ea9e2-9457-45e9-88bd-5841b4bcf863", "pergunta": "orgao_emissor_rg", "label": "Órgão Emissor RG"},
  {"id": "16509b32-f927-4610-8121-b143850bfdfe", "pergunta": "data_emissao_rg", "label": "Data Emissão RG"},
  {"id": "b5162a58-1d91-4aa6-abb2-3dc2354c4299", "pergunta": "cidade_origem", "label": "Cidade de Origem"},
  {"id": "5ea73ecd-41b6-482e-bf7f-8ea6108f53a9", "pergunta": "cidade", "label": "Cidade"},
]

# Proposed Mapping
mapping = {
    "ra": "Matrícula do aluno",
    "rg": "RG do aluno",
    "cpf": "CPF do aluno",
    "endereco": "Logradouro",
    "numero": "Número do logradouro",
    "complemento": "Complemento do logradouro",
    "bairro": "Bairro do logradouro",
    "cep": "CEP do logradouro",
    "cidade": "Município do logradouro",
    "genero": "Sexo",
    "data_nascimento": "Data de nascimento do aluno",
    "etnia": "Raça/Cor",
    "mae": "Filiação 1",
    "pai": "Filiação 2",
    "responsavel": "Nome do responsável",
    "tipo_responsavel": "Tipo de responsável",
    "bolsa_familia": "Recebe Bolsa Família",
    "nis": "NIS do aluno",
    "necessidades_especiais": "Possui deficiência",
    "desc_necessidades_especiais": "Tipo de deficiência",
    "celular": "Telefones de contato",
    "orgao_emissor_rg": "RG do aluno - Órgão expedidor",
    "data_emissao_rg": "RG do aluno - Data de emissão",
    "cidade_origem": "Município de nascimento"
}

try:
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        headers = reader.fieldnames
        
        print("CSV Columns loaded:", len(headers))
        
        # Check one row for non-null checks?
        # We'll just check headers existence first
        
        print("\n--- Mapping Verification ---")
        for q in questions:
            pk = q['pergunta']
            if pk in mapping:
                csv_col = mapping[pk]
                if csv_col in headers:
                    print(f"[OK] {q['label']} ({pk}) maps to '{csv_col}'")
                else:
                    print(f"[FAIL] {q['label']} ({pk}) mapped to '{csv_col}' but column not found in CSV")
            else:
                print(f"[MISSING] No mapping for {q['label']} ({pk})")

        print("\n--- Additional Fields for user_expandido ---")
        user_exp_mapping = {
            "matricula": "Matrícula do aluno",
            "nome_completo": "Nome civil do aluno",
            "email": "Endereço eletrônico do aluno",
            "telefone": "Telefones de contato",
            "escola_nome": "Nome da escola"
        }
        for k, v in user_exp_mapping.items():
            if v in headers:
                print(f"[OK] user_expandido.{k} maps to '{v}'")
            else:
                print(f"[FAIL] user_expandido.{k} mapped to '{v}' not found")

except Exception as e:
    print(f"Error: {e}")
