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
      <p class="text-xs font-bold uppercase tracking-widest text-secondary">Carregando Anos/Etapas...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="!isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 text-center text-secondary bg-div-15 rounded border border-div-30/50">
      <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="mb-4 text-secondary/40"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
      <p>Nenhum ano ou etapa encontrado.</p>
    </div>

    <!-- Data List -->
    <div v-else class="flex flex-col gap-2">
      <ManagerListItem
        v-for="(item, index) in items"
        :key="item.id || item.uuid || index"
        :item="item"
        :title="item.nome || item.ano || 'Sem Nome'"
        icon="📅"
        @edit="$emit('edit', item)"
        @delete="$emit('delete', item)"
      >
        <template #metadata>
          <span v-if="item.ano" class="font-bold text-primary">{{ item.ano }}</span>
          <span v-if="item.etapa" class="opacity-70">{{ item.etapa }}</span>
        </template>
      </ManagerListItem>
    </div>
  </div>
</template>
