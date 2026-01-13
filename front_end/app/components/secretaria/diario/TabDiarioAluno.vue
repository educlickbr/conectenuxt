<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import MatrizFilterBar from '@/components/matriz_curricular/MatrizFilterBar.vue'
import ManagerField from '@/components/ManagerField.vue'

const appStore = useAppStore()
const toast = useToastStore()

const today = new Date().toISOString().split('T')[0]

// Filters
const filters = ref({
    escola_id: null,
    ano_etapa_id: null,
    turma_id: null
})
const date = ref(today)
const componente_id = ref<string | null>(null)

// Data
const isLoading = ref(false)
const students = ref<any[]>([])
const componentes = ref<any[]>([])
const turmas = ref<any[]>([]) // To get details like Name/Shift for the card
const currentTurmaDetails = ref<any>(null)

// Modal for Report
const isReportModalOpen = ref(false)
const selectedStudentForReport = ref<any>(null)
const reportText = ref('')

// --- Fetchers ---

const fetchComponentes = async () => {
    try {
        const client = useSupabaseClient()
        const { data, error } = await client
            .from('componente') // Singular, based on schema references
            .select('uuid, nome') // uuid is PK
            .eq('id_empresa', appStore.company?.empresa_id)
            .order('nome')
        
        if (error) throw error
        componentes.value = data || []
    } catch (e) {
        console.error('Error fetching componentes:', e)
    }
}

const fetchTurmaDetails = async () => {
    // Deprecated: Context is now returned by the main RPC
}

const fetchStudents = async () => {
    if (!filters.value.turma_id || !date.value) {
        students.value = []
        return
    }

    isLoading.value = true
    try {
        const client = useSupabaseClient()
        
        // Use the new simplified RPC that returns everything
        const { data, error } = await (client as any)
            .rpc('diario_presenca_get_por_turma', {
                p_id_empresa: appStore.company?.empresa_id,
                p_id_turma: filters.value.turma_id,
                p_data: date.value,
                p_id_componente: componente_id.value
            })

        if (error) throw error

        students.value = data || []
        
        // Update context if we have at least one student (the RPC returns context columns)
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
        // toast.showToast('Erro ao carregar alunos.', 'error')
    } finally {
        isLoading.value = false
    }
}

// Watchers
watch(() => filters.value.turma_id, fetchStudents)
watch(date, fetchStudents)
watch(componente_id, fetchStudents)

onMounted(() => {
    fetchComponentes()
})


// --- Actions ---

const setPresence = async (student: any, status: 'P' | 'F' | 'A') => {
    // Current State
    const currentPresente = student.presente
    const currentObs = student.observacao
    
    // Determine New State
    let newPresente: boolean | null = false
    let newObs: string | null = null

    if (status === 'P') {
        // Toggle Logic: If already P, could toggle off? Or just force P? User usually wants to set P.
        // Assuming force set.
        newPresente = true
        if (currentObs === 'Abonada') newObs = null // Clear special status
        else newObs = currentObs // Keep other notes
    } else if (status === 'F') {
        newPresente = false
        if (currentObs === 'Abonada') newObs = null
        else newObs = currentObs
    } else if (status === 'A') {
        newPresente = false
        newObs = 'Abonada'
    }

    // Optimistic Update
    const oldPresente = student.presente
    const oldObs = student.observacao
    
    student.presente = newPresente
    student.observacao = newObs

    try {
        const payload = [{
            id: student.id_presenca || undefined, // Use existing ID if we have it
            id_matricula: student.id_matricula,
            id_turma: filters.value.turma_id,
            id_componente: componente_id.value,
            data: date.value,
            presente: newPresente,
            observacao: newObs,
            id_usuario: appStore.user?.id
        }]

        await useFetch('/api/estrutura_academica/diario_presenca', {
            method: 'POST',
            body: {
                id_empresa: appStore.company?.empresa_id,
                data: payload
            }
        })
        
        // Background refresh to get real IDs for new records
        // This prevents creating duplicates if user clicks again rapidly before reload
        // Or if backend upsert requires ID validation
        fetchStudents()

    } catch (e) {
        console.error(e)
        // Revert on error
        student.presente = oldPresente
        student.observacao = oldObs
        toast.showToast('Erro ao salvar presença.', 'error')
    }
}

const openReport = (student: any) => {
    selectedStudentForReport.value = student
    reportText.value = student.observacao || ''
    isReportModalOpen.value = true
}

const saveReport = async () => {
    if (!selectedStudentForReport.value) return
    
    const student = selectedStudentForReport.value
    student.observacao = reportText.value
    // Logic: Keep current meaningful presence status? 
    // Usually changing report acts as an update.
    // We assume presence doesn't change just by editing report? 
    // Wait, if I just edit report, does it count as "Present" or "Absent"? 
    // It should keep the existing boolean. (If null/undefined, maybe default False? backend defaults False).
    // `student.presente` comes from API as boolean (or null if no record?).
    // `diario_presenca_get_por_turma` returns `dp.presente`. Can be null.
    // If null, we should probably treat as Present or Absent? 
    // If I add report, I must decide. Default False usually.
    
    const pres = student.presente ?? false // Default false if new
    
    try {
         const payload = [{
            id: student.id_presenca || undefined,
            id_matricula: student.id_matricula,
            id_turma: filters.value.turma_id,
            id_componente: componente_id.value,
            data: date.value,
            presente: pres,
            observacao: reportText.value,
            id_usuario: appStore.user?.id
        }]

        await useFetch('/api/estrutura_academica/diario_presenca', {
            method: 'POST',
            body: {
                id_empresa: appStore.company?.empresa_id,
                data: payload
            }
        })
        
        isReportModalOpen.value = false
        toast.showToast('Relatório salvo.', 'success')
        fetchStudents()
        
    } catch (e) {
        toast.showToast('Erro ao salvar relatório.', 'error')
    }
}

const getInitials = (name: string) => {
    if (!name) return '?'
    const parts = name.trim().split(/\s+/)
    if (parts.length >= 2) {
        const first = parts[0]
        const second = parts[1]
        if (first && second) {
            return (first.charAt(0) + second.charAt(0)).toUpperCase()
        }
    }
    return name.slice(0, 2).toUpperCase()
}

</script>

<template>
    <div class="p-6 md:p-8 min-h-[500px]">
        
        <!-- Filters -->
        <div class="flex flex-col gap-4 mb-6">
            <MatrizFilterBar v-model="filters" />
            
            <div class="flex items-center gap-4 flex-wrap">
                 <!-- Date Picker -->
                 <ManagerField 
                    label="Data" 
                    type="date" 
                    :model-value="date ?? undefined"
                    @update:modelValue="(v: any) => date = v"
                    class="min-w-[150px]"
                />

                 <!-- Componente Picker -->
                 <ManagerField 
                    label="Componente / Disciplina" 
                    type="select" 
                    :model-value="componente_id ?? undefined"
                    @update:modelValue="(v: any) => componente_id = v"
                    class="min-w-[200px] flex-1"
                >
                    <option :value="null">Geral / Sem Componente</option>
                    <option v-for="c in componentes" :key="c.uuid || c.id" :value="c.uuid || c.id">
                        {{ c.nome }}
                    </option>
                </ManagerField>
            </div>
        </div>

        <!-- Warning -->
        <div v-if="!filters.turma_id" class="p-8 text-center border border-dashed border-secondary/20 rounded-xl">
            <p class="text-secondary">Selecione uma turma para carregar os alunos.</p>
        </div>

        <!-- List -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
            
             <div v-if="isLoading && students.length === 0" class="col-span-full py-12 text-center text-secondary">
                Carregando alunos...
             </div>

             <div v-for="student in students" :key="student.id_matricula" 
                class="group bg-surface border border-div-15 rounded-lg overflow-hidden hover:shadow-lg transition-all duration-300 relative flex flex-col"
            >
                <!-- Card Header: Student Info -->
                <div class="p-4 flex items-center gap-4 relative"> 
                    <!-- Status Bullet (Top Right) -->
                    <div class="absolute top-4 right-4 text-[10px] font-bold px-2 py-0.5 rounded-full border"
                        :class="[
                            student.presente === true 
                                ? 'bg-success/20 text-success border-success/20' :
                            student.presente === false 
                                ? (student.observacao === 'Abonada' 
                                    ? 'bg-secondary/20 text-secondary border-secondary/20' 
                                    : 'bg-danger/20 text-danger border-danger/20') :
                            'bg-div-30 text-secondary border-div-15'
                        ]"
                    >
                        {{ 
                            student.presente === true ? 'PRESENTE' :
                            student.presente === false ? (student.observacao === 'Abonada' ? 'ABONADA' : 'FALTA') :
                            'AGUARDANDO'
                        }}
                    </div>

                    <!-- Avatar -->
                    <div 
                        class="w-10 h-10 rounded-md flex items-center justify-center text-sm font-bold shrink-0 shadow-sm transition-colors mt-1"
                        :class="[
                            student.presente === true ? '!bg-success/20 text-success' : 
                            student.presente === false ? (student.observacao === 'Abonada' ? '!bg-secondary/20 text-secondary' : '!bg-danger/20 text-danger') : 
                            'bg-div-15 text-secondary'
                        ]"
                    >
                        {{ getInitials(student.aluno_nome) }}
                    </div>
                    
                    <!-- Info -->
                    <div class="min-w-0 flex-1 pr-20"> <!-- Padding right for badge -->
                        <h4 class="font-bold text-text text-sm truncate leading-tight mb-0.5" :title="student.aluno_nome">
                            {{ student.aluno_nome }}
                        </h4>
                        <!-- Context Info -->
                        <div class="text-[10px] text-secondary flex flex-col leading-tight">
                             <div v-if="currentTurmaDetails" class="flex flex-col">
                                <!-- Turma + Ano Etapa -->
                                <span class="font-bold text-text/70">
                                    {{ currentTurmaDetails.nome_turma }} 
                                    <span v-if="currentTurmaDetails.ano_etapa" class="font-normal text-secondary">
                                        - {{ currentTurmaDetails.ano_etapa }}
                                    </span>
                                </span>
                             </div>
                             <span v-else>Carregando info...</span>
                        </div>
                    </div>
                </div>

                <!-- Controls Body -->
                <div class="px-4 pb-4">
                    <!-- Attendance Toggle -->
                    <div class="flex items-center gap-2">
                        
                        <!-- Presente (Success) -->
                        <button 
                            @click="setPresence(student, 'P')" 
                            class="flex-1 h-8 rounded text-xs font-bold transition-all flex items-center justify-center gap-1.5 relative overflow-hidden border"
                            :class="[
                                student.presente === true 
                                ? '!bg-success text-white border-success' 
                                : 'bg-success/10 text-success border-success/20 hover:bg-success hover:text-white'
                            ]"
                        >
                            <svg v-if="student.presente === true" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            <span>P</span>
                        </button>

                        <!-- Falta (Danger) -->
                        <button 
                            @click="setPresence(student, 'F')" 
                            class="flex-1 h-8 rounded text-xs font-bold transition-all flex items-center justify-center gap-1.5 relative overflow-hidden border"
                            :class="[
                                student.presente === false && (!student.observacao || student.observacao !== 'Abonada')
                                ? '!bg-danger text-white border-danger' 
                                : 'bg-danger/10 text-danger border-danger/20 hover:bg-danger hover:text-white'
                            ]"
                        >
                            <svg v-if="student.presente === false && (!student.observacao || student.observacao !== 'Abonada')" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                            <span>F</span>
                        </button>

                        <!-- Abono (Secondary) -->
                        <button 
                            @click="setPresence(student, 'A')" 
                            class="flex-1 h-8 rounded text-xs font-bold transition-all flex items-center justify-center gap-1.5 relative overflow-hidden border"
                             :class="[
                                student.presente === false && student.observacao === 'Abonada'
                                ? '!bg-secondary text-white border-secondary' 
                                : 'bg-secondary/10 text-secondary border-secondary/20 hover:bg-secondary hover:text-white'
                            ]"
                            title="Falta Abonada/Justificada"
                        >
                            <svg v-if="student.presente === false && student.observacao === 'Abonada'" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                            <span>A</span>
                        </button>

                    </div>
                </div>

                <!-- Footer: Report Button & Status Indicator -->
                <button 
                    @click="openReport(student)"
                    class="w-full py-3 text-xs font-semibold text-secondary hover:text-primary transition-colors flex items-center justify-center gap-2 border-t border-div-15 bg-surface-hover/30 hover:bg-surface-hover"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                        :class="student.observacao && student.observacao !== 'Abonada' ? 'text-primary' : 'text-div-30'"
                    ><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
                    
                    <span :class="student.observacao && student.observacao !== 'Abonada' ? 'text-primary' : ''">
                        {{ student.observacao && student.observacao !== 'Abonada' ? 'Ver Observação' : 'Adicionar Observação' }}
                    </span>
                    
                    <span v-if="student.observacao && student.observacao !== 'Abonada'" class="flex h-2 w-2 relative">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-2 w-2 bg-primary"></span>
                    </span>
                </button>

            </div>

        </div>

        <!-- Report Modal -->
        <div v-if="isReportModalOpen" class="fixed inset-0 z-[200] flex items-center justify-center p-4">
             <div class="absolute inset-0 bg-text/20 backdrop-blur-sm" @click="isReportModalOpen = false"></div>
             <div class="relative bg-surface rounded-xl shadow-2xl p-6 w-full max-w-md">
                 <h3 class="font-bold text-lg mb-4">Relatório / Observação</h3>
                 <p class="text-sm text-secondary mb-4">{{ selectedStudentForReport?.aluno_nome }}</p>
                 
                 <textarea 
                    v-model="reportText"
                    rows="4"
                    class="w-full bg-input-bg border border-input-border rounded-lg p-3 text-text outline-none focus:border-primary transition-all mb-4"
                    placeholder="Digite a observação..."
                ></textarea>

                <div class="flex justify-end gap-3">
                    <button @click="isReportModalOpen = false" class="text-sm font-bold text-secondary hover:text-text">Cancelar</button>
                    <button @click="saveReport" class="px-4 py-2 bg-primary text-white text-sm font-bold rounded">Salvar</button>
                </div>
             </div>
        </div>

    </div>
</template>
