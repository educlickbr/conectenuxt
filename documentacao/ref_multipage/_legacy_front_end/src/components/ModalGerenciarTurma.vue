<script setup>
import { ref, watch, onMounted } from 'vue'
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

// State
const isLoading = ref(false)
const isSaving = ref(false)
const errorMessage = ref('')

// Dropdown lists
// Dropdown lists
const listaEscolas = ref([])
const listaAnos = ref([])
const listaClasses = ref([])
const listaHorarios = ref([])
const listaAnosLetivos = ref([])

// Form Data
const form = ref({
    id: null,
    id_escola: '',
    id_ano_etapa: '',
    id_classe: '',
    id_horario: '',
    ano: ''
})

// Generate Years
const generateYears = () => {
    const currentYear = new Date().getFullYear()
    const years = []
    for (let i = -2; i <= 3; i++) {
        years.push((currentYear + i).toString())
    }
    listaAnosLetivos.value = years.sort((a, b) => b - a)
}

// Initialization
const resetForm = () => {
    form.value = {
        id: null,
        id_escola: '',
        id_ano_etapa: '',
        id_classe: '',
        id_horario: '',
        ano: new Date().getFullYear().toString()
    }
    errorMessage.value = ''
}

const fetchData = async () => {
    isLoading.value = true
    generateYears()
    try {
        // Fetch all lists in parallel
        const [escolasRes, anosRes, classesRes, horariosRes] = await Promise.all([
            supabase.rpc('escolas_get_paginado', { p_id_empresa: appStore.id_empresa, p_pagina: 1, p_limite_itens_pagina: 1000 }),
            supabase.rpc('ano_etapa_get_paginado', { p_id_empresa: appStore.id_empresa, p_pagina: 1, p_limite_itens_pagina: 1000 }),
            supabase.rpc('classe_get_paginado', { p_id_empresa: appStore.id_empresa, p_pagina: 1, p_limite_itens_pagina: 1000 }),
            supabase.rpc('horarios_escola_get_paginado', { p_id_empresa: appStore.id_empresa, p_pagina: 1, p_limite_itens_pagina: 1000 })
        ])

        const parseRes = (res) => {
             if (res.error) throw res.error
             const data = res.data
             if (Array.isArray(data)) return data
             if (data && data.itens) return data.itens
             return []
        }

        listaEscolas.value = parseRes(escolasRes)
        listaAnos.value = parseRes(anosRes)
        listaClasses.value = parseRes(classesRes)
        listaHorarios.value = parseRes(horariosRes)

    } catch (error) {
        console.error('Erro ao carregar dados:', error)
        errorMessage.value = 'Erro ao carregar listas.'
    } finally {
        isLoading.value = false
    }
}

watch(() => props.isOpen, async (newVal) => {
    if (newVal) {
        resetForm()
        await fetchData()
        
        if (props.initialData) {
            form.value = {
                id: props.initialData.id,
                id_escola: props.initialData.id_escola,
                id_ano_etapa: props.initialData.id_ano_etapa,
                id_classe: props.initialData.id_classe,
                id_horario: props.initialData.id_horario,
                ano: props.initialData.ano || new Date().getFullYear().toString()
            }
        }
    }
})

// Save
const handleSave = async () => {
    errorMessage.value = ''
    if (!form.value.id_escola || !form.value.id_ano_etapa || !form.value.id_classe || !form.value.id_horario || !form.value.ano) {
        errorMessage.value = 'Preencha todos os campos obrigatórios.'
        return
    }

    isSaving.value = true
    try {
        const payload = {
            id: form.value.id,
            id_escola: form.value.id_escola,
            id_ano_etapa: form.value.id_ano_etapa,
            id_classe: form.value.id_classe,
            id_horario: form.value.id_horario,
            ano: form.value.ano
        }

        const { error } = await supabase.rpc('turmas_upsert', {
            p_id_empresa: appStore.id_empresa,
            p_turma: payload
        })

        if (error) throw error

        toast.showToast('Turma salva com sucesso!', 'success')
        emit('success')
        emit('close')
    } catch (error) {
        console.error('Erro ao salvar turma:', error)
        errorMessage.value = 'Erro ao salvar turma.'
        toast.showToast('Erro ao salvar.', 'error')
    } finally {
        isSaving.value = false
    }
}

const handleClose = () => {
    emit('close')
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-0 md:p-6" @click.self="handleClose">
        <div class="bg-background flex flex-col w-full h-full md:w-[90%] md:h-[90%] md:rounded-xl overflow-hidden shadow-2xl border border-secondary/20">
            
            <div class="flex items-center justify-between p-4 border-b border-secondary/20 bg-div-15 shrink-0">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Turma' : 'Nova Turma' }}</h2>
                <button @click="handleClose" class="p-2 text-secondary hover:text-text hover:bg-div-30 rounded-lg">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <div class="flex-1 overflow-y-auto p-6 bg-background">
                 <div v-if="errorMessage" class="p-3 bg-red-100/10 border border-red-500/50 text-red-500 rounded-lg text-sm mb-4">
                    {{ errorMessage }}
                 </div>

                 <div class="space-y-4">
                    <!-- Escola -->
                    <div class="flex flex-col gap-1">
                        <label class="text-sm font-medium text-secondary">Escola <span class="text-red-500">*</span></label>
                        <select v-model="form.id_escola" class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary">
                            <option value="" disabled>Selecione a Escola</option>
                            <option v-for="item in listaEscolas" :key="item.id" :value="item.id">{{ item.nome }}</option>
                        </select>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                         <!-- Ano/Etapa -->
                         <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Ano / Etapa <span class="text-red-500">*</span></label>
                             <select v-model="form.id_ano_etapa" class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary">
                                 <option value="" disabled>Selecione o Ano/Etapa</option>
                                 <option v-for="item in listaAnos" :key="item.id" :value="item.id">{{ item.nome }}</option>
                             </select>
                         </div>

                         <!-- Classe -->
                         <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Classe <span class="text-red-500">*</span></label>
                             <select v-model="form.id_classe" class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary">
                                 <option value="" disabled>Selecione a Classe</option>
                                 <option v-for="item in listaClasses" :key="item.id" :value="item.id">{{ item.nome }}</option>
                             </select>
                         </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <!-- Horario -->
                        <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Horário <span class="text-red-500">*</span></label>
                            <select v-model="form.id_horario" class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary">
                                <option value="" disabled>Selecione o Horário</option>
                                <option v-for="item in listaHorarios" :key="item.id" :value="item.id">
                                {{ item.periodo }} - {{ item.hora_completo || item.hora_inicio + ' - ' + item.hora_fim }}
                                </option>
                            </select>
                        </div>

                        <!-- Ano Letivo -->
                        <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Ano Letivo <span class="text-red-500">*</span></label>
                            <select v-model="form.ano" class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary">
                                <option value="" disabled>Selecione o Ano</option>
                                <option v-for="ano in listaAnosLetivos" :key="ano" :value="ano">{{ ano }}</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="p-4 bg-div-15 border-t border-secondary/20 flex justify-end gap-3 shrink-0">
                <button @click="handleClose" class="px-4 py-2 text-secondary font-medium hover:bg-div-30 rounded-lg transition-colors">Cancelar</button>
                <button 
                    @click="handleSave" 
                    :disabled="isSaving" 
                    class="px-6 py-2 bg-primary text-white font-bold rounded-lg hover:bg-primary-hover transition-colors flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                    <span v-if="isSaving" class="animate-spin">⌛</span>
                    Salvar
                </button>
            </div>
        </div>
    </div>
</template>
