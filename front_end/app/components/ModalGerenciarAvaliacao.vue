<script setup>
import { useToastStore } from '@/stores/toast'

const props = defineProps({
  isOpen: Boolean,
  initialData: Object
})

const emit = defineEmits(['close', 'success'])

const toast = useToastStore()
const appStore = useAppStore()

const isLoading = ref(false)
const formData = ref({
  id: null,
  nome_modelo: ''
})

const grupos = ref([]) // Array of groups. Each group has .itens = []
const criteriosCache = ref([]) // List of available criteria for select

// --- Helper Functions (Defined before usage) ---
const resetForm = () => {
  formData.value = { id: null, nome_modelo: '' }
  grupos.value = []
}

const fetchCriterios = async () => {
    // Helper to get all criterias for selection
    try {
        const response = await $fetch('/api/avaliacao/criterios', {
            query: { id_empresa: appStore.company.empresa_id, limite: 100 }
        })
        criteriosCache.value = response.items || []
    } catch(e) {
        console.error('Error fetching criterios:', e)
    }
}

const fetchGruposAndItens = async (idModelo) => {
  try {
     // 1. Get Groups
     const { items: loadedGrupos } = await $fetch('/api/avaliacao/grupos', {
       query: { 
         id_empresa: appStore.company.empresa_id,
         id_modelo: idModelo
       }
     })
     
     // 2. For each group, get items (Parallel)
     const gruposWithItens = await Promise.all(loadedGrupos.map(async (g) => {
         const { items: perguntas } = await $fetch('/api/avaliacao/itens_avaliacao', {
             query: { id_empresa: appStore.company.empresa_id, id_grupo: g.id }
         })
         return { 
             ...g, 
             itens: (perguntas || []).map(p => ({ ...p, id_modelo_criterio: p.id_modelo_criterio || '' })), // Ensure reactivity
             fileOpen: false // UI state for accordion
         }
     }))

     grupos.value = gruposWithItens

  } catch (err) {
    console.error('Erro ao buscar dados:', err)
    toast.showToast('Erro ao carregar estrutura da avaliação.', 'error')
  }
}

// Load data on open
watch(() => props.isOpen, async (val) => {
  if (val) {
    await fetchCriterios()
    if (props.initialData) {
      formData.value = { ...props.initialData }
      await fetchGruposAndItens(props.initialData.id)
    } else {
      resetForm()
    }
  }
}, { immediate: true })

// --- Group Management ---
const addGrupo = () => {
    grupos.value.push({
        id: null,
        nome_grupo: '',
        peso_grupo: 1,
        itens: [],
        fileOpen: true // Auto expand new group
    })
}

const removeGrupo = async (index) => {
    const g = grupos.value[index]
    if (g.id) {
        if(!confirm('Deseja remover este grupo e todas as suas perguntas?')) return
        try {
            await $fetch('/api/avaliacao/grupos', {
                method: 'DELETE',
                body: { id: g.id, id_empresa: appStore.company.empresa_id }
            })
            grupos.value.splice(index, 1)
        } catch(e) { 
            toast.showToast('Erro ao remover grupo', 'error') 
        }
    } else {
        grupos.value.splice(index, 1)
    }
}

const toggleGrupo = (index) => {
    grupos.value[index].fileOpen = !grupos.value[index].fileOpen
}

// --- Item Management (Nested) ---
const addItem = (grupoIndex) => {
    grupos.value[grupoIndex].itens.push({
        id: null,
        texto_pergunta: '',
        peso_item: 1,
        id_modelo_criterio: '' // User must select
    })
}

const removeItem = async (grupoIndex, itemIndex) => {
    const group = grupos.value[grupoIndex]
    const item = group.itens[itemIndex]
    if (item.id) {
        if(!confirm('Remover pergunta?')) return
        try {
            await $fetch('/api/avaliacao/itens_avaliacao', {
                method: 'DELETE',
                body: { id: item.id, id_empresa: appStore.company.empresa_id }
            })
            group.itens.splice(itemIndex, 1)
        } catch(e) {
            toast.showToast('Erro ao remover pergunta', 'error')
        }
    } else {
        group.itens.splice(itemIndex, 1)
    }
}

// --- Saving ---
const save = async () => {
    if (!formData.value.nome_modelo) {
        toast.showToast('Nome da avaliação é obrigatório.', 'warning')
        return
    }

    isLoading.value = true
    try {
        // 1. Save Model
        const { data: savedModel } = await $fetch('/api/avaliacao/modelos', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: formData.value
            }
        })
        const modelId = savedModel.id

        // 2. Process Groups
        for (const grupo of grupos.value) {
            if (!grupo.nome_grupo) continue;

            const { data: savedGrupo } = await $fetch('/api/avaliacao/grupos', {
                method: 'POST',
                body: {
                    id_empresa: appStore.company.empresa_id,
                    data: {
                        id: grupo.id,
                        id_modelo_avaliacao: modelId,
                        nome_grupo: grupo.nome_grupo,
                        peso_grupo: grupo.peso_grupo
                    }
                }
            })
            const grupoId = savedGrupo.id
            
            // 3. Process Items for this Group
            for (const item of grupo.itens) {
                if (!item.texto_pergunta || !item.id_modelo_criterio) continue;

                await $fetch('/api/avaliacao/itens_avaliacao', {
                    method: 'POST',
                    body: {
                        id_empresa: appStore.company.empresa_id,
                        data: {
                            id: item.id,
                            id_grupo: grupoId,
                            id_modelo_criterio: item.id_modelo_criterio,
                            texto_pergunta: item.texto_pergunta,
                            peso_item: item.peso_item
                        }
                    }
                })
            }
        }

        toast.showToast('Avaliação salva com sucesso!', 'success')
        emit('success')
        emit('close')
    } catch (err) {
        console.error('Erro ao salvar avaliação:', err)
        toast.showToast('Erro ao salvar avaliação.', 'error')
    } finally {
        isLoading.value = false
    }
}
</script>

<template>
  <div v-if="isOpen" class="fixed inset-0 z-[99999] flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
    <div class="bg-background w-full max-w-4xl rounded-lg shadow-xl overflow-hidden flex flex-col h-[90vh]">
      
      <!-- Header -->
      <div class="px-6 py-4 border-b border-div-15 flex items-center justify-between shrink-0">
        <h3 class="text-lg font-bold text-text">
          {{ initialData ? 'Editar Avaliação' : 'Nova Avaliação' }}
        </h3>
        <button @click="$emit('close')" class="text-secondary hover:text-text transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
      </div>

      <!-- Body -->
      <div class="p-6 overflow-y-auto flex-1 bg-div-05 space-y-6">
        
        <!-- Main Form -->
        <div class="space-y-1 bg-background p-4 rounded border border-div-15 shadow-sm">
            <label class="text-xs font-bold text-secondary uppercase">Nome da Avaliação</label>
            <input 
              v-model="formData.nome_modelo" 
              type="text" 
              class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded text-sm text-text focus:outline-none focus:border-primary transition-colors font-bold"
              placeholder="Ex: Avaliação Bimestral 2026"
            >
        </div>

        <!-- Groups Container -->
        <div class="space-y-4">
             <div class="flex items-center justify-between px-1">
                 <h4 class="text-sm font-bold text-secondary uppercase tracking-widest">Estrutura de Grupos</h4>
                 <button @click="addGrupo" class="bg-primary/10 text-primary hover:bg-primary hover:text-white px-3 py-1.5 rounded text-xs font-bold transition-all flex items-center gap-1">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    Adicionar Grupo
                 </button>
            </div>

            <!-- Group Loop -->
            <div v-for="(grupo, gIndex) in grupos" :key="gIndex" class="bg-background rounded border border-div-15 shadow-sm overflow-hidden">
                <!-- Group Header -->
                <div class="flex items-center gap-2 p-3 bg-div-05 border-b border-div-15">
                    <button @click="toggleGrupo(gIndex)" class="p-1 text-secondary hover:text-primary transition-transform" :class="{'rotate-90': grupo.fileOpen}">
                         <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                    </button>
                    <div class="flex-1 grid grid-cols-12 gap-2">
                        <input v-model="grupo.nome_grupo" placeholder="Nome do Grupo (Ex: Comportamental)" class="col-span-10 px-2 py-1 bg-transparent border-b border-transparent focus:border-primary rounded-none outline-none font-bold text-sm">
                        
                        <div class="col-span-2 flex items-center border-[0.5px] border-div-15 bg-background/50 rounded px-2 h-[28px] focus-within:border-primary transition-colors">
                            <span class="text-[9px] font-bold text-secondary uppercase mr-1">Peso</span>
                            <input v-model.number="grupo.peso_grupo" type="number" class="w-full bg-transparent border-none outline-none text-xs text-text h-full p-0 placeholder-div-30" placeholder="1">
                        </div>
                    </div>
                     <button @click="removeGrupo(gIndex)" class="p-1 text-secondary hover:text-danger">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Group Items (Accordion Body) -->
                <div v-show="grupo.fileOpen" class="p-4 bg-div-05/30">
                     <div class="space-y-2">
                         <div v-for="(item, iIndex) in grupo.itens" :key="iIndex" class="flex gap-2 items-start">
                             <div class="flex-1 grid grid-cols-12 gap-2">
                                 <input v-model="item.texto_pergunta" placeholder="Pergunta / Item" class="col-span-7 px-3 py-2 bg-background border border-div-15 rounded text-sm focus:border-primary outline-none text-text">
                                 <div class="col-span-3 relative">
                                    <select v-model="item.id_modelo_criterio" class="w-full pl-3 pr-6 py-2 bg-background border border-div-15 rounded text-xs focus:border-primary outline-none appearance-none text-text cursor-pointer">
                                        <option value="" disabled selected>Critério</option>
                                        <option v-for="c in criteriosCache" :key="c.id" :value="c.id">{{ c.nome_modelo_criterio }}</option>
                                    </select>
                                    <div class="absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none text-secondary">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>
                                    </div>
                                 </div>
                                 <div class="col-span-2 flex items-center bg-background border border-div-15 rounded px-3 focus-within:border-primary transition-colors h-[38px]">
                                     <span class="text-[10px] font-bold text-secondary uppercase mr-2">Peso</span>
                                     <input v-model.number="item.peso_item" type="number" class="w-full bg-transparent border-none outline-none text-sm text-text h-full p-0 placeholder-div-30" placeholder="1">
                                 </div>
                             </div>
                             <button @click="removeItem(gIndex, iIndex)" class="p-2 text-div-30 hover:text-danger">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                             </button>
                         </div>
                         <button @click="addItem(gIndex)" class="w-full py-2 border border-dashed border-div-30 rounded text-center text-xs font-bold text-secondary hover:text-primary hover:border-primary transition-colors">
                             + Adicionar Pergunta ao Grupo
                         </button>
                     </div>
                </div>
            </div>

             <div v-if="grupos.length === 0" class="text-center py-8 text-secondary text-sm">
                Nenhum grupo definido. Clique em "Adicionar Grupo".
             </div>
        </div>

      </div>

      <!-- Footer -->
      <div class="px-6 py-4 border-t border-div-15 flex justify-end gap-3 bg-div-05 shrink-0">
        <button 
          @click="$emit('close')" 
          class="px-4 py-2 text-sm font-bold text-secondary hover:text-text transition-colors"
        >
          Cancelar
        </button>
        <button 
          @click="save" 
          :disabled="isLoading"
          class="px-6 py-2 text-sm font-bold text-white bg-primary rounded hover:bg-primary/90 transition-all shadow-sm disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
          <div v-if="isLoading" class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
          Salvar
        </button>
      </div>

    </div>
  </div>
</template>

<style scoped>
select option {
  background-color: rgb(var(--color-background));
  color: rgb(var(--color-text));
}
</style>
