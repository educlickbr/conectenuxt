<script setup lang="ts">
import { type PropType } from 'vue'
import ManagerListItem from '@/components/ManagerListItem.vue'

const props = defineProps({
  items: {
    type: Array as PropType<any[]>,
    default: () => []
  },
  isLoading: {
    type: Boolean,
    default: false
  }
})

defineEmits(['edit', 'delete'])

const formatDate = (date: string) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('pt-BR', { 
    day: '2-digit', 
    month: '2-digit', 
    year: 'numeric' 
  })
}
</script>

<template>
  <div class="flex flex-col gap-2">
    <!-- Loading State -->
    <div v-if="isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 gap-4 opacity-50">
      <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin" />
      <p class="text-xs font-bold uppercase tracking-widest text-secondary">Carregando Ciclos...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="!isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 text-center text-secondary bg-div-15 rounded border border-div-30/50">
      <div class="w-16 h-16 bg-div-15 rounded-full flex items-center justify-center mb-4 text-secondary text-2xl">
        📅
      </div>
      <p>Nenhum ciclo de cardápio encontrado. Clique em "Novo" para criar.</p>
    </div>

    <!-- Data List -->
    <ManagerListItem
      v-for="(item, index) in items"
      :key="item.id || index"
      :item="item"
      :title="item.nome"
      @edit="$emit('edit', item)"
      @delete="$emit('delete', item)"
    >
      <template #icon>
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-primary"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
      </template>
      <template #metadata>
        <span class="text-[10px] text-secondary font-medium">
          {{ formatDate(item.data_inicio) }} - {{ formatDate(item.data_fim) }}
        </span>
        <span v-if="item.etapas && item.etapas.length" class="text-[10px] bg-div-15 px-2 py-0.5 rounded text-secondary font-black uppercase tracking-wider">
          {{ item.etapas.length }} Etapas
        </span>
      </template>
    </ManagerListItem>
  </div>
</template>
