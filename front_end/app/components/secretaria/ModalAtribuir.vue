<script setup>
import { ref, watch, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'
import { useSupabaseClient } from '#imports'

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    },
    type: {
        type: String,
        default: 'polivalente' // 'polivalente' | 'componentes'
    },
    initialData: {
        type: Object,
        default: null
    }
})

const emit = defineEmits(['close', 'success', 'delete'])
const appStore = useAppStore()
const toast = useToastStore()

// State
const isSaving = ref(false)
const errorMessage = ref('')
const isLoadingProfessores = ref(false)

// Mode State: 'create' | 'manage' | 'substitute'
const mode = ref('create')

// Data
const professoresOptions = ref([])

// Form
const formData = ref({
    id: null,
    id_turma: '',
    id_carga_horaria: '',
    id_professor: '',
    ano: new Date().getFullYear(),
    data_inicio: '',
    data_fim: '',
    motivo_substituicao: '',
    nivel_substituicao: 0
})

// Config based on Type
const config = computed(() => {
    return props.type === 'polivalente' 
        ? { title: 'Atribuir Professor', resource: 'atribuicao_turmas' }
        : { title: 'Atribuir Professor de Componente', resource: 'atribuicao_componentes' }
})

// Display info
const turmaInfo = computed(() => {
    if (!props.initialData) return ''
    const { turma_ano, ano_etapa_nome, classe_nome, escola_nome } = props.initialData
    return `${turma_ano} - ${ano_etapa_nome} ${classe_nome} (${escola_nome})`
})

const componenteInfo = computed(() => {
    if (!props.initialData || props.type === 'polivalente') return ''
    return `Disciplina: ${props.initialData.componente_nome} (${props.initialData.carga_horaria}h)`
})

const componentInfoRaw = computed(() => {
     if (!props.initialData || props.type === 'polivalente') return ''
    return `${props.initialData.componente_nome} • ${props.initialData.carga_horaria}h`
})

// History processing
const historyItems = computed(() => {
    if (!props.initialData || !props.initialData.historico) return []
    // Filter out the active one (which is usually the last one or has specific logic, 
    // but the backend returns all. The 'active' one is already shown in the main card).
    // Based on user JSON, 'is_ativo' is a flag.
    return props.initialData.historico.filter(h => !h.is_ativo).sort((a, b) => new Date(b.data_inicio) - new Date(a.data_inicio))
})

// Fetch Professores
const fetchProfessores = async () => {
    isLoadingProfessores.value = true
    try {
        const { items } = await $fetch(`/api/estrutura_academica/candidatos_tutores`, {
            query: {
                id_empresa: appStore.company.empresa_id,
                limite: 200
            }
        })
        
        professoresOptions.value = (items || []).map(u => ({
            value: u.id,
            label: u.nome_completo
        }))
        
    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao carregar professores', 'error')
    } finally {
        isLoadingProfessores.value = false
    }
}

const resetForm = () => {
    formData.value = {
        id: null,
        id_turma: '',
        id_carga_horaria: '',
        id_professor: '',
        ano: new Date().getFullYear(),
        data_inicio: new Date().toISOString().split('T')[0], // Default today
        data_fim: '',
        motivo_substituicao: '',
        nivel_substituicao: 0
    }
    errorMessage.value = ''
    mode.value = 'create'
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        resetForm()
        fetchProfessores()
        
        if (props.initialData && props.initialData.atribuicao_id) {
            // Existing Attribution -> Manage Mode
            mode.value = 'manage'
            
            // Populate basic data even for Manage mode (used if we switch to Substitute)
            formData.value.id_turma = props.initialData.id_turma
            formData.value.ano = props.initialData.turma_ano
            formData.value.nivel_substituicao = (props.initialData.nivel_substituicao || 0) + 1
            
            if (props.type === 'componentes') {
                formData.value.id_carga_horaria = props.initialData.id_carga_horaria
            }
        } else if (props.initialData) {
             // New Attribution
             mode.value = 'create'
             formData.value.id_turma = props.initialData.id_turma
             formData.value.ano = props.initialData.turma_ano
             if (props.type === 'componentes') {
                formData.value.id_carga_horaria = props.initialData.id_carga_horaria
            }
        }
    }
})

// Helper actions
const startSubstitution = () => {
    mode.value = 'substitute'
    formData.value.id_professor = '' // Clear so user selects new one
    errorMessage.value = ''
}

const handleDelete = () => {
    if (confirm('Tem certeza que deseja remover esta atribuição?')) {
        emit('delete', props.initialData)
        // Parent handles the actual delete call or we do it here? 
        // Component logic says emit('delete').
        emit('close')
    }
}

// Save
const handleSave = async () => {
    errorMessage.value = ''
    
    if (!formData.value.id_professor) {
        errorMessage.value = 'Selecione um professor.'
        return
    }
    if (!formData.value.data_inicio) {
        errorMessage.value = 'Informe a data de início.'
        return
    }
    if (mode.value === 'substitute' && !formData.value.motivo_substituicao) {
        errorMessage.value = 'Informe o motivo da substituição.'
        return
    }

    isSaving.value = true
    try {
        const client = useSupabaseClient() // Use direct client for sequential RPCs? Or BFF? 
        // BFF is easier for consistent headers, but sequential updates are tricky via single endpoint unless batch.
        // We will do sequential requests here for simplicity and explicit control.

        // 1. If Substitute: Close old attribution
        if (mode.value === 'substitute' && props.initialData.atribuicao_id) {
            
            // Validate Data Integrity before sending
            if (!props.initialData.id_professor || !props.initialData.ano) {
                errorMessage.value = 'Dados da atribuição atual incompletos. Atualize a página e tente novamente.'
                isSaving.value = false
                return
            }

            const closePayload = {
                id: props.initialData.atribuicao_id, // Update existing
                id_empresa: appStore.company.empresa_id,
                id_turma: props.initialData.id_turma,
                id_professor: props.initialData.id_professor, // Same prof (Must be present in initialData)
                ano: props.initialData.ano, // Fix: RPC returns 'ano', not 'atribuicao_ano'
                data_inicio: props.initialData.data_inicio, // Original start
                data_fim: formData.value.data_inicio, // Ends when new one starts
                // Keep others same or default
                motivo_substituicao: props.initialData.motivo_substituicao || null,
                nivel_substituicao: props.initialData.nivel_substituicao || 0
            }

            if (props.type === 'componentes') {
                closePayload.id_carga_horaria = props.initialData.id_carga_horaria
            }
             
            // We need to call RPC directly for this specific Update, as BFF might not support partial updates easily without ID.
            // Actually our BFF maps to `atrib_turmas_upsert`. So we can POST with `id`.
            
            await $fetch(`/api/secretaria/${config.value.resource}`, {
                method: 'POST',
                body: {
                    id_empresa: appStore.company.empresa_id,
                    data: closePayload
                }
            })
        }

        // 2. Create New Attribution (Create or Substitute)
        const payload = {
            id: null, // Always new
            id_turma: formData.value.id_turma,
            id_professor: formData.value.id_professor,
            ano: formData.value.ano,
            data_inicio: formData.value.data_inicio,
            data_fim: null,
            motivo_substituicao: mode.value === 'substitute' ? formData.value.motivo_substituicao : null,
            nivel_substituicao: mode.value === 'substitute' ? formData.value.nivel_substituicao : 0
        }
        
        if (props.type === 'componentes') {
            payload.id_carga_horaria = formData.value.id_carga_horaria
        }
        
        const res = await $fetch(`/api/secretaria/${config.value.resource}`, {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload
            }
        })

        if (res && res.success) {
            toast.showToast(mode.value === 'substitute' ? 'Professor substituído com sucesso!' : 'Atribuição realizada!')
            emit('success')
            emit('close')
        } else {
            errorMessage.value = res?.message || 'Erro ao salvar.'
        }
    } catch (err) {
        console.error(err)
        errorMessage.value = err.data?.message || err.message || 'Erro ao salvar.'
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-6">
             <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="emit('close')"></div>
             
             <div class="relative bg-background w-full max-w-2xl flex flex-col rounded-xl shadow-2xl border border-div-15 overflow-hidden transition-all duration-300">
                 
                 <!-- Header -->
                <div class="px-6 py-4 border-b border-div-15 flex items-center justify-between bg-div-15/50">
                    <div>
                        <h2 class="text-xl font-bold text-text flex items-center gap-2">
                             <span v-if="mode === 'manage'">Gerenciar Atribuição</span>
                             <span v-else-if="mode === 'substitute'">Substituir Professor</span>
                             <span v-else>Nova Atribuição</span>
                        </h2>
                        <div class="flex flex-col mt-0.5">
                            <span class="text-xs text-secondary">{{ turmaInfo }}</span>
                            <span v-if="componenteInfo" class="text-xs font-bold text-primary">{{ componentInfoRaw }}</span>
                        </div>
                    </div>
                    <button @click="emit('close')" class="text-secondary hover:text-text transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body: Manage Mode (Current Info) -->
                <div v-if="mode === 'manage'" class="p-8 space-y-8">
                    
                    <!-- Component Info Block (Manage Mode) -->
                    <div v-if="type === 'componentes'" class="bg-div-15 p-4 rounded-lg border border-div-15 flex items-center gap-3">
                        <div class="w-1.5 h-8 rounded-full" :style="{ backgroundColor: initialData?.componente_cor || '#ccc' }"></div>
                        <div>
                            <p class="text-[10px] font-bold text-secondary uppercase tracking-wider">Componente Curricular</p>
                            <p class="text-sm font-bold text-text">{{ initialData?.componente_nome }}</p>
                        </div>
                        <div class="ml-auto">
                            <span class="text-xs font-bold text-secondary bg-background px-2 py-1 rounded border border-div-15">
                                {{ initialData?.carga_horaria }}h
                            </span>
                        </div>
                    </div>

                    <!-- Current Professor Card -->
                    <div class="flex items-start gap-4 p-4 rounded-xl border border-primary/20 bg-primary/5">
                        <div class="w-12 h-12 rounded-full bg-primary text-white flex items-center justify-center text-lg font-bold shrink-0">
                             {{ initialData?.professor_nome ? initialData.professor_nome.charAt(0) : '?' }}
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center gap-2 mb-1">
                                <p class="text-xs font-bold text-primary uppercase tracking-wider">Professor Atual</p>
                                <span 
                                    class="text-[10px] font-black px-1.5 py-0.5 rounded border uppercase tracking-wider"
                                    :class="(initialData?.nivel_substituicao || 0) > 0 
                                        ? 'bg-orange-500/10 text-orange-600 border-orange-500/20' 
                                        : 'bg-blue-500/10 text-blue-600 border-blue-500/20'"
                                >
                                    {{ (initialData?.nivel_substituicao || 0) > 0 ? 'Substituto' : 'Titular' }}
                                </span>
                            </div>
                            <h3 class="text-lg font-bold text-text truncate leading-tight">{{ initialData?.professor_nome }}</h3>
                            <div class="flex items-center gap-4 mt-2 text-xs text-secondary">
                                <span class="flex items-center gap-1">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                                    Início: {{ initialData?.data_inicio ? new Date(initialData.data_inicio).toLocaleDateString() : '-' }}
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- History Timeline -->
                    <div v-if="historyItems.length > 0" class="space-y-3">
                        <h4 class="text-xs font-bold text-secondary uppercase tracking-wider">Histórico de Substituições</h4>
                        <div class="space-y-2">
                             <div v-for="item in historyItems" :key="item.atribuicao_id" class="p-3 rounded border border-div-15 bg-background flex items-start gap-3 opacity-70 hover:opacity-100 transition-opacity">
                                 <div class="w-8 h-8 rounded-full bg-div-15 text-secondary flex items-center justify-center text-xs font-bold shrink-0">
                                     {{ item.professor_nome ? item.professor_nome.charAt(0) : '?' }}
                                 </div>
                                 <div class="flex-1 min-w-0">
                                     <p class="text-sm font-bold text-text truncate leading-tight">{{ item.professor_nome }}</p>
                                     <div class="flex flex-wrap items-center gap-x-3 gap-y-1 mt-1 text-[11px] text-secondary">
                                         <span>De: {{ new Date(item.data_inicio).toLocaleDateString() }}</span>
                                         <span>Até: {{ item.data_fim ? new Date(item.data_fim).toLocaleDateString() : '?' }}</span>
                                         <span v-if="item.motivo_substituicao" class="text-orange-500/80 italic">"{{ item.motivo_substituicao }}"</span>
                                     </div>
                                 </div>
                             </div>
                        </div>
                    </div>

                    <!-- Actions Grid -->
                    <div class="grid grid-cols-2 gap-4">
                        <button 
                            @click="startSubstitution"
                            class="flex flex-col items-center justify-center gap-3 p-6 rounded-xl border border-div-15 bg-surface hover:border-primary/50 hover:bg-primary/5 hover:text-primary transition-all group"
                        >
                            <div class="w-10 h-10 rounded-full bg-div-15 group-hover:bg-primary group-hover:text-white flex items-center justify-center transition-colors text-secondary">
                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><polyline points="17 11 19 13 23 9"></polyline></svg>
                            </div>
                            <span class="font-bold text-sm">Substituir Professor</span>
                        </button>

                        <button 
                            @click="handleDelete"
                            class="flex flex-col items-center justify-center gap-3 p-6 rounded-xl border border-div-15 bg-surface hover:border-red-500/50 hover:bg-red-500/5 hover:text-red-500 transition-all group"
                        >
                            <div class="w-10 h-10 rounded-full bg-div-15 group-hover:bg-red-500 group-hover:text-white flex items-center justify-center transition-colors text-secondary">
                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                            </div>
                            <span class="font-bold text-sm">Remover Atribuição</span>
                        </button>
                    </div>

                </div>

                <!-- Body: Form (Create or Substitute) -->
                <div v-else class="p-6 space-y-6 flex-1 overflow-y-auto max-h-[70vh]">
                    <div v-if="errorMessage" class="p-3 rounded bg-red-500/5 text-red-500 text-xs text-center border border-red-500/10">{{ errorMessage }}</div>

                    <!-- Info Header -->
                    <div class="bg-div-15 p-4 rounded-lg border border-div-15 space-y-3">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-[10px] font-bold text-secondary uppercase tracking-wider">Ano Letivo</p>
                                <p class="text-sm font-bold text-text">{{ formData.ano }}</p>
                            </div>
                            <div class="text-right">
                                <p class="text-[10px] font-bold text-secondary uppercase tracking-wider">Turma</p>
                                <p class="text-sm font-bold text-text">{{ initialData?.classe_nome }}</p>
                            </div>
                        </div>
                        
                        <div v-if="type === 'componentes'" class="pt-3 border-t border-secondary/10 flex items-center gap-3">
                            <div class="w-1.5 h-8 rounded-full" :style="{ backgroundColor: initialData?.componente_cor || '#ccc' }"></div>
                            <div>
                                <p class="text-[10px] font-bold text-secondary uppercase tracking-wider">Componente Curricular</p>
                                <p class="text-sm font-bold text-text">{{ initialData?.componente_nome }}</p>
                            </div>
                            <div class="ml-auto">
                                <span class="text-xs font-bold text-secondary bg-background px-2 py-1 rounded border border-div-15">
                                    {{ initialData?.carga_horaria }}h
                                </span>
                            </div>
                        </div>
                    </div>
                    
                    <div v-if="mode === 'substitute'" class="p-3 bg-yellow-500/10 text-yellow-600 border border-yellow-500/20 rounded text-xs flex items-start gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 mt-0.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                        <span>
                            Você está substituindo <strong>{{ initialData?.professor_nome }}</strong>. 
                            A atribuição atual será encerrada automaticamente.
                        </span>
                    </div>

                    <!-- Professor Select (Full Width) -->
                    <ManagerField 
                        v-model="formData.id_professor"
                        :label="mode === 'substitute' ? 'Novo Professor' : 'Professor'"
                        type="select"
                        :options="professoresOptions"
                        :disabled="isLoadingProfessores"
                        required
                        placeholder="Selecione..."
                    />

                    <!-- Data Início (Full Width) -->
                    <ManagerField 
                        v-model="formData.data_inicio"
                        label="Data Início"
                        type="date"
                        required
                    />

                    <!-- Motivo: Only if Substitute -->
                    <ManagerField 
                        v-if="mode === 'substitute'"
                        v-model="formData.motivo_substituicao"
                        label="Motivo da Substituição"
                        type="textarea"
                        placeholder="Justifique a troca de professor..."
                        required
                    />
                </div>

                 <!-- Footer -->
                <div v-if="mode !== 'manage'" class="px-6 py-4 border-t border-div-15 flex items-center justify-end gap-3 bg-div-15/50">
                    <button 
                        @click="mode === 'substitute' ? mode = 'manage' : emit('close')" 
                        class="px-5 py-2.5 rounded text-secondary font-semibold text-sm hover:bg-div-30 transition-colors"
                    >
                        Cancelar
                    </button>
                    <button 
                        @click="handleSave" 
                        :disabled="isSaving" 
                        class="px-8 py-2.5 rounded bg-primary text-white font-bold text-sm hover:brightness-110 shadow-lg shadow-primary/20 transition-all flex items-center gap-2"
                    >
                         <svg v-if="isSaving" class="animate-spin w-4 h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                         {{ isSaving ? 'Salvando...' : (mode === 'substitute' ? 'Confirmar Substituição' : 'Salvar Atribuição') }}
                    </button>
                </div>

             </div>
        </div>
    </Teleport>
</template>

