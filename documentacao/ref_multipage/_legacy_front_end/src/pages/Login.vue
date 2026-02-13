<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'
import { supabase } from '../lib/supabase'

const store = useAppStore()
const toast = useToastStore()
const router = useRouter()

const loading = ref(true)
const error = ref(null)
const isSubmitting = ref(false)
const BUNNY_NET_BASE_URL = 'https://conecteedu.b-cdn.net/public/';

onMounted(async () => {
  try {
    loading.value = true
    let origin = window.location.origin
    
    // Check if localhost
    if (window.location.hostname === 'localhost') {
        origin = store.empresa_local
    }
    
        const { data, error: err } = await supabase.rpc('buscar_empresa_por_dominio_publico', {
      p_dominio: origin
    })

    console.log('Supabase RPC Data:', data)
    console.log('Supabase RPC Error:', err)

    if (err) throw err
    
    if (data && data.length > 0) {
        store.setCompanyData(data[0])
    } else {
       // Handle case where no company returned? 
       // User said: "Erro: Trate o erro exibindo uma mensagem simples"
       // If empty data but no error, it might be "not found".
       if (!data || data.length === 0) {
           error.value = "Falha ao carregar dados da empresa."
       }
    }

  } catch (err) {
    console.error(err)
    error.value = "Falha ao carregar dados da empresa."
  } finally {
    loading.value = false
  }
})

// Validation / Form Logic (Placeholders)
const email = ref('')
const password = ref('')

const handleLogin = async () => {
    isSubmitting.value = true
    
    const { error } = await supabase.auth.signInWithPassword({
        email: email.value,
        password: password.value
    })

    if (error) {
        toast.showToast('Email ou senha incorretos.', 'error')
    } else {
        const { data: { user } } = await supabase.auth.getUser()
        store.setUser(user)
        
        // Fetch User Role
        await store.fetchUserRole(supabase)
        
        toast.showToast('Login realizado com sucesso!', 'success')
        router.push({ name: 'inicio' })
    }

    isSubmitting.value = false
}

</script>

<template>
  <div class="min-h-screen w-full flex items-center justify-center bg-background text-text">
    
    <!-- Container de Login -->
    <div class="w-full max-w-md bg-div-15 p-8 rounded-xl shadow-2xl space-y-8">
      
      <!-- Content -->
      <div v-if="loading" class="text-center py-10">
         <p>Carregando...</p>
      </div>

      <div v-else-if="error" class="text-center py-10 text-danger">
          <p>{{ error }}</p>
      </div>

      <div v-else class="space-y-6">
          
          <!-- Header -->
          <div class="text-center space-y-4">
              <h3 class="text-base font-bold tracking-wide">Faça login em sua conta</h3>
              
              <!-- Logo -->
              <div v-if="store.logo_aberto" class="flex justify-center">
                  <img :src="BUNNY_NET_BASE_URL + store.logo_aberto" alt="Logo Empresa" class="max-h-20 object-contain" />
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
                    class="w-full px-4 py-3 rounded-lg bg-background border border-secondary border-opacity-30 focus:border-primary focus:ring-2 focus:ring-primary outline-none transition-all placeholder-opacity-50"
                  />
              </div>

              <div class="space-y-2">
                  <label for="password" class="sr-only">Senha</label>
                  <input 
                    id="password" 
                    type="password" 
                    v-model="password"
                    placeholder="Senha" 
                    class="w-full px-4 py-3 rounded-lg bg-background border border-secondary border-opacity-30 focus:border-primary focus:ring-2 focus:ring-primary outline-none transition-all placeholder-opacity-50"
                  />
              </div>

              <button 
                type="submit" 
                :disabled="isSubmitting"
                class="w-full py-3 px-4 bg-primary hover:bg-primary-dark disabled:opacity-50 disabled:cursor-not-allowed text-white font-bold rounded-lg transition-colors duration-200 uppercase tracking-wide"
              >
                  {{ isSubmitting ? 'ENTRANDO...' : 'ENTRAR' }}
              </button>

              <!-- Footer Links -->
              <div class="flex justify-between text-sm text-secondary pt-2">
                  <a href="#" class="hover:text-primary transition-colors">Esqueceu sua senha?</a>
                  <a href="#" class="hover:text-primary transition-colors font-medium">Criar conta</a>
              </div>

          </form> 
      </div>

    </div>
  </div>
</template>
