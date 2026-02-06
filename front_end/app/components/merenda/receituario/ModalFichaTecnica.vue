<script setup>
import { ref, watch, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps({
    isOpen: Boolean,
    initialData: Object // { prato_id, prato_nome, ... }
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

const fichaItems = ref([])
const isSaving = ref(false)
const isLoading = ref(false)
const errorMessage = ref('')

// --- Alimentos for Select ---
const { data: alimentosData } = await useFetch('/api/merenda/alimentos', {
    query: computed(() => ({
        id_empresa: appStore.company?.empresa_id,
        page: 1,
        limit: 1000
    })),
    watch: [() => appStore.company?.empresa_id]
})

const alimentos = computed(() => alimentosData.value?.data || [])

// Initialize form
const initForm = async () => {
    if (!props.initialData?.prato_id) return
    
    isLoading.value = true
    try {
        const data = await $fetch('/api/merenda/fichastecnicas/by-prato', {
            query: {
                id_empresa: appStore.company.empresa_id,
                prato_id: props.initialData.prato_id
            }
        })
        fichaItems.value = data || []
    } catch (err) {
        console.error('Error loading ficha:', err)
        fichaItems.value = []
    } finally {
        isLoading.value = false
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

const addIngredient = () => {
    fichaItems.value.push({
        id: null,
        alimento_id: null,
        gramagem_per_capita: 0,
        modo_preparo_complementar: '',
        ordem_adicao: fichaItems.value.length,
        opcional: false,
        substituivel_por: null
    })
}

const removeIngredient = (index) => {
    fichaItems.value.splice(index, 1)
}

const handleSave = async () => {
    if (!props.initialData?.prato_id) {
        errorMessage.value = 'Prato não identificado.'
        return
    }

    // Validate at least one ingredient
    if (fichaItems.value.length === 0) {
        errorMessage.value = 'Adicione pelo menos um ingrediente.'
        return
    }

    // Validate all ingredients have alimento_id
    const hasInvalidItems = fichaItems.value.some(item => !item.alimento_id)
    if (hasInvalidItems) {
        errorMessage.value = 'Todos os ingredientes devem ter um alimento selecionado.'
        return
    }

    isSaving.value = true
    errorMessage.value = ''

    try {
        const { success, message, error } = await $fetch('/api/merenda/fichastecnicas/batch', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                prato_id: props.initialData.prato_id,
                itens: fichaItems.value
            }
        })

        if (success) {
            toast.showToast('Ficha técnica salva com sucesso!')
            emit('success')
            emit('close')
        } else {
            if (error) throw new Error(message || 'Erro ao salvar.')
            toast.showToast('Ficha técnica salva com sucesso!')
            emit('success')
            emit('close')
        }
    } catch (err) {
        console.error('Erro ao salvar ficha técnica:', err)
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
            <div class="relative bg-background w-full max-w-4xl flex flex-col rounded shadow-2xl border border-secondary/10 overflow-hidden transform transition-all max-h-[90vh]">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-div-15 shrink-0">
                    <div>
                        <h2 class="text-xl font-bold text-text">Ficha Técnica: {{ initialData?.prato_nome }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Gerencie os ingredientes e quantidades deste prato.</p>
                    </div>
                    <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body (Scrollable) -->
                <div class="p-6 overflow-y-auto">
                    <!-- Error Alert -->
                    <div v-if="errorMessage" class="p-4 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-xs flex items-start gap-2 mb-4">
                        <span>{{ errorMessage }}</span>
                    </div>

                    <!-- Loading State -->
                    <div v-if="isLoading" class="flex items-center justify-center py-12">
                        <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin"></div>
                    </div>

                    <!-- Empty State -->
                    <div v-else-if="fichaItems.length === 0" class="text-center py-12">
                        <p class="text-secondary mb-4">Nenhum ingrediente adicionado ainda.</p>
                        <button @click="addIngredient" class="px-4 py-2 bg-primary text-white rounded text-xs font-bold hover:brightness-110 transition-all">
                            + Adicionar Primeiro Ingrediente
                        </button>
                    </div>

                    <!-- Ingredients List -->
                    <div v-else class="flex flex-col gap-4">
                        <div class="flex items-center justify-between mb-2">
                            <h3 class="text-sm font-bold text-text">Ingredientes ({{ fichaItems.length }})</h3>
                            <button @click="addIngredient" class="px-3 py-1.5 bg-primary text-white rounded text-xs font-bold hover:brightness-110 transition-all">
                                + Adicionar
                            </button>
                        </div>

                        <div
                            v-for="(item, index) in fichaItems"
                            :key="index"
                            class="bg-div-15 p-4 rounded border border-div-30 flex items-start gap-4"
                        >
                            <div class="flex-1 grid grid-cols-1 md:grid-cols-3 gap-3">
                                <div class="md:col-span-2">
                                    <label class="text-[10px] font-black text-secondary uppercase tracking-wider mb-1 block">Alimento *</label>
                                    <select v-model="item.alimento_id" class="w-full px-3 py-2 bg-background border border-secondary/30 rounded text-sm">
                                        <option :value="null">Selecione um alimento...</option>
                                        <option v-for="alimento in alimentos" :key="alimento.id" :value="alimento.id">
                                            {{ alimento.nome }} ({{ alimento.unidade_medida }})
                                        </option>
                                    </select>
                                </div>
                                <div>
                                    <label class="text-[10px] font-black text-secondary uppercase tracking-wider mb-1 block">Gramagem (per capita)</label>
                                    <input v-model="item.gramagem_per_capita" type="number" step="0.01" class="w-full px-3 py-2 bg-background border border-secondary/30 rounded text-sm" placeholder="0.00">
                                </div>
                                <div class="md:col-span-2">
                                    <label class="text-[10px] font-black text-secondary uppercase tracking-wider mb-1 block">Modo de Preparo Complementar</label>
                                    <input v-model="item.modo_preparo_complementar" type="text" class="w-full px-3 py-2 bg-background border border-secondary/30 rounded text-sm" placeholder="Ex: Picar em cubos">
                                </div>
                                <div>
                                    <label class="text-[10px] font-black text-secondary uppercase tracking-wider mb-1 block">Ordem</label>
                                    <input v-model="item.ordem_adicao" type="number" class="w-full px-3 py-2 bg-background border border-secondary/30 rounded text-sm" placeholder="0">
                                </div>
                            </div>
                            <button @click="removeIngredient(index)" class="p-2 text-red-500 hover:bg-red-500/10 rounded transition-colors shrink-0 mt-6">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                            </button>
                        </div>
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
                        {{ isSaving ? 'Salvando...' : 'Salvar Ficha' }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
