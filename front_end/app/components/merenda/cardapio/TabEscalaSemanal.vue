<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import ManagerListItem from '@/components/ManagerListItem.vue'

// Props from parent (mostly unused now, as we handle logic internally for this specific flow)
const props = defineProps({
  items: Array, 
  isLoading: Boolean
})

const emit = defineEmits(['edit'])
const appStore = useAppStore()

// --- Data ---
const selectedCicloId = ref('')
const semanas = ref([])
const loadingSemanas = ref(false)

// Fetch Ciclos for Dropdown
const { data: ciclosData } = await useFetch('/api/merenda/cardapios', {
    query: computed(() => ({
        id_empresa: appStore.company?.empresa_id,
        limit: 100 // Fetch recent cycles
    })),
    watch: [() => appStore.company?.empresa_id]
})

const ciclos = computed(() => {
    const data = ciclosData.value?.data || ciclosData.value || []
    return Array.isArray(data) ? data : []
})

// Auto-select first cycle
watch(ciclos, (newCiclos) => {
    if (newCiclos.length > 0 && !selectedCicloId.value) {
        selectedCicloId.value = newCiclos[0].id
    }
}, { immediate: true })

// Helper to get ISO week
function getWeekNumber(d: Date) {
    d = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
    d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay()||7));
    var yearStart = new Date(Date.UTC(d.getUTCFullYear(),0,1));
    var weekNo = Math.ceil(( ( (d - yearStart) / 86400000) + 1)/7);
    return weekNo;
}

function getMondays(startDate: Date, endDate: Date) {
    var d = new Date(startDate);
    var mondays = [];
    
    // Adjust to Monday
    var day = d.getDay();
    var diff = d.getDate() - day + (day == 0 ? -6:1); // adjust when day is sunday
    d.setDate(diff);

    // If start date is mid-week, the first monday might be before start date, but that's the "week" start.
    // Loop until end date
    while (d <= endDate) {
        mondays.push(new Date(d));
        d.setDate(d.getDate() + 7);
    }
    return mondays;
}

// Generate Weeks based on Cycle
const generateWeeks = async () => {
    if (!selectedCicloId.value) return
    
    const ciclo = ciclos.value.find(c => c.id === selectedCicloId.value)
    if (!ciclo) return

    loadingSemanas.value = true
    semanas.value = []

    try {
        const start = new Date(ciclo.data_inicio)
        const end = new Date(ciclo.data_fim)
        
        // Generate list of mondays/weeks
        // This is a simplified logic, reliable enough for UI listing
        let current = new Date(start)
        // Reset to monday
        const day = current.getDay()
        const diff = current.getDate() - day + (day === 0 ? -6 : 1)
        current.setDate(diff)

        const weeks = []
        
        while (current <= end) {
            const weekIso = getWeekNumber(current)
            const year = current.getFullYear() // ISO week year might differ, simplified for now
            
            // Calculate week end (Sunday)
            const weekEnd = new Date(current)
            weekEnd.setDate(weekEnd.getDate() + 6)
            
            weeks.push({
                ano: year,
                semana_iso: weekIso,
                data_inicio: new Date(current),
                data_fim: weekEnd,
                status: 'Pendente', // Placeholder, ideally fetch status
                total_refeicoes: 0 // Placeholder
            })
            
            // Next week
            current.setDate(current.getDate() + 7)
        }
        
        // Fetch status from API (optional optimization: batch fetch status for these weeks)
        // For now, we list them as "Available to Plan"
        
        semanas.value = weeks
    } finally {
        loadingSemanas.value = false
    }
}

watch(selectedCicloId, () => {
    generateWeeks()
})

const handleEdit = (semana) => {
    emit('edit', {
        ...semana,
        cardapio_grupo_id: selectedCicloId.value,
        cardapio_grupo_nome: ciclos.value.find(c => c.id === selectedCicloId.value)?.nome
    })
}

const formatDateShort = (date: Date) => {
    return date.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' })
}
</script>

<template>
  <div class="flex flex-col gap-4">
    
    <!-- Cycle Selector -->
    <div class="bg-div-15 p-4 rounded border border-div-30 flex items-center gap-4">
        <div class="flex-1">
            <label class="text-[10px] font-black text-secondary uppercase tracking-wider mb-1 block">Ciclo de Cardápio</label>
            <select v-model="selectedCicloId" class="w-full bg-background border border-secondary/20 rounded px-3 py-2 text-sm focus:outline-none focus:border-primary">
                <option value="" disabled>Selecione um ciclo...</option>
                <option v-for="ciclo in ciclos" :key="ciclo.id" :value="ciclo.id">
                    {{ ciclo.nome }}
                </option>
            </select>
        </div>
        <div v-if="selectedCicloId" class="shrink-0 text-right">
             <p class="text-[10px] text-secondary font-black uppercase tracking-wider">Vigência</p>
             <p class="text-xs font-medium">
                {{ ciclos.find(c => c.id === selectedCicloId)?.data_inicio ? formatDateShort(new Date(ciclos.find(c => c.id === selectedCicloId).data_inicio)) : '' }} 
                até 
                {{ ciclos.find(c => c.id === selectedCicloId)?.data_fim ? formatDateShort(new Date(ciclos.find(c => c.id === selectedCicloId).data_fim)) : '' }}
             </p>
        </div>
    </div>

    <!-- Weeks List -->
    <div class="flex flex-col gap-2">
        <div v-if="loadingSemanas" class="flex items-center justify-center py-12">
             <div class="w-6 h-6 border-2 border-primary/20 border-t-primary rounded-full animate-spin"></div>
        </div>

        <div v-else-if="!selectedCicloId" class="text-center py-12 text-secondary bg-div-15 rounded border border-div-30/50">
             Selecione um ciclo acima para visualizar as semanas.
        </div>

        <div v-else-if="semanas.length === 0" class="text-center py-12 text-secondary">
             Nenhuma semana encontrada neste período.
        </div>

        <ManagerListItem
          v-else
          v-for="(semana, index) in semanas"
          :key="`${semana.ano}-${semana.semana_iso}`"
          :item="semana"
          :title="`Semana ${semana.semana_iso} | ${semana.ano}`"
          :subtitle="`${formatDateShort(semana.data_inicio)} a ${formatDateShort(semana.data_fim)}`"
          @edit="handleEdit(semana)"
        >

          <template #metadata>
             <button class="text-xs text-primary font-bold hover:underline">
                 Planejar Cardápio
             </button>
          </template>
        </ManagerListItem>
    </div>
  </div>
</template>
