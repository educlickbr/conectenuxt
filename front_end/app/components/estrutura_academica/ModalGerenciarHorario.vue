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
    descricao: '',
    periodo: 'Matutino',
    hora_inicio: '',
    hora_fim: ''
})
const isSaving = ref(false)
const errorMessage = ref('')

// Initialize form
const initForm = () => {
    if (props.initialData) {
        formData.value = { 
            id: props.initialData.id || props.initialData.uuid,
            nome: props.initialData.nome || '',
            descricao: props.initialData.descricao || '',
            periodo: props.initialData.periodo || 'Matutino',
            hora_inicio: props.initialData.hora_inicio || '',
            hora_fim: props.initialData.hora_fim || ''
        }
    } else {
        formData.value = {
            nome: '',
            descricao: '',
            periodo: 'Matutino',
            hora_inicio: '',
            hora_fim: ''
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

const handleSave = async () => {
    if (!formData.value.nome.trim()) {
        errorMessage.value = 'O nome do horário é obrigatório.'
        return
    }
    if (!formData.value.hora_inicio || !formData.value.hora_fim) {
         errorMessage.value = 'Defina a hora de início e fim.'
        return
    }

    isSaving.value = true
    errorMessage.value = ''

    try {
        const payload = {
            id: formData.value.id,
            nome: formData.value.nome,
            descricao: formData.value.descricao,
            periodo: formData.value.periodo,
            hora_inicio: formData.value.hora_inicio,
            hora_fim: formData.value.hora_fim,
            hora_completo: `${formData.value.hora_inicio} - ${formData.value.hora_fim}`
        }

        const { success, message, error } = await $fetch('/api/estrutura_academica/horarios', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload
            }
        })

        if (success) {
            toast.showToast(message || 'Horário salvo com sucesso!')
            emit('success')
            emit('close')
        } else {
             throw new Error(message || 'Erro desconhecido ao salvar.')
        }

    } catch (err) {
        console.error('Erro ao salvar horário:', err)
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
                        <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Horário' : 'Novo Horário' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Configure os turnos e horários escolares.</p>
                    </div>
                     <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="p-6 flex flex-col gap-4">
                     <!-- Error Alert -->
                    <div v-if="errorMessage" class="p-4 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-xs flex items-start gap-2">
                        <span>{{ errorMessage }}</span>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <ManagerField 
                            label="Nome"
                            v-model="formData.nome"
                            placeholder="Ex: Turno Matutino"
                            required
                        />
                         <ManagerField 
                            label="Período"
                            v-model="formData.periodo"
                            type="select"
                        >
                            <option value="Matutino">Matutino</option>
                            <option value="Vespertino">Vespertino</option>
                            <option value="Noturno">Noturno</option>
                            <option value="Integral">Integral</option>
                        </ManagerField>
                    </div>

                    <ManagerField 
                        label="Descrição (Opcional)"
                        v-model="formData.descricao"
                        placeholder="Detalhes adicionais..."
                    />

                    <div class="grid grid-cols-2 gap-4">
                         <ManagerField 
                            label="Início"
                            v-model="formData.hora_inicio"
                            type="time"
                            required
                        />
                         <ManagerField 
                            label="Fim"
                            v-model="formData.hora_fim"
                            type="time"
                            required
                        />
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
