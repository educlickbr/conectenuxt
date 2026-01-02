<script setup>
const store = useAppStore()
const clientUser = useSupabaseUser()

onMounted(() => {
  console.log('Test Page Mounted')
  console.log('Store User:', store.user)
  console.log('Client Auth User:', clientUser.value)
})
</script>

<template>
  <div class="min-h-screen flex flex-col items-center justify-center p-8 bg-background text-text">
    <div class="w-full max-w-2xl bg-div-15 p-8 rounded-xl shadow-2xl border border-secondary border-opacity-30">
      <h1 class="text-3xl font-bold text-primary mb-6">Conecte Nuxt - BFF Test</h1>
      
      <div v-if="!store.initialized" class="animate-pulse flex space-y-4 flex-col">
        <div class="h-4 bg-secondary bg-opacity-20 rounded w-3/4"></div>
        <div class="h-4 bg-secondary bg-opacity-20 rounded w-1/2"></div>
      </div>

      <div v-else class="space-y-6">
        <section>
          <h2 class="text-xl font-semibold mb-2 flex items-center gap-2">
            <span class="w-2 h-2 rounded-full bg-success"></span>
            Empresa Detectada
          </h2>
          <div class="bg-background bg-opacity-50 p-4 rounded-lg">
            <pre class="text-sm overflow-x-auto">{{ JSON.stringify(store.company, null, 2) }}</pre>
          </div>
        </section>

        <section>
          <h2 class="text-xl font-semibold mb-2 flex items-center gap-2">
            <span class="w-2 h-2 rounded-full" :class="clientUser ? 'bg-success' : 'bg-danger'"></span>
            Auth User (Client Side)
          </h2>
          <div class="bg-blue-900 bg-opacity-20 p-4 rounded-lg">
            <p v-if="!clientUser" class="text-danger italic">Nenhum usuário logado no client.</p>
            <pre v-else class="text-sm overflow-x-auto">{{ JSON.stringify(clientUser, null, 2) }}</pre>
          </div>
        </section>

        <section>
          <h2 class="text-xl font-semibold mb-2 flex items-center gap-2">
            <span class="w-2 h-2 rounded-full" :class="store.user ? 'bg-success' : 'bg-danger'"></span>
            BFF Session User (Store)
          </h2>
          <div class="bg-background bg-opacity-50 p-4 rounded-lg">
            <p v-if="!store.user" class="text-danger italic">Nenhum usuário logado no store (BFF).</p>
            <pre v-else class="text-sm overflow-x-auto">{{ JSON.stringify(store.user, null, 2) }}</pre>
          </div>
        </section>

        <section v-if="store.profile">
          <h2 class="text-xl font-semibold mb-2 flex items-center gap-2">
            <span class="w-2 h-2 rounded-full bg-success"></span>
            User Profile (user_expandido)
          </h2>
          <div class="bg-purple-900 bg-opacity-20 p-4 rounded-lg">
            <pre class="text-sm overflow-x-auto">{{ JSON.stringify(store.profile, null, 2) }}</pre>
          </div>
        </section>

        <section v-if="store.role">
          <h2 class="text-xl font-semibold mb-2">Papel/Role</h2>
          <div class="bg-white p-4 rounded-lg border border-primary border-opacity-20">
            <span class="font-bold text-primary">{{ store.role.nome }}</span>
          </div>
        </section>

        <div class="pt-4 flex gap-4">
          <button @click="store.initSession()" class="px-6 py-2 bg-secondary text-white font-bold rounded-lg hover:bg-secondary-dark transition-colors uppercase tracking-wide">
            Atualizar Session BFF
          </button>
          <NuxtLink to="/" class="px-6 py-2 bg-primary text-white font-bold rounded-lg hover:bg-primary-dark transition-colors uppercase tracking-wide">
            Ir para Login
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>
