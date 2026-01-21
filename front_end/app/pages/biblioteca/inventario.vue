<script setup lang="ts">
import { ref, watch, computed, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ModalInventario from '@/components/biblioteca/inventario/ModalInventario.vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'

definePageMeta({
    layout: false,
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
const imageBaseUrl = ref('') // Support for images if needed in future

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

// Initial Load
onMounted(() => {
    fetchItems()
})

const dashboardStats = computed(() => [
  { label: 'Total Edições', value: total.value },
  { label: 'Página Atual', value: page.value }
])
</script>

<template>
    <NuxtLayout name="manager">
        <!-- Header Slots -->
        <template #header-icon>
            <div class="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center text-primary">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
            </div>
        </template>
        <template #header-title>Inventário</template>
        <template #header-subtitle>Gerencie exemplares e locais físicos.</template>
        
        <template #header-actions>
            <div class="relative w-64">
                    <input 
                    v-model="search"
                    type="text" 
                    placeholder="Buscar obras..." 
                    class="w-full h-9 pl-9 pr-4 bg-surface border border-div-15 rounded text-sm text-text focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all shadow-sm"
                >
                <span class="absolute left-3 top-2.5 text-secondary/50">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                </span>
            </div>
        </template>

        <!-- Sidebar Slot -->
        <template #sidebar>
            <ManagerDashboard title="Dashboard Inventário" :stats="dashboardStats">
                <template #extra>
                     <div class="p-4 bg-primary/5 border border-primary/10 rounded-lg">
                        <h4 class="text-xs font-bold text-primary mb-1">Dica de Gestão</h4>
                        <p class="text-[11px] text-secondary leading-normal">
                             Mantenha o inventário atualizado para facilitar a localização dos livros nas estantes.
                        </p>
                     </div>
                </template>
            </ManagerDashboard>
        </template>

        <!-- Content Slot -->
        <div class="h-full flex flex-col">
            
            <div v-if="isLoading && items.length === 0" class="h-full flex flex-col items-center justify-center text-secondary gap-3">
                 <div class="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                 Carregando edições...
            </div>

            <div v-else-if="items.length === 0" class="h-full flex flex-col items-center justify-center text-secondary">
                 <div class="text-4xl mb-2 opacity-50">📦</div>
                 <p>Nenhuma edição encontrada.</p>
            </div>

            <div v-else class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-7 gap-4 overflow-y-auto pr-2 pb-4 content-start auto-rows-max">
                <div 
                    v-for="item in items" 
                    :key="item.id_edicao"
                    @click="handleManage(item)"
                    class="flex flex-col bg-surface rounded-lg border border-div-15 overflow-hidden cursor-pointer hover:shadow-xl transition-all hover:border-primary/50 group h-full"
                >
                    <!-- Cover/Icon Section -->
                    <div class="aspect-[2/3] w-full relative bg-div-05 overflow-hidden border-b border-div-15 flex flex-col items-center justify-center text-secondary">
                        <!-- Placeholder for Cover or Icon -->
                        <span class="text-3xl opacity-20 mb-2">📖</span>
                        <div v-if="item.ano_edicao" class="absolute top-2 right-2 bg-surface/80 backdrop-blur px-1.5 py-0.5 rounded text-[10px] font-bold shadow-sm border border-div-15">
                            {{ item.ano_edicao }}
                        </div>
                    </div>

                    <!-- Info Section -->
                    <div class="p-3 flex flex-col gap-1 bg-div-05/30 flex-1">
                        <h3 class="font-bold text-xs text-text leading-tight line-clamp-2" :title="item.titulo_principal">
                            {{ item.titulo_principal }}
                        </h3>
                        <p class="text-[10px] text-secondary line-clamp-1" :title="item.editora">
                            {{ item.editora || 'Editora N/A' }}
                        </p>
                        <p class="text-[10px] text-secondary/70 line-clamp-1">
                             {{ item.autor_principal }}
                        </p>
                    </div>
                </div>
            </div>

            <!-- Pagination -->
             <div v-if="totalPages > 1" class="flex justify-center shrink-0 pt-4 border-t border-div-15 mt-auto">
                 <div class="flex items-center gap-2 bg-surface p-1 rounded-lg border border-div-15 shadow-sm">
                    <button @click="page--" :disabled="page <= 1" class="p-1.5 rounded hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg></button>
                    <span class="text-xs font-bold text-secondary px-2">{{ page }} / {{ totalPages }}</span>
                    <button @click="page++" :disabled="page >= totalPages" class="p-1.5 rounded hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg></button>
                 </div>
            </div>

            <ModalInventario :isOpen="isModalOpen" :edicao="selectedEdicao" @close="isModalOpen=false" />
        </div>
    </NuxtLayout>
</template>
