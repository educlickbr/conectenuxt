<script setup>
definePageMeta({
  layout: false
})

import ManagerListItem from '@/components/ManagerListItem.vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'
import ModalConfirmacao from '@/components/ModalConfirmacao.vue'
import { useToastStore } from '@/stores/toast'

// Role Constants
const ROLES = {
    PROFESSOR: ["3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1", "07028505-01d7-4986-800e-9d71cab5dd6c"],
    ALUNO: ["b7f53d6e-70b5-453b-b564-728aeb4635d5"]
}

// Note: Modals will be imported dynamically or we assume they exist/are created
// Since I haven't checked if they exist, I will use AsyncComponent or assume they need to be imported.
// For now, I will import them, but I might need to create them in next steps if they don't exist.
// Based on file list earlier, they DO NOT exist in `front_end/app/components` yet (only infra ones).
// I will create placeholders or stub imports that I will fill shortly.

const ModalGerenciarProfessor = defineAsyncComponent(() => import('@/components/ModalGerenciarProfessor.vue'))
const ModalGerenciarAluno = defineAsyncComponent(() => import('@/components/ModalGerenciarAluno.vue'))
const ModalGerenciarFamilia = defineAsyncComponent(() => import('@/components/ModalGerenciarFamilia.vue'))
const ModalGerenciarAdmin = defineAsyncComponent(() => import('@/components/ModalGerenciarAdmin.vue'))

const supabase = useSupabaseClient()
const store = useAppStore()
const toast = useToastStore()
const route = useRoute()
const router = useRouter()

// --- Icons ---
const IconProfessores = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z' }),
    h('path', { d: 'M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z' })
  ])
})

const IconAlunos = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M22 10v6M2 10l10-5 10 5-10 5-10-5z' }),
    h('path', { d: 'M6 12v5c3 3 9 3 12 0v-5' })
  ])
})

const IconFamilias = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2' }),
    h('circle', { cx: '9', cy: '7', r: '4' }),
    h('path', { d: 'M22 21v-2a4 4 0 0 0-3-3.87' }),
    h('path', { d: 'M16 3.13a4 4 0 0 1 0 7.75' })
  ])
})

const IconAdmins = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z' })
  ])
})

// --- Tabs Config ---
const TABS = [
  { id: 'professores', label: 'Professores', icon: IconProfessores },
  { id: 'alunos', label: 'Alunos', icon: IconAlunos },
  { id: 'familias', label: 'Famílias', icon: IconFamilias },
  { id: 'admins', label: 'Admins', icon: IconAdmins }
]

const currentTabId = ref(route.query.tab || 'professores')
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
// Prefetched Data
const modalQuestions = ref([])
const modalComponents = ref([])

// --- BFF Data Fetching ---
const { data: bffData, pending, error: bffError, refresh } = await useFetch(() => `/api/usuarios/${currentTabId.value}`, {
  query: computed(() => ({
    id_empresa: store.company?.empresa_id,
    pagina: page.value,
    limite: limit.value,
    busca: search.value || null
  })),
  watch: [currentTabId, page, search, () => store.company?.empresa_id],
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

const handleNew = async () => {
  // Reset preloaded data
  modalQuestions.value = []
  modalComponents.value = []
  
  const companyId = store.company?.empresa_id || store.company?.id
  console.log('[UsersPage] handleNew clicked. Tab:', currentTabId.value, 'Company:', companyId)

  if (!companyId) {
      toast.showToast('Erro: ID da empresa não encontrado.', 'error')
      return
  }

  // CRITICAL: Open modal FIRST with empty data
  selectedItem.value = null
  isModalOpen.value = true

  try {
      if (currentTabId.value === 'professores') {
          console.log('[UsersPage] Fetching Professor data...')
          const [perguntas, componentes] = await Promise.all([
              $fetch('/api/usuarios/auxiliar', {
                  query: { type: 'perguntas', id_empresa: companyId, papeis: ROLES.PROFESSOR.join(',') }
              }),
              $fetch('/api/usuarios/auxiliar', {
                  query: { type: 'componentes', id_empresa: companyId }
              })
          ])
          console.log('[UsersPage] Professor Data Loaded:', { perguntas, componentes })
          // Assign AFTER modal is open - this will trigger the watcher
          modalQuestions.value = perguntas || []
          modalComponents.value = componentes || []

      } else if (currentTabId.value === 'alunos') {
          console.log('[UsersPage] Fetching Aluno data...')
          const perguntas = await $fetch('/api/usuarios/auxiliar', {
              query: { type: 'perguntas', id_empresa: companyId, papeis: ROLES.ALUNO.join(',') }
          })
          console.log('[UsersPage] Aluno Data Loaded:', { perguntas })
          // Assign AFTER modal is open - this will trigger the watcher
          modalQuestions.value = perguntas || []
      }

  } catch (err) {
      console.error('[UsersPage] Error prefetching data:', err)
      toast.showToast('Erro ao carregar dados do formulário', 'error')
  }
}

const handleEdit = (item) => {
  // Legacy pattern: just open modal with item, modal does the rest
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
    // Determine ID needed based on resource type
    // Prof/Aluno uses user_expandido_id usually for operations, but let's check legacy logic.
    // Legacy: 
    // Prof/Aluno: p_id = item.user_expandido_id
    // Familia/Admin: p_id = item.id
    
    let idPayload = itemToDelete.value.id
    if (['professores', 'alunos'].includes(currentTabId.value)) {
         idPayload = itemToDelete.value.user_expandido_id
    }

    const data = await $fetch(`/api/usuarios/${currentTabId.value}`, {
      method: 'DELETE',
      body: {
        id: idPayload,
        id_empresa: store.company.empresa_id
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
      {{ total }} usuários cadastrados
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
        <span>+</span> <span class="hidden sm:inline">Convidar/Novo</span>
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
              Utilize as abas acima para navegar entre os diferentes tipos de usuários do sistema de forma rápida.
            </p>
          </div>
        </template>
      </ManagerDashboard>
    </template>

    <!-- Default Content Slot -->
    <div v-if="isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 gap-4 opacity-50">
      <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin" />
      <p class="text-xs font-bold uppercase tracking-widest text-secondary">Carregando...</p>
    </div>

    <div v-else-if="items.length > 0" class="flex flex-col gap-2">
      <ManagerListItem
        v-for="item in items"
        :key="item.id || item.user_expandido_id"
        :title="item.nome_completo || item.nome || item.nome_familia || item.email"
        :id="item.id || item.user_expandido_id"
        @edit="handleEdit(item)"
        @delete="handleDelete(item)"
      >
        <template #metadata>
          <div class="flex items-center gap-1.5 text-[10px] font-medium tracking-wide group-hover:text-secondary/80 transition-colors">
             <!-- Family Metadata -->
             <template v-if="currentTabId === 'familias'">
                <span class="opacity-70">Responsável: {{ item.responsavel_principal || 'N/A' }}</span>
                <span class="opacity-40">•</span>
                <span class="opacity-70">{{ item.qtd_alunos }} Aluno(s)</span>
             </template>
             
             <!-- User Metadata -->
             <template v-else>
                <span class="opacity-70">{{ item.email }}</span>
                <span v-if="item.telefone" class="opacity-40">•</span>
                <span v-if="item.telefone">{{ item.telefone }}</span>
             </template>
          </div>
        </template>
        <template #icon>
           <div class="text-primary  w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center font-bold text-xs">
              {{ (item.nome_completo || item.nome || item.nome_familia || item.email || '?').charAt(0).toUpperCase() }}
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

    <template #modals>
       <component 
          :is="currentTabId === 'professores' ? ModalGerenciarProfessor : 
               currentTabId === 'alunos' ? ModalGerenciarAluno : 
               currentTabId === 'familias' ? ModalGerenciarFamilia : 
               ModalGerenciarAdmin"
          v-if="isModalOpen"
          :is-open="isModalOpen"
          :initial-data="selectedItem"
          :preloaded-questions="modalQuestions"
          :preloaded-components="modalComponents"
          @close="isModalOpen = false"
          @success="handleSuccess"
       />

      <ModalConfirmacao
        :is-open="isConfirmOpen"
        title="Excluir Usuário?"
        :message="`Deseja realmente excluir <b>${itemToDelete?.nome || itemToDelete?.email}</b>?<br>Esta ação não pode ser desfeita.`"
        confirm-text="Sim, excluir"
        :is-loading="isDeleting"
        @close="isConfirmOpen = false"
        @confirm="confirmDelete"
      />
    </template>
  </NuxtLayout>
</template>
