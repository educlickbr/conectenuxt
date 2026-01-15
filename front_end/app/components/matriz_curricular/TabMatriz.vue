<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import draggable from 'vuedraggable'
import MatrizFilterBar from './MatrizFilterBar.vue'
import { useToastStore } from '@/stores/toast'
import { useAppStore } from '@/stores/app'

const client = useSupabaseClient()
const appStore = useAppStore()
const toast = useToastStore()

// --- State ---
const filters = ref({
    escola_id: null,
    ano_etapa_id: null,
    turma_id: null // Nullable now!
})

const loading = ref(false)

// Data Models
interface Block {
    id_temp: string // Unique ID for draggable tracking
    id_componente: string
    componente_nome: string
    componente_cor: string
    db_id?: string // Real DB ID if saved
    escopo?: 'ano_etapa' | 'turma'
    is_inherited?: boolean
}

// Repository (Available Blocks)
interface RepoItem {
    componente_id: string
    componente_nome: string
    componente_cor: string
    blocks: Block[]
}
const repository = ref<RepoItem[]>([])

// Calendar Grid: 5 Days x 5 Slots
const days = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta']
const slots = [1, 2, 3, 4, 5] 
const calendarGrid = ref<Block[][][]>([])

// Init Grid
const initGrid = () => {
    const newGrid = []
    for (let d = 0; d < 5; d++) {
        const daySlots = []
        for (let s = 0; s < 5; s++) {
            daySlots.push([] as Block[])
        }
        newGrid.push(daySlots)
    }
    calendarGrid.value = newGrid
}

initGrid()

// --- Fetching Logic ---
const fetchData = async () => {
    // Only Año Etapa is strictly required now. Turma is optional.
    if (!filters.value.ano_etapa_id) return

    loading.value = true
    try {
        // 1. Fetch Carga Horaria (Definitions)
        const chResponse = await (client.rpc as any)('carga_horaria_get', {
            p_id_empresa: appStore.company?.empresa_id,
            p_id_ano_etapa: filters.value.ano_etapa_id
        })
        
        let chData: any[] = []
        if (chResponse.data && (chResponse.data as any).itens) chData = (chResponse.data as any).itens
        else if (Array.isArray(chResponse.data)) chData = chResponse.data

        // 2. Fetch Merged Schedule (Inheritance!)
        const { data: matrizItems, error: matrizError } = await (client.rpc as any)('mtz_matriz_curricular_get_merged', {
             p_id_empresa: appStore.company?.empresa_id,
             p_id_ano_etapa: filters.value.ano_etapa_id,
             // Safety check: ensure turma_id is a valid UUID (length 36) or null
             p_id_turma: (filters.value.turma_id && (filters.value.turma_id as string).length === 36) ? filters.value.turma_id : null
        })

        if (matrizError) throw matrizError
        
        const scheduled = (matrizItems as any)?.items || []

        // 3. Build Grid & Repository
        buildBoard(chData, scheduled)

    } catch (error) {
        console.error('Erro ao carregar dados da matriz:', error)
        toast.showToast('Falha ao carregar matriz.', 'error')
    } finally {
        loading.value = false
    }
}

const buildBoard = (cargaHoraria: any[], scheduledItems: any[]) => {
    // A. Reset Grid
    initGrid()
    
    // B. Map Scheduled Items to Grid
    // Count how many used per component (only count effective ones)
    const usedCounts: Record<string, number> = {}

    scheduledItems.forEach((item: any) => {
        // item: { id, dia_semana, aula, id_componente, ... escopo, is_inherited }
        const dayIndex = item.dia_semana - 1 
        const slotIndex = item.aula - 1

        if (dayIndex >= 0 && dayIndex < 5 && slotIndex >= 0 && slotIndex < 5) {
             // TS Guard
            if (calendarGrid.value[dayIndex] && calendarGrid.value[dayIndex][slotIndex]) {
                calendarGrid.value[dayIndex][slotIndex] = [{
                    id_temp: `db-${item.id}`,
                    db_id: item.id,
                    id_componente: item.id_componente,
                    componente_nome: item.componente_nome,
                    componente_cor: item.componente_cor,
                    escopo: item.escopo,
                    is_inherited: item.is_inherited
                }]
            }
        }

        // Track usage
        const compId = item.id_componente as string
        if (compId) {
            if (typeof usedCounts[compId] !== 'number') usedCounts[compId] = 0
            usedCounts[compId]++
        }
    })

    // C. Build Repository (Remaining Blocks)
    const newRepo: RepoItem[] = []
    
    cargaHoraria.forEach((ch: any) => {
        const total = ch.carga_horaria || 0
        const used = usedCounts[ch.id_componente] || 0
        const remaining = Math.max(0, total - used)

        if (remaining > 0) {
            const blocks: Block[] = []
            for (let i = 0; i < remaining; i++) {
                blocks.push({
                    id_temp: `repo-${ch.id_componente}-${i}-${Date.now()}`,
                    id_componente: ch.id_componente,
                    componente_nome: ch.componente_nome,
                    componente_cor: ch.componente_cor
                })
            }
            newRepo.push({
                componente_id: ch.id_componente,
                componente_nome: ch.componente_nome,
                componente_cor: ch.componente_cor,
                blocks: blocks
            })
        }
    })

    repository.value = newRepo
}


// --- Drag & Drop Handlers ---

// Handle Drop on Cell
const onCellChange = async (evt: any, dayIndex: number, slotIndex: number) => {
    if (evt.added) {
        const block = evt.added.element as Block
        const oldDbId = block.db_id

        // Rule: If we are in "Specific Mode" (Turma Selected), and we drop something:
        // 1. If the previous item in this slot (which triggered the drop) was INHERITED, we don't need to delete it. We just insert the OVERRIDE.
        // 2. If the previous item was SPECIFIC (same scope), we might need to update/delete it? The UPSERT handles conflict on (turma, day, slot).
        // 3. But wait, 'block' describes what we DROPPED.
        //    If 'block' came from another slot AND it was SPECIFIC, we must DELETE it from the old slot.
        //    If 'block' came from another slot AND it was INHERITED? We can't "move" an inherited block. 
        //    (UI should probably Clone inherited blocks if dragged? No, dragging implies moving).
        //    If I drag an Inherited block from Mon to Tue:
        //        - Mon becomes empty (OVERRIDE with nothing? or just reveal underlying? No, if I move it, I want Mon empty for this Turma).
        //        - Tue gets the Specific Override.
        //    Complex. Let's simplify:
        //    If I drag, I am creating a SPECIFIC record at Target.
        //    If the source had a DB_ID (specific or general), what happens?
        //    - If source was General (Inherited): I cannot "delete" the General record. It affects others.
        //      So effectively I am creating a NEW Specific record at Target. Use 'repo' logic?
        //      And Source? It reverts to "Inherited" state? Or if it WAS inherited, it stays there?
        //      Visually, dragging removes it from Source.
        //      If I assume "Specific Overrides", then Source needs an "Empty Override"?
        //      This is getting too complex for drag-and-drop.
        //    
        //    Simple approach:
        //    - If `block.is_inherited` is TRUE: Treat as NEW INSERT. DO NOT DELETE OLD ID.
        //    - If `block.escopo` matches current scope (e.g. both 'turma'): DELETE OLD ID, Insert New.
        //    - If `block.escopo` != current scope (moving General item while in Turma view?): Treat as NEW. Do not delete.
        
        const currentScope = filters.value.turma_id ? 'turma' : 'ano_etapa'

        // Check legacy deletion need
        if (oldDbId) {
             // Delete ONLY if it belongs to the current editing scope.
             // If I am editing Turma A, and I move a block that belongs to Turma A, I delete the old pos.
             // If I move a block that belongs to 'ano_etapa' (Inherited), I CANNOT delete it (it's global).
             if (block.escopo === currentScope && !block.is_inherited) {
                 await (client.rpc as any)('mtz_matriz_curricular_delete', {
                    p_id_empresa: appStore.company?.empresa_id,
                    p_id: oldDbId
                })
             }
        }

        await saveSlot(dayIndex, slotIndex, block)
    }
}

const saveSlot = async (dayIndex: number, slotIndex: number, block: Block) => {
    const dia = dayIndex + 1
    const aula = slotIndex + 1
    
    // determine target Payload
    // If filters.turma_id is set, we use it -> Scope 'turma'
    // Else -> Scope 'ano_etapa'
    
    try {
        const { data, error } = await useFetch('/api/estrutura_academica/matriz_curricular', {
             method: 'POST',
             body: {
                 id_empresa: appStore.company?.empresa_id,
                 data: {
                     id_ano_etapa: filters.value.ano_etapa_id,
                     id_turma: filters.value.turma_id || undefined,
                     ano: 2026, // TODO dynamic
                     dia_semana: dia,
                     aula: aula,
                     id_componente: block.id_componente,
                     id_usuario: appStore.user?.id // Send Auth ID (Backend will resolve to Profile ID)
                 }
             }
        })
        
        if (error.value) throw error.value
        
        // Response wrapper from BFF: { success: true, data: { status: 'success', data: { ... } }, ... }
        // The RPC returns { status: 'success', data: row }.
        // So BFF 'data' property holds the RPC result.
        const rpcResult = (data.value as any)?.data 
        const savedRecord = rpcResult?.data
        
        if (savedRecord && savedRecord.id) {
            block.db_id = savedRecord.id
            block.id_temp = `db-${savedRecord.id}`
            block.escopo = savedRecord.escopo
            block.is_inherited = false // It's now explicit record
        }

        toast.showToast('Horário atualizado', 'success')
        
    } catch (err) {
        console.error('Save error', err)
        toast.showToast('Erro ao salvar', 'error')
        fetchData() // Revert
    }
}

const onRepoChange = async (evt: any) => {
    // Moved back to Repo
    if (evt.added) {
        const block = evt.added.element as Block
        const currentScope = filters.value.turma_id ? 'turma' : 'ano_etapa'
        
        if (block.db_id) {
             // Logic: If it's a specific record matching current scope, delete it.
             // If it's inherited, we can't delete it globally.
             // (In UI, dragging inherited OFF means "Delete specific"? No, inherited has no specific.)
             // (It means "Create Empty Override"? We don't support "Empty Override" yet. It just reveals underlying.)
             // So dragging Inherited to Repo does nothing (it remains in DB, but UI removes it temporarily? Reload brings it back).
             // Actually if I drag inherited to Repo, I probably want to REMOVE the specific override if it existed?
             // But if it IS inherited, no specific exists. So I cannot "Remove" it from this Turma unless I create a "Blocked/Empty" record.
             // For now, let's assume we can only Delete what is matching Scope.
             
             if (block.escopo === currentScope && !block.is_inherited) {
                try {
                await (client.rpc as any)('mtz_matriz_curricular_delete', {
                    p_id_empresa: appStore.company?.empresa_id,
                    p_id: block.db_id
                })
                block.db_id = undefined
                } catch (err) {
                    console.error(err)
                    fetchData()
                }
             } else {
                 // Warn user? "Cannot remove inherited item globally from here"
                 if (block.is_inherited) {
                     toast.showToast('Item herdado do Ano/Etapa. Altere no escopo Geral.', 'error')
                     fetchData() // Restore it
                 }
             }
        }
        block.id_temp = `repo-${block.id_componente}-${Date.now()}`
    }
}

// Watch filters
watch(() => filters.value.turma_id, (newVal) => {
    // Refresh when switching Turma (or clearing it for General)
    fetchData()
})

watch(() => filters.value.ano_etapa_id, (newVal) => {
    if (newVal) fetchData()
    else {
        calendarGrid.value = []
        repository.value = []
        initGrid()
    }
})

</script>

<template>
    <div class="p-4 space-y-4">
        <MatrizFilterBar v-model="filters" />

        <!-- Info Bar about Scope -->
        <div v-if="filters.ano_etapa_id" class="px-2 mb-2 flex items-center gap-2 text-sm">
             <span v-if="!filters.turma_id" class="px-2 py-1 bg-yellow-100 text-yellow-800 rounded font-bold border border-yellow-200">
                 Modo Geral (Ano/Etapa)
             </span>
             <span v-else class="px-2 py-1 bg-blue-100 text-blue-800 rounded font-bold border border-blue-200">
                 Modo Específico (Turma)
             </span>
             <span class="text-gray-500 text-xs">
                 {{ !filters.turma_id ? 'As alterações aqui aplicam a TODAS as turmas deste ano.' : 'As alterações aqui se sobrepõem ao geral.' }}
             </span>
        </div>

        <div v-if="filters.ano_etapa_id" class="grid grid-cols-1 lg:grid-cols-4 gap-6 h-[calc(100vh-280px)]">
            
            <!-- Repository (Left) -->
            <div class="lg:col-span-1 border-r pr-4 overflow-y-auto custom-scrollbar">
                <h3 class="font-bold text-gray-400 mb-4 px-2">Disciplinas</h3>
                
                <div v-if="loading" class="space-y-2">
                    <div v-for="i in 5" :key="i" class="h-12 bg-surface-1 rounded animate-pulse"></div>
                </div>

                <div v-else class="space-y-6">
                    <div v-for="repoItem in repository" :key="repoItem.componente_id">
                        <div class="flex items-center justify-between text-xs text-gray-500 mb-2 uppercase tracking-wider px-1">
                            <span>{{ repoItem.componente_nome }}</span>
                            <span>{{ repoItem.blocks.length }} aulas</span>
                        </div>
                        
                        <draggable 
                            :list="repoItem.blocks" 
                            group="matriz" 
                            item-key="id_temp"
                            class="flex flex-col gap-2 min-h-[50px] p-1 rounded hover:bg-surface-1 transition-colors"
                            @change="onRepoChange"
                        >
                            <template #item="{ element }">
                                <div 
                                    class="p-3 rounded-lg shadow-sm cursor-grab active:cursor-grabbing text-sm font-medium border-l-4 bg-surface text-white hover:brightness-110 transition-all transform hover:-translate-y-0.5"
                                    :style="{ borderLeftColor: element.componente_cor || '#ccc' }"
                                >
                                    {{ element.componente_nome }}
                                </div>
                            </template>
                        </draggable>
                    </div>
                </div>
            </div>

            <!-- Calendar (Right) -->
            <div class="lg:col-span-3 flex flex-col h-full overflow-hidden">
                <!-- Header -->
                <div class="grid grid-cols-5 gap-2 mb-2 text-center">
                    <div v-for="day in days" :key="day" class="font-bold text-gray-400 py-2 border-b border-gray-700">
                        {{ day }}
                    </div>
                </div>

                <!-- Grid -->
                <div class="grid grid-cols-5 gap-2 flex-1 overflow-y-auto custom-scrollbar content-start">
                    
                    <!-- Columns by Day -->
                    <div v-for="(dayName, dIndex) in days" :key="dIndex" class="space-y-2">
                        
                        <!-- Rows by Slot -->
                        <div v-for="(slotNum, sIndex) in slots" :key="sIndex" class="relative group">
                            <!-- Slot Label -->
                            <div v-if="dIndex === 0" class="absolute -left-8 top-1/2 -translate-y-1/2 text-xs text-gray-600 w-6 text-right">
                                {{ slotNum }}º
                            </div>

                            <draggable
                                :list="calendarGrid[dIndex]?.[sIndex] || []"
                                group="matriz"
                                item-key="id_temp"
                                class="h-16 md:h-20 lg:h-24 bg-surface-1 rounded-xl border border-transparent hover:border-primary/20 transition-colors relative"
                                :class="{'bg-black/20': (calendarGrid[dIndex]?.[sIndex] || []).length === 0}"
                                :data-day="dIndex"
                                :data-slot="sIndex"
                                @change="(evt: any) => onCellChange(evt, dIndex, sIndex)"
                            >
                                <template #item="{ element }">
                                    <div 
                                        class="h-full w-full p-2 rounded-xl cursor-grab active:cursor-grabbing flex flex-col justify-center items-center text-center leading-tight bg-surface text-white border-b-4 shadow-sm relative overflow-hidden"
                                        :style="{ borderBottomColor: element.componente_cor || '#ccc' }"
                                    >
                                        <!-- Inheritance Indicator -->
                                        <div v-if="element.is_inherited" class="absolute top-1 right-1 text-[9px] bg-black/40 px-1 rounded text-white/80" title="Herdado do Modelo Geral">
                                            (H)
                                        </div>
                                        <div v-else-if="filters.turma_id" class="absolute top-1 right-1 text-[9px] bg-blue-500/80 px-1 rounded text-white" title="Específico para esta Turma">
                                            (E)
                                        </div>

                                        <span class="text-xs md:text-sm font-semibold line-clamp-2">
                                            {{ element.componente_nome }}
                                        </span>
                                    </div>
                                </template>
                            </draggable>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <div v-else class="text-center py-20 text-gray-500">
            <Icon name="ph:chalkboard-teacher" size="48" class="mb-4 opacity-50" />
            <p>Selecione um Ano/Etapa para gerenciar o horário.</p>
        </div>
    </div>
</template>

<style scoped>
.custom-scrollbar::-webkit-scrollbar {
  width: 6px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent; 
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background-color: rgba(156, 163, 175, 0.3);
  border-radius: 20px;
}
</style>
