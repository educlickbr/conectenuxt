<script setup>
import { ref, onMounted, computed, watch } from 'vue'
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

const formData = ref({})
const isSaving = ref(false)
const errorMessage = ref('')

// Time Picker State
const timeStart = ref({ h: '07', m: '00' })
const timeEnd = ref({ h: '12', m: '00' })

// Options Generation
const hours = Array.from({ length: 24 }, (_, i) => i.toString().padStart(2, '0'))
const minutes = Array.from({ length: 60 }, (_, i) => i.toString().padStart(2, '0'))

const periodos = [
    { label: 'Matutino', value: 'Matutino' },
    { label: 'Vespertino', value: 'Vespertino' },
    { label: 'Noturno', value: 'Noturno' },
    { label: 'Integral', value: 'Integral' }
]

// Initialize form data
const initFormData = () => {
    errorMessage.value = ''
    
    if (props.initialData) {
        formData.value = { ...props.initialData }
        
        // Parse Existing Times
        if (formData.value.hora_inicio) {
            const [h, m] = formData.value.hora_inicio.split(':')
            timeStart.value = { h: h || '07', m: m || '00' }
        }
        if (formData.value.hora_fim) {
            const [h, m] = formData.value.hora_fim.split(':')
            timeEnd.value = { h: h || '12', m: m || '00' }
        }
    } else {
        // Defaults
        formData.value = {
            id: null,
            nome: '',
            descricao: '',
            periodo: 'Matutino',
            hora_inicio: '07:00',
            hora_fim: '12:00',
            hora_completo: '07:00 - 12:00'
        }
        timeStart.value = { h: '07', m: '00' }
        timeEnd.value = { h: '12', m: '00' }
    }
    
    updateComputedFields()
}

const updateComputedFields = () => {
    const start = `${timeStart.value.h}:${timeStart.value.m}`
    const end = `${timeEnd.value.h}:${timeEnd.value.m}`
    
    formData.value.hora_inicio = start
    formData.value.hora_fim = end
    formData.value.hora_completo = `${start} - ${end}`
    
    // Internal name hidden field -> REMOVED auto-generation
    // formData.value.nome = `Horário: ${formData.value.hora_completo}`
    
    console.log('Fields Updated:', formData.value) // Debugging
}

// Watchers for time changes
watch([timeStart, timeEnd], () => {
    updateComputedFields()
}, { deep: true })

const handleCancel = () => {
    initFormData()
    emit('close')
}

const handleSave = async () => {
    errorMessage.value = ''
    updateComputedFields() // Ensure latest state

    // Validation
    if (!formData.value.nome || !formData.value.nome.toString().trim()) {
        errorMessage.value = 'O campo "Nome" é obrigatório.'
        return
    }

    if (!formData.value.periodo) {
        errorMessage.value = 'O campo "período" é obrigatório.'
        return
    }

    isSaving.value = true
    try {
        const payload = { 
            ...formData.value 
        }

        // Call Upsert
        const { data, error } = await supabase.rpc('horarios_escola_upsert', {
            p_data: payload,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        // Success
        initFormData()
        emit('success')
        emit('close')
        toast.showToast('Horário salvo com sucesso.', 'success')

    } catch (err) {
        console.error('Erro ao salvar horário:', err)
        errorMessage.value = err.message || 'Erro ao salvar registro.'
        toast.showToast('Erro na solicitação', 'error')
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

onMounted(() => {
    if (props.isOpen) {
        initFormData()
    }
})

</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-0 md:p-6" @click.self="handleCancel">
        
        <!-- Modal Container -->
        <div class="bg-background flex flex-col w-full h-full md:w-[600px] md:h-auto md:max-h-[90%] md:rounded-xl overflow-hidden shadow-2xl border border-secondary/20">
            
            <!-- Header -->
            <div class="flex items-center justify-between p-4 border-b border-secondary/20 bg-div-15 shrink-0">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Horário' : 'Novo Horário' }}</h2>
                <button 
                    @click="handleCancel" 
                    class="p-2 text-secondary hover:text-text hover:bg-div-30 rounded-lg transition-colors"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-4 md:p-6 flex flex-col gap-6">
                
                <div v-if="errorMessage" class="p-3 rounded-lg bg-red-500/10 border border-red-500/30 text-red-500 text-sm">
                    {{ errorMessage }}
                </div>

                <!-- 0. Nome (Manual Input) -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm font-bold text-secondary uppercase tracking-wider">Nome</label>
                    <input 
                        type="text" 
                        v-model="formData.nome"
                        placeholder="Ex: Turno da Manhã A"
                        class="w-full px-4 py-3 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/50"
                    >
                </div>

                <!-- 1. Período (Full Width) -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm font-bold text-secondary uppercase tracking-wider">Período</label>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-2">
                        <button 
                            v-for="p in periodos" 
                            :key="p.value"
                            @click="formData.periodo = p.value"
                            class="px-3 py-2 rounded-lg border text-sm font-medium transition-all"
                            :class="formData.periodo === p.value 
                                ? 'bg-primary/20 border-primary text-primary' 
                                : 'bg-div-15 border-secondary/20 text-secondary hover:border-secondary/50'"
                        >
                            {{ p.label }}
                        </button>
                    </div>
                </div>

                <!-- 2. Horários (Same Line) -->
                 <div class="flex flex-col gap-2">
                     <label class="text-sm font-bold text-secondary uppercase tracking-wider">Definição de Horário</label>
                     
                     <div class="bg-div-15 p-4 rounded-xl border border-secondary/20 flex flex-col md:flex-row items-center gap-4 md:gap-8 justify-center">
                         
                         <!-- Hora Início -->
                         <div class="flex flex-col items-center gap-1">
                             <span class="text-xs text-secondary font-medium uppercase">Início</span>
                             <div class="flex items-center gap-1">
                                 <!-- Hours -->
                                 <select v-model="timeStart.h" class="bg-background border border-secondary/30 rounded-lg px-2 py-2 text-lg font-bold text-text focus:border-primary focus:outline-none appearance-none cursor-pointer text-center w-16">
                                     <option v-for="h in hours" :key="h" :value="h">{{ h }}</option>
                                 </select>
                                 <span class="text-text font-bold text-lg">:</span>
                                 <!-- Minutes -->
                                 <select v-model="timeStart.m" class="bg-background border border-secondary/30 rounded-lg px-2 py-2 text-lg font-bold text-text focus:border-primary focus:outline-none appearance-none cursor-pointer text-center w-16">
                                     <option v-for="m in minutes" :key="m" :value="m">{{ m }}</option>
                                 </select>
                             </div>
                         </div>

                         <!-- Separator -->
                         <div class="hidden md:block w-px h-12 bg-secondary/20"></div>
                         
                         <!-- Hora Fim -->
                         <div class="flex flex-col items-center gap-1">
                             <span class="text-xs text-secondary font-medium uppercase">Fim</span>
                             <div class="flex items-center gap-1">
                                 <!-- Hours -->
                                 <select v-model="timeEnd.h" class="bg-background border border-secondary/30 rounded-lg px-2 py-2 text-lg font-bold text-text focus:border-primary focus:outline-none appearance-none cursor-pointer text-center w-16">
                                     <option v-for="h in hours" :key="h" :value="h">{{ h }}</option>
                                 </select>
                                 <span class="text-text font-bold text-lg">:</span>
                                 <!-- Minutes -->
                                 <select v-model="timeEnd.m" class="bg-background border border-secondary/30 rounded-lg px-2 py-2 text-lg font-bold text-text focus:border-primary focus:outline-none appearance-none cursor-pointer text-center w-16">
                                     <option v-for="m in minutes" :key="m" :value="m">{{ m }}</option>
                                 </select>
                             </div>
                         </div>

                     </div>
                 </div>

                <!-- 3. Visualização (Horário Completo) -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm font-bold text-secondary uppercase tracking-wider">Preview</label>
                    <div class="w-full px-4 py-3 bg-div-30 border border-secondary/30 rounded-lg text-text font-mono text-center text-lg tracking-widest">
                        {{ formData.hora_completo }}
                    </div>
                    <p class="text-xs text-secondary text-center">Este texto será exibido nas listagens.</p>
                </div>

                <!-- 4. Descrição (Textarea) -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm font-bold text-secondary uppercase tracking-wider">Descrição</label>
                    <textarea 
                        v-model="formData.descricao"
                        rows="4"
                        placeholder="Adicione observações ou detalhes sobre este horário..."
                        class="w-full px-4 py-3 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/50 resize-none"
                    ></textarea>
                </div>

            </div>

            <!-- Footer -->
            <div class="flex items-center justify-end gap-3 p-4 border-t border-secondary/20 bg-div-15 shrink-0">
                <button 
                    @click="handleCancel"
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
                    Salvar Horário
                </button>
            </div>

        </div>
    </div>
</template>
