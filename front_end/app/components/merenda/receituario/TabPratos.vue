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
</script>

<template>
  <div class="flex flex-col gap-2 p-6">
    <!-- Loading State -->
    <div v-if="isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 gap-4 opacity-50">
      <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin" />
      <p class="text-xs font-bold uppercase tracking-widest text-secondary">Carregando Pratos...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="!isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 text-center text-secondary bg-div-15 rounded border border-div-30/50">
        <div class="w-16 h-16 bg-div-15 rounded-full flex items-center justify-center mb-4 text-secondary text-2xl">
            🥘
        </div>
      <p>Nenhum prato encontrado.</p>
    </div>

    <!-- Data List -->
    <div v-else class="flex flex-col gap-2">
      <ManagerListItem
        v-for="(item, index) in items"
        :key="item.id || index"
        :item="item"
        :title="item.nome"
        :description="item.descricao || 'Sem descrição'"
        @edit="$emit('edit', item)"
        @delete="$emit('delete', item)"
      >
        <template #icon>
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-primary"><path d="M2 12h20"/><path d="M20 12v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-8"/><path d="m4 8 16-4"/><path d="m8.86 6.78-.45-1.81a2 2 0 0 1 1.45-2.43l1.94-.55a2 2 0 0 1 2.43 1.45l.45 1.81"/></svg>
        </template>
        <template #metadata>
             <span v-if="item.modo_preparo" class="text-[10px] text-secondary truncate max-w-[200px]" title="Modo de Preparo">
                🥣 {{ item.modo_preparo }}
            </span>
        </template>
      </ManagerListItem>
    </div>
  </div>
</template>
