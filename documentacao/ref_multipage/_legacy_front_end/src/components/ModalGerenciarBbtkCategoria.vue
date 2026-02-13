<script setup>
import { ref, computed, watch } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const props = defineProps({
    isOpen: { type: Boolean, default: false },
    initialData: { type: Object, default: null }
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

const formData = ref({
    nome: '',
    descricao: ''
})
const isSaving = ref(false)
const errorMessage = ref('')

const initFormData = () => {
    if (props.initialData) {
        formData.value = { ...props.initialData }
    } else {
        formData.value = {
            nome: '',
            descricao: ''
        }
    }
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        initFormData()
        errorMessage.value = ''
    }
})

const handleCancel = () => {
    emit('close')
}

const handleSave = async () => {
    errorMessage.value = ''
    
    if (!formData.value.nome || !formData.value.nome.trim()) {
        errorMessage.value = 'O campo "Nome" é obrigatório.'
        return
    }

    isSaving.value = true
    try {
        const payload = { ...formData.value }
        
        const { error } = await supabase.rpc('bbtk_dim_categoria_upsert', {
            p_data: payload,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        emit('success')
        emit('close')
        toast.showToast('Categoria salva com sucesso.', 'success')

    } catch (err) {
        console.error('Erro ao salvar categoria:', err)
        errorMessage.value = err.message || 'Erro ao salvar registro.'
        toast.showToast('Houve um erro na solicitação', 'error')
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-0 md:p-6" @click.self="handleCancel">
        <div class="bg-background flex flex-col w-full h-full md:w-[600px] md:h-auto md:max-h-[90%] md:rounded-xl overflow-hidden shadow-2xl border border-secondary/20">
            
            <div class="flex items-center justify-between p-4 border-b border-secondary/20 bg-div-15 shrink-0">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Categoria' : 'Nova Categoria' }}</h2>
                <button @click="handleCancel" class="p-2 text-secondary hover:text-text hover:bg-div-30 rounded-lg transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <div class="flex-1 overflow-y-auto p-4 md:p-6 flex flex-col gap-4">
                <div v-if="errorMessage" class="p-3 rounded-lg bg-red-500/10 border border-red-500/30 text-red-500">
                    {{ errorMessage }}
                </div>

                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-secondary">Nome <span class="text-red-500">*</span></label>
                    <input 
                        type="text" 
                        v-model="formData.nome"
                        placeholder="Nome da categoria"
                        class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
                    >
                </div>

                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-secondary">Descrição</label>
                    <textarea 
                        v-model="formData.descricao"
                        placeholder="Descrição opcional"
                        rows="3"
                        class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all resize-none"
                    ></textarea>
                </div>
            </div>

            <div class="flex items-center justify-end gap-3 p-4 border-t border-secondary/20 bg-div-15 shrink-0">
                <button @click="handleCancel" class="px-4 py-2 rounded-lg text-secondary hover:bg-div-30 transition-colors font-medium">Cancelar</button>
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
