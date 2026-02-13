<script setup>
import { ref, watch, computed } from 'vue'
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

const formData = ref({ nome: '', sala_uuid: '', predio_uuid: '', escola_id: null })
const isSaving = ref(false)
const errorMessage = ref('')

const escolas = ref([])
const fetchEscolas = async () => {
    try {
        const { data, error } = await supabase.rpc('escolas_com_predio_get', {
            p_id_empresa: appStore.id_empresa
        })
        if (error) throw error
        escolas.value = data || []
    } catch (err) {
        console.error('Erro ao buscar escolas:', err)
    }
}

// --- Predio Logic ---
const predios = ref([])
const predioSearch = ref('')
const selectedPredioName = ref('')
const isSearchingPredio = ref(false)
const showPredioDropdown = ref(false)

const fetchPredios = async (query) => {
    if (!formData.value.escola_id) return
    isSearchingPredio.value = true
    try {
        const { data } = await supabase.rpc('bbtk_dim_predio_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: 1,
            p_limite_itens_pagina: 20,
            p_busca: query || '',
            p_id_escola: formData.value.escola_id
        })
        const result = Array.isArray(data) ? data[0] : data
        // Filter is done in backend via p_id_escola usually or here if function not updated (it is updated)
        predios.value = result.itens || []
    } catch (e) { console.error(e) } finally { isSearchingPredio.value = false }
}

const selectPredio = (predio) => {
    formData.value.predio_uuid = predio.uuid
    selectedPredioName.value = predio.nome
    predioSearch.value = ''
    showPredioDropdown.value = false
    // Clear next level
    onPredioChange() 
}

// --- Sala Logic ---
const salas = ref([])
const salaSearch = ref('')
const selectedSalaName = ref('')
const isSearchingSala = ref(false)
const showSalaDropdown = ref(false)

const fetchSalas = async (query) => {
    if (!formData.value.predio_uuid) return
    isSearchingSala.value = true
    try {
        const { data } = await supabase.rpc('bbtk_dim_sala_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: 1,
            p_limite_itens_pagina: 20,
            p_busca: query,
            p_predio_uuid: formData.value.predio_uuid
        })
        const result = Array.isArray(data) ? data[0] : data
        salas.value = result.itens || []
    } catch (e) { console.error(e) } finally { isSearchingSala.value = false }
}

const selectSala = (sala) => {
    formData.value.sala_uuid = sala.uuid
    selectedSalaName.value = sala.nome
    salaSearch.value = ''
    showSalaDropdown.value = false
}

// --- Resets ---
const onEscolaChange = () => {
    formData.value.predio_uuid = ''
    selectedPredioName.value = ''
    predioSearch.value = ''
    onPredioChange()
}

const onPredioChange = () => {
    formData.value.sala_uuid = ''
    selectedSalaName.value = ''
    salaSearch.value = ''
}

// Retrieve data on open
watch(() => props.isOpen, async (newVal) => {
    if (newVal) {
        await fetchEscolas()
        predios.value = []
        salas.value = []
        showPredioDropdown.value = false
        showSalaDropdown.value = false
        predioSearch.value = ''
        salaSearch.value = ''
        
        if (props.initialData) {
            formData.value = {
                nome: props.initialData.nome,
                sala_uuid: props.initialData.sala_uuid,
                predio_uuid: props.initialData.predio_uuid,
                escola_id: props.initialData.escola_id
            }
            if (props.initialData.predio_nome) selectedPredioName.value = props.initialData.predio_nome
            else selectedPredioName.value = 'Prédio Selecionado'

            if (props.initialData.sala_nome) selectedSalaName.value = props.initialData.sala_nome
            else selectedSalaName.value = 'Sala Selecionada'
        } else {
            formData.value = { nome: '', sala_uuid: '', predio_uuid: '', escola_id: null }
            selectedPredioName.value = ''
            selectedSalaName.value = ''
        }
        errorMessage.value = ''
    }
})

// --- Watchers for Search ---
let debouncePredio = null
watch(predioSearch, (newVal) => {
    if (!formData.value.escola_id) return
    if (debouncePredio) clearTimeout(debouncePredio)
    debouncePredio = setTimeout(() => {
        fetchPredios(newVal)
        showPredioDropdown.value = true
    }, 300)
})

const onPredioSearchFocus = () => {
    if (!formData.value.escola_id) return
    fetchPredios(predioSearch.value)
    showPredioDropdown.value = true
}

let debounceSala = null
watch(salaSearch, (newVal) => {
    if (!formData.value.predio_uuid) return
    if (debounceSala) clearTimeout(debounceSala)
    debounceSala = setTimeout(() => {
        fetchSalas(newVal)
        showSalaDropdown.value = true
    }, 300)
})

const onSalaSearchFocus = () => {
    if (!formData.value.predio_uuid) return
    fetchSalas(salaSearch.value)
    showSalaDropdown.value = true
}


const handleSave = async () => {
    errorMessage.value = ''
    if (!formData.value.escola_id) return errorMessage.value = 'Selecione uma Escola.'
    if (!formData.value.predio_uuid) return errorMessage.value = 'Selecione um Prédio.'
    if (!formData.value.sala_uuid) return errorMessage.value = 'Selecione uma Sala.'
    if (!formData.value.nome || !formData.value.nome.trim()) return errorMessage.value = 'Nome obrigatório.'

    isSaving.value = true
    try {
        const payload = {
            uuid: props.initialData?.uuid,
            nome: formData.value.nome,
            sala_uuid: formData.value.sala_uuid 
        }
        const { error } = await supabase.rpc('bbtk_dim_estante_upsert', {
            p_data: payload,
            p_id_empresa: appStore.id_empresa
        })
        if (error) throw error
        emit('success')
        emit('close')
        toast.showToast('Estante salva com sucesso.', 'success')
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
        <div class="bg-background w-full md:w-[700px] rounded-xl overflow-hidden shadow-2xl border border-secondary/20">
            <div class="p-4 border-b border-secondary/20 bg-div-15 flex justify-between items-center">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Estante' : 'Nova Estante' }}</h2>
                <button @click="$emit('close')" class="p-2 rounded-lg hover:bg-div-30 text-secondary">X</button>
            </div>
            <div class="p-6 flex flex-col gap-4">
                <div v-if="errorMessage" class="p-3 bg-red-500/10 text-red-500 rounded-lg">{{ errorMessage }}</div>
                
                <!-- 1. School Select -->
                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-secondary">Escola <span class="text-red-500">*</span></label>
                    <select 
                        v-model="formData.escola_id" 
                        @change="onEscolaChange"
                        class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:border-primary focus:outline-none"
                    >
                        <option :value="null">Selecione uma escola...</option>
                        <option v-for="escola in escolas" :key="escola.id" :value="escola.id">{{ escola.nome }}</option>
                    </select>
                </div>

                <!-- 2. Building Async Select -->
                <div class="flex flex-col gap-1 relative">
                    <label class="text-sm font-medium text-secondary">Prédio <span class="text-red-500">*</span></label>
                    <div v-if="formData.predio_uuid" class="flex items-center gap-2 mb-2 p-2 bg-div-30 rounded-lg border border-primary/30">
                        <div class="flex-1 font-bold text-text">{{ selectedPredioName }}</div>
                        <button @click="formData.predio_uuid = ''; selectedPredioName = ''; onPredioChange()" class="text-red-500 hover:text-red-700 text-xs px-2 py-1 rounded bg-red-500/10 hover:bg-red-500/20">Trocar</button>
                    </div>
                     <div v-else class="relative">
                        <input 
                            type="text" 
                            v-model="predioSearch" 
                            @focus="onPredioSearchFocus"
                            :disabled="!formData.escola_id"
                            :placeholder="!formData.escola_id ? 'Selecione uma escola primeiro' : 'Selecione o prédio...'" 
                            class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:border-primary focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                        <div v-if="isSearchingPredio" class="absolute right-3 top-2.5"><span class="animate-spin text-sm">⌛</span></div>
                        <div v-if="showPredioDropdown && !formData.predio_uuid" class="absolute top-full left-0 right-0 z-20 bg-background border border-secondary/20 rounded-lg shadow-xl mt-1 max-h-48 overflow-y-auto">
                            <div v-if="predios.length === 0 && !isSearchingPredio" class="p-3 text-secondary text-sm text-center">Nenhum prédio encontrado nesta escola.</div>
                            <button 
                                v-for="predio in predios" 
                                :key="predio.uuid" 
                                @click="selectPredio(predio)"
                                class="w-full text-left p-3 hover:bg-div-30 transition-colors border-b border-secondary/10 last:border-0 text-text"
                            >
                                {{ predio.nome }}
                            </button>
                        </div>
                    </div>
                </div>

                <!-- 3. Sala Async Select -->
                 <div class="flex flex-col gap-1 relative">
                    <label class="text-sm font-medium text-secondary">Sala <span class="text-red-500">*</span></label>
                    <div v-if="formData.sala_uuid" class="flex items-center gap-2 mb-2 p-2 bg-div-30 rounded-lg border border-primary/30">
                        <div class="flex-1 font-bold text-text">{{ selectedSalaName }}</div>
                        <button @click="formData.sala_uuid = ''; selectedSalaName = ''" class="text-red-500 hover:text-red-700 text-xs px-2 py-1 rounded bg-red-500/10 hover:bg-red-500/20">Trocar</button>
                    </div>
                     <div v-else class="relative">
                        <input 
                            type="text" 
                            v-model="salaSearch" 
                            @focus="onSalaSearchFocus"
                            :disabled="!formData.predio_uuid"
                            :placeholder="!formData.predio_uuid ? 'Selecione um prédio primeiro' : 'Selecione a sala...'" 
                            class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:border-primary focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                        <div v-if="isSearchingSala" class="absolute right-3 top-2.5"><span class="animate-spin text-sm">⌛</span></div>
                        <div v-if="showSalaDropdown && !formData.sala_uuid" class="absolute top-full left-0 right-0 z-20 bg-background border border-secondary/20 rounded-lg shadow-xl mt-1 max-h-48 overflow-y-auto">
                            <div v-if="salas.length === 0 && !isSearchingSala" class="p-3 text-secondary text-sm text-center">Nenhuma sala encontrada neste prédio.</div>
                            <button 
                                v-for="sala in salas" 
                                :key="sala.uuid" 
                                @click="selectSala(sala)"
                                class="w-full text-left p-3 hover:bg-div-30 transition-colors border-b border-secondary/10 last:border-0 text-text"
                            >
                                {{ sala.nome }}
                            </button>
                        </div>
                    </div>
                </div>

                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-secondary">Nome da Estante <span class="text-red-500">*</span></label>
                    <input type="text" v-model="formData.nome" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:border-primary focus:outline-none">
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
