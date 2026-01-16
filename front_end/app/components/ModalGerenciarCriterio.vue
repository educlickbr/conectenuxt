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
const isSavingItem = ref(false) // State for the add item button
const formData = ref({
  id: null,
  nome_modelo_criterio: '',
  tipo_modelo_criterio: 'NUMERICO'
})

// State for the "New Item" inputs
const newItem = ref({
    rotulo: '',
    valor_numerico: null
})

const itens = ref([]) 

const resetForm = () => {
  formData.value = {
    id: null,
    nome_modelo_criterio: '',
    tipo_modelo_criterio: 'NUMERICO'
  }
  newItem.value = { rotulo: '', valor_numerico: null }
  itens.value = []
}

const fetchItens = async (idCriterio) => {
  try {
     const data = await $fetch('/api/avaliacao/itens_criterio', {
       query: { 
         id_empresa: appStore.company.empresa_id,
         id_criterio: idCriterio
       }
     })
     // Convert integer from DB back to float for display (ex: 975 -> 9.75)
     itens.value = (data.items || []).map(i => ({
         ...i,
         valor_numerico: i.valor_numerico ? i.valor_numerico / 100 : 0
     }))
  } catch (err) {
    console.error('Erro ao buscar itens:', err)
    /* toast.showToast('Erro ao carregar itens.', 'error') - Suppress on init to avoid spam if closed quickly */
  }
}

// Load data on open
watch(() => props.isOpen, async (val) => {
  if (val) {
    if (props.initialData) {
      formData.value = { ...props.initialData }
      await fetchItens(props.initialData.id)
    } else {
      resetForm()
    }
  }
}, { immediate: true })

// 1. Save Model (Header)
const saveModel = async () => {
  if (!formData.value.nome_modelo_criterio) {
    toast.showToast('Nome do critério é obrigatório.', 'warning')
    return
  }

  isLoading.value = true
  try {
    const isUpdate = !!formData.value.id
    
    const { data: savedCriterio } = await $fetch('/api/avaliacao/criterios', {
      method: 'POST',
      body: {
        id_empresa: appStore.company.empresa_id,
        data: formData.value
      }
    })

    if (savedCriterio) {
        formData.value.id = savedCriterio.id // Update ID to unlock items section
        toast.showToast('Dados do critério salvos com sucesso!', 'success')
        emit('success') // Refresh parent list
        
        // If it was an edit (updating existing), close the modal
        if (isUpdate) {
            emit('close')
        }
        // If it was new, stay open to add items
    }
  } catch (err) {
    console.error('Erro ao salvar modelo:', err)
    toast.showToast('Erro ao salvar critério.', 'error')
  } finally {
    isLoading.value = false
  }
}

// 2. Add Item (Immediate Save)
const handleAddItem = async () => {
    if (!newItem.value.rotulo) {
        toast.showToast('Informe o rótulo do item.', 'warning')
        return
    }
    // For numeric type, 0 is valid, so check against null/undefined if needed
    if (formData.value.tipo_modelo_criterio === 'NUMERICO' && (newItem.value.valor_numerico === null || newItem.value.valor_numerico === '')) {
         toast.showToast('Informe o valor numérico.', 'warning')
         return
    }

    isSavingItem.value = true
    try {
        await $fetch('/api/avaliacao/itens_criterio', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: {
                    id_modelo_criterio: formData.value.id,
                    rotulo: newItem.value.rotulo,
                    // Convert float to integer for DB (ex: 9.75 -> 975)
                    valor_numerico: Math.round(Number(newItem.value.valor_numerico) * 100)
                }
            }
        })
        
        toast.showToast('Item adicionado!', 'success')
        await fetchItens(formData.value.id) // Reload list
        
        // Reset inputs
        newItem.value = { rotulo: '', valor_numerico: null }
        // Focus back on rotulo input? (Optional UX refinement)

    } catch (err) {
        console.error('Erro ao adicionar item:', err)
        toast.showToast('Erro ao salvar item.', 'error')
    } finally {
        isSavingItem.value = false
    }
}

// 3. Remove Item (Immediate Delete)
const handleDeleteItem = async (item) => {
    if(!confirm(`Excluir item "${item.rotulo}"?`)) return

    try {
        await $fetch('/api/avaliacao/itens_criterio', {
            method: 'DELETE',
            body: { id: item.id, id_empresa: appStore.company.empresa_id }
        })
        toast.showToast('Item removido.', 'success')
        await fetchItens(formData.value.id)
    } catch(err) {
        toast.showToast('Erro ao remover item.', 'error')
    }
}

</script>

<template>
  <div v-if="isOpen" class="fixed inset-0 z-[99999] flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
    <div class="bg-background w-full max-w-2xl rounded-lg shadow-xl overflow-hidden flex flex-col max-h-[90vh] text-text">
      
      <!-- Header -->
      <div class="px-6 py-4 border-b border-div-15 flex items-center justify-between bg-div-05">
        <h3 class="text-lg font-bold">
          {{ initialData ? 'Editar Critério' : 'Novo Critério' }}
        </h3>
        <button @click="$emit('close')" class="text-secondary hover:text-text transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
      </div>

      <!-- Body -->
      <div class="p-6 overflow-y-auto flex-1 space-y-8">
        
        <!-- 1. Main Info Form -->
        <div class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="space-y-1">
                <label class="text-xs font-bold text-secondary uppercase">Nome do Modelo</label>
                <input 
                v-model="formData.nome_modelo_criterio" 
                type="text" 
                class="w-full px-3 py-2 bg-background border border-div-30 rounded text-sm text-text focus:outline-none focus:border-primary transition-colors font-bold"
                placeholder="Ex: Escala 0 a 10"
                >
            </div>
            <div class="space-y-1">
                <label class="text-xs font-bold text-secondary uppercase">Tipo</label>
                <div class="relative">
                <select 
                    v-model="formData.tipo_modelo_criterio"
                    class="w-full pl-3 pr-8 py-2 bg-background border border-div-30 rounded text-sm text-text focus:outline-none focus:border-primary transition-colors appearance-none cursor-pointer"
                    :disabled="itens.length > 0" 
                >
                    <!-- Disable changing type if items exist to avoid mess -->
                    <option value="NUMERICO">Numérico</option>
                    <option value="CONCEITUAL">Conceitual</option>
                </select>
                <div class="absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none text-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>
                </div>
                </div>
            </div>
            </div>
            
            <!-- Save Helper Text -->
            <p v-if="!formData.id" class="text-xs text-secondary italic text-center py-2 bg-div-15 rounded">
                Salve o modelo para começar a adicionar os itens.
            </p>
        </div>

        <hr class="border-div-15" />

        <!-- 2. Items Management Section -->
        <div v-if="formData.id" class="space-y-4">
            <div class="flex items-center justify-between">
                 <h4 class="text-sm font-bold uppercase tracking-wider text-secondary">Itens do Critério</h4>
                 <span class="text-xs font-bold bg-div-15 px-2 py-1 rounded text-primary">{{ itens.length }} itens</span>
            </div>

            <!-- Add Item Row -->
            <div class="p-4 bg-div-05 rounded border border-div-15 flex flex-col md:flex-row gap-3 items-end">
                <div class="flex-1 w-full">
                    <label class="text-[10px] font-bold text-secondary uppercase mb-1 block">Rótulo (Ex: Bom, 10)</label>
                    <input 
                        v-model="newItem.rotulo"
                        type="text" 
                        class="w-full px-3 py-2 bg-background border border-div-30 rounded text-sm focus:border-primary outline-none"
                        placeholder="Digite o rótulo..."
                        @keyup.enter="handleAddItem"
                    >
                </div>
                <div class="w-full md:w-32">
                    <label class="text-[10px] font-bold text-secondary uppercase mb-1 block">Valor Numérico</label>
                    <input 
                        v-model.number="newItem.valor_numerico"
                        type="number" 
                        step="0.1"
                        class="w-full px-3 py-2 bg-background border border-div-30 rounded text-sm focus:border-primary outline-none"
                        placeholder="0.0"
                        @keyup.enter="handleAddItem"
                    >
                </div>
                <button 
                    @click="handleAddItem" 
                    :disabled="isSavingItem"
                    class="w-full md:w-auto px-4 py-2 bg-primary text-white text-sm font-bold rounded shadow-sm hover:brightness-110 transition-all flex items-center justify-center gap-2 disabled:opacity-50"
                >
                    <!-- Floppy/Save Icon as requested -->
                    <svg v-if="!isSavingItem" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
                    <div v-else class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                    Salvar Item
                </button>
            </div>

            <!-- Items List -->
            <div class="border border-div-15 rounded overflow-hidden">
                <table class="w-full text-left text-sm">
                    <thead class="bg-div-15 text-xs font-bold text-secondary uppercase">
                        <tr>
                            <th class="px-4 py-2">Rótulo</th>
                            <th class="px-4 py-2">Valor</th>
                            <th class="px-4 py-2 w-10"></th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-div-15">
                        <tr v-for="item in itens" :key="item.id" class="group hover:bg-div-05 transition-colors">
                            <td class="px-4 py-2 font-medium">{{ item.rotulo }}</td>
                            <td class="px-4 py-2 font-mono text-secondary">{{ item.valor_numerico }}</td>
                            <td class="px-4 py-2 text-right">
                                <button @click="handleDeleteItem(item)" class="text-div-30 hover:text-danger p-1 rounded transition-colors" title="Excluir">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                </button>
                            </td>
                        </tr>
                        <tr v-if="itens.length === 0">
                            <td colspan="3" class="p-8 text-center text-secondary italic text-xs">
                                Nenhum item cadastrado neste critério.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

      </div>

      <!-- Footer -->
      <div class="px-6 py-4 border-t border-div-15 flex justify-end gap-3 bg-div-05">
        <button 
          @click="$emit('close')" 
          class="px-4 py-2 text-sm font-bold text-secondary hover:text-text transition-colors"
        >
          Fechar
        </button>
        <button 
          @click="saveModel" 
          :disabled="isLoading"
          class="px-6 py-2 text-sm font-bold text-white bg-primary rounded hover:bg-primary/90 transition-all shadow-sm disabled:opacity-50 flex items-center gap-2"
        >
          <div v-if="isLoading" class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
          {{ formData.id ? 'Atualizar Dados' : 'Salvar e Continuar' }}
        </button>
      </div>

    </div>
  </div>
</template>

<style scoped>
/* Force native options to follow theme colors */
select option {
  background-color: rgb(var(--color-background));
  color: rgb(var(--color-text));
}
</style>
