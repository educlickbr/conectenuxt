<script setup>
definePageMeta({
  layout: false
})

import TabAulas from '@/components/secretaria/diario/TabAulas.vue'
import TabDiarioAluno from '@/components/secretaria/diario/TabDiarioAluno.vue'
import TabDiarioSemanal from '@/components/secretaria/diario/TabDiarioSemanal.vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'

const route = useRoute()
const router = useRouter()

// --- Icons ---
const IconAulas = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z' }),
    h('path', { d: 'M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z' })
  ])
})

const IconAluno = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2' }),
    h('circle', { cx: '12', cy: '7', r: '4' })
  ])
})

const IconSemanal = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('rect', { x: '3', y: '4', width: '18', height: '18', rx: '2', ry: '2' }),
    h('line', { x1: '16', y1: '2', x2: '16', y2: '6' }),
    h('line', { x1: '8', y1: '2', x2: '8', y2: '6' }),
    h('line', { x1: '3', y1: '10', x2: '21', y2: '10' })
  ])
})

// --- Tabs Config ---
const TABS = [
  { id: 'aulas', label: 'Aulas', icon: IconAulas, component: TabAulas },
  { id: 'aluno', label: 'Diário por Aluno', icon: IconAluno, component: TabDiarioAluno },
  { id: 'semanal', label: 'Diário Semanal', icon: IconSemanal, component: TabDiarioSemanal }
]

const currentTabId = ref(route.query.tab || 'aulas')
const currentTab = computed(() => TABS.find(t => t.id === currentTabId.value) || TABS[0])

// Watchers
watch(currentTabId, (newId) => {
  router.push({ query: { ...route.query, tab: newId } })
})

const switchTab = (tabId) => {
  currentTabId.value = tabId
}

// Child ref to trigger methods (if needed in future)
const currentTabRef = ref(null)

const handleNewAction = () => {
    // Check if the current tab component has a 'handleNew' method exposed
    if (currentTabRef.value && currentTabRef.value.handleNew) {
        currentTabRef.value.handleNew()
    }
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
      Secretaria Acadêmica
    </template>

    <!-- Header Actions Slot -->
    <template #header-actions>
      <!-- Action for Calendario Tab (Example from reference) -->
      <!-- <button ... >Novo Calendário</button> -->
      
      <button 
        v-if="currentTabId === 'aulas'"
        @click="handleNewAction" 
        class="bg-primary hover:bg-primary/90 text-white px-4 py-1.5 rounded text-xs font-bold transition-all shadow-sm hover:shadow-md flex items-center gap-1 shrink-0"
      >
        <span>+</span> <span class="hidden sm:inline">Novo Registro</span>
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
            <h4 class="text-[10px] font-black text-primary uppercase tracking-[0.2em] mb-2">Classroom</h4>
            <p class="text-[11px] text-primary/70 leading-relaxed font-medium">
               Gerencie as aulas, frequências e ocorrências diárias da turma.
            </p>
          </div>
        </template>
      </ManagerDashboard>
    </template>

    <!-- Content Slot -->
    <div class="rounded min-h-[400px]">
        <component :is="currentTab.component" ref="currentTabRef" />
    </div>

  </NuxtLayout>
</template>
