<script setup lang="ts">
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import TabCiclos from '@/components/merenda/cardapio/TabCiclos.vue'
import TabEscalaSemanal from '@/components/merenda/cardapio/TabEscalaSemanal.vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'

definePageMeta({
    permission: 'botao:merenda_cardapio',
    layout: false
})

const store = useAppStore()
const toast = useToastStore()
const route = useRoute()
const router = useRouter()

// --- Tabs Config ---
const TABS = [
  { id: 'ciclos', label: 'Ciclos', api: 'merenda/cardapios' },
  { id: 'escala', label: 'Escala Semanal', api: null }
]

const currentTabId = ref(route.query.tab || 'ciclos')
const currentTab = computed(() => TABS.find(t => t.id === currentTabId.value) || TABS[0])

// --- Search State ---
const search = ref('')
const page = ref(1)
const limit = ref(10)

// --- BFF Data Fetching ---
const { data: bffData, pending, error: bffError, refresh } = await useFetch(() => { 
  if (!currentTab.value.api) return null
  return `/api/${currentTab.value.api}`
}, {
  query: computed(() => ({
    id_empresa: store.company?.empresa_id,
    page: page.value,
    limit: limit.value,
    search: search.value || null
  })),
  watch: [currentTabId, page, search, () => store.company?.empresa_id],
  immediate: true
})

const items = computed(() => {
    if (!bffData.value) return []
    if (bffData.value.data && Array.isArray(bffData.value.data)) return bffData.value.data
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
import ModalCiclo from '@/components/merenda/cardapio/ModalCiclo.vue'
import ModalEscalaSemanal from '@/components/merenda/cardapio/ModalEscalaSemanal.vue'
import ModalConfirmacao from '@/components/ModalConfirmacao.vue'

const isModalCicloOpen = ref(false)
const selectedItem = ref(null)

const isModalEscalaOpen = ref(false)
const selectedEscala = ref(null)

const handleNew = () => {
    selectedItem.value = null
    if (currentTabId.value === 'ciclos') {
        isModalCicloOpen.value = true
    } else {
        toast.showToast('Selecione um ciclo primeiro para criar escalas semanais', 'info')
    }
}

const handleEdit = (item) => {
    if (currentTabId.value === 'ciclos') {
        selectedItem.value = item
        isModalCicloOpen.value = true
    } else if (currentTabId.value === 'escala') {
        selectedEscala.value = item
        isModalEscalaOpen.value = true
    }
}

const handleSuccess = () => {
    refresh()
}

// --- Delete Logic ---
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
        let resource = ''
        if (currentTabId.value === 'ciclos') resource = 'cardapios'

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
      <div class="w-10 h-10 rounded bg-primary/10 text-primary flex items-center justify-center shrink-0">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
      </div>
    </template>

    <!-- Header Title -->
    <template #header-title>
      <span class="capitalize">{{ currentTab.label }}</span>
    </template>

    <!-- Header Subtitle -->
    <template #header-subtitle>
      Merenda Escolar - Cardápio
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
        :title="`Cardápio: ${currentTab.label}`" 
        :stats="dashboardStats"
      >
        <template #extra>
          <div class="bg-orange-500/5 p-4 rounded border border-orange-500/10">
            <h4 class="text-[10px] font-black text-orange-500 uppercase tracking-[0.2em] mb-2">Cardápio</h4>
            <p class="text-[11px] text-orange-500/70 leading-relaxed font-medium">
              Gerencie os ciclos de cardápio e suas escalas semanais. Defina o que será servido em cada dia da semana.
            </p>
          </div>
        </template>
      </ManagerDashboard>
    </template>

    <!-- Content -->
    <div class="w-full">
        <TabCiclos 
            v-if="currentTabId === 'ciclos'" 
            :items="items" 
            :is-loading="isLoading"
            @edit="handleEdit" 
            @delete="handleDelete" 
        />
        <TabEscalaSemanal 
            v-if="currentTabId === 'escala'" 
            :items="items" 
            :is-loading="isLoading"
            @edit="handleEdit" 
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
        <ModalCiclo
            :is-open="isModalCicloOpen"
            :initial-data="selectedItem"
            @close="isModalCicloOpen = false"
            @success="handleSuccess"
        />

        <ModalEscalaSemanal
            v-if="currentTabId === 'escala'"
            :is-open="isModalEscalaOpen"
            :initial-data="selectedEscala"
            @close="isModalEscalaOpen = false"
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
