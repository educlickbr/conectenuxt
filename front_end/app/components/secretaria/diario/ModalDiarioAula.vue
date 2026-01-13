<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps<{
    isOpen: boolean
    initialData?: any
    initialFilters?: any // Pass current page filters to pre-fill
}>()

const emit = defineEmits(['close', 'success'])

const appStore = useAppStore()
const toast = useToastStore()
const config = useRuntimeConfig()

const today = new Date().toISOString().split('T')[0]

const form = ref({
    // Context
    id_escola: null as string | null,
    id_ano_etapa: null as string | null,
    id_turma: null as string | null,
    id_componente: null as string | null,
    
    // Data
    data: today,
    conteudo: '',
    metodologia: '',
    tarefa_casa: '',
    
    // Hidden
    id: null as string | null
})

// --- Dropdown States ---
const escolas = ref<any[]>([])
const anosEtapas = ref<any[]>([])
const turmas = ref<any[]>([])
const componentes = ref<any[]>([])

const isLoadingComponents = ref(false)
const isSaving = ref(false)

// --- Fetchers ---

// --- Fetchers ---

const fetchEscolas = async () => {
    // Replicating MatrizFilterBar logic using client directly
    try {
        const client = useSupabaseClient()
        const { data, error } = await client
            .from('escolas')
            .select('id, nome')
            .eq('id_empresa', appStore.company?.empresa_id)
            .order('nome')
        
        if (error) throw error
        escolas.value = data || []
    } catch (e) {
        console.error(e)
    }
}

const fetchAnosEtapas = async () => {
     try {
        const { data }: any = await useFetch('/api/estrutura_academica/ano_etapa', {
            params: { id_empresa: appStore.company?.empresa_id, limite: 100 }
        })
        anosEtapas.value = data.value?.items || []
    } catch (e) {
        console.error(e)
    }
}

const fetchTurmas = async () => {
    if (!form.value.id_escola && !form.value.id_ano_etapa) { // loosened condition slightly to allow searching by partial filter if needed, matching MatrizFilterBar behavior
        turmas.value = []
        return
    }
    
    try {
         // Using turmas_simple for consistency if available, or 'turmas' resource. 
         // 'turmas' works based on previous tests.
         const { data }: any = await useFetch('/api/estrutura_academica/turmas', {
            params: { 
                id_empresa: appStore.company?.empresa_id, 
                id_escola: form.value.id_escola,
                id_ano_etapa: form.value.id_ano_etapa,
                limite: 100 
            }
        })
        turmas.value = data.value?.items || []
    } catch (e) {
        console.error(e)
    }
}

const fetchComponentes = async () => {
    // User requested to use the /componentes endpoint, but it's failing.
    // Switching to direct client fetch like Escolas.
    isLoadingComponents.value = true
    try {
        const client = useSupabaseClient()
        const { data, error } = await client
            .from('componente')
            .select('uuid, nome')
            .eq('id_empresa', appStore.company?.empresa_id)
            .order('nome')

        if (error) throw error
        componentes.value = data || []

    } catch (e) {
        console.error('Error fetching componentes:', e)
    } finally {
        isLoadingComponents.value = false
    }
}

// --- Watchers for Cascading ---

watch(() => form.value.id_escola, () => {
    // When school changes, clear Turma but keep Year/Stage if possible? 
    // Usually Year/Stage is independent of School in this model (Network level).
    // So just re-fetch Turmas.
    if (!props.initialData) { // prevent clear on init
        form.value.id_turma = null
        fetchTurmas()
    }
})

watch(() => form.value.id_ano_etapa, () => {
   if (!props.initialData) {
        form.value.id_turma = null
        fetchTurmas()
   }
})

watch(() => form.value.id_turma, () => {
    // If we were filtering components by turma, we would fetch here.
    // But now we fetch generic components on mount.
    // if (!props.initialData) {
    //    form.value.id_componente = null
    // }
})

// --- Init ---

onMounted(async () => {
    await Promise.all([fetchEscolas(), fetchAnosEtapas(), fetchComponentes()])

    if (props.initialData) {
        // Editing mode: Populate form
        const d = props.initialData
        form.value.id = d.id
        form.value.data = d.data.split('T')[0]
        form.value.conteudo = d.conteudo
        form.value.metodologia = d.metodologia
        form.value.tarefa_casa = d.tarefa_casa
        form.value.id_escola = d.id_escola // Assumes join returned this or we infer it
        form.value.id_ano_etapa = d.id_ano_etapa // Same
        form.value.id_turma = d.id_turma
        
        // Trigger cascading fetches manually in order
        await fetchTurmas()
        await fetchComponentes()
        
        form.value.id_componente = d.id_componente
    } else if (props.initialFilters) {
        // Pre-fill from filters if creating new
        const f = props.initialFilters
        if (f.escola_id) form.value.id_escola = f.escola_id
        if (f.ano_etapa_id) form.value.id_ano_etapa = f.ano_etapa_id
        
        // Wait for cascading then set Turma
        setTimeout(async () => {
            if (f.turma_id) {
                await fetchTurmas()
                form.value.id_turma = f.turma_id
                
                await fetchComponentes()
            }
        }, 100)
    }
})


const handleSave = async () => {
    if (!form.value.id_turma || !form.value.data || !form.value.conteudo) {
        toast.showToast('Preencha os campos obrigatórios (Turma, Data, Conteúdo).', 'error')
        return
    }

    isSaving.value = true
    try {
        const { error } = await useFetch('/api/estrutura_academica/diario_aulas', {
            method: 'POST',
            body: {
                id_empresa: appStore.company?.empresa_id,
                data: {
                    id: form.value.id,
                    id_turma: form.value.id_turma,
                    id_componente: form.value.id_componente,
                    data: form.value.data,
                    conteudo: form.value.conteudo,
                    metodologia: form.value.metodologia,
                    tarefa_casa: form.value.tarefa_casa,
                    id_usuario: appStore.user?.id
                }
            }
        })

        if (error.value) throw error.value

        toast.showToast('Registro de aula salvo!', 'success')
        emit('success')
        emit('close')

    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao salvar aula.', 'error')
    } finally {
        isSaving.value = false
    }
}

</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-[200] flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-text/20 backdrop-blur-sm" @click="$emit('close')"></div>
        
        <div class="relative w-full max-w-3xl bg-surface rounded-xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
            
            <!-- Header -->
            <div class="px-6 py-4 border-b border-div-15 flex items-center justify-between bg-surface sticky top-0 z-10">
                <h3 class="font-bold text-lg text-text">
                    {{ form.id ? 'Editar Aula' : 'Nova Aula' }}
                </h3>
                <button @click="$emit('close')" class="p-2 hover:bg-div-15 rounded-full transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-secondary"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Body (Scrollable) -->
            <div class="p-6 overflow-y-auto custom-scrollbar">
                
                <!-- 1. Context Selection -->
                 <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-6">
                     
                     <ManagerField 
                        label="Escola" 
                        type="select" 
                        :model-value="form.id_escola ?? undefined"
                        @update:modelValue="form.id_escola = $event"
                        :disabled="!!initialData"
                    >
                         <option :value="null" disabled>Selecione...</option>
                         <option v-for="e in escolas" :key="e.id" :value="e.id">{{ e.nome }}</option>
                    </ManagerField>

                     <ManagerField 
                        label="Ano/Etapa" 
                        type="select" 
                        :model-value="form.id_ano_etapa ?? undefined"
                        @update:modelValue="form.id_ano_etapa = $event"
                        :disabled="!!initialData"
                    >
                         <option :value="null" disabled>Selecione...</option>
                         <option v-for="a in anosEtapas" :key="a.id" :value="a.id">{{ a.nome }}</option>
                    </ManagerField>

                     <ManagerField 
                        label="Turma" 
                        type="select" 
                        :model-value="form.id_turma ?? undefined"
                        @update:modelValue="form.id_turma = $event"
                        :disabled="!form.id_escola || !form.id_ano_etapa || !!initialData"
                    >
                         <option :value="null" disabled>Selecione a turma...</option>
                         <option v-for="t in turmas" :key="t.id" :value="t.id">{{ t.nome_turma }}</option>
                    </ManagerField>

                 </div>

                 <!-- 2. Class Details -->
                 <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                     <ManagerField 
                        label="Data" 
                        type="date" 
                        v-model="form.data"
                    />

                    <ManagerField 
                        label="Componente (Disciplina)" 
                        type="select" 
                        :model-value="form.id_componente ?? undefined"
                        @update:modelValue="form.id_componente = $event"
                        :disabled="!form.id_turma"
                    >
                         <option :value="null">Geral / Não se aplica</option>
                         <option v-for="c in componentes" :key="c.uuid || c.id" :value="c.uuid || c.id">{{ c.nome }}</option>
                    </ManagerField>
                 </div>

                 <div class="space-y-4">
                     <ManagerField 
                        label="Conteúdo Ministrado" 
                        type="textarea" 
                        v-model="form.conteudo"
                        placeholder="Descreva o que foi ensinado na aula..."
                        rows="4"
                    />
                    
                    <button 
                        v-if="!form.metodologia && !form.tarefa_casa" 
                        @click="form.metodologia = ' '; form.tarefa_casa = ' '"
                        class="text-xs text-primary font-bold hover:underline"
                    >
                        + Adicionar Metodologia e Tarefa de Casa
                    </button>

                     <div v-if="form.metodologia || form.tarefa_casa" class="grid grid-cols-1 gap-4">
                        <ManagerField 
                            label="Metodologia (Opcional)" 
                            type="textarea" 
                            v-model="form.metodologia"
                            rows="2"
                        />
                         <ManagerField 
                            label="Tarefa de Casa (Opcional)" 
                            type="textarea" 
                            v-model="form.tarefa_casa"
                            rows="2"
                        />
                     </div>
                 </div>

            </div>

            <!-- Footer -->
            <div class="p-6 border-t border-div-15 bg-surface-hover flex justify-end gap-3 sticky bottom-0 z-10">
                <button 
                    @click="$emit('close')" 
                    class="px-4 py-2 text-sm font-bold text-secondary hover:text-text transition-colors"
                >
                    Cancelar
                </button>
                <button 
                    @click="handleSave"
                    :disabled="isSaving"
                    class="px-6 py-2 bg-primary hover:bg-primary/90 text-white rounded text-sm font-bold transition-all shadow-sm flex items-center gap-2"
                >
                    <span v-if="isSaving" class="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></span>
                    Salvar Aula
                </button>
            </div>

        </div>
    </div>
</template>

<style scoped>
.custom-scrollbar::-webkit-scrollbar {
    width: 6px;
}
.custom-scrollbar::-webkit-scrollbar-track {
    background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
    background-color: rgba(156, 163, 175, 0.3);
    border-radius: 20px;
}
</style>
