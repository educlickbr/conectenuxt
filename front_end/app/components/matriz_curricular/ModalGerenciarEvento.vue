<script setup>
import { ref, computed, watch, onMounted } from 'vue'
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
    nome_evento: '',
    escopo: 'Rede',
    id_ano_etapa: null,
    data_inicio: '',
    duracao: 1,
    matriz_sobrepor: false,
})

const isSaving = ref(false)
const isLoadingAnos = ref(false)
const anosEtapaOptions = ref([])

// Computed Data Fim based on Start Date + Duration
const calculatedDataFim = computed(() => {
    if (!formData.value.data_inicio) return ''
    
    // Parse YYYY-MM-DD parts to avoid UTC/Timezone shifts
    const [year, month, day] = formData.value.data_inicio.split('-').map(Number)
    const date = new Date(year, month - 1, day) // Local construction
    
    // Add duration
    const durationIds = (parseInt(formData.value.duracao) || 1) - 1
    date.setDate(date.getDate() + durationIds)
    
    // Return YYYY-MM-DD manually to ensure local consistency
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, '0')
    const d = String(date.getDate()).padStart(2, '0')
    
    return `${y}-${m}-${d}`
})

// Initialize form
const initForm = () => {
    if (props.initialData) {
        // Initial Data (from backend) is TIMESTAMPTZ ISO string (e.g. 2025-01-01T00:00:00-03:00)
        // We need to extract the YYYY-MM-DD part relative to Sao Paulo for the input[type=date]
        
        let startDate = '';
        if (props.initialData.data_inicio) {
             const d = new Date(props.initialData.data_inicio);
             // Format to YYYY-MM-DD in SP timezone
             const parts = new Intl.DateTimeFormat('pt-BR', { 
                timeZone: 'America/Sao_Paulo', 
                year: 'numeric', month: '2-digit', day: '2-digit' 
            }).formatToParts(d);
            
            // Reassemble (formatToParts returns day, month, year separately)
            const p = {};
            parts.forEach(({type, value}) => p[type] = value);
            startDate = `${p.year}-${p.month}-${p.day}`;
        }

        const start = props.initialData.data_inicio ? new Date(props.initialData.data_inicio) : new Date()
        const end = props.initialData.data_fim ? new Date(props.initialData.data_fim) : new Date()
        
        // Duration: diff in days
        const diffTime = Math.abs(end - start)
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1 

        formData.value = {
            id: props.initialData.id,
            nome_evento: props.initialData.nome_evento || '',
            escopo: props.initialData.escopo || 'Rede',
            id_ano_etapa: props.initialData.id_ano_etapa || null,
            data_inicio: startDate,
            duracao: diffDays,
            matriz_sobrepor: !!props.initialData.matriz_sobrepor
        }
    } else {
        // Default to today
        const today = new Date().toISOString().split('T')[0]
        formData.value = {
            nome_evento: '',
            escopo: 'Rede',
            id_ano_etapa: null,
            data_inicio: today,
            duracao: 1,
            matriz_sobrepor: false
        }
    }
}

const fetchAnosEtapa = async () => {
    isLoadingAnos.value = true
    try {
        const { items } = await $fetch('/api/estrutura_academica/ano_etapa', {
            query: {
                id_empresa: appStore.company.empresa_id,
                limite: 100 // Fetch all relevant ones
            }
        })
        anosEtapaOptions.value = (items || []).map(a => ({
            value: a.id,
            label: a.nome
        }))
    } catch (err) {
        console.error('Erro ao buscar anos/etapas:', err)
        toast.showToast('Erro ao carregar anos escolares.', 'error')
    } finally {
        isLoadingAnos.value = false
    }
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        initForm()
        if (anosEtapaOptions.value.length === 0) {
            fetchAnosEtapa()
        }
    }
})

onMounted(() => {
    if (props.isOpen) {
        initForm()
        if (anosEtapaOptions.value.length === 0) {
            fetchAnosEtapa()
        }
    }
})

const handleCancel = () => {
    emit('close')
}

const handleSave = async () => {
    if (!formData.value.nome_evento.trim()) {
        toast.showToast('O nome do evento é obrigatório.', 'warning')
        return
    }
    if (!formData.value.data_inicio) {
        toast.showToast('A data de início é obrigatória.', 'warning')
        return
    }
    if (formData.value.escopo === 'Ano_Etapa' && !formData.value.id_ano_etapa) {
        toast.showToast('Selecione o Ano/Etapa para este evento.', 'warning')
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

        const { success, message } = await $fetch('/api/estrutura_academica/eventos', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload
            }
        })

        if (success) {
            toast.showToast('Evento salvo com sucesso!')
            emit('success')
            emit('close')
        }
    } catch (err) {
        console.error('Erro ao salvar evento:', err)
        toast.showToast(err.data?.message || 'Erro ao salvar evento.', 'error')
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
                        <h2 class="text-xl font-bold">{{ initialData ? 'Editar Evento' : 'Novo Evento' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Agende eventos para a rede ou turmas específicas.</p>
                    </div>
                     <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="p-6 flex flex-col gap-6">
                    <ManagerField 
                        label="Nome do Evento"
                        v-model="formData.nome_evento"
                        placeholder="Ex: Festa Junina, Reunião de Pais"
                        required
                    />

                    <div class="grid grid-cols-2 gap-4">
                        <ManagerField 
                            label="Escopo"
                            v-model="formData.escopo"
                            type="select"
                            :options="[
                                { value: 'Rede', label: 'Toda a Rede' },
                                { value: 'Ano_Etapa', label: 'Ano Escolar Específico' }
                            ]"
                        />

                        <div v-if="formData.escopo === 'Ano_Etapa'">
                             <ManagerField 
                                label="Ano / Etapa"
                                v-model="formData.id_ano_etapa"
                                type="select"
                                :options="anosEtapaOptions"
                                :loading="isLoadingAnos"
                                placeholder="Selecione..."
                                required
                            />
                        </div>
                    </div>
                    
                    <!-- Overlap Matrix Toggle -->
                    <div class="flex items-center gap-3 p-3 bg-div-15 rounded border border-secondary/10">
                         <label class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" v-model="formData.matriz_sobrepor" class="sr-only peer">
                            <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                        </label>
                        <div class="flex flex-col">
                            <span class="text-sm font-bold text-text">Sobrepor Matriz Curricular?</span>
                            <span class="text-[10px] text-secondary">Se marcado, este evento substituirá a rotina de aulas normal.</span>
                        </div>
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
                        {{ isSaving ? 'Salvando...' : 'Salvar Evento' }}
                    </button>
                </div>

            </div>
        </div>
    </Teleport>
</template>
