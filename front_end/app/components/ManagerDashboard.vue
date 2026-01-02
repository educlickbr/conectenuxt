<script setup>
const props = defineProps({
  title: {
    type: String,
    default: 'Visão Geral'
  },
  stats: {
    type: Array,
    default: () => [] // Array of { label, value, colorClass }
  }
})
</script>

<template>
  <div class="flex flex-col gap-6 h-full">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <h2 class="font-black text-secondary text-xs uppercase tracking-[0.2em]">{{ title }}</h2>

    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <div v-for="stat in stats" :key="stat.label" class="bg-background/40 p-4 rounded border border-secondary/5 flex flex-col gap-1 hover:border-primary/20 transition-all font-sans">
        <span class="text-2xl font-black text-text">{{ stat.value }}</span>
        <span class="text-[10px] text-secondary font-bold uppercase tracking-wider">{{ stat.label }}</span>
      </div>
    </div>

    <!-- Main Chart/Vis Area Slot -->
    <div class="flex-1 min-h-[200px] bg-background/20 rounded border border-dashed border-secondary/10 flex items-center justify-center p-6">
      <slot name="visualization">
        <div class="text-center space-y-2 opacity-30">
          <svg class="mx-auto" xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"></path><path d="m19 9-5 5-4-4-3 3"></path></svg>
          <p class="text-[10px] font-bold uppercase tracking-widest">Aguardando dados...</p>
        </div>
      </slot>
    </div>

    <!-- Extra Info / Logs Slot -->
    <div class="mt-auto space-y-4">
      <slot name="extra" />
    </div>
  </div>
</template>
