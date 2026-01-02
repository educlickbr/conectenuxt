<script setup>
import { ref, watch } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const props = defineProps({
    isOpen: Boolean,
    initialData: Object
})

const emit = defineEmits(['close', 'success'])

const appStore = useAppStore()
const toast = useToastStore()

// State
const isSaving = ref(false)
const form = ref({
    id: null,
    nome_completo: '',
    email: '',
    telefone: ''
})

// Init
watch(() => props.isOpen, (val) => {
    if (val) {
        if (props.initialData) {
            form.value = {
                id: props.initialData.id,
                nome_completo: props.initialData.nome_completo,
                email: props.initialData.email,
                telefone: props.initialData.telefone
            }
        } else {
            resetForm()
        }
    }
})

const resetForm = () => {
    form.value = { id: null, nome_completo: '', email: '', telefone: '' }
}

const handleSave = async () => {
    isSaving.value = true
    try {
        if (!form.value.nome_completo) throw new Error("Nome Completo é obrigatório")
        if (!form.value.email) throw new Error("Email é obrigatório")

        const payload = {
            id: form.value.id,
            nome_completo: form.value.nome_completo,
            email: form.value.email,
            telefone: form.value.telefone
        }

        const { error } = await supabase.rpc('admin_upsert', {
            p_id_empresa: appStore.id_empresa,
            p_data: payload
        })

        if (error) throw error

        toast.showToast("Administrador salvo com sucesso!", "success")
        emit('success')
        emit('close')

    } catch (e) {
        console.error(e)
        toast.showToast(e.message || "Erro ao salvar", "error")
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-0 md:p-6" @click.self="$emit('close')">
        <div class="bg-background flex flex-col w-full h-full md:w-[90%] md:h-[90%] md:rounded-xl overflow-hidden shadow-2xl border border-div-30">
            
            <!-- Header -->
            <div class="flex items-center justify-between p-4 border-b border-div-30 bg-div-15 shrink-0">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Administrador' : 'Novo Administrador' }}</h2>
                <button @click="$emit('close')" class="p-2 text-secondary hover:text-text hover:bg-div-30 rounded-lg">✕</button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-6 bg-background text-text space-y-4">
                
                <div>
                    <label class="text-sm font-medium text-secondary">Nome Completo</label>
                    <input v-model="form.nome_completo" class="input-theme" placeholder="Ex: João da Silva">
                </div>

                <div>
                    <label class="text-sm font-medium text-secondary">Email</label>
                    <input v-model="form.email" type="email" class="input-theme" placeholder="email@exemplo.com">
                </div>

                <div>
                    <label class="text-sm font-medium text-secondary">Telefone</label>
                    <input v-model="form.telefone" class="input-theme" placeholder="(00) 00000-0000">
                </div>
            
            </div>

             <!-- Footer -->
            <div class="flex items-center justify-end p-4 border-t border-div-30 bg-div-15 shrink-0 gap-3">
                <button @click="$emit('close')" class="px-4 py-2 text-secondary hover:text-text hover:bg-div-30 rounded-lg transition-colors font-medium">Cancelar</button>
                <button @click="handleSave" :disabled="isSaving" class="px-6 py-2 bg-primary hover:bg-primary-dark text-white rounded-lg shadow-lg shadow-primary/20 transition-all font-medium disabled:opacity-50 flex items-center gap-2">
                    <span v-if="isSaving" class="animate-spin">⏳</span>
                    <span>{{ isSaving ? 'Salvando...' : 'Salvar' }}</span>
                </button>
            </div>

        </div>
    </div>
</template>

<style scoped>
.input-theme {
    @apply w-full px-3 py-2 bg-background border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary;
}
</style>
