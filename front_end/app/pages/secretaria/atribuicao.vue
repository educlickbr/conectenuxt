<script setup>
definePageMeta({
  layout: false
})

import TabPolivalente from '@/components/secretaria/TabPolivalente.vue'
import TabComponentes from '@/components/secretaria/TabComponentes.vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'
import MatrizFilterBar from '@/components/matriz_curricular/MatrizFilterBar.vue'
import { useToastStore } from '@/stores/toast'
import ModalAtribuir from '@/components/secretaria/ModalAtribuir.vue'
import ModalConfirmacao from '@/components/ModalConfirmacao.vue'

const store = useAppStore()
const toast = useToastStore()
const route = useRoute()
const router = useRouter()

// --- Tabs Config ---
const TABS = [
  { id: 'polivalente', label: 'Turmas', icon: '👨‍🏫' },
  { id: 'componentes', label: 'Componentes', icon: '📚' }
]

const currentTabId = ref(route.query.tab || 'polivalente')
const currentTab = computed(() => TABS.find(t => t.id === currentTabId.value) || TABS[0])

// --- Filters State ---
const filters = ref({
    escola_id: null,
    ano_etapa_id: null,
    turma_id: null,
    componente_id: null
})

// Year Selector
const currentYear = new Date().getFullYear()
const selectedYear = ref(currentYear)

const changeYear = (delta) => {
    selectedYear.value += delta
}

// --- Search State ---
const search = ref('')
const page = ref(1)
const limit = ref(10)

// --- Resource mapping ---
const resourceMap = {
  polivalente: 'atribuicao_turmas',
  componentes: 'atribuicao_componentes'
}

const currentResource = computed(() => resourceMap[currentTabId.value])

// Legacy useFetch removed to fix 404 error

// Local state for Polivalente manual fetch
const manualItems = ref([])
const manualTotal = ref(0)
const manualLoading = ref(false)

const fetchPolivalente = async () => {
    // Only manual fetch for 'polivalente'
    if (currentTabId.value !== 'polivalente') return

    manualLoading.value = true
    const client = useSupabaseClient()
    try {
        const { data, error } = await client.rpc('atrib_turmas_get_paginado', {
            p_id_empresa: store.company?.empresa_id || null, 
            p_pagina: page.value, 
            p_limite_itens_pagina: limit.value,
            p_busca: search.value || null,
            p_id_turma: filters.value.turma_id || null, // Dynamic
            p_id_professor: null,
            p_ano: selectedYear.value, // Dynamic Year
            p_id_escola: filters.value.escola_id || null, // Dynamic 
            p_id_ano_etapa: filters.value.ano_etapa_id || null, // Dynamic
            p_id_classe: null // Not in MatrizFilterBar, usually inferred from turma or separate
        })
        
        if (error) {
            console.error('RPC Error:', error)
            toast.showToast('Erro ao carregar turmas', 'error')
        } else {
             // Handle data format (API usually normalizes, but direct RPC returns raw)
             let rawItems = []
             let totalCount = 0
             
             if (Array.isArray(data)) {
                 if (data.length > 0 && data[0].itens) {
                     rawItems = data[0].itens || []
                     totalCount = data[0].qtd_itens || 0
                 } else if (data.length > 0 && typeof data[0].total_registros !== 'undefined') {
                     rawItems = data
                     totalCount = data[0].total_registros || 0
                 } else { // Direct array from user sample
                     rawItems = data
                     totalCount = data.length 
                 }
             } else if (data && data.items) {
                 rawItems = data.items
                 totalCount = data.total
             }
             
             manualItems.value = rawItems.map(i => {
                 // Get active attribution from history if available or top-level props
                 // RPC debug showed: historico: [{ ... }]
                 // The active one is marked with is_ativo: true. We must find it, as order isn't guaranteed.
                 
                 const activeAttr = i.historico ? i.historico.find(h => h.is_ativo) : null
                 
                 return {
                    ...i,
                    professor_nome: i.professor_atual_nome,
                    atribuicao_id: i.atribuicao_atual_id,
                    data_inicio: i.professor_atual_desde,
                    // Fix for Substitution error: Ensure we have id_professor and ano
                    id_professor: activeAttr ? activeAttr.id_professor : null,
                    ano: (activeAttr && activeAttr.ano) ? activeAttr.ano : (i.turma_ano || selectedYear.value), // Fix: Check property existence
                    nivel_substituicao: activeAttr ? activeAttr.nivel_substituicao : 0
                 }
             })
             manualTotal.value = totalCount || 0
        }
    } catch (e) {
        console.error('RPC Exception:', e)
    } finally {
        manualLoading.value = false
    }
}

const items = computed(() => {
    if (currentTabId.value === 'polivalente' || currentTabId.value === 'componentes') return manualItems.value
    return [] 
})

const total = computed(() => {
    if (currentTabId.value === 'polivalente' || currentTabId.value === 'componentes') return manualTotal.value
    return 0
})

const pages = computed(() => {
    if (currentTabId.value === 'polivalente' || currentTabId.value === 'componentes') return Math.ceil(manualTotal.value / limit.value)
    return 0
})

// --- Componentes Tab Logic ---
const componentList = ref([])

const fetchComponentesList = async () => {
    if (!filters.value.turma_id) {
        componentList.value = []
        return
    }
    const client = useSupabaseClient()
    try {
        const { data, error } = await client.rpc('mtz_matriz_curricular_get_by_turma', {
            p_id_empresa: store.company?.empresa_id,
            p_id_turma: filters.value.turma_id
        })
        if (!error && data) {
            // Matriz RPC returns items with { id_componente, nome, ... }
            componentList.value = data
        }
    } catch (e) {
        console.error('Error fetching component list:', e)
    }
}

// Manual Fetch for Componentes Tab (similar to Polivalente)
const fetchComponentesData = async () => {
    if (currentTabId.value !== 'componentes') return

    manualLoading.value = true
    const client = useSupabaseClient()
    try {
        const { data, error } = await client.rpc('atrib_componentes_get_paginado', {
            p_id_empresa: store.company?.empresa_id || null, 
            p_pagina: page.value, 
            p_limite_itens_pagina: limit.value,
            p_busca: search.value || null,
            p_id_turma: filters.value.turma_id || null,
            p_id_professor: null,
            p_ano: selectedYear.value,
            p_id_componente: filters.value.componente_id || null // Filter by component
        })
        
        if (error) {
            console.error('RPC Error:', error)
            toast.showToast('Erro ao carregar componentes', 'error')
        } else {
             let rawItems = []
             let totalCount = 0
             
             if (data && data.items) {
                 rawItems = data.items
                 totalCount = data.total
             } else if (Array.isArray(data)) {
                  // Fallback for direct array returns
                  rawItems = data
                  totalCount = data.length
             }
             
             manualItems.value = rawItems.map(i => {
                 const activeAttr = i.historico ? i.historico.find(h => h.is_ativo) : null
                 return {
                    ...i,
                    professor_nome: i.professor_atual_nome, // Assuming RPC returns this alias or mapped in View
                    atribuicao_id: i.atribuicao_atual_id || i.id, // Using row ID as attribution ID? Check RPC.
                    // RPC 'atrib_componentes_get_paginado' returns 'id' as the attribution ID row.
                    // AND 'professor_nome'.
                    // It seems the RPC structure is slightly different or needs mapping.
                    // Checking existing RPC migration:
                    // SELECT a.id, ..., u.nome_completo as professor_nome.
                    // So i.id IS the attribution ID.
                    
                    data_inicio: i.professor_atual_desde, 
                    id_professor: activeAttr ? activeAttr.id_professor : null,
                    ano: i.turma_ano, 
                    nivel_substituicao: activeAttr ? activeAttr.nivel_substituicao : 0,
                    
                    // Logic for badges (Active/History split is not strictly enforced in get_paginado rows, 
                    // get_paginado returns ALL rows. 
                    // BUT for UI we want to see "Class + Component" card.
                    // If multiple attributions exist for same component/turma, they appear as multiple rows?
                    // Yes, get_paginado listing tables.
                    // Ideally we should group by component... but for now listing rows is fine.
                 }
             })
             manualTotal.value = totalCount || 0
        }
    } catch (e) {
        console.error('RPC Exception:', e)
    } finally {
        manualLoading.value = false
    }
}

const isLoading = computed(() => {
    return manualLoading.value
})

// --- Modals ---
const isModalAtribuirOpen = ref(false)
const selectedItem = ref(null)

// --- Watchers ---
watch(currentTabId, (newId) => {
  page.value = 1
  search.value = ''
  selectedItem.value = null
  router.push({ query: { ...route.query, tab: newId } })
  
  if (newId === 'polivalente') {
      fetchPolivalente()
  } else if (newId === 'componentes') {
      fetchComponentesData()
  }
}, { immediate: true })

// Also watch page/search for manual fetch
watch([page, search, selectedYear, () => filters.value.turma_id, () => filters.value.escola_id, () => filters.value.ano_etapa_id, () => filters.value.componente_id], () => {
    if (currentTabId.value === 'polivalente') {
        fetchPolivalente()
    } else if (currentTabId.value === 'componentes') {
        fetchComponentesData()
        if (filters.value.turma_id) fetchComponentesList()
    }
})

// Watch specifically for Turma change to reload Component List
watch(() => filters.value.turma_id, (newVal) => {
    if (newVal && currentTabId.value === 'componentes') {
        fetchComponentesList()
    } else {
        componentList.value = []
    }
}, { immediate: true })

// --- Methods ---
const switchTab = (tabId) => {
  currentTabId.value = tabId
}

const handleSuccess = () => {
    if (currentTabId.value === 'polivalente') {
        fetchPolivalente()
    } else if (currentTabId.value === 'componentes') {
        fetchComponentesData()
    }
}

const handleAtribuir = (item) => {
    selectedItem.value = item
    isModalAtribuirOpen.value = true
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
             id_empresa: store.company.empresa_id,
             id: itemToDelete.value.atribuicao_id
        }

        const { success, message } = await $fetch(`/api/secretaria/${currentResource.value}`, {
            method: 'DELETE',
            body
        })

        if (success) {
            toast.showToast(message || 'Atribuição removida com sucesso!')
            isConfirmOpen.value = false
            itemToDelete.value = null
            handleSuccess() // Use unified handler
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
      <span class="capitalize">Atribuição de Aulas - {{ currentTab.label }}</span>
    </template>
    <template #header-subtitle>
      Gestão de Professores e Turmas
    </template>
    <template #header-actions>
      <!-- Year Selector -->
      <div class="flex items-center bg-background border border-secondary/30 rounded-lg overflow-hidden h-9 shadow-sm">
         <button @click="changeYear(-1)" class="px-3 h-full hover:bg-div-15 text-secondary transition-colors border-r border-secondary/10">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
         </button>
         <span class="px-3 text-xs font-bold text-text tabular-nums">{{ selectedYear }}</span>
         <button @click="changeYear(1)" class="px-3 h-full hover:bg-div-15 text-secondary transition-colors border-l border-secondary/10">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
         </button>
      </div>

      <!-- Component Filter (Only for Componentes Tab and when Turma is selected) -->
      <div v-if="currentTabId === 'componentes' && filters.turma_id" class="w-full sm:max-w-[200px]">
          <select 
            v-model="filters.componente_id" 
            class="w-full px-3 py-1.5 text-xs bg-background border border-secondary/30 rounded text-text focus:outline-none focus:border-primary transition-all shadow-sm appearance-none"
          >
              <option :value="null">Todos os Componentes</option>
              <option v-for="comp in componentList" :key="comp.id_componente || comp.id" :value="comp.id_componente || comp.id">
                  {{ comp.nome }}
              </option>
          </select>
      </div>

      <!-- Search Input -->
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
            <h4 class="text-[10px] font-black text-indigo-500 uppercase tracking-[0.2em] mb-2">Atribuição de Aulas</h4>
            <p class="text-[11px] text-indigo-500/70 leading-relaxed font-medium">
              Gerencie a atribuição de professores às turmas e componentes curriculares.
            </p>
          </div>
        </template>
      </ManagerDashboard>
    </template>

    <div class="w-full space-y-4">
      <!-- Filter Bar (Polivalente Only for now, but could be global) -->
      <MatrizFilterBar 
          v-if="currentTabId === 'polivalente'"
          v-model="filters"
          :show-turma="true"
      />

      <TabPolivalente 
        v-if="currentTabId === 'polivalente'" 
        :items="items" 
        :is-loading="isLoading"
        @atribuir="handleAtribuir"
        @delete="handleDelete"
      />
      
      <TabComponentes 
        v-if="currentTabId === 'componentes'" 
        :items="items" 
        :is-loading="isLoading"
        @atribuir="handleAtribuir"
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
       <ModalAtribuir
          :is-open="isModalAtribuirOpen"
          :type="currentTabId"
          :initial-data="selectedItem"
          @close="isModalAtribuirOpen = false"
          @success="handleSuccess"
       />

        <ModalConfirmacao
            :is-open="isConfirmOpen"
            title="Remover Atribuição?"
            :message="`Deseja realmente remover a atribuição de <b>${itemToDelete?.professor_nome || 'este professor'}</b>?`"
            confirm-text="Sim, remover"
            :is-loading="isDeleting"
            @close="isConfirmOpen = false"
            @confirm="confirmDelete"
      />
    </template>

  </NuxtLayout>
</template>
