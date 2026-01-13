<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
    periodos: {
        numero: number
        data_inicio: string
        data_fim: string
    }[]
}>()

// Helper to format date "DD" and "MMM"
const getDay = (dateStr: string) => {
    if (!dateStr) return ''
    return new Date(dateStr).getUTCDate().toString().padStart(2, '0')
}

const getMonth = (dateStr: string) => {
    if (!dateStr) return ''
    return new Date(dateStr).toLocaleDateString('pt-BR', { month: 'short', timeZone: 'UTC' }).replace('.', '').toUpperCase()
}

// Helper: Calculate width/position based on dates?
// Or just equal distribution since it's "Bimestres"?
// The user asked for "linear timeline showing 4 bimestres in sequence"
// "Diferente de um Gantt tradicional... ocupam a mesma faixa horizontal"
// If we just render them side-by-side (flex), it mimics the "sequence".

const sortedPeriodos = computed(() => {
    return [...props.periodos].sort((a, b) => a.numero - b.numero)
})

// Optional: Colors for different periods to make them distinct
const getPeriodColor = (index: number) => {
    const colors = [
        'bg-blue-500/10 text-blue-600 border-blue-200',
        'bg-emerald-500/10 text-emerald-600 border-emerald-200',
        'bg-purple-500/10 text-purple-600 border-purple-200',
        'bg-orange-500/10 text-orange-600 border-orange-200'
    ]
    return colors[index % colors.length]
}

</script>

<template>
    <div class="w-full flex items-center h-16 rounded-xl bg-div-10 overflow-hidden relative border border-secondary/5">
        
        <div 
            v-for="(periodo, idx) in sortedPeriodos" 
            :key="periodo.numero"
            class="flex-1 h-full flex flex-col justify-between p-1.5 relative group border-r last:border-r-0 border-secondary/5 transition-colors hover:bg-white/40"
            :class="getPeriodColor(idx)"
        >
            <!-- Label (Bimestre X) -->
            <div class="flex items-center justify-center w-full">
                <span class="text-[9px] uppercase tracking-widest font-bold opacity-70">
                    {{ periodo.numero }}º Período
                </span>
            </div>

            <!-- Dates -->
            <div class="flex justify-between items-end w-full px-1 mb-1">
                <!-- Start Date -->
                <div class="flex flex-col items-center leading-none">
                    <span class="text-[13px] font-black tracking-tight opacity-90">{{ getDay(periodo.data_inicio) }}</span>
                    <span class="text-[8px] font-bold uppercase opacity-60">{{ getMonth(periodo.data_inicio) }}</span>
                </div>

                 <!-- Connector Line visual -->
                <div class="h-[2px] flex-1 mx-2 bg-current opacity-10 rounded-full mb-1.5"></div>
                
                <!-- End Date -->
                <div class="flex flex-col items-center leading-none">
                     <span class="text-[13px] font-black tracking-tight opacity-90">{{ getDay(periodo.data_fim) }}</span>
                    <span class="text-[8px] font-bold uppercase opacity-60">{{ getMonth(periodo.data_fim) }}</span>
                </div>
            </div>
            
             <!-- Hover Tooltip equivalent -->
             <div class="absolute inset-0 opacity-0 group-hover:opacity-10 pointer-events-none bg-current"></div>
        </div>

        <!-- Empty State if no periods -->
        <div v-if="periodos.length === 0" class="w-full flex items-center justify-center text-xs text-secondary/50 italic">
            Sem períodos definidos
        </div>
    </div>
</template>
