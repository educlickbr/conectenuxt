<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    },
    initialData: {
        type: Object,
        default: null
    }
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

const schema = ref([])
const formData = ref({})
const isLoadingSchema = ref(false)
const isSaving = ref(false)
const errorMessage = ref('')
const isLoadingCep = ref(false)

// Configuração de Layout e Ordem dos campos (Personalizado conforme legacy)
const fieldConfig = {
    'nome': { order: 1, span: 'col-span-1 md:col-span-2' },
    'cep': { order: 2, span: 'col-span-1' },
    'bairro': { order: 3, span: 'col-span-1', readonly: true },
    'endereco': { order: 4, span: 'col-span-1 md:col-span-2', readonly: true },
    'numero': { order: 5, span: 'col-span-1' },
    'complemento': { order: 6, span: 'col-span-1' },
    'email': { order: 7, span: 'col-span-1 md:col-span-2' },
    'telefone_1': { order: 8, span: 'col-span-1' },
    'telefone_2': { order: 9, span: 'col-span-1' }
}

// Filtra e ordena o schema
const filteredSchema = computed(() => {
    return schema.value
        .filter(item => {
            const name = item.column_name.toLowerCase()
            return !name.includes('htpc') && !name.includes('sharepoint') && name !== 'id' && name !== 'id_empresa' && name !== 'created_at' && name !== 'updated_at'
        })
        .map(item => {
            const config = fieldConfig[item.column_name] || {}
            return {
                ...item,
                order: config.order || 999,
                span: config.span || 'col-span-1',
                readonly: config.readonly || false
            }
        })
        .sort((a, b) => a.order - b.order)
})

// Initialize form data based on schema to ensure reactivity
const initFormData = () => {
    const initial = {}
    schema.value.forEach(field => {
        if (props.initialData && props.initialData[field.column_name] !== undefined) {
             initial[field.column_name] = props.initialData[field.column_name]
        } else {
             initial[field.column_name] = null
        }
    })
    
    // Ensure ID is preserved if editing
    if (props.initialData && props.initialData.id) {
        initial.id = props.initialData.id
    }
    
    formData.value = initial
}

const resetForm = () => {
    initFormData()
    errorMessage.value = ''
}

const fetchSchema = async () => {
    if (!appStore.company?.empresa_id) return
    
    isLoadingSchema.value = true
    errorMessage.value = ''
    try {
        const { data, error } = await useFetch(`/api/infra/schema/escolas`, {
            query: { id_empresa: appStore.company.empresa_id }
        })

        if (error.value) throw error.value

        if (data.value?.fields) {
            schema.value = data.value.fields
            initFormData()
        }
    } catch (err) {
        console.error('Erro ao buscar schema:', err)
        errorMessage.value = 'Falha ao carregar formulário dinâmico.'
    } finally {
        isLoadingSchema.value = false
    }
}

// Busca CEP
const fetchCep = async (cep) => {
    if (!cep) return
    const cleanCep = cep.replace(/\D/g, '')
    if (cleanCep.length !== 8) return

    isLoadingCep.value = true
    try {
        const response = await fetch(`https://viacep.com.br/ws/${cleanCep}/json/`)
        const data = await response.json()
        
        if (!data.erro) {
            formData.value.endereco = data.logradouro
            formData.value.bairro = data.bairro
        }
    } catch (err) {
        console.error('Erro ao buscar CEP', err)
    } finally {
        isLoadingCep.value = false
    }
}

// Watchers
watch(() => formData.value.cep, (newVal) => {
    if (newVal) fetchCep(newVal)
})

const handleCancel = () => {
    resetForm()
    emit('close')
}

const handleSave = async () => {
    errorMessage.value = ''
    
    if (!formData.value.nome || !formData.value.nome.toString().trim()) {
        errorMessage.value = 'O campo "nome" é obrigatório.'
        return
    }

    isSaving.value = true
    try {
        const payload = { ...formData.value }
        
        const res = await $fetch(`/api/infra/escolas`, {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload
            }
        })

        if (res && res.success) {
            toast.showToast('Escola salva com sucesso!')
            emit('success')
            emit('close')
            resetForm()
        } else {
            errorMessage.value = res?.message || 'Erro ao salvar escola.'
        }
    } catch (err) {
        console.error('Erro ao salvar escola:', err)
        errorMessage.value = err.statusMessage || 'Erro ao salvar registro.'
    } finally {
        isSaving.value = false
    }
}

// Input type helper
const getInputType = (dataType) => {
    if (['integer', 'numeric', 'smallint', 'bigint', 'decimal', 'double precision', 'real'].includes(dataType)) {
        return 'number'
    }
    return 'text'
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        if (schema.value.length === 0) {
            fetchSchema()
        } else {
            initFormData()
        }
    }
})
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-6">
            <!-- Backdrop -->
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="handleCancel"></div>
            
            <!-- Modal Content -->
            <div class="relative bg-background w-full max-w-4xl max-h-[90vh] flex flex-col rounded shadow-2xl border border-[#6B82A71A] overflow-hidden transform transition-all">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between bg-div-15">
                    <div>
                        <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Escola' : 'Nova Escola' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Preencha as informações básicas da instituição.</p>
                    </div>
                    <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="flex-1 overflow-y-auto p-6">
                    <!-- Loading State -->
                    <div v-if="isLoadingSchema" class="flex flex-col items-center justify-center py-20 text-secondary">
                        <div class="w-10 h-10 border-4 border-[#3571CB33] border-t-primary rounded-full animate-spin mb-4"></div>
                        <span class="text-sm font-medium">Carregando formulário...</span>
                    </div>

                    <!-- Error Alert -->
                    <div v-if="errorMessage" class="mb-6 p-4 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-sm flex items-start gap-3">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 mt-0.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                        <span>{{ errorMessage }}</span>
                    </div>

                    <!-- Form Grid -->
                    <div v-if="!isLoadingSchema && filteredSchema.length > 0" class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-5">
                        <ManagerField
                            v-for="item in filteredSchema" 
                            :key="item.column_name" 
                            v-model="formData[item.column_name]"
                            :label="item.column_name.replace(/_/g, ' ')"
                            :type="getInputType(item.data_type)"
                            :disabled="item.readonly"
                            :required="!item.is_nullable"
                            :placeholder="item.readonly ? 'Preenchimento automático' : `Ex: ${item.column_name === 'email' ? 'escola@email.com' : '...'}`"
                            :class="item.span"
                        />
                    </div>

                    <!-- Empty State -->
                    <div v-if="!isLoadingSchema && filteredSchema.length === 0" class="text-center py-20 text-[#6B82A780]">
                        <p>Nenhum campo disponível no momento.</p>
                    </div>
                </div>

                <!-- Footer -->
                <div class="px-6 py-4 border-t border-[#6B82A71A] flex items-center justify-end gap-3 bg-div-15">
                    <button 
                        @click="handleCancel"
                        class="px-5 py-2.5 rounded text-secondary font-semibold text-sm hover:bg-div-30 transition-colors"
                    >
                        Cancelar
                    </button>
                    <button 
                        @click="handleSave"
                        :disabled="isSaving || isLoadingSchema"
                        class="px-8 py-2.5 rounded bg-primary text-white font-bold text-sm hover:brightness-110 active:scale-95 disabled:opacity-50 disabled:active:scale-100 transition-all flex items-center gap-2 shadow-lg shadow-[#3571CB33]"
                    >
                        <svg v-if="isSaving" class="animate-spin w-4 h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                        {{ isSaving ? 'Salvando...' : (initialData ? 'Atualizar Escola' : 'Criar Escola') }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
