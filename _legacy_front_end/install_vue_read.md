# Documentação do Ambiente de Desenvolvimento Frontend

Este documento serve como um registro técnico das decisões arquiteturais e das ferramentas escolhidas para o desenvolvimento do **Conecte App**. Ele explica "o quê", "o como" e, o mais importante, "o porquê" das nossas escolhas tecnológicas.

## 1. O Core: Vue.js 3

### Por que Vue 3?
Escolhemos o **Vue 3** (atualmente na versão `3.5.x`) como nosso framework reativo. 

*   **Não "Vue 4":** É importante esclarecer que o **Vue 4 não existe**. O Vue 3 é a versão *major* atual, estável e de longo prazo. O Vue 2 chegou ao fim da vida útil (EOL) em 2023. Portanto, estar no Vue 3 não é apenas uma escolha, é o padrão da indústria para novas aplicações Vue.
*   **Composition API (`<script setup>`):** Utilizamos a sintaxe `script setup`, que oferece uma DX (Developer Experience) superior. Ela permite organizar o código por funcionalidade lógica (ao invés de opções de ciclo de vida), facilita a reutilização de lógica através de *composables* e possui melhor performance de runtime.
*   **Reatividade com Proxy:** O sistema de reatividade do Vue 3, baseado em ES6 Proxies, é mais robusto e performático que os *getters/setters* do Vue 2, detectando mudanças em arrays e objetos profundamente aninhados sem "hacks".

## 2. Estilização: Tailwind CSS v3

### Por que Tailwind v3 e não v4?
Atualmente estamos utilizando o **Tailwind CSS v3.4.17**.

*   **Estabilidade e Maturidade:** O Tailwind v4 (anunciado recentemente) representa uma mudança significativa de arquitetura ("Oxide engine"). Embora promissor e mais rápido, o ecossistema v3 é extremamente maduro, estável e livre de bugs críticos de "bleeding edge". Para uma aplicação em produção que exige confiabilidade, a v3 é a escolha segura ("battle-tested").
*   **Compatibilidade de Plugins:** Todo o nosso setup de plugins e configurações de tema (`tailwind.config.js`) segue o padrão v3. A migração para v4, quando ele se tornar o padrão LTS, exigirá refatoração de configurações, mas por hora, a v3 oferece tudo o que precisamos sem a volatilidade de uma versão alpha/beta ou recém-lançada.
*   **PostCSS & Autoprefixer:** A v3 integra-se perfeitamente com nossa pipeline do Vite via PostCSS, garantindo que o CSS final seja otimizado e compatível com navegadores mais antigos automaticamente.

### Nossa Arquitetura de Design System
Não usamos o Tailwind "cru" apenas. Configuramos um sistema de design semântico no `tailwind.config.js`:
*   **Variáveis CSS Dinâmicas:** Em vez de *hardcoded hex codes* (ex: `#FFFFFF`), usamos variáveis CSS (`var(--color-background)`). Isso permite **temas dinâmicos** (Dark/Light mode) que trocam instantaneamente sem re-renderizar componentes, apenas alterando os valores das variáveis na raiz.
*   **Glassmorphism (`bg-div-15`):** Criamos utilitários personalizados para suportar nossa estética de vidro/transparência, garantindo consistência visual em todos os modais e cards.

## 3. Ecossistema e Plugins

Nossa stack não é apenas o Vue e Tailwind. Cada peça foi escolhida para resolver um problema específico com eficiência máxima:

### ⚡ Vite (Build Tool)
*   **Por que:** Substituiu o antigo Webpack. O Vite oferece *Hot Module Replacement* (HMR) instantâneo. O servidor de desenvolvimento inicia em milissegundos, independente do tamanho do projeto.
*   **Versão:** v7.x (Atualizada e extremamente rápida).

### 🍍 Pinia (Gerenciamento de Estado)
*   **Por que não Vuex?** O Pinia é o sucessor oficial do Vuex para Vue 3. É mais leve, modular, intuitivo e remove a complexidade de *mutations*.
*   **Persistência:** Utilizamos `pinia-plugin-persistedstate` para salvar automaticamente dados críticos (como o token de usuário e preferências de tema) no `localStorage`. Isso garante que, se o usuário der F5, ele não perde a sessão ou o estado da interface.

### 🛣️ Vue Router (Roteamento)
*   Integrado nativamente para criar uma SPA (*Single Page Application*) fluida. Gerencia as rotas protegidas (que exigem login) e a navegação sem *refresh* de página.

### 🔌 Supabase JS (Backend-as-a-Service)
*   Conexão direta com nosso banco de dados PostgreSQL e serviços de Auth, sem necessidade de uma API intermediária complexa para operações padrão de CRUD, agilizando drasticamente o desenvolvimento.

### 📱 Vite PWA Plugin
*   Transforma nossa aplicação web em um app instalável (**Progressive Web App**). Gerencia o `manifest.json` e os *Service Workers*, permitindo que o app funcione offline, tenha ícone na home do celular e pareça um aplicativo nativo.

## 4. Segurança e Infraestrutura de Dados

### 🐇 Bunny.net (CDN Seguro)
Utilizamos o **Bunny.net** não apenas como CDN para entrega rápida de conteúdo estático, mas principalmente pela sua capacidade de segurança:
*   **URLs Assinadas (Token Authentication):** Para documentos sensíveis (como livros e materiais didáticos exclusivos), não expomos links públicos diretos. Utilizamos URLs assinadas geradas dinamicamente via Edge Functions. Isso garante que apenas usuários autenticados e autorizados tenham acesso ao conteúdo, prevenindo o compartilhamento não autorizado de links.
*   **Proteção de Ativos:** Mantém nossos arquivos de mídia protegidos na nuvem, acessíveis apenas pela nossa aplicação.

### 🐘 PostgreSQL via RPCs (Remote Procedure Calls)
Uma decisão arquitetural chave foi **evitar chamadas diretas de `SELECT` ou `INSERT`** do frontend para o banco de dados. Em vez disso, utilizamos exclusivamente **RPCs** (Funções SQL armazenadas no banco):
*   **Proteção do Schema:** O frontend nunca precisa conhecer a estrutura real das tabelas (`schema`). Ele apenas conhece a "interface" da função (quais parâmetros enviar e o que esperar de retorno). Se mudarmos o nome de uma coluna no banco, apenas atualizamos a função, sem quebrar o código do frontend.
*   **Encapsulamento de Lógica:** Regras de negócio complexas, filtros de segurança e queries de agregação residem no banco, onde são processadas com performace nativa.
*   **Segurança:** Isso reduz drasticamente a superfície de ataque. O usuário mal-intencionado não consegue explorar as tabelas livremente, pois está restrito apenas ao que as funções expõem.

---

**Resumo para o Desenvolvedor:**
Este ambiente foi desenhado para ser **rápido (Vite)**, **escalável (Vue 3 + Pinia)**, **bonito e temático (Tailwind 3 + CSS Vars)** e **moderno (PWA + Supabase)**. A escolha de não pular para ferramentas "alpha" (como Tailwind 4 cedo demais) reflete um compromisso com a estabilidade do produto final, enquanto o uso do Vue 3 garante que estamos na vanguarda da tecnologia mainstream suportada.
