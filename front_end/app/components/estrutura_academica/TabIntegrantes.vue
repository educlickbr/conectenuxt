<script setup>
import ManagerListItem from '@/components/ManagerListItem.vue'

const props = defineProps({
  items: { type: Array, default: () => [] },
  isLoading: { type: Boolean, default: false }
})

const emit = defineEmits(['delete'])

</script>

<template>
  <div class="space-y-3">
    <div v-if="isLoading">
        <div v-for="i in 3" :key="i" class="h-20 bg-div-15 animate-pulse rounded border border-[#6B82A71A]"></div>
    </div>
    <div v-else-if="items.length === 0" class="text-center py-20 bg-div-15 rounded border border-[#6B82A71A]">
         <h3 class="text-sm font-bold text-text">Nenhum integrante encontrado</h3>
         <p class="text-xs text-secondary">Vincule alunos aos grupos utilizando o botão "Novo".</p>
    </div>
    <div v-else class="grid grid-cols-1 gap-3">
        <ManagerListItem
            v-for="item in items"
            :key="item.id"
            :title="item.nome_completo"
            :subtitle="item.nome_grupo + ' • Ano ' + (item.ano || '-')"
            @delete="emit('delete', item)"
        >
             <template #icon>
                 <div class="w-10 h-10 rounded-full bg-pink-500/10 text-pink-500 flex items-center justify-center font-bold text-lg overflow-hidden">
                     <img v-if="item.avatar" :src="item.avatar" class="w-full h-full object-cover">
                     <span v-else>{{ item.nome_completo.charAt(0).toUpperCase() }}</span>
                 </div>
             </template>
              <template #details>
                   <div class="flex items-center gap-4 text-xs text-secondary">
                      <span>{{ item.email }}</span>
                      <div class="flex items-center gap-1">
                         <div :class="['w-2 h-2 rounded-full', item.status === 'ATIVO' ? 'bg-green-500' : 'bg-red-500']"></div>
                         <span class="font-medium">{{ item.status }}</span>
                      </div>
                   </div>
              </template>
        </ManagerListItem>
    </div>
  </div>
</template>
