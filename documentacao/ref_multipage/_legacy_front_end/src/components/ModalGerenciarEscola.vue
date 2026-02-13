<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

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

// Configuração de Layout e Ordem dos campos
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
            return !name.includes('htpc') && !name.includes('sharepoint')
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
    const initialData = {}
    schema.value.forEach(field => {
        if (props.initialData && props.initialData[field.column_name] !== undefined) {
             initialData[field.column_name] = props.initialData[field.column_name]
        } else {
             initialData[field.column_name] = null
        }
    })
    
    // Ensure ID is preserved if editing
    if (props.initialData && props.initialData.id) {
        initialData.id = props.initialData.id
    }
    
    formData.value = initialData
}

const resetForm = () => {
    initFormData()
    errorMessage.value = ''
}

const fetchSchema = async () => {
    isLoadingSchema.value = true
    errorMessage.value = ''
    try {
        const { data, error } = await supabase.rpc('escolas_get_schema', {
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        if (data) {
            schema.value = data
            initFormData()
        }
    } catch (err) {
        console.error('Erro ao buscar schema:', err)
        errorMessage.value = 'Falha ao carregar formulário.'
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
            // formData.value.cidade = data.localidade // Se houver campo cidade
            // formData.value.uf = data.uf // Se houver campo uf
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

const handleCandel = () => {
    resetForm()
    emit('close')
}

const handleSave = async () => {
    errorMessage.value = ''
    
    // 1. Validation
    if (!formData.value.nome || !formData.value.nome.toString().trim()) {
        errorMessage.value = 'O campo "nome" é obrigatório.'
        return
    }

    isSaving.value = true
    try {
        // 2. Prepare Data
        // id is handled by DB if null (gen_random_uuid in SQL)
        const payload = { ...formData.value }

        // 3. Call Upsert
        const { data, error } = await supabase.rpc('escolas_upsert', {
            p_data: payload,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        // 4. Success
        resetForm() // Limpa formulário
        emit('success')
        emit('close')
        toast.showToast('Ação concluída com sucesso.', 'success')

    } catch (err) {
        console.error('Erro ao salvar escola:', err)
        errorMessage.value = err.message || 'Erro ao salvar registro.'
        toast.showToast('Houve um erro na solicitação', 'error')
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


// Watch for changes in initialData or isOpen to reset/populate form
watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        if (schema.value.length > 0) {
            initFormData()
        } else {
            fetchSchema()
        }
    }
})

onMounted(() => {
    fetchSchema()
})

</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-0 md:p-6" @click.self="handleCandel">
        
        <!-- Modal Container -->
        <div class="bg-background flex flex-col w-full h-full md:w-[90%] md:h-[90%] md:rounded-xl overflow-hidden shadow-2xl border border-secondary/20">
            
            <!-- Header -->
            <div class="flex items-center justify-between p-4 border-b border-secondary/20 bg-div-15 shrink-0">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Escola' : 'Nova Escola' }}</h2>
                <button 
                    @click="handleCandel" 
                    class="p-2 text-secondary hover:text-text hover:bg-div-30 rounded-lg transition-colors"
                    title="Cancelar"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Body (Scrollable) -->
            <div class="flex-1 overflow-y-auto p-4 md:p-6">
                
                <!-- Loading State -->
                <div v-if="isLoadingSchema" class="flex flex-col items-center justify-center h-full text-secondary">
                    <svg class="animate-spin mb-2" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="2" x2="12" y2="6"></line><line x1="12" y1="18" x2="12" y2="22"></line><line x1="4.93" y1="4.93" x2="7.76" y2="7.76"></line><line x1="16.24" y1="16.24" x2="19.07" y2="19.07"></line><line x1="2" y1="12" x2="6" y2="12"></line><line x1="18" y1="12" x2="22" y2="12"></line><line x1="4.93" y1="19.07" x2="7.76" y2="16.24"></line><line x1="16.24" y1="7.76" x2="19.07" y2="4.93"></line></svg>
                    <span>Carregando formulário...</span>
                </div>

                <!-- Error State -->
                <div v-if="errorMessage" class="mb-4 p-3 rounded-lg bg-red-500/10 border border-red-500/30 text-red-500">
                    {{ errorMessage }}
                </div>

                <!-- Dynamic Form -->
                <div v-if="!isLoadingSchema && filteredSchema.length > 0" class="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
                    <div 
                        v-for="item in filteredSchema" 
                        :key="item.column_name" 
                        class="flex flex-col gap-1"
                        :class="item.span"
                    >
                        <label :for="item.column_name" class="text-sm font-medium text-secondary capitalize flex items-center gap-2">
                            {{ item.column_name.replace(/_/g, ' ') }} 
                            <span v-if="!item.is_nullable" class="text-red-500">*</span>
                            <span v-if="item.column_name === 'cep' && isLoadingCep" class="animate-spin text-primary">⌛</span>
                        </label>
                        <input 
                            :id="item.column_name"
                            :type="getInputType(item.data_type)" 
                            v-model="formData[item.column_name]"
                            :disabled="item.readonly"
                            :placeholder="item.readonly ? 'Preenchimento automático' : `Digite o ${item.column_name.replace(/_/g, ' ')}`"
                            class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/50 disabled:opacity-60 disabled:cursor-not-allowed"
                        >
                    </div>
                </div>

                <div v-if="!isLoadingSchema && filteredSchema.length === 0" class="text-center text-secondary py-10">
                    Nenhum campo disponível para o formulário.
                </div>

            </div>

            <!-- Footer -->
            <div class="flex items-center justify-end gap-3 p-4 border-t border-secondary/20 bg-div-15 shrink-0">
                <button 
                    @click="handleCandel"
                    class="px-4 py-2 rounded-lg text-secondary hover:bg-div-30 transition-colors font-medium"
                >
                    Cancelar
                </button>
                <button 
                    @click="handleSave"
                    :disabled="isSaving || isLoadingSchema"
                    class="px-6 py-2 rounded-lg bg-primary text-white font-bold hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                >
                    <span v-if="isSaving" class="animate-spin">⌛</span>
                    Salvar Escola
                </button>
            </div>

        </div>
    </div>
</template>
