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
const alunoResults = ref<any[]>([])
const alunoSearchTerm = ref('')
let turmaSearchTimer: any

const scopeOptions = [
    { value: 'Global', label: 'Global (Toda a Escola)' },
    { value: 'Turma', label: 'Por Turma' },
    { value: 'AnoEtapa', label: 'Por Ano/Etapa' },
    { value: 'Aluno', label: 'Aluno Específico' }
]

// Form Data
const form = ref({
    titulo: '',
    descricao: '',
    escopo: 'Global',
    id_turma: '',
    id_ano_etapa: '',
    id_aluno: '',
    data_referencia: new Date().toISOString().split('T')[0],
    visivel_para_alunos: true
})

// Fetch Turmas
const fetchTurmas = async () => {
    if (turmas.value.length > 0) return
    try {
        const result = await $fetch(`/api/estrutura_academica/turmas`, {
            params: {
                id_empresa: appStore.company?.empresa_id,
                limite: 100
            }
        }) as any
        turmas.value = result.items || []
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
    
    if (newVal === 'Turma') fetchTurmas()
    if (newVal === 'AnoEtapa') fetchAnoEtapas()
})

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
                id_aluno: props.initialData.id_aluno || '',
                data_referencia: props.initialData.data_referencia?.split('T')[0] || new Date().toISOString().split('T')[0],
                visivel_para_alunos: props.initialData.visivel_para_alunos
            }
            if (props.initialData.nome_aluno) {
                alunoSearchTerm.value = props.initialData.nome_aluno
            }
             // Fetch required data based on initial scope
            if (form.value.escopo === 'Turma') fetchTurmas()
            if (form.value.escopo === 'AnoEtapa') fetchAnoEtapas()
        } else {
             // Defaults
             form.value = {
                titulo: '',
                descricao: '',
                escopo: 'Global',
                id_turma: '',
                id_ano_etapa: '',
                id_aluno: '',
                data_referencia: new Date().toISOString().split('T')[0],
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
        <div class="bg-surface w-full max-w-2xl rounded-2xl shadow-xl border border-div-15 overflow-hidden flex flex-col max-h-[90vh]">
            
            <!-- Header -->
            <div class="p-6 border-b border-div-15 flex items-center justify-between shrink-0 bg-div-05/30">
                <div class="flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-violet-500/10 text-violet-500 flex items-center justify-center text-xl font-bold shadow-sm">
                        📁
                    </div>
                    <div>
                        <h2 class="text-lg font-black text-text">{{ initialData ? 'Editar Folder' : 'Novo Folder' }}</h2>
                        <p class="text-xs text-secondary font-medium mt-0.5">Organize o conteúdo pedagógico (BETA)</p>
                    </div>
                </div>
                <button @click="emit('close')" class="p-2 text-secondary hover:text-danger hover:bg-danger/10 rounded-lg transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Body -->
            <div class="p-6 overflow-y-auto space-y-6 relative">
                 <div v-if="errorMessage" class="p-3 rounded-lg bg-danger/10 border border-danger/20 text-danger text-xs font-bold flex items-center gap-2">
                    <span>⚠️</span> {{ errorMessage }}
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Left Column -->
                    <div class="space-y-4">
                        <ManagerField label="Identificação do Folder">
                            <input v-model="form.titulo" type="text" placeholder="Ex: Aula de História - Revolução Francesa" class="w-full bg-background border border-div-15 rounded-xl px-4 py-2.5 text-sm font-bold text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 transition-all placeholder:font-normal">
                        </ManagerField>

                         <ManagerField label="Descrição (Opcional)">
                            <textarea v-model="form.descricao" rows="4" placeholder="Breve resumo sobre o conteúdo..." class="w-full bg-background border border-div-15 rounded-xl px-4 py-2.5 text-sm text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 transition-all resize-none"></textarea>
                        </ManagerField>
                    </div>

                    <!-- Right Column -->
                    <div class="space-y-4">


                        <!-- Scope Selection -->
                        <div class="col-span-12">
                             <ManagerField 
                                label="Escopo de Visibilidade"
                                v-model="form.escopo"
                                type="select"
                                :options="scopeOptions"
                                required
                             />
                        </div>

                        <!-- Conditional Scope Fields -->
                        
                        <!-- 1. Turma: Select -->
                        <div v-if="form.escopo === 'Turma'" class="col-span-12 animate-in slide-in-from-top-2 duration-200">
                             <ManagerField 
                                label="Selecionar Turma"
                                v-model="form.id_turma"
                                type="select"
                                :options="turmas.map(t => ({ value: t.id, label: `${t.nome_turma || t.ano} - ${t.periodo || ''}` }))"
                                placeholder="Escolha uma turma..."
                             />
                        </div>

                        <!-- 2. Ano Etapa: Select -->
                        <div v-if="form.escopo === 'AnoEtapa'" class="col-span-12 animate-in slide-in-from-top-2 duration-200">
                             <ManagerField 
                                label="Selecionar Ano/Etapa"
                                v-model="form.id_ano_etapa"
                                type="select"
                                :options="anoEtapas.map(a => ({ value: a.id, label: a.nome }))"
                                placeholder="Escolha um ano/etapa..."
                             />
                        </div>
                        
                        <!-- 3. Aluno: Search Input -->
                        <div v-if="form.escopo === 'Aluno'" class="col-span-12 animate-in slide-in-from-top-2 duration-200 relative">
                             <ManagerField label="Buscar Aluno" type="custom">
                                <input 
                                    type="text" 
                                    :value="alunoSearchTerm"
                                    @input="(e) => onAlunoSearch((e.target as HTMLInputElement).value)"
                                    placeholder="Digite o nome do aluno..." 
                                    class="w-full px-4 py-2.5 bg-background border border-div-15 rounded-lg text-sm text-text focus:outline-none focus:border-primary focus:ring-4 focus:ring-primary/5 transition-all"
                                >
                                <!-- Aluno Results -->
                                <div v-if="alunoResults.length > 0 && !form.id_aluno" class="absolute left-0 top-full z-10 w-full mt-1 bg-surface border border-div-15 rounded-lg shadow-xl max-h-48 overflow-y-auto">
                                    <div 
                                        v-for="aluno in alunoResults" 
                                        :key="aluno.value" 
                                        @click="selectAluno(aluno)"
                                        class="p-3 text-xs font-bold hover:bg-primary/10 hover:text-primary cursor-pointer border-b border-div-15 last:border-0"
                                    >
                                        {{ aluno.label }}
                                    </div>
                                </div>
                                <div v-if="form.id_aluno" class="mt-2 flex items-center gap-2 text-xs font-bold text-primary bg-primary/10 px-3 py-1.5 rounded-lg border border-primary/20 w-fit">
                                    <span>Aluno selecionado</span>
                                    <button @click="clearAlunoSelection" class="hover:text-red-500"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                                </div>
                            </ManagerField>
                        </div>
                        
                        <!-- 4. Global Info -->
                         <div v-if="form.escopo === 'Global'" class="col-span-12 animate-in slide-in-from-top-2 duration-200">
                            <div class="bg-emerald-500/10 border border-emerald-500/20 p-3 rounded-lg flex items-start gap-3">
                                <div class="p-1 bg-emerald-500/20 rounded text-emerald-600 shrink-0">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg>
                                </div>
                                <div>
                                    <h4 class="text-xs font-bold text-emerald-600 uppercase tracking-wide mb-1">Visibilidade Global</h4>
                                    <p class="text-[11px] text-emerald-600/80 leading-relaxed">Este conteúdo ficará visível para <b>toda a escola</b>.</p>
                                </div>
                            </div>
                        </div>
                        
                         <div class="pt-2 flex items-center gap-4">
                            <ManagerField label="Data de Referência" class="flex-1">
                                <input v-model="form.data_referencia" type="date" class="w-full bg-background border border-div-15 rounded-xl px-4 py-2.5 text-sm font-bold text-text focus:outline-none focus:border-primary transition-all">
                            </ManagerField>
                            <div class="flex flex-col items-center justify-center pt-6">
                                <label class="relative inline-flex items-center cursor-pointer">
                                    <input type="checkbox" v-model="form.visivel_para_alunos" class="sr-only peer">
                                    <div class="w-10 h-6 bg-div-30 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                                </label>
                                <span class="text-[9px] font-black text-secondary uppercase tracking-tighter mt-1">{{ form.visivel_para_alunos ? 'Visível' : 'Oculto' }}</span>
                             </div>
                        </div>
                    </div>
                </div>

                <LoadingOverlay v-if="isSaving" text="Salvando..." />
            </div>

            <!-- Footer -->
            <div class="p-4 border-t border-div-15 bg-div-05/30 flex justify-end gap-3 shrink-0">
                <button @click="emit('close')" class="px-6 py-2.5 rounded-xl font-bold text-secondary hover:bg-div-15 transition-colors text-sm">Cancelar</button>
                <button @click="handleSave" class="px-6 py-2.5 rounded-xl bg-primary text-white font-bold hover:bg-primary-hover shadow-lg shadow-primary/20 transition-all text-sm flex items-center gap-2">
                    <span>Salvar Folder</span>
                </button>
            </div>
        </div>
    </div>
</template>
