<script setup>
const props = defineProps({
  item: {
    type: Object,
    default: () => ({})
  },
  type: {
    type: String,
    default: ''
  },
  title: String,
  subtitle: String,
  icon: String,
  id: [String, Number]
})

defineEmits(['edit', 'delete', 'invite'])

// Optimized Icon Selection
const displayIcon = computed(() => {
  if (props.icon) return props.icon
  switch (props.type) {
    case 'professor': return '👨‍🏫'
    case 'aluno': return '👨‍🎓'
    case 'escola': return '🏫'
    case 'predio': return '🏢'
    case 'sala': return '🚪'
    case 'estante': return '📚'
    case 'turma': return '🎓'
    default: return '👤'
  }
})

const displayName = computed(() => {
  return props.title || props.item?.nome || props.item?.nome_completo || props.item?.titulo || 'Sem Nome'
})

const displaySubtitle = computed(() => {
  return props.subtitle || props.item?.email || props.item?.email_pessoal || ''
})

const statusColorClass = computed(() => {
  if (props.item?.status === 'Ativo') return 'text-green-500 bg-green-500/10'
  if (props.item?.status === 'Inativo') return 'text-red-500 bg-red-500/10'
  return 'text-secondary bg-secondary/10'
})
</script>

<template>
  <div class="group relative bg-div-15 py-2.5 px-6 rounded hover:border-l-primary transition-all flex items-center gap-4 shadow-sm hover:shadow-md border-l-4 border-l-transparent">
    <!-- Icon/Avatar -->
    <div class="w-8 h-8 rounded bg-background border border-secondary/10 flex items-center justify-center text-sm shrink-0 group-hover:scale-105 transition-transform">
      <slot name="icon">
        <span>{{ displayIcon }}</span>
      </slot>
    </div>

    <!-- Info -->
    <div class="flex-1 min-w-0">
      <div class="flex items-center gap-2">
        <h3 class="font-bold text-text text-sm truncate group-hover:text-primary transition-colors">
          {{ displayName }}
        </h3>
        <span v-if="item?.status" :class="statusColorClass" class="text-[9px] font-black uppercase tracking-widest px-1.5 py-0.5 rounded">
          {{ item.status }}
        </span>
      </div>
      
      <!-- Metadata Slot -->
      <div class="flex items-center gap-3 text-[11px] text-secondary mt-1 truncate">
        <slot name="metadata" :item="item">
          <!-- Fallback metadata display -->
          <span>{{ displaySubtitle }}</span>
          <span v-if="item?.codigo">{{ item.codigo }}</span>
        </slot>
      </div>
    </div>

    <!-- Actions Area -->
    <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
      <slot name="actions" :item="item">
        <button @click="$emit('edit', item)" class="p-2 hover:bg-primary/10 text-secondary hover:text-primary rounded transition-colors" title="Editar">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
        </button>
        <button @click="$emit('delete', item)" class="p-2 hover:bg-red-500/10 text-secondary hover:text-red-500 rounded transition-colors" title="Excluir">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
        </button>
      </slot>
    </div>
  </div>
</template>
