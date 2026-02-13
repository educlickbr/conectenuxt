<script setup>
import { computed } from "vue";

const props = defineProps({
  stats: {
    type: Object,
    default: () => ({ total: 0, active: 0 }),
  },
  type: {
    type: String,
    default: "professor",
  },
});

// Contextual Labels
const labels = computed(() => {
  switch (props.type) {
    case "professor":
      return { total: "Professores", active: "Ativos" };
    case "aluno":
      return { total: "Alunos", active: "Matriculados" };
    case "familia":
      return { total: "Famílias", active: "Com Alunos" };
    case "admin":
      return { total: "Admins", active: "Ativos" };
    default:
      return { total: "Total", active: "Ativos" };
  }
});

// Dummy Chart Logic - Just visual variation per type
const chartColor = computed(() => {
  switch (props.type) {
    case "aluno":
      return "bg-green-500"; // Green bars
    case "familia":
      return "bg-orange-500"; // Orange bars
    case "admin":
      return "bg-purple-500"; // Purple bars
    default:
      return "bg-primary"; // Default Blue
  }
});
</script>

<template>
  <div
    class="hidden md:flex w-80 lg:w-96 flex-col bg-div-15 rounded-xl border border-secondary/20 p-5 shadow-sm shrink-0 gap-6 h-full overflow-y-auto"
  >
    <div class="flex items-center justify-between">
      <h2 class="font-bold text-text text-lg">Visão Geral</h2>
      <div
        class="p-1.5 bg-background rounded-lg text-secondary cursor-pointer hover:text-primary transition-colors"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="16"
          height="16"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <circle cx="12" cy="12" r="1"></circle>
          <circle cx="19" cy="12" r="1"></circle>
          <circle cx="5" cy="12" r="1"></circle>
        </svg>
      </div>
    </div>

    <!-- Cards -->
    <div class="grid grid-cols-2 gap-3">
      <div
        class="bg-background p-3 rounded-xl border border-secondary/10 flex flex-col"
      >
        <span
          class="text-[10px] text-secondary uppercase font-bold tracking-wider"
          >{{ labels.total }}</span
        >
        <span class="text-2xl font-bold text-primary mt-1">{{
          stats.total
        }}</span>
      </div>
      <div
        class="bg-background p-3 rounded-xl border border-secondary/10 flex flex-col"
      >
        <span
          class="text-[10px] text-secondary uppercase font-bold tracking-wider"
          >{{ labels.active }}</span
        >
        <!-- Fallback logic: if active not provided, assume 90% -->
        <span class="text-2xl font-bold text-green-500 mt-1">{{
          stats.active || Math.floor(stats.total * 0.9)
        }}</span>
      </div>
    </div>

    <!-- Dummy Chart Section -->
    <div class="flex-1 flex flex-col gap-3 min-h-[200px]">
      <h3 class="text-sm font-semibold text-text/80">Atividade Recente</h3>
      <div
        class="flex-1 bg-background/50 rounded-xl border border-secondary/10 p-4 flex items-end justify-between gap-2 relative overflow-hidden"
      >
        <!-- Dummy Bars with Dynamic Color -->
        <div
          :class="[
            'w-full h-[40%] rounded-t-sm opacity-20 hover:opacity-40 transition-opacity relative group',
            chartColor,
          ]"
        ></div>
        <div
          :class="[
            'w-full h-[65%] rounded-t-sm opacity-20 hover:opacity-40 transition-opacity relative group',
            chartColor,
          ]"
        ></div>
        <div
          :class="[
            'w-full h-[85%] rounded-t-sm hover:opacity-80 transition-opacity relative group shadow-lg',
            chartColor,
          ]"
        ></div>
        <div
          :class="[
            'w-full h-[50%] rounded-t-sm opacity-20 hover:opacity-40 transition-opacity relative group',
            chartColor,
          ]"
        ></div>
        <div
          :class="[
            'w-full h-[30%] rounded-t-sm opacity-20 hover:opacity-40 transition-opacity relative group',
            chartColor,
          ]"
        ></div>
      </div>
      <p class="text-[10px] text-center text-secondary">
        Amostragem dos últimos 30 dias
      </p>
    </div>

    <!-- Recent Activity Mini List -->
    <div class="mt-auto">
      <h3 class="text-sm font-semibold text-text/80 mb-3">Logs do Sistema</h3>
      <div class="space-y-3">
        <div class="flex items-center gap-3 text-xs">
          <div class="w-2 h-2 rounded-full bg-green-500"></div>
          <span class="text-secondary flex-1 truncate"
            >Novo registro adicionado</span
          >
          <span class="text-secondary/50">2h</span>
        </div>
        <div class="flex items-center gap-3 text-xs">
          <div class="w-2 h-2 rounded-full bg-blue-500"></div>
          <span class="text-secondary flex-1 truncate"
            >Atualização de dados</span
          >
          <span class="text-secondary/50">1d</span>
        </div>
      </div>
    </div>
  </div>
</template>
