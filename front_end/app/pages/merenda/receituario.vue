<script setup lang="ts">
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerDashboard from '@/components/ManagerDashboard.vue'
import ModalConfirmacao from '@/components/ModalConfirmacao.vue'

// Import Tab Components
import TabPratos from '@/components/merenda/receituario/TabPratos.vue'
import TabReceitas from '@/components/merenda/receituario/TabReceitas.vue'

// Page Meta
definePageMeta({
    permission: 'botao:merenda_receituario',
    layout: false
})

const appStore = useAppStore()
const toast = useToastStore()
const route = useRoute()
const router = useRouter()

// --- Tabs Config ---
const TABS = [
  { id: 'pratos', label: 'Pratos', api: 'merenda/pratos' },
  { id: 'receitas', label: 'Receitas', api: 'merenda/fichastecnicas' }
]

const currentTabId = ref(route.query.tab || 'pratos')
const currentTab = computed(() => TABS.find(t => t.id === currentTabId.value) || TABS[0])

// --- Search/Pagination State ---
const search = ref('')
const page = ref(1)
const limit = ref(10)

// --- BFF Data Fetching ---
const { data: bffData, pending, refresh } = await useFetch<any>(() => `/api/${currentTab.value?.api}`, {
    query: computed(() => ({
        id_empresa: appStore.company?.empresa_id,
        page: page.value,
        limit: limit.value,
        search: search.value || null
    })),
    watch: [currentTabId, page, search, () => appStore.company?.empresa_id],
    immediate: true
})

const items = computed(() => {
    if (!bffData.value) return []
    // If it's paginated object { data: [], total: ... }
    if (bffData.value.data && Array.isArray(bffData.value.data)) return bffData.value.data
    // If it's straight array
    if (Array.isArray(bffData.value)) return bffData.value
    return []
})

const total = computed(() => (bffData.value as any)?.total || items.value.length)
const pagesTotal = computed(() => {
    const t = (bffData.value as any)?.total
    if (!t) return 1
    return Math.ceil(t / limit.value)
})

const isLoading = computed(() => pending.value)

// --- Watchers ---
watch(currentTabId, (newId) => {
  page.value = 1
  search.value = ''
  router.push({ query: { ...route.query, tab: newId } })
})

const switchTab = (tabId: string) => {
  currentTabId.value = tabId
}

// --- Modals State ---
import ModalPratos from '@/components/merenda/receituario/ModalPratos.vue'
import ModalFichaTecnica from '@/components/merenda/receituario/ModalFichaTecnica.vue'

const isModalPratosOpen = ref(false)
const isModalReceitaOpen = ref(false)
const selectedItem = ref<any>(null)

const handleNew = () => {
    selectedItem.value = null
    if (currentTabId.value === 'pratos') {
        isModalPratosOpen.value = true
    } else {
        toast.showToast('Selecione um prato na aba Receitas para detalhar sua ficha técnica', 'info')
    }
}

const handleEdit = (item: any) => {
    selectedItem.value = item
    if (currentTabId.value === 'pratos') {
        isModalPratosOpen.value = true
    } else {
        isModalReceitaOpen.value = true
    }
}

const handleSuccess = () => {
    refresh()
}

// --- Delete Logic ---
const isConfirmOpen = ref(false)
const isDeleting = ref(false)
const itemToDelete = ref<any>(null)

const handleDelete = (item: any) => {
    itemToDelete.value = item
    if (currentTabId.value === 'pratos') {
        isConfirmOpen.value = true
    } else {
        toast.showToast('Para remover ingredientes, edite a ficha técnica', 'info')
    }
}

const confirmDelete = async () => {
    if (!itemToDelete.value) return 
    isDeleting.value = true
    try {
        const { success } = await $fetch(`/api/merenda/pratos/delete`, {
            method: 'POST',
            body: {
                id: itemToDelete.value.id,
                id_empresa: appStore.company.empresa_id
            }
        })

        if (success) {
            toast.showToast('Prato excluído com sucesso!')
            isConfirmOpen.value = false
            itemToDelete.value = null
            refresh()
        }
    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao excluir prato.', 'error')
    } finally {
        isDeleting.value = false
    }
}

// Stats
const dashboardStats = computed(() => [
    { label: 'Total', value: total.value },
    { label: 'Página', value: page.value }
])
</script>

<template>
    <NuxtLayout name="manager">
        <!-- Header Icon -->
        <template #header-icon>
            <div class="w-10 h-10 rounded bg-primary/10 text-primary flex items-center justify-center shrink-0">
                <svg v-if="currentTabId === 'pratos'" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12h20"/><path d="M20 12v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-8"/><path d="m4 8 16-4"/><path d="m8.86 6.78-.45-1.81a2 2 0 0 1 1.45-2.43l1.94-.55a2 2 0 0 1 2.43 1.45l.45 1.81"/></svg>
                <svg v-else xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 3h5v5"/><path d="M8 3H3v5"/><path d="M12 22v-8.3a4 4 0 0 0-1.172-2.872L3 3"/><path d="m15 9 6-6"/><path d="M3 21h18"/></svg>
            </div>
        </template>

        <template #header-title>
            <span class="capitalize">{{ currentTab?.label }}</span>
        </template>

        <!-- Header Subtitle -->
        <template #header-subtitle>
            Receituário e Gestão de Pratos
        </template>

        <!-- Header Actions -->
        <template #header-actions>
            <div class="relative w-full sm:max-w-[180px]">
                <input 
                    type="text" 
                    v-model="search" 
                    placeholder="Buscar..." 
                    class="w-full pl-8 pr-3 py-1.5 text-xs bg-background border border-secondary/30 rounded text-text focus:outline-none focus:border-primary transition-all placeholder:text-secondary/70 shadow-sm"
                >
                <div class="absolute left-2.5 top-1/2 -translate-y-1/2 text-secondary/70">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                </div>
            </div>

            <button v-if="currentTabId === 'pratos'" @click="handleNew" class="bg-primary hover:bg-primary/90 text-white px-4 py-1.5 rounded text-xs font-bold transition-all shadow-sm hover:shadow-md flex items-center gap-1 shrink-0">
                <span>+</span> <span class="hidden sm:inline">Novo</span>
            </button>
        </template>

        <!-- Tabs -->
        <template #tabs>
          <button
            v-for="tab in TABS"
            :key="tab.id"
            @click="switchTab(tab.id)"
            :class="[
              'relative px-4 py-3 text-sm font-bold transition-all whitespace-nowrap outline-none',
              currentTabId === tab.id ? 'text-primary' : 'text-secondary hover:text-text'
            ]"
          >
            {{ tab.label }}
            <div v-if="currentTabId === tab.id" class="absolute bottom-0 left-0 w-full h-[3px] bg-primary rounded-full" />
          </button>
        </template>

        <template #sidebar>
            <ManagerDashboard 
                :title="`Receituário: ${currentTab?.label}`" 
                :stats="dashboardStats"
            >
                <template #extra>
                    <div class="bg-orange-500/5 p-4 rounded border border-orange-500/10">
                        <h4 class="text-[10px] font-black text-orange-500 uppercase tracking-[0.2em] mb-2">Orientações</h4>
                        <p v-if="currentTabId === 'pratos'" class="text-[11px] text-orange-500/70 leading-relaxed font-medium">
                            Gerencie aqui o nome dos pratos e seu modo de preparo básico.
                        </p>
                        <p v-else class="text-[11px] text-orange-500/70 leading-relaxed font-medium">
                            Selecione um prato para detalhar seus ingredientes e as quantidades necessárias na ficha técnica.
                        </p>
                    </div>
                </template>
            </ManagerDashboard>
        </template>

        <!-- Content -->
        <div class="w-full">
            <TabPratos 
                v-if="currentTabId === 'pratos'" 
                :items="items" 
                :is-loading="isLoading"
                @edit="handleEdit" 
                @delete="handleDelete" 
            />
            <TabReceitas 
                v-if="currentTabId === 'receitas'" 
                :items="items" 
                :is-loading="isLoading"
                @edit="handleEdit" 
                @delete="handleDelete" 
            />
        </div>

        <!-- Pagination -->
        <div v-if="!isLoading && pagesTotal > 1" class="flex items-center justify-center gap-4 mt-6 py-4">
            <button @click="page--" :disabled="page === 1" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30">Anterior</button>
            <span class="text-[11px] font-black bg-div-15 px-3 py-1 rounded-full border border-secondary/10">{{ page }} / {{ pagesTotal }}</span>
            <button @click="page++" :disabled="page >= pagesTotal" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30">Próxima</button>
        </div>

        <!-- Modals -->
        <template #modals>
            <ModalPratos
                :is-open="isModalPratosOpen"
                :initial-data="selectedItem"
                @close="isModalPratosOpen = false"
                @success="handleSuccess"
            />

            <ModalFichaTecnica
                :is-open="isModalReceitaOpen"
                :initial-data="selectedItem"
                @close="isModalReceitaOpen = false"
                @success="handleSuccess"
            />

            <ModalConfirmacao
                :is-open="isConfirmOpen"
                title="Excluir Prato?"
                :message="`Deseja realmente excluir o prato <b>${itemToDelete?.nome || 'este prato'}</b>?`"
                confirm-text="Sim, excluir"
                :is-loading="isDeleting"
                @close="isConfirmOpen = false"
                @confirm="confirmDelete"
            />
        </template>
    </NuxtLayout>
</template>
