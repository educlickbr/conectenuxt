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
const viewMode = ref<'Tudo' | 'Rede' | 'Segmentado'>('Tudo')
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
        // If Segmentado: seg-2025-{etapa}-{escola? 'all'}
        let key = ''
        if (item.escopo === 'Rede') {
            key = `rede-${item.ano}`
        } else {
            key = `seg-${item.ano}-${item.id_ano_etapa}-${item.id_escola || 'all'}`
        }

        if (!groups[key]) {
            groups[key] = {
                id: key, // Virtual ID for the group
                ano: item.ano,
                escopo: item.escopo,
                ano_etapa_nome: item.ano_etapa_nome,
                escola_nome: item.escola_nome, // Added this field in RPC/Join
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
    console.log('Fetching Calendarios. Mode:', viewMode.value, 'Filters:', filters.value)
    try {
        const { data, error }: any = await useFetch('/api/estrutura_academica/calendarios', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                pagina: 1,
                limite: 100, // Fetch all for now to group
                id_ano_etapa: filters.value.ano_etapa_id,
                id_escola: filters.value.escola_id,
                modo: viewMode.value
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
watch(() => filters.value.escola_id, fetchCalendarios)
watch(viewMode, () => {
    // When switching modes, logic requires:
    // If 'Tudo' or 'Rede' -> Clear filters handled by UI (optional, but requested "filters inactive or disappear")
    // Note: The backend handles ignoring filters if needed, but clearing keeps UI consistent.
    if (viewMode.value !== 'Segmentado') {
        filters.value.escola_id = null
        filters.value.ano_etapa_id = null
    }
    fetchCalendarios()
})

// Watch company to fetch when ready (fix F5 load)
watch(() => appStore.company, (val) => {
    if (val?.empresa_id) fetchCalendarios()
}, { immediate: true })

onMounted(() => {
    // optional, watcher with immediate covers it
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
        
        <!-- View Mode Selector -->
        <div class="flex flex-col md:flex-row gap-4 items-center justify-between mb-6">
            <div class="flex items-center bg-surface rounded-full p-1 border border-secondary/10">
                <button 
                    v-for="mode in (['Tudo', 'Rede', 'Segmentado'] as const)" 
                    :key="mode"
                    @click="viewMode = mode"
                    class="px-4 py-1.5 rounded-full text-sm font-bold transition-all"
                    :class="viewMode === mode ? 'bg-primary text-white shadow-md' : 'text-secondary hover:text-text'"
                >
                    {{ mode }}
                </button>
            </div>
            
            <div v-if="viewMode === 'Segmentado'" class="text-xs text-secondary font-medium">
                Selecione os filtros para refinar a busca
            </div>
        </div>

        <!-- Filters (Hide if NOT Segmentado) -->
        <div v-show="viewMode === 'Segmentado'" class="transition-all duration-300">
             <MatrizFilterBar 
                v-model="filters" 
                :show-turma="false"
            />
        </div>

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
