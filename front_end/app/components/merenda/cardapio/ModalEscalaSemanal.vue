<script setup lang="ts">
import { ref, watch, computed, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps({
    isOpen: Boolean,
    initialData: Object // Contains: cardapio_grupo_id, ano, semana_iso, data_inicio, data_fim
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

const loading = ref(true)
const saving = ref(false)
const refeicoesTipos = ref([])
const pratos = ref([])
const gridData = ref({}) // Map: `${dia_indice}_${refeicao_tipo_id}` -> { id, prato_id, ... }

// Days of week (Monday to Friday, maybe Saturday/Sunday if needed, sticking to Mon-Fri for school context usually, currently 5 days)
const daysOfWeek = [
    { label: 'Segunda', index: 1 },
    { label: 'Terça', index: 2 },
    { label: 'Quarta', index: 3 },
    { label: 'Quinta', index: 4 },
    { label: 'Sexta', index: 5 }
]

// --- Fetch Helpers ---
// Fetch Meal Types
const { data: tiposData } = await useFetch('/api/merenda/tipos', {
    query: computed(() => ({ id_empresa: appStore.company?.empresa_id })),
    watch: [() => appStore.company?.empresa_id]
})

// Fetch Pratos
const { data: pratosData } = await useFetch('/api/merenda/pratos', {
    query: computed(() => ({ id_empresa: appStore.company?.empresa_id, limit: 1000 })),
    watch: [() => appStore.company?.empresa_id]
})

// Initialize Data
const initData = async () => {
    if (!props.initialData) return

    loading.value = true
    gridData.value = {}
    
    // Set Types & Pratos from fetch result if not setup yet (or reactivity handles it)
    refeicoesTipos.value = tiposData.value?.data || []
    pratos.value = pratosData.value?.data || []

    try {
        // Fetch existing grid data for this week/group
        // We need a specific endpoint for this: /api/merenda/cardapios/semanal/grid
        // Or generic RPC call
        const { data: grid, error } = await $fetch('/api/merenda/cardapios/semanal/grid', {
            params: {
                id_empresa: appStore.company.empresa_id,
                cardapio_grupo_id: props.initialData.cardapio_grupo_id,
                ano: props.initialData.ano,
                semana_iso: props.initialData.semana_iso
            }
        })
        
        if (grid && Array.isArray(grid)) {
            grid.forEach(item => {
                const key = `${item.dia_semana_indice}_${item.refeicao_tipo_id}`
                gridData.value[key] = { ...item } // clone
            })
        }
    } catch (err) {
        console.error('Erro ao carregar grid:', err)
        toast.showToast('Erro ao carregar dados da semana.', 'error')
    } finally {
        loading.value = false
    }
}

watch(() => props.isOpen, (val) => {
    if (val) initData()
})

const getCellData = (dayIndex, typeId) => {
    const key = `${dayIndex}_${typeId}`
    if (!gridData.value[key]) {
        // Initialize empty
        gridData.value[key] = {
            cardapio_grupo_id: props.initialData?.cardapio_grupo_id,
            ano: props.initialData?.ano,
            semana_iso: props.initialData?.semana_iso,
            dia_semana_indice: dayIndex,
            refeicao_tipo_id: typeId,
            prato_id: null,
            prato_alternativo_id: null,
            observacoes: ''
        }
    }
    return gridData.value[key]
}

const handleSave = async () => {
    saving.value = true
    try {
        // Convert gridData object to array for upsert
        const itemsToSave = Object.values(gridData.value).filter(item => {
             // Filter out empty items if you want optimization, but "deletion" logic in RPC relies on sending what is active.
             // If I don't send a cell, the RPC soft-deletes it?
             // The RPC "upsert_batch" does: 
             // "Soft-delete missing items for this week"
             // So I MUST send everything that should exist.
             // If a day has no prato, should I send it?
             // Logic: If prato_id is null, maybe don't send? 
             // But if I want to "clear" a cell that had data, I shouldn't send it. 
             // So only send items with prato_id.
             return item.prato_id != null
        }).map(item => {
             // Try to calculate exact date for p_dia_semana/u_dia_semana from initialData + dayIndex
             // initialData.data_inicio is the Monday of that week
             const date = new Date(props.initialData.data_inicio)
             // Adjust to specific day (Monday is index 1 in our logic? Check daysOfWeek)
             // If data_inicio is Monday, and dayIndex is 1 (Mon), offset is 0.
             const offset = item.dia_semana_indice - 1
             date.setDate(date.getDate() + offset)
             
             return {
                 ...item,
                 p_dia_semana: date.toISOString(), // Start of day
                 u_dia_semana: date.toISOString()  // End of day (simplification, backend uses timestamptz)
             }
        })

        const payload = {
            id_empresa: appStore.company.empresa_id,
            cardapio_grupo_id: props.initialData.cardapio_grupo_id,
            ano: props.initialData.ano,
            semana_iso: props.initialData.semana_iso,
            itens: itemsToSave
        }

        const { success, error } = await $fetch('/api/merenda/cardapios/semanal/upsert', {
            method: 'POST',
            body: payload
        })
        
        if (success || !error) {
            toast.showToast('Escala salva com sucesso!')
            emit('success')
            emit('close')
        }
    } catch (err) {
        console.error('Erro ao salvar escala:', err)
        toast.showToast('Erro ao salvar escala.', 'error')
    } finally {
        saving.value = false
    }
}
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <!-- Fullscreen Backdrop -->
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="emit('close')"></div>
            
            <!-- Modal (Large) -->
            <div class="relative bg-background w-full max-w-[95vw] h-[90vh] flex flex-col rounded shadow-2xl border border-secondary/10 overflow-hidden">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-div-15 shrink-0">
                    <div>
                        <h2 class="text-xl font-bold text-text">
                            Semana {{ initialData?.semana_iso }} ({{ initialData?.ano }})
                        </h2>
                        <p class="text-xs text-secondary mt-0.5">
                            {{ initialData?.cardapio_grupo_nome }} 
                        </p>
                    </div>
                    <div class="flex items-center gap-3">
                         <button @click="handleSave" :disabled="saving" class="px-6 py-2 rounded bg-primary text-white font-bold hover:brightness-110 active:scale-95 disabled:opacity-50 transition-all">
                            {{ saving ? 'Salvando...' : 'Salvar Planejamento' }}
                        </button>
                        <button @click="emit('close')" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                        </button>
                    </div>
                </div>

                <!-- Body (Grid) -->
                <div class="flex-1 overflow-auto bg-div-15/30 p-4">
                    <div v-if="loading" class="flex justify-center items-center h-full">
                         <div class="w-10 h-10 border-4 border-primary/20 border-t-primary rounded-full animate-spin"></div>
                    </div>

                    <div v-else class="min-w-[1000px]"> <!-- Force scroll on small screens -->
                        <table class="w-full border-collapse">
                            <thead>
                                <tr>
                                    <th class="p-4 text-left text-xs font-black uppercase tracking-wider text-secondary border-b border-div-30 w-32 bg-background sticky top-0 left-0 z-10">
                                        Refeição
                                    </th>
                                    <th v-for="day in daysOfWeek" :key="day.index" class="p-4 text-left text-xs font-black uppercase tracking-wider text-secondary border-b border-div-30 bg-background sticky top-0 z-0">
                                        {{ day.label }}
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="tipo in refeicoesTipos" :key="tipo.id" class="hover:bg-div-15 transition-colors group">
                                    <td class="p-4 border-b border-div-30 font-bold text-sm text-text sticky left-0 bg-background group-hover:bg-div-15 transition-colors z-10 border-r border-div-30/50">
                                        {{ tipo.nome }}
                                        <span class="block text-[10px] text-secondary font-normal mt-1">{{ tipo.horario_inicio?.slice(0,5) }}</span>
                                    </td>
                                    <td v-for="day in daysOfWeek" :key="day.index" class="p-2 border-b border-div-30 border-r border-div-30/50 last:border-r-0 relative">
                                        <!-- Cell Content -->
                                        <div class="flex flex-col gap-1">
                                            <select 
                                                v-model="getCellData(day.index, tipo.id).prato_id" 
                                                class="w-full bg-background border border-secondary/15 rounded text-xs px-2 py-1.5 focus:border-primary focus:ring-1 focus:ring-primary/20 outline-none"
                                            >
                                                <option :value="null">- Selecione -</option>
                                                <option v-for="prato in pratos" :key="prato.id" :value="prato.id">
                                                    {{ prato.nome }}
                                                </option>
                                            </select>
                                            
                                            <!-- Validations/Info could go here -->
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>
    </Teleport>
</template>
