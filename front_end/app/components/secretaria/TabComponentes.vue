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

const emit = defineEmits(['atribuir', 'delete'])

// Helper to format date
const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('pt-BR')
}

// Helper to get status badge
const getStatusBadge = (item) => {
  if (!item.atribuicao_id) {
    return { text: 'Sem atribuição', class: 'bg-yellow-500/10 text-yellow-600 border-yellow-500/20' }
  }
  if (item.data_fim) {
    return { text: 'Finalizada', class: 'bg-gray-500/10 text-gray-600 border-gray-500/20' }
  }
  return { text: 'Ativa', class: 'bg-green-500/10 text-green-600 border-green-500/20' }
}

const getInitials = (name) => {
    if (!name) return '?'
    const parts = name.split(' ')
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase()
    return name.slice(0, 2).toUpperCase()
}
</script>

<template>
  <div class="space-y-3">
    <!-- Loading State -->
    <div v-if="isLoading" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div v-for="i in 6" :key="i" class="h-48 bg-div-15 animate-pulse rounded-xl border border-[#6B82A71A]"></div>
    </div>

    <!-- Empty State -->
    <div v-else-if="items.length === 0" class="text-center py-20 bg-div-15 rounded-xl border border-[#6B82A71A]">
      <div class="w-16 h-16 bg-[#6B82A71A] rounded-full flex items-center justify-center mx-auto mb-4 text-secondary">
         <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5z"></path><path d="M2 17l10 5 10-5"></path><path d="M2 12l10 5 10-5"></path></svg>
      </div>
      <h3 class="text-sm font-bold text-text">Nenhum componente encontrado</h3>
      <p class="text-xs text-secondary mt-1 max-w-xs mx-auto">Não há componentes curriculares disponíveis com os filtros atuais.</p>
    </div>

    <!-- Card Grid -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-20">
      <div 
        v-for="item in items" 
        :key="`${item.id_turma}-${item.id_carga_horaria}`"
        class="group bg-surface border border-div-15 rounded-xl relative overflow-hidden hover:shadow-xl hover:-translate-y-1 transition-all duration-300 flex flex-col"
      >
         <!-- Color Bar -->
         <div class="absolute top-0 left-0 w-1.5 h-full" :style="{ backgroundColor: item.componente_cor || '#6B7280' }"></div>
         
         <!-- Card Header: Componente + Status -->
         <div class="p-4 pl-7 border-b border-div-15 bg-gradient-to-br from-white to-background dark:from-surface dark:to-surface">
            <div class="flex items-start justify-between gap-4 mb-3">
               <!-- Badge Status -->
               <div :class="['px-2.5 py-1 rounded-md text-[10px] font-black uppercase tracking-wider border shadow-sm backdrop-blur-sm', getStatusBadge(item).class]">
                  {{ getStatusBadge(item).text }}
               </div>
               
               <!-- Carga Horária -->
               <div class="text-[10px] font-bold text-secondary bg-div-15 px-2 py-0.5 rounded border border-secondary/10 tabular-nums" title="Carga Horária">
                   {{ item.carga_horaria }}h
               </div>
            </div>

            <!-- Titles -->
            <div>
               <h3 class="font-bold text-lg text-text truncate leading-tight mb-1" :title="item.componente_nome">
                   {{ item.componente_nome }}
               </h3>
               <p class="text-xs font-medium text-secondary truncate flex items-center gap-1.5">
                   <span class="font-bold text-primary">{{ item.turma_ano }}º {{ item.ano_etapa_nome }} {{ item.classe_nome }}</span>
                   <span class="w-1 h-1 rounded-full bg-secondary/40"></span>
                   <span class="opacity-80">{{ item.escola_nome }}</span>
               </p>
            </div>
         </div>

         <!-- Card Details: Professor -->
         <div class="p-4 pl-7 flex-1 flex flex-col gap-3">
             <div v-if="item.professor_nome" class="flex items-center gap-3 p-3 rounded-lg bg-div-15 border border-div-15">
                 <div class="w-8 h-8 rounded-full bg-surface border border-div-15 flex items-center justify-center text-xs font-bold text-primary shrink-0">
                     {{ getInitials(item.professor_nome) }}
                 </div>
                 <div class="min-w-0 flex-1">
                     <div class="flex items-center gap-2 mb-0.5">
                         <p class="text-[10px] font-bold text-secondary uppercase tracking-wider">Professor Atual</p>
                         <span 
                            class="text-[9px] font-black px-1.5 py-0 rounded border uppercase tracking-wider"
                            :class="(item.nivel_substituicao || 0) > 0 
                                ? 'bg-orange-500/10 text-orange-600 border-orange-500/20' 
                                : 'bg-blue-500/10 text-blue-600 border-blue-500/20'"
                        >
                            {{ (item.nivel_substituicao || 0) > 0 ? 'Substituto' : 'Titular' }}
                        </span>
                     </div>
                     <p class="text-xs font-bold text-text truncate" :title="item.professor_nome">{{ item.professor_nome }}</p>
                     <p v-if="item.data_inicio" class="text-[10px] text-secondary mt-0.5">Desde: {{ formatDate(item.data_inicio) }}</p>
                 </div>
             </div>

             <div v-else class="flex-1 flex flex-col items-center justify-center py-4 text-center border-2 border-dashed border-div-15 rounded-lg opacity-60">
                 <span class="text-xs font-semibold text-secondary">Sem professor titular</span>
             </div>
         </div>

         <!-- Actions Footer -->
         <button 
            @click="emit('atribuir', item)" 
            class="w-full py-3 text-xs font-bold uppercase tracking-wider transition-colors flex items-center justify-center gap-2 border-t border-div-15 bg-surface hover:bg-surface-hover group-hover:border-primary/10 text-primary"
         >
             <svg v-if="item.atribuicao_id" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
             <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="20" y1="8" x2="20" y2="14"></line><line x1="23" y1="11" x2="17" y2="11"></line></svg>
             {{ item.atribuicao_id ? 'Gerenciar Atribuição' : 'Atribuir Professor' }}
         </button>
      </div>
    </div>
  </div>
</template>
