<script setup>
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import { useToastStore } from '../stores/toast'

const router = useRouter()
const toast = useToastStore()

const handleLogout = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) {
        toast.showToast(error.message, 'error')
    } else {
        toast.showToast('Logout realizado com sucesso.', 'success')
        router.push('/')
    }
}
</script>

<template>
  <div class="min-h-screen bg-background text-text flex flex-col items-center justify-center p-6">
    <div class="bg-div-15 p-8 rounded-xl shadow-2xl max-w-2xl w-full text-center space-y-6">
        <h1 class="text-3xl font-bold text-primary">Dashboard</h1>
        <p class="text-lg">Bem-vindo! Você está logado com sucesso.</p>
        
        <div class="pt-4">
            <button 
                @click="handleLogout"
                class="px-6 py-2 bg-danger hover:bg-red-700 text-white rounded-lg transition-colors"
             >
                Sair
            </button>
        </div>
    </div>
  </div>
</template>
