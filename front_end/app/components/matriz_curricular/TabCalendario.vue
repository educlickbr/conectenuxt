<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import MatrizFilterBar from '@/components/matriz_curricular/MatrizFilterBar.vue'
import CalendarioList from '@/components/matriz_curricular/calendario/CalendarioList.vue'
import ModalGerenciarCalendario from '@/components/matriz_curricular/calendario/ModalGerenciarCalendario.vue'

const appStore = useAppStore()
const toast = useToastStore()

// Filter State
const filters = ref({
    escola_id: null,
    ano_etapa_id: null,
    turma_id: null // Unused but required by interface
})

const isLoading = ref(false)
const rawCalendars = ref<any[]>([])

// Logic to group API flat rows into "Calendars" (Group by ID_Ano_Etapa + Ano OR Scope='Rede' + Ano)
// Actually, mtz_calendario_anual has `id` which is unique per period. 
// We want to group by (escopo, ano, id_ano_etapa).
const groupedCalendars = computed(() => {
    const groups: Record<string, any> = {}

    for (const item of rawCalendars.value) {
        // Create a unique key for the "Calendar Entity"
        // If Rede: rede-2025
        // If Etapa: etapa-{uuid}-2025
        const key = item.escopo === 'Rede' 
            ? `rede-${item.ano}` 
            : `etapa-${item.id_ano_etapa}-${item.ano}`

        if (!groups[key]) {
            groups[key] = {
                id: key, // Virtual ID for the group
                ano: item.ano,
                escopo: item.escopo,
                ano_etapa_nome: item.ano_etapa_nome, // Ensure View returns this or we fetch it?
                // The VIEW/RPC mtz_calendario_anual_get_paginado usually returns joined columns.
                // If not, we might need to display just 'Etapa...' 
                // Let's assume RPC returns ano_etapa_nome or similar.
                // Checking migration (Step 110): SELECT id, ..., ae.nome as ano_etapa_nome ...
                // Yes, it returns ano_etapa_nome.
                modelo_nome: item.modelo_nome,
                periodos: []
            }
        }

        groups[key].periodos.push({
            id: item.id, // ID of the period row
            numero: item.numero_periodo,
            data_inicio: item.data_inicio,
            data_fim: item.data_fim
        })
    }

    return Object.values(groups)
})


const fetchCalendarios = async () => {
    isLoading.value = true
    try {
        const { data, error }: any = await useFetch('/api/estrutura_academica/calendarios', {
            params: {
                id_empresa: appStore.company.empresa_id,
                pagina: 1,
                limite: 100, // Fetch all for now to group
                id_ano_etapa: filters.value.ano_etapa_id
                // Note: The RPC filters by id_ano_etapa. If null, it returns all.
            }
        })

        if (error.value) throw error.value
        
        rawCalendars.value = data.value?.items || []

    } catch (err) {
        console.error('Erro ao buscar calendários:', err)
        toast.showToast('Erro ao carregar calendários.', 'error')
    } finally {
        isLoading.value = false
    }
}

// Watch filters
// watch(() => filters.value.escola_id, fetchCalendarios) // Calendars are not strictly tied to Escola usually, mostly Ano/Etapa
watch(() => filters.value.ano_etapa_id, fetchCalendarios)

onMounted(() => {
    fetchCalendarios()
})

// Modal Logic
const isModalOpen = ref(false)
const selectedCalendar = ref<any>(null)

const handleNew = () => {
    selectedCalendar.value = null
    isModalOpen.value = true
}

// Expose to parent
defineExpose({ handleNew })

const handleEdit = (cal: any) => {
    // When editing, we pass the group. 
    // The Modal expects { periodos: [...] }.
    selectedCalendar.value = cal
    isModalOpen.value = true
}

const handleDelete = (cal: any) => {
    // Implement delete logic (batch delete periods?)
    // For now log
    console.log('Delete', cal)
}

const handleSuccess = (savedContext?: any) => {
    if (savedContext) {
        // Update filters to match what was saved, ensuring the user sees the new data
        if (savedContext.escopo === 'Ano_Etapa' && savedContext.id_ano_etapa) {
            filters.value.ano_etapa_id = savedContext.id_ano_etapa
            // If we selected an Ano/Etapa, usually we want to see it.
            // Note: FilterBar watcher will trigger fetchCalendarios automatically.
        } else if (savedContext.escopo === 'Rede') {
            // If Rede, maybe clear filters to show everything including Rede?
            filters.value.ano_etapa_id = null
            // filters.value.escola_id = null // Optional: clear school too if needed
        }
    } else {
        fetchCalendarios()
    }
}
</script>

<template>
    <div class="p-6 md:p-8 min-h-[500px]">
        
        <!-- Header (Title only, Actions moved to Page Layout) -->
        <div class="mb-8">
            <div class="flex items-center gap-2 mb-1">
                 <h2 class="text-2xl font-bold text-text">Calendários Escolares</h2>
            </div>
            <p class="text-sm text-secondary">
                Gerencie os períodos letivos da rede ou por etapa.
            </p>
        </div>

        <!-- Filters (Hide Turma) -->
        <MatrizFilterBar 
            v-model="filters" 
            :show-turma="false"
        />

        <!-- Content -->
        <CalendarioList 
            :calendarios="groupedCalendars"
            :loading="isLoading"
            @edit="handleEdit"
            @delete="handleDelete"
        />

        <!-- Modal -->
        <ModalGerenciarCalendario
            v-if="isModalOpen"
            :isOpen="isModalOpen"
            :initialData="selectedCalendar"
            @close="isModalOpen = false"
            @success="handleSuccess"
        />

    </div>
</template>
