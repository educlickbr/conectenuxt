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
      <p class="text-xs font-bold uppercase tracking-widest text-secondary">Carregando Componentes...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="!isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 text-center text-secondary bg-div-15 rounded border border-div-30/50">
      <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="mb-4 text-secondary/40"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
      <p>Nenhum componente encontrado.</p>
    </div>

    <!-- Data List -->
    <div v-else class="flex flex-col gap-2">
      <ManagerListItem
        v-for="(item, index) in items"
        :key="item.uuid || index"
        :item="item"
        :title="item.nome"
        @edit="$emit('edit', item)"
        @delete="$emit('delete', item)"
      >
        <template #icon>
           <div 
             class="w-10 h-10 rounded flex items-center justify-center shrink-0 border border-secondary/10 shadow-sm"
             :style="{ backgroundColor: item.cor || '#3571CB1A', color: item.cor ? '#fff' : 'inherit' }"
           >
             <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"></path></svg>
           </div>
        </template>
        <template #metadata>
           <div class="text-[10px] font-medium text-secondary/60 uppercase tracking-wider">
             {{ item.id_sharepoint ? `ID: ${item.id_sharepoint}` : 'Local' }}
           </div>
        </template>
      </ManagerListItem>
    </div>
  </div>
</template>
