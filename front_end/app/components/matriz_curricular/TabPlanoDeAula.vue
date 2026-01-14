<script setup>
import { ref, onMounted, watch } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ModalGerenciarPlano from './planejamento/ModalGerenciarPlano.vue'
import ModalGerenciarAula from './planejamento/ModalGerenciarAula.vue'
import ManagerField from '@/components/ManagerField.vue'

// Stores
const appStore = useAppStore()
const toast = useToastStore()

// State
const isLoading = ref(false)
const items = ref([])
const totalItems = ref(0)
const page = ref(1)
const perPage = ref(10)

// Filters
const filterSearch = ref('')
const filterAnoEtapa = ref('')

// Dropdowns
const anoEtapaOptions = ref([])

// Detailed View State
const expandedRows = ref(new Set())
const loadingDetails = ref(new Set())
const detailsData = ref({}) // Format: { planId: [lessons...] }

// Modal State
const showModalPlano = ref(false)
const showModalAula = ref(false)
const selectedPlano = ref(null)
const selectedAula = ref(null)
const modalContext = ref(null)

// Init
onMounted(async () => {
    await fetchFilters()
    await fetchData()
})

// Fetch Filters (Ano/Etapa)
const fetchFilters = async () => {
    try {
        const { items } = await $fetch('/api/estrutura_academica/ano_etapa', {
            query: { id_empresa: appStore.company.empresa_id }
        })
        if (items && items.length) {
            anoEtapaOptions.value = items.map(i => ({ value: i.id, label: i.nome }))
        }
    } catch (err) {
        console.error('Error loading filters', err)
    }
}

// Fetch Data (Plans)
const fetchData = async () => {
    isLoading.value = true
    try {
        const { items: data, total } = await $fetch('/api/estrutura_academica/plano_de_aulas_get_paginado', {
            query: {
                id_empresa: appStore.company.empresa_id,
                page: page.value,
                limit: perPage.value,
                search: filterSearch.value,
                id_ano_etapa: filterAnoEtapa.value || undefined
            }
        })
        items.value = data || []
        totalItems.value = total || 0
    } catch (err) {
        console.error('Error loading plans', err)
        toast.showToast('Erro ao carregar planos de aula', 'error')
    } finally {
        isLoading.value = false
    }
}

// Watch Filters
let searchTimer = null
watch(filterSearch, () => {
    clearTimeout(searchTimer)
    searchTimer = setTimeout(() => {
        page.value = 1
        fetchData()
    }, 500)
})

watch(filterAnoEtapa, () => {
    page.value = 1
    fetchData()
})

watch(page, fetchData)

// Expand/Collapse Logic
const toggleExpand = async (item) => {
    const id = item.id
    if (expandedRows.value.has(id)) {
        expandedRows.value.delete(id)
    } else {
        expandedRows.value.add(id)
        if (!detailsData.value[id]) {
            await fetchLessons(id)
        }
    }
}

const fetchLessons = async (planId) => {
    loadingDetails.value.add(planId)
    try {
        const { items: lessons } = await $fetch('/api/estrutura_academica/plano_itens_get_by_plano', {
            query: {
                id_empresa: appStore.company.empresa_id,
                id_plano: planId
            }
        })
        detailsData.value[planId] = lessons || []
    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao carregar aulas', 'error')
    } finally {
        loadingDetails.value.delete(planId)
    }
}

// Actions
const handleEditPlan = (item) => {
    selectedPlano.value = item
    modalContext.value = {
        id_componente: item.id_componente,
        id_ano_etapa: item.id_ano_etapa,
        componente_nome: item.componente_nome,
        ano_etapa_nome: item.ano_etapa_nome
    }
    showModalPlano.value = true
}

const handleDeletePlan = async (item) => {
    if (!confirm(`Tem certeza que deseja excluir o plano "${item.titulo}"?`)) return

    try {
        await $fetch('/api/estrutura_academica/pl_plano_de_aulas_delete', {
            method: 'DELETE',
            body: {
                id: item.id,
                id_empresa: appStore.company.empresa_id
            }
        })
        toast.showToast('Plano removido com sucesso!')
        fetchData()
    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao remover plano', 'error')
    }
}

// Lessons Actions
const handleNewLesson = (plan) => {
    selectedPlano.value = plan // We need context
    selectedAula.value = null
    showModalAula.value = true
}

const handleEditLesson = (lesson, plan) => {
    selectedPlano.value = plan
    selectedAula.value = lesson
    showModalAula.value = true
}

const handleModalSuccess = () => {
    fetchData()
    // Refresh details if needed
    if (selectedPlano.value?.id) {
        fetchLessons(selectedPlano.value.id)
    }
}

// Global "New" Action (Button from Parent)
const openNewPlanModal = () => {
    selectedPlano.value = null
    modalContext.value = null // No context -> Triggers Selection Mode
    showModalPlano.value = true
}

defineExpose({
    openNewPlanModal
})

</script>

<template>
    <div class="flex flex-col h-full">
        <!-- Filters -->
         <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
            <ManagerField 
                label="Ano / Etapa" 
                type="select" 
                v-model="filterAnoEtapa"
            >
                <option value="">Todos os Anos/Etapas</option>
                <option v-for="opt in anoEtapaOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
            </ManagerField>

            <ManagerField
                label="Buscar Componente"
                v-model="filterSearch"
                placeholder="Ex: Matemática..."
            >
                <template #icon>
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="text-secondary"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                </template>
            </ManagerField>
        </div>

        <!-- Content -->
        <div v-if="isLoading" class="flex-1 flex items-center justify-center">
             <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin"></div>
        </div>
        
        <div v-else-if="items.length === 0" class="flex-1 flex flex-col items-center justify-center text-secondary opacity-50">
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" class="mb-4"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
            <p>Nenhum plano de aula encontrado.</p>
        </div>

        <div v-else class="flex-1 overflow-y-auto pr-2 space-y-3">
            <div 
                v-for="item in items" 
                :key="item.id" 
                class="bg-div-15 rounded-lg border border-div-30 overflow-hidden transition-all hover:border-div-50"
            >
                <!-- Main Row -->
                <div class="p-4 flex items-center justify-between gap-4">
                    <div class="flex-1 min-w-0 cursor-pointer" @click="toggleExpand(item)">
                        <div class="flex items-center gap-2 mb-1">
                            <span class="text-[10px] font-black uppercase tracking-wider text-primary bg-primary/10 px-2 py-0.5 rounded">{{ item.componente_nome }}</span>
                            <span class="text-[10px] font-bold text-secondary uppercase tracking-wider">{{ item.ano_etapa_nome }}</span>
                        </div>
                        <h3 class="text-sm font-bold text-text truncate">{{ item.titulo || 'Sem Título' }}</h3>
                        <p class="text-[11px] text-secondary truncate mt-0.5">{{ item.descricao || 'Sem descrição' }}</p>
                    </div>

                    <div class="flex items-center gap-2">
                         <button 
                            @click="handleEditPlan(item)" 
                            class="p-2 text-secondary hover:text-primary hover:bg-div-30 rounded-lg transition-colors"
                            title="Editar Dados do Plano"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                        </button>
                        <button 
                            @click="handleDeletePlan(item)" 
                            class="p-2 text-secondary hover:text-danger hover:bg-danger/10 rounded-lg transition-colors"
                            title="Excluir Plano"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2-2v2"></path></svg>
                        </button>
                         <button 
                            @click="toggleExpand(item)" 
                            class="p-2 text-secondary hover:bg-div-30 rounded-lg transition-all transform"
                            :class="expandedRows.has(item.id) ? 'rotate-180 text-primary' : ''"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                        </button>
                    </div>
                </div>

                <!-- Expanded Content (Lessons List) -->
                <div v-if="expandedRows.has(item.id)" class="border-t border-div-30 bg-div-30/30 p-4">
                    <div class="flex items-center justify-between mb-4">
                        <h4 class="text-xs font-black uppercase text-secondary tracking-widest flex items-center gap-2">
                            Aulas Planejadas
                            <span v-if="detailsData[item.id]" class="bg-div-50 text-text px-1.5 py-0.5 rounded-full text-[10px]">{{ detailsData[item.id].length }}</span>
                        </h4>
                        <button 
                            @click="handleNewLesson(item)"
                            class="text-[10px] font-bold uppercase tracking-wider text-primary bg-primary/10 hover:bg-primary/20 px-3 py-1.5 rounded-lg transition-colors flex items-center gap-2"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                            Nova Aula
                        </button>
                    </div>

                    <div v-if="loadingDetails.has(item.id)" class="flex justify-center py-4">
                         <div class="w-5 h-5 border-2 border-primary/20 border-t-primary rounded-full animate-spin"></div>
                    </div>

                    <div v-else-if="!detailsData[item.id] || detailsData[item.id].length === 0" class="text-center py-4 text-secondary/50 text-xs italic">
                        Nenhuma aula cadastrada neste plano.
                    </div>

                    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                        <div 
                            v-for="aula in detailsData[item.id]" 
                            :key="aula.id"
                            @click="handleEditLesson(aula, item)"
                            class="bg-background border border-div-30 p-3 rounded-lg hover:border-primary/50 cursor-pointer transition-all shadow-sm group"
                        >
                            <div class="flex items-center justify-between mb-2">
                                <span class="text-[10px] font-black uppercase bg-div-15 px-1.5 py-0.5 rounded text-secondary group-hover:text-primary transition-colors">Aula {{ aula.aula_numero }}</span>
                                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-secondary/30 group-hover:text-primary transition-colors"><polyline points="9 18 15 12 9 6"></polyline></svg>
                            </div>
                            <p class="text-xs font-bold text-text line-clamp-2">{{ aula.conteudo }}</p>
                            <p class="text-[10px] text-secondary line-clamp-1 mt-1">{{ aula.metodologia || 'Sem metodologia' }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modals -->
        <ModalGerenciarPlano 
            :is-open="showModalPlano"
            :context="modalContext"
            :initial-data="selectedPlano"
            @close="showModalPlano = false"
            @success="handleModalSuccess"
        />

        <ModalGerenciarAula
            :is-open="showModalAula"
            :plan-id="selectedPlano?.id"
            :initial-data="selectedAula"
            @close="showModalAula = false"
            @success="handleModalSuccess"
        />

    </div>
</template>
