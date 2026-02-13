# Documentação: Módulo de Grupos de Estudo

Este documento descreve a implementação técnica e funcional do módulo de
**Grupos de Estudo** (Estrutura Acadêmica).

## 1. Visão Geral

O módulo permite a criação e gestão de grupos de estudo multiturmas, que podem
ser usados para atividades extracurriculares, reforço ou projetos. Diferente das
turmas regulares, os grupos de estudo podem agregar alunos de diferentes
origens.

## 2. Estrutura de Dados

### Tabelas Principais (Schema `public`)

1. **`grp_grupos`**: Tabela principal.
   - Campos: `nome_grupo`, `descricao`, `status` (ATIVO/INATIVO), `ano` (Ano
     Letivo).
   - Auditoria: `criado_por`, `modificado_por` (FKs para `user_expandido`).
   - _Soft Delete_: Suportado via coluna `soft_delete` (embora a implementação
     atual use status para inativação visual).

2. **`grp_tutores`**: Tabela de vínculo (N:N).
   - Vincula um Grupo (`id_grupo`) a um Usuário Tutor (`id_user`).
   - Campo `ano` para histórico.

3. **`grp_integrantes`**: Tabela de vínculo (N:N).
   - Vincula um Grupo (`id_grupo`) a um Usuário Aluno (`id_user`).
   - Campo `ano` para histórico.

## 3. Arquitetura Técnica

### Frontend (Vue 3)

- **Página Principal**: `pages/estrutura_academica/grupos.vue`
  - Gerencia 3 abas principais: Grupos, Tutores e Integrantes.
- **Componentes Chave**:
  - `TabGrupos.vue`: Listagem dos grupos.
  - `TabTutores.vue` / `TabIntegrantes.vue`: Listagem dos membros vinculados.
  - `ModalGerenciarGrupo.vue`: Criação e edição de grupos.
    - _Padrão UI_: Utiliza `ManagerField` para inputs e drops padronizados.
  - `ModalVincularUsuario.vue`: Modal genérico para adicionar Tutores ou
    Integrantes.
    - _Feature_: Busca via **Autocomplete** (não carrega todos os usuários de
      uma vez).

### BFF (Backend for Frontend)

Os endpoints utilizam o padrão genérico de CRUD em
`server/api/estrutura_academica/`:

1. **Recursos Mapeados**:
   - `grupos` -> RPC `grp_grupo_...`
   - `tutores` -> RPC `grp_tutores_...` / `grp_tutor_upsert`
   - `integrantes` -> RPC `grp_integrantes_...` / `grp_integrante_upsert`
   - `candidatos_tutores` / `candidatos_integrantes`: Endpoints de leitura para
     o autocomplete.

### Banco de Dados (Supabase/PostgreSQL)

A lógica de negócio reside estritamente em **Functions (RPCs)**:

- **Upsert**:
  - `grp_grupo_upsert`: Cria/Atualiza grupo (com suporte a campo `ano`).
  - `grp_tutor_upsert`: Vincula tutor.
  - `grp_integrante_upsert`: Vincula aluno.
- **Leitura (Paginada)**:
  - `grp_grupo_get_paginado`: Aceita `p_pagina`, `p_limite_itens_pagina`,
    `p_ano`.
  - `grp_tutores_get_paginado` / `grp_integrantes_get_paginado`: Listam membros
    com joins em `user_expandido`.
- **Busca de Candidatos**:
  - `grp_candidatos_tutores_get`: Retorna usuários elegíveis para serem tutores.
  - `grp_candidatos_integrantes_get`: Retorna usuários elegíveis para serem
    alunos.

## 4. Funcionalidades Recentes

- **Campo Ano Letivo**: Adicionado suporte para selecionar o Ano Letivo do grupo
  (Padrão: Ano Atual).
- **Padronização UI**: O seletor de Ano no modal segue o padrão visual do
  sistema (`ManagerField`).
- **Correção de Assinaturas RPC**: Migração `20260124114500` ajustou os
  parâmetros de paginação (`offset` -> `pagina`) para compatibilidade com o BFF.

---

**Observações**: O sistema de exclusão é "lógico" via Soft Delete ou
desativação, garantindo integridade referencial.
