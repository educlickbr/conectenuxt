<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerDashboard from '@/components/ManagerDashboard.vue'
import ModalFolder from '@/components/pedagogico/ModalFolder.vue'
import ModalContentItem from '@/components/pedagogico/ModalContentItem.vue'

// Layout
definePageMeta({
    layout: false, // We use NuxtLayout explicitly for slots
})

const appStore = useAppStore()
const toast = useToastStore()
const route = useRoute()
const router = useRouter()

// Tabs
const tabs = [
  { id: 'atividades', label: 'Atividades' },
  { id: 'relatorios', label: 'Relatórios' },
]

const currentTab = ref('atividades')
const currentTabObj = computed(() => tabs.find(t => t.id === currentTab.value) || tabs[0])

// State
const search = ref('')
const activeSearch = ref('') // Debounced search
const page = ref(1)
const limit = ref(10)

// Modal State
const isModalOpen = ref(false)
const selectedFolder = ref<any>(null)

// Item Modal State
const isItemModalOpen = ref(false)
const activeFolderId = ref<string | null>(null)
const selectedItem = ref<any>(null)

// Data Fetching
const { data: atividadesData, refresh: refreshAtividades, pending: isLoading } = await useFetch('/api/pedagogico/atividades', {
    params: computed(() => ({
        id_empresa: appStore.company?.empresa_id,
        page: page.value,
        limit: limit.value,
        search: activeSearch.value || undefined
    })),
    // Watch params automatically
    watch: [page, activeSearch, () => appStore.company?.empresa_id], 
    immediate: true,
    server: false, // Client-side only to ensure store hydration
    key: 'pedagogico-atividades-list',
    transform: (res: any) => {
        return {
            items: (res.items || []).map((c: any) => ({
                ...c, 
                isExpanded: false,
                itens: c.itens || []
            })),
            total: res.total || 0,
            totalPages: res.pages || 0
        }
    }
})

// State for Items (Local Ref for Reactivity)
const items = ref<any[]>([])

// Synced Computed Refs (Total only)
const total = computed(() => atividadesData.value?.total || 0)
const totalPages = computed(() => atividadesData.value?.totalPages || 0)

// Sync Data
watch(atividadesData, (val) => {
    if (val && val.items) {
        items.value = val.items
    } else {
        items.value = []
    }
}, { immediate: true })

const fetchItems = () => refreshAtividades()

// Watchers
// Handle Query Params for Tabs
watch(() => route.query.tab, (val) => {
    if (val && tabs.find(t => t.id === val)) {
        currentTab.value = val as string
    } else {
        currentTab.value = 'atividades'
    }
    if (currentTab.value === 'atividades') {
       // fetchItems handled by useFetch params usually, but if tab switch needs refresh:
       // refreshAtividades()
    }
}, { immediate: true })

const switchTab = (tabId: string) => {
    router.push({ query: { ...route.query, tab: tabId } })
}

// Debounce Search
let debounceTimer: any
watch(search, (val) => {
    clearTimeout(debounceTimer)
    debounceTimer = setTimeout(() => {
        page.value = 1
        activeSearch.value = val 
        refreshAtividades()
    }, 400)
})

watch(page, () => refreshAtividades())

// Actions
const handleAdd = () => {
    selectedFolder.value = null
    isModalOpen.value = true
}

const toggleExpand = (item: any) => {
    console.log('Toggling item:', item.id, 'Current state:', item.isExpanded)
    item.isExpanded = !item.isExpanded
}

const handleEditConteudo = (item: any) => {
    selectedFolder.value = item
    isModalOpen.value = true
}

const handleDelete = (item: any) => {
    toast.showToast(`Excluir folder: ${item.titulo}`, 'info')
}

const handleEditItem = (content: any, item: any) => {
    activeFolderId.value = content.id
    selectedItem.value = item
    isItemModalOpen.value = true
}

const handleAddItem = (content: any) => {
    activeFolderId.value = content.id
    selectedItem.value = null
    isItemModalOpen.value = true
}

// Helpers
const getScopeBadgeClass = (scope: string) => {
    switch(scope) {
        case 'Turma': return 'bg-blue-500/10 text-blue-500 border-blue-500/20'
        case 'Aluno': return 'bg-purple-500/10 text-purple-500 border-purple-500/20'
        case 'Grupo': return 'bg-orange-500/10 text-orange-500 border-orange-500/20'
        case 'Global': return 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20'
        default: return 'bg-secondary/10 text-secondary border-secondary/20'
    }
}

const getItemIcon = (tipo: string) => {
    switch(tipo) {
        case 'Video': return '🎥'
        case 'Material': return '📄'
        case 'Tarefa': return '📝'
        case 'Questionario': return '❓'
        default: return '📎'
    }
}

const formatDate = (dateStr: string | null) => {
    if (!dateStr) return 'Sem data'
    return new Date(dateStr).toLocaleDateString('pt-BR')
}

// Dashboard Stats
const dashboardStats = computed(() => {
    if (currentTab.value === 'atividades') {
        return [
            { label: 'Total Folders', value: total.value },
            { label: 'Global', value: items.value.filter(i => i.escopo === 'Global').length },
            { label: 'Turmas', value: items.value.filter(i => i.escopo === 'Turma').length }
        ]
    }
    return [
       { label: 'Relatórios Gerados', value: 0 }
    ]
})
</script>

<template>
    <NuxtLayout name="manager">
        
        <!-- Header Slots -->
        <template #header-icon>
            <div class="w-10 h-10 rounded bg-violet-500/10 text-violet-500 flex items-center justify-center shrink-0 text-xl font-bold">
                {{ currentTabObj?.label?.charAt(0) }}
            </div>
        </template>
        
        <template #header-title>
            Gestão de Atividades
        </template>

        <template #header-subtitle>
            Gerenciamento de atividades pedagógicas
        </template>

        <template #header-actions>
            <div class="relative w-full sm:max-w-[180px]">
                <input 
                    v-model="search"
                    type="text" 
                    placeholder="Buscar..." 
                    class="w-full pl-8 pr-3 py-1.5 text-xs bg-background border border-secondary/30 rounded text-text focus:outline-none focus:border-primary transition-all placeholder:text-secondary/70 shadow-sm"
                >
                <div class="absolute left-2.5 top-1/2 -translate-y-1/2 text-secondary/70">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                </div>
            </div>

            <button 
                @click="handleAdd"
                class="bg-primary hover:bg-primary-hover text-white px-4 py-1.5 rounded text-xs font-bold transition-all shadow-sm hover:shadow-md flex items-center gap-1 shrink-0"
            >
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                <span class="hidden sm:inline">Novo</span>
            </button>
        </template>

        <!-- Tabs Slot -->
        <template #tabs>
            <button 
                v-for="tab in tabs" 
                :key="tab.id"
                @click="switchTab(tab.id)"
                class="relative px-4 py-3 text-sm font-bold transition-all whitespace-nowrap outline-none"
                :class="currentTab === tab.id ? 'text-primary' : 'text-secondary hover:text-text'"
            >
                {{ tab.label }}
                <div v-if="currentTab === tab.id" class="absolute bottom-0 left-0 w-full h-[3px] bg-primary rounded-full" />
            </button>
        </template>

        <!-- Sidebar Slot -->
        <template #sidebar>
            <ManagerDashboard 
                :title="`Dashboard: ${currentTabObj?.label}`" 
                :stats="dashboardStats"
            >
                <template #extra>
                    <div class="bg-violet-500/5 p-4 rounded border border-violet-500/10">
                        <h4 class="text-[10px] font-black text-violet-500 uppercase tracking-[0.2em] mb-2">Pedagógico</h4>
                        <p class="text-[11px] text-violet-500/70 leading-relaxed font-medium">
                            Organize suas aulas por <b>Folders</b> para facilitar a navegação do aluno. Cada folder pode conter múltiplos recursos.
                        </p>
                    </div>
                </template>
            </ManagerDashboard>
        </template>

        <!-- Modals Slot -->
        <template #modals>
             <ModalFolder 
                :isOpen="isModalOpen" 
                :initialData="selectedFolder" 
                @close="isModalOpen = false" 
                @success="fetchItems" 
            />
            <ModalContentItem
                :isOpen="isItemModalOpen"
                :initialData="selectedItem"
                :folderId="activeFolderId"
                @close="isItemModalOpen = false"
                @success="fetchItems"
            />
        </template>

        <!-- Main Content (Default Slot) -->
        <div class="w-full">
            <div v-if="isLoading && items.length === 0" class="flex flex-col items-center justify-center p-12 text-secondary gap-3">
                 <div class="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                 Carregando atividades...
            </div>

            <div v-else-if="items.length === 0 && currentTab === 'atividades'" class="flex flex-col items-center justify-center p-12 text-secondary text-center">
                 <div class="text-4xl mb-2 opacity-50">📭</div>
                 <p>Nenhuma atividade encontrada.</p>
                 <button @click="handleAdd" class="text-primary hover:underline font-bold mt-2">Criar primeiro folder</button>
            </div>
            
             <!-- Relatórios Placeholder -->
            <div v-else-if="currentTab === 'relatorios'" class="flex flex-col items-center justify-center p-12 text-secondary text-center">
                 <div class="text-4xl mb-2 opacity-50">📊</div>
                 <p>Relatórios em construção.</p>
            </div>

            <!-- List View -->
            <div v-else class="space-y-3">
                <div v-for="item in items" :key="item.id" class="bg-surface rounded-lg border border-div-15 shadow-sm overflow-hidden transition-all duration-300 group hover:border-div-30">
                    <!-- Card Header -->
                    <div class="p-4 flex items-center gap-4 cursor-pointer hover:bg-div-05/50 transition-colors" @click="toggleExpand(item)">
                        <!-- Simple Arrow Button (Reference Style) -->
                        <button class="p-1 text-secondary hover:text-primary transition-transform duration-200" :class="{'rotate-90': item.isExpanded}">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                        </button>
                        
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center gap-2">
                                <h3 class="font-bold text-text text-sm truncate group-hover:text-primary transition-colors">{{ item.titulo }}</h3>
                                <span :class="getScopeBadgeClass(item.escopo)" class="text-[9px] font-black uppercase tracking-widest px-1.5 py-0.5 rounded border">
                                    {{ item.escopo }}
                                </span>
                            </div>
                            <div class="flex items-center gap-3 text-[10px] text-secondary mt-1">
                                <span class="flex items-center gap-1">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18"/><path d="M5 21V7l8-4 8 4v14"/><path d="M17 21v-8H7v8"/></svg>
                                    {{ item.nome_turma || 'Geral' }}
                                </span>
                                <span class="flex items-center gap-1">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="4" rx="2" ry="2"/><line x1="16" x2="16" y1="2" y2="6"/><line x1="8" x2="8" y1="2" y2="6"/><line x1="3" x2="21" y1="10" y2="10"/></svg>
                                    {{ formatDate(item.data_referencia || item.criado_em) }}
                                </span>
                            </div>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="text-[10px] font-bold text-secondary bg-div-05 px-2 py-1 rounded-md border border-div-15">
                                {{ item.itens ? item.itens.length : 0 }} itens
                            </div>
                            <div class="flex items-center gap-1 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity">
                                <button @click.stop="handleEditConteudo(item)" class="p-2 hover:bg-primary/10 text-secondary hover:text-primary rounded-lg transition-colors" title="Editar">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                </button>
                                <button @click.stop="handleDelete(item)" class="p-2 hover:bg-danger/10 text-secondary hover:text-danger rounded-lg transition-colors" title="Excluir">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Nested Items Area -->
                    <div v-show="item.isExpanded" class="bg-div-05/30 border-t border-div-15 p-4 space-y-2 animate-in slide-in-from-top-2 duration-200">
                        <div v-for="subItem in item.itens" :key="subItem.id" class="bg-surface p-3 rounded-lg border border-div-15 flex items-center justify-between group/item hover:border-primary/30 transition-all hover:shadow-sm">
                            <div class="flex items-center gap-3">
                                <span class="text-lg bg-div-05 w-8 h-8 flex items-center justify-center rounded-md">{{ getItemIcon(subItem.tipo) }}</span>
                                <div class="flex flex-col">
                                    <span class="text-xs font-bold text-text group-hover/item:text-primary transition-colors">{{ subItem.titulo }}</span>
                                    <div class="flex items-center gap-2 text-[9px] text-secondary font-medium mt-0.5 uppercase tracking-tighter">
                                        <span>{{ subItem.tipo }}</span>
                                        <span v-if="subItem.pontuacao_maxima" class="text-orange-500">• {{ subItem.pontuacao_maxima }} pts</span>
                                    </div>
                                </div>
                            </div>
                            <div class="flex items-center gap-1 opacity-0 group-hover/item:opacity-100 transition-opacity">
                                <button @click="handleEditItem(item, subItem)" class="p-1.5 text-secondary hover:text-primary transition-colors rounded hover:bg-primary/5">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                </button>
                            </div>
                        </div>
                        <button @click="handleAddItem(item)" class="w-full py-2.5 border border-dashed border-div-15 hover:border-primary/40 rounded-lg text-[10px] font-bold text-secondary hover:text-primary transition-all uppercase tracking-widest bg-transparent hover:bg-primary/5">
                            + Adicionar Atividade
                        </button>
                    </div>
                </div>
            </div>

            <!-- Pagination -->
            <div v-if="totalPages > 1 && currentTab === 'atividades'" class="flex items-center justify-center gap-4 mt-6 py-4">
                <button @click="page--" :disabled="page <= 1" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30">Anterior</button>
                <span class="text-[11px] font-black bg-div-15 px-3 py-1 rounded-full border border-secondary/10">{{ page }} / {{ totalPages }}</span>
                <button @click="page++" :disabled="page >= totalPages" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30">Próxima</button>
            </div>
        </div>

    </NuxtLayout>
</template>
