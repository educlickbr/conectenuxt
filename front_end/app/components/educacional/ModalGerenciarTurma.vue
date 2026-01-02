<script setup>
import { ref, watch, onMounted } from 'vue'
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
    ano: new Date().getFullYear().toString(),
    id_escola: '',
    id_classe: '',
    id_ano_etapa: '',
    id_horario: ''
})

const isSaving = ref(false)
const isLoadingDependencies = ref(false)
const errorMessage = ref('')

// Dependency Lists
const escolas = ref([])
const classes = ref([])
const anosEtapas = ref([])
const horarios = ref([])

// Fetch all dependencies
const fetchDependencies = async () => {
    isLoadingDependencies.value = true
    try {
        const companyId = appStore.company.empresa_id
        
        // Fetch in parallel
        const [resEscolas, resClasses, resAnos, resHorarios] = await Promise.all([
            $fetch('/api/infra/escolas', { query: { id_empresa: companyId, limite: 100 } }),
            $fetch('/api/educacional/classes', { query: { id_empresa: companyId, limite: 100 } }),
            $fetch('/api/educacional/ano_etapa', { query: { id_empresa: companyId, limite: 100 } }),
            $fetch('/api/educacional/horarios', { query: { id_empresa: companyId, limite: 100 } })
        ])

        escolas.value = resEscolas.items || []
        classes.value = resClasses.items || []
        anosEtapas.value = resAnos.items || []
        horarios.value = resHorarios.items || []

    } catch (err) {
        console.error('Erro ao carregar dependências da turma:', err)
        errorMessage.value = 'Erro ao carregar listas de seleção.'
    } finally {
        isLoadingDependencies.value = false
    }
}

// Initialize form
const initForm = () => {
    if (props.initialData) {
        formData.value = { 
            id: props.initialData.id || props.initialData.uuid,
            ano: props.initialData.ano || new Date().getFullYear().toString(),
            id_escola: props.initialData.id_escola || '',
            id_classe: props.initialData.id_classe || '',
            id_ano_etapa: props.initialData.id_ano_etapa || '',
            id_horario: props.initialData.id_horario || ''
        }
    } else {
        formData.value = {
            ano: new Date().getFullYear().toString(),
            // Pre-select first option if available for convenience, or empty
            id_escola: '', 
            id_classe: '',
            id_ano_etapa: '',
            id_horario: ''
        }
    }
}

watch(() => props.isOpen, async (newVal) => {
    if (newVal) {
        errorMessage.value = ''
        await fetchDependencies()
        initForm()
    }
})

const handleCancel = () => {
    emit('close')
}

const handleSave = async () => {
    if (!formData.value.ano || !formData.value.id_escola || !formData.value.id_classe || !formData.value.id_horario) {
        errorMessage.value = 'Preencha todos os campos obrigatórios.'
        return
    }

    isSaving.value = true
    errorMessage.value = ''

    try {
        const payload = {
            id: formData.value.id,
            ano: formData.value.ano,
            id_escola: formData.value.id_escola,
            id_classe: formData.value.id_classe,
            id_ano_etapa: formData.value.id_ano_etapa || null, // Optional in some contexts, but usually linked
            id_horario: formData.value.id_horario
        }

        const { success, message, error } = await $fetch('/api/educacional/turmas', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload
            }
        })

        if (success) {
            toast.showToast(message || 'Turma salva com sucesso!')
            emit('success')
            emit('close')
        } else {
             throw new Error(message || 'Erro desconhecido ao salvar.')
        }

    } catch (err) {
        console.error('Erro ao salvar turma:', err)
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
            <div class="relative bg-background w-full max-w-lg flex flex-col rounded shadow-2xl border border-secondary/10 overflow-hidden transform transition-all">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-div-15">
                    <div>
                        <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Turma' : 'Nova Turma' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Vincule classe, alunos e horários.</p>
                    </div>
                     <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="p-6 flex flex-col gap-4">
                     <!-- Loading Deps State -->
                    <div v-if="isLoadingDependencies" class="absolute inset-0 z-10 bg-white/80 dark:bg-black/80 flex items-center justify-center">
                         <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin"></div>
                    </div>

                     <!-- Error Alert -->
                    <div v-if="errorMessage" class="p-4 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-xs flex items-start gap-2">
                        <span>{{ errorMessage }}</span>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <ManagerField 
                            label="Ano Letivo"
                            v-model="formData.ano"
                            placeholder="Ex: 2025"
                            required
                        />
                         <ManagerField 
                            label="Escola"
                            v-model="formData.id_escola"
                            type="select"
                            required
                        >
                            <option value="">Selecione...</option>
                            <option v-for="e in escolas" :key="e.id" :value="e.id">{{ e.nome }}</option>
                        </ManagerField>
                    </div>

                    <ManagerField 
                        label="Classe / Série"
                        v-model="formData.id_classe"
                        type="select"
                        required
                    >
                         <option value="">Selecione...</option>
                         <option v-for="c in classes" :key="c.id" :value="c.id">{{ c.nome }}</option>
                    </ManagerField>

                     <div class="grid grid-cols-2 gap-4">
                        <ManagerField 
                            label="Ano / Etapa"
                            v-model="formData.id_ano_etapa"
                            type="select"
                        >
                             <option value="">Selecione...</option>
                             <option v-for="ae in anosEtapas" :key="ae.id" :value="ae.id">{{ ae.nome }} ({{ ae.tipo }})</option>
                        </ManagerField>

                        <ManagerField 
                            label="Horário / Turno"
                            v-model="formData.id_horario"
                            type="select"
                            required
                        >
                             <option value="">Selecione...</option>
                             <option v-for="h in horarios" :key="h.id" :value="h.id">{{ h.nome }} ({{ h.periodo }})</option>
                        </ManagerField>
                    </div>
                </div>

                <!-- Footer -->
                <div class="px-6 py-4 border-t border-secondary/10 flex items-center justify-end gap-3 bg-div-15">
                    <button 
                        @click="handleCancel"
                        class="px-4 py-2 rounded text-secondary font-semibold hover:bg-div-30 transition-colors"
                    >
                        Cancelar
                    </button>
                    <button 
                        @click="handleSave"
                        :disabled="isSaving || isLoadingDependencies"
                        class="px-6 py-2 rounded bg-primary text-white font-bold hover:brightness-110 active:scale-95 disabled:opacity-50 transition-all flex items-center gap-2"
                    >
                        <span v-if="isSaving" class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
                        {{ isSaving ? 'Salvando...' : 'Salvar' }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
