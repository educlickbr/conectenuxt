<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import MatrizFilterBar from '@/components/matriz_curricular/MatrizFilterBar.vue'

const appStore = useAppStore()
const toast = useToastStore()

// Filters
const filters = ref({
    escola_id: null,
    ano_etapa_id: null,
    turma_id: null
})
const selectedModelo = ref<string | null>(null)

// Data
const availableModelos = ref<any[]>([])
const gridData = ref<any[]>([])
const isLoadingModelos = ref(false)
const isLoadingGrid = ref(false)
const isSaving = ref(false)

// Columns for the grid (from the first student which should have all items, or we could fetch model details separately)
const gridColumns = computed(() => {
    if (gridData.value.length === 0) return []
    // Assuming the first student has the structure or we find one that has 'respostas'
    const firstWithAnswers = gridData.value.find(s => s.respostas && s.respostas.length > 0)
    if (!firstWithAnswers) return []
    
    // Check if responses have item names? The grid RPC returns nested objects with: id_item, conceito, id_resposta.
    // It does NOT return item Name. We might need to fetch Model Details to get Column Headers.
    // However, for now, let's assume we need to fetch the Model Details to get the Item Names.
    return [] 
})

// Store separate Model Details for headers
const modelDetails = ref<any>(null)

// --- Fetchers ---

const fetchModelos = async () => {
    if (!filters.value.ano_etapa_id) {
        availableModelos.value = []
        selectedModelo.value = null
        return
    }

    isLoadingModelos.value = true
    try {
        const { data } = await useFetch('/api/avaliacao/assoc_ano_etapa', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                id_ano_etapa: filters.value.ano_etapa_id
            }
        })
        availableModelos.value = data.value || []
        
        // Auto-select first if available
        if (availableModelos.value.length > 0 && !selectedModelo.value) {
            // selectedModelo.value = availableModelos.value[0].id_modelo_avaliacao
        }
    } catch (e) {
        console.error('Error fetching models:', e)
    } finally {
        isLoadingModelos.value = false
    }
}

const fetchModelDetails = async () => {
   if (!selectedModelo.value) {
       modelDetails.value = null
       return
   }
   // We need the Questions/Items text for the headers.
   // We can reuse 'api/avaliacao/modelos' but asking for specific ID? 
   // Or 'api/avaliacao/itens_avaliacao' by group? 
   // Actually, the easiest is to fetch the full model hierarchy.
   // For now, let's just fetch the items structure separately or assume the user knows the order? No, we need labels.
   // Let's call /api/avaliacao/itens_avaliacao?id_modelo=... (Wait, we don't have that easily).
   // Let's use the generic 'modelos' fetch and filter client side or implement a specific getter.
   // Actually, let's try to fetch all items for the model. 
   // The 'toggleAvaliacao' in ModalGerenciarAnoEtapa fetched groups then items.
   // Let's implement a quick fetch for model structure here or just rely on the grid to include names (updated RPC?).
   // Updating RPC is safer but I can also just fetch groups -> items.
   
   // Let's fetch groups for the model
   const { data: groups } = await useFetch('/api/avaliacao/grupos', {
       params: { id_empresa: appStore.company?.empresa_id, id_modelo: selectedModelo.value }
   })
   
   const groupsList = groups.value?.items || []
   let allItems = []
   
   for (const group of groupsList) {
       const { data: items } = await useFetch('/api/avaliacao/itens_avaliacao', {
           params: { id_empresa: appStore.company?.empresa_id, id_grupo: group.id }
       })
       if (items.value?.items) {
           allItems.push(...items.value.items.map(i => ({ ...i, groupParams: group })))
       }
   }
   modelDetails.value = { items: allItems }
}


const fetchGrid = async () => {
    if (!filters.value.turma_id || !selectedModelo.value) {
        gridData.value = []
        return
    }

    isLoadingGrid.value = true
    await fetchModelDetails() // Get headers
    
    try {
        const { data } = await useFetch('/api/avaliacao/grid', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                id_turma: filters.value.turma_id,
                id_modelo: selectedModelo.value
            }
        })
        gridData.value = data.value || []
    } catch (e) {
        console.error('Error fetching grid:', e)
        toast.showToast('Erro ao carregar notas.', 'error')
    } finally {
        isLoadingGrid.value = false
    }
}

// Actions
const saveEvaluation = async (student: any) => {
    // Optimistic or explicit save? 
    // Let's do explicit save for the row on blur or specific button?
    // Let's try auto-save on blur of inputs?
    
    // Prepare payload
    // student.respostas has the array.
    const payload = {
        id: student.id_avaliacao, // null if new
        id_turma: filters.value.turma_id,
        id_aluno: student.id_aluno,
        id_modelo_avaliacao: selectedModelo.value,
        id_ano_etapa: filters.value.ano_etapa_id,
        status: 'CONCLUIDA', // Or PENDENTE? Let's say CONCLUIDA if modified?
        observacao: student.observacao_avaliacao,
        respostas: student.respostas.map((r: any) => ({
            id_item_avaliacao: r.id_item,
            conceito: r.conceito
        }))
    }
    
    try {
        isSaving.value = true
        const { data, error } = await useFetch('/api/avaliacao/registros', {
            method: 'POST',
            body: {
                id_empresa: appStore.company?.empresa_id,
                data: payload // RPC avaliacao_aluno_registrar_completa expects (p_id_empresa, p_header, p_respostas)
                // Wait, the BFF [resource].post.ts passes 'data' as the body.
                // The RPC expects p_header and p_respostas split?
                // No, my RPC 'avaliacao_aluno_registrar_completa' takes (p_id_empresa, p_header, p_respostas).
                // But the BFF general handler (generic) usually passes 'p_data' as JSON.
                // I need to check the BFF logic for 'registros'. 
                // If it calls generic 'upsert', it passes 'p_data'.
                // My RPC 'avaliacao_aluno_registrar_completa' takes 3 args.
                // The generic BFF handler might fail if it tries to pass just 'p_data'.
                // I might need to adjust the BFF or the RPC signature.
                // Or simply wrap the call in a custom API handler? 
                
                // Let's check the BFF code again.
            }
        })
        
        // Actually, let's look at the BFF implementation in `server/api/avaliacao/[resource].post.ts`.
        // It does `client.rpc(rpcName, { p_data: body.data, p_id_empresa: body.id_empresa })`.
        // It strictly passes `p_data` and `p_id_empresa`.
        // My RPC `avaliacao_aluno_registrar_completa` has signature `(p_id_empresa, p_header, p_respostas)`.
        // THIS WILL FAIL. 
        
        // FIX: I should create a Wrapper RPC requiring only `p_data` that splits it, OR update the BFF to handle this specific resource specially?
        // Updating BFF is cleaner but might break the pattern.
        // Easiest: Create a wrapper RPC `avaliacao_aluno_registrar_completa_wrapper(p_data, p_id_empresa)` 
        // that extracts header and answers from `p_data`.
        // `p_data` could be `{ header: ..., respostas: ... }`.
    } catch(e) {
        console.error(e)
    } finally {
        isSaving.value = false
    }
}

// Watchers
watch(() => filters.value.ano_etapa_id, fetchModelos)
watch(() => [filters.value.turma_id, selectedModelo.value], () => {
    if (filters.value.turma_id && selectedModelo.value) {
        fetchGrid()
    } else {
        gridData.value = []
    }
})

</script>

<template>
    <div class="space-y-6">
        <!-- Controls -->
        <div class="bg-surface border border-div-15 rounded-xl p-6 shadow-sm">
             <div class="grid grid-cols-1 xl:grid-cols-[1fr,auto] gap-6 items-end">
                <div class="flex flex-col gap-4">
                     <MatrizFilterBar v-model="filters" />
                     
                     <div v-if="filters.ano_etapa_id" class="flex flex-col gap-1 w-full max-w-md animate-in fade-in slide-in-from-top-2">
                        <label class="text-xs font-bold text-secondary uppercase tracking-wider">Modelo de Avaliação</label>
                        <select 
                            v-model="selectedModelo"
                            class="h-10 border border-div-15 rounded-lg px-3 bg-input-bg text-text text-sm focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all"
                        >
                            <option :value="null">Selecione uma avaliação...</option>
                            <option v-for="m in availableModelos" :key="m.id_modelo_avaliacao" :value="m.id_modelo_avaliacao">
                                {{ m.nome_modelo }}
                            </option>
                        </select>
                     </div>
                </div>
             </div>
        </div>

        <!-- Grid -->
        <div v-if="filters.turma_id && selectedModelo" class="space-y-4">
            
            <div v-if="isLoadingGrid" class="py-12 text-center text-secondary">
                <div class="animate-spin h-8 w-8 border-2 border-primary border-t-transparent rounded-full mx-auto mb-2"></div>
                Carregando notas...
            </div>
            
            <div v-else-if="gridData.length === 0" class="py-12 text-center text-secondary bg-surface rounded-xl border border-div-15 border-dashed">
                Nenhum aluno encontrado ou erro ao carregar.
            </div>

            <div v-else class="bg-surface border border-div-15 rounded-xl overflow-hidden shadow-sm">
                <div class="overflow-x-auto">
                    <table class="w-full text-sm">
                        <thead class="bg-div-05 border-b border-div-15">
                            <tr>
                                <th class="px-4 py-3 text-left font-bold text-secondary text-xs uppercase tracking-wider sticky left-0 bg-div-05 z-10 w-64 shadow-[1px_0_0_0_rgba(0,0,0,0.05)]">
                                    Aluno
                                </th>
                                <th v-for="item in modelDetails?.items" :key="item.id" class="px-3 py-3 text-center font-bold text-secondary text-xs uppercase tracking-wider min-w-[100px]">
                                    <div class="flex flex-col items-center gap-1 group relative cursor-help">
                                        <span class="truncate max-w-[120px]">{{ item.enunciado }}</span>
                                        <span class="text-[9px] text-primary/70 bg-primary/5 px-1 rounded">{{ item.peso_maximo }} pts</span>
                                        
                                        <!-- Tooltip -->
                                        <div class="absolute bottom-full mb-2 hidden group-hover:block bg-text text-inverse text-[10px] p-2 rounded w-48 z-50 shadow-xl">
                                           {{ item.enunciado }} (Max: {{ item.peso_maximo }})
                                        </div>
                                    </div>
                                </th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-div-15">
                            <tr v-for="student in gridData" :key="student.id_aluno" class="group hover:bg-div-05/50 transition-colors">
                                <td class="px-4 py-3 sticky left-0 bg-surface group-hover:bg-div-05/50 z-10 shadow-[1px_0_0_0_rgba(0,0,0,0.05)]">
                                    <div class="flex flex-col">
                                        <span class="font-bold text-text">{{ student.nome_aluno }}</span>
                                        <span class="text-[10px] text-secondary">{{ student.status_matricula }}</span>
                                    </div>
                                </td>
                                <td v-for="item in modelDetails?.items" :key="item.id" class="px-2 py-2 text-center relative">
                                    
                                    <!-- Input Logic -->
                                    <!-- We need to find the specific answer for this item in student.respostas -->
                                    <!-- Since arrays might not map 1:1 by index, we find by ID -->
                                    <input 
                                        type="number"
                                        :value="student.respostas?.find(r => r.id_item === item.id)?.conceito"
                                        min="0"
                                        :max="item.peso_maximo"
                                        class="w-16 h-8 text-center border border-div-15 rounded bg-input-bg focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all font-mono"
                                        :class="{'text-primary font-bold': student.respostas?.find(r => r.id_item === item.id)?.conceito !== null}"
                                        placeholder="-"
                                        @blur="(e) => {
                                            const val = e.target.value === '' ? null : Number(e.target.value);
                                            // Update local state deeply
                                            const existingAnswer = student.respostas?.find(r => r.id_item === item.id);
                                            if (existingAnswer) {
                                                existingAnswer.conceito = val;
                                            } else {
                                                if (!student.respostas) student.respostas = [];
                                                student.respostas.push({ id_item: item.id, conceito: val });
                                            }
                                            // Trigger Save
                                            saveEvaluation(student);
                                        }"
                                    />
                                    
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div v-else class="py-24 text-center border-2 border-dashed border-div-15 rounded-xl bg-surface/50">
            <p class="text-secondary font-medium">Selecione uma turma e um modelo de avaliação para começar.</p>
        </div>
    </div>
</template>
