<script setup>
definePageMeta({
  layout: false
})

import TabEventos from '@/components/matriz_curricular/TabEventos.vue'
import TabFeriados from '@/components/matriz_curricular/TabFeriados.vue'
import TabMatriz from '@/components/matriz_curricular/TabMatriz.vue'
import TabCalendario from '@/components/matriz_curricular/TabCalendario.vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'

const route = useRoute()
const router = useRouter()

// --- Icons ---
const IconEventos = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('rect', { x: '3', y: '4', width: '18', height: '18', rx: '2', ry: '2' }),
    h('line', { x1: '16', y1: '2', x2: '16', y2: '6' }),
    h('line', { x1: '8', y1: '2', x2: '8', y2: '6' }),
    h('line', { x1: '3', y1: '10', x2: '21', y2: '10' })
  ])
})

const IconFeriados = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z' })
  ])
})

const IconMatriz = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('path', { d: 'M3 3h7v7H3z' }),
    h('path', { d: 'M14 3h7v7h-7z' }),
    h('path', { d: 'M14 14h7v7h-7z' }),
    h('path', { d: 'M3 14h7v7H3z' })
  ])
})

const IconCalendario = defineComponent({
  render: () => h('svg', { xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: '2', strokeLinecap: 'round', strokeLinejoin: 'round', class: 'w-6 h-6' }, [
    h('rect', { x: '3', y: '4', width: '18', height: '18', rx: '2', ry: '2' }),
    h('line', { x1: '16', y1: '2', x2: '16', y2: '6' }),
    h('line', { x1: '8', y1: '2', x2: '8', y2: '6' }),
    h('line', { x1: '3', y1: '10', x2: '21', y2: '10' }),
    h('path', { d: 'M8 14h.01' }),
    h('path', { d: 'M12 14h.01' }),
    h('path', { d: 'M16 14h.01' }),
    h('path', { d: 'M8 18h.01' }),
    h('path', { d: 'M12 18h.01' }),
    h('path', { d: 'M16 18h.01' })
  ])
})

// --- Tabs Config ---
const TABS = [
  { id: 'eventos', label: 'Eventos', icon: IconEventos, component: TabEventos },
  { id: 'feriados', label: 'Feriados', icon: IconFeriados, component: TabFeriados },
  { id: 'matriz', label: 'Matriz', icon: IconMatriz, component: TabMatriz },
  { id: 'calendario', label: 'Calendário Escolar', icon: IconCalendario, component: TabCalendario }
]

const currentTabId = ref(route.query.tab || 'eventos')
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
      Gestão Acadêmica
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
            <h4 class="text-[10px] font-black text-primary uppercase tracking-[0.2em] mb-2">Info</h4>
            <p class="text-[11px] text-primary/70 leading-relaxed font-medium">
              Configure aqui os eventos, feriados e a estrutura do calendário escolar.
            </p>
          </div>
        </template>
      </ManagerDashboard>
    </template>

    <!-- Content Slot -->
    <div class="rounded min-h-[400px]">
        <component :is="currentTab.component" />
    </div>

  </NuxtLayout>
</template>
