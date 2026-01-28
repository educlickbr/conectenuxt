<script setup>
import { computed } from 'vue'
import ManagerListItem from '@/components/ManagerListItem.vue'

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  },
  isLoading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['edit', 'delete'])

// Helper to format date
const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('pt-BR')
}
</script>

<template>
  <div class="space-y-3">
    <!-- Loading State -->
    <div v-if="isLoading" class="space-y-3">
      <div v-for="i in 3" :key="i" class="h-20 bg-div-15 animate-pulse rounded border border-[#6B82A71A]"></div>
    </div>

    <!-- Empty State -->
    <div v-else-if="items.length === 0" class="text-center py-20 bg-div-15 rounded border border-[#6B82A71A]">
      <div class="w-16 h-16 bg-[#6B82A71A] rounded-full flex items-center justify-center mx-auto mb-4 text-secondary">
         <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><users class=""></users><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
      </div>
      <h3 class="text-sm font-bold text-text">Nenhum grupo encontrado</h3>
      <p class="text-xs text-secondary mt-1 max-w-xs mx-auto">Utilize o botão "Novo" para criar um novo grupo de estudos.</p>
    </div>

    <!-- List -->
    <div v-else class="grid grid-cols-1 gap-3">
      <ManagerListItem
        v-for="item in items"
        :key="item.id"
        :title="item.nome_grupo"
        :subtitle="item.descricao || 'Sem descrição'"
        @edit="emit('edit', item)"
        @delete="emit('delete', item)"
      >
        <template #icon>
           <div class="w-10 h-10 rounded bg-[#3571CB1A] text-primary flex items-center justify-center font-bold text-lg">
             {{ item.nome_grupo.charAt(0).toUpperCase() }}
           </div>
        </template>

        <template #details>
           <div class="flex items-center gap-4 text-xs text-secondary">
              <div class="flex items-center gap-1" title="Ano Letivo">
                 <span class="font-bold text-text bg-div-30 px-1.5 rounded text-[10px]">{{ item.ano }}</span>
              </div>
              <div class="flex items-center gap-1" title="Data de Criação">
                 <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                 <span>{{ formatDate(item.criado_em) }}</span>
              </div>
              <div class="flex items-center gap-1" title="Status">
                 <div :class="['w-2 h-2 rounded-full', item.status === 'ATIVO' ? 'bg-green-500' : 'bg-red-500']"></div>
                 <span class="font-medium">{{ item.status }}</span>
              </div>
              <div class="flex items-center gap-1" title="Tutores">
                  <span class="font-bold text-text">{{ item.total_tutores }}</span> Tutores
              </div>
               <div class="flex items-center gap-1" title="Integrantes">
                  <span class="font-bold text-text">{{ item.total_integrantes }}</span> Integrantes
              </div>
           </div>
        </template>
        
        <!-- Not implementing delete emission directly here unless parent handles it -->
      </ManagerListItem>
    </div>
  </div>
</template>
