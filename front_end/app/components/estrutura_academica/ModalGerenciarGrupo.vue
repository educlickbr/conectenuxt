<script setup>
import { ref, watch, computed } from 'vue'
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

const formData = ref({
    nome_grupo: '',
    descricao: '',
    status: 'ATIVO',
    ano: new Date().getFullYear()
})

const currentYear = new Date().getFullYear()
const yearOptions = [
    currentYear - 1,
    currentYear,
    currentYear + 1,
    currentYear + 2
].map(y => ({ value: y, label: String(y) }))

const isSaving = ref(false)
const errorMessage = ref('')

const statusOptions = [
    { value: 'ATIVO', label: 'Ativo' },
    { value: 'INATIVO', label: 'Inativo' }
]

const resetForm = () => {
    if (props.initialData) {
        formData.value = {
            id: props.initialData.id,
            nome_grupo: props.initialData.nome_grupo || '',
            descricao: props.initialData.descricao || '',
            status: props.initialData.status || 'ATIVO',
            ano: props.initialData.ano || currentYear
        }
    } else {
        formData.value = {
            nome_grupo: '',
            descricao: '',
            status: 'ATIVO',
            ano: currentYear
        }
    }
    errorMessage.value = ''
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) resetForm()
})

const handleCancel = () => {
    emit('close')
}

const handleSave = async () => {
    errorMessage.value = ''
    if (!formData.value.nome_grupo.trim()) {
        errorMessage.value = 'O nome do grupo é obrigatório.'
        return
    }

    isSaving.value = true
    try {
        const payload = { ...formData.value }
        
        const res = await $fetch(`/api/estrutura_academica/grupos`, {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload // Using 'data' wrapper as per standard, caught by my generic handler
            }
        })

        if (res && res.success) {
            toast.showToast('Grupo salvo com sucesso!')
            emit('success')
            emit('close')
        } else {
            errorMessage.value = res?.message || 'Erro ao salvar grupo.'
        }
    } catch (err) {
        console.error('Erro ao salvar grupo:', err)
        errorMessage.value = err.data?.message || err.message || 'Erro ao salvar registro.'
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
            <div class="relative bg-background w-full max-w-lg flex flex-col rounded shadow-2xl border border-[#6B82A71A] overflow-hidden transform transition-all">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between bg-div-15">
                    <div>
                        <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Grupo' : 'Novo Grupo' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Defina as informações do grupo de estudo.</p>
                    </div>
                    <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="p-6 space-y-4">
                     <!-- Error Alert -->
                    <div v-if="errorMessage" class="p-3 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-xs flex items-start gap-2">
                        <span>{{ errorMessage }}</span>
                    </div>

                    <ManagerField
                        v-model="formData.nome_grupo"
                        label="Nome do Grupo"
                        placeholder="Ex: Reforço de Matemática"
                        required
                    />

                    <ManagerField
                        v-model="formData.descricao"
                        label="Descrição"
                        placeholder="Objetivo do grupo..."
                        type="textarea"
                    />

                     <ManagerField 
                        label="Ano Letivo"
                        v-model="formData.ano"
                        type="select"
                        :options="yearOptions"
                        required
                     />

                    <div class="flex flex-col gap-1.5">
                        <label class="text-[11px] font-bold text-secondary uppercase tracking-wider">Status</label>
                        <div class="flex gap-4">
                            <label v-for="opt in statusOptions" :key="opt.value" class="flex items-center gap-2 cursor-pointer">
                                <input type="radio" v-model="formData.status" :value="opt.value" class="text-primary focus:ring-primary">
                                <span class="text-sm text-text">{{ opt.label }}</span>
                            </label>
                        </div>
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
                        {{ isSaving ? 'Salvando...' : (initialData ? 'Salvar' : 'Criar Grupo') }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
