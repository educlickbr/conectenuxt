<script setup lang="ts">
import { ref, watch, onMounted, computed, nextTick } from 'vue'
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
const componente_id = ref<string | null>(null) // null = Geral

// Data
const isLoading = ref(false)
const students = ref<any[]>([])
const dailyComponents = ref<any[]>([])
const currentTurmaDetails = ref<any>(null)

// Modal for Report
const isReportModalOpen = ref(false)
const selectedStudentForReport = ref<any>(null)
const reportText = ref('')

// --- Fetchers ---

const fetchDailyComponents = async () => {
    if (!filters.value.turma_id || !date.value) {
        dailyComponents.value = []
        return
    }

    try {
        const client = useSupabaseClient()
        // Cast to any to avoid TS errors with new RPC signature
        const { data, error }: any = await (client as any).rpc('diario_get_componentes_dia', {
            p_id_empresa: appStore.company?.empresa_id,
            p_id_turma: filters.value.turma_id,
            p_data: date.value
        })

        if (error) throw error
        
        // Add "Geral" option implicitly handled by null selection, but we render buttons
        dailyComponents.value = data.items || []
        
        // If current selected component is not in the new list, reset to General (null)
        if (componente_id.value && !dailyComponents.value.find((c: any) => c.id_componente === componente_id.value)) {
            componente_id.value = null
        }

    } catch (e) {
        console.error('Error fetching daily components:', e)
        dailyComponents.value = []
    }
}

const fetchStudents = async () => {
    if (!filters.value.turma_id || !date.value) {
        students.value = []
        return
    }

    isLoading.value = true
    try {
        const client = useSupabaseClient()
        
        const { data, error } = await (client as any)
            .rpc('diario_presenca_get_por_turma', {
                p_id_empresa: appStore.company?.empresa_id,
                p_id_turma: filters.value.turma_id,
                p_data: date.value,
                p_id_componente: componente_id.value
            })

        if (error) throw error

        students.value = data || []
        
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
    } finally {
        isLoading.value = false
    }
}

// Watchers
watch(() => filters.value.turma_id, () => {
    fetchDailyComponents()
    fetchStudents()
})
watch(date, async () => {
    await fetchDailyComponents()
    fetchStudents()
})
watch(componente_id, fetchStudents)


// --- Actions ---

const setPresence = async (student: any, status: 'P' | 'F' | 'A') => {
    const oldStatus = student.status
    student.status = status // Optimistic

    try {
        const payload = [{
            id: student.id_presenca || undefined,
            id_matricula: student.id_matricula,
            id_turma: filters.value.turma_id,
            id_componente: componente_id.value,
            data: date.value,
            status: status,
            observacao: student.observacao,
            id_usuario: appStore.user?.id
        }]

        await useFetch('/api/estrutura_academica/diario_presenca', {
            method: 'POST',
            body: {
                id_empresa: appStore.company?.empresa_id,
                data: payload
            }
        })
        
        fetchStudents() // Refresh IDs

    } catch (e) {
        student.status = oldStatus
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
    const currentStatus = student.status || 'P'
    
    try {
         const payload = [{
            id: student.id_presenca || undefined,
            id_matricula: student.id_matricula,
            id_turma: filters.value.turma_id,
            id_componente: componente_id.value,
            data: date.value,
            status: currentStatus,
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
    if (parts.length >= 2) return ((parts[0] || '').charAt(0) + (parts[1] || '').charAt(0)).toUpperCase()
    return name.slice(0, 2).toUpperCase()
}

// Helpers for Component UI
const getDayName = computed(() => {
    if (!date.value) return ''
    const d = new Date(date.value + 'T12:00:00') // Force noon to avoid timezone issues
    return d.toLocaleDateString('pt-BR', { weekday: 'long' })
})

</script>

<template>
    <div class="p-6 md:p-8 min-h-[500px]">
        
        <!-- Header Controls -->
        <div class="flex flex-col gap-6 mb-8">
            <MatrizFilterBar v-model="filters" />
            
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
                            @click="componente_id = null"
                            class="px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap border"
                            :class="componente_id === null 
                                ? 'bg-primary text-white border-primary shadow-lg shadow-primary/20' 
                                : 'bg-surface text-secondary border-div-15 hover:border-primary/50'"
                        >
                            Geral (Dia Inteiro)
                        </button>

                        <div class="h-6 w-px bg-div-15 mx-2"></div>

                        <!-- Scheduled Components -->
                        <button 
                            v-for="comp in dailyComponents" 
                            :key="comp.id_componente"
                            @click="componente_id = comp.id_componente"
                            class="px-4 py-2 rounded-lg text-sm font-bold transition-all whitespace-nowrap border flex items-center gap-2"
                            :class="componente_id === comp.id_componente 
                                ? 'bg-white text-primary border-primary ring-2 ring-primary/20' 
                                : 'bg-surface text-secondary border-div-15 hover:border-primary/50'"
                            :style="componente_id === comp.id_componente ? { borderColor: comp.cor } : {}"
                        >
                            <span class="w-2 h-2 rounded-full" :style="{ backgroundColor: comp.cor || '#ccc' }"></span>
                            {{ comp.nome }}
                        </button>
                        
                        <div v-if="dailyComponents.length === 0" class="text-xs text-secondary italic px-2">
                            Sem aulas cadastradas na Matriz para hoje.
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Warning -->
        <div v-if="!filters.turma_id" class="py-12 text-center border-2 border-dashed border-secondary/10 rounded-xl bg-surface/50">
            <p class="text-secondary font-medium">Selecione uma turma acima para iniciar a chamada.</p>
        </div>

        <!-- List -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            
             <div v-if="isLoading && students.length === 0" class="col-span-full py-12 text-center text-secondary">
                <div class="animate-pulse flex flex-col items-center gap-3">
                    <div class="h-8 w-8 rounded-full border-2 border-primary border-t-transparent animate-spin"></div>
                    <span class="text-sm font-medium">Carregando alunos...</span>
                </div>
             </div>
             
             <div v-if="!isLoading && students.length === 0" class="col-span-full py-12 text-center text-secondary">
                 Nenhum aluno encontrado nesta turma.
             </div>

             <div v-for="student in students" :key="student.id_matricula" 
                class="group bg-surface border border-div-15 rounded-xl overflow-hidden hover:shadow-xl hover:-translate-y-1 transition-all duration-300 relative flex flex-col"
            >
                <!-- Card Header -->
                <div class="p-4 flex items-center gap-4 relative bg-gradient-to-br from-white to-background dark:from-surface dark:to-surface"> 
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
                             <span v-if="componente_id" class="text-primary font-bold">• {{ dailyComponents.find(c => c.id_componente === componente_id)?.nome }}</span>
                             <span v-else>• Geral</span>
                        </div>
                    </div>
                </div>

                <!-- Controls Body -->
                <div class="px-4 pb-4">
                    <div class="flex items-center gap-3">
                        
                        <!-- Presente (Success) -->
                        <button 
                            @click="setPresence(student, 'P')" 
                            class="flex-1 h-9 rounded-lg text-xs font-bold transition-all flex items-center justify-center gap-1.5 relative overflow-hidden border"
                            :class="[
                                student.status === 'P' 
                                ? '!bg-success !text-white !border-success ring-1 ring-success shadow-sm' 
                                : 'bg-success/20 text-success border-success/30 hover:bg-success hover:text-white'
                            ]"
                        >
                            P
                        </button>

                        <!-- Falta (Danger) -->
                        <button 
                            @click="setPresence(student, 'F')" 
                            class="flex-1 h-9 rounded-lg text-xs font-bold transition-all flex items-center justify-center gap-1.5 relative overflow-hidden border"
                            :class="[
                                student.status === 'F'
                                ? '!bg-danger !text-white !border-danger ring-1 ring-danger shadow-sm' 
                                : 'bg-danger/20 text-danger border-danger/30 hover:bg-danger hover:text-white'
                            ]"
                        >
                            F
                        </button>

                        <!-- Abono (Secondary) -->
                        <button 
                            @click="setPresence(student, 'A')" 
                            class="flex-1 h-9 rounded-lg text-xs font-bold transition-all flex items-center justify-center gap-1.5 relative overflow-hidden border"
                             :class="[
                                student.status === 'A'
                                ? '!bg-secondary !text-white !border-secondary ring-1 ring-secondary shadow-sm' 
                                : 'bg-secondary/20 text-secondary border-secondary/30 hover:bg-secondary hover:text-white'
                            ]"
                            title="Falta Abonada/Justificada"
                        >
                            A
                        </button>

                    </div>
                </div>

                <!-- Footer -->
                <button 
                    @click="openReport(student)"
                    class="w-full py-3 text-xs font-semibold transition-colors flex items-center justify-center gap-2 border-t border-div-15 bg-surface hover:bg-surface-hover group-hover:border-primary/10"
                    :class="student.observacao ? 'text-primary' : 'text-secondary'"
                >
                    <span v-if="student.observacao" class="relative flex h-2 w-2">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-2 w-2 bg-primary"></span>
                    </span>
                    {{ student.observacao ? 'Observação Salva' : 'Adicionar Observação' }}
                </button>

            </div>

        </div>

        <!-- Report Modal -->
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
