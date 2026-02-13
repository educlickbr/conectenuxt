import json
import os

# Configuration
json_path = '/home/eikmeier/Documentos/dev/nuxt/conectenuxt/documentacao/refolinda/escolas.json'
migration_path = '/home/eikmeier/Documentos/dev/nuxt/conectenuxt/supabase/migrations/20260129123000_seed_escolas.sql'
empresa_id = '3cdb36bf-bede-46f2-8f17-1a975f6f1151'

# SQL Template
create_table_sql = """
CREATE TABLE public.escolas (
  id uuid not null default gen_random_uuid (),
  nome text not null,
  endereco text null,
  numero text null,
  complemento text null,
  bairro text null,
  cep text null,
  email text null,
  telefone_1 text null,
  telefone_2 text null,
  horario_htpc text null,
  horario_htpc_hora integer null,
  horario_htpc_minuto integer null,
  dia_semana_htpc text null,
  id_empresa uuid not null,
  id_sharepoint_apagar_depois integer null,
  uuid_sharepoint_apagar_depois text null,
  constraint escolas_pkey primary key (id),
  constraint escolas_empresa_fkey foreign KEY (id_empresa) references empresa (id) on delete CASCADE
) TABLESPACE pg_default;
"""

def escape_sql(value):
    if value is None:
        return 'NULL'
    return "'" + str(value).replace("'", "''") + "'"

try:
    with open(json_path, 'r', encoding='utf-8') as f:
        escolas = json.load(f)

    with open(migration_path, 'w', encoding='utf-8') as f:
        f.write(create_table_sql)
        f.write("\n\n")
        
        for escola in escolas:
            nome = escape_sql(escola.get('nome'))
            endereco = escape_sql(escola.get('endereco'))
            cep = escape_sql(escola.get('cep'))
            
            # Since the json only has nome, endereco, cep, we fill those and the mandatory company id
            # address parsing is tricky, so we will put the full address in 'endereco' for now as per json structure
            # unless the user wants us to parse it, but standard practice with provided jsons is to map available fields.
            
            insert_sql = f"INSERT INTO public.escolas (nome, endereco, cep, id_empresa) VALUES ({nome}, {endereco}, {cep}, '{empresa_id}');\n"
            f.write(insert_sql)
            
    print(f"Migration generated successfully at {migration_path}")

except Exception as e:
    print(f"Error generating migration: {e}")
