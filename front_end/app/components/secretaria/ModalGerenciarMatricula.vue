<script setup>
import { ref, watch, onMounted, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps({
    isOpen: Boolean,
    initialData: Object
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

const years = ref([])
const currentYear = new Date().getFullYear()
years.value = [
    { value: currentYear, label: currentYear.toString() },
    { value: currentYear + 1, label: (currentYear + 1).toString() }
]

const formData = ref({
    id: null,
    id_aluno: '',
    id_ano_etapa: '',
    ano: currentYear,
    status: 'ativa',
    observacao: ''
})
const selectedAluno = ref(null)
const selectedTurma = ref(null)
const alunoSearch = ref('')
const turmaSearch = ref('')
const alocacoes = ref([])
const anosEtapas = ref([])

const alunoResults = ref([])
const turmaResults = ref([])
const isSearchingAlunos = ref(false)
const isSearchingTurmas = ref(false)
const isTurmaSearchFocused = ref(false)
const isLoadingAnos = ref(false)
const isSaving = ref(false)
const isAlocando = ref(false)
const isLoadingHistorico = ref(false)
const errorMessage = ref('')


// Initialize Form
const initForm = async () => {
    if (props.initialData) {
        formData.value = {
            id: props.initialData.id || props.initialData.uuid,
            id_aluno: props.initialData.id_aluno,
            id_ano_etapa: props.initialData.id_ano_etapa,
            ano: props.initialData.ano || currentYear,
            status: props.initialData.status,
            observacao: props.initialData.observacao || ''
        }
        selectedAluno.value = {
            id: props.initialData.id_aluno,
            nome_completo: props.initialData.aluno_nome
        }
        alunoSearch.value = props.initialData.aluno_nome
        // Load history if editing
        await fetchHistorico()
    } else {
        formData.value = {
            id: null,
            id_aluno: '',
            id_ano_etapa: '',
            ano: currentYear,
            status: 'ativa',
            observacao: ''
        }
        selectedAluno.value = null
        alunoSearch.value = ''
        alocacoes.value = []
    }
}

const fetchAnosEtapas = async () => {
    isLoadingAnos.value = true
    try {
        const { items } = await $fetch('/api/estrutura_academica/ano_etapa', {
            query: { id_empresa: appStore.company.empresa_id, limite: 100 }
        })
        anosEtapas.value = items || []
    } catch (err) {
        console.error('Erro ao buscar anos/etapas:', err)
    } finally {
        isLoadingAnos.value = false
    }
}

const fetchHistorico = async () => {
    if (!formData.value.id) return
    isLoadingHistorico.value = true
    try {
        const { items } = await $fetch('/api/secretaria/matricula_turma', {
            query: {
                id_empresa: appStore.company.empresa_id,
                id_matricula: formData.value.id
            }
        })
        console.log('[DEBUG] Historico Items:', items)
        alocacoes.value = items || []
    } catch (err) {
        console.error('Erro ao buscar histórico:', err)
    } finally {
        isLoadingHistorico.value = false
    }
}

onMounted(() => {
    fetchAnosEtapas()
    if (props.isOpen) initForm()
})

watch(() => props.isOpen, (val) => {
    if (val) initForm()
})

// Aluno Search logic
watch(alunoSearch, async (query) => {
    if (!query || (selectedAluno.value && query === selectedAluno.value.nome_completo)) {
        alunoResults.value = []
        return
    }
    if (query.length < 3) return
    
    isSearchingAlunos.value = true
    try {
        const { items } = await $fetch('/api/usuarios/alunos', {
            query: {
                id_empresa: appStore.company.empresa_id,
                busca: query,
                limite: 5
            }
        })
        alunoResults.value = items || []
    } catch (err) {
        console.error('Erro ao buscar alunos:', err)
    } finally {
        isSearchingAlunos.value = false
    }
})

const selectAluno = (aluno) => {
    selectedAluno.value = aluno
    // The RPC returns user_expandido_id, use it if id is missing
    formData.value.id_aluno = aluno.user_expandido_id || aluno.id || aluno.uuid
    alunoSearch.value = aluno.nome_completo
    alunoResults.value = []
}

// Turma Search Logic - Combined with Auto-fetch
const fetchTurmasDisponiveis = async (query = '') => {
    // We can fetch even without query if ano_etapa is selected
    if (!formData.value.id_ano_etapa) {
        turmaResults.value = []
        return
    }

    isSearchingTurmas.value = true
    try {
        const { items } = await $fetch('/api/estrutura_academica/turmas', {
            query: {
                id_empresa: appStore.company.empresa_id,
                id_ano_etapa: formData.value.id_ano_etapa,
                ano: formData.value.ano,
                busca: query,
                limite: 10
            }
        })
        turmaResults.value = items || []
    } catch (err) {
        console.error('Erro ao buscar turmas:', err)
    } finally {
        isSearchingTurmas.value = false
    }
}

// Watchers for auto-fetch
watch([() => formData.value.id_ano_etapa, () => formData.value.ano], () => {
    if (props.isOpen && formData.value.id_ano_etapa) {
        fetchTurmasDisponiveis()
    }
})

// Basic debounce for search
let searchTimeout;
watch(turmaSearch, (query) => {
    if (selectedTurma.value && query.includes(selectedTurma.value.nome_turma)) return
    
    // Clear debounce
    clearTimeout(searchTimeout)
    
    // Empty search: reset to default only if we have period
    if (!query && formData.value.id_ano_etapa) {
        fetchTurmasDisponiveis()
        return
    }

    // Debounce actual search
    searchTimeout = setTimeout(() => {
        if (query.length >= 2) fetchTurmasDisponiveis(query)
    }, 400)
})

const selectTurma = (turma) => {
    selectedTurma.value = turma
    turmaSearch.value = `${turma.nome_turma} - ${turma.periodo}`
    turmaResults.value = []
}

const handleAddTurma = async () => {
    if (!selectedTurma.value || !formData.value.id) return
    
    isAlocando.value = true
    try {
        const { success } = await $fetch('/api/secretaria/alocar_turma', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: {
                    id_matricula: formData.value.id,
                    id_turma: selectedTurma.value.id
                }
            }
        })
        if (success) {
            toast.showToast('Aluno alocado na turma!')
            selectedTurma.value = null
            turmaSearch.value = ''
            await fetchHistorico()
        }
    } catch (err) {
        toast.showToast('Erro ao alocar turma.', 'error')
    } finally {
        isAlocando.value = false
    }
}

const handleCancel = () => {
    emit('close')
}

const handleSave = async () => {
    if (!formData.value.id_aluno || !formData.value.id_ano_etapa) {
        errorMessage.value = 'Aluno e Ano/Etapa são obrigatórios.'
        return
    }

    isSaving.value = true
    errorMessage.value = ''

    try {
        const { success, data } = await $fetch('/api/secretaria/matriculas', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: formData.value
            }
        })

        if (success) {
            toast.showToast('Matrícula salva com sucesso!')
            // If it was a new record, we might want to keep the modal open to alocar turma
            if (!formData.value.id) {
                formData.value.id = data.id || data.uuid
                await fetchHistorico()
                toast.showToast('Matrícula criada. Você já pode alocar a turma.', 'info')
            } else {
                emit('success')
                emit('close')
            }
        }
    } catch (err) {
        errorMessage.value = err.data?.message || 'Erro ao salvar matrícula.'
    } finally {
        isSaving.value = false
    }
}

const getStatusColor = (status) => {
    const colors = {
        ativa: '#10b981',
        transferida: '#f59e0b',
        cancelada: '#ef4444',
        evadida: '#6b7280',
        concluida: '#3b82f6'
    }
    return colors[status] || '#ccc'
}
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[110] flex items-center justify-center p-4 md:p-6 text-sm">
            <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="handleCancel"></div>
            
            <div class="relative bg-background w-full max-w-3xl flex flex-col rounded-lg shadow-2xl border border-secondary/10 overflow-hidden max-h-[90vh]">
                
                <!-- Header -->
                <div class="px-6 py-5 border-b border-secondary/10 flex items-center justify-between bg-div-15">
                    <div>
                        <h2 class="text-2xl font-black text-text">{{ initialData ? 'Gerenciar Matrícula' : 'Nova Matrícula' }}</h2>
                        <p class="text-xs text-secondary mt-1">Vínculo do aluno com o período letivo e alocação de turmas.</p>
                    </div>
                     <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body Scrollable -->
                <div class="p-6 overflow-y-auto flex flex-col gap-8">
                     <!-- 1. Matrícula Info -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div class="relative">
                            <label class="text-[10px] uppercase font-bold text-secondary mb-2 block tracking-widest">Aluno</label>
                            <input 
                                type="text" 
                                v-model="alunoSearch"
                                placeholder="Buscar nome do aluno..."
                                class="w-full bg-div-15 border border-secondary/20 rounded-md px-4 py-2.5 outline-none focus:border-primary transition-all text-sm"
                                :disabled="initialData"
                            />
                            <div v-if="alunoResults.length > 0" class="absolute top-full left-0 w-full mt-1 bg-surface border border-secondary/20 rounded shadow-2xl z-50 overflow-hidden">
                                <button 
                                    v-for="aluno in alunoResults" 
                                    :key="aluno.id"
                                    @click="selectAluno(aluno)"
                                    class="w-full text-left px-4 py-3 hover:bg-div-15 transition-colors flex items-center gap-3 border-b border-secondary/5 last:border-0"
                                >
                                    <div class="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-[10px] font-black text-primary shrink-0">
                                        {{ aluno.nome_completo ? aluno.nome_completo.split(' ').filter(n => n).map(n => n[0]).join('').substring(0,2).toUpperCase() : '??' }}
                                    </div>
                                    <div class="flex flex-col min-w-0">
                                        <span class="text-xs font-bold text-text truncate">{{ aluno.nome_completo }}</span>
                                        <div class="flex items-center gap-2">
                                            <span class="text-[10px] text-secondary/70 truncate">{{ aluno.email }}</span>
                                            <span v-if="aluno.matricula" class="text-[9px] font-black text-secondary/40 whitespace-nowrap uppercase">| RM: {{ aluno.matricula }}</span>
                                        </div>
                                    </div>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                        <div class="md:col-span-2">
                            <ManagerField 
                                label="Ano / Etapa Letiva"
                                v-model="formData.id_ano_etapa"
                                type="select"
                                placeholder="Selecione o período..."
                                :disabled="initialData"
                                :options="anosEtapas.map(ano => ({ value: ano.id, label: `${ano.nome} (${ano.tipo})` }))"
                            />
                        </div>
                        <div class="md:col-span-2">
                            <ManagerField 
                                label="Ano Calendário"
                                v-model="formData.ano"
                                type="select"
                                :options="years"
                                :disabled="initialData"
                            />
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                        <div class="md:col-span-1">
                             <ManagerField 
                                label="Status da Matrícula"
                                v-model="formData.status"
                                type="select"
                                :options="[
                                    { value: 'ativa', label: 'Ativa' },
                                    { value: 'transferida', label: 'Transferida' },
                                    { value: 'cancelada', label: 'Cancelada' },
                                    { value: 'evadida', label: 'Evadida' },
                                    { value: 'concluida', label: 'Concluída' }
                                ]"
                            />
                        </div>
                        <div class="md:col-span-3">
                             <ManagerField 
                                label="Observações"
                                v-model="formData.observacao"
                                placeholder="Notas internas sobre a matrícula..."
                            />
                        </div>
                    </div>

                    <hr class="border-secondary/10" />

                    <!-- 2. Histórico de Turmas (Only if Matricula exists) -->
                    <div v-if="formData.id" class="flex flex-col gap-4">
                        <div class="flex items-center justify-between">
                            <h3 class="text-lg font-bold">Histórico de Alocação (Turmas)</h3>
                            <span class="text-[10px] font-bold text-secondary bg-div-15 px-2 py-1 rounded">Vínculo Temporal</span>
                        </div>

                        <!-- Add allocation -->
                        <div class="flex flex-col md:flex-row gap-3 p-4 bg-div-10 rounded-lg border border-secondary/5">
                            <div class="flex-1 relative">
                                <label class="text-[10px] uppercase font-bold text-secondary mb-1 block">Buscar Turma</label>
                                <input 
                                    type="text" 
                                    v-model="turmaSearch"
                                    placeholder="Ex: 1º Ano A..."
                                    class="w-full bg-div-15 border border-secondary/20 rounded px-3 py-2 outline-none focus:border-primary transition-all text-xs"
                                    @focus="isTurmaSearchFocused = true"
                                    @blur="setTimeout(() => isTurmaSearchFocused = false, 200)"
                                />
                                <div v-if="turmaResults.length > 0 && isTurmaSearchFocused" class="absolute top-full left-0 w-full mt-1 bg-surface border border-secondary/20 rounded shadow-xl z-50 overflow-hidden">
                                    <button 
                                        v-for="turma in turmaResults" 
                                        :key="turma.id"
                                        @click="selectTurma(turma)"
                                        class="w-full text-left px-4 py-2 hover:bg-div-15 transition-colors flex items-center justify-between border-b border-secondary/5 last:border-0"
                                    >
                                        <div class="flex flex-col">
                                            <span class="text-xs font-bold">{{ turma.nome_turma }} - {{ turma.periodo }}</span>
                                            <span class="text-[10px] text-secondary">{{ turma.nome_escola }}</span>
                                        </div>
                                        <div class="flex flex-col items-end">
                                            <span class="text-[10px] font-mono opacity-50">{{ turma.ano }}</span>
                                            <span class="text-[9px] opacity-30">{{ turma.hora_completo }}</span>
                                        </div>
                                    </button>
                                </div>
                            </div>
                            <div class="flex items-end">
                                <button 
                                    @click="handleAddTurma"
                                    :disabled="!selectedTurma || isAlocando"
                                    class="h-9 px-6 rounded bg-primary text-white font-bold hover:brightness-110 active:scale-95 disabled:opacity-50 transition-all text-xs flex items-center gap-2"
                                >
                                    <span v-if="isAlocando" class="w-3 h-3 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
                                    {{ isAlocando ? 'Alocando...' : '+ Alocar na Turma' }}
                                </button>
                            </div>
                        </div>

                        <!-- Allocation History List -->
                        <div class="flex flex-col gap-2 mt-2">
                             <div v-if="isLoadingHistorico" class="flex justify-center p-4">
                                <div class="w-6 h-6 border-2 border-primary/20 border-t-primary rounded-full animate-spin"></div>
                             </div>
                             <div v-else-if="alocacoes.length === 0" class="text-center py-6 text-secondary/40 italic text-xs bg-div-5 rounded border border-dashed border-secondary/10">
                                 O aluno ainda não foi alocado em nenhuma turma neste período.
                             </div>
                             <div 
                                v-for="aloc in alocacoes" 
                                :key="aloc.id"
                                class="flex items-center justify-between p-4 bg-div-15 hover:bg-div-20 rounded-md border border-secondary/5 transition-all group"
                             >
                                <div class="flex items-center gap-4">
                                    <div 
                                        class="w-8 h-8 rounded flex items-center justify-center border border-secondary/10"
                                        :style="{ backgroundColor: getStatusColor(aloc.status) + '15', color: getStatusColor(aloc.status) }"
                                    >
                                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18"/><path d="M5 21V7l8-4 8 4v14"/><path d="M17 21v-8.33A2 2 0 0 0 15 10.67h-6a2 2 0 0 0-2 2V21"/><path d="M9 13.67h6"/></svg>
                                    </div>
                                    <div class="flex flex-col">
                                        <span class="font-bold text-sm">{{ aloc.turma_nome || 'Turma Desconhecida' }}</span>
                                        <div class="flex flex-col">
                                            <span v-if="aloc.escola_nome" class="text-[10px] text-secondary font-medium">{{ aloc.escola_nome }}</span>
                                            <span v-if="aloc.periodo" class="text-[10px] text-secondary/70">{{ aloc.periodo }}</span>
                                        </div>
                                        <span class="text-[10px] text-secondary font-medium uppercase tracking-tight mt-1">
                                            Entrada: {{ new Date(aloc.data_entrada).toLocaleDateString() }} 
                                            {{ aloc.data_saida ? ' • Saída: ' + new Date(aloc.data_saida).toLocaleDateString() : '' }}
                                        </span>
                                    </div>
                                </div>
                                <div class="flex items-center gap-4">
                                     <span 
                                        class="px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-widest border"
                                        :style="{ 
                                            backgroundColor: aloc.status === 'ativa' ? '#10b98110' : '#6b728010',
                                            color: aloc.status === 'ativa' ? '#10b981' : '#6b7280',
                                            borderColor: aloc.status === 'ativa' ? '#10b98120' : '#6b728020'
                                        }"
                                     >
                                        {{ aloc.status }}
                                     </span>
                                </div>
                             </div>
                        </div>
                    </div>
                </div>

                <!-- Footer -->
                <div class="px-6 py-5 border-t border-secondary/10 flex items-center justify-between bg-div-15">
                    <div v-if="errorMessage" class="text-xs text-red-500 font-bold flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                        {{ errorMessage }}
                    </div>
                    <div v-else></div>
                    
                    <div class="flex items-center gap-4">
                        <button 
                            @click="handleCancel"
                            class="px-5 py-2.5 rounded text-secondary font-bold hover:bg-div-30 transition-colors"
                        >
                            Descartar
                        </button>
                        <button 
                            @click="handleSave"
                            :disabled="isSaving"
                            class="px-8 py-2.5 rounded bg-primary text-white font-black shadow-lg shadow-primary/20 hover:brightness-110 active:scale-95 disabled:opacity-50 transition-all flex items-center gap-2"
                        >
                            <span v-if="isSaving" class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
                            {{ isSaving ? 'Processando...' : (formData.id ? 'Salvar Alterações' : 'Concluir Matrícula') }}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>
