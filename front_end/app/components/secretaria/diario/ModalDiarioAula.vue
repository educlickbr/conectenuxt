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

// --- Restricted Clients List ---
// Clients where teachers cannot edit content if a Lesson Plan is selected
const RESTRICTED_CLIENTS = [
    // Add real UUIDs here when provided by user
    'PLACEHOLDER_UUID' 
]

const isRestrictedClient = computed(() => {
    return appStore.company?.empresa_id && RESTRICTED_CLIENTS.includes(appStore.company.empresa_id)
})

const form = ref({
    // Context
    id_escola: null as string | null,
    id_ano_etapa: null as string | null,
    id_turma: null as string | null,
    id_componente: null as string | null,
    
    // Lesson Plan Link
    id_plano_aula_item: null as string | null,

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
const planoItens = ref<any[]>([]) // Items available for the selected Component

const isLoadingComponents = ref(false)
const isLoadingPlano = ref(false)
const isSaving = ref(false)

// Lock fields if a plan key is selected AND client is restricted
const isFieldsLocked = computed(() => {
    return !!form.value.id_plano_aula_item && isRestrictedClient.value
})

// --- Fetchers ---

const fetchEscolas = async () => {
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
    if (!form.value.id_escola && !form.value.id_ano_etapa) { 
        turmas.value = []
        return
    }
    
    try {
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

const fetchPlanoItens = async () => {
    if (!form.value.id_componente || !form.value.id_ano_etapa) {
        planoItens.value = []
        return
    }

    isLoadingPlano.value = true
    try {
        const { data }: any = await useFetch('/api/estrutura_academica/plano_itens_contexto', {
            params: { 
                id_empresa: appStore.company?.empresa_id, 
                id_componente: form.value.id_componente,
                id_ano_etapa: form.value.id_ano_etapa
            }
        })
        // API returns { items: [...] } or just array depending on implementation
        planoItens.value = data.value?.items || [] 
    } catch (e) {
        console.error('Error fetching plan items:', e)
        planoItens.value = []
    } finally {
        isLoadingPlano.value = false
    }
}

// --- Watchers ---

watch(() => form.value.id_escola, () => {
    if (!props.initialData) {
        form.value.id_turma = null
        fetchTurmas()
    }
})

watch(() => form.value.id_ano_etapa, () => {
   if (!props.initialData) {
        form.value.id_turma = null
        fetchTurmas()
        
        // Also fetch plan items since they depend on Year/Stage too
        if (form.value.id_componente) fetchPlanoItens()
   }
})

watch(() => form.value.id_componente, () => {
    // When component changes, fetch available lessons
    form.value.id_plano_aula_item = null
    fetchPlanoItens()
})

watch(() => form.value.id_plano_aula_item, (newVal) => {
    if (newVal) {
        const item = planoItens.value.find(i => i.id === newVal)
        if (item) {
            form.value.conteudo = item.conteudo || ''
            form.value.metodologia = item.metodologia || ''
            form.value.tarefa_casa = item.tarefa || ''
        }
    }
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
        form.value.id_escola = d.id_escola 
        form.value.id_ano_etapa = d.id_ano_etapa 
        form.value.id_turma = d.id_turma
        
        // This field was added to View/RPC? 
        // We added it to diarios_get... make sure frontend receives it.
        form.value.id_plano_aula_item = d.id_plano_aula_item

        // Trigger cascading fetches
        await fetchTurmas()
        await fetchComponentes()
        // Wait for fetchComponentes before fetching items? Actually they are independent but logic needs component set
        form.value.id_componente = d.id_componente
        
        // Now fetch items so dropdown works
        await fetchPlanoItens()

    } else if (props.initialFilters) {
        // Pre-fill from filters
        const f = props.initialFilters
        if (f.escola_id) form.value.id_escola = f.escola_id
        if (f.ano_etapa_id) form.value.id_ano_etapa = f.ano_etapa_id
        
        setTimeout(async () => {
            if (f.turma_id) {
                await fetchTurmas()
                form.value.id_turma = f.turma_id
                await fetchComponentes() // Generic fetch
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
        const payload = {
            id_empresa: appStore.company?.empresa_id,
            data: {
                id: form.value.id,
                id_turma: form.value.id_turma,
                id_componente: form.value.id_componente,
                data: form.value.data,
                conteudo: form.value.conteudo,
                metodologia: form.value.metodologia,
                tarefa_casa: form.value.tarefa_casa,
                id_plano_aula_item: form.value.id_plano_aula_item, // Send Link
                id_usuario: appStore.user?.id
            }
        }

        const { error } = await useFetch('/api/estrutura_academica/diario_aulas', {
            method: 'POST',
            body: payload
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
                         <option :value="null">Geral (Sem vínculo a plano)</option>
                         <option v-for="c in componentes" :key="c.uuid || c.id" :value="c.uuid || c.id">{{ c.nome }}</option>
                    </ManagerField>
                 </div>

                 <!-- Lesson Plan Selection -->
                 <div v-if="form.id_componente" class="mb-6 animate-fade-in-down">
                     <ManagerField 
                        label="Conteúdo do Plano de Aula (Opcional)" 
                        type="select" 
                        :model-value="form.id_plano_aula_item ?? undefined"
                        @update:modelValue="form.id_plano_aula_item = $event"
                        :disabled="isLoadingPlano"
                    >
                         <option :value="null">-- Digitação Manual --</option>
                         <option v-for="item in planoItens" :key="item.id" :value="item.id">
                            {{ item.plano_titulo }} - Aula {{ item.aula_numero }}: {{ item.conteudo?.substring(0, 40) }}...
                         </option>
                    </ManagerField>
                    <p v-if="isLoadingPlano" class="text-xs text-secondary mt-1 ml-1 animate-pulse">Buscando planos...</p>
                 </div>

                 <div class="space-y-4">
                     <!-- Content Fields -->
                     <!-- Locked if restricted client and plan selected -->
                     <div class="relative">
                        <ManagerField 
                            label="Conteúdo Ministrado" 
                            type="textarea" 
                            v-model="form.conteudo"
                            placeholder="Descreva o que foi ensinado na aula..."
                            rows="4"
                            :disabled="isFieldsLocked"
                            :class="{ 'opacity-60': isFieldsLocked }"
                        />
                         <div v-if="isFieldsLocked" class="absolute top-0 right-0 p-2 text-xs text-orange-500 font-bold flex items-center gap-1">
                            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                            Bloqueado pelo Plano
                        </div>
                     </div>
                    
                    <button 
                        v-if="!form.metodologia && !form.tarefa_casa && !isFieldsLocked" 
                        @click="form.metodologia = ' '; form.tarefa_casa = ' '"
                        class="text-xs text-primary font-bold hover:underline"
                    >
                        + Adicionar Metodologia e Tarefa de Casa
                    </button>

                     <div v-if="form.metodologia || form.tarefa_casa || isFieldsLocked" class="grid grid-cols-1 gap-4">
                        <ManagerField 
                            label="Metodologia (Opcional)" 
                            type="textarea" 
                            v-model="form.metodologia"
                            rows="2"
                            :disabled="isFieldsLocked"
                            :class="{ 'opacity-60': isFieldsLocked }"
                        />
                         <ManagerField 
                            label="Tarefa de Casa (Opcional)" 
                            type="textarea" 
                            v-model="form.tarefa_casa"
                            rows="2"
                            :disabled="isFieldsLocked"
                            :class="{ 'opacity-60': isFieldsLocked }"
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
