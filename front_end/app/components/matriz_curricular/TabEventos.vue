<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ModalGerenciarEvento from '@/components/matriz_curricular/ModalGerenciarEvento.vue'
import ModalConfirmacao from '@/components/ModalConfirmacao.vue'

const appStore = useAppStore()
const toast = useToastStore()

// State
const events = ref([])
const isLoading = ref(false)
const expandedMonths = ref({}) // { '2025-01': true }
const currentYear = ref(new Date().getFullYear())

// Modals
const isModalOpen = ref(false)
const selectedEvent = ref(null)
const isConfirmOpen = ref(false)
const eventToDelete = ref(null)
const isDeleting = ref(false)

// Fetch Data
const fetchEvents = async () => {
    isLoading.value = true
    try {
        const { items } = await $fetch('/api/estrutura_academica/eventos', {
            query: {
                id_empresa: appStore.company.empresa_id,
                limite: 1000 // Get all for timeline
            }
        })
        events.value = items || []
        
        // Auto-expand current month IF no months are expanded yet
        if (Object.keys(expandedMonths.value).length === 0) {
             const currentMonthKey = new Date().toISOString().slice(0, 7) // YYYY-MM
             expandedMonths.value[currentMonthKey] = true
        }
       
    } catch (err) {
        console.error('Erro ao buscar eventos:', err)
        toast.showToast('Erro ao carregar eventos.', 'error')
    } finally {
        isLoading.value = false
    }
}

onMounted(() => {
    fetchEvents()
})

// Generate all months for the current year context
// If we have events spanning multiple years, we might want to handle that.
// For now, let's focus on the year of the events or current year.
// Strategy: Find min/max year from events, or default to current year.
// Simple approach: Show current year and next year? Or just a dynamic list of months covering the events range + gaps.
// User Request: "podemos colocar todos os meses já isso nos ajuda a criar qualquer evento em qualquer mês"

// Generate Timeline Months (Full Year)
const timelineMonths = computed(() => {
    let minYear = currentYear.value
    let maxYear = currentYear.value

    // Flatten logic: Expand multi-day events into single-day entries
    const allEntries = []

    events.value.forEach(evt => {
        const start = new Date(evt.data_inicio)
        const end = new Date(evt.data_fim)
        
        let curr = new Date(start)
        let isFirstDay = true
        
        while (curr <= end) {
             const entryDate = curr.toISOString()
             
             allEntries.push({
                 ...evt,
                 uniqueKey: `${evt.id}_${entryDate}`,
                 displayDate: entryDate,
                 isFirstDay: isFirstDay,
                 originalStart: evt.data_inicio
             })
             
             curr.setDate(curr.getDate() + 1)
             isFirstDay = false
        }
    })

    if (allEntries.length > 0) {
        const years = allEntries.map(e => new Date(e.displayDate).getUTCFullYear())
        minYear = Math.min(minYear, ...years)
        maxYear = Math.max(maxYear, ...years)
    }

    const months = []
    
    for (let y = minYear; y <= maxYear; y++) {
        for (let m = 0; m < 12; m++) {
            const date = new Date(Date.UTC(y, m, 1))
            const key = date.toISOString().slice(0, 7) // YYYY-MM
            
            // Filter entries for this month
            const monthEntries = allEntries.filter(e => e.displayDate.startsWith(key))
            monthEntries.sort((a, b) => new Date(a.displayDate) - new Date(b.displayDate))

            months.push({
                key,
                label: date.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric', timeZone: 'UTC' }),
                monthName: date.toLocaleDateString('pt-BR', { month: 'long', timeZone: 'UTC' }),
                year: y,
                events: monthEntries, // Changed from 'eventos' to 'events' to match existing ref
                isPast: new Date() > new Date(y, m + 1, 0),
                isCurrent: key === new Date().toISOString().slice(0, 7)
            })
        }
    }
    
    return months
})

// Actions
const toggleMonth = (key) => {
    // Toggle capability
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
    selectedEvent.value = {
        data_inicio: `${monthKey}-01` // Default to 1st of that month
    }
    isModalOpen.value = true
}

const handleEdit = (evt) => {
    // When editing, pass the original event, not the flattened entry
    const originalEvent = events.value.find(e => e.id === evt.id)
    selectedEvent.value = originalEvent || evt
    isModalOpen.value = true
}

const handleDelete = (evt) => {
    // When deleting, pass the original event, not the flattened entry
    const originalEvent = events.value.find(e => e.id === evt.id)
    eventToDelete.value = originalEvent || evt
    isConfirmOpen.value = true
}

const confirmDelete = async () => {
    if (!eventToDelete.value) return
    isDeleting.value = true
    try {
        const { success } = await $fetch('/api/estrutura_academica/eventos', {
            method: 'DELETE',
            body: {
                id: eventToDelete.value.id,
                id_empresa: appStore.company.empresa_id
            }
        })
        if (success) {
            toast.showToast('Evento excluído.')
            await fetchEvents()
            isConfirmOpen.value = false
        }
    } catch (err) {
        toast.showToast('Erro ao excluir evento.', 'error')
    } finally {
        isDeleting.value = false
    }
}

const handleSuccess = () => {
    fetchEvents()
}

// Helpers
const getDay = (dateStr) => {
    // Force specific timezone interpretation
    const date = new Date(dateStr)
    return new Intl.DateTimeFormat('pt-BR', { day: 'numeric', timeZone: 'America/Sao_Paulo' }).format(date)
}
const getWeekDay = (dateStr) => {
    const date = new Date(dateStr)
    return new Intl.DateTimeFormat('pt-BR', { weekday: 'short', timeZone: 'America/Sao_Paulo' }).format(date).toUpperCase().slice(0, 3)
}
</script>

<template>
    <div class="p-6 md:p-8 min-h-[500px]">
        
        <div v-if="isLoading && events.length === 0" class="flex justify-center py-12">
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
                        // parseInt(month.key.split('-')[1]) % 2 !== 0 ? 'items-start' : 'items-end',
                        { 'opacity-60 hover:opacity-100': month.events.length === 0 && !expandedMonths[month.key] && !month.isCurrent }
                    ]"
                >
                    <!-- Timeline Node (Circle) -->
                    <div 
                        class="absolute left-[-4.5px] md:left-1/2 md:-ml-[5px] top-6 w-[10px] h-[10px] rounded-full transition-all duration-300 z-20 shadow-[0_0_10px_rgba(var(--color-primary),0.2)]"
                        :class="[
                            month.events.length > 0 ? 'bg-primary border-primary' : 'bg-background border-secondary/30',
                            month.isCurrent ? 'scale-125 border-primary bg-primary shadow-[0_0_15px_rgba(var(--color-primary),0.8)]' : 'border-2'
                        ]"
                    ></div>

                    <!-- Month Header Card -->
                    <div 
                        class="w-full md:w-[calc(50%-2rem)] mb-2 md:mb-0 transition-all duration-300 select-none relative"
                         :class="[
                            parseInt(month.key.split('-')[1]) % 2 !== 0 ? 'md:mr-auto text-left' : 'md:ml-auto text-left' // Both internal text left, but container moves
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
                                    v-if="month.events.length > 0"
                                    class="px-2 py-0.5 rounded text-[10px] font-bold"
                                    :class="month.isCurrent ? 'bg-primary text-white' : 'bg-div-30 text-secondary'"
                                >
                                    {{ month.events.length }}
                                </div>
                            </div>
                            
                            <!-- Actions -->
                            <div class="flex items-center gap-3">
                                <!-- Add Button -->
                                <button 
                                    @click.stop="handleAddInMonth(month.key)"
                                    class="w-8 h-8 flex items-center justify-center rounded-full bg-div-30 text-secondary hover:bg-primary hover:text-white hover:scale-110 transition-all"
                                    title="Adicionar Evento"
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

                    <!-- Events List (Collapsible) -->
                    <div 
                        v-show="expandedMonths[month.key]"
                        class="flex flex-col gap-3 mt-2 transition-all w-full md:w-[calc(50%-2rem)]"
                         :class="[
                            // Keep content aligned with header? Or opposite?
                            // Usually children follow parent column.
                            parseInt(month.key.split('-')[1]) % 2 !== 0 ? 'md:mr-auto' : 'md:ml-auto'
                        ]"
                    >
                         <!-- If empty and expanded, show hint -->
                        <div v-if="month.events.length === 0" class="w-full p-4 opacity-50 text-xs italic text-secondary text-center md:text-left">
                            (Sem eventos)
                        </div>

                        <div 
                            v-for="(evt, idx) in month.eventos" 
                            :key="evt.uniqueKey"
                            class="relative w-full transition-all hover:-translate-y-0.5"
                        >   
                            <!-- Connection Line (Desktop) - Logic reversed since content is inside the column -->
                            <!-- If Month is LEFT (Even), line goes RIGHT to center -->
                            <!-- If Month is RIGHT (Odd), line goes LEFT to center -->
                            <!-- Center is relative. We are inside a 50% width container. -->
                            
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
                                        <span class="text-[9px] font-black uppercase text-secondary tracking-widest">{{ getWeekDay(evt.displayDate) }}</span>
                                        <span class="text-lg font-bold text-primary leading-none">{{ getDay(evt.displayDate) }}</span>
                                    </div>

                                    <!-- Content -->
                                    <div class="flex-1 min-w-0 flex flex-col justify-center">
                                        <h4 class="font-bold text-sm truncate" :title="evt.nome_evento">{{ evt.nome_evento }}</h4>
                                        <div class="text-[10px] text-secondary flex items-center gap-2 mt-0.5">
                                            <span 
                                                class="px-1.5 py-0.5 rounded-[3px] bg-div-30 uppercase tracking-wider font-bold text-[8px]"
                                            >
                                                {{ evt.escopo === 'Ano_Etapa' ? 'Ano/Etapa' : 'Rede' }}
                                            </span>
                                            
                                            <!-- Show 'Continuação' if not first day -->
                                            <span v-if="!evt.isFirstDay" class="italic opacity-70">
                                                (Continuação)
                                            </span>
                                            
                                            <!-- Overlap Flag -->
                                            <span 
                                                v-if="evt.matriz_sobrepor" 
                                                class="flex items-center gap-1 text-[8px] bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 px-1.5 py-0.5 rounded font-bold uppercase tracking-wider"
                                                title="Este evento sobrepõe a matriz curricular"
                                            >
                                                <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                                Sobrepõe Aula
                                            </span>
                                        </div>
                                    </div>

                                    <!-- Actions (Hover Only) - Show only on First Day -->
                                    <div v-if="evt.isFirstDay" class="flex items-center gap-1 opacity-100 md:opacity-0 group-hover/card:opacity-100 transition-opacity">
                                        <button @click="handleEdit(evt)" class="p-1.5 hover:bg-div-30 rounded text-secondary hover:text-primary transition-colors" title="Editar">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                        </button>
                                         <button @click="handleDelete(evt)" class="p-1.5 hover:bg-red-500/10 rounded text-secondary hover:text-red-500 transition-colors" title="Excluir">
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
        <ModalGerenciarEvento
            v-if="isModalOpen"
            :is-open="isModalOpen"
            :initial-data="selectedEvent"
            @close="isModalOpen = false"
            @success="handleSuccess"
        />

        <ModalConfirmacao
            :is-open="isConfirmOpen"
            title="Excluir Evento?"
            :message="`Tem certeza que deseja excluir <b>${eventToDelete?.nome_evento}</b>?`"
            confirm-text="Sim, excluir"
            :is-loading="isDeleting"
            @close="isConfirmOpen = false"
            @confirm="confirmDelete"
        />
    </div>
</template>
