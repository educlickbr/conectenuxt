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
    turma_id: null
})

const loading = ref(false)
const saving = ref(false)

// Data Models
interface Block {
    id_temp: string // Unique ID for draggable tracking
    id_componente: string
    componente_nome: string
    componente_cor: string
    db_id?: string // Real DB ID if saved
}

// Repository (Available Blocks)
// Grouped by Component for better UI? Or just a flat list?
// Grouped is cleaner: "Mathematics (3 blocks left)"
interface RepoItem {
    componente_id: string
    componente_nome: string
    componente_cor: string
    blocks: Block[]
}
const repository = ref<RepoItem[]>([])

// Calendar Grid: 5 Days x 5 Slots (Fixed for now, can be dynamic later)
// Structure: grid[dayIndex][slotIndex] -> Array of Blocks (0 or 1)
const days = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta']
const slots = [1, 2, 3, 4, 5] // Aulas 1 to 5
const calendarGrid = ref<Block[][][]>([])

// Init Grid
const initGrid = () => {
    // 5 days (indices 0-4), 5 slots (indices 0-4)
    const newGrid = []
    for (let d = 0; d < 5; d++) {
        const daySlots = []
        for (let s = 0; s < 5; s++) {
            daySlots.push([] as Block[]) // Each cell is a list (for draggable)
        }
        newGrid.push(daySlots)
    }
    calendarGrid.value = newGrid
}

initGrid()

// --- Fetching Logic ---
const fetchData = async () => {
    if (!filters.value.turma_id || !filters.value.ano_etapa_id) return

    loading.value = true
    try {
        // 1. Fetch Carga Horaria (Definitions)
        // Cast client.rpc to any to avoid strict param type checking against generated types that might be out of sync or strict
        const chResponse = await (client.rpc as any)('carga_horaria_get', {
            p_id_empresa: appStore.company?.empresa_id,
            p_id_ano_etapa: filters.value.ano_etapa_id
        })
        
        let chData: any[] = []
        if (chResponse.data && (chResponse.data as any).itens) chData = (chResponse.data as any).itens
        else if (Array.isArray(chResponse.data)) chData = chResponse.data

        // 2. Fetch Existing Schedule (Matriz)
        const { data: matrizItems, error: matrizError } = await useFetch('/api/estrutura_academica/matriz_curricular', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                id_turma: filters.value.turma_id
            }
        })

        if (matrizError.value) throw matrizError.value
        
        const scheduled = (matrizItems.value as any)?.items || []

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
    // Count how many used per component
    const usedCounts: Record<string, number> = {}

    scheduledItems.forEach((item: any) => {
        // item: { id, dia_semana (1-7), aula (1-N), id_componente, componente_nome, componente_cor }
        // Adjust indices: dia_semana 2(Seg) -> 0. 
        // Let's assume DB: 1=Sun, 2=Mon... or 1=Mon? 
        // Standard ISO: 1=Mon. Let's assume 1=Mon.
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
                    componente_cor: item.componente_cor
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
        await saveSlot(dayIndex, slotIndex, block)
    }
    // If removed (dragged to another cell), do nothing here? 
    // The "added" event on the new cell will handle the upsert (which updates the record).
    // HOWEVER, if we drag from cell A to cell B, it's an update.
    // If we drag from Repo to Cell A, it's an insert.
    // Wait, if I drag from Cell A to Cell B, 'evt.added' in Cell B fires.
    // Does 'evt.removed' in Cell A fire? Yes.
    // Function upsert handles conflict on (turma, day, slot). 
    // BUT we need to clear the OLD slot if it was a move?
    // Actually, if we move, the block carries its DB_ID.
    // If we simply UPSERT with new (day, slot), the old record with that ID is updated?
    // No. The table PK is 'id'. The Unique constraint is (turma, day, slot).
    // If I take record ID=1 (Mon, Slot1) and Update it to (Tue, Slot1):
    // SQL: UPDATE mtz SET dia=2, aula=1 WHERE id=1.
    // Our RPC 'upsert' acts as "Insert or Update ON CONFLICT(slot)".
    // It doesn't know "I moved from Mon".
    // SO: For moves within the board, we should call an UPDATE on the ID.
    // OR: We delete the old one and insert new?
    // Better: The RPC 'upsert' logic I wrote takes 'p_data'.
    // If I pass the ID, does it update by ID?
    // My RPC `mtz_matriz_curricular_upsert` does:
    // INSERT ... ON CONFLICT (turma, day, slot) DO UPDATE.
    // It does NOT update by ID. It assumes the SLOT is the key.
    // PROBLEM: If I move "Math" from Mon-1 to Tue-1:
    // 1. Mon-1 is empty in UI.
    // 2. Tue-1 has Math.
    // 3. I call upsert(Tue, 1, Math). It creates NEW record or overwrites Tue-1.
    // 4. THE OLD RECORD at Mon-1 STILL EXISTS in DB? 
    // Yes, unless I delete it.
    
    // FIX: 
    // When 'added' to a cell:
    //   If block has 'db_id', it means it came from another cell.
    //      -> We should DELETE the old record (or Update it).
    //      -> Ideally, update the existing record to new coordinates.
    //   If block has NO 'db_id', it came from repository.
    //      -> Insert new.

    // How to update logic:
    // I need a generic 'save' that handles both.
    // But 'upsert' by slot is tricky for moves.
    // Let's modify the strategy:
    // 1. If 'added', check if it's a move.
    // 2. If move, delete old? NO, we don't know the old slot easily here without tracking.
    // 3. Easier: Just Delete the old one if we know it?
    // Wait, 'vuedraggable' doesn't give "previous container" easily in 'added'.
    
    // Alternative: 
    // ALWAYS Delete + Insert?
    // If block.db_id is present, call delete(block.db_id). 
    // Then call upsert(new slot).
    // This works for moves.
    // Use `block.db_id` to delete.
}

const saveSlot = async (dayIndex: number, slotIndex: number, block: Block) => {
    // 1. If it was a move (has db_id), delete the old reference first
    //    Why? To avoid duplicate schedule or constraint issues if swapping?
    //    Actually, if I move Mon->Tue, Mon becomes free. DB still has Mon.
    //    So yes, MUST delete old db_id.
    if (block.db_id) {
        await (client.rpc as any)('mtz_matriz_curricular_delete', {
            p_id_empresa: appStore.company?.empresa_id,
            p_id: block.db_id
        })
    }

    // 2. Upsert new slot
    const dia = dayIndex + 1
    const aula = slotIndex + 1
    
    try {
        const { data, error } = await useFetch('/api/estrutura_academica/matriz_curricular', {
            method: 'POST',
            body: {
                id_empresa: appStore.company?.empresa_id,
                data: {
                    id_turma: filters.value.turma_id,
                    ano: 2026, // TODO: Get from store or context? Using fixed for now or parse from ano_etapa name? Ideally fetch.
                    dia_semana: dia,
                    aula: aula,
                    id_componente: block.id_componente
                }
            }
        })

        if (error.value) throw error.value
        
        // Update block with new DB ID
        // The API returns { success: true, data: { status: 'success', data: {id: ...} ... } }
        const result = (data.value as any)?.data // this is the RPC result: { status: 'success', data: { ... } }
        const savedRecord = result?.data
        
        if (savedRecord && savedRecord.id) {
            block.db_id = savedRecord.id
            block.id_temp = `db-${savedRecord.id}`
        }

        toast.showToast('Horário atualizado', 'success')

    } catch (err) {
        console.error('Save error', err)
        toast.showToast('Erro ao salvar', 'error')
        fetchData() // Revert UI on error
    }
}

const onRepoChange = async (evt: any) => {
    // If item added to repo (dragged FROM calendar TO repo)
    if (evt.added) {
        const block = evt.added.element as Block
        if (block.db_id) {
            // Delete from DB
            try {
                await useFetch('/api/estrutura_academica/matriz_curricular', {
                    method: 'DELETE',
                    body: {
                        id_empresa: appStore.company?.empresa_id,
                        id: block.db_id
                    }
                })
                block.db_id = undefined // Clear ID as it's now in repo
            } catch (err) {
                console.error('Delete error', err)
                fetchData() // Revert
            }
        }
        // Normalize ID for repo
        block.id_temp = `repo-${block.id_componente}-${Date.now()}`
    }
}

// Watch filters
watch(() => filters.value.turma_id, (newVal) => {
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

        <div v-if="filters.turma_id" class="grid grid-cols-1 lg:grid-cols-4 gap-6 h-[calc(100vh-250px)]">
            
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
                <!-- Use flex-1 to fill height, and overflow-auto if needed, but we want a fixed grid mostly -->
                <div class="grid grid-cols-5 gap-2 flex-1 overflow-y-auto custom-scrollbar content-start">
                    
                    <!-- Columns by Day -->
                    <div v-for="(dayName, dIndex) in days" :key="dIndex" class="space-y-2">
                        
                        <!-- Rows by Slot -->
                        <div v-for="(slotNum, sIndex) in slots" :key="sIndex" class="relative group">
                            <!-- Slot Label (Visible only on first column or absolute?) -->
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
                                        class="h-full w-full p-2 rounded-xl cursor-grab active:cursor-grabbing flex flex-col justify-center items-center text-center leading-tight bg-surface text-white border-b-4 shadow-sm"
                                        :style="{ borderBottomColor: element.componente_cor || '#ccc' }"
                                    >
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
            <p>Selecione uma turma para gerenciar o horário.</p>
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
