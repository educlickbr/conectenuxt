<script setup lang="ts">
import { type PropType } from 'vue'
import ManagerListItem from '@/components/ManagerListItem.vue'

interface FichaTecnica {
  prato_id: string
  prato_nome: string
  ingredientes_count: number
  total_quantidade: number
  rendimento: number
  [key: string]: any
}

const props = defineProps({
  items: {
    type: Array as PropType<FichaTecnica[]>,
    default: () => []
  },
  isLoading: {
    type: Boolean,
    default: false
  }
})

defineEmits(['edit', 'delete'])
</script>

<template>
  <div class="flex flex-col gap-2 p-6">
    <!-- Loading State -->
    <div v-if="isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 gap-4 opacity-50">
      <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin" />
      <p class="text-xs font-bold uppercase tracking-widest text-secondary">Carregando Receitas...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="!isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 text-center text-secondary bg-div-15 rounded border border-div-30/50">
      <div class="w-16 h-16 bg-div-15 rounded-full flex items-center justify-center mb-4 text-secondary text-2xl">
        📋
      </div>
      <p>Nenhuma receita encontrada. Selecione um prato para detalhar sua composição.</p>
    </div>

    <!-- Data List -->
    <div v-else class="flex flex-col gap-2">
      <ManagerListItem
        v-for="(item, index) in items"
        :key="item.prato_id || index"
        :item="item"
        :title="item.prato_nome"
        @edit="$emit('edit', item)"
        @delete="$emit('delete', item)"
      >
        <template #icon>
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-primary">
            <path d="M16 3h5v5"/><path d="M8 3H3v5"/><path d="M12 22v-8.3a4 4 0 0 0-1.172-2.872L3 3"/><path d="m15 9 6-6"/><path d="M3 21h18"/>
          </svg>
        </template>
        <template #metadata>
          <span class="text-[10px] bg-div-15 px-2 py-0.5 rounded text-secondary font-black uppercase tracking-wider">
            {{ item.ingredientes_count || 0 }} Ingredientes
          </span>
          <span v-if="item.rendimento > 1" class="text-[10px] bg-div-15 px-2 py-0.5 rounded text-primary font-black uppercase tracking-wider">
            Rende {{ item.rendimento }} porções
          </span>
          <span v-if="item.total_quantidade" class="text-[10px] text-secondary font-medium">
            Total p/ receita: {{ item.total_quantidade }}
          </span>
        </template>
      </ManagerListItem>
    </div>
  </div>
</template>
