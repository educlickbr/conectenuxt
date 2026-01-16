<script setup>
definePageMeta({
  layout: false
})

import ManagerListItem from '@/components/ManagerListItem.vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'
import ModalConfirmacao from '@/components/ModalConfirmacao.vue'
import { useToastStore } from '@/stores/toast'

// Dynamic imports for Modals (to be created)
const ModalGerenciarCriterio = defineAsyncComponent(() => import('@/components/ModalGerenciarCriterio.vue'))
const ModalGerenciarAvaliacao = defineAsyncComponent(() => import('@/components/ModalGerenciarAvaliacao.vue'))

const appStore = useAppStore()
const toast = useToastStore()
const route = useRoute()
const router = useRouter()

// --- Icons ---
const IconCriterios = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z' }),
    h('polyline', { points: '14 2 14 8 20 8' }),
    h('line', { x1: '16', y1: '13', x2: '8', y2: '13' }),
    h('line', { x1: '16', y1: '17', x2: '8', y2: '17' }),
    h('polyline', { points: '10 9 9 9 8 9' })
  ])
})

const IconAvaliacoes = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M22 11.08V12a10 10 0 1 1-5.93-9.14' }),
    h('polyline', { points: '22 4 12 14.01 9 11.01' })
  ])
})

// --- Tabs Config ---
const TABS = [
  { id: 'criterios', label: 'Critérios', icon: IconCriterios },
  { id: 'modelos', label: 'Avaliações', icon: IconAvaliacoes }
]

const currentTabId = ref(route.query.tab || 'criterios')
const currentTab = computed(() => TABS.find(t => t.id === currentTabId.value) || TABS[0])

// --- Search & Pagination ---
const search = ref('')
const page = ref(1)
const limit = ref(10)

// --- Modal States ---
const isModalOpen = ref(false)
const selectedItem = ref(null)
const isConfirmOpen = ref(false)
const itemToDelete = ref(null)
const isDeleting = ref(false)

// --- BFF Data Fetching ---
// Note: 'criterios' maps to 'criterios' resource
// 'modelos' maps to 'modelos' resource
const { data: bffData, pending, error: bffError, refresh } = await useFetch(() => `/api/avaliacao/${currentTabId.value}`, {
  query: computed(() => ({
    id_empresa: appStore.company?.empresa_id,
    pagina: page.value,
    limite: limit.value,
    busca: search.value || null
  })),
  watch: [currentTabId, page, search, () => appStore.company?.empresa_id],
  immediate: true
})

// Bind BFF data
const items = computed(() => bffData.value?.items || [])
const total = computed(() => bffData.value?.total || 0)
const pages = computed(() => bffData.value?.pages || 0)
const isLoading = computed(() => pending.value)

// Watchers
watch(currentTabId, (newId) => {
  page.value = 1
  search.value = ''
  router.push({ query: { ...route.query, tab: newId } })
})

// --- Methods ---
const switchTab = (tabId) => {
  currentTabId.value = tabId
}

const handleNew = () => {
  selectedItem.value = null
  isModalOpen.value = true
}

const handleEdit = (item) => {
  selectedItem.value = item
  isModalOpen.value = true
}

const handleDelete = (item) => {
  itemToDelete.value = item
  isConfirmOpen.value = true
}

const confirmDelete = async () => {
  if (!itemToDelete.value) return
  isDeleting.value = true
  try {
    const data = await $fetch(`/api/avaliacao/${currentTabId.value}`, {
      method: 'DELETE',
      body: {
        id: itemToDelete.value.id,
        id_empresa: appStore.company.empresa_id
      }
    })
    
    if (data && data.success) {
      toast.showToast('Registro excluído com sucesso!', 'success')
      isConfirmOpen.value = false
      itemToDelete.value = null
      refresh()
    }
  } catch (err) {
    console.error('Erro ao excluir:', err)
    toast.showToast(err.data?.message || err.message || 'Erro ao excluir registro.', 'error')
  } finally {
    isDeleting.value = false
  }
}

const handleSuccess = () => {
  refresh()
}

// Stats for Dashboard
const dashboardStats = computed(() => [
  { label: 'Total Registros', value: total.value },
  { label: 'Página Atual', value: page.value }
])

</script>

<template>
  <NuxtLayout name="manager">
    <!-- Header Icon Slot -->
    <template #header-icon>
      <div class="w-10 h-10 rounded bg-primary/10 text-primary flex items-center justify-center shrink-0">
        <component :is="currentTab.icon" />
      </div>
    </template>

    <!-- Header Title Slot -->
    <template #header-title>
      <span class="capitalize">{{ currentTab.label }}</span>
    </template>

    <!-- Header Subtitle Slot -->
    <template #header-subtitle>
      {{ total }} registros encontrados
    </template>

    <!-- Header Actions Slot -->
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
        <span>+</span> <span class="hidden sm:inline">Novo Modelo</span>
      </button>
    </template>

    <!-- Tabs Slot -->
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

    <!-- Sidebar Slot -->
    <template #sidebar>
      <ManagerDashboard 
        :title="`Gestão: ${currentTab.label}`" 
        :stats="dashboardStats"
      >
        <template #extra>
          <div class="bg-primary/5 p-4 rounded border border-primary/10">
            <h4 class="text-[10px] font-black text-primary uppercase tracking-[0.2em] mb-2">Dica</h4>
            <p class="text-[11px] text-primary/70 leading-relaxed font-medium">
              Utilize o módulo de Critérios para definir as escalas de notas (Numéricas ou Conceituais) que serão usadas nas Avaliações.
            </p>
          </div>
        </template>
      </ManagerDashboard>
    </template>

    <!-- Content Slot -->
    <div v-if="isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 gap-4 opacity-50">
      <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin" />
      <p class="text-xs font-bold uppercase tracking-widest text-secondary">Carregando...</p>
    </div>

    <div v-else-if="items.length > 0" class="flex flex-col gap-2">
      <ManagerListItem
        v-for="item in items"
        :key="item.id"
        :title="item.nome_modelo_criterio || item.nome_modelo"
        :id="item.id"
        @edit="handleEdit(item)"
        @delete="handleDelete(item)"
      >
        <template #metadata>
          <div class="flex items-center gap-1.5 text-[10px] font-medium tracking-wide transition-colors">
             <template v-if="currentTabId === 'criterios'">
                <span class="opacity-70">Tipo: {{ item.tipo_modelo_criterio }}</span>
             </template>
             <template v-else>
                 <!-- Metadata for Avaliacoes -->
                 <span class="opacity-70">Avaliação</span>
             </template>
          </div>
        </template>
        <template #icon>
           <div class="text-primary  w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center font-bold text-xs">
              {{ (item.nome_modelo_criterio || item.nome_modelo || '?').charAt(0).toUpperCase() }}
           </div>
        </template>
      </ManagerListItem>

      <!-- Pagination -->
      <div class="flex items-center justify-center gap-4 mt-6 py-4">
        <button @click="page--" :disabled="page === 1" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30">Anterior</button>
        <span class="text-[11px] font-black bg-div-15 px-3 py-1 rounded-full border border-secondary/10">{{ page }} / {{ pages }}</span>
        <button @click="page++" :disabled="page >= pages" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30">Próxima</button>
      </div>
    </div>

    <div v-else class="flex flex-col items-center justify-center py-20 text-center text-secondary">
      <p>Nenhum registro encontrado.</p>
    </div>

    <!-- Modals -->
    <template #modals>
       <component 
          :is="currentTabId === 'criterios' ? ModalGerenciarCriterio : ModalGerenciarAvaliacao"
          v-if="isModalOpen"
          :is-open="isModalOpen"
          :initial-data="selectedItem"
          @close="isModalOpen = false"
          @success="handleSuccess"
       />

      <ModalConfirmacao
        :is-open="isConfirmOpen"
        title="Excluir Registro?"
        :message="`Deseja realmente excluir <b>${itemToDelete?.nome_modelo_criterio || itemToDelete?.nome_modelo}</b>?<br>Esta ação não pode ser desfeita.`"
        confirm-text="Sim, excluir"
        :is-loading="isDeleting"
        @close="isConfirmOpen = false"
        @confirm="confirmDelete"
      />
    </template>
  </NuxtLayout>
</template>
