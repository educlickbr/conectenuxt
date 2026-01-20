<script setup lang="ts">
import { ref, watch } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps<{
    isOpen: boolean
    initialData?: any
}>()

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

const formData = ref({ codigo: '', nome: '' })
const isSaving = ref(false)
const errorMessage = ref('')

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        if (props.initialData) {
            formData.value = { ...props.initialData }
        } else {
            formData.value = { codigo: '', nome: '' }
        }
        errorMessage.value = ''
    }
})

const handleCancel = () => {
    emit('close')
}

const handleSave = async () => {
    errorMessage.value = ''
    if (!formData.value.codigo || !formData.value.codigo.trim()) {
        errorMessage.value = 'O campo "Código" é obrigatório.'
        return
    }
    if (!formData.value.nome || !formData.value.nome.trim()) {
        errorMessage.value = 'O campo "Nome" é obrigatório.'
        return
    }

    isSaving.value = true
    try {
        await $fetch('/api/biblioteca/catalogo/cdu', {
            method: 'POST',
            body: {
                data: formData.value,
                id_empresa: appStore.company?.empresa_id
            }
        })
        emit('success')
        emit('close')
        toast.showToast('CDU salvo com sucesso.', 'success')
    } catch (e: any) {
        errorMessage.value = e.statusMessage || e.message || 'Erro ao salvar.'
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-6">
            <!-- Backdrop -->
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="handleCancel"></div>
            
            <!-- Modal Content -->
            <div class="relative bg-background w-full max-w-2xl max-h-[90vh] flex flex-col rounded shadow-2xl border border-[#6B82A71A] overflow-hidden transform transition-all animate-in zoom-in-95 duration-200">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between bg-div-15">
                    <div>
                        <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar CDU' : 'Novo CDU' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Classificação Decimal Universal.</p>
                    </div>
                    <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="flex-1 overflow-y-auto p-6">

                    <!-- Error Alert -->
                    <div v-if="errorMessage" class="mb-6 p-4 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-sm flex items-start gap-3">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 mt-0.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                        <span>{{ errorMessage }}</span>
                    </div>

                    <!-- Form Grid -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-5">
                        <ManagerField
                            v-model="formData.codigo"
                            label="Código"
                            placeholder="Ex: 821.134.3"
                            :required="true"
                            class="col-span-1"
                        />

                        <ManagerField
                            v-model="formData.nome"
                            label="Nome"
                            placeholder="Ex: Literatura Brasileira"
                            :required="true"
                            class="col-span-1"
                        />
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
                        :disabled="isSaving"
                        class="px-8 py-2.5 rounded bg-primary text-white font-bold text-sm hover:brightness-110 active:scale-95 disabled:opacity-50 disabled:active:scale-100 transition-all flex items-center gap-2 shadow-lg shadow-[#3571CB33]"
                    >
                        <svg v-if="isSaving" class="animate-spin w-4 h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                        {{ isSaving ? 'Salvando...' : (initialData ? 'Atualizar' : 'Criar') }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
