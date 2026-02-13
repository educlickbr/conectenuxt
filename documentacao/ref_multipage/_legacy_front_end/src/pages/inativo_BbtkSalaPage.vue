<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import FullPageMenu from '../components/FullPageMenu.vue'
import ModalGerenciarBbtkSala from '../components/ModalGerenciarBbtkSala.vue'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const appStore = useAppStore()
const toast = useToastStore()

const items = ref([])
const totalItens = ref(0)
const totalPaginas = ref(0)
const paginaAtual = ref(1)
const limitePorPagina = ref(10)
const busca = ref('')
const isLoading = ref(false)
const isMenuOpen = ref(false)
const isModalOpen = ref(false)
const isDeleteModalOpen = ref(false)
const itemToDelete = ref(null)
const selectedItem = ref(null)

const fetchItems = async () => {
    isLoading.value = true
    try {
        const { data, error } = await supabase.rpc('bbtk_dim_sala_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: paginaAtual.value,
            p_limite_itens_pagina: limitePorPagina.value,
            p_busca: busca.value || null
        })
        if (error) throw error
        const result = Array.isArray(data) ? data[0] : data
        // The return structure for sala_get_paginado items usually includes predio columns due to join.
        items.value = result.itens || []
        totalItens.value = result.qtd_itens || 0
        totalPaginas.value = result.qtd_paginas || 0
    } catch (error) {
        toast.showToast('Erro ao carregar dados', 'error')
    } finally {
        isLoading.value = false
    }
}

onMounted(fetchItems)
watch([paginaAtual], fetchItems)
let debounceTimeout = null
watch(busca, () => {
    if (debounceTimeout) clearTimeout(debounceTimeout)
    debounceTimeout = setTimeout(() => { paginaAtual.value = 1; fetchItems() }, 300)
})

const proxPagina = () => { if (paginaAtual.value < totalPaginas.value) paginaAtual.value++ }
const antPagina = () => { if (paginaAtual.value > 1) paginaAtual.value-- }

const handleAdd = () => { selectedItem.value = null; isModalOpen.value = true }
const handleEdit = (item) => { 
    // Prepare item for modal. The modal expects predio_nome for display if available.
    // Assuming the get_paginado returns columns like 'nome' (sala), 'predio_nome' OR 'nome_predio'.
    // I need to check the SQL for sala_get_paginado to be sure of the column name for predio name.
    // Based on previous contexts, it likely does a join.
    // I will pass the item as is, the modal will try to use predio_nome.
    selectedItem.value = item; 
    isModalOpen.value = true 
}
const handleDelete = (item) => { itemToDelete.value = item; isDeleteModalOpen.value = true }
const confirmDelete = async () => {
    try {
        const { error } = await supabase.rpc('bbtk_dim_sala_delete', { p_id: itemToDelete.value.uuid, p_id_empresa: appStore.id_empresa })
        if (error) throw error
        toast.showToast('Removido com sucesso.', 'success')
        isDeleteModalOpen.value = false
        fetchItems()
    } catch (err) { toast.showToast('Erro ao remover.', 'error') }
}
</script>

<template>
    <div class="min-h-screen bg-background p-6 flex flex-col gap-6">
        <div class="sticky top-0 z-30 bg-div-15 backdrop-blur-2xl p-4 rounded-xl border border-secondary shadow-sm flex flex-col gap-6">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-4">
                     <div class="w-12 h-12 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-2xl">🚪</div>
                     <div><h1 class="text-xl font-bold text-text">Salas</h1><p class="text-sm text-secondary">Gerencie {{ totalItens }} registros.</p></div>
                </div>
                <button @click="isMenuOpen = !isMenuOpen" class="p-2 text-secondary hover:text-primary"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg></button>
            </div>
            <!-- Separator -->
            <hr class="border-secondary/20" />

            <!-- Bottom Section: Controls (Pagination & Search) -->
            <div class="flex flex-col md:flex-row gap-4 items-center justify-between">
                
                <!-- Pagination Controls -->
                <div class="flex flex-col items-center md:items-start gap-2 w-full md:w-auto">
                    <div class="flex items-center gap-2 bg-background/50 p-1 rounded-lg border border-secondary/30">
                         <button 
                            @click="antPagina" 
                            :disabled="paginaAtual === 1"
                            class="p-1 text-secondary hover:text-primary disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                         >
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                         </button>
                         
                         <div class="flex flex-col items-center">
                            <input 
                                type="number" 
                                v-model="paginaAtual"
                                class="w-12 text-center bg-transparent text-text font-bold focus:outline-none no-arrows"
                                min="1"
                                :max="totalPaginas"
                            >
                            <span class="text-[10px] text-secondary">{{ totalPaginas }} páginas</span>
                         </div>

                         <button 
                            @click="proxPagina" 
                            :disabled="paginaAtual >= totalPaginas"
                            class="p-1 text-secondary hover:text-primary disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                         >
                             <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                         </button>
                    </div>
                </div>

                <!-- Search and Action -->
                <div class="flex w-full md:flex-1 gap-4">
                    <div class="relative flex-1">
                         <input 
                            type="text" 
                            v-model="busca"
                            placeholder="Buscar..." 
                            class="w-full pl-10 pr-4 py-2 bg-div-15 border border-secondary rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/70"
                         >
                         <!-- Search Icon -->
                         <span class="absolute left-3 top-2.5 text-secondary">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                         </span>
                    </div>
                    <button 
                        @click="handleAdd"
                        class="bg-blue-600 hover:bg-blue-700 text-white font-medium px-6 py-2 rounded-lg transition-colors flex items-center gap-2 shadow-sm"
                    >
                        Adicionar
                    </button>
                </div>
            </div>
        </div>
        <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />
        <ModalGerenciarBbtkSala :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen = false" @success="fetchItems" />
        <div v-if="isDeleteModalOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-6">
             <div class="bg-background w-full max-w-md rounded-xl p-6 shadow-2xl border border-secondary/20">
                <h3 class="text-center text-xl font-bold mb-4 text-text">Excluir Item?</h3>
                <div class="flex gap-3"><button @click="isDeleteModalOpen = false" class="flex-1 py-2 rounded-lg text-secondary hover:bg-div-30">Cancelar</button><button @click="confirmDelete" class="flex-1 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700">Confirmar</button></div>
            </div>
        </div>
        <div class="flex flex-col gap-3">
            <div v-for="item in items" :key="item.uuid" class="bg-div-15 p-4 rounded-xl flex justify-between items-center group">
                <div class="flex items-center gap-4">
                    <div class="w-10 h-10 rounded-lg bg-background flex items-center justify-center font-bold border border-secondary/20">🚪</div>
                    <div>
                        <h3 class="font-bold text-text">{{ item.nome }}</h3>
                        <p class="text-xs text-secondary flex items-center gap-1">
                             <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18"/><path d="M5 21V7l8-4 8 4v14"/><path d="M8 14h1v4h-1z"/><path d="M12 14h1v4h-1z"/><path d="M16 14h1v4h-1z"/></svg>
                             {{ item.escola_nome }} <span class="text-secondary/50">></span> {{ item.predio_nome }}
                        </p>
                    </div>
                </div>
                <div class="flex items-center gap-2 opacity-80 group-hover:opacity-100 transition-opacity">
                    <button @click="handleEdit(item)" class="flex flex-col items-center justify-center w-12 h-12 rounded-lg bg-div-30 hover:bg-blue-50 hover:text-blue-600 text-secondary transition-colors" title="Editar">
                         <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                         <span class="text-[10px] mt-0.5">Editar</span>
                    </button>
                    <button @click="handleDelete(item)" class="flex flex-col items-center justify-center w-12 h-12 rounded-lg bg-div-30 hover:bg-red-500 hover:text-white text-secondary transition-colors" title="Apagar">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                        <span class="text-[10px] mt-0.5">Apagar</span>
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
/* Remove numeric inputs arrows */
input[type=number]::-webkit-inner-spin-button, 
input[type=number]::-webkit-outer-spin-button { 
  -webkit-appearance: none; 
  margin: 0; 
}
input[type=number] {
  -moz-appearance: textfield;
  appearance: none;
  margin: 0;
}
.no-arrows {
    appearance: none;
}
</style>
