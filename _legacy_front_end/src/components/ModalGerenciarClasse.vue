<script setup>
import { ref, onMounted, watch } from 'vue'
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

const formData = ref({
    nome: '',
    ordem: null
})
const isSaving = ref(false)
const errorMessage = ref('')

// Initialize form data
const initFormData = () => {
    if (props.initialData) {
        formData.value = {
            id: props.initialData.id,
            nome: props.initialData.nome,
            ordem: props.initialData.ordem
        }
    } else {
        formData.value = {
            nome: '',
            ordem: null
        }
    }
}

const resetForm = () => {
    initFormData()
    errorMessage.value = ''
}

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
        const payload = { ...formData.value }

        // 3. Call Upsert
        const { data, error } = await supabase.rpc('classe_upsert', {
            p_data: payload,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        // Check for application-level error returned as JSON
        if (data && data.status === 'error') {
            throw new Error(data.message || 'Erro desconhecido ao salvar classe.')
        }

        // 4. Success
        resetForm() // Limpa formulário
        emit('success')
        emit('close')
        toast.showToast('Classe salva com sucesso.', 'success')

    } catch (err) {
        console.error('Erro ao salvar classe:', err)
        errorMessage.value = err.message || 'Erro ao salvar classe.'
        toast.showToast('Houve um erro na solicitação', 'error')
    } finally {
        isSaving.value = false
    }
}

// Watch for changes in initialData or isOpen to reset/populate form
watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        initFormData()
    }
})

</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-0 md:p-6" @click.self="handleCandel">
        
        <!-- Modal Container -->
        <div class="bg-background flex flex-col w-full h-full md:w-[90%] md:max-w-md md:h-auto md:max-h-[80%] md:rounded-xl overflow-hidden shadow-2xl border border-secondary/20">
            
            <!-- Header -->
            <div class="flex items-center justify-between p-4 border-b border-secondary/20 bg-div-15 shrink-0">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Classe' : 'Nova Classe' }}</h2>
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
                
                <!-- Error State -->
                <div v-if="errorMessage" class="mb-4 p-3 rounded-lg bg-red-500/10 border border-red-500/30 text-red-500">
                    {{ errorMessage }}
                </div>

                <!-- Form -->
                <div class="flex flex-col gap-4">
                    
                    <!-- Nome -->
                    <div class="flex flex-col gap-1">
                        <label for="nome" class="text-sm font-medium text-secondary capitalize flex items-center gap-2">
                            Nome <span class="text-red-500">*</span>
                        </label>
                        <input 
                            id="nome"
                            type="text" 
                            v-model="formData.nome"
                            placeholder="Digite o nome da classe"
                            class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/50"
                        >
                    </div>

                    <!-- Ordem -->
                    <div class="flex flex-col gap-1">
                        <label for="ordem" class="text-sm font-medium text-secondary capitalize flex items-center gap-2">
                            Ordem
                        </label>
                        <input 
                            id="ordem"
                            type="number" 
                            v-model="formData.ordem"
                            placeholder="Digite a ordem"
                            class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/50"
                        >
                    </div>
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
                    :disabled="isSaving"
                    class="px-6 py-2 rounded-lg bg-primary text-white font-bold hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                >
                    <span v-if="isSaving" class="animate-spin">⌛</span>
                    Salvar
                </button>
            </div>

        </div>
    </div>
</template>

<style scoped>
/* Remove numeric inputs arrows */
input[type=number]::-webkit-inner-spin-button, 
input[type=number]::-webkit-outer-spin-button { 
  -webkit-appearance: none; 
  margin: 0; 
}
input[type=number] {
      -moz-appearance: textfield; 
  appearance: none; 
  margin: 0; 
}
</style>
