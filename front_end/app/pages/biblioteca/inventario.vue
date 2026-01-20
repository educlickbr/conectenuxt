<script setup lang="ts">
import { ref, watch } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ModalInventario from '@/components/biblioteca/inventario/ModalInventario.vue'

// Layout
definePageMeta({
    layout: 'default' as any,

})

const appStore = useAppStore()
const toast = useToastStore()

// State
const items = ref<any[]>([])
const total = ref(0)
const page = ref(1)
const totalPages = ref(0)
const limit = ref(12)
const search = ref('')
const isLoading = ref(false)
const tipoPublicacao = ref('Impresso') 

const isModalOpen = ref(false)
const selectedEdicao = ref<any>(null)

const fetchItems = async () => {
    isLoading.value = true
    try {
        const result = await $fetch('/api/biblioteca/inventario/edicoes', {
             params: {
                id_empresa: appStore.company?.empresa_id,
                page: page.value,
                limit: limit.value,
                search: search.value || undefined,
                tipo: tipoPublicacao.value
            }
        }) as any
        items.value = result.items || []
        total.value = result.total || 0
        totalPages.value = result.pages || 0

    } catch (e: any) {
        toast.showToast(e.message || 'Erro ao carregar dados.', 'error')
    } finally {
        isLoading.value = false
    }
}

// Actions
const handleManage = (item: any) => {
    selectedEdicao.value = item
    isModalOpen.value = true
}

// Debounce
let debounceTimer: any
watch(search, () => {
    clearTimeout(debounceTimer)
    debounceTimer = setTimeout(() => {
        page.value = 1
        fetchItems()
    }, 400)
})
</script>

<template>
    <div class="h-full flex flex-col p-4 md:p-6 gap-6">
        
        <!-- Header -->
        <header class="flex flex-col md:flex-row md:items-center justify-between gap-4 shrink-0">
             <div>
                 <h1 class="text-2xl font-bold text-text flex items-center gap-2">
                    <span class="text-3xl">📦</span>
                    Inventário
                 </h1>
                 <p class="text-sm text-secondary mt-1">Gerencie exemplares físicos e localização.</p>
            </div>

            <div class="flex items-center gap-3 w-full md:w-auto">
                 <div class="relative flex-1 md:w-64">
                    <input 
                        v-model="search"
                        type="text" 
                        placeholder="Buscar por obra..." 
                        class="w-full h-10 pl-10 pr-4 bg-surface border border-div-15 rounded-lg text-sm text-text focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all shadow-sm"
                    >
                    <span class="absolute left-3 top-2.5 text-secondary/50">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    </span>
                 </div>
            </div>
        </header>

        <!-- List -->
        <div class="flex-1 overflow-y-auto min-h-0 bg-surface border border-div-15 rounded-xl p-4 shadow-sm space-y-3">
            
            <div v-if="isLoading" class="flex flex-col items-center justify-center p-12 text-secondary gap-3">
                 <div class="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                 Carregando edições...
            </div>

            <div v-else-if="items.length === 0" class="flex flex-col items-center justify-center p-12 text-secondary">
                 <div class="text-4xl mb-2 opacity-50">📚</div>
                 <p>Nenhuma edição impressa encontrada.</p>
            </div>

            <div 
                v-for="item in items" 
                :key="item.id_edicao"
                class="bg-div-05/50 p-4 rounded-xl border border-div-15 hover:border-primary/30 transition-all flex flex-col md:flex-row items-center gap-4 group"
            >
                <div class="w-12 h-12 rounded-lg bg-surface border border-div-15 flex items-center justify-center text-secondary font-bold text-xl shrink-0">
                    📖
                </div>

                <div class="flex-1 min-w-0 flex flex-col gap-1">
                    <h3 class="font-bold text-text truncate" :title="item.titulo_principal">{{ item.titulo_principal }}</h3>
                    <div class="flex items-center gap-3 text-xs text-secondary">
                        <span class="flex items-center gap-1">
                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                            {{ item.editora }}
                        </span>
                        <span>•</span>
                        <span>{{ item.ano_edicao || 'Ano N/A' }}</span>
                        <span class="hidden sm:inline">•</span>
                        <span class="hidden sm:inline">{{ item.autor_principal }}</span>
                    </div>
                </div>

                <button @click="handleManage(item)" class="px-4 py-2 bg-primary/10 text-primary hover:bg-primary hover:text-white rounded-lg font-bold text-sm transition-all flex items-center gap-2 shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    Gerenciar Inventário
                </button>
            </div>

        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="flex justify-center shrink-0">
             <div class="flex items-center gap-2 bg-surface p-2 rounded-xl border border-div-15 shadow-sm">
                <button @click="page--" :disabled="page <= 1" class="p-2 rounded-lg hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg></button>
                <span class="text-sm font-bold text-secondary px-2">{{ page }} / {{ totalPages }}</span>
                <button @click="page++" :disabled="page >= totalPages" class="p-2 rounded-lg hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg></button>
             </div>
        </div>

        <ModalInventario :isOpen="isModalOpen" :edicao="selectedEdicao" @close="isModalOpen=false" />

    </div>
</template>
