<script setup lang="ts">
import CalendarioTimeline from './CalendarioTimeline.vue'

const props = defineProps<{
    calendarios: Array<{
        id: string
        ano: number
        escopo: 'Rede' | 'Ano_Etapa'
        ano_etapa_nome?: string // If scoped to Ano_Etapa
        modelo_nome?: string
        periodos: Array<{
            numero: number
            data_inicio: string
            data_fim: string
        }>
    }>,
    loading?: boolean
}>()

const emit = defineEmits(['edit', 'delete'])

</script>

<template>
    <div class="flex flex-col gap-4">
        
        <div v-if="loading && calendarios.length === 0" class="py-12 flex justify-center">
            <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin"></div>
        </div>

        <div v-else-if="calendarios.length === 0" class="py-12 text-center text-secondary/50 italic bg-div-10 rounded-lg border border-div-30 border-dashed">
            Nenhum calendário encontrado para os filtros selecionados.
        </div>

        <div 
            v-for="cal in calendarios" 
            :key="cal.id"
            class="bg-surface rounded-xl border border-secondary/10 shadow-sm p-4 hover:border-primary/30 transition-colors group"
        >
            <div class="flex flex-col md:flex-row md:items-center gap-4">
                
                <!-- Left: Info -->
                <div class="w-full md:w-1/4 min-w-[200px] flex flex-col gap-1">
                    <div class="flex items-center gap-2">
                        <span 
                            class="px-1.5 py-0.5 rounded-[3px] uppercase tracking-wider font-bold text-[9px]"
                            :class="cal.escopo === 'Rede' ? 'bg-primary/10 text-primary' : 'bg-orange-500/10 text-orange-600'"
                        >
                            {{ cal.escopo === 'Rede' ? 'Rede' : 'Por Etapa' }}
                        </span>
                        <span class="text-xs font-bold text-secondary">{{ cal.ano }}</span>
                    </div>

                    <h4 class="font-bold text-text truncate" :title="cal.escopo === 'Rede' ? 'Calendário da Rede' : cal.ano_etapa_nome">
                        {{ cal.escopo === 'Rede' ? 'Calendário Unificado' : cal.ano_etapa_nome }}
                    </h4>
                    
                    <span class="text-[10px] text-secondary/70">
                        Modelo: {{ cal.modelo_nome || 'Padrão' }}
                    </span>
                </div>

                <!-- Right: Timeline -->
                <div class="flex-1 min-w-0">
                    <CalendarioTimeline :periodos="cal.periodos" />
                </div>

                <!-- Context Actions (Visible on Hover/Focus) -->
                <!-- <div class="flex items-center gap-1 opacity-100 md:opacity-0 group-hover:opacity-100 transition-opacity">
                    <button @click="$emit('edit', cal)" class="p-2 hover:bg-div-30 rounded text-secondary hover:text-primary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    </button>
                    <button @click="$emit('delete', cal)" class="p-2 hover:bg-red-500/10 rounded text-secondary hover:text-red-500 transition-colors">
                         <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"></path><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"></path><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"></path></svg>
                    </button>
                </div> -->
                <!-- Temporarily hidden until actions implemented -->
            </div>
        </div>
    </div>
</template>
