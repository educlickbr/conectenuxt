import json
import re

# Data mapping with CEPs
schools_data = {
    "CMEI BARTOLOMEU AROUCHA": "Rua Álvaro da Boa Vista Maia, 355, Jardim Atlântico, Olinda - PE, CEP 53140-200",
    "CMEI MARIA DAS DORES DA SILVA": "Avenida Asa Branca, 65, Rio Doce, Olinda - PE, CEP 53070-195",
    "CMEI MESTRE SALUSTIANO": "Rua Caminho do Sol, Cidade Tabajara, Olinda - PE, CEP 53350-825",
    "CMEI METODISTA GLADYS OBERLYN": "Avenida Leopoldino Canuto de Melo, 437, Caixa D'Água, Olinda - PE, CEP 53210-240", 
    "CMEI MÃE OUTRA": "Rua Jorge Albuquerque Carvalho, 142, Peixinhos, Olinda - PE, CEP 53230-330",
    "CMEI PROFESSOR JOSÉ ANTÔNIO FERREIRA SOBRAL": "Avenida da Integração, 59, Ilha de Santana, Olinda - PE, CEP 53060-001",
    "CMEI PROFESSORA CLEIDE BETÂNIA DO AMARAL": "Rua Austrália, S/Nº, Alto do Cajueiro, Olinda - PE, CEP 53160-830",
    "CMEI PROFESSORA NORMA COELHO": "Avenida Presidente Kennedy, S/N, Peixinhos, Olinda - PE, CEP 53230-630",
    "CMEI REVERENDO JULIÃO FERREIRA": "Rua Alto Nova Olinda, 95, Águas Compridas, Olinda - PE, CEP 53180-050",
    "CMEI SANTA BÁRBARA": "Rua Golfinho, S/N, Ouro Preto, Olinda - PE, CEP 53370-192",
    "CRECHE EMANUEL": "Praça Dantas Barreto, 15, Carmo, Olinda - PE, CEP 53120-370",
    "ESCOLA DE EDUCAÇÃO INFANTIL E ENSINO FUNDAMENTAL ARCEBISPO DOM JOÃO COSTA": "Rua Manuel Regueira, 49, Bultrins, Olinda - PE, CEP 53320-160",
    "ESCOLA MUNICIPAL 19 DE SETEMBRO": "Estrada de Águas Compridas, 796-A, Águas Compridas, Olinda - PE, CEP 53160-800",
    "ESCOLA MUNICIPAL AGEU MAGALHÃES": "Rua Ageu Magalhães, 758, Vila Popular, Olinda - PE, CEP 53230-060",
    "ESCOLA MUNICIPAL ALLAN KARDEC": "Avenida Professor Andrade Bezerra, 826, Salgadinho, Olinda - PE, CEP 53110-110",
    "ESCOLA MUNICIPAL ALTO DA MACAÍBA": "Rua Dezoito de Fevereiro, 353, Águas Compridas, Olinda - PE, CEP 53160-350",
    "ESCOLA MUNICIPAL ANTÔNIO CORREIA DA SILVA": "Rua da Tijuca, Alto Jardim Conquista, Olinda - PE, CEP 53190-000",
    "ESCOLA MUNICIPAL CENTRO DE ASSISTÊNCIA SOCIAL": "Estrada de Águas Compridas, 94, Águas Compridas, Olinda - PE, CEP 53160-800",
    "ESCOLA MUNICIPAL CORONEL JOSÉ DOMINGOS DA SILVA": "Rua Dracena, 9, Ouro Preto, Olinda - PE, CEP 53370-560",
    "ESCOLA MUNICIPAL CRIANÇA FELIZ": "Rua Joaquim Mendes da Silva, 218, Bultrins, Olinda - PE, CEP 53320-150",
    "ESCOLA MUNICIPAL DE EDUCAÇÃO INFANTIL E ENSINO FUNDAMENTAL CHICO SCIENCE": "Avenida das Acácias, Terceira Etapa, Rio Doce, Olinda - PE, CEP 53070-100",
    "ESCOLA MUNICIPAL DE EDUCAÇÃO INFANTIL E ENSINO FUNDAMENTAL DONA GUIOMAR BARBOSA": "Rua Clarice, 77, Jardim Brasil V, Olinda - PE, CEP 53270-180",
    "ESCOLA MUNICIPAL DE EDUCAÇÃO INFANTIL E ENSINO FUNDAMENTAL PASTOR CONRADO PAULINO": "Avenida E, S/N, Rio Doce IV Etapa, Olinda - PE, CEP 53080-230",
    "ESCOLA MUNICIPAL DE EDUCAÇÃO INFANTIL E ENSINO FUNDAMENTAL PRINCESA ISABEL": "Rua Belém, 13, Jardim Brasil, Olinda - PE, CEP 53290-200",
    "ESCOLA MUNICIPAL DO BEM ESTAR SOCIAL": "Rua Pacificador, 94, Sapucaia, Olinda - PE, CEP 53280-010",
    "ESCOLA MUNICIPAL DOM AZEREDO COUTINHO": "Avenida Presidente Kennedy, 660, São Benedito, Olinda - PE, CEP 53230-630",
    "ESCOLA MUNICIPAL DONA BRITES DE ALBUQUERQUE": "Rua Cleto Campelo, S/N, Bairro Novo, Olinda - PE, CEP 53030-150",
    "ESCOLA MUNICIPAL DOUTOR MANOEL BORBA": "Rua Benjamin Constant, Sítio Novo, Olinda - PE, CEP 53110-270",
    "ESCOLA MUNICIPAL DR JOSÉ MARIANO": "Estrada de Águas Compridas, 269, Águas Compridas, Olinda - PE, CEP 53160-800",
    "ESCOLA MUNICIPAL DUARTE COELHO": "Rua do Bonfim, 315, Carmo, Olinda - PE, CEP 53120-090",
    "ESCOLA MUNICIPAL ELPÍDIO DE FRANÇA": "Rua Alto Nova Olinda, S/N, Águas Compridas, Olinda - PE, CEP 53180-050",
    "ESCOLA MUNICIPAL EM TEMPO INTEGRAL ALBERTO TORRES": "Endereço não encontrado",
    "ESCOLA MUNICIPAL EM TEMPO INTEGRAL BASE RURAL MARGARIDA ALVES": "Sítio Ouro Preto, SN, Ouro Preto, Olinda - PE, CEP 53370-000",
    "ESCOLA MUNICIPAL EM TEMPO INTEGRAL CAIC PROFESSORA NORMA COELHO": "Avenida Presidente Kennedy, S/N, Peixinhos, Olinda - PE, CEP 53230-630",
    "ESCOLA MUNICIPAL EM TEMPO INTEGRAL LIONS DIRCEU VELOSO": "Rua Prefeito Manoel Regueira, S/N, Bultrins, Olinda - PE, CEP 53320-160",
    "ESCOLA MUNICIPAL EM TEMPO INTEGRAL MONTE CASTELO": "Rua Jules Rimet, Rio Doce, Olinda - PE, CEP 53150-590",
    "ESCOLA MUNICIPAL EM TEMPO INTEGRAL SAGRADO CORAÇÃO DE JESUS": "Rua Frei Afonso Maria, 199, Amaro Branco, Olinda - PE, CEP 53120-170",
    "ESCOLA MUNICIPAL GREGÓRIO BEZERRA": "Rua Santana, S/N, Jardim Atlântico, Olinda - PE, CEP 53050-030",
    "ESCOLA MUNICIPAL IRACEMA PIRES": "Rua Maria dos Prazeres, 775, Aguazinha, Olinda - PE, CEP 53260-000",
    "ESCOLA MUNICIPAL ISAAC PEREIRA DA SILVA": "Avenida Carlos de Lima Cavalcante, 2293, Casa Caiada, Olinda - PE, CEP 53030-260",
    "ESCOLA MUNICIPAL IZAULINA DE CASTRO E SILVA": "Quadra C 14, S/N, Ouro Preto, Olinda - PE, CEP 53370-100",
    "ESCOLA MUNICIPAL LAR ESPÍRITA BEZERRA DE MENEZES": "Rua Professor Agamenon Magalhães, 29, Vila Popular, Olinda - PE, CEP 53230-010",
    "ESCOLA MUNICIPAL LAR TRANSITÓRIO DE CHRISTIE": "Rua 48 A, 2-78, Rio Doce, Olinda - PE, CEP 53080-730",
    "ESCOLA MUNICIPAL MARIA JOSÉ DOS PRAZERES": "Rua General Sampaio, 48, Caixa D'água, Olinda - PE, CEP 53160-160",
    "ESCOLA MUNICIPAL MINISTRO MARCOS FREIRE": "Avenida Pirâmides, S/N, Alto do Sol Nascente, Olinda - PE, CEP 53200-080",
    "ESCOLA MUNICIPAL MIZAEL MONTENEGRO FILHO": "Rua Catarina Batista de Alencar, 791, Casa Caiada, Olinda - PE, CEP 53130-020",
    "ESCOLA MUNICIPAL MONSENHOR VIANA": "Rua Edmundo Gonçalves da Silva, 194, Caixa D'água, Olinda - PE, CEP 53210-310",
    "ESCOLA MUNICIPAL NOSSA SENHORA DE LOURDES": "Rua Alto do Bonfim, 126, Águas Compridas, Olinda - PE, CEP 53210-000",
    "ESCOLA MUNICIPAL NOSSA SENHORA DO CARMO": "Estrada do Caenga, 23, Beberibe, Olinda - PE, CEP 53210-460",
    "ESCOLA MUNICIPAL NOSSA SENHORA DO MONTE": "Rua Irmã Gertrudes de Alencar, 50, Bultrins, Olinda - PE, CEP 53240-290",
    "ESCOLA MUNICIPAL NOVA OLINDA": "Rua Alto Nova Olinda, 133, Águas Compridas, Olinda - PE, CEP 53180-050",
    "ESCOLA MUNICIPAL PASTOR DAVID BLACKBURN": "Avenida Hamurabi, S/N, Alto da Bondade, Olinda - PE, CEP 53170-310",
    "ESCOLA MUNICIPAL PRO MENOR": "Rua C-6, 15, Rio Doce, Olinda - PE, CEP 53150-100",
    "ESCOLA MUNICIPAL PROFESSOR HÉLIO FERREIRA MAIA": "Rua São José do Monte, 283, Guadalupe, Olinda - PE, CEP 53320-570",
    "ESCOLA MUNICIPAL PROFESSOR JOÃO FRANCISCO DE SOUZA": "Rua Humberto de Lima Mendes, 405, Jardim Fragoso, Olinda - PE, CEP 53130-090",
    "ESCOLA MUNICIPAL PROFESSOR MARCOLINO BOTELHO": "Rua Cláudio Nigro, 303, Salgadinho, Olinda - PE, CEP 53110-610",
    "ESCOLA MUNICIPAL PROFESSOR WILSON DE SOUZA": "Rua Manuel Clementino Marques, S/N, Ouro Preto, Olinda - PE, CEP 53330-170",
    "ESCOLA MUNICIPAL PROFESSORA ANA PAULA SILVA DE ALBUQUERQUE PONTES RAMOS": "Rua Teresópolis, 10, Sapucaia de Dentro, Olinda - PE, CEP 53280-250",
    "ESCOLA MUNICIPAL PROFESSORA IZABEL BURITY": "Avenida Brasil, SN 2ª Etapa, Rio Doce, Olinda - PE, CEP 53150-470",
    "ESCOLA MUNICIPAL PROFESSORA JOANA SENA COSTA": "Rua da Boa Vontade, S/N, Aguazinha, Olinda - PE, CEP 53270-280",
    "ESCOLA MUNICIPAL RECANTO DA ARTE E DO SABER": "Rua Nova, 37, Sapucaia, Olinda - PE, CEP 53280-090",
    "ESCOLA MUNICIPAL SANTA TEREZA": "Avenida Olinda Dom Helder Camara, 750, Santa Tereza, Olinda - PE, CEP 53010-005",
    "ESCOLA MUNICIPAL SHEKINÁ": "Rua Monte Alegre, 300, Ouro Preto, Olinda - PE, CEP 53160-270",
    "ESCOLA MUNICIPAL SÃO BENTO": "Rua Presidente Kennedy, 10, Monte, Olinda - PE, CEP 53240-720",
    "ESCOLA MUNICIPAL VEREADOR JOSÉ MENDES DE LIMA": "Estrada do Passarinho, S/N, Passarinho, Olinda - PE, CEP 53170-110"
}

# Output file path
output_file = "/home/eikmeier/Documentos/dev/nuxt/conectenuxt/documentacao/refolinda/escolas.json"

# Convert to list of objects with CEP extraction
json_output = []
cep_regex = re.compile(r'CEP\s*([\d]{5}-?[\d]{3})')

for name, full_address in schools_data.items():
    if full_address == "Endereço não encontrado":
        # Keep as is, no CEP
        json_output.append({
            "nome": name,
            "endereco": full_address,
            "cep": None
        })
        continue

    # Extract CEP
    match = cep_regex.search(full_address)
    cep = match.group(1) if match else None
    
    # Clean address by removing the CEP part
    # We remove ", CEP XXXXX-XXX" or " CEP XXXXX-XXX"
    clean_address = cep_regex.sub('', full_address).strip()
    if clean_address.endswith(','):
        clean_address = clean_address[:-1].strip()
    
    json_output.append({
        "nome": name,
        "endereco": clean_address,
        "cep": cep
    })

# Write to file
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(json_output, f, ensure_ascii=False, indent=2)

print(f"JSON generated at {output_file} with {len(json_output)} schools.")
