<script setup lang="ts">
import { ref, watch } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ModalObra from '@/components/biblioteca/obras/ModalObra.vue'
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
const imageBaseUrl = ref('')
const r2Token = ref<any>(null)

const isModalOpen = ref(false)
const selectedItem = ref<any>(null)

// R2 Token Handling
const fetchR2Token = async () => {
    try {
        const tokenData = await $fetch('/api/storage/token', {
            query: { scope: '/' } 
        })
        r2Token.value = tokenData
    } catch (e) {
        console.error('Erro ao obter token R2:', e)
    }
}

const getR2ImageUrl = (path: string) => {
    if (!path || !r2Token.value) return ''
    // If path is full URL (old Bunny), return it (fallback)
    if (path.startsWith('http')) return path
    
    // Construct signed URL
    const { worker_url, token, expires, scope } = r2Token.value
    return `${worker_url}/${path}?token=${encodeURIComponent(token)}&expires=${expires}&scope=${encodeURIComponent(scope)}`
}

const fetchItems = async () => {
    isLoading.value = true
    try {
        const result = await $fetch('/api/biblioteca/obras', {
             params: {
                id_empresa: appStore.company?.empresa_id,
                page: page.value,
                limit: limit.value,
                search: search.value || undefined
            }
        }) as any
        items.value = (result.items || []).map((item: any) => ({
             ...item,
        }))
        total.value = result.total || 0
        totalPages.value = result.pages || 0
        
        // Legacy support if API still returns it, but we prefer getR2ImageUrl
        if (result.imageBaseUrl) {
            imageBaseUrl.value = result.imageBaseUrl
        }

    } catch (e: any) {
        toast.showToast(e.message || 'Erro ao carregar dados.', 'error')
    } finally {
        isLoading.value = false
    }
}

// Actions
const handleAdd = () => {
    selectedItem.value = null
    isModalOpen.value = true
}

const handleEdit = (item: any) => {
    selectedItem.value = item
    isModalOpen.value = true
}

// Watchers
watch(search, () => {
    page.value = 1
    // Debounce handled by UI typing speed naturally or add debounce util if needed
    // Adding simple timeout for now
    setTimeout(() => fetchItems(), 500)
})

// Initial Load
onMounted(async () => {
    await fetchR2Token() // Fetch token first
    fetchItems()
    fetchStats()
})

const dashboardStats = computed(() => [
  { label: 'Total Obras', value: total.value },
  { label: 'Página Atual', value: page.value }
])

const statsCategories = ref<any[]>([])

const fetchStats = async () => {
    try {
        const result = await $fetch('/api/biblioteca/obras/stats-categoria', {
            params: {
                id_empresa: appStore.company?.empresa_id
            }
        } as any) // Fix type
        statsCategories.value = result
    } catch (e) {
        console.error('Erro ao carregar estatísticas:', e)
    }
}

const categoryStats = computed(() => {
    if (!statsCategories.value.length) return []
    
    const totalWorks = statsCategories.value.reduce((acc, curr) => acc + Number(curr.quantidade), 0)
    
    return statsCategories.value
        .map((item: any) => ({ 
            label: item.categoria_nome || 'Sem Categoria', 
            value: Number(item.quantidade),
            percentage: totalWorks > 0 ? Math.round((Number(item.quantidade) / totalWorks) * 100) : 0
        }))
        .slice(0, 5) // Top 5
})
</script>

<template>
    <NuxtLayout name="manager">
        <!-- Header Slots -->
        <template #header-icon>
            <div class="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center text-primary">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
            </div>
        </template>
        <template #header-title>Gestão de Livros</template>
        <template #header-subtitle>Gerencie o acervo bibliográfico.</template>
        
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

            <button 
                @click="handleAdd"
                class="bg-primary hover:bg-primary-hover text-white px-4 py-1.5 rounded text-xs font-bold transition-all shadow-sm hover:shadow-md flex items-center gap-1 shrink-0"
            >
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                <span class="hidden sm:inline">Novo</span>
            </button>
        </template>

        <!-- Sidebar Slot -->
        <template #sidebar>
            <ManagerDashboard title="Dashboard Obras" :stats="dashboardStats">
                <template #visualization>
                     <div v-if="categoryStats.length > 0" class="w-full h-full flex flex-col justify-end gap-3">
                        <div class="flex items-end justify-between gap-1 h-32 px-2">
                            <div 
                                v-for="(stat, i) in categoryStats" 
                                :key="i"
                                class="w-full bg-primary/20 rounded-t flex flex-col justify-end relative group hover:bg-primary/30 transition-colors"
                                :style="{ height: `${stat.percentage}%` }"
                            >
                                <div class="absolute -top-6 left-1/2 -translate-x-1/2 text-[10px] font-bold text-text opacity-0 group-hover:opacity-100 transition-opacity bg-surface px-1.5 py-0.5 rounded shadow-sm border border-div-15 whitespace-nowrap z-10">
                                    {{ stat.value }} ({{ stat.percentage }}%)
                                </div>
                            </div>
                        </div>
                        <div class="flex justify-between px-2 pt-2 border-t border-div-15">
                            <div 
                                v-for="(stat, i) in categoryStats" 
                                :key="i"
                                class="text-[9px] text-secondary text-center w-full truncate px-0.5"
                                :title="stat.label"
                            >
                                {{ stat.label }}
                            </div>
                        </div>
                    </div>
                     <div v-else class="text-center opacity-40">
                        <p class="text-[10px] uppercase font-bold">Sem dados para gráfico</p>
                    </div>
                </template>

                <template #extra>
                     <div class="p-4 bg-primary/5 border border-primary/10 rounded-lg">
                        <h4 class="text-xs font-bold text-primary mb-1">Dica de Gestão</h4>
                        <p class="text-[11px] text-secondary leading-normal">
                             Mantenha as categorias atualizadas para melhor visualização do acervo.
                        </p>
                     </div>
                </template>
            </ManagerDashboard>
        </template>

        <!-- Content Slot -->
        <div class="h-full flex flex-col">
            
            <div v-if="isLoading && items.length === 0" class="h-full flex flex-col items-center justify-center text-secondary gap-3">
                 <div class="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                 Carregando obras...
            </div>

            <div v-else-if="items.length === 0" class="h-full flex flex-col items-center justify-center text-secondary">
                 <div class="text-4xl mb-2 opacity-50">📚</div>
                 <p>Nenhuma obra encontrada.</p>
                 <button @click="handleAdd" class="text-primary hover:underline font-bold mt-2">Cadastrar primeira obra</button>
            </div>

            <div v-else class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-7 gap-4 overflow-y-auto pr-2 pb-4 content-start auto-rows-max">
                <div 
                    v-for="item in items" 
                    :key="item.uuid"
                    @click="handleEdit(item)"
                    class="flex flex-col bg-surface rounded-lg border border-div-15 overflow-hidden cursor-pointer hover:shadow-xl transition-all hover:border-primary/50 group h-full"
                >
                    <!-- Cover Image Section (Fixed Aspect Ratio) -->
                    <div class="aspect-[2/3] w-full relative bg-div-05 overflow-hidden border-b border-div-15">
                        <div v-if="item.capa_imagem" class="w-full h-full">
                                <img :src="getR2ImageUrl(item.capa_imagem)" alt="Capa" class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110">
                        </div>
                        <div v-else class="w-full h-full flex flex-col items-center justify-center p-4 text-center text-secondary">
                            <span class="text-3xl opacity-20 mb-2">📖</span>
                        </div>
                    </div>

                    <!-- Info Section (Always Visible) -->
                    <div class="p-3 flex flex-col gap-1 bg-div-05/30 flex-1">
                        <h3 class="font-bold text-xs text-text leading-tight line-clamp-2" :title="item.titulo_principal">
                            {{ item.titulo_principal }}
                        </h3>
                        <p class="text-[10px] text-secondary line-clamp-1" :title="item.autor_principal_nome">
                            {{ item.autor_principal_nome || 'Autor desconhecido' }}
                        </p>
                    </div>
                </div>
            </div>

            <!-- Pagination (if needed) -->
             <div v-if="totalPages > 1" class="flex justify-center shrink-0 pt-4 border-t border-div-15 mt-auto">
                 <div class="flex items-center gap-2 bg-surface p-1 rounded-lg border border-div-15 shadow-sm">
                    <button @click="page--" :disabled="page <= 1" class="p-1.5 rounded hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg></button>
                    <span class="text-xs font-bold text-secondary px-2">{{ page }} / {{ totalPages }}</span>
                    <button @click="page++" :disabled="page >= totalPages" class="p-1.5 rounded hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg></button>
                 </div>
            </div>

            <ModalObra 
                :isOpen="isModalOpen" 
                :initialData="selectedItem"
                :imageBaseUrl="imageBaseUrl"
                @close="isModalOpen=false" 
                @success="fetchItems" 
            />
        </div>
    </NuxtLayout>
</template>
