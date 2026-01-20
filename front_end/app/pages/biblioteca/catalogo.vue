<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'

// Modals
import ModalEditora from '@/components/biblioteca/catalogo/ModalEditora.vue'
import ModalAutoria from '@/components/biblioteca/catalogo/ModalAutoria.vue'
import ModalCategoria from '@/components/biblioteca/catalogo/ModalCategoria.vue'
import ModalCdu from '@/components/biblioteca/catalogo/ModalCdu.vue'
import ModalMetadado from '@/components/biblioteca/catalogo/ModalMetadado.vue'
import ModalDoador from '@/components/biblioteca/catalogo/ModalDoador.vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'

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
  { id: 'editoras', label: 'Editoras' },
  { id: 'autoria', label: 'Autoria' },
  { id: 'categoria', label: 'Categoria' },
  { id: 'cdu', label: 'CDU' },
  { id: 'metadado', label: 'Metadado' },
  { id: 'doador', label: 'Doador' },
]

const currentTab = ref('editoras')
const currentTabObj = computed(() => tabs.find(t => t.id === currentTab.value) || tabs[0])

// State
const items = ref<any[]>([])
const total = ref(0)
const page = ref(1)
const totalPages = ref(0)
const limit = ref(10)
const search = ref('')
const isLoading = ref(false)

// Modals
const isModalOpen = ref(false)
const selectedItem = ref<any>(null)
const isDeleteModalOpen = ref(false)
const itemToDelete = ref<any>(null)
const isDeleting = ref(false)

// Fetch Data (BFF)
const fetchItems = async () => {
    isLoading.value = true
    try {
        const result = await $fetch(`/api/biblioteca/catalogo/${currentTab.value}`, {
            params: {
                id_empresa: appStore.company?.empresa_id,
                page: page.value,
                limit: limit.value,
                search: search.value || undefined
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

// Sync with Query Param ?tab=...
watch(() => route.query.tab, (val) => {
    if (val && tabs.find(t => t.id === val)) {
        currentTab.value = val as string
    } else {
        currentTab.value = 'editoras'
    }
    fetchItems()
}, { immediate: true })

const switchTab = (tabId: string) => {
    router.push({ query: { ...route.query, tab: tabId } })
}

// Debounced Search
let debounceTimer: any
const handleSearch = () => {
    clearTimeout(debounceTimer)
    debounceTimer = setTimeout(() => {
        page.value = 1
        fetchItems()
    }, 400)
}
watch(search, handleSearch)

// Actions
const handleAdd = () => {
    selectedItem.value = null
    isModalOpen.value = true
}

const handleEdit = (item: any) => {
    selectedItem.value = item
    isModalOpen.value = true
}

const handleDelete = (item: any) => {
    itemToDelete.value = item
    isDeleteModalOpen.value = true
}

const confirmDelete = async () => {
    if (!itemToDelete.value) return
    isDeleting.value = true
    try {
        await $fetch(`/api/biblioteca/catalogo/${currentTab.value}`, {
            method: 'POST',
            body: {
                action: 'delete',
                id: itemToDelete.value.id || itemToDelete.value.uuid,
                id_empresa: appStore.company?.empresa_id
            }
        })
        toast.showToast('Item removido com sucesso.', 'success')
        isDeleteModalOpen.value = false
        fetchItems()
    } catch (e: any) {
         toast.showToast(e.statusMessage || 'Erro ao remover.', 'error')
    } finally {
        isDeleting.value = false
    }
}

// Helpers for List Display
const getItemTitle = (item: any) => {
    return item.nome || item.nome_completo || item.descricao || item.rotulo || 'Item sem nome'
}
const getItemSubtitle = (item: any) => {
    if (item.email) return item.email
    if (item.codigo_cutter) return `Cutter: ${item.codigo_cutter}`
    if (item.codigo_cdu) return `CDU: ${item.codigo_cdu}`
    return ''
}

// Dashboard Stats
const dashboardStats = computed(() => [
  { label: 'Total Registros', value: total.value },
  { label: 'Página Atual', value: page.value }
])
</script>

<template>
    <NuxtLayout name="manager">
        
        <!-- Header Slots -->
        <template #header-icon>
            <div class="w-10 h-10 rounded bg-emerald-500/10 text-emerald-500 flex items-center justify-center shrink-0 text-xl font-bold">
                {{ currentTabObj?.label?.charAt(0) }}
            </div>
        </template>
        
        <template #header-title>
            Catálogo Bibliográfico
        </template>

        <template #header-subtitle>
            Gerenciamento de dados auxiliares do acervo
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
                    <div class="bg-emerald-500/5 p-4 rounded border border-emerald-500/10">
                        <h4 class="text-[10px] font-black text-emerald-500 uppercase tracking-[0.2em] mb-2">Catálogo</h4>
                        <p class="text-[11px] text-emerald-500/70 leading-relaxed font-medium">
                            Gerencie editoras, autores, categorias e outros metadados essenciais para a organização do acervo bibliográfico.
                        </p>
                    </div>
                </template>
            </ManagerDashboard>
        </template>

        <!-- Modals Slot -->
        <template #modals>
            <ModalEditora v-if="currentTab === 'editoras'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen=false" @success="fetchItems" />
            <ModalAutoria v-if="currentTab === 'autoria'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen=false" @success="fetchItems" />
            <ModalCategoria v-if="currentTab === 'categoria'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen=false" @success="fetchItems" />
            <ModalCdu v-if="currentTab === 'cdu'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen=false" @success="fetchItems" />
            <ModalMetadado v-if="currentTab === 'metadado'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen=false" @success="fetchItems" />
            <ModalDoador v-if="currentTab === 'doador'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen=false" @success="fetchItems" />

            <!-- Confirm Delete Modal -->
            <div v-if="isDeleteModalOpen" class="fixed inset-0 z-[60] flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-in fade-in duration-200" @click.self="isDeleteModalOpen=false">
                 <div class="bg-surface w-full max-w-sm rounded-xl border border-div-15 shadow-2xl p-6 text-center animate-in zoom-in-95 duration-200">
                      <div class="w-16 h-16 rounded-full bg-danger/10 text-danger flex items-center justify-center mx-auto mb-4">
                          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                      </div>
                      <h3 class="text-xl font-bold text-text mb-2 animate-pulse">Excluir Registro?</h3>
                      <p class="text-secondary text-sm mb-6">Esta ação não pode ser desfeita.</p>
                      
                      <div class="flex gap-3">
                          <button @click="isDeleteModalOpen=false" class="flex-1 py-2.5 rounded-lg border border-div-15 hover:bg-div-05 transition-colors font-bold text-secondary">Cancelar</button>
                          <button @click="confirmDelete" :disabled="isDeleting" class="flex-1 py-2.5 rounded-lg bg-danger text-white font-bold hover:bg-danger/90 transition-colors flex items-center justify-center gap-2">
                               <span v-if="isDeleting" class="animate-spin w-4 h-4 border-2 border-white/50 border-t-white rounded-full"></span>
                               Excluir
                          </button>
                      </div>
                 </div>
            </div>
        </template>

        <!-- Main Content (Default Slot) -->
        <div class="w-full">
            <div v-if="isLoading" class="flex flex-col items-center justify-center p-12 text-secondary gap-3">
                 <div class="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                 Carregando registros...
            </div>

            <div v-else-if="items.length === 0" class="flex flex-col items-center justify-center p-12 text-secondary text-center">
                 <div class="text-4xl mb-2 opacity-50">📭</div>
                 <p>Nenhum registro encontrado em <strong>{{ currentTabObj?.label }}</strong>.</p>
                 <button @click="handleAdd" class="text-primary hover:underline font-bold mt-2">Adicionar novo item</button>
            </div>

            <div v-else class="rounded-xl border border-div-15 bg-surface overflow-hidden">
                <table class="w-full text-left border-collapse">
                    <thead class="bg-div-05 text-xs font-bold text-secondary uppercase tracking-wider">
                        <tr>
                            <th class="p-4 border-b border-div-15">Item</th>
                            <th class="p-4 border-b border-div-15 w-32 text-center">Ações</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-div-15 text-sm">
                        <tr v-for="item in items" :key="item.id || item.uuid" class="hover:bg-div-05/50 transition-colors group">
                            <td class="p-4">
                                <div class="font-bold text-text">{{ getItemTitle(item) }}</div>
                                <div class="text-xs text-secondary mt-0.5">{{ getItemSubtitle(item) }}</div>
                            </td>
                            <td class="p-4 flex items-center justify-center gap-2 opacity-80 group-hover:opacity-100">
                                <button @click="handleEdit(item)" class="p-2 text-secondary hover:text-primary hover:bg-primary/10 rounded-lg transition-colors" title="Editar">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                </button>
                                <button @click="handleDelete(item)" class="p-2 text-secondary hover:text-danger hover:bg-danger/10 rounded-lg transition-colors" title="Excluir">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <div v-if="totalPages > 1" class="flex items-center justify-center gap-4 mt-6 py-4">
                <button @click="page--" :disabled="page <= 1" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30">Anterior</button>
                <span class="text-[11px] font-black bg-div-15 px-3 py-1 rounded-full border border-secondary/10">{{ page }} / {{ totalPages }}</span>
                <button @click="page++" :disabled="page >= totalPages" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30">Próxima</button>
            </div>
        </div>

    </NuxtLayout>
</template>
