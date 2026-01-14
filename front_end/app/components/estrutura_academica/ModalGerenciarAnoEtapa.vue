<script setup>
import { ref, watch, computed, onMounted } from 'vue'
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


const formData = ref({
    nome: '',
    tipo: 'Ano',
    carg_horaria: 0
})
const workloads = ref([])
const isSaving = ref(false)
const isLoadingWorkloads = ref(false)
const errorMessage = ref('')

// Search and add component state
const componentSearch = ref('')
const componentResults = ref([])
const isSearchingComponents = ref(false)
const selectedComponent = ref(null)
const newWorkloadHours = ref(0)
const isAddingWorkload = ref(false)
const editingWorkloadId = ref(null)

// Calculations
const currentTotalWorkload = computed(() => {
    return workloads.value.reduce((acc, curr) => acc + (Number(curr.carga_horaria) || 0), 0)
})

const remainingWorkload = computed(() => {
    const target = Number(formData.value.carg_horaria) || 0
    return target - currentTotalWorkload.value
})

const workloadStatus = computed(() => {
    if (remainingWorkload.value > 0) return { type: 'warning', text: `Faltam ${remainingWorkload.value} aulas para atingir a meta.` }
    if (remainingWorkload.value < 0) return { type: 'error', text: `Carga horária excedida em ${Math.abs(remainingWorkload.value)} horas!` }
    return { type: 'success', text: 'Carga horária total atingida com perfeição.' }
})

// Initialize form
const initForm = async () => {
    if (props.initialData) {
        formData.value = { 
            id: props.initialData.id || props.initialData.uuid,
            nome: props.initialData.nome || props.initialData.ano || '',
            tipo: props.initialData.tipo || 'Ano',
            carg_horaria: props.initialData.carg_horaria || 0,
            id_modelo_calendario: props.initialData.id_modelo_calendario || null
        }
        await Promise.all([
            fetchWorkloads(),
            fetchCalendarModels()
        ])
    } else {
        formData.value = {
            nome: '',
            tipo: 'Ano',
            carg_horaria: 800,
            id_modelo_calendario: null
        }
        workloads.value = []
    }
}

const calendarModels = ref([])
const isLoadingModels = ref(false)

const fetchCalendarModels = async () => {
    isLoadingModels.value = true
    try {
        const { items } = await $fetch('/api/estrutura_academica/modelo_calendario', {
            // No parameters needed
        })
        
        calendarModels.value = (items || []).map(m => ({
            value: m.id,
            label: m.nome
        }))
    } catch (err) {
        console.error('Erro ao buscar modelos de calendário:', err)
        toast.showToast('Erro ao carregar modelos de calendário.', 'error')
    } finally {
        isLoadingModels.value = false
    }
}

onMounted(() => {
    fetchCalendarModels()
})

const fetchWorkloads = async () => {
    if (!formData.value.id) return
    isLoadingWorkloads.value = true
    try {
        const { items } = await $fetch('/api/estrutura_academica/carga_horaria', {
            query: {
                id_empresa: appStore.company.empresa_id,
                id_ano_etapa: formData.value.id
            }
        })
        workloads.value = items || []
    } catch (err) {
        console.error('Erro ao buscar cargas horárias:', err)
        toast.showToast('Erro ao carregar lista de componentes.', 'error')
    } finally {
        isLoadingWorkloads.value = false
    }
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        initForm()
        errorMessage.value = ''
        resetNewWorkload()
    }
})

// Component Search
watch(componentSearch, async (query) => {
    // If empty, reset selection
    if (!query) {
        selectedComponent.value = null
        componentResults.value = []
        return
    }

    // Prevent search if the query matches the already selected component
    if (selectedComponent.value && query === selectedComponent.value.nome) {
        componentResults.value = []
        return
    }

    if (query.length < 2) {
        componentResults.value = []
        return
    }
    
    isSearchingComponents.value = true
    try {
        const { items } = await $fetch('/api/estrutura_academica/componentes', {
            query: {
                id_empresa: appStore.company.empresa_id,
                busca: query,
                limite: 5
            }
        })
        componentResults.value = items || []
    } catch (err) {
        console.error('Erro na busca de componentes:', err)
    } finally {
        isSearchingComponents.value = false
    }
})

const selectComponent = (comp) => {
    selectedComponent.value = comp
    componentSearch.value = comp.nome
    componentResults.value = []
}

const resetNewWorkload = () => {
    selectedComponent.value = null
    componentSearch.value = ''
    componentResults.value = []
    componentResults.value = []
    newWorkloadHours.value = 0
    editingWorkloadId.value = null
}

const handleEditWorkload = (ch) => {
    selectedComponent.value = {
        uuid: ch.id_componente,
        nome: ch.componente_nome,
        cor: ch.componente_cor
    }
    componentSearch.value = ch.componente_nome
    newWorkloadHours.value = ch.carga_horaria
    editingWorkloadId.value = ch.uuid
}

const handleAddWorkload = async () => {
    if (!selectedComponent.value) {
        toast.showToast('Selecione um componente.', 'warning')
        return
    }
    if (newWorkloadHours.value <= 0) {
        toast.showToast('Informe a carga horária.', 'warning')
        return
    }

    isAddingWorkload.value = true
    try {
        const payload = {
            id_componente: selectedComponent.value.uuid,
            id_ano_etapa: formData.value.id,
            carga_horaria: newWorkloadHours.value,
            uuid: editingWorkloadId.value // Include if editing
        }

        const { success, message, data } = await $fetch('/api/estrutura_academica/carga_horaria', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload
            }
        })

        if (success) {
            toast.showToast('Carga horária salva!')
            await fetchWorkloads()
            resetNewWorkload()
        }
    } catch (err) {
        console.error('Erro ao salvar carga horária:', err)
        toast.showToast(err.data?.message || 'Erro ao salvar.', 'error')
    } finally {
        isAddingWorkload.value = false
    }
}

const handleRemoveWorkload = async (ch) => {
    try {
        const { success } = await $fetch('/api/estrutura_academica/carga_horaria', {
            method: 'DELETE',
            body: {
                id: ch.uuid,
                id_empresa: appStore.company.empresa_id
            }
        })
        if (success) {
            toast.showToast('Componente removido do ano/etapa.')
            await fetchWorkloads()
        }
    } catch (err) {
        toast.showToast('Erro ao remover componente.', 'error')
    }
}

const handleCancel = () => {
    emit('close')
}

const handleSave = async () => {
    if (!formData.value.nome.trim()) {
        errorMessage.value = 'O nome/ano é obrigatório.'
        return
    }

    isSaving.value = true
    errorMessage.value = ''

    try {
        const payload = {
            id: formData.value.id,
            nome: formData.value.nome,
            tipo: formData.value.tipo,
            carg_horaria: Number(formData.value.carg_horaria),
            id_modelo_calendario: formData.value.id_modelo_calendario
        }

        const { success, message } = await $fetch('/api/estrutura_academica/ano_etapa', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload
            }
        })

        if (success) {
            toast.showToast(message || 'Registro salvo com sucesso!')
            emit('success')
            emit('close')
        } else {
             throw new Error(message || 'Erro desconhecido ao salvar.')
        }

    } catch (err) {
        console.error('Erro ao salvar ano/etapa:', err)
        errorMessage.value = err.data?.message || err.message || 'Erro ao comunicar com o servidor.'
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-6 text-sm">
            <!-- Backdrop -->
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="handleCancel"></div>
            
            <!-- Modal Content -->
            <div class="relative bg-background w-full max-w-2xl flex flex-col rounded shadow-2xl border border-secondary/10 overflow-hidden transform transition-all text-text max-h-[90vh]">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-div-15 shrink-0">
                    <div>
                        <h2 class="text-xl font-bold">{{ initialData ? 'Editar Ano/Etapa' : 'Novo Ano/Etapa' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Defina o período letivo e a matriz curricular.</p>
                    </div>
                     <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body Scrollable -->
                <div class="flex-1 overflow-y-auto p-6 flex flex-col gap-8">
                     <!-- 1. Basic Info Section -->
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div class="md:col-span-2">
                             <ManagerField 
                                label="Nome / Ano Escolar"
                                v-model="formData.nome"
                                placeholder="Ex: 2025 ou 1º Semestre"
                                required
                            />
                        </div>
                        <ManagerField 
                            label="Tipo"
                            v-model="formData.tipo"
                            type="select"
                            :options="[
                                { value: 'Ano', label: 'Ano' },
                                { value: 'Etapa', label: 'Etapa' }
                            ]"
                        />
                        <div class="md:col-span-3">
                            <ManagerField 
                                label="Modelo de Calendário"
                                v-model="formData.id_modelo_calendario"
                                type="select"
                                :options="calendarModels"
                                :loading="isLoadingModels"
                                placeholder="Selecione..."
                            />
                        </div>
                    </div>

                    <div>
                         <ManagerField 
                            label="Meta de Aulas por Semana"
                            v-model="formData.carg_horaria"
                            type="number"
                            placeholder="Ex: 800"
                        />
                    </div>

                    <hr class="border-secondary/10" />

                    <!-- 2. Matriz Curricular / Componentes Section -->
                    <div v-if="formData.id" class="flex flex-col gap-4">
                        <div class="flex items-center justify-between">
                            <h3 class="font-bold text-lg">Matriz Curricular</h3>
                            <div class="px-3 py-1 rounded-full bg-div-15 border border-secondary/10 text-[10px] font-black uppercase tracking-wider">
                                Total: {{ currentTotalWorkload }} / {{ formData.carg_horaria }}a
                            </div>
                        </div>

                        <!-- Status Alert -->
                        <div :class="[
                            'p-3 rounded text-[11px] font-medium border flex items-center gap-2',
                            workloadStatus.type === 'warning' ? 'bg-orange-500/5 border-orange-500/20 text-orange-500' :
                            workloadStatus.type === 'error' ? 'bg-red-500/5 border-red-500/20 text-red-500' :
                            'bg-green-500/5 border-green-500/20 text-green-500'
                        ]">
                            <svg v-if="workloadStatus.type === 'error'" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                            <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                            {{ workloadStatus.text }}
                        </div>

                        <!-- Add Component Form Row -->
                        <div class="flex flex-col md:flex-row gap-3 p-4 bg-div-15 rounded border border-div-30/50">
                            <div class="flex-1 relative">
                                <label class="text-[10px] uppercase font-bold text-secondary mb-1 block">Componente</label>
                                <input 
                                    type="text" 
                                    v-model="componentSearch"
                                    placeholder="Buscar componente..."
                                    class="w-full bg-div-15 border border-secondary/30 rounded px-3 py-2 outline-none focus:border-primary transition-all text-xs"
                                />
                                <!-- Dropdown Results -->
                                <div v-if="componentResults.length > 0" class="absolute top-full left-0 w-full mt-1 bg-surface border border-secondary/20 rounded shadow-xl z-20 overflow-hidden">
                                    <button 
                                        v-for="comp in componentResults" 
                                        :key="comp.uuid"
                                        @click="selectComponent(comp)"
                                        class="w-full text-left px-4 py-2 hover:bg-div-15 transition-colors flex items-center gap-2 border-b border-secondary/5 last:border-0"
                                    >
                                        <div class="w-2 h-2 rounded-full" :style="{ backgroundColor: comp.cor || '#ccc' }"></div>
                                        <span class="text-xs font-medium">{{ comp.nome }}</span>
                                    </button>
                                </div>
                                <div v-if="isSearchingComponents" class="absolute right-3 top-[34px]">
                                    <div class="w-3 h-3 border border-primary/20 border-t-primary rounded-full animate-spin"></div>
                                </div>
                            </div>
                            <div class="w-24">
                                <label class="text-[10px] uppercase font-bold text-secondary mb-1 block">Aula/Sem</label>
                                <input 
                                    type="number" 
                                    v-model="newWorkloadHours"
                                    class="w-full bg-div-15 border border-secondary/30 rounded px-3 py-2 outline-none focus:border-primary transition-all text-xs"
                                />
                            </div>
                            <div class="flex items-end">
                                <button 
                                    @click="handleAddWorkload"
                                    :disabled="isAddingWorkload || !selectedComponent"
                                    class="h-9 px-4 rounded bg-primary text-white font-bold hover:brightness-110 disabled:opacity-50 transition-all flex items-center gap-2"
                                >
                                     <span v-if="isAddingWorkload" class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
                                     <span v-if="isAddingWorkload" class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
                                     {{ isAddingWorkload ? '...' : (editingWorkloadId ? 'Atualizar' : '+ Adicionar') }}
                                </button>
                                <button
                                    v-if="editingWorkloadId"
                                    @click="resetNewWorkload"
                                    class="h-9 px-3 ml-2 rounded bg-div-30 text-secondary hover:text-text transition-colors font-medium text-xs"
                                >
                                    Cancelar
                                </button>
                            </div>
                        </div>

                        <!-- Workloads List -->
                        <div class="flex flex-col gap-1.5 mt-2">
                             <div v-if="isLoadingWorkloads" class="flex justify-center py-4">
                                <div class="w-6 h-6 border-2 border-primary/20 border-t-primary rounded-full animate-spin"></div>
                             </div>
                             <div v-else-if="workloads.length === 0" class="text-center py-8 text-secondary/50 italic text-[11px]">
                                 Nenhum componente vinculado a este ano/etapa.
                             </div>
                             <div 
                                v-for="ch in workloads" 
                                :key="ch.uuid"
                                class="flex items-center justify-between p-3 bg-div-10 hover:bg-div-15 rounded border border-secondary/5 group transition-all"
                             >
                                <div class="flex items-center gap-3">
                                     <div class="w-3 h-3 rounded-full" :style="{ backgroundColor: ch.componente_cor || '#ccc' }"></div>
                                     <span class="font-bold text-xs">{{ ch.componente_nome }}</span>
                                </div>
                                <div class="flex items-center gap-6">
                                     <span class="text-xs font-mono font-bold">{{ ch.carga_horaria }} Aulas</span>
                                     <button 
                                        @click="handleEditWorkload(ch)"
                                        class="p-1.5 rounded-full hover:bg-div-30 text-secondary hover:text-primary transition-all opacity-0 group-hover:opacity-100"
                                        title="Editar Carga Horária"
                                     >
                                         <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                     </button>
                                     <button 
                                        @click="handleRemoveWorkload(ch)"
                                        class="p-1.5 rounded-full hover:bg-red-500/10 text-secondary group-hover:text-red-500 transition-all opacity-0 group-hover:opacity-100"
                                     >
                                         <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"></path><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"></path><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"></path></svg>
                                     </button>
                                </div>
                             </div>
                        </div>
                    </div>
                    <div v-else class="p-8 bg-div-15 rounded border border-dashed border-secondary/20 text-center">
                        <p class="text-xs text-secondary italic">Salve o Ano/Etapa primeiro para gerenciar a Matriz Curricular.</p>
                    </div>
                </div>

                <!-- Footer -->
                <div class="px-6 py-4 border-t border-secondary/10 flex items-center justify-between bg-div-15 shrink-0">
                    <div class="text-[10px] text-secondary font-medium">
                        {{ workloads.length }} componentes configurados
                    </div>
                    <div class="flex items-center gap-3">
                        <button 
                            @click="handleCancel"
                            class="px-4 py-2 rounded text-secondary font-semibold hover:bg-div-30 transition-colors"
                        >
                            Cancelar
                        </button>
                        <button 
                            @click="handleSave"
                            :disabled="isSaving"
                            class="px-6 py-2 rounded bg-primary text-white font-bold hover:brightness-110 active:scale-95 disabled:opacity-50 transition-all flex items-center gap-2"
                        >
                            <span v-if="isSaving" class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
                            {{ isSaving ? 'Salvando...' : 'Finalizar' }}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>
