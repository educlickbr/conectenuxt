<script setup>
import { ref, watch } from 'vue'
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

const formData = ref({ nome: '', email: '', telefone: '' })
const isSaving = ref(false)
const errorMessage = ref('')

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        if (props.initialData) {
            formData.value = { ...props.initialData }
        } else {
            formData.value = { nome: '', email: '', telefone: '' }
        }
        errorMessage.value = ''
    }
})

const handleSave = async () => {
    errorMessage.value = ''
    if (!formData.value.nome || !formData.value.nome.trim()) {
        errorMessage.value = 'O campo "Nome" é obrigatório.'
        return
    }

    isSaving.value = true
    try {
        const { error } = await supabase.rpc('bbtk_dim_editora_upsert', {
            p_data: formData.value,
            p_id_empresa: appStore.id_empresa
        })
        if (error) throw error
        emit('success')
        emit('close')
        toast.showToast('Editora salva com sucesso.', 'success')
    } catch (err) {
        errorMessage.value = err.message
        toast.showToast('Erro ao salvar.', 'error')
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-0 md:p-6" @click.self="$emit('close')">
        <div class="bg-background w-full md:w-[600px] rounded-xl overflow-hidden shadow-2xl border border-secondary/20">
            <div class="p-4 border-b border-secondary/20 bg-div-15 flex justify-between items-center">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Editora' : 'Nova Editora' }}</h2>
                <button @click="$emit('close')" class="p-2 rounded-lg hover:bg-div-30 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
            </div>
            <div class="p-6 flex flex-col gap-4">
                <div v-if="errorMessage" class="p-3 bg-red-500/10 text-red-500 rounded-lg">{{ errorMessage }}</div>
                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-secondary">Nome <span class="text-red-500">*</span></label>
                    <input type="text" v-model="formData.nome" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:border-primary focus:outline-none">
                </div>
                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-secondary">E-mail</label>
                    <input type="email" v-model="formData.email" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:border-primary focus:outline-none">
                </div>
                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-secondary">Telefone</label>
                    <input type="text" v-model="formData.telefone" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:border-primary focus:outline-none">
                </div>
            </div>
            <div class="p-4 border-t border-secondary/20 bg-div-15 flex justify-end gap-3">
                <button @click="$emit('close')" class="px-4 py-2 text-secondary hover:bg-div-30 rounded-lg">Cancelar</button>
                <button @click="handleSave" :disabled="isSaving" class="px-6 py-2 bg-primary text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center gap-2">
                    <span v-if="isSaving" class="animate-spin">⌛</span> Salvar
                </button>
            </div>
        </div>
    </div>
</template>
