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
  <div class="flex flex-col gap-2">
    <!-- Loading State -->
    <div v-if="isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 gap-4 opacity-50">
      <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin" />
      <p class="text-xs font-bold uppercase tracking-widest text-secondary">Carregando Classes...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="!isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 text-center text-secondary bg-div-15 rounded border border-div-30/50">
      <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="mb-4 text-secondary/40"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect></svg>
      <p>Nenhuma classe encontrada.</p>
    </div>

    <!-- Data List -->
    <div v-else class="flex flex-col gap-2">
      <ManagerListItem
        v-for="(item, index) in items"
        :key="item.id || item.uuid || index"
        :item="item"
        :title="item.nome || item.descricao"
        icon="📋"
        @edit="$emit('edit', item)"
        @delete="$emit('delete', item)"
      >
        <template #metadata>
           <!-- Customize metadata for Classes if needed -->
           <!-- Example: <span v-if="item.sigla">{{ item.sigla }}</span> -->
        </template>
      </ManagerListItem>
    </div>
  </div>
</template>
