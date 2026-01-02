<script setup lang="ts">
// Tailwind Test Page
</script>

<template>
  <div class="min-h-screen bg-slate-950 text-slate-200 font-sans selection:bg-indigo-500/30">
    <!-- Animated background gradient -->
    <div class="fixed inset-0 overflow-hidden pointer-events-none">
      <div class="absolute -top-[25%] -left-[10%] w-[70%] h-[70%] bg-indigo-500/10 blur-[120px] rounded-full animate-pulse"></div>
      <div class="absolute -bottom-[25%] -right-[10%] w-[70%] h-[70%] bg-purple-500/10 blur-[120px] rounded-full animate-pulse [animation-delay:2s]"></div>
    </div>

    <main class="relative z-10 max-w-5xl mx-auto px-6 py-20">
      <header class="mb-16 space-y-4">
        <h1 class="text-5xl font-extrabold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-indigo-400 via-purple-400 to-pink-400">
          Tailwind Design Test
        </h1>
        <p class="text-xl text-slate-400 max-w-2xl">
          Verificando a configuração do Tailwind CSS com componentes premium, efeitos de vidro e animações fluídas.
        </p>
      </header>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Glassmorphism Card -->
        <section class="group relative p-8 rounded-3xl bg-slate-900/40 border border-slate-800 backdrop-blur-xl hover:border-indigo-500/50 transition-all duration-500 hover:shadow-2xl hover:shadow-indigo-500/10 active:scale-95">
          <div class="mb-4 w-12 h-12 rounded-2xl bg-indigo-500/20 flex items-center justify-center text-indigo-400 group-hover:scale-110 transition-transform duration-500">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
          </div>
          <h2 class="text-2xl font-bold mb-2">Glassmorphism</h2>
          <p class="text-slate-400 leading-relaxed">
            Painéis translúcidos com blur de fundo e bordas sutis para uma interface moderna e limpa.
          </p>
        </section>

        <!-- Dynamic Gradient Card -->
        <section class="group relative p-8 rounded-3xl bg-gradient-to-br from-purple-600/20 to-indigo-600/20 border border-purple-500/20 overflow-hidden hover:border-purple-500/40 transition-all duration-500">
          <div class="absolute inset-0 bg-gradient-to-br from-purple-600/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
          <div class="relative z-10">
            <div class="mb-4 w-12 h-12 rounded-2xl bg-purple-500/20 flex items-center justify-center text-purple-400">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.172-1.172a4 4 0 115.656 5.656l-1.172 1.172" />
              </svg>
            </div>
            <h2 class="text-2xl font-bold mb-2">Gradients</h2>
            <p class="text-slate-400 leading-relaxed">
              Uso de gradientes dinâmicos e vibrantes para guiar a atenção do usuário para elementos chave.
            </p>
          </div>
        </section>

        <!-- Interactive States Card -->
        <section class="group relative p-8 rounded-3xl bg-slate-900 border border-slate-800 hover:bg-slate-800/50 transition-all duration-300">
          <div class="mb-6 flex space-x-2">
            <span class="px-3 py-1 text-xs font-semibold rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 animate-bounce">Novo</span>
            <span class="px-3 py-1 text-xs font-semibold rounded-full bg-blue-500/10 text-blue-400 border border-blue-500/20">Ativo</span>
          </div>
          <h2 class="text-2xl font-bold mb-2">Interatividade</h2>
          <div class="mt-4">
            <button class="w-full py-3 px-6 rounded-xl bg-white text-slate-950 font-bold hover:bg-indigo-400 hover:text-white transition-all transform hover:-translate-y-1 active:translate-y-0">
              Botão Premium
            </button>
          </div>
        </section>
      </div>

      <footer class="mt-20 pt-8 border-t border-slate-800 text-center">
        <p class="text-slate-500 text-sm">
          &copy; 2025 Conecte Nuxt - Tailwind Validation Style
        </p>
      </footer>
    </main>
  </div>
</template>

<style scoped>
@keyframes pulse {
  0%, 100% { opacity: 0.1; transform: scale(1); }
  50% { opacity: 0.2; transform: scale(1.1); }
}

.animate-pulse {
  animation: pulse 8s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
</style>
