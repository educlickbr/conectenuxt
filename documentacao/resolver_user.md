# O dilema do Vue hoje (e a proposta com Nuxt)

## O que normalmente temos em Vue (SPA tradicional)

Em Vue puro, é comum que:

- A página faça login
- A página chame RPCs
- A página salve dados no Pinia
- O app passe a **confiar no estado persistido**

Isso funciona no início, mas cria problemas estruturais:

- A página vira orquestradora
- Auth depende da rota acessada
- Persistência vira “fonte da verdade”
- Bugs de timing (refresh, reload, SSR inexistente)
- Lógica duplicada entre páginas
- Dificuldade de escalar regras de acesso

O Vue **não está errado** — ele é uma lib de UI.  
Mas ele **não impõe fronteiras**.

---

## O problema central

> **Estado persistido não entende tempo.**  
> **Página não deveria decidir autenticação.**

Quando essas responsabilidades se misturam:
- surgem race conditions
- surgem acessos indevidos momentâneos
- surgem decisões baseadas em dados não validados

---

## A proposta (Nuxt + BFF)

Com Nuxt, o app passa a ter um **ciclo de vida próprio**:

- O app inicializa
- O server (BFF) valida a sessão
- Um endpoint central (`/api/me`) resolve o usuário
- O estado é preparado **antes** das páginas
- As páginas apenas consomem

Separação clara:

- **Client** → UI
- **BFF (Nuxt server)** → orquestração, validação, adaptação
- **Backend real (Supabase)** → regras definitivas

Pinia deixa de ser “verdade” e vira **cache confiável após validação**.

---

## Resultado

- Menos bugs temporais
- Auth previsível
- Páginas simples
- Estado consistente
- Arquitetura que cresce sem virar gambiarra

> **Nuxt não substitui Vue.  
> Ele organiza responsabilidades que o Vue deixa em aberto.**
