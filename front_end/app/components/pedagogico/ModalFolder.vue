<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'
import LoadingOverlay from '@/components/LoadingOverlay.vue'

const props = defineProps<{
    isOpen: boolean
    initialData?: any
}>()

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

// State
// State
const isSaving = ref(false)
const errorMessage = ref('')
const turmas = ref<any[]>([])
const anoEtapas = ref<any[]>([])
const componentes = ref<any[]>([])
const alunoResults = ref<any[]>([])
const alunoSearchTerm = ref('')
let turmaSearchTimer: any

const scopeOptions = [
    { value: 'Global', label: 'Global' },
    { value: 'AnoEtapa', label: 'Ano/Etapa' },
    { value: 'Turma', label: 'Turma' },
    { value: 'Grupo', label: 'Grupo' },
    { value: 'Componente', label: 'Componente' },
    { value: 'Aluno', label: 'Aluno' }
]

// Form Data
const form = ref({
    titulo: '',
    descricao: '',
    escopo: 'Global',
    id_turma: '',
    id_ano_etapa: '',
    id_componente: '',
    id_aluno: '',

    data_disponivel: '',
    liberar_por: 'Conteúdo',
    visivel_para_alunos: true
})

// Fetch Turmas
const fetchTurmas = async (idAnoEtapa?: string) => {
    try {
        const params: any = {
            id_empresa: appStore.company?.empresa_id,
            limite: 100
        }
        if (idAnoEtapa) params.id_ano_etapa = idAnoEtapa

        const result = await $fetch(`/api/estrutura_academica/turmas`, { params }) as any
        
        let items = result.items || []
        // Client-side filter fallback if API ignores it (safe bet)
        if (idAnoEtapa && items.length > 0) {
             items = items.filter((t: any) => t.id_ano_etapa === idAnoEtapa)
        }
        turmas.value = items
    } catch (e) {
        console.error('Erro ao buscar turmas', e)
    }
}

// Fetch AnoEtapas
const fetchAnoEtapas = async () => {
    if (anoEtapas.value.length > 0) return
    try {
        const result = await $fetch(`/api/estrutura_academica/ano_etapa`, {
            params: {
                id_empresa: appStore.company?.empresa_id,
                limite: 100
            }
        }) as any
        anoEtapas.value = result.items || []
    } catch (e) {
        console.error('Erro ao buscar ano/etapa', e)
    }
}

// Search Alunos
let searchTimer: any
const handleSearchAluno = async (term: string) => {
    if (!term || term.length < 3) return
    
    try {
        const result = await $fetch(`/api/usuarios/alunos`, {
            params: {
                id_empresa: appStore.company?.empresa_id,
                limite: 20,
                busca: term
            }
        }) as any
        
        if (result && result.items) {
             alunoResults.value = result.items.map((a: any) => ({
                 value: a.user_expandido_id,
                 label: a.nome_completo
            }))
        }
    } catch (e) {
        console.error('Erro ao buscar alunos', e)
    }
}

const onAlunoSearch = (val: string) => {
   alunoSearchTerm.value = val
   clearTimeout(searchTimer)
   searchTimer = setTimeout(() => handleSearchAluno(val), 500)
}

const selectAluno = (a: any) => {
    form.value.id_aluno = a.value
    alunoSearchTerm.value = a.label
    alunoResults.value = []
}

const clearAlunoSelection = () => {
    form.value.id_aluno = ''
    alunoSearchTerm.value = ''
    alunoResults.value = []
}

// Watchers
watch(() => form.value.escopo, async (newVal, oldVal) => {
    // Reset dependant fields if manually changed (not initial load)
    if (oldVal && props.isOpen) {
        form.value.id_turma = ''
        form.value.id_ano_etapa = ''
        form.value.id_aluno = ''
        alunoSearchTerm.value = ''
        alunoResults.value = []
    }
    
    if (['AnoEtapa', 'Turma', 'Componente', 'Aluno'].includes(newVal)) {
        fetchAnoEtapas()
    }
})

// Cascade: AnoEtapa -> Turma / Componente
watch(() => form.value.id_ano_etapa, async (newVal) => {
    if (!props.isOpen) return
    
    // Reset dependant fields
    form.value.id_turma = ''
    form.value.id_componente = ''
    form.value.id_aluno = ''
    
    if (newVal) {
        if (['Turma', 'Componente', 'Aluno'].includes(form.value.escopo)) {
            fetchTurmas(newVal)
        }
        if (form.value.escopo === 'Componente') {
            fetchComponentes(newVal)
        }
    }
})

// Fetch Componentes (via BFF)
const fetchComponentes = async (idAnoEtapa: string) => {
    if (!idAnoEtapa) return
    try {
        const result = await $fetch('/api/pedagogico/atividades/componentes', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                id_ano_etapa: idAnoEtapa
            }
        }) as any
        
        componentes.value = (result.items || []).map((ch: any) => ({
             value: ch.id, 
             label: ch.nome,
             cor: ch.cor
        }))
    } catch (e) {
        console.error('Erro ao buscar componentes:', e)
    }
}

watch(() => props.isOpen, async (val) => {
    if (val) {
        errorMessage.value = ''
        if (props.initialData) {
            form.value = {
                titulo: props.initialData.titulo,
                descricao: props.initialData.descricao || '',
                escopo: props.initialData.escopo || 'Global',
                id_turma: props.initialData.id_turma || '',
                id_ano_etapa: props.initialData.id_ano_etapa || '',
                id_componente: props.initialData.id_componente || '',
                id_aluno: props.initialData.id_aluno || '',
                data_disponivel: props.initialData.data_disponivel ? new Date(props.initialData.data_disponivel).toISOString().slice(0, 16) : '',
                liberar_por: props.initialData.liberar_por || 'Conteúdo',
                visivel_para_alunos: props.initialData.visivel_para_alunos ?? true
            }
            if (props.initialData.nome_aluno) {
                alunoSearchTerm.value = props.initialData.nome_aluno
            }
             // Fetch required data based on initial scope
            if (['AnoEtapa', 'Turma', 'Componente', 'Aluno'].includes(form.value.escopo)) await fetchAnoEtapas()
            if (form.value.id_ano_etapa) {
                 await fetchTurmas(form.value.id_ano_etapa)
                 if (form.value.escopo === 'Componente') await fetchComponentes(form.value.id_ano_etapa)
            }
        } else {
             // Defaults
             form.value = {
                titulo: '',
                descricao: '',
                escopo: 'Global',
                id_turma: '',
                id_ano_etapa: '',
                id_componente: '',
                id_aluno: '',
                data_disponivel: '',
                liberar_por: 'Conteúdo',
                visivel_para_alunos: true
            }
            alunoSearchTerm.value = ''
        }
    }
})

// Save
const handleSave = async () => {
    errorMessage.value = ''
    
    if (!form.value.titulo) {
        errorMessage.value = 'O título é obrigatório.'
        return
    }
    if (form.value.escopo === 'Turma' && !form.value.id_turma) {
        errorMessage.value = 'Selecione uma turma.'
        return
    }
    if (form.value.escopo === 'Aluno' && !form.value.id_aluno) {
        errorMessage.value = 'Selecione um aluno.'
        return
    }

    isSaving.value = true
    try {
        await $fetch('/api/pedagogico/atividades/upsert', {
            method: 'POST',
            body: {
                id: props.initialData?.id,
                id_empresa: appStore.company?.empresa_id,
                ...form.value
            }
        })
        
        toast.showToast('Folder salvo com sucesso!', 'success')
        emit('success')
        emit('close')
    } catch (e: any) {
        errorMessage.value = e.statusMessage || e.message || 'Erro ao salvar.'
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" @click.self="emit('close')">
        <div class="bg-background w-full max-w-lg rounded shadow-2xl border border-[#6B82A71A] overflow-hidden flex flex-col max-h-[90vh]">
            
            <!-- Header -->
            <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between shrink-0 bg-div-15">
                <div class="flex items-center gap-4">
                    <div class="w-10 h-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center text-xl font-bold shadow-sm">
                        📁
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-text">{{ initialData ? 'Editar Folder' : 'Novo Folder' }}</h2>
                        <p class="text-xs text-secondary font-medium mt-0.5">Conteúdo Pedagógico</p>
                    </div>
                </div>
                <button @click="emit('close')" class="p-2 text-secondary hover:text-danger hover:bg-danger/10 rounded-lg transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Body -->
            <div class="p-6 flex flex-col gap-5 overflow-y-auto">
                 <div v-if="errorMessage" class="p-3 rounded-lg bg-danger/10 border border-danger/20 text-danger text-xs font-bold flex items-center gap-2">
                    <span>⚠️</span> {{ errorMessage }}
                </div>

                <!-- 1. Scope and Hierarchy -->
                <ManagerField 
                    label="Escopo"
                    v-model="form.escopo"
                    type="select"
                    :options="scopeOptions"
                    placeholder="Selecione o escopo..."
                />

                <!-- Dynamic Fields -->
                
                <!-- 1. Ano/Etapa: Visible for AnoEtapa, Turma, Componente, Aluno -->
                <div v-if="['AnoEtapa', 'Turma', 'Componente', 'Aluno'].includes(form.escopo)" class="animate-in slide-in-from-top-2 duration-200">
                     <ManagerField 
                        label="Ano / Etapa"
                        v-model="form.id_ano_etapa"
                        type="select"
                        :options="anoEtapas.map(a => ({ value: a.id, label: a.nome }))"
                        placeholder="Selecione o ano/etapa..."
                     />
                </div>

                <!-- 2. Turma: Visible for Turma, Componente, Aluno -->
                <div v-if="['Turma', 'Componente', 'Aluno'].includes(form.escopo)" class="animate-in slide-in-from-top-2 duration-200">
                     <ManagerField 
                        label="Turma"
                        v-model="form.id_turma"
                        type="select"
                        :options="turmas.map(t => ({ value: t.id, label: `${t.nome_turma || t.ano} - ${t.periodo || ''}` }))"
                        placeholder="Selecione a turma..."
                        :disabled="!form.id_ano_etapa"
                     />
                </div>

                <!-- 3. Componente: Visible for Componente -->
                <div v-if="form.escopo === 'Componente'" class="animate-in slide-in-from-top-2 duration-200">
                     <ManagerField 
                        label="Componente Curricular"
                        v-model="form.id_componente"
                        type="select"
                        :options="componentes"
                        placeholder="Selecione o componente..."
                        :disabled="!form.id_ano_etapa"
                     />
                </div>

                <!-- 4. Grupo: Placeholder -->
                <div v-if="form.escopo === 'Grupo'" class="p-4 bg-div-05 rounded border border-div-15 text-center text-xs text-secondary italic animate-in slide-in-from-top-2 duration-200">
                    🚧 Funcionalidade de Grupos em desenvolvimento.
                </div>

                <!-- 5. Aluno: Visible for Aluno -->
                <div v-if="form.escopo === 'Aluno'" class="animate-in slide-in-from-top-2 duration-200 relative">
                     <ManagerField label="Aluno" type="custom">
                        <input 
                            type="text" 
                            :value="alunoSearchTerm"
                            @input="(e) => onAlunoSearch((e.target as HTMLInputElement).value)"
                            placeholder="Buscar aluno por nome..." 
                            class="w-full px-4 py-2.5 bg-background border border-div-15 rounded text-sm text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 transition-all"
                            :disabled="!form.id_turma"
                        >
                        <!-- Aluno Results -->
                        <div v-if="alunoResults.length > 0 && !form.id_aluno" class="absolute left-0 top-full z-10 w-full mt-1 bg-surface border border-div-15 rounded shadow-xl max-h-48 overflow-y-auto">
                            <div 
                                v-for="aluno in alunoResults" 
                                :key="aluno.value" 
                                @click="selectAluno(aluno)"
                                class="p-3 text-xs font-bold hover:bg-primary/10 hover:text-primary cursor-pointer border-b border-div-15 last:border-0"
                            >
                                {{ aluno.label }}
                            </div>
                        </div>
                        <div v-if="form.id_aluno" class="mt-2 flex items-center gap-2 text-xs font-bold text-primary bg-primary/10 px-3 py-1.5 rounded border border-primary/20 w-fit">
                            <span>{{ alunoSearchTerm }}</span>
                            <button @click="clearAlunoSelection" class="hover:text-red-500"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                        </div>
                    </ManagerField>
                </div>

                <!-- 2. Content Details -->
                <div class="h-px bg-div-15 w-full my-1"></div>

                <ManagerField 
                    label="Título"
                    v-model="form.titulo"
                    placeholder="Ex: Material de Apoio - Matemática"
                />

                <ManagerField 
                    label="Descrição"
                    v-model="form.descricao"
                    type="textarea"
                    placeholder="Breve descrição do conteúdo..."
                />

                 <!-- 3. Settings -->
                 <div class="h-px bg-div-15 w-full my-1"></div>

                 <!-- 3. Settings -->
                 <div class="h-px bg-div-15 w-full my-1"></div>

                 <!-- Date -->
                <ManagerField 
                    label="Disponível a partir de"
                    v-model="form.data_disponivel"
                    type="datetime-local"
                />
                
                <!-- Toggles -->
                 <div class="flex flex-col gap-2">
                    <label class="text-xs font-bold text-secondary">Configurações</label>
                    <div class="flex flex-col gap-3 p-3 border border-div-15 rounded bg-background">
                        <!-- Liberar Por Toggle -->
                        <div class="flex items-center justify-between">
                            <span class="text-sm font-medium text-text">Liberar por Conteúdo</span>
                            <input 
                                type="checkbox" 
                                class="toggle toggle-primary toggle-sm"
                                :checked="form.liberar_por === 'Conteúdo'"
                                @change="(e) => form.liberar_por = (e.target as HTMLInputElement).checked ? 'Conteúdo' : 'Data'"
                            />
                        </div>
                         <!-- Visivel Toggle -->
                        <div class="flex items-center justify-between">
                            <span class="text-sm font-medium text-text">Visível para Alunos</span>
                            <input 
                                type="checkbox" 
                                class="toggle toggle-primary toggle-sm" 
                                v-model="form.visivel_para_alunos"
                            />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <div class="px-6 py-4 border-t border-[#6B82A71A] bg-div-15 flex justify-end gap-3 shrink-0">
                <button @click="emit('close')" class="px-6 py-2.5 rounded hover:bg-div-30 transition-colors text-sm font-bold text-secondary">Cancelar</button>
                <button @click="handleSave" class="px-6 py-2.5 rounded bg-primary text-white font-bold hover:brightness-110 shadow-lg shadow-primary/20 transition-all text-sm flex items-center gap-2">
                    <span>Salvar Folder</span>
                </button>
            </div>
        </div>
    </div>
</template>
