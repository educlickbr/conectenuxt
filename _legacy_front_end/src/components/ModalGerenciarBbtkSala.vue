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

const formData = ref({ nome: '', predio_uuid: '', escola_id: null })
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

// Async Dropdown Logic for Predio
const predios = ref([])
const predioSearch = ref('')
const selectedPredioName = ref('')
const isSearchingPredio = ref(false)
const showPredioDropdown = ref(false)

// Reset predio if escola changes
watch(() => formData.value.escola_id, (newVal, oldVal) => {
    // Only reset if it's a user change or we are not initializing (difficult to distinguish here precisely without more flags, but basic check helps)
    // Actually, when initialData is loaded, we set escola_id. We don't want to reset fields then.
    // We can rely on isOpen logic to handle initial set, and here we handle SUBSEQUENT changes.
    // However, Vue watch fires on creation or change. 
    // Lets simple check: if we have a predio_uuid, and we changed school to something else, clear predio.
    // If we are strictly just setting up, logic in isOpen watcher handles "initial set".
    if (newVal !== oldVal && oldVal !== undefined) {
       // Check if the current predio belongs to the new school? 
       // Simplest: If user changes school, reset predio.
       // But this fires when we load initialData. 
       // We can use a flag isLoaded.
    }
})

// Better approach: Handle logic in the isOpen watcher mainly.
watch(() => props.isOpen, async (newVal) => {
    if (newVal) {
        await fetchEscolas()
        predioSearch.value = ''
        predios.value = []
        showPredioDropdown.value = false
        errorMessage.value = ''

        if (props.initialData) {
            // Edit mode
            formData.value = { 
                nome: props.initialData.nome,
                predio_uuid: props.initialData.predio_uuid,
                escola_id: props.initialData.escola_id // Provided by update sala_get_paginado
            }
            if (props.initialData.predio_nome) {
                selectedPredioName.value = props.initialData.predio_nome
            } else {
                 selectedPredioName.value = 'Prédio Selecionado'
            }
        } else {
            // New mode
            formData.value = { nome: '', predio_uuid: '', escola_id: null }
            selectedPredioName.value = ''
        }
    }
})

// When user MANUALLY selects a school (change event), we should clear predio
const onEscolaChange = () => {
    formData.value.predio_uuid = ''
    selectedPredioName.value = ''
    predioSearch.value = ''
}

const fetchPredios = async (query) => {
    // Must have school selected
    if (!formData.value.escola_id) return 
    
    isSearchingPredio.value = true
    try {
        const { data } = await supabase.rpc('bbtk_dim_predio_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: 1,
            p_limite_itens_pagina: 10,
            p_busca: query || '',
            p_id_escola: formData.value.escola_id
        })
        const result = Array.isArray(data) ? data[0] : data
        predios.value = result.itens || []
    } catch (e) { console.error(e) } finally { isSearchingPredio.value = false }
}

let debounceTimeout = null
watch(predioSearch, (newVal) => {
    if (!formData.value.escola_id) return

    if (debounceTimeout) clearTimeout(debounceTimeout)
    debounceTimeout = setTimeout(() => {
        // Fetch even if empty to show list of all buildings in school if user clicks/focuses (optional logic)
        // Here we require typing or just focus? Let's allow fetching all ("") if convenient?
        // Current logic: fetch if has text. 
        // Let's allow fetching even empty if focused, but here we watch text change.
        fetchPredios(newVal)
        showPredioDropdown.value = true
    }, 300)
})

const onPredioSearchFocus = () => {
    if (!formData.value.escola_id) {
        // maybe warn user?
        return
    }
    fetchPredios(predioSearch.value)
    showPredioDropdown.value = true
}

const selectPredio = (predio) => {
    formData.value.predio_uuid = predio.uuid
    selectedPredioName.value = predio.nome
    predioSearch.value = ''
    showPredioDropdown.value = false
}

const handleSave = async () => {
    errorMessage.value = ''
    if (!formData.value.escola_id) return errorMessage.value = 'Selecione uma Escola.'
    if (!formData.value.predio_uuid) return errorMessage.value = 'Selecione um Prédio.'
    if (!formData.value.nome || !formData.value.nome.trim()) return errorMessage.value = 'Nome da Sala é obrigatório.'

    isSaving.value = true
    try {
        const payload = { 
            uuid: props.initialData?.uuid, // If editing
            nome: formData.value.nome,
            predio_uuid: formData.value.predio_uuid
        }
        const { error } = await supabase.rpc('bbtk_dim_sala_upsert', {
            p_data: payload,
            p_id_empresa: appStore.id_empresa
        })
        if (error) throw error
        emit('success')
        emit('close')
        toast.showToast('Sala salva com sucesso.', 'success')
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
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Sala' : 'Nova Sala' }}</h2>
                <button @click="$emit('close')" class="p-2 rounded-lg hover:bg-div-30 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
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
                        <button @click="formData.predio_uuid = ''; selectedPredioName = ''" class="text-red-500 hover:text-red-700 text-xs px-2 py-1 rounded bg-red-500/10 hover:bg-red-500/20">Trocar</button>
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

                <!-- 3. Room Name Input -->
                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-secondary">Nome da Sala <span class="text-red-500">*</span></label>
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
