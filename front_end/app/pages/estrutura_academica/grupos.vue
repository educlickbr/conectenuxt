<script setup>
definePageMeta({
  layout: false
})

import TabGrupos from '@/components/estrutura_academica/TabGrupos.vue'
import TabTutores from '@/components/estrutura_academica/TabTutores.vue'
import TabIntegrantes from '@/components/estrutura_academica/TabIntegrantes.vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'
import { useToastStore } from '@/stores/toast'
import ModalGerenciarGrupo from '@/components/estrutura_academica/ModalGerenciarGrupo.vue'
import ModalVincularUsuario from '@/components/estrutura_academica/ModalVincularUsuario.vue'
import ModalConfirmacao from '@/components/ModalConfirmacao.vue'

const store = useAppStore()
const toast = useToastStore()
const route = useRoute()
const router = useRouter()

// --- Tabs Config ---
const TABS = [
  { id: 'grupos', label: 'Grupos', icon: '👥' },
  { id: 'tutores', label: 'Tutores', icon: '👨‍🏫' },
  { id: 'integrantes', label: 'Integrantes', icon: '🎓' }
]

const currentTabId = ref(route.query.tab || 'grupos')
const currentTab = computed(() => TABS.find(t => t.id === currentTabId.value) || TABS[0])

// --- Search State ---
const search = ref('')
const page = ref(1)
const limit = ref(10)

// --- BFF Data Fetching ---
const { data: bffData, pending, error: bffError, refresh, execute } = await useFetch(() => `/api/estrutura_academica/${currentTabId.value}`, {
  query: computed(() => ({
    id_empresa: store.company?.empresa_id,
    pagina: page.value,
    limite: limit.value,
    busca: search.value || null
  })),
  watch: [currentTabId, page, search, () => store.company?.empresa_id],
  immediate: true
})

const items = computed(() => bffData.value?.items || [])
const total = computed(() => bffData.value?.total || 0)
const pages = computed(() => bffData.value?.pages || 0)
const isLoading = computed(() => pending.value)

// --- Modals ---
const isModalGrupoOpen = ref(false)
const isModalVincularOpen = ref(false)
const modalVincularType = ref('tutor')
const selectedItem = ref(null)

// --- Watchers ---
watch(currentTabId, (newId) => {
  page.value = 1
  search.value = ''
  selectedItem.value = null
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
    if (currentTabId.value === 'grupos') {
        isModalGrupoOpen.value = true
    } else if (currentTabId.value === 'tutores') {
        modalVincularType.value = 'tutor'
        isModalVincularOpen.value = true
    } else if (currentTabId.value === 'integrantes') {
        modalVincularType.value = 'integrante'
        isModalVincularOpen.value = true
    }
}

const handleEdit = (item) => {
    selectedItem.value = item
    if (currentTabId.value === 'grupos') {
        isModalGrupoOpen.value = true
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
        const body = {
             id_empresa: store.company.empresa_id
        }
        
        // For link tables, we need id_grupo and id_user
        if (currentTabId.value === 'tutores' || currentTabId.value === 'integrantes') {
             body.id_grupo = itemToDelete.value.id_grupo
             body.id_user = itemToDelete.value.id_user
        } else {
             // For groups, use ID
             body.id = itemToDelete.value.id
        }

        const { success, message } = await $fetch(`/api/estrutura_academica/${currentTabId.value}`, {
            method: 'DELETE',
            body
        })

        if (success) {
            toast.showToast(message || 'Excluído com sucesso!')
            isConfirmOpen.value = false
            itemToDelete.value = null
            if (page.value === 1) await execute()
            else page.value = 1
        }
    } catch (err) {
        console.error(err)
        const msg = err.data?.message || err.message || 'Erro ao excluir.'
        toast.showToast(msg, 'error')
    } finally {
        isDeleting.value = false
    }
}

// Stats
const dashboardStats = computed(() => [
  { label: 'Total Registros', value: total.value },
  { label: 'Página Atual', value: page.value }
])
</script>

<template>
  <NuxtLayout name="manager">
    <template #header-icon>
      <div class="w-10 h-10 rounded bg-indigo-500/10 text-indigo-500 flex items-center justify-center shrink-0 text-xl">
        {{ currentTab.icon }}
      </div>
    </template>
    <template #header-title>
      <span class="capitalize">{{ currentTab.label }} de Estudo</span>
    </template>
    <template #header-subtitle>
      Gestão de Grupos Multiturmas
    </template>
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
        :title="`Dashboard: ${currentTab.label}`" 
        :stats="dashboardStats"
      >
        <template #extra>
          <div class="bg-indigo-500/5 p-4 rounded border border-indigo-500/10">
            <h4 class="text-[10px] font-black text-indigo-500 uppercase tracking-[0.2em] mb-2">Grupos de Estudo</h4>
            <p class="text-[11px] text-indigo-500/70 leading-relaxed font-medium">
              Crie grupos que abrigam alunos de diferentes séries e turmas para atividades extracurriculares ou reforço.
            </p>
          </div>
        </template>
      </ManagerDashboard>
    </template>

    <div class="w-full">
      <TabGrupos 
        v-if="currentTabId === 'grupos'" 
        :items="items" 
        :is-loading="isLoading"
        @edit="handleEdit"
        @delete="handleDelete"
        @success="handleSuccess"
      />
      
      <TabTutores 
        v-if="currentTabId === 'tutores'" 
        :items="items" 
        :is-loading="isLoading"
        @delete="handleDelete"
      />

       <TabIntegrantes 
        v-if="currentTabId === 'integrantes'" 
        :items="items" 
        :is-loading="isLoading"
        @delete="handleDelete"
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
       <ModalGerenciarGrupo
          :is-open="isModalGrupoOpen"
          :initial-data="selectedItem"
          @close="isModalGrupoOpen = false"
          @success="handleSuccess"
       />

       <ModalVincularUsuario
          :is-open="isModalVincularOpen"
          :type="modalVincularType"
          @close="isModalVincularOpen = false"
          @success="handleSuccess"
       />

        <ModalConfirmacao
            :is-open="isConfirmOpen"
            title="Excluir Registro?"
            :message="`Deseja realmente remover <b>${itemToDelete?.nome_grupo || itemToDelete?.nome_completo || 'este item'}</b>?`"
            confirm-text="Sim, remover"
            :is-loading="isDeleting"
            @close="isConfirmOpen = false"
            @confirm="confirmDelete"
      />
    </template>

  </NuxtLayout>
</template>
