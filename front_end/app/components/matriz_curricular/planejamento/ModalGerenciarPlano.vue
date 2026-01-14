<script setup>
import { ref, watch, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps({
    isOpen: Boolean,
    context: Object, // { id_componente, id_ano_etapa, ... } IF provided
    initialData: Object // If editing
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

// State
const isSaving = ref(false)
const isLoadingContext = ref(false)

// Data
const availableComponents = ref([])
const availableAnos = ref([])

// Form
const planData = ref({
    id: null,
    id_ano_etapa: '',
    id_componente: '',
    titulo: '',
    descricao: ''
})

watch(() => props.isOpen, (val) => {
    if (val) {
        init()
    }
})

const init = async () => {
    if (props.initialData) {
        // Editing existing plan
        planData.value = {
            id: props.initialData.id,
            id_ano_etapa: props.context?.id_ano_etapa || props.initialData.id_ano_etapa,
            id_componente: props.context?.id_componente || props.initialData.id_componente,
            titulo: props.initialData.titulo || '',
            descricao: props.initialData.descricao || ''
        }
    } else if (props.context) {
        // Creating new plan with known context (e.g. from row)
        planData.value = {
            id: null,
            id_ano_etapa: props.context.id_ano_etapa,
            id_componente: props.context.id_componente,
            titulo: `Plano de Aula - ${props.context.componente_nome}`,
            descricao: ''
        }
    } else {
        // Creating completely new plan (no context) - Need selection
        planData.value = { 
            id: null, 
            id_ano_etapa: '', 
            id_componente: '', 
            titulo: '', 
            descricao: '' 
        }
        await fetchDropdowns()
    }
}

const fetchDropdowns = async () => {
    try {
        isLoadingContext.value = true
        // 1. Fetch Anos
        const { items: anos } = await $fetch('/api/estrutura_academica/ano_etapa', {
            query: { id_empresa: appStore.company.empresa_id }
        })
        availableAnos.value = anos || []

    } catch (err) {
        console.error(err)
    } finally {
        isLoadingContext.value = false
    }
}

// When Ano changes, fetch components (Carga Horaria)
watch(() => planData.value.id_ano_etapa, async (val) => {
    if (!props.initialData && !props.context && val) {
        // Fetch components available for this Year
        try {
            const { items } = await $fetch('/api/estrutura_academica/carga_horaria', {
                 query: { id_empresa: appStore.company.empresa_id, id_ano_etapa: val }
            })
            // Unique components
            const comps = []
            const seen = new Set()
            if (items) {
                items.forEach(i => {
                    if (!seen.has(i.id_componente)) {
                        seen.add(i.id_componente)
                        comps.push({ value: i.id_componente, label: i.componente_nome })
                    }
                })
            }
            availableComponents.value = comps
        } catch (err) {
            console.error(err)
        }
    } else {
        availableComponents.value = []
    }
})

// Auto-fill title if component selected
watch(() => planData.value.id_componente, (val) => {
    if (!props.initialData && !planData.value.titulo && val) {
        const compName = availableComponents.value.find(c => c.value === val)?.label
        if (compName) {
            planData.value.titulo = `Plano de Aula - ${compName}`
        }
    }
})

const handleSavePlanHeader = async () => {
    if (!planData.value.titulo.trim()) {
        toast.showToast('Informe o título do plano.', 'warning')
        return
    }
    if (!planData.value.id_ano_etapa || !planData.value.id_componente) {
        toast.showToast('Selecione o Ano/Etapa e o Componente.', 'warning')
        return
    }

    isSaving.value = true
    try {
        const payload = {
            id: planData.value.id,
            id_componente: planData.value.id_componente,
            id_ano_etapa: planData.value.id_ano_etapa,
            titulo: planData.value.titulo,
            descricao: planData.value.descricao
        }

        const { data } = await $fetch('/api/estrutura_academica/plano_de_aulas', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload
            }
        })
        
        if (data) {
            toast.showToast('Dados do plano salvos com sucesso!')
            emit('success')
            emit('close')
        }
    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao salvar plano.', 'error')
    } finally {
        isSaving.value = false
    }
}

const handleClose = () => {
    emit('close')
}

// Display helpers
const contextTitle = computed(() => {
    if (props.context) return `${props.context.componente_nome} • ${props.context.ano_etapa_nome}`
    if (props.initialData) return 'Editar Plano' // Or verify context logic ??
    return 'Novo Plano de Aula'
})
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-6 text-sm">
            <!-- Backdrop -->
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="handleClose"></div>
            
            <!-- Modal Content -->
            <div class="relative bg-background w-full max-w-lg flex flex-col rounded shadow-2xl border border-secondary/10 overflow-hidden transform transition-all text-text">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-div-15 shrink-0">
                    <div>
                        <h2 class="text-xl font-bold">Gerenciar Plano de Aula</h2>
                        <div v-if="context" class="flex items-center gap-2 text-xs text-secondary mt-0.5">
                            <span class="font-bold text-primary">{{ context.componente_nome }}</span>
                            <span>•</span>
                            <span>{{ context.ano_etapa_nome }}</span>
                        </div>
                         <div v-else class="text-xs text-secondary mt-0.5">
                            Preencha os dados do novo plano
                        </div>
                    </div>
                     <button @click="handleClose" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="p-6 flex flex-col gap-4 max-h-[70vh] overflow-y-auto">
                    
                    <!-- Selection Logic (Only if no context/new) -->
                    <div v-if="!context && !initialData" class="grid grid-cols-2 gap-4 p-4 bg-div-15/50 rounded-lg border border-div-30">
                         <ManagerField 
                            label="Ano / Etapa"
                            type="select"
                            v-model="planData.id_ano_etapa"
                            required
                        >
                            <option value="" disabled>Selecione...</option>
                            <option v-for="a in availableAnos" :key="a.id" :value="a.id">{{ a.nome }}</option>
                        </ManagerField>

                         <ManagerField 
                            label="Componente"
                            type="select"
                            v-model="planData.id_componente"
                            :disabled="!planData.id_ano_etapa"
                            required
                        >
                            <option value="" disabled>Selecione...</option>
                            <option v-for="c in availableComponents" :key="c.value" :value="c.value">{{ c.label }}</option>
                        </ManagerField>
                    </div>

                    <ManagerField 
                        label="Título do Plano"
                        v-model="planData.titulo"
                        placeholder="Ex: Plano Anual de Matemática"
                        required
                    />
                    <div class="flex flex-col gap-1">
                        <label class="text-xs font-bold text-secondary uppercase tracking-wider ml-1">Descrição Geral</label>
                        <textarea 
                            v-model="planData.descricao" 
                            rows="8" 
                            class="w-full bg-div-15 border border-div-30 rounded-lg p-3 text-sm focus:border-primary outline-none transition-colors resize-none"
                            placeholder="Objetivos gerais e observações..."
                        ></textarea>
                    </div>
                </div>

                <!-- Footer -->
                <div class="px-6 py-4 bg-div-15 border-t border-secondary/10 flex justify-end gap-3">
                    <button 
                        @click="handleClose"
                        class="px-4 py-2 rounded text-secondary hover:bg-div-30 transition-colors font-semibold"
                    >
                        Cancelar
                    </button>
                    <button 
                        @click="handleSavePlanHeader"
                        class="px-6 py-2 bg-primary text-white rounded font-bold hover:brightness-110 transition-colors flex items-center gap-2"
                        :disabled="isSaving"
                    >
                         <span v-if="isSaving" class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
                         Salvar Plano
                    </button>
                </div>

            </div>
        </div>
    </Teleport>
</template>
