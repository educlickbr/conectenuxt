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

const formatCurrency = (value: number | string) => {
    if (!value) return 'R$ -'
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(Number(value))
}
</script>

<template>
  <div class="flex flex-col gap-2 p-6">
    <!-- Loading State -->
    <div v-if="isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 gap-4 opacity-50">
      <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin" />
      <p class="text-xs font-bold uppercase tracking-widest text-secondary">Carregando Alimentos...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="!isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 text-center text-secondary bg-div-15 rounded border border-div-30/50">
        <div class="w-16 h-16 bg-div-15 rounded-full flex items-center justify-center mb-4 text-secondary text-2xl">
            🥦
        </div>
      <p>Nenhum alimento encontrado.</p>
    </div>

    <!-- Data List -->
    <div v-else class="flex flex-col gap-2">
      <ManagerListItem
        v-for="(item, index) in items"
        :key="item.id || index"
        :item="item"
        :title="item.nome"
        @edit="$emit('edit', item)"
        @delete="$emit('delete', item)"
      >
        <template #icon>
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-primary"><path d="M2.27 21.7s9.87-3.5 12.73-6.36a4.5 4.5 0 0 0-6.36-6.37C5.77 11.84 2.27 21.7 2.27 21.7z"/><path d="M8.64 14l-2.05 2.04"/><path d="M15.34 15l-2.46-.61"/><path d="M15.34 15l.61 2.46"/><path d="M15.34 15l-6.7-6.7"/></svg>
        </template>
        <template #metadata>
             <span class="text-[10px] bg-div-15 px-2 py-0.5 rounded text-secondary font-black uppercase tracking-wider">
               {{ item.unidade_medida }}
            </span>
             <span class="text-[10px] bg-div-15 px-2 py-0.5 rounded text-secondary font-medium uppercase">
               {{ item.categoria }}
             </span>
             <span class="text-[10px] text-secondary font-medium">
               Médio: {{ formatCurrency(item.preco_medio) }}
             </span>
        </template>
      </ManagerListItem>
    </div>
  </div>
</template>
