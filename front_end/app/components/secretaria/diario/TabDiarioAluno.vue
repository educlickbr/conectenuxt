<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import MatrizFilterBar from '@/components/matriz_curricular/MatrizFilterBar.vue'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps<{
    turmaId?: string
}>()

const route = useRoute()
const router = useRouter()
const appStore = useAppStore()
const toast = useToastStore()

// --- State ---
const date = ref(new Date().toISOString().split('T')[0])
const students = ref<any[]>([])
const isLoading = ref(false)
const componente_id = ref<string | null>(null)
const componentes_dia = ref<any[]>([])
const currentTurmaDetails = ref<any>(null)

// Filters State (Restored for MatrizFilterBar)
const filters = ref({
    escola_id: (route.query.id_escola as string) || null,
    ano_etapa_id: (route.query.id_ano_etapa as string) || null,
    turma_id: props.turmaId || (route.query.id_turma as string) || null
})

// Validation State (New Logic)
const diaValido = ref(true)
const motivoInvalido = ref('')
const detalhesInvalido = ref<any>(null)

// Report Modal State (Old Design)
const isReportModalOpen = ref(false)
const selectedStudentForReport = ref<any>(null)
const reportText = ref('')

// --- Computed ---
const activeComponents = computed(() => {
    return componentes_dia.value || []
})

const getDayName = computed(() => {
    if (!date.value) return ''
    const d = new Date(date.value + 'T12:00:00')
    return d.toLocaleDateString('pt-BR', { weekday: 'long' })
})

const getInitials = (name: string) => {
    if (!name) return '?'
    const parts = name.trim().split(/\s+/)
    if (parts.length >= 2) return ((parts[0] || '').charAt(0) + (parts[1] || '').charAt(0)).toUpperCase()
    return name.slice(0, 2).toUpperCase()
}

// --- Fetchers (BFF Integration) ---

const selectComponent = (id: string | null) => {
    componente_id.value = id
}

const validateDay = async () => {
    if (!appStore.company?.empresa_id || !filters.value.turma_id || !date.value) return

    try {
        const response: any = await $fetch(`/api/estrutura_academica/diario_validar_dia`, {
            params: {
                id_empresa: appStore.company.empresa_id,
                id_turma: filters.value.turma_id,
                data: date.value
            }
        })
        
        const result = response.items?.[0]
        
        if (result) {
            diaValido.value = result.valido
            motivoInvalido.value = result.motivo
            detalhesInvalido.value = result.detalhes
            componentes_dia.value = result.componentes || []
        } else {
            diaValido.value = false
            motivoInvalido.value = 'Erro ao validar dia'
            componentes_dia.value = []
        }

        // If current component selection is invalid for the new day, reset to null
        if (componente_id.value && !componentes_dia.value.find((c: any) => c.id === componente_id.value)) {
            componente_id.value = null
        }

    } catch (e) {
        console.error('Error validating day:', e)
        diaValido.value = false
        motivoInvalido.value = 'Erro de conexão'
    }
}

const fetchStudents = async () => {
    if (!filters.value.turma_id || !appStore.company?.empresa_id) return
    
    isLoading.value = true
    try {
        const response: any = await $fetch('/api/estrutura_academica/diario_presenca', {
            params: {
                id_empresa: appStore.company.empresa_id,
                id_turma: filters.value.turma_id,
                data: date.value,
                id_componente: componente_id.value // Can be null
            }
        })

        students.value = response.items || []
        
        if (students.value.length > 0) {
            const first = students.value[0]
            currentTurmaDetails.value = {
                nome_turma: first.turma_nome,
                escola_nome: first.escola_nome,
                turno: first.turno_nome,
                ano_etapa: first.ano_etapa_nome
            }
        }

    } catch (e) {
        console.error('Error fetching students:', e)
        toast.showToast('Erro ao buscar alunos', 'error')
    } finally {
        isLoading.value = false
    }
}

// --- Actions ---

const savePresence = async (student: any, status: string) => {
    if (!diaValido.value) {
        toast.showToast(`Dia inválido: ${motivoInvalido.value}`, 'error')
        return
    }

    // Optimistic Update
    const oldStatus = student.status
    student.status = status

    try {
        const payload = [{
            id: student.id_presenca,
            id_matricula: student.id_matricula,
            id_turma: filters.value.turma_id,
            data: date.value,
            id_componente: componente_id.value,
            status: status,
            observacao: student.observacao
        }]

        await $fetch('/api/estrutura_academica/diario_presenca', {
            method: 'POST',
            body: {
                id_empresa: appStore.company?.empresa_id,
                data: payload
            }
        })
        
        // Background refresh to ensure IDs are synced for subsequent updates
        fetchStudents()

    } catch (e) {
        console.error('Error saving presence:', e)
        student.status = oldStatus // Revert
        toast.showToast('Erro ao salvar presença', 'error')
    }
}

const openReport = (student: any) => {
    selectedStudentForReport.value = student
    reportText.value = student.observacao || ''
    isReportModalOpen.value = true
}

const saveReport = async () => {
    if (!selectedStudentForReport.value) return
    if (!diaValido.value) {
         toast.showToast(`Dia inválido: ${motivoInvalido.value}`, 'error')
         return
    }
    
    const student = selectedStudentForReport.value
    // Optimistic
    const oldObs = student.observacao
    student.observacao = reportText.value
    
    try {
        const payload = [{
            id: student.id_presenca,
            id_matricula: student.id_matricula,
            id_turma: filters.value.turma_id,
            data: date.value,
            id_componente: componente_id.value,
            status: student.status || 'P',
            observacao: reportText.value
        }]

        await $fetch('/api/estrutura_academica/diario_presenca', {
            method: 'POST',
            body: {
                id_empresa: appStore.company?.empresa_id,
                data: payload
            }
        })
        
        isReportModalOpen.value = false
        toast.showToast('Observação salva', 'success')
        fetchStudents()
        
    } catch (e) {
        student.observacao = oldObs
        toast.showToast('Erro ao salvar observação', 'error')
    }
}

// --- Watchers ---

// Watch filters.turma_id to fetch/validate
watch(() => filters.value.turma_id, async (newVal) => {
    if (newVal) {
        // Sync URL if needed
        const query = { ...route.query, id_turma: newVal, id_escola: filters.value.escola_id, id_ano_etapa: filters.value.ano_etapa_id }
        router.replace({ query })
        
        await validateDay()
        await fetchStudents()
    }
})

watch(date, async () => {
    await validateDay()
    await fetchStudents()
})

watch(componente_id, fetchStudents)

onMounted(async () => {
    // If props provided (e.g. from modal), sync to filters
    if (props.turmaId) {
        filters.value.turma_id = props.turmaId
    }
    
    if (filters.value.turma_id) {
        await validateDay()
        await fetchStudents()
    }
})
</script>

<template>
    <div class="p-6 md:p-8 min-h-[500px]">
        
        <!-- Header Controls -->
        <div class="flex flex-col gap-6 mb-8">
            <!-- Filter Bar -->
            <MatrizFilterBar v-if="!props.turmaId" v-model="filters" />
            
            <div class="flex flex-col md:flex-row gap-6 items-start md:items-center justify-between border-b pb-6 border-secondary/10">
                <!-- Date Picker -->
                <div class="flex flex-col">
                    <div class="flex items-center gap-2 mb-1.5 pl-1">
                        <span class="text-xs font-bold text-secondary uppercase tracking-wider">Data do Diário</span>
                        <span v-if="date" class="text-[10px] font-bold text-primary bg-primary/10 border border-primary/20 px-2 py-0.5 rounded-full uppercase leading-none">
                            {{ getDayName }}
                        </span>
                    </div>
                    <ManagerField 
                        type="date" 
                        :model-value="date ?? undefined"
                        @update:modelValue="(v: any) => date = v"
                        class="min-w-[160px]"
                    />
                </div>

                <!-- Component Slider -->
                <div class="flex-1 w-full md:w-auto overflow-x-auto pb-2 md:pb-0" v-if="filters.turma_id">
                    <div class="flex items-center gap-2">
                        <!-- Geral Option -->
                        <button 
                            @click="selectComponent(null)"
                            class="px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap border"
                            :class="componente_id === null 
                                ? 'bg-primary text-white border-primary shadow-lg shadow-primary/20' 
                                : 'bg-surface text-secondary border-div-15 hover:border-primary/50'"
                        >
                            Dia Inteiro
                        </button>

                        <div class="h-6 w-px bg-div-15 mx-2"></div>

                        <!-- Scheduled Components -->
                        <button 
                            v-for="comp in activeComponents" 
                            :key="comp.id"
                            @click="selectComponent(comp.id)"
                            class="px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap border flex items-center gap-2"
                            :class="componente_id === comp.id 
                                ? 'bg-white text-primary border-primary ring-2 ring-primary/20' 
                                : 'bg-surface text-secondary border-div-15 hover:border-primary/50'"
                            :style="componente_id === comp.id ? { borderColor: comp.cor } : {}"
                        >
                            <span class="w-2 h-2 rounded-full" :style="{ backgroundColor: comp.cor || '#ccc' }"></span>
                            {{ comp.nome }} ({{ comp.aula }}ª)
                        </button>
                        
                        <div v-if="activeComponents.length === 0" class="text-xs text-secondary italic px-2">
                            Sem aulas na Matriz hoje.
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Global Validation/Action Bar REMOVED HERE -->
        </div>

        <!-- Warning No Turma -->
        <div v-if="!filters.turma_id" class="py-12 text-center border-2 border-dashed border-secondary/10 rounded-xl bg-surface/50">
            <p class="text-secondary font-medium">Selecione uma turma acima para iniciar a chamada.</p>
        </div>

        <!-- Warning Invalid Day -->
        <div v-else-if="!diaValido" class="py-16 flex flex-col items-center justify-center text-center border-2 border-dashed border-warning/30 rounded-xl bg-warning/5 gap-6">
            <div class="w-20 h-20 rounded-full bg-warning/10 flex items-center justify-center text-warning mb-2 animate-in fade-in zoom-in-75 duration-300">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
            </div>
            <div class="max-w-md">
                <h3 class="font-bold text-2xl text-text mb-2">{{ motivoInvalido === 'feriado' ? 'Feriado' : motivoInvalido === 'evento' ? 'Evento Escolar' : 'Dia não Letivo' }}</h3>
                <p class="text-base text-secondary/80 leading-relaxed bg-surface px-4 py-2 rounded-lg border border-div-15 inline-block">
                    {{ detalhesInvalido?.mensagem || 'Não é possível registrar frequência neste dia.' }}
                    <span v-if="detalhesInvalido?.nome" class="block font-bold mt-1 text-primary">{{ detalhesInvalido.nome }}</span>
                </p>
            </div>
        </div>

        <!-- Student List (Grid Layout from Old Design) -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            
             <div v-if="isLoading" class="col-span-full py-12 flex justify-center">
                <div class="animate-pulse flex flex-col items-center gap-3">
                    <div class="h-8 w-8 rounded-full border-2 border-primary border-t-transparent animate-spin"></div>
                    <span class="text-sm font-medium text-secondary">Carregando alunos...</span>
                </div>
             </div>
             
             <div v-else-if="students.length === 0" class="col-span-full py-12 text-center text-secondary border border-dashed border-div-15 rounded-xl">
                 Nenhum aluno encontrado nesta turma.
             </div>

             <div v-else v-for="student in students" :key="student.id_matricula" 
                class="group bg-surface border border-div-15 rounded-xl overflow-hidden hover:shadow-xl hover:-translate-y-1 transition-all duration-300 relative flex flex-col"
            >
                <!-- Card Header -->
                <div class="p-4 flex items-center gap-4 relative bg-gradient-to-br from-white to-background dark:from-surface dark:to-surface-hover/50"> 
                    <!-- Status Badge -->
                    <div class="absolute top-4 right-4 text-[10px] font-bold px-2 py-1 rounded-md border shadow-sm backdrop-blur-sm"
                        :class="[
                            student.status === 'P' ? 'bg-success/10 text-success border-success/20' :
                            student.status === 'F' ? 'bg-danger/10 text-danger border-danger/20' :
                            student.status === 'A' ? 'bg-secondary/10 text-secondary border-secondary/20' :
                            'bg-surface text-secondary border-div-15'
                        ]"
                    >
                        {{ student.status === 'P' ? 'PRESENTE' : student.status === 'F' ? 'FALTA' : student.status === 'A' ? 'ABONADA' : 'AGUARDANDO' }}
                    </div>

                    <!-- Avatar -->
                    <div 
                        class="w-12 h-12 rounded-xl flex items-center justify-center text-base font-bold shrink-0 shadow-inner transition-colors"
                        :class="[
                            student.status === 'P' ? 'bg-success/20 text-success' : 
                            student.status === 'F' ? 'bg-danger/20 text-danger' : 
                            student.status === 'A' ? 'bg-secondary/20 text-secondary' :
                            'bg-div-15 text-secondary/70'
                        ]"
                    >
                        {{ getInitials(student.aluno_nome) }}
                    </div>
                    
                    <!-- Info -->
                    <div class="min-w-0 flex-1 pr-20">
                        <h4 class="font-bold text-text text-sm truncate leading-snug mb-1" :title="student.aluno_nome">
                            {{ student.aluno_nome }}
                        </h4>
                        <div class="text-[10px] text-secondary flex flex-wrap gap-x-2 leading-none opacity-80">
                             <span v-if="currentTurmaDetails">{{ currentTurmaDetails.nome_turma }}</span>
                             <span v-if="componente_id" class="text-primary font-bold">• {{ activeComponents.find(c => c.id === componente_id)?.nome }}</span>
                             <span v-else>• Dia Inteiro</span>
                        </div>
                    </div>
                </div>

                <!-- Controls Body -->
                <div class="px-4 pb-4">
                    <div class="flex items-center gap-3">
                        <button 
                            @click="savePresence(student, 'P')" 
                            class="flex-1 h-9 rounded-lg text-xs font-bold transition-all flex items-center justify-center gap-1.5 relative overflow-hidden border"
                            :class="[
                                student.status === 'P' 
                                ? '!bg-success !text-white !border-success ring-1 ring-success shadow-sm' 
                                : 'bg-success/5 text-success border-success/30 hover:bg-success hover:text-white'
                            ]"
                        >
                            P
                        </button>
                        <button 
                            @click="savePresence(student, 'F')" 
                            class="flex-1 h-9 rounded-lg text-xs font-bold transition-all flex items-center justify-center gap-1.5 relative overflow-hidden border"
                            :class="[
                                student.status === 'F'
                                ? '!bg-danger !text-white !border-danger ring-1 ring-danger shadow-sm' 
                                : 'bg-danger/5 text-danger border-danger/30 hover:bg-danger hover:text-white'
                            ]"
                        >
                            F
                        </button>
                        <button 
                            @click="savePresence(student, 'A')" 
                            class="flex-1 h-9 rounded-lg text-xs font-bold transition-all flex items-center justify-center gap-1.5 relative overflow-hidden border"
                             :class="[
                                student.status === 'A'
                                ? '!bg-secondary !text-white !border-secondary ring-1 ring-secondary shadow-sm' 
                                : 'bg-secondary/5 text-secondary border-secondary/30 hover:bg-secondary hover:text-white'
                            ]"
                        >
                            A
                        </button>
                    </div>
                </div>

                <!-- Footer -->
                <button 
                    @click="openReport(student)"
                    class="w-full py-3 text-xs font-semibol transition-colors flex items-center justify-center gap-2 border-t border-div-15 bg-surface hover:bg-surface-hover group-hover:border-primary/10"
                    :class="student.observacao ? 'text-primary' : 'text-secondary/70'"
                >
                    <span v-if="student.observacao" class="relative flex h-2 w-2">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-2 w-2 bg-primary"></span>
                    </span>
                    <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    {{ student.observacao ? 'Ver Observação' : 'Adicionar Observação' }}
                </button>
            </div>
        </div>

        <!-- Report Modal (From Old Design) -->
        <div v-if="isReportModalOpen" class="fixed inset-0 z-[200] flex items-center justify-center p-4">
             <div class="absolute inset-0 bg-black/60 backdrop-blur-sm transition-opacity" @click="isReportModalOpen = false"></div>
             <div class="relative bg-surface rounded-xl shadow-2xl p-6 w-full max-w-lg border border-div-15 scale-100 animate-in fade-in zoom-in-95 duration-200">
                 
                 <div class="flex items-center justify-between mb-6">
                    <div>
                        <h3 class="font-bold text-lg text-text">Diário de Classe</h3>
                        <p class="text-sm text-secondary">{{ selectedStudentForReport?.aluno_nome }}</p>
                    </div>
                    <button @click="isReportModalOpen = false" class="text-secondary hover:text-text">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                 </div>
                 
                 <label class="block text-xs font-bold text-secondary uppercase tracking-wider mb-2">Observações / Ocorrências</label>
                 <textarea 
                    v-model="reportText"
                    rows="5"
                    class="w-full bg-input-bg border border-input-border rounded-lg p-3 text-sm text-text outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all mb-6 resize-none"
                    placeholder="Descreva detalhes sobre a presença ou comportamento do aluno nesta aula..."
                ></textarea>

                <div class="flex justify-end gap-3 pt-4 border-t border-div-15">
                    <button @click="isReportModalOpen = false" class="px-4 py-2 text-sm font-bold text-secondary hover:text-text transition-colors">Cancelar</button>
                    <button @click="saveReport" class="px-6 py-2 bg-primary hover:bg-primary-hover text-white text-sm font-bold rounded-lg shadow-lg shadow-primary/20 transition-all transform active:scale-95">
                        Salvar Anotação
                    </button>
                </div>
             </div>
        </div>

    </div>
</template>
