<script setup>
import { ref, watch } from 'vue'
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
    nome: '',
    cor: '#3571CB'
})
const isSaving = ref(false)
const errorMessage = ref('')

const PRESET_COLORS = [
    '#3571CB', '#EF4444', '#F59E0B', '#10B981', 
    '#8B5CF6', '#EC4899', '#6366F1', '#14B8A6',
    '#F97316', '#06B6D4'
]

// Initialize form
const initForm = () => {
    if (props.initialData) {
        formData.value = { 
            uuid: props.initialData.uuid,
            nome: props.initialData.nome || '',
            cor: props.initialData.cor || '#3571CB'
        }
    } else {
        formData.value = {
            nome: '',
            cor: '#3571CB'
        }
    }
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        initForm()
        errorMessage.value = ''
    }
})

const handleCancel = () => {
    emit('close')
}

const selectPreset = (color) => {
    formData.value.cor = color
}

const handleSave = async () => {
    if (!formData.value.nome.trim()) {
        errorMessage.value = 'O nome do componente é obrigatório.'
        return
    }

    isSaving.value = true
    errorMessage.value = ''

    try {
        const { success, message, data } = await $fetch('/api/estrutura_academica/componentes', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: formData.value
            }
        })

        if (success) {
            toast.showToast(message || 'Componente salvo com sucesso!')
            emit('success')
            emit('close')
        } else {
             throw new Error(message || 'Erro desconhecido ao salvar.')
        }

    } catch (err) {
        console.error('Erro ao salvar componente:', err)
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
            <div class="relative bg-background w-full max-w-md flex flex-col rounded shadow-2xl border border-secondary/10 overflow-hidden transform transition-all text-text">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-div-15">
                    <div>
                        <h2 class="text-xl font-bold">{{ initialData ? 'Editar Componente' : 'Novo Componente' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Identifique o componente com nome e cor.</p>
                    </div>
                     <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="p-6 flex flex-col gap-6">
                     <!-- Error Alert -->
                    <div v-if="errorMessage" class="p-4 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-xs flex items-start gap-2">
                        <span>{{ errorMessage }}</span>
                    </div>

                    <ManagerField 
                        label="Nome do Componente"
                        v-model="formData.nome"
                        placeholder="Ex: Português, Matemática, Arte..."
                        required
                    />

                    <!-- Color Selector -->
                    <div class="flex flex-col gap-2">
                        <label class="text-xs font-bold text-secondary uppercase tracking-wider">Cor Representativa</label>
                        <div class="flex flex-wrap gap-2">
                            <button 
                                v-for="color in PRESET_COLORS" 
                                :key="color"
                                @click="selectPreset(color)"
                                class="w-8 h-8 rounded-full border-2 transition-transform active:scale-90"
                                :class="formData.cor === color ? 'border-primary ring-2 ring-primary/20 scale-110' : 'border-transparent'"
                                :style="{ backgroundColor: color }"
                            ></button>
                            
                            <!-- Native Color Picker -->
                            <div class="relative w-8 h-8 group">
                                <input 
                                    type="color" 
                                    v-model="formData.cor"
                                    class="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10"
                                />
                                <div 
                                    class="w-8 h-8 rounded-full border border-secondary/20 flex items-center justify-center bg-div-15 group-hover:bg-div-30 transition-colors"
                                    :title="'Escolher cor customizada'"
                                >
                                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="text-secondary"><path d="M12 19l7-7 3 3-7 7-3-3z"></path><path d="M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5z"></path><path d="M2 2l7.586 7.586"></path><circle cx="11" cy="11" r="2"></circle></svg>
                                </div>
                            </div>
                        </div>
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
                        :disabled="isSaving"
                        class="px-6 py-2 rounded bg-primary text-white font-bold hover:brightness-110 active:scale-95 disabled:opacity-50 transition-all flex items-center gap-2 shadow-sm"
                    >
                        <span v-if="isSaving" class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
                        {{ isSaving ? 'Salvando...' : 'Salvar Componente' }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
