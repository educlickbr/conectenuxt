<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import MatrizFilterBar from '@/components/matriz_curricular/MatrizFilterBar.vue'

const appStore = useAppStore()
const toast = useToastStore()

// Filters
const filters = ref({
    escola_id: null,
    ano_etapa_id: null,
    turma_id: null
})
const selectedModelo = ref<string | null>(null)

// Data
const availableModelos = ref<any[]>([])
const students = ref<any[]>([]) // Grid Data
const isLoadingModelos = ref(false)
const isLoadingGrid = ref(false)
const isSaving = ref(false)

// Columns/Structure for the evaluation
const modelDetails = ref<any>(null)
// UI State
const expandedStudentId = ref<string | null>(null)

// --- Fetchers ---

const fetchModelos = async () => {
    if (!filters.value.ano_etapa_id) {
        availableModelos.value = []
        selectedModelo.value = null
        return
    }

    isLoadingModelos.value = true
    try {
        const { data } = await useFetch('/api/avaliacao/assoc_ano_etapa', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                id_ano_etapa: filters.value.ano_etapa_id
            }
        })
        availableModelos.value = (data.value as any)?.items || []
    } catch (e) {
        console.error('Error fetching models:', e)
    } finally {
        isLoadingModelos.value = false
    }
}

const criterioOptions = ref<Record<string, any[]>>({})

const fetchModelDetails = async () => {
   if (!selectedModelo.value) {
       modelDetails.value = null
       criterioOptions.value = {}
       return
   }
   
   // Fetch groups
   const { data: groups } = await useFetch('/api/avaliacao/grupos', {
       params: { id_empresa: appStore.company?.empresa_id, id_modelo: selectedModelo.value }
   })
   
   const groupsList = (groups.value as any)?.items || []
   const enrichedGroups = []
   const uniqueCriterios = new Set<string>()
   
   for (const group of groupsList) {
       const { data: items } = await useFetch('/api/avaliacao/itens_avaliacao', {
           params: { id_empresa: appStore.company?.empresa_id, id_grupo: group.id }
       })
       
       const groupItems = (items.value as any)?.items || []
       enrichedGroups.push({
           ...group,
           items: groupItems
       })

       // Collect criterion IDs
       groupItems.forEach((i: any) => {
           if (i.id_modelo_criterio) uniqueCriterios.add(i.id_modelo_criterio)
       })
   }
   
   modelDetails.value = { groups: enrichedGroups }

   // Fetch Options for Criterios
   for (const criterioId of uniqueCriterios) {
       if (criterioOptions.value[criterioId]) continue; // Already fetched

       const { data: options } = await useFetch('/api/avaliacao/itens_criterio', {
            params: { id_empresa: appStore.company?.empresa_id, id_criterio: criterioId }
       })
       
       criterioOptions.value[criterioId] = (options.value as any)?.items || []
   }
}


const fetchGrid = async () => {
    if (!filters.value.turma_id || !selectedModelo.value) {
        students.value = []
        return
    }

    isLoadingGrid.value = true
    await fetchModelDetails() 
    
    try {
        // Use the new RPC 'avaliacao_diario_get_grid' via generic get handler
        const { data } = await useFetch('/api/avaliacao/grid', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                id_turma: filters.value.turma_id,
                id_modelo: selectedModelo.value
            }
        })
        students.value = (data.value as any)?.items || []
    } catch (e) {
        console.error('Error fetching grid:', e)
        toast.showToast('Erro ao carregar lista de alunos.', 'error')
    } finally {
        isLoadingGrid.value = false
    }
}

// Actions
const toggleExpand = (studentId: string) => {
    if (expandedStudentId.value === studentId) {
        expandedStudentId.value = null
    } else {
        expandedStudentId.value = studentId
    }
}

const saveEvaluation = async (student: any) => {
    
    const payload = {
        id_turma: filters.value.turma_id,
        id_aluno: student.id_aluno,
        id_modelo_avaliacao: selectedModelo.value,
        id_ano_etapa: filters.value.ano_etapa_id,
        status: 'CONCLUIDA', 
        respostas: student.respostas?.map((r: any) => ({
            id_item_avaliacao: r.id_item,
            id_item_criterio: r.id_item_criterio
        })) || []
    }
    
    try {
        isSaving.value = true
        await $fetch('/api/avaliacao/registros', {
            method: 'POST',
            body: {
                id_empresa: appStore.company?.empresa_id,
                data: payload 
            }
        })
    } catch(e) {
        console.error(e)
        const studentName = student.nome_aluno?.split(' ')[0] || 'Aluno'
        toast.showToast(`Erro ao salvar nota de ${studentName}.`, 'error')
    } finally {
        isSaving.value = false
    }
}

// Helpers
const getInitials = (name: string) => {
    if (!name) return '?'
    const parts = name.trim().split(/\s+/)
    if (parts.length >= 2) return ((parts[0] || '').charAt(0) + (parts[1] || '').charAt(0)).toUpperCase()
    return name.slice(0, 2).toUpperCase()
}

// Watchers
watch(() => filters.value.ano_etapa_id, fetchModelos)
watch(() => [filters.value.turma_id, selectedModelo.value], () => {
    if (filters.value.turma_id && selectedModelo.value) {
        fetchGrid()
    } else {
        students.value = []
        expandedStudentId.value = null
    }
})

</script>

<template>
    <div class="space-y-6 min-h-[500px]">
        
        <!-- Controls -->
        <div class="bg-surface border border-div-15 rounded-xl p-6 shadow-sm">
             <div class="grid grid-cols-1 xl:grid-cols-[1fr,auto] gap-6 items-end">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 w-full">
                     <MatrizFilterBar v-model="filters" :showTurma="true" />
                     
                     <div v-if="filters.ano_etapa_id" class="animate-in fade-in slide-in-from-top-2">
                        <ManagerField 
                            label="Modelo de Avaliação" 
                            type="select" 
                            :model-value="selectedModelo ?? undefined"
                            @update:modelValue="v => selectedModelo = v"
                            :disabled="isLoadingModelos"
                        >
                            <option :value="null">Selecione uma avaliação...</option>
                            <option v-for="m in availableModelos" :key="m.id_modelo_avaliacao" :value="m.id_modelo_avaliacao">
                                {{ m.nome_modelo }}
                            </option>
                        </ManagerField>
                     </div>
                </div>
             </div>
        </div>

        <!-- List View -->
        <div v-if="filters.turma_id && selectedModelo" class="space-y-4">
            
            <div v-if="isLoadingGrid" class="py-12 text-center text-secondary">
                <div class="animate-spin h-8 w-8 border-2 border-primary border-t-transparent rounded-full mx-auto mb-2"></div>
                Carregando lista de alunos...
            </div>
            
            <div v-else-if="students.length === 0" class="py-12 text-center text-secondary bg-surface rounded-xl border border-div-15 border-dashed">
                Nenhum aluno encontrado ou erro ao carregar.
            </div>

            <!-- Students List -->
            <div v-else class="grid grid-cols-1 gap-4">
                 <div v-for="student in students" :key="student.id_aluno" 
                    class="bg-surface border border-div-15 rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-all duration-300"
                    :class="{'ring-2 ring-primary/10': expandedStudentId === student.id_aluno}"
                 >
                    <!-- Card Header (Click to Expand) -->
                    <div 
                        @click="toggleExpand(student.id_aluno)"
                        class="p-4 flex items-center gap-4 cursor-pointer hover:bg-div-05/50 transition-colors select-none"
                    >
                         <!-- Avatar -->
                        <div 
                            class="w-10 h-10 rounded-xl flex items-center justify-center text-sm font-bold shrink-0 bg-div-15 text-secondary transition-colors"
                            :class="{'bg-primary/20 text-primary': expandedStudentId === student.id_aluno}"
                        >
                            {{ getInitials(student.nome_aluno) }}
                        </div>

                        <!-- Basic Info -->
                        <div class="flex-1 min-w-0">
                            <h4 class="font-bold text-text text-sm truncate leading-snug">
                                {{ student.nome_aluno }}
                            </h4>
                            <p class="text-[10px] text-secondary/80">
                                {{ student.status_matricula === 'ativa' ? 'Matriculado' : student.status_matricula }}
                            </p>
                        </div>
                        
                        <!-- Status/Chevron -->
                         <div class="text-secondary/50 transform transition-transform duration-300" :class="{'rotate-180': expandedStudentId === student.id_aluno}">
                           <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                        </div>
                    </div>

                    <!-- Expanded Content (Grades) -->
                    <div v-if="expandedStudentId === student.id_aluno" class="border-t border-div-15 bg-div-05/20 px-4 py-6 animate-in slide-in-from-top-2">
                        
                        <!-- Groups Logic -->
                        <div v-for="group in modelDetails?.groups" :key="group.id" class="mb-6 last:mb-0">
                            
                            <!-- Group Header -->
                            <div class="flex items-center gap-2 mb-3 border-b border-div-15 pb-2">
                                <h5 class="text-xs font-black text-secondary uppercase tracking-wider">{{ group.nome_grupo }}</h5>
                                <span class="text-[9px] font-bold text-primary bg-primary/10 px-1.5 py-0.5 rounded">Peso: {{ group.peso_grupo }}</span>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-8 gap-y-6">
                                <div v-for="item in group.items" :key="item.id" class="flex flex-col gap-1.5">
                                    <div class="flex justify-between items-baseline">
                                         <label class="text-xs font-bold text-secondary truncate max-w-[80%]" :title="item.texto_pergunta">
                                            {{ item.texto_pergunta }}
                                         </label>
                                         <span class="text-[9px] font-black text-primary/60 bg-primary/5 px-1.5 py-0.5 rounded">
                                            Max: {{ item.peso_item }}
                                         </span>
                                    </div>
                                    
                                    <!-- Dropdown Input -->
                                    <select
                                        :value="student.respostas?.find((r: any) => r.id_item === item.id)?.id_item_criterio"
                                        class="w-full h-10 px-3 border border-div-15 rounded-lg bg-surface text-text text-sm focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all appearance-none bg-[url('data:image/svg+xml;charset=utf-8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20fill%3D%22none%22%20viewBox%3D%220%200%2020%2020%22%3E%3Cpath%20stroke%3D%22%236B7280%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%20stroke-width%3D%221.5%22%20d%3D%22M6%208l4%204%204-4%22%2F%3E%3C%2Fsvg%3E')] bg-[length:1.25rem_1.25rem] bg-[right_0.5rem_center] bg-no-repeat pr-10"
                                        @change="(e: any) => {
                                             const val = e.target.value === '' ? null : e.target.value;
                                             
                                             // Update Local
                                             const existingAnswer = student.respostas?.find((r: any) => r.id_item === item.id);
                                             if (existingAnswer) {
                                                 existingAnswer.id_item_criterio = val;
                                             } else {
                                                 if (!student.respostas) student.respostas = [];
                                                 student.respostas.push({ id_item: item.id, id_item_criterio: val });
                                             }
                                             
                                             saveEvaluation(student);
                                        }"
                                    >
                                        <option value="">Selecione...</option>
                                        <option 
                                            v-for="opt in (criterioOptions[item.id_modelo_criterio] || [])" 
                                            :key="opt.id" 
                                            :value="opt.id"
                                        >
                                            {{ opt.rotulo }}
                                        </option>
                                    </select>
                                </div>
                            </div>

                        </div>
                    </div>

                 </div>
            </div>

        </div>

        <!-- Initial Placeholder -->
        <div v-else class="py-24 text-center border-2 border-dashed border-div-15 rounded-xl bg-surface/50">
            <p class="text-secondary font-medium">Selecione uma turma e um modelo de avaliação para começar.</p>
        </div>
    </div>
</template>
