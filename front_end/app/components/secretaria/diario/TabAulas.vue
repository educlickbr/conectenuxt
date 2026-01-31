<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import MatrizFilterBar from '@/components/matriz_curricular/MatrizFilterBar.vue'
import ModalDiarioAula from '@/components/secretaria/diario/ModalDiarioAula.vue'

const appStore = useAppStore()
const toast = useToastStore()

const route = useRoute()
const router = useRouter()

// State
const filters = ref({
    escola_id: (route.query.id_escola as string) || null,
    ano_etapa_id: (route.query.id_ano_etapa as string) || null,
    turma_id: (route.query.id_turma as string) || null
})

// Sync filters to URL
watch(filters, (newVal) => {
    router.replace({
        query: {
            ...route.query,
            id_escola: newVal.escola_id || undefined,
            id_ano_etapa: newVal.ano_etapa_id || undefined,
            id_turma: newVal.turma_id || undefined
        }
    })
}, { deep: true })

const isLoading = ref(false)
const aulas = ref<any[]>([])
const selectedAula = ref<any>(null)
const isModalOpen = ref(false)

// Actions
const fetchAulas = async () => {
    // We need at least a school context usually, but pagination allows broad search.
    // However, for "Diário", typically you select a class (turma).
    // The RPC allows p_id_turma=NULL, but it might return too much.
    // Let's only fetch if a Turma is selected OR at least a School.
    if (!filters.value.escola_id && !filters.value.turma_id) {
         aulas.value = [] // Clear if no context
         return
    }

    isLoading.value = true
    try {
        const data: any = await $fetch('/api/estrutura_academica/diario_aulas', {
            params: {
                id_empresa: appStore.company.empresa_id,
                id_turma: filters.value.turma_id || undefined, // undefined to exclude param if null
            }
        })

        aulas.value = data?.items || []

    } catch (e: any) {
        console.error(e)
        toast.showToast('Erro ao carregar aulas.', 'error')
    } finally {
        isLoading.value = false
    }
}

// Watch filters
watch(() => filters.value.turma_id, (newVal) => {
    if (newVal) fetchAulas()
    else aulas.value = []
})

// Modal Actions
const handleNew = () => {
    selectedAula.value = null
    isModalOpen.value = true
}

const handleEdit = (aula: any) => {
    selectedAula.value = aula
    isModalOpen.value = true
}

// Expose to parent
defineExpose({ handleNew })

onMounted(() => {
    if (filters.value.turma_id) {
        fetchAulas()
    }
})

// Helper
const formatDate = (dateStr: string) => {
    if (!dateStr) return ''
    const date = new Date(dateStr)
    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'short', year: 'numeric' }).format(date)
}

</script>

<template>
    <div class="p-6 md:p-8 min-h-[500px]">
        
        <!-- Filters -->
        <MatrizFilterBar v-model="filters" />

        <!-- Warning if no turma selected -->
        <div v-if="!filters.turma_id" class="mt-8 flex flex-col items-center justify-center p-12 bg-div-15 rounded-xl border border-dashed border-secondary/20">
             <div class="w-12 h-12 rounded-full bg-secondary/10 flex items-center justify-center mb-4 text-secondary">
                 <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10v6M2 10l10-5 10 5-10 5z"></path><path d="M6 12v5c3 3 9 3 12 0v-5"></path></svg>
             </div>
             <p class="text-secondary font-medium">Selecione uma turma acima para começar.</p>
        </div>

        <!-- List -->
        <div v-else class="mt-6 flex flex-col gap-4">
            
            <div v-if="isLoading" class="p-12 text-center text-secondary">Carregando aulas...</div>

            <div v-else-if="aulas.length === 0" class="p-12 text-center bg-surface rounded-xl border border-secondary/10">
                <p class="text-secondary">Nenhuma aula registrada nesta turma ainda.</p>
                <button @click="handleNew" class="mt-4 text-primary font-bold hover:underline text-sm">
                    + Registrar primeira aula
                </button>
            </div>

            <div v-for="aula in aulas" :key="aula.id" 
                class="group bg-surface hover:bg-surface-hover border border-div-15 rounded p-5 transition-all relative"
            >
                <div class="flex items-start justify-between gap-4">
                    
                    <!-- Date Box -->
                    <div class="flex flex-col items-center justify-center bg-div-30 rounded w-14 h-14 shrink-0 border border-div-30">
                        <!-- Date Fix: Parse YYYY-MM-DD manually to avoid timezone shift -->
                         <div class="flex flex-col items-center leading-none">
                            <span class="text-xs font-black text-secondary uppercase">
                                {{ new Date(aula.data + 'T12:00:00').toLocaleString('pt-BR', { month: 'short' }).replace('.', '') }}
                            </span>
                            <span class="text-xl font-bold text-text">
                                {{ aula.data.split('-')[2] }}
                            </span>
                         </div>
                    </div>

                    <!-- Content -->
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 mb-1">
                            <span v-if="aula.componente_nome" class="px-2 py-0.5 rounded bg-primary/10 text-primary text-[10px] font-bold uppercase tracking-wider">
                                {{ aula.componente_nome }}
                            </span>
                            <span v-else class="px-2 py-0.5 rounded bg-secondary/10 text-secondary text-[10px] font-bold uppercase tracking-wider">
                                Geral
                            </span>
                             <span class="text-[10px] text-secondary">
                                • Prof. {{ aula.professor_nome?.split(' ')[0] || 'Desconhecido' }}
                            </span>
                        </div>
                        
                        <p class="text-text/90 font-medium line-clamp-2 text-sm leading-relaxed">
                            {{ aula.conteudo }}
                        </p>
                        
                        <!-- Details Footer (Turma info always visible as requested, though redundant if filtered, good for context) -->
                         <div class="flex flex-wrap gap-x-4 gap-y-1 mt-3 text-[11px] text-secondary/70 border-t border-dashed border-div-30 pt-2">
                             <div class="flex items-center gap-1">
                                 <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path></svg>
                                 {{ aula.nome_escola }}
                             </div>
                              <div class="flex items-center gap-1">
                                 <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path></svg>
                                 {{ aula.nome_ano_etapa }} • {{ aula.nome_classe }}
                             </div>
                              <div class="flex items-center gap-1">
                                 <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                 {{ aula.turno }}
                             </div>
                         </div>
                    </div>

                    <!-- Edit Action -->
                     <button @click="handleEdit(aula)" class="p-2 text-secondary hover:text-primary rounded-full hover:bg-primary/5 transition-colors opacity-0 group-hover:opacity-100 focus:opacity-100">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                     </button>

                </div>
            </div>
        </div>

        <ModalDiarioAula
            v-if="isModalOpen"
            :isOpen="isModalOpen"
            :initialData="selectedAula"
            :initialFilters="filters"
            @close="isModalOpen = false"
            @success="fetchAulas"
        />

    </div>
</template>
