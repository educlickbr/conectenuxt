<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import { useToastStore } from '../stores/toast'
import FullPageMenu from '../components/FullPageMenu.vue'

const router = useRouter()
const toast = useToastStore()
const menuAberto = ref(true)

// Local logout removed in favor of global store action in FullPageMenu
// User fetching removed in favor of App Store logic (or App.vue initialization)

const toggleMenu = () => {
    menuAberto.value = !menuAberto.value
}
</script>

<template>
  <div class="min-h-screen bg-background text-text">
    <!-- Main Content Background (Empty as requested, just a placeholder if menu closes) -->
    <div class="p-8">
        <h1 class="text-2xl font-bold">Página Inicial</h1>
        <button @click="toggleMenu" class="mt-4 px-4 py-2 bg-primary text-white rounded-lg">Abrir Menu</button>
    </div>

    <!-- Full Page Menu -->
    <FullPageMenu 
      :is-open="menuAberto" 
      @close="toggleMenu"
    />
  </div>
</template>
