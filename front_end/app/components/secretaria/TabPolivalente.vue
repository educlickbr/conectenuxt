<script setup>
import { computed } from 'vue'

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

const emit = defineEmits(['atribuir'])

// Helper to format date
const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('pt-BR')
}

// Helper to get status badge
const getStatusBadge = (item) => {
  if (!item.atribuicao_id) {
    return { text: 'SEM ATRIBUIÇÃO', class: 'bg-yellow-500/10 text-yellow-600 border-yellow-500/20' }
  }
  if (item.data_fim) {
    return { text: 'FINALIZADA', class: 'bg-gray-500/10 text-gray-600 border-gray-500/20' }
  }
  return { text: 'ATIVA', class: 'bg-green-500/10 text-green-600 border-green-500/20' }
}

const getInitials = (name) => {
    if (!name) return '?'
    const parts = name.trim().split(/\s+/)
    if (parts.length >= 2) return ((parts[0] || '').charAt(0) + (parts[1] || '').charAt(0)).toUpperCase()
    return name.slice(0, 2).toUpperCase()
}
</script>

<template>
  <div class="space-y-6">
    <!-- Loading State -->
    <div v-if="isLoading" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      <div v-for="i in 6" :key="i" class="h-40 bg-div-15 animate-pulse rounded-xl border border-div-15"></div>
    </div>

    <!-- Empty State -->
    <div v-else-if="items.length === 0" class="text-center py-20 bg-div-15 rounded-xl border border-div-15">
      <div class="w-16 h-16 bg-div-15 rounded-full flex items-center justify-center mx-auto mb-4 text-secondary">
         <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
      </div>
      <h3 class="text-sm font-bold text-text">Nenhuma turma encontrada</h3>
      <p class="text-xs text-secondary mt-1 max-w-xs mx-auto">Não há turmas disponíveis para atribuição com os filtros atuais.</p>
    </div>

    <!-- Grid List -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      <div 
        v-for="item in items" 
        :key="item.id_turma"
        class="group bg-surface border border-div-15 rounded-xl overflow-hidden hover:shadow-xl hover:-translate-y-1 transition-all duration-300 relative flex flex-col"
      >
        <!-- Card Header -->
        <div class="p-4 flex items-start gap-4 relative bg-gradient-to-br from-white to-background dark:from-surface dark:to-surface border-b border-div-15">
            
            <!-- Status Badge -->
            <div class="absolute top-4 right-4 text-[10px] font-bold px-2 py-1 rounded-md border shadow-sm backdrop-blur-sm"
                :class="getStatusBadge(item).class"
            >
                {{ getStatusBadge(item).text }}
            </div>

            <!-- Icon -->
            <div class="w-12 h-12 rounded-xl bg-primary/10 text-primary flex items-center justify-center font-black text-sm shrink-0">
                {{ item.classe_nome ? item.classe_nome.charAt(0) : 'T' }}
            </div>

            <!-- Info -->
            <div class="min-w-0 flex-1 pr-20">
                <h4 class="font-bold text-text text-sm truncate leading-snug mb-1" :title="`${item.turma_ano} - ${item.classe_nome}`">
                    {{ item.classe_nome }}
                </h4>
                <div class="text-[11px] text-secondary flex flex-col gap-0.5 leading-tight opacity-80">
                     <span>{{ item.ano_etapa_nome }}</span>
                     <span>{{ item.escola_nome }}</span>
                </div>
            </div>
        </div>

        <!-- Body: Professor Info -->
        <div class="p-4 flex-1 flex flex-col gap-3">
            <div v-if="item.professor_nome" class="flex items-center gap-3 p-3 rounded-lg bg-div-15 border border-div-15">
                <div class="w-8 h-8 rounded-full bg-surface border border-div-15 flex items-center justify-center text-xs font-bold text-primary">
                    {{ getInitials(item.professor_nome) }}
                </div>
                <div class="min-w-0">
                    <div class="flex items-center gap-2">
                        <p class="text-[10px] font-bold text-secondary uppercase tracking-wider">Professor Atual</p>
                        <span 
                            v-if="item.professor_nome"
                            class="text-[9px] font-black px-1.5 py-0.5 rounded border uppercase tracking-wider"
                            :class="item.nivel_substituicao > 0 
                                ? 'bg-orange-500/10 text-orange-600 border-orange-500/20' 
                                : 'bg-blue-500/10 text-blue-600 border-blue-500/20'"
                        >
                            {{ item.nivel_substituicao > 0 ? 'Substituto' : 'Titular' }}
                        </span>
                    </div>
                    <p class="text-xs font-bold text-text truncate" :title="item.professor_nome">{{ item.professor_nome }}</p>
                    <p class="text-[10px] text-secondary mt-0.5">Desde: {{ formatDate(item.data_inicio) }}</p>
                </div>
            </div>
            
            <div v-else class="flex-1 flex flex-col items-center justify-center py-4 text-center border-2 border-dashed border-div-15 rounded-lg opacity-60">
                <span class="text-xs font-semibold text-secondary">Sem professor titular</span>
            </div>
        </div>

        <!-- Footer -->
        <button 
            @click="emit('atribuir', item)"
            class="w-full py-3 text-xs font-bold uppercase tracking-wider transition-colors flex items-center justify-center gap-2 border-t border-div-15 bg-surface hover:bg-surface-hover group-hover:border-primary/10 text-primary"
        >
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
            {{ item.atribuicao_id ? 'Gerenciar Atribuição' : 'Atribuir Professor' }}
        </button>

      </div>
    </div>
  </div>
</template>

