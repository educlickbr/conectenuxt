<script setup>
definePageMeta({
  layout: false
})

import { ref, computed, watch } from 'vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'
import ManagerListItem from '@/components/ManagerListItem.vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ModalConfirmacao from '@/components/ModalConfirmacao.vue'
// We will create this modal next
import ModalGerenciarMatricula from '@/components/secretaria/ModalGerenciarMatricula.vue'

const store = useAppStore()
const toast = useToastStore()
const route = useRoute()
const router = useRouter()

// --- State ---
const search = ref('')
const page = ref(1)
const limit = ref(10)
const isModalOpen = ref(false)
const isConfirmOpen = ref(false)
const selectedItem = ref(null)
const itemToDelete = ref(null)
const isDeleting = ref(false)

// --- Data Fetching ---
const { data: bffData, pending, refresh } = await useFetch('/api/secretaria/matriculas', {
  query: computed(() => ({
    id_empresa: store.company?.empresa_id,
    pagina: page.value,
    limite: limit.value,
    busca: search.value || null
  })),
  watch: [page, search, () => store.company?.empresa_id],
  immediate: true
})

const items = computed(() => bffData.value?.items || [])
const total = computed(() => bffData.value?.total || 0)
const pages = computed(() => bffData.value?.pages || 0)
const isLoading = computed(() => pending.value)

// --- Methods ---
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
        const { success, message } = await $fetch('/api/secretaria/matriculas', {
            method: 'DELETE',
            body: {
                id: itemToDelete.value.id,
                id_empresa: store.company.empresa_id
            }
        })
        if (success) {
            toast.showToast(message || 'Matrícula removida!')
            refresh()
            isConfirmOpen.value = false
        }
    } catch (err) {
        toast.showToast('Erro ao remover matrícula.', 'error')
    } finally {
        isDeleting.value = false
    }
}

const dashboardStats = computed(() => [
  { label: 'Total Matrículas', value: total.value },
  { label: 'Página Atual', value: page.value }
])

const getStatusColor = (status) => {
    const colors = {
        ativa: '#10b981',
        transferida: '#f59e0b',
        cancelada: '#ef4444',
        evadida: '#6b7280',
        concluida: '#3b82f6'
    }
    return colors[status] || '#ccc'
}
</script>

<template>
  <NuxtLayout name="manager">
    <!-- Header Icon Slot -->
    <template #header-icon>
      <div class="w-10 h-10 rounded bg-amber-500/10 text-amber-500 flex items-center justify-center shrink-0 shadow-sm">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
      </div>
    </template>

    <!-- Header Title Slot -->
    <template #header-title>
      Gestão de Matrículas
    </template>

    <!-- Header Subtitle Slot -->
    <template #header-subtitle>
      Secretaria Acadêmica
    </template>

    <!-- Header Actions Slot -->
    <template #header-actions>
      <div class="relative w-full sm:max-w-[220px]">
        <input 
          type="text" 
          v-model="search" 
          placeholder="Buscar aluno..." 
          class="w-full pl-8 pr-3 py-1.5 text-xs bg-background border border-secondary/30 rounded text-text focus:outline-none focus:border-primary transition-all placeholder:text-secondary/70 shadow-sm"
        >
        <div class="absolute left-2.5 top-1/2 -translate-y-1/2 text-secondary/70">
          <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        </div>
      </div>

      <button @click="handleNew" class="bg-primary hover:bg-primary/90 text-white px-4 py-1.5 rounded text-xs font-bold transition-all shadow-sm hover:shadow-md flex items-center gap-1 shrink-0">
        <span>+</span> <span class="hidden sm:inline">Nova Matrícula</span>
      </button>
    </template>

    <!-- Tabs Slot -->
    <template #tabs>
      <button class="relative px-4 py-3 text-sm font-bold text-primary transition-all whitespace-nowrap outline-none">
        Alunos Matriculados
        <div class="absolute bottom-0 left-0 w-full h-[3px] bg-primary rounded-full" />
      </button>
    </template>

    <!-- Sidebar Slot -->
    <template #sidebar>
      <ManagerDashboard 
        title="Dashboard de Matrículas" 
        :stats="dashboardStats"
      >
        <template #extra>
          <div class="bg-amber-500/5 p-4 rounded border border-amber-500/10 mt-4">
            <h4 class="text-[10px] font-black text-amber-500 uppercase tracking-[0.2em] mb-2">Secretaria</h4>
            <p class="text-[11px] text-amber-500/70 leading-relaxed font-medium">
              Vincule alunos a anos e etapas letivas. A matrícula é o vínculo principal do aluno com a instituição no período.
            </p>
          </div>
        </template>
      </ManagerDashboard>
    </template>

    <!-- Default Content Slot (Main List) -->
    <div class="flex flex-col gap-2 min-h-0">
      <div v-if="isLoading && items.length === 0" class="flex flex-col items-center justify-center py-20 gap-4 opacity-50">
          <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin" />
          <p class="text-xs font-bold uppercase tracking-widest text-secondary">Carregando...</p>
      </div>

      <template v-else-if="items.length > 0">
        <ManagerListItem
          v-for="item in items"
          :key="item.id"
          :title="item.aluno_nome"
          :subtitle="`${item.ano_etapa_nome} • ${item.ano}`"
          @edit="handleEdit(item)"
          @delete="handleDelete(item)"
        >
          <template #icon>
            <div 
                class="w-10 h-10 rounded-full flex items-center justify-center shadow-inner"
                :style="{ backgroundColor: getStatusColor(item.status) + '20', color: getStatusColor(item.status) }"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
            </div>
          </template>
          
          <template #info>
             <div class="flex items-center gap-3">
                <span 
                    class="px-2 py-0.5 rounded text-[10px] font-black uppercase tracking-wider"
                    :style="{ backgroundColor: getStatusColor(item.status) + '15', color: getStatusColor(item.status), border: `1px solid ${getStatusColor(item.status)}30` }"
                >
                    {{ item.status }}
                </span>
                <span class="text-[10px] text-secondary/60">Desde: {{ new Date(item.criado_em).toLocaleDateString() }}</span>
             </div>
          </template>
        </ManagerListItem>

        <!-- Pagination -->
        <div class="flex items-center justify-center gap-4 mt-6 py-4">
            <button @click="page--" :disabled="page === 1" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30 transition-opacity">Anterior</button>
            <span class="text-[11px] font-black bg-div-15 px-3 py-1 rounded-full border border-secondary/10 shadow-sm">{{ page }} / {{ pages }}</span>
            <button @click="page++" :disabled="page >= pages" class="px-4 py-2 text-xs font-bold text-secondary disabled:opacity-30 transition-opacity">Próxima</button>
        </div>
      </template>

      <!-- Empty State -->
      <div v-else-if="!isLoading" class="flex-1 flex flex-col items-center justify-center p-12 text-center">
        <div class="w-20 h-20 bg-div-15 rounded-full flex items-center justify-center text-secondary/20 mb-4">
          <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
        </div>
        <h3 class="text-xl font-bold text-secondary/40">Nenhuma matrícula encontrada</h3>
        <p class="text-xs text-secondary/30 mt-2 max-w-xs">Matricule um aluno para gerenciar seu percurso acadêmico.</p>
        <button @click="handleNew" class="mt-6 px-6 py-2 bg-primary/10 hover:bg-primary/20 text-primary text-xs font-bold rounded transition-all">
          + Iniciar Matrícula
        </button>
      </div>
    </div>

    <!-- Modals Slot -->
    <template #modals>
      <ModalGerenciarMatricula 
          v-if="isModalOpen"
          :isOpen="isModalOpen"
          :initialData="selectedItem"
          @close="isModalOpen = false"
          @success="refresh"
      />

      <ModalConfirmacao
        :isOpen="isConfirmOpen"
        title="Remover Matrícula?"
        message="Esta ação é irreversível e removerá todo o histórico de alocação deste aluno no período."
        :isLoading="isDeleting"
        @close="isConfirmOpen = false"
        @confirm="confirmDelete"
      />
    </template>
  </NuxtLayout>
</template>
