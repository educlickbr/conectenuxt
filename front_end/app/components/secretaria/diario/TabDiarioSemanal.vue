<script setup lang="ts">
import { ref, watch, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAppStore } from '@/stores/app'
import MatrizFilterBar from '@/components/matriz_curricular/MatrizFilterBar.vue'
import ManagerField from '@/components/ManagerField.vue'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()

// Filters
const filters = ref({
    escola_id: (route.query.id_escola as string) || null,
    ano_etapa_id: (route.query.id_ano_etapa as string) || null,
    turma_id: (route.query.id_turma as string) || null
})

// Weekly View State
const studentId = ref<string | null>(null)
const selectedDate = ref(new Date().toISOString().split('T')[0]) // Default today

// Data
const students = ref<any[]>([])
const weeklyData = ref<any[]>([])
const matrixData = ref<any[]>([])
const matrixMap = ref<Map<string, Set<number>>>(new Map()) // ComponentID -> Set of ISODOW (1-7)

const isLoadingStudents = ref(false)
const isLoadingGrid = ref(false)

// Sync filters to URL
watch(filters, (newVal) => {
    router.replace({
        query: {
            ...route.query,
            id_escola: newVal.escola_id || undefined,
            id_ano_etapa: newVal.ano_etapa_id || undefined,
            id_turma: newVal.turma_id || undefined
        }
    })
}, { deep: true })

// Computed Week Range
const weekDays = computed(() => {
    if (!selectedDate.value) return []
    const d = new Date(selectedDate.value + 'T12:00:00')
    const day = d.getDay() // 0 (Sun) to 6 (Sat)
    const diff = d.getDate() - day + (day === 0 ? -6 : 1) // Adjust when day is Sunday
    const monday = new Date(d.setDate(diff))
    
    const days = []
    for (let i = 0; i < 5; i++) { // Mon-Fri
        const current = new Date(monday)
        current.setDate(monday.getDate() + i)
        days.push({
            date: current.toISOString().split('T')[0],
            label: current.toLocaleDateString('pt-BR', { weekday: 'short' }).toUpperCase().slice(0, 3), // SEG, TER...
            dayNumber: current.getDate(),
            isoDow: i + 1 // 1=Monday, 5=Friday
        })
    }
    return days
})

const weekRange = computed(() => {
    if (!weekDays.value || weekDays.value.length === 0) return { start: '', end: '' }
    return {
        start: weekDays.value[0]?.date || '',
        end: weekDays.value[4]?.date || ''
    }
})

// Fetchers
const fetchStudents = async () => {
    if (!filters.value.turma_id) {
        students.value = []
        studentId.value = null
        return
    }

    isLoadingStudents.value = true
    try {
        const data: any = await $fetch('/api/secretaria/alunos_turma', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                id_turma: filters.value.turma_id
            }
        })
        
        students.value = data?.items || []
        
        // Auto-select first student if none selected
        if (students.value.length > 0 && !studentId.value) {
            studentId.value = students.value[0].id_matricula
        } else if (students.value.length === 0) {
            studentId.value = null
        }
        
    } catch (e) {
        console.error('Error fetching students:', e)
    } finally {
        isLoadingStudents.value = false
    }
}

const fetchMatrix = async () => {
    if (!filters.value.turma_id || !appStore.company?.empresa_id || !filters.value.ano_etapa_id) return

    try {
        const response: any = await $fetch('/api/estrutura_academica/matriz_curricular_merged', {
            params: {
                id_empresa: appStore.company.empresa_id,
                id_turma: filters.value.turma_id,
                id_ano_etapa: filters.value.ano_etapa_id
            }
        })

        const items = response?.items || []
        matrixData.value = items
        
        // Build Map: Component ID -> Set of Day of Week (1-5)
        const map = new Map<string, Set<number>>()
        items.forEach((m: any) => {
            if (!map.has(m.id_componente)) {
                map.set(m.id_componente, new Set())
            }
            map.get(m.id_componente)?.add(m.dia_semana) // dia_semana is 1-based (1=Mon) in existing logic
        })
        matrixMap.value = map
        
    } catch (e) {
        console.error('Error fetching matrix:', e)
    }
}

const fetchWeeklyData = async () => {
    if (!filters.value.turma_id || !studentId.value || !weekRange.value.start) {
        weeklyData.value = []
        return
    }

    isLoadingGrid.value = true
    try {
        // Parallel fetch of Matrix (if needed again or if not loaded) and Presence Data
        if (matrixData.value.length === 0) {
            await fetchMatrix()
        }

        const data: any = await $fetch('/api/secretaria/diario_semanal', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                id_turma: filters.value.turma_id,
                id_matricula: studentId.value,
                data_inicio: weekRange.value.start,
                data_fim: weekRange.value.end
            }
        })
        
        // Process raw data into a grid-friendly structure
        const rawItems = data?.items || []
        const grouped = new Map()

        // 1. Add components from Matrix
        matrixData.value.forEach(m => {
            if (!grouped.has(m.id_componente)) {
               grouped.set(m.id_componente, {
                   id: m.id_componente,
                   nome: m.componente_nome,
                   cor: m.componente_cor,
                   days: {} // Date string -> Status
               }) 
            }
        })

        // 2. Merge Presence Data
        rawItems.forEach((item: any) => {
            if (!grouped.has(item.id_componente)) {
                grouped.set(item.id_componente, {
                    id: item.id_componente,
                    nome: item.componente_nome,
                    cor: item.componente_cor,
                    days: {} 
                })
            }
            if (item.data) {
                grouped.get(item.id_componente).days[item.data] = item.status?.trim()
            }
        })
        
        // Convert to array and sort by name
        weeklyData.value = Array.from(grouped.values()).sort((a:any, b:any) => a.nome.localeCompare(b.nome))

    } catch (e) {
        console.error('Error fetching weekly data:', e)
    } finally {
        isLoadingGrid.value = false
    }
}

// Watchers
watch(() => filters.value.turma_id, async () => {
    await fetchStudents()
    await fetchMatrix() // Also fetch matrix when class changes
})

watch([studentId, selectedDate], () => {
    fetchWeeklyData()
})

watch(students, () => {
    if (studentId.value) fetchWeeklyData()
})

onMounted(async () => {
    if (filters.value.turma_id) {
        await fetchStudents()
        await fetchMatrix()
    }
})

// Helpers
const getDayStatus = (comp: any, date: string | undefined): string => {
    if (!date) return ''
    return ((comp.days as Record<string, string>)[date] || '')
}

const isClassScheduled = (comp: any, isoDow: number): boolean => {
    return matrixMap.value.get(comp.id)?.has(isoDow) || false
}

const getStatusClass = (status: string) => {
    switch (status) {
        case 'P': return 'bg-success/10 text-success border-success/20'
        case 'F': return 'bg-danger/10 text-danger border-danger/20'
        case 'A': return 'bg-secondary/10 text-secondary border-secondary/20'
        case 'J': return 'bg-warning/10 text-warning border-warning/20'
        default: return 'bg-surface text-secondary border-div-15'
    }
}
</script>

<template>
    <div class="p-6 md:p-8 min-h-[500px]">
        
        <!-- Filters -->
        <MatrizFilterBar v-model="filters" class="mb-8" />
        
        <div v-if="!filters.turma_id" class="py-12 text-center border-2 border-dashed border-secondary/10 rounded bg-surface/50">
            <p class="text-secondary font-medium">Selecione uma turma acima para visualizar o diário semanal.</p>
        </div>

        <div v-else>
            <!-- Controls -->
            <div class="flex flex-col md:flex-row gap-6 mb-8 items-end">
                <!-- Student Selector -->
                <div class="w-full md:w-1/3">
                    <label class="block text-xs font-bold text-secondary uppercase tracking-wider mb-2 pl-1">Estudante</label>
                    <div class="relative">
                        <select 
                            v-model="studentId"
                            class="w-full h-11 bg-input-bg border border-input-border rounded px-3 text-sm text-text outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all appearance-none cursor-pointer"
                            :disabled="isLoadingStudents || students.length === 0"
                        >
                            <option value="" disabled selected>Selecione um estudante</option>
                            <option v-for="student in students" :key="student.id_matricula" :value="student.id_matricula">
                                {{ student.aluno_nome }}
                            </option>
                        </select>
                        <div class="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none text-secondary">
                             <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>
                        </div>
                    </div>
                </div>

                <!-- Week Picker (using Date Picker as anchor) -->
                <div class="w-full md:w-auto">
                    <ManagerField 
                        type="date" 
                        label="Semana de Ref."
                        :model-value="selectedDate ?? undefined"
                        @update:modelValue="(v: any) => selectedDate = v"
                        class="min-w-[160px]"
                    />
                </div>
            </div>

            <!-- Grid -->
            <div v-if="isLoadingGrid" class="py-12 flex justify-center">
                 <div class="animate-pulse flex flex-col items-center gap-3">
                    <div class="h-8 w-8 rounded-full border-2 border-primary border-t-transparent animate-spin"></div>
                    <span class="text-sm font-medium text-secondary">Carregando dados da semana...</span>
                </div>
            </div>

            <div v-else-if="weeklyData.length === 0" class="py-12 text-center text-secondary border border-dashed border-div-15 rounded bg-surface/50">
                Selecione um estudante para visualizar o histórico.
            </div>

            <div v-else class="overflow-x-auto rounded border border-div-15 bg-surface shadow-sm">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="bg-surface/50 border-b border-div-15">
                            <th class="p-4 text-left font-bold text-secondary uppercase tracking-wider w-1/4">Componente</th>
                            <th v-for="day in weekDays" :key="day.date" class="p-4 text-center border-l border-div-15/50 min-w-[80px]">
                                <div class="flex flex-col items-center">
                                    <span class="text-[10px] font-bold text-secondary/70">{{ day.label }}</span>
                                    <span class="text-lg font-bold text-text leading-none">{{ day.dayNumber }}</span>
                                </div>
                            </th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-div-15">
                        <tr v-for="comp in weeklyData" :key="comp.id" class="hover:bg-surface-hover/50 transition-colors group">
                            <!-- Component Name -->
                            <td class="p-4 border-r border-div-15/50">
                                <div class="flex items-center gap-3">
                                    <div class="w-1.5 h-8 rounded-full" :style="{ backgroundColor: comp.cor || '#ccc' }"></div>
                                    <span class="font-semibold text-text group-hover:text-primary transition-colors">{{ comp.nome }}</span>
                                </div>
                            </td>
                            
                            <!-- Days Cells -->
                            <td v-for="day in weekDays" :key="day.date" class="p-2 text-center border-l border-div-15/50">
                                <!-- Condition 1: Presence Exists -->
                                <div v-if="getDayStatus(comp, day.date)" 
                                    class="w-10 h-10 mx-auto flex items-center justify-center rounded font-bold text-sm shadow-sm border"
                                    :class="getStatusClass(getDayStatus(comp, day.date))"
                                >
                                    {{ getDayStatus(comp, day.date) }}
                                </div>
                                
                                <!-- Condition 2: No Presence, But Scheduled (Pending) -->
                                <div v-else-if="isClassScheduled(comp, day.isoDow)" 
                                    class="w-10 h-10 mx-auto rounded border-2 border-dashed border-secondary/10 bg-surface/50 relative group/cell"
                                    title="Aula prevista na matriz (pendente)"
                                >
                                    <!-- Empty Box -->
                                </div>

                                <!-- Condition 3: Not Scheduled (Blocked) -->
                                <div v-else class="w-10 h-10 mx-auto flex items-center justify-center rounded text-div-15/30 select-none text-[10px] font-bold tracking-tighter">
                                    S/A
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            
            <div class="mt-4 flex gap-4 text-xs text-secondary justify-end">
                <div class="flex items-center gap-1.5"><div class="w-3 h-3 rounded bg-success/10 border border-success/20"></div> P = Presente</div>
                <div class="flex items-center gap-1.5"><div class="w-3 h-3 rounded bg-danger/10 border border-danger/20"></div> F = Falta</div>
                <div class="flex items-center gap-1.5"><div class="w-3 h-3 rounded bg-secondary/10 border border-secondary/20"></div> A = Abonada</div>
                <div class="flex items-center gap-1.5"><div class="w-3 h-3 rounded border-2 border-dashed border-secondary/30"></div> Pendente</div>
                <div class="flex items-center gap-1.5"><span class="text-div-15/50 font-bold text-[10px]">S/A</span> Sem Aula</div>
            </div>

        </div>
    </div>
</template>
