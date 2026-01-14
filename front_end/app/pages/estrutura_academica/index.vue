<script setup>
definePageMeta({
  layout: false
})

// Import placeholder components for tabs
import TabClasses from '@/components/estrutura_academica/TabClasses.vue'
import TabComponentes from '@/components/estrutura_academica/TabComponentes.vue'
import TabAnoEtapa from '@/components/estrutura_academica/TabAnoEtapa.vue'
import TabHorarios from '@/components/estrutura_academica/TabHorarios.vue'
import TabTurmas from '@/components/estrutura_academica/TabTurmas.vue'
import TabPlanoDeAula from '@/components/matriz_curricular/TabPlanoDeAula.vue'

import ManagerDashboard from '@/components/ManagerDashboard.vue'
import { useToastStore } from '@/stores/toast'

const store = useAppStore()
const toast = useToastStore()
const route = useRoute()
const router = useRouter()

// --- Tabs Config ---
const TABS = [
  { id: 'classes', label: 'Classes', icon: '📋' },
  { id: 'componentes', label: 'Componentes', icon: '🧩' },
  { id: 'ano_etapa', label: 'Ano / Etapa', icon: '📅' },
  { id: 'horarios', label: 'Horários', icon: '🕒' },
  { id: 'turmas', label: 'Turmas', icon: '👥' },
  { id: 'planejamento', label: 'Planejamento', icon: '📚' }
]

const currentTabId = ref(route.query.tab || 'classes')
const currentTab = computed(() => TABS.find(t => t.id === currentTabId.value) || TABS[0])

// --- Search State (Placeholder) ---
const search = ref('')
const page = ref(1)
const limit = ref(10)

// --- BFF Data Fetching ---
const { data: bffData, pending, error: bffError, refresh } = await useFetch(() => 
  currentTabId.value === 'planejamento' ? undefined : `/api/estrutura_academica/${currentTabId.value}`, {
  query: computed(() => ({
    id_empresa: store.company?.empresa_id,
    pagina: page.value,
    limite: limit.value,
    busca: search.value || null
  })),
  watch: [currentTabId, page, search, () => store.company?.empresa_id],
  immediate: true
})

// Bind BFF data to local refs
const items = computed(() => bffData.value?.items || [])
const total = computed(() => bffData.value?.total || 0)
const pages = computed(() => bffData.value?.pages || 0)
const isLoading = computed(() => pending.value)

// Modals State
import ModalGerenciarClasse from '@/components/estrutura_academica/ModalGerenciarClasse.vue'
import ModalGerenciarComponente from '@/components/estrutura_academica/ModalGerenciarComponente.vue'
import ModalGerenciarAnoEtapa from '@/components/estrutura_academica/ModalGerenciarAnoEtapa.vue'
import ModalGerenciarHorario from '@/components/estrutura_academica/ModalGerenciarHorario.vue'
import ModalGerenciarTurma from '@/components/estrutura_academica/ModalGerenciarTurma.vue'
import ModalConfirmacao from '@/components/ModalConfirmacao.vue'

const isModalClassesOpen = ref(false)
const isModalComponentesOpen = ref(false)
const isModalAnoEtapaOpen = ref(false)
const isModalHorarioOpen = ref(false)
const isModalTurmaOpen = ref(false)
const selectedItem = ref(null)
const tabPlanoRef = ref(null)

// --- Watchers for Route Sync ---
watch(currentTabId, (newId) => {
  page.value = 1
  search.value = ''
  router.push({ query: { ...route.query, tab: newId } })
})

// --- Methods ---
const switchTab = (tabId) => {
  currentTabId.value = tabId
}

const handleSuccess = () => {
    refresh()
}

const handleNew = () => {
  selectedItem.value = null
  if (currentTabId.value === 'classes') {
    isModalClassesOpen.value = true
  } else if (currentTabId.value === 'componentes') {
    isModalComponentesOpen.value = true
  } else if (currentTabId.value === 'ano_etapa') {
    isModalAnoEtapaOpen.value = true
  } else if (currentTabId.value === 'horarios') {
    isModalHorarioOpen.value = true
  } else if (currentTabId.value === 'turmas') {
    isModalTurmaOpen.value = true
  } else if (currentTabId.value === 'planejamento') {
     tabPlanoRef.value?.openNewPlanModal()
  } else {
    toast.showToast('Funcionalidade "Novo" em desenvolvimento para esta aba.', 'info')
  }
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
        const { success, message } = await $fetch(`/api/estrutura_academica/${currentTabId.value}`, {
            method: 'DELETE',
            body: {
                id: itemToDelete.value.id || itemToDelete.value.uuid,
                id_empresa: store.company.empresa_id
            }
        })

        if (success) {
            toast.showToast(message || 'Registro excluído com sucesso!')
            isConfirmOpen.value = false
            itemToDelete.value = null
            // Refresh logic
            if (page.value === 1) {
                await execute() // Wait for refresh
            } else {
                page.value = 1
            }
        }
    } catch (err) {
        console.error('Erro ao excluir:', err)
        const msg = err.data?.message || err.message || 'Erro ao excluir o registro.'
        toast.showToast(msg, 'error')
    } finally {
        isDeleting.value = false
        // Ensure modal closes on error if desired, but usually we keep it open so user can retry or cancel.
        // Actually, for errors like "dependency exists", we might want to keep it open or close it?
        // Standard behavior: close specifically on success, keep open on error (so user sees context), OR close and show toast.
        // The previous implementation kept it open on error. Let's stick to that or let user cancel.
        // Wait, if error is "cannot delete", user must cancel manually. That's fine.
    }
}

const handleEdit = (item) => {
    selectedItem.value = item
    if (currentTabId.value === 'classes') {
        isModalClassesOpen.value = true
    } else if (currentTabId.value === 'componentes') {
        isModalComponentesOpen.value = true
    } else if (currentTabId.value === 'ano_etapa') {
        isModalAnoEtapaOpen.value = true
    } else if (currentTabId.value === 'horarios') {
        isModalHorarioOpen.value = true
    } else if (currentTabId.value === 'turmas') {
        isModalTurmaOpen.value = true
    } else {
        toast.showToast('Edição em desenvolvimento.', 'info')
    }
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
      <div class="w-10 h-10 rounded bg-orange-500/10 text-orange-500 flex items-center justify-center shrink-0 text-xl">
        {{ currentTab.icon }}
      </div>
    </template>

    <!-- Header Title Slot -->
    <template #header-title>
      <span class="capitalize">{{ currentTab.label }}</span>
    </template>

    <!-- Header Subtitle Slot -->
    <template #header-subtitle>
      Estrutura Acadêmica
    </template>

    <template #header-actions>
      <div v-if="currentTabId !== 'planejamento'" class="relative w-full sm:max-w-[180px]">
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
        :title="`Dashboard: ${currentTab.label}`" 
        :stats="dashboardStats"
      >
        <template #extra>
          <div class="bg-orange-500/5 p-4 rounded border border-orange-500/10">
            <h4 class="text-[10px] font-black text-orange-500 uppercase tracking-[0.2em] mb-2">Estrutura Acadêmica</h4>
            <p class="text-[11px] text-orange-500/70 leading-relaxed font-medium">
              Gerencie as informações fundamentais da instituição, como turmas, horários e ciclos.
            </p>
          </div>
        </template>
      </ManagerDashboard>
    </template>

    <!-- Main Content Area: Render Active Tab Component -->
    <div class="w-full">
      <TabClasses 
        v-if="currentTabId === 'classes'" 
        :items="items" 
        :is-loading="isLoading"
        @edit="handleEdit"
        @delete="handleDelete"
      />
      <TabComponentes 
        v-if="currentTabId === 'componentes'" 
        :items="items" 
        :is-loading="isLoading"
        @edit="handleEdit"
        @delete="handleDelete"
      />
      <TabAnoEtapa 
        v-if="currentTabId === 'ano_etapa'" 
        :items="items" 
        :is-loading="isLoading"
        @edit="handleEdit"
        @delete="handleDelete"
      />
      <TabHorarios 
        v-if="currentTabId === 'horarios'" 
        :items="items" 
        :is-loading="isLoading"
        @edit="handleEdit"
        @delete="handleDelete"
      />
      <TabTurmas 
        v-if="currentTabId === 'turmas'" 
        :items="items" 
        :is-loading="isLoading"
        @edit="handleEdit"
        @delete="handleDelete"
      />
      <TabPlanoDeAula 
        v-if="currentTabId === 'planejamento'"
        ref="tabPlanoRef"
      />
    </div>

    <!-- Pagination -->
    <div v-if="!isLoading && items.length > 0" class="flex items-center justify-center gap-4 mt-6 py-4">
        <button @click="page--" :disabled="page === 1" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30">Anterior</button>
        <span class="text-[11px] font-black bg-div-15 px-3 py-1 rounded-full border border-secondary/10">{{ page }} / {{ pages }}</span>
        <button @click="page++" :disabled="page >= pages" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30">Próxima</button>
    </div>

    <!-- Modals -->
    <template #modals>
       <ModalGerenciarClasse
          :is-open="isModalClassesOpen"
          :initial-data="selectedItem"
          @close="isModalClassesOpen = false"
          @success="handleSuccess"
       />

       <ModalGerenciarComponente
          :is-open="isModalComponentesOpen"
          :initial-data="selectedItem"
          @close="isModalComponentesOpen = false"
          @success="handleSuccess"
       />

       <ModalGerenciarAnoEtapa
          :is-open="isModalAnoEtapaOpen"
          :initial-data="selectedItem"
          @close="isModalAnoEtapaOpen = false"
          @success="handleSuccess"
       />

       <ModalGerenciarHorario
          :is-open="isModalHorarioOpen"
          :initial-data="selectedItem"
          @close="isModalHorarioOpen = false"
          @success="handleSuccess"
       />

       <ModalGerenciarTurma
          :is-open="isModalTurmaOpen"
          :initial-data="selectedItem"
          @close="isModalTurmaOpen = false"
          @success="handleSuccess"
       />

       <ModalConfirmacao
        :is-open="isConfirmOpen"
        title="Excluir Registro?"
        :message="`Deseja realmente excluir <b>${itemToDelete?.nome || itemToDelete?.nome_turma || 'este item'}</b>?<br>Esta ação não pode ser desfeita.`"
        confirm-text="Sim, excluir"
        :is-loading="isDeleting"
        @close="isConfirmOpen = false"
        @confirm="confirmDelete"
      />
    </template>

  </NuxtLayout>
</template>
