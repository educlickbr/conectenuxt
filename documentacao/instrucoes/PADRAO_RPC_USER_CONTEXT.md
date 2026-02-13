# Padrão: Resolução de Contexto de Usuário em RPCs (PostgreSQL)

> **Recomendação**: Para todas as RPCs (Stored Procedures) que dependem de dados
> do usuário expandido (`user_expandido`), a resolução do ID deve ser feita
> **internamente na função SQL**, e não passada como argumento pelo client ou
> servidor (Node/Nuxt).

## O Problema

Anteriormente, a responsabilidade de buscar o `user_expandido.id` era do
endpoint (API/BFF). O fluxo era:

1. Client/API chama `user_expandido` filtrando por `auth.uid()`.
2. Client/API pega o ID retornado.
3. Client/API chama a RPC passando esse ID como argumento (`p_user_uuid`).

**Falhas desse modelo:**

- **Erros de RLS**: Frequentemente, a query de lookup falha silenciosamente ou
  retorna nulo devido a políticas de Row Level Security (RLS) que podem não
  estar perfeitamente alinhadas com o contexto da aplicação no momento da
  chamada.
- **Race Conditions**: O token de auth pode ser válido, mas o registro em
  `user_expandido` pode estar inacessível momentaneamente para a role do
  usuário.
- **Segurança Frágil**: Confiar que o identificador passado pelo `client` (mesmo
  via BFF) está correto e validado exige validação dupla (no código e no banco).

## A Solução: Resolução Interna (Internal Lookup)

A nova abordagem delega ao PostgreSQL a responsabilidade de identificar "quem é
o usuário atual" baseado na sessão autenticada (`auth.uid()`) no momento exato
da execução da função com permissões de `SECURITY DEFINER`.

### Como Implementar

1. **Remova o argumento de usuário** da assinatura da função.
2. **Declare uma variável** interna para armazenar o ID.
3. **Faça o lookup** usando `auth.uid()` (função nativa do Supabase/GoTrue).
4. **Valide** a existência do registro e lance exceção se necessário.

### Exemplo Prático (`bbtk_reserva_create`)

#### ❌ Antes (Não Recomendado)

```sql
-- Assinatura exige que alguém de fora diga quem é o usuário
CREATE FUNCTION bbtk_reserva_create(
    p_copia_uuid uuid,
    p_user_uuid uuid, -- <--- Ponto de falha
    p_id_empresa uuid
) ...
```

#### ✅ Depois (Padrão Recomendado)

```sql
CREATE FUNCTION bbtk_reserva_create(
    p_copia_uuid uuid,
    p_id_empresa uuid
    -- p_user_uuid REMOVIDO
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- Garante acesso às tabelas necessárias (como user_expandido)
AS $$
DECLARE
    v_user_uuid uuid; -- Variável interna
BEGIN
    -- 1. Resolução Segura e Atômica
    SELECT id INTO v_user_uuid
    FROM public.user_expandido
    WHERE user_id = auth.uid() -- Contexto da sessão atual
    LIMIT 1;

    -- 2. Validação Obrigatória
    IF v_user_uuid IS NULL THEN
        RAISE EXCEPTION 'Perfil de usuário não encontrado para o usuário logado.';
    END IF;

    -- 3. Uso do ID resolvido
    INSERT INTO public.bbtk_historico_interacao (
        ...
        user_uuid,
        ...
    ) VALUES (
        ...
        v_user_uuid,
        ...
    );
END;
$$;
```

## Vantagens

1. **Robustez**: Elimina o erro "Perfil de usuário não encontrado" causado por
   falhas de lookup no client-side ou RLS restritivo na leitura pública.
2. **Segurança**: O ID do usuário é garantido pelo próprio banco de dados com
   base no token JWT válido. É impossível falsificar o usuário sem comprometer o
   token.
3. **Simplicidade na API**: O endpoint Nuxt (`create.post.ts`) fica mais limpo,
   apenas repassando os dados do formulário sem precisar fazer queries
   auxiliares.
4. **Performance**: Uma viagem a menos ao banco de dados (o lookup acontece na
   mesma transação da inserção).
