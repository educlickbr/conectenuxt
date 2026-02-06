<script setup>
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
// Import Tab Components
import TabTipos from '@/components/merenda/base/TabTipos.vue'
import TabAlimentos from '@/components/merenda/base/TabAlimentos.vue'
import TabPratos from '@/components/merenda/base/TabPratos.vue'

// Import ManagerDashboard (Assuming it's a globally available or common component, matching estrutura_academica patterns)
import ManagerDashboard from '@/components/ManagerDashboard.vue'

// Page Meta
definePageMeta({
    permission: 'botao:merenda_base',
    layout: false
})

const store = useAppStore()
const toast = useToastStore()
const route = useRoute()
const router = useRouter()

// --- Tabs Config ---
const TABS = [
  { id: 'tipos', label: 'Tipos de Refeição', api: 'merenda/refeicaotipos' },
  { id: 'alimentos', label: 'Alimentos', api: 'merenda/alimentos' },
  { id: 'pratos', label: 'Pratos', api: 'merenda/pratos' }
]

const currentTabId = ref(route.query.tab || 'tipos')
const currentTab = computed(() => TABS.find(t => t.id === currentTabId.value) || TABS[0])

// --- Search State ---
const search = ref('')
const page = ref(1)
const limit = ref(10)

// --- BFF Data Fetching ---
const { data: bffData, pending, error: bffError, refresh, execute } = await useFetch(() => { 
  return `/api/${currentTab.value.api}`
}, {
  query: computed(() => ({
    id_empresa: store.company?.empresa_id,
    page: page.value, // Using 'page' as per API definition (though structure_academica used 'pagina', check API files)
    limit: limit.value,
    search: search.value || null
  })),
  watch: [currentTabId, page, search, () => store.company?.empresa_id],
  immediate: true
})

// Note: API implementation used 'mrd_alimento_get_paginado' which returns { data, total, pagina, limite }
// But for 'refeicaotipos', it returns a straight array. We need to handle this difference.
// Let's normalize.

const items = computed(() => {
    if (!bffData.value) return []
    // If it's paginated object
    if (bffData.value.data && Array.isArray(bffData.value.data)) return bffData.value.data
    // If it's straight array (e.g. Types)
    if (Array.isArray(bffData.value)) return bffData.value
    return []
})

const total = computed(() => bffData.value?.total || items.value.length)
const pagesTotal = computed(() => {
    if (!bffData.value?.total) return 1
    return Math.ceil(bffData.value.total / limit.value)
})

const isLoading = computed(() => pending.value)


// --- Watchers ---
watch(currentTabId, (newId) => {
  page.value = 1
  search.value = ''
  router.push({ query: { ...route.query, tab: newId } })
})

const switchTab = (tabId) => {
  currentTabId.value = tabId
}

// --- Modals State ---
import ModalTipos from '@/components/merenda/base/ModalTipos.vue'
import ModalAlimentos from '@/components/merenda/base/ModalAlimentos.vue'
import ModalPratos from '@/components/merenda/base/ModalPratos.vue'

const isModalTiposOpen = ref(false)
const isModalAlimentosOpen = ref(false)
const isModalPratosOpen = ref(false)
const selectedItem = ref(null)

const handleNew = () => {
    selectedItem.value = null
    if (currentTabId.value === 'tipos') {
        isModalTiposOpen.value = true
    } else if (currentTabId.value === 'alimentos') {
        isModalAlimentosOpen.value = true
    } else if (currentTabId.value === 'pratos') {
        isModalPratosOpen.value = true
    } else {
        toast.showToast(`Novo ${currentTab.value.label} em desenvolvimento`, 'info')
    }
}

const handleEdit = (item) => {
    selectedItem.value = item
    if (currentTabId.value === 'tipos') {
        isModalTiposOpen.value = true
    } else if (currentTabId.value === 'alimentos') {
        isModalAlimentosOpen.value = true
    } else if (currentTabId.value === 'pratos') {
        isModalPratosOpen.value = true
    } else {
        toast.showToast(`Editar ${item.nome} em desenvolvimento`, 'info')
    }
}

const handleSuccess = () => {
    refresh()
}

// --- Delete Logic ---
import ModalConfirmacao from '@/components/ModalConfirmacao.vue' // Reuse existing
const isConfirmOpen = ref(false)
const isDeleting = ref(false)
const itemToDelete = ref(null)

const handleDelete = (item) => {
    itemToDelete.value = item
    isConfirmOpen.value = true
}

const confirmDelete = async () => {
    if (!itemToDelete.value) return 
    isDeleting.value = true
    try {
        // Construct delete URL based on tab. All delete endpoints are at 'delete.post.ts' within subfolder
        // Using $fetch to call POST with body { id, id_empresa } to /api/merenda/[resource]/delete
        
        let resource = ''
        if (currentTabId.value === 'tipos') resource = 'refeicaotipos'
        if (currentTabId.value === 'alimentos') resource = 'alimentos'
        if (currentTabId.value === 'pratos') resource = 'pratos'

        const { success } = await $fetch(`/api/merenda/${resource}/delete`, {
            method: 'POST',
            body: {
                id: itemToDelete.value.id,
                id_empresa: store.company.empresa_id
            }
        })

        if (success) {
            toast.showToast('Registro excluído com sucesso!')
            isConfirmOpen.value = false
            itemToDelete.value = null
            refresh()
        }
    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao excluir registro.', 'error')
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
      <div class="w-10 h-10 rounded bg-primary/10 text-primary flex items-center justify-center shrink-0 text-xl">
        <svg v-if="currentTabId === 'tipos'" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"/><path d="M7 2v20"/><path d="M21 15V2v0a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7"/></svg>
        <svg v-if="currentTabId === 'alimentos'" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2.27 21.7s9.87-3.5 12.73-6.36a4.5 4.5 0 0 0-6.36-6.37C5.77 11.84 2.27 21.7 2.27 21.7z"/><path d="M8.64 14l-2.05 2.04"/><path d="M15.34 15l-2.46-.61"/><path d="M15.34 15l.61 2.46"/><path d="M15.34 15l-6.7-6.7"/></svg>
        <svg v-if="currentTabId === 'pratos'" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12h20"/><path d="M20 12v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-8"/><path d="m4 8 16-4"/><path d="m8.86 6.78-.45-1.81a2 2 0 0 1 1.45-2.43l1.94-.55a2 2 0 0 1 2.43 1.45l.45 1.81"/></svg>
      </div>
    </template>

    <!-- Header Title -->
    <template #header-title>
      <span class="capitalize">{{ currentTab.label }}</span>
    </template>

    <!-- Header Subtitle -->
    <template #header-subtitle>
      Merenda Escolar - Base de Dados
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

      <button @click="handleNew" class="bg-primary hover:bg-primary/90 text-white px-4 py-1.5 rounded text-xs font-bold transition-all shadow-sm hover:shadow-md flex items-center gap-1 shrink-0">
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

    <!-- Sidebar -->
    <template #sidebar>
      <ManagerDashboard 
        :title="`Merenda: ${currentTab.label}`" 
        :stats="dashboardStats"
      >
        <template #extra>
          <div class="bg-orange-500/5 p-4 rounded border border-orange-500/10">
            <h4 class="text-[10px] font-black text-orange-500 uppercase tracking-[0.2em] mb-2">Base de Dados</h4>
            <p class="text-[11px] text-orange-500/70 leading-relaxed font-medium">
              Gerencie os elementos fundamentais para a composição do cardápio: Tipos de refeição, Ingredientes e Pratos.
            </p>
          </div>
        </template>
      </ManagerDashboard>
    </template>

    <!-- Content -->
    <div class="w-full">
        <TabTipos 
            v-if="currentTabId === 'tipos'" 
            :items="items" 
            :is-loading="isLoading"
            @edit="handleEdit" 
            @delete="handleDelete" 
        />
        <TabAlimentos 
            v-if="currentTabId === 'alimentos'" 
            :items="items" 
            :is-loading="isLoading"
            @edit="handleEdit" 
            @delete="handleDelete" 
        />
        <TabPratos 
            v-if="currentTabId === 'pratos'" 
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
        <ModalTipos
            :is-open="isModalTiposOpen"
            :initial-data="selectedItem"
            @close="isModalTiposOpen = false"
            @success="handleSuccess"
        />

        <ModalAlimentos
            :is-open="isModalAlimentosOpen"
            :initial-data="selectedItem"
            @close="isModalAlimentosOpen = false"
            @success="handleSuccess"
        />

        <ModalPratos
            :is-open="isModalPratosOpen"
            :initial-data="selectedItem"
            @close="isModalPratosOpen = false"
            @success="handleSuccess"
        />

        <ModalConfirmacao
            :is-open="isConfirmOpen"
            title="Excluir Registro?"
            :message="`Deseja realmente excluir <b>${itemToDelete?.nome || 'este item'}</b>?<br>Esta ação não pode ser desfeita.`"
            confirm-text="Sim, excluir"
            :is-loading="isDeleting"
            @close="isConfirmOpen = false"
            @confirm="confirmDelete"
        />
    </template>

  </NuxtLayout>
</template>
