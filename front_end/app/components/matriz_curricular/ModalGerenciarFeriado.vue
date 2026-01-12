<script setup>
import { ref, computed, watch } from 'vue'
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
    nome_feriado: '',
    tipo: 'Nacional', // Nacional, Estadual, Municipal, Escolar (Recesso)
    data_inicio: '',
    duracao: 1
})

const isSaving = ref(false)

// Computed Data Fim based on Start Date + Duration (Same logic as Eventos)
const calculatedDataFim = computed(() => {
    if (!formData.value.data_inicio) return ''
    
    // Parse YYYY-MM-DD parts to avoid UTC/Timezone shifts
    const [year, month, day] = formData.value.data_inicio.split('-').map(Number)
    const date = new Date(year, month - 1, day) // Local time
    
    // Add duration days (duration 1 = same day, so add duration - 1)
    const durationIds = (parseInt(formData.value.duracao) || 1) - 1
    date.setDate(date.getDate() + durationIds)
    
    // Format back to YYYY-MM-DD
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, '0')
    const d = String(date.getDate()).padStart(2, '0')
    
    return `${y}-${m}-${d}`
})

// Initialize form
const initForm = () => {
    if (props.initialData) {
        const start = props.initialData.data_inicio ? new Date(props.initialData.data_inicio) : new Date()
        const end = props.initialData.data_fim ? new Date(props.initialData.data_fim) : new Date()
        
        // Calculate duration in days
        const diffTime = Math.abs(end - start)
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1 

        formData.value = {
            id: props.initialData.id,
            nome_feriado: props.initialData.nome_feriado || '',
            tipo: props.initialData.tipo || 'Nacional',
            data_inicio: props.initialData.data_inicio,
            duracao: diffDays
        }
    } else {
        // Default to today
        const today = new Date().toISOString().split('T')[0]
        formData.value = {
            nome_feriado: '',
            tipo: 'Nacional',
            data_inicio: today,
            duracao: 1
        }
    }
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        initForm()
    }
})

const handleCancel = () => {
    emit('close')
}

const handleSave = async () => {
    if (!formData.value.nome_feriado.trim()) {
        toast.showToast('O nome do feriado é obrigatório.', 'warning')
        return
    }
    if (!formData.value.data_inicio) {
        toast.showToast('A data de início é obrigatória.', 'warning')
        return
    }

    isSaving.value = true
    try {
        const payload = {
            ...formData.value,
            data_fim: calculatedDataFim.value
        }
        // Remove helper field
        delete payload.duracao

        const { success, message } = await $fetch('/api/estrutura_academica/feriados', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload
            }
        })

        if (success) {
            toast.showToast('Feriado salvo com sucesso!')
            emit('success')
            emit('close')
        }
    } catch (err) {
        console.error('Erro ao salvar feriado:', err)
        toast.showToast(err.data?.message || 'Erro ao salvar feriado.', 'error')
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
            <div class="relative bg-background w-full max-w-lg flex flex-col rounded-[var(--radius-md)] shadow-2xl border border-secondary/10 overflow-hidden transform transition-all text-text">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-div-15 shrink-0">
                    <div>
                        <h2 class="text-xl font-bold">{{ initialData ? 'Editar Feriado/Recesso' : 'Novo Feriado/Recesso' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Cadastre feriados nacionais, estaduais ou recessos escolares.</p>
                    </div>
                     <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="p-6 flex flex-col gap-6">
                    <ManagerField 
                        label="Nome do Feriado"
                        v-model="formData.nome_feriado"
                        placeholder="Ex: Natal, Carnaval, Recesso Escolar"
                        required
                    />

                    <div>
                        <ManagerField 
                            label="Tipo"
                            v-model="formData.tipo"
                            type="select"
                            :options="[
                                { value: 'Nacional', label: 'Feriado Nacional' },
                                { value: 'Estadual', label: 'Feriado Estadual' },
                                { value: 'Municipal', label: 'Feriado Municipal' },
                                { value: 'Escolar', label: 'Recesso Escolar' },
                                { value: 'Ponto Facultativo', label: 'Ponto Facultativo' }
                            ]"
                            required
                        />
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <ManagerField 
                            label="Data de Início"
                            v-model="formData.data_inicio"
                            type="date"
                            required
                        />
                        <ManagerField 
                            label="Duração (Dias)"
                            v-model="formData.duracao"
                            type="number"
                            min="1"
                            required
                        />
                    </div>

                    <div class="p-3 bg-div-15 rounded border border-secondary/10 text-xs text-secondary flex justify-between items-center">
                        <span class="font-bold uppercase tracking-wider">Término Previsto:</span>
                        <span class="font-mono bg-background px-2 py-1 rounded border border-secondary/10 text-text">
                            {{ calculatedDataFim ? calculatedDataFim.split('-').reverse().join('/') : '-' }}
                        </span>
                    </div>

                </div>

                <!-- Footer -->
                <div class="px-6 py-4 border-t border-secondary/10 flex items-center justify-end gap-3 bg-div-15 shrink-0">
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
                        {{ isSaving ? 'Salvando...' : 'Salvar Feriado' }}
                    </button>
                </div>

            </div>
        </div>
    </Teleport>
</template>
