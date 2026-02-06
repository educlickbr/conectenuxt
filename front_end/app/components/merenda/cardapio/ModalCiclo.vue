<script setup>
import { ref, watch, computed } from 'vue'
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

const form = ref({
    id: null,
    nome: '',
    data_inicio: '',
    data_fim: '',
    etapas: [] // Array of ano_etapa_id
})

const isSaving = ref(false)
const errorMessage = ref('')

// --- Fetch Ano Etapas for Select ---
const { data: etapasData } = await useFetch('/api/estrutura_academica/ano_etapas', {
    query: computed(() => ({
        id_empresa: appStore.company?.empresa_id,
        limit: 100 // Fetch plenty
    })),
    watch: [() => appStore.company?.empresa_id]
})

const anoEtapas = computed(() => {
    // Adapter for different API responses
    const data = etapasData.value
    if (!data) return []
    if (data.items) return data.items
    if (data.data) return data.data // Some APIs wrap in data
    if (Array.isArray(data)) return data
    return []
})

// Initialize form
const initForm = () => {
    if (props.initialData) {
        // Parse dates safely (YYYY-MM-DD from API usually comes as string ISO)
        const startDate = props.initialData.data_inicio ? props.initialData.data_inicio.split('T')[0] : ''
        const endDate = props.initialData.data_fim ? props.initialData.data_fim.split('T')[0] : ''

        // Etapas might come as array of objects or strings/ids depending on the join
        // The RPC returns jsonb_agg(ae.nome) which is names, not IDs. 
        // CAUTION: The RPC 'mrd_cardapio_grupo_get_paginado' returns names! 
        // We need IDs to edit. 
        // ISSUE: The current GET RPC only returns names 'etapas': ["Nome 1", "Nome 2"].
        // We can't pre-populate the checkboxes with just names if we want to save IDs.
        // FIX: I need to update the RPC to return IDs as well if I want to edit properly.
        // For now, I will leave it empty on edit if I can't match, OR I match by name (risky).
        // Let's rely on the user re-selecting for now or assume I need to fetch details.
        // Actually, let's fix the RPC to return array of objects {id, nome} later if needed.
        // For now, I'll use what I have. If it's names, I can try to find the ID from `anoEtapas` list.
        
        // Let's try to map names back to IDs if possible
        let initialEtapas = []
        if (props.initialData.etapas && props.initialData.etapas.length) {
             initialEtapas = props.initialData.etapas.map(nome => {
                 const found = anoEtapas.value.find(ae => ae.nome === nome)
                 return found ? found.id : null
             }).filter(id => id)
        }

        form.value = {
            id: props.initialData.id,
            nome: props.initialData.nome || '',
            data_inicio: startDate,
            data_fim: endDate,
            etapas: initialEtapas
        }
    } else {
        const today = new Date().toISOString().split('T')[0]
        form.value = {
            id: null,
            nome: '',
            data_inicio: today,
            data_fim: '',
            etapas: []
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

const toggleEtapa = (id) => {
    const idx = form.value.etapas.indexOf(id)
    if (idx === -1) {
        form.value.etapas.push(id)
    } else {
        form.value.etapas.splice(idx, 1)
    }
}

const handleSave = async () => {
    // Validate
    if (!form.value.nome || !form.value.data_inicio || !form.value.data_fim) {
        errorMessage.value = 'Preencha todos os campos obrigatórios.'
        return
    }

    if (form.value.etapas.length === 0) {
        errorMessage.value = 'Selecione pelo menos uma etapa/série.'
        return
    }

    isSaving.value = true
    errorMessage.value = ''

    try {
        const payload = {
            id_empresa: appStore.company.empresa_id,
            data: {
                id: form.value.id,
                nome: form.value.nome,
                data_inicio: form.value.data_inicio, // API expects timestamptz, string YYYY-MM-DD works in Supabase casting usually
                data_fim: form.value.data_fim
            },
            etapas_ids: form.value.etapas // Need to handle this in Backend
        }
        
        // Wait, the current mrd_cardapio_grupo_upsert RPC DOES NOT handle etapas relations!
        // It only upserts the group table.
        // The mrd_cardapio_etapa table needs to be updated too.
        // I need to update the BFF (or create a new RPC) to handle this transactionally.
        // Or make two calls. Transactional RPC is better.
        // I'll update the BFF to call a NEW RPC or update existing one.
        // For this step I'll assume I'll fix the backend right after.
        
        const { success, message, error } = await $fetch('/api/merenda/cardapios/upsert', {
            method: 'POST',
            body: payload
        })

        if (success || !error) {
            toast.showToast('Ciclo salvo com sucesso!')
            emit('success')
            emit('close')
        } else {
            errorMessage.value = message || 'Erro ao salvar.'
        }
    } catch (err) {
        console.error('Erro ao salvar ciclo:', err)
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
            <div class="relative bg-background w-full max-w-2xl flex flex-col rounded shadow-2xl border border-secondary/10 overflow-hidden transform transition-all max-h-[90vh]">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-div-15 shrink-0">
                    <div>
                        <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Ciclo' : 'Novo Ciclo' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Defina o período e público-alvo do cardápio.</p>
                    </div>
                    <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body (Scrollable) -->
                <div class="p-6 overflow-y-auto flex flex-col gap-6">
                    <!-- Error Alert -->
                    <div v-if="errorMessage" class="p-4 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-xs flex items-start gap-2">
                        <span>{{ errorMessage }}</span>
                    </div>

                    <!-- Main Fields -->
                    <div class="grid grid-cols-1 gap-4">
                        <ManagerField 
                            label="Nome do Ciclo" 
                            v-model="form.nome" 
                            placeholder="Ex: Cardápio 1º Semestre 2026"
                            required
                        />

                        <div class="grid grid-cols-2 gap-4">
                            <ManagerField 
                                label="Data Início" 
                                v-model="form.data_inicio" 
                                type="date"
                                required
                            />
                            <ManagerField 
                                label="Data Fim" 
                                v-model="form.data_fim" 
                                type="date"
                                required
                            />
                        </div>
                    </div>

                    <!-- Etapas Selection -->
                    <div>
                        <label class="text-[10px] font-black text-secondary uppercase tracking-[0.15em] mb-2 block">
                            Público-Alvo (Etapas/Séries) <span class="text-primary">*</span>
                        </label>
                        
                        <div class="bg-div-15 border border-secondary/10 rounded overflow-hidden max-h-48 overflow-y-auto p-2 grid grid-cols-1 sm:grid-cols-2 gap-2">
                            <div v-if="anoEtapas.length === 0" class="col-span-full text-center py-4 text-xs text-secondary">
                                Nenhuma etapa encontrada.
                            </div>

                            <label 
                                v-for="etapa in anoEtapas" 
                                :key="etapa.id"
                                class="flex items-center gap-2 p-2 rounded hover:bg-background transition-colors cursor-pointer select-none"
                            >
                                <div class="relative flex items-center justify-center w-4 h-4">
                                    <input 
                                        type="checkbox" 
                                        :checked="form.etapas.includes(etapa.id)"
                                        @change="toggleEtapa(etapa.id)"
                                        class="peer appearance-none w-4 h-4 border border-secondary/40 rounded checked:bg-primary checked:border-primary transition-all"
                                    >
                                    <svg class="absolute w-2.5 h-2.5 text-white opacity-0 peer-checked:opacity-100 pointer-events-none transition-opacity" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                </div>
                                <span class="text-xs font-medium text-text">{{ etapa.nome }}</span>
                            </label>
                        </div>
                        <p class="text-[10px] text-secondary mt-1 text-right">
                            {{ form.etapas.length }} selecionado(s)
                        </p>
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
                        {{ isSaving ? 'Salvando...' : 'Salvar' }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
