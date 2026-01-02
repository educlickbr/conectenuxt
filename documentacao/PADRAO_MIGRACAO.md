# Padrão de Migração de Páginas e Funcionalidades

Este documento estabelece o fluxo de trabalho padrão para migrar páginas e funcionalidades do sistema legado para o novo projeto Nuxt (Conecte).

## 1. Análise do Legado
Antes de iniciar a codificação, analise a página correspondente no projeto legado para entender:
*   **Componentes de UI**: Quais campos, tabelas e modais são utilizados.
*   **Fluxo de Dados**: Como os dados são carregados e salvos.
*   **RPCs Utilizadas**: Identifique as chamadas ao Supabase (ex: `supabase.rpc('nome_funcao')`) nos arquivos `.vue` ou `.js` do legado.

## 2. Migração de RPCs para BFF (Backend for Frontend)
No novo projeto Nuxt, **não chame RPCs diretamente do frontend** (exceto em casos muito específicos e justificados). Utilize o padrão BFF:
1.  Crie um endpoint de servidor em `server/api/[modulo]/[recurso].get.ts`, `.post.ts`, `.delete.ts`, etc.
2.  O frontend chama este endpoint via `$fetch` ou `useFetch`.
3.  O servidor (Nitro) chama a RPC do Supabase usando `serverSupabaseClient`.
4.  **Tratamento de Erro**: O servidor deve capturar erros da RPC e retornar mensagens claras. Use a propriedade `message` no corpo da resposta para erros tratados, garantindo suporte a caracteres e acentuação.

## 3. Busca de Definições de RPC (Database)
Para entender o que uma RPC faz (parâmetros, tabelas afetadas), busque sua definição nos arquivos de migração.
*   **Onde buscar**: Pasta `supabase/migrations`.
*   **Como buscar**:
    *   **Não use `grep` simples** se estiver no terminal Windows (PowerShell/CMD) pois pode ser limitado.
    *   Use `Select-String` no PowerShell:
        ```powershell
        Select-String -Path "supabase/migrations/*.sql" -Pattern "nome_da_rpc"
        ```
    *   Ou use a busca global do VS Code (`Ctrl + Shift + F`).

## 4. Padrão de Layout
Ao criar novas páginas administrativas ou de gestão:
*   Use o layout `layouts/manager.vue` (`<NuxtLayout name="manager">`).
*   Este layout fornece estrutura pronta para:
    *   **Abas** (Tabs) superiores.
    *   **Dashboard** lateral (opcional).
    *   **Cabeçalho** com ações e busca.
*   Siga o exemplo de `pages/infraestrutura/index.vue` como modelo ("Golden Sample").

## 5. Integridade em Operações de Delete
Ao implementar exclusão de registros:
*   **Nunca confie apenas no frontend**.
*   **Revise a RPC de delete**: Verifique se ela protege a integridade dos dados.
*   **Cascade vs. Bloqueio**:
    *   Prefira **bloquear** a exclusão se existirem filhos (ex: não deletar Escola se tiver Prédios).
    *   Se a RPC atual não faz isso, **altere a RPC** para lançar uma `EXCEPTION` caso existam dependências.
    *   Exemplo de verificação em PL/pgSQL:
        ```sql
        if exists (select 1 from tabela_filha where pai_id = p_id) then
            return jsonb_build_object('status', 'error', 'message', 'Não é possível excluir...');
        end if;
        ```

## 6. Auditoria de Segurança (Security Definer)
Sempre que tocar em uma RPC ou criar uma nova:
*   Verifique se ela usa `SECURITY DEFINER`.
*   **Por padrão, evite `SECURITY DEFINER`**. Ele executa a função com permissões de superusuário (ou do dono da função), ignorando RLS (Row Level Security).
*   Use apenas se estritamente necessário (ex: criar usuário na tabela `auth.users`).
*   Se for possível fazer a operação com as permissões do próprio usuário logado, retire o `SECURITY DEFINER` e confie nas RLS das tabelas.

---

### Exemplo de Fluxo (Infraestrutura)
1.  Identificamos `escolas_delete`.
2.  Vimos que deletava direto.
3.  Alteramos para checar se existem prédios (`bbtk_dim_predio`) antes de deletar.
4.  No Frontend, tratamos o erro retornado para exibir um Toast amigável.
