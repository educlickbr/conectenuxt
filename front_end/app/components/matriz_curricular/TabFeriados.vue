<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ModalGerenciarFeriado from '@/components/matriz_curricular/ModalGerenciarFeriado.vue'
import ModalConfirmacao from '@/components/ModalConfirmacao.vue'

const appStore = useAppStore()
const toast = useToastStore()

// State
const feriados = ref([])
const isLoading = ref(false)
const expandedMonths = ref({}) 
const currentYear = ref(new Date().getFullYear())

// Modals
const isModalOpen = ref(false)
const selectedFeriado = ref(null)
const isConfirmOpen = ref(false)
const feriadoToDelete = ref(null)
const isDeleting = ref(false)

// Fetch Data
const fetchFeriados = async () => {
    isLoading.value = true
    try {
        const { items } = await $fetch('/api/estrutura_academica/feriados', {
            query: {
                id_empresa: appStore.company.empresa_id,
                limite: 1000 
            }
        })
        feriados.value = items || []
        
        // Auto-expand current month IF no months are expanded yet
        if (Object.keys(expandedMonths.value).length === 0) {
             const currentMonthKey = new Date().toISOString().slice(0, 7) // YYYY-MM
             expandedMonths.value[currentMonthKey] = true
        }
    } catch (err) {
        console.error('Erro ao buscar feriados:', err)
        toast.showToast('Erro ao carregar feriados.', 'error')
    } finally {
        isLoading.value = false
    }
}

onMounted(() => {
    fetchFeriados()
})

// Generate Timeline Months (Full Year)
const timelineMonths = computed(() => {
    let minYear = currentYear.value
    let maxYear = currentYear.value

    if (feriados.value.length > 0) {
        const years = feriados.value.map(f => new Date(f.data_inicio).getUTCFullYear())
        minYear = Math.min(minYear, ...years)
        maxYear = Math.max(maxYear, ...years)
    }

    const months = []
    
    for (let y = minYear; y <= maxYear; y++) {
        for (let m = 0; m < 12; m++) {
            const date = new Date(Date.UTC(y, m, 1))
            const key = date.toISOString().slice(0, 7) 
            
            // Filter feriados
            const monthFeriados = feriados.value.filter(f => f.data_inicio.startsWith(key))
            monthFeriados.sort((a, b) => new Date(a.data_inicio) - new Date(b.data_inicio))

            months.push({
                key,
                label: date.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric', timeZone: 'UTC' }),
                monthName: date.toLocaleDateString('pt-BR', { month: 'long', timeZone: 'UTC' }),
                year: y,
                feriados: monthFeriados,
                isPast: new Date() > new Date(y, m + 1, 0),
                isCurrent: key === new Date().toISOString().slice(0, 7)
            })
        }
    }
    
    return months
})

// Actions
const toggleMonth = (key) => {
    if (expandedMonths.value[key] === undefined) {
        expandedMonths.value[key] = true
    } else {
        expandedMonths.value[key] = !expandedMonths.value[key]
    }
}

const toggleAllMonths = () => {
    const allKeys = timelineMonths.value.map(m => m.key)
    const areAllExpanded = allKeys.every(k => expandedMonths.value[k])
    
    if (areAllExpanded) {
        expandedMonths.value = {}
    } else {
        const newExpanded = {}
        allKeys.forEach(k => newExpanded[k] = true)
        expandedMonths.value = newExpanded
    }
}

const handleAddInMonth = (monthKey) => {
    selectedFeriado.value = {
        data_inicio: `${monthKey}-01`
    }
    isModalOpen.value = true
}

const handleEdit = (feriado) => {
    selectedFeriado.value = feriado
    isModalOpen.value = true
}

const handleDelete = (feriado) => {
    feriadoToDelete.value = feriado
    isConfirmOpen.value = true
}

const confirmDelete = async () => {
    if (!feriadoToDelete.value) return
    isDeleting.value = true
    try {
        const { success } = await $fetch('/api/estrutura_academica/feriados', {
            method: 'DELETE',
            body: {
                id: feriadoToDelete.value.id,
                id_empresa: appStore.company.empresa_id
            }
        })
        if (success) {
            toast.showToast('Feriado excluído.')
            await fetchFeriados()
            isConfirmOpen.value = false
        }
    } catch (err) {
        toast.showToast('Erro ao excluir feriado.', 'error')
    } finally {
        isDeleting.value = false
    }
}

const handleSuccess = () => {
    fetchFeriados()
}

// Helpers
const getDay = (dateStr) => {
    return new Date(dateStr).getUTCDate()
}
const getWeekDay = (dateStr) => {
    return new Date(dateStr).toLocaleDateString('pt-BR', { weekday: 'short', timeZone: 'UTC' }).toUpperCase().slice(0, 3)
}
</script>

<template>
    <div class="p-6 md:p-8 min-h-[500px]">
        
        <div v-if="isLoading && feriados.length === 0" class="flex justify-center py-12">
             <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin"></div>
        </div>

        <!-- Timeline Container -->
        <div v-else class="relative max-w-4xl mx-auto pl-4 md:pl-0">

            <!-- Expand/Collapse All -->
            <div class="flex justify-end mb-4 relative z-20">
                 <button 
                    @click="toggleAllMonths"
                    class="p-2 text-secondary hover:text-primary transition-colors flex items-center gap-2 text-xs font-bold uppercase tracking-wider bg-div-10 rounded-lg hover:bg-div-30"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="13 17 18 12 13 7"></polyline><polyline points="6 17 11 12 6 7"></polyline></svg>
                    <span>Expandir / Recolher</span>
                </button>
            </div>
            
            <!-- Vertical Line -->
            <div class="absolute left-0 md:left-1/2 top-0 bottom-0 w-px bg-gradient-to-b from-transparent via-primary/30 to-transparent"></div>

            <div class="flex flex-col gap-8 relative z-10">
                
                <!-- Month Group -->
                <div 
                    v-for="month in timelineMonths" 
                    :key="month.key"
                    class="group relative transition-all duration-300 flex flex-col"
                    :class="[
                        // Alternating alignment based on Month Number (1-12)
                        // month.key is YYYY-MM
                         { 'opacity-60 hover:opacity-100': month.feriados.length === 0 && !expandedMonths[month.key] && !month.isCurrent }
                    ]"
                >
                    <!-- Timeline Node (Circle) -->
                    <div 
                        class="absolute left-[-4.5px] md:left-1/2 md:-ml-[5px] top-6 w-[10px] h-[10px] rounded-full transition-all duration-300 z-20 shadow-[0_0_10px_rgba(var(--color-primary),0.2)]"
                        :class="[
                            month.feriados.length > 0 ? 'bg-primary border-primary' : 'bg-background border-secondary/30',
                            month.isCurrent ? 'scale-125 border-primary bg-primary shadow-[0_0_15px_rgba(var(--color-primary),0.8)]' : 'border-2'
                        ]"
                    ></div>

                    <!-- Month Header Card -->
                    <div 
                        class="w-full md:w-[calc(50%-2rem)] mb-2 md:mb-0 transition-all duration-300 select-none relative"
                        :class="[
                            parseInt(month.key.split('-')[1]) % 2 !== 0 ? 'md:mr-auto text-left' : 'md:ml-auto text-left' 
                        ]"
                    >
                        <!-- Connection Line for Header -->
                        <div 
                             class="hidden md:block absolute top-[1.6rem] w-[2rem] h-px bg-secondary/10"
                             :class="parseInt(month.key.split('-')[1]) % 2 !== 0 ? '-right-[2rem]' : '-left-[2rem]'"
                        ></div>

                         <div 
                            class="rounded-xl p-3 flex items-center justify-between shadow-sm cursor-pointer transition-all group-hover:bg-div-15"
                             @click="toggleMonth(month.key)"
                        >
                            <div class="flex items-center gap-4 flex-1">
                                <!-- Month Name -->
                                <div class="flex flex-col">
                                    <h3 
                                        class="text-xl font-bold capitalize leading-tight transition-colors"
                                        :class="month.isCurrent ? 'text-primary' : 'text-text'"
                                    >
                                        {{ month.monthName }} 
                                    </h3>
                                    <span class="text-[10px] font-black tracking-widest text-secondary/50">{{ month.year }}</span>
                                </div>
                                
                                <!-- Count Badge -->
                                <div 
                                    v-if="month.feriados.length > 0"
                                    class="px-2 py-0.5 rounded text-[10px] font-bold"
                                    :class="month.isCurrent ? 'bg-primary text-white' : 'bg-div-30 text-secondary'"
                                >
                                    {{ month.feriados.length }}
                                </div>
                            </div>
                            
                            <!-- Actions -->
                            <div class="flex items-center gap-3">
                                <!-- Add Button -->
                                <button 
                                    @click.stop="handleAddInMonth(month.key)"
                                    class="w-8 h-8 flex items-center justify-center rounded-full bg-div-30 text-secondary hover:bg-primary hover:text-white hover:scale-110 transition-all"
                                    title="Adicionar Feriado"
                                >
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                                </button>
                                
                                <!-- Chevron -->
                                <div 
                                    class="text-secondary/50 transition-transform duration-300"
                                    :class="{ 'rotate-180': expandedMonths[month.key] }"
                                >
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Feriados List (Collapsible) -->
                    <div 
                        v-show="expandedMonths[month.key]"
                        class="flex flex-col gap-3 mt-2 transition-all w-full md:w-[calc(50%-2rem)]"
                         :class="[
                            parseInt(month.key.split('-')[1]) % 2 !== 0 ? 'md:mr-auto' : 'md:ml-auto'
                        ]"
                    >
                         <!-- If empty and expanded, show hint -->
                        <div v-if="month.feriados.length === 0" class="w-full p-4 opacity-50 text-xs italic text-secondary text-center md:text-left">
                            (Nenhum feriado)
                        </div>

                        <div 
                            v-for="(feriado, idx) in month.feriados" 
                            :key="feriado.id"
                            class="relative w-full transition-all hover:-translate-y-0.5"
                        >   
                            <!-- Connection Line (Desktop) -->
                            <div class="hidden md:block absolute top-1/2 w-[2rem] h-px bg-secondary/10"
                                :class="parseInt(month.key.split('-')[1]) % 2 !== 0 ? '-right-[2rem]' : '-left-[2rem]'"
                            ></div>

                            <div 
                                class="bg-surface border border-secondary/10 hover:border-primary/50 px-4 py-3 rounded-lg shadow-sm group/card relative overflow-hidden cursor-default"
                            >   
                                <!-- Neon Glow on Hover -->
                                <div class="absolute inset-0 bg-primary/5 opacity-0 group-hover/card:opacity-100 transition-opacity pointer-events-none"></div>

                                <div class="relative flex items-center gap-4 justify-between">
                                    
                                    <!-- Date Badge -->
                                    <div class="flex flex-col items-center justify-center bg-div-15 rounded p-1.5 min-w-[3rem] border border-secondary/5">
                                        <span class="text-[9px] font-black uppercase text-secondary tracking-widest">{{ getWeekDay(feriado.data_inicio) }}</span>
                                        <span class="text-lg font-bold text-primary leading-none">{{ getDay(feriado.data_inicio) }}</span>
                                    </div>

                                    <!-- Content -->
                                    <div class="flex-1 min-w-0 flex flex-col justify-center">
                                        <h4 class="font-bold text-sm truncate" :title="feriado.nome_feriado">{{ feriado.nome_feriado }}</h4>
                                        <div class="text-[10px] text-secondary flex items-center gap-2 mt-0.5">
                                            <span 
                                                class="px-1.5 py-0.5 rounded-[3px] bg-div-30 uppercase tracking-wider font-bold text-[8px]"
                                                :class="{
                                                    'text-red-500': feriado.tipo === 'Nacional',
                                                    'text-blue-500': feriado.tipo === 'Estadual',
                                                    'text-green-500': feriado.tipo === 'Escolar'
                                                }"
                                            >
                                                {{ feriado.tipo }}
                                            </span>
                                            <span v-if="feriado.data_inicio !== feriado.data_fim">
                                                 até {{ new Date(feriado.data_fim).getUTCDate() }}/{{ new Date(feriado.data_fim).getUTCMonth()+1 }}
                                            </span>
                                        </div>
                                    </div>

                                    <!-- Actions (Hover Only) -->
                                    <div class="flex items-center gap-1 opacity-100 md:opacity-0 group-hover/card:opacity-100 transition-opacity">
                                        <button @click="handleEdit(feriado)" class="p-1.5 hover:bg-div-30 rounded text-secondary hover:text-primary transition-colors" title="Editar">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                        </button>
                                         <button @click="handleDelete(feriado)" class="p-1.5 hover:bg-red-500/10 rounded text-secondary hover:text-red-500 transition-colors" title="Excluir">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"></path><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"></path><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"></path></svg>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                 <!-- Hint at bottom -->
                 <div class="flex justify-center mt-12 mb-8 opacity-50">
                     <p class="text-[10px] uppercase tracking-widest text-secondary font-medium">-- Fim do Calendário --</p>
                 </div>
            </div>
        </div>

        <!-- Modals -->
        <ModalGerenciarFeriado
            v-if="isModalOpen"
            :is-open="isModalOpen"
            :initial-data="selectedFeriado"
            @close="isModalOpen = false"
            @success="handleSuccess"
        />

        <ModalConfirmacao
            :is-open="isConfirmOpen"
            title="Excluir Feriado?"
            :message="`Tem certeza que deseja excluir <b>${feriadoToDelete?.nome_feriado}</b>?`"
            confirm-text="Sim, excluir"
            :is-loading="isDeleting"
            @close="isConfirmOpen = false"
            @confirm="confirmDelete"
        />
    </div>
</template>
