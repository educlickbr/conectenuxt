<script setup>
definePageMeta({
  layout: false
})

import TabLancamentoAvaliacao from '@/components/secretaria/avaliacao/TabLancamentoAvaliacao.vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'

const route = useRoute()
const router = useRouter()

// --- Icons ---
const IconAssessment = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z' }),
    h('polyline', { points: '14 2 14 8 20 8' }),
    h('line', { x1: '16', y1: '13', x2: '8', y2: '13' }),
    h('line', { x1: '16', y1: '17', x2: '8', y2: '17' }),
    h('polyline', { points: '10 9 9 9 8 9' })
  ])
})

const IconReports = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z' }),
    h('path', { d: 'M16 13h-8' }),
    h('path', { d: 'M16 17h-8' }),
    h('path', { d: 'M10 9h-1' })
  ])
})

// --- Tabs Config ---
const TABS = [
  { id: 'lancamento', label: 'Lançamento de Notas', icon: IconAssessment, component: TabLancamentoAvaliacao },
  { id: 'relatorios', label: 'Relatórios (Em Breve)', icon: IconReports, component: null } // Placeholder
]

const currentTabId = ref(route.query.tab || 'lancamento')
const currentTab = computed(() => TABS.find(t => t.id === currentTabId.value) || TABS[0])

// Watchers
watch(currentTabId, (newId) => {
  router.push({ query: { ...route.query, tab: newId } })
})

const switchTab = (tabId) => {
  currentTabId.value = tabId
}

// Stats (Placeholder)
const dashboardStats = computed(() => [])

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
      Avaliação Acadêmica
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
            <h4 class="text-[10px] font-black text-primary uppercase tracking-[0.2em] mb-2">Avaliação</h4>
            <p class="text-[11px] text-primary/70 leading-relaxed font-medium">
               Selecione a turma e o modelo de avaliação para lançar as notas ou conceitos dos alunos.
            </p>
          </div>
        </template>
      </ManagerDashboard>
    </template>

    <!-- Content Slot -->
    <div class="rounded min-h-[400px]">
        <component :is="currentTab.component" v-if="currentTab.component" />
        <div v-else class="p-12 text-center text-secondary">
            Funcionalidade em desenvolvimento.
        </div>
    </div>

  </NuxtLayout>
</template>
