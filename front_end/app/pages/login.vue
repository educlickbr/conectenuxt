<script setup>
const supabase = useSupabaseClient()
const store = useAppStore()
const toast = useToastStore()
const router = useRouter()

const email = ref('')
const password = ref('')
const isSubmitting = ref(false)
const BUNNY_NET_BASE_URL = 'https://conecteedu.b-cdn.net/public/'

// Redirect if already logged in
watchEffect(() => {
  if (store.initialized && store.user) {
    router.push('/inicio')
  }
})

const handleLogin = async () => {
  isSubmitting.value = true
  
  const { error } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value
  })

  if (error) {
    toast.showToast('Email ou senha incorretos.', 'error')
  } else {
    // Show loading immediately before navigation to mask transitions
    store.setLoading(true)
    
    // Refresh BFF context with the new session before moving
    await store.initSession()
    
    toast.showToast('Login realizado com sucesso!', 'success')
    router.push('/inicio')
  }

  isSubmitting.value = false
}
</script>

<template>
  <div class="min-h-screen w-full flex items-center justify-center bg-background text-text">
    
    <!-- Login Container -->
    <div class="w-full max-w-md bg-div-15 p-8 rounded shadow-2xl space-y-8 border border-secondary border-opacity-10">
      
      <div class="space-y-6">
          
          <!-- Header -->
          <div class="text-center space-y-4">
              <h3 class="text-base font-bold tracking-wide uppercase opacity-70">Faça login em sua conta</h3>
              
              <!-- Logo -->
              <div v-if="store.company?.logo_grande" class="flex justify-center">
                  <img :src="BUNNY_NET_BASE_URL + store.company.logo_grande" alt="Logo Empresa" class="max-h-24 object-contain transition-all hover:scale-105" />
              </div>
          </div>

          <!-- Form -->
          <form @submit.prevent="handleLogin" class="space-y-6">
              
              <div class="space-y-2">
                  <label for="email" class="sr-only">Email</label>
                  <input 
                    id="email" 
                    type="email" 
                    v-model="email"
                    placeholder="Email" 
                    required
                    class="w-full px-4 py-3 rounded bg-background border border-secondary border-opacity-30 focus:border-primary focus:ring-2 focus:ring-primary outline-none transition-all placeholder-opacity-50"
                  />
              </div>

              <div class="space-y-2">
                  <label for="password" class="sr-only">Senha</label>
                  <input 
                    id="password" 
                    type="password" 
                    v-model="password"
                    placeholder="Senha" 
                    required
                    class="w-full px-4 py-3 rounded bg-background border border-secondary border-opacity-30 focus:border-primary focus:ring-2 focus:ring-primary outline-none transition-all placeholder-opacity-50"
                  />
              </div>

              <button 
                type="submit" 
                :disabled="isSubmitting"
                class="w-full py-3 px-4 bg-primary hover:bg-primary-dark disabled:opacity-50 disabled:cursor-not-allowed text-white font-bold rounded transition-all duration-200 uppercase tracking-widest shadow-lg active:scale-95"
              >
                  {{ isSubmitting ? 'ENTRANDO...' : 'ENTRAR' }}
              </button>

              <!-- Footer Links -->
              <div class="flex justify-between text-sm text-secondary pt-2 opacity-60">
                  <a href="#" class="hover:text-primary transition-colors hover:opacity-100">Esqueceu sua senha?</a>
                  <a href="#" class="hover:text-primary transition-colors font-medium hover:opacity-100">Criar conta</a>
              </div>

          </form> 
      </div>

    </div>
  </div>
</template>
