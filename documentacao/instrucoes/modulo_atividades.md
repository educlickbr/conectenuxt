# Documentação: Módulo de Gestão de Atividades

Este documento descreve a implementação técnica e funcional do módulo de
**Gestão de Atividades** (Pedagógico).

## 1. Visão Geral

O módulo permite que professores e gestores criem e organizem conteúdos
pedagógicos. A estrutura baseia-se no conceito de **Folders** (Pastas) que agem
como contêineres para múltiplos **Itens de Conteúdo**.

## 2. Estrutura de Dados

Os dados são persistidos principalmente na tabela `lms_conteudo` (ou similar,
acessada via RPCs).

### Entidades Principais

1. **Folder (Atividade Pai)**:
   - Representa o agrupamento principal.
   - Define o **Escopo**:
     - `Global`: Visível para toda a escola/curso.
     - `Turma`: Específico para uma turma.
     - `Aluno`: Personalizado para um aluno.
   - Contém metadados como Título, Descrição e Datas.

2. **Item de Conteúdo (Filho)**:
   - Vinculado a um Folder (`id_folder` implícito ou hierarquia).
   - **Tipos**:
     - `Material`: Texto, PDF ou Link.
     - `Video`: Link de vídeo (YouTube/Vimeo).
     - `Tarefa`: Atividade com entrega e nota.
     - `Questionário`: Lista de perguntas (Dissertativas ou Múltipla Escolha).
   - Pode ser vinculado a um Livro da Biblioteca Digital (`id_bbtk_edicao`).

## 3. Arquitetura Técnica (Nuxt + Supabase)

### Frontend (Vue 3)

- **Página Principal**: `pages/pedagogico/gestao-atividades.vue`
  - Listagem de Folders com expansão para ver itens filhos.
  - Filtros por busca e paginação.
- **Componentes**:
  - `ModalFolder.vue`: Criação/Edição do Folder pai.
  - `ModalContentItem.vue`: Criação/Edição dos itens filhos.
    - _Feature_: Integração com busca de livros da Biblioteca.
    - _Feature_: Gerenciador de perguntas para Questionários.

### BFF (Backend for Frontend)

Os endpoints estão localizados em `server/api/pedagogico/atividades/`:

1. **Listagem (`index.get.ts`)**:
   - Retorna folders paginados.
   - Pode incluir itens aninhados dependendo da query.
2. **Upsert (`upsert.post.ts`)**:
   - Chama a RPC `lms_conteudo_upsert`.
   - Trata a lógica de payload para diferentes escopos (Turma vs Aluno).
   - _Correção Recente_: Tipagem do payload para compatibilidade com a RPC
     (`as any`).

### Banco de Dados (Supabase)

- **RPC**: `lms_conteudo_upsert`
  - Gerencia tanto a criação quanto a atualização (Upsert).
  - Recebe parâmetros como `p_escopo`, `p_id_turma`, `p_id_aluno`,
    `p_data_disponivel`, etc.

## 4. Status Atual e Correções Recentes

1. **Payload de Upsert**: Corrigido erro de tipagem no envio dos dados para a
   RPC.
2. **Modal Content Item**:
   - Prop `folderId` ajustada para aceitar `null` (compatibilidade com estado
     inicial).
   - Lógica de busca de livros e renderização de perguntas implementada.
3. **Gestão de Atividades**:
   - Correção na passagem de props e eventos entre a lista e os modais.

---

**Próximos Passos Sugeridos**:

- Implementar a exclusão (Soft Delete via BFF).
- Refinar a validação de datas (Início < Fim).
- Implementar a visualização do aluno (LMS Player).
