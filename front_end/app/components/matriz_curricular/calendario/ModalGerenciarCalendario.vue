<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'
// ManagerModal removed (custom implementation used)

const props = defineProps<{
    isOpen: boolean
    initialData?: any
}>()

const emit = defineEmits(['close', 'success'])

const appStore = useAppStore()
const toast = useToastStore()

// State
const form = ref({
    ano: new Date().getFullYear(),
    escopo: 'Rede',
    id_ano_etapa: null as string | null,
    id_modelo_calendario: null as string | null,
    id_escola: null as string | null,
    periodos: [] as { numero: number, data_inicio: string, data_fim: string, id?: string }[]
})

const loading = ref(false)
const modelos = ref<any[]>([])
const anosEtapa = ref<any[]>([])
const escolas = ref<any[]>([])

// Fetch Dependencies
const fetchData = async () => {
    loading.value = true
    try {
        // Fetch Modelos
        const resModelos: any = await $fetch('/api/estrutura_academica/modelo_calendario', {
             params: { id_empresa: appStore.company.empresa_id }
        })
        modelos.value = resModelos.items || []

        // Fetch Anos/Etapa for selector
        const resEtapas: any = await $fetch('/api/estrutura_academica/ano_etapa', {
             params: { id_empresa: appStore.company.empresa_id }
        })
        anosEtapa.value = resEtapas.items || []

        // Fetch Escolas
        const { data: resEscolas, error: errEscolas } = await useSupabaseClient()
            .from('escolas')
            .select('id, nome')
            .eq('id_empresa', appStore.company.empresa_id)
            .order('nome')
        
        if (errEscolas) throw errEscolas
        escolas.value = resEscolas || []

    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao carregar dados auxiliares.', 'error')
    } finally {
        loading.value = false
    }
}

// Logic to generate periods slots
const generatePeriods = () => {
    if (!form.value.id_modelo_calendario) return

    const selectedModel = modelos.value.find(m => m.id === form.value.id_modelo_calendario)
    if (!selectedModel) return

    let count = 0
    if (selectedModel.nome.includes('Bimestral')) count = 4
    else if (selectedModel.nome.includes('Trimestral')) count = 3
    else if (selectedModel.nome.includes('Semestral')) count = 2
    else count = 1 // Default

    // Preserve existing data if resizing? 
    // For simplicity, reconstruct structure but try to keep values if index exists
    const newPeriods = []
    for (let i = 1; i <= count; i++) {
        const existing = form.value.periodos[i-1]
        newPeriods.push({
            numero: i,
            data_inicio: existing?.data_inicio || '',
            data_fim: existing?.data_fim || '',
            id: existing?.id // Keep ID if editing
        })
    }
    form.value.periodos = newPeriods
}

watch(() => form.value.id_modelo_calendario, generatePeriods)

// Initialize
onMounted(() => {
    fetchData()
    if (props.initialData) {
        form.value = {
            ano: props.initialData.ano,
            escopo: props.initialData.escopo,
            id_ano_etapa: props.initialData.id_ano_etapa,
            id_modelo_calendario: props.initialData.id_modelo || modelos.value.find(m => m.nome === props.initialData.modelo_nome)?.id, 
            id_escola: props.initialData.id_escola || null, // Ensure to load if exists
            periodos: props.initialData.periodos ? [...props.initialData.periodos] : []
        }
    }
})

const handleSave = async () => {
    // Validate
    if (!form.value.id_modelo_calendario) return toast.showToast('Selecione um modelo.', 'error')
    if (form.value.escopo === 'Ano_Etapa' && !form.value.id_ano_etapa) return toast.showToast('Selecione a etapa.', 'error')
    
    // Validate Dates
    for (const p of form.value.periodos) {
        if (!p.data_inicio || !p.data_fim) {
            return toast.showToast(`Preencha as datas do ${p.numero}º Período.`, 'error')
        }
    }

    loading.value = true
    try {
        // Loop upsert calls (Backend batching would be better but this works for MVP)
        // We need to save EACH period as a row in mtz_calendario_anual
        
        const promises = form.value.periodos.map(p => {
            return $fetch('/api/estrutura_academica/calendarios', { // Assuming we create this generic endpoint or use direct RPC wrapper page
                // Actually, let's use the explicit generic RPC endpoint pattern if available, or just create a specific server route?
                // The generic route `[resource].get.ts` is only for GET.
                // We usually implement POST/PUT in `[resource].post.ts` or similar? 
                // Or maybe the user has a `structure` action handler.
                // Let's assume we need to implement the server handler too. For now let's invoke a new route we will build.
                method: 'POST',
                body: {
                    id_empresa: appStore.company.empresa_id,
                    data: {
                        id: p.id,
                        // id_empresa is needed in the payload for the procedure? 
                        // The SQL procedure uses (p_data ->> 'id_usuario') and others.
                        // It does NOT read id_empresa from p_data, it uses the argument p_id_empresa.
                        id_ano_etapa: form.value.escopo === 'Rede' ? null : (form.value.id_ano_etapa || null),
                        id_modelo_calendario: form.value.id_modelo_calendario || null,
                        id_escola: form.value.escopo === 'Rede' ? null : (form.value.id_escola || null),
                        escopo: form.value.escopo,
                        ano: form.value.ano,
                        numero_periodo: p.numero,
                        data_inicio: p.data_inicio,
                        data_fim: p.data_fim,
                        id_usuario: appStore.user?.id
                    }
                }
            })
        })

        await Promise.all(promises)

        toast.showToast('Calendário salvo com sucesso!')
        emit('success', {
            escopo: form.value.escopo,
            id_ano_etapa: form.value.escopo === 'Rede' ? null : form.value.id_ano_etapa
        })
        emit('close')

    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao salvar calendário.', 'error')
    } finally {
        loading.value = false
    }
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-[60] flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="$emit('close')"></div>
        
        <div class="relative w-full max-w-2xl bg-surface rounded-xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
            
            <!-- Header -->
            <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-white dark:bg-surface relative z-10">
                <h3 class="text-lg font-bold text-text">Gerenciar Calendário</h3>
                <button @click="$emit('close')" class="text-secondary hover:text-text transition-colors">
                     <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Scrollable Content -->
            <div class="p-6 overflow-y-auto flex-1 bg-background/50">
                
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                    <!-- Ano -->
                    <ManagerField label="Ano Letivo" type="number" v-model="form.ano" />
                    
                    <!-- Escopo -->
                    <div class="flex flex-col gap-2">
                         <label class="text-[10px] font-bold uppercase tracking-wider text-secondary">Escopo</label>
                         <div class="flex items-center gap-4 h-10">
                            <label class="flex items-center gap-2 cursor-pointer">
                                <input type="radio" v-model="form.escopo" value="Rede" class="accent-primary">
                                <span class="text-sm font-medium">Rede (Unificado)</span>
                            </label>
                            <label class="flex items-center gap-2 cursor-pointer">
                                <input type="radio" v-model="form.escopo" value="Ano_Etapa" class="accent-primary">
                                <span class="text-sm font-medium">Por Ano/Etapa</span>
                            </label>
                         </div>
                    </div>

                    <!-- Etapa Selector (Conditional) -->
                    <ManagerField 
                        v-if="form.escopo === 'Ano_Etapa'"
                        label="Selecione o Ano/Etapa" 
                        type="select" 
                        :model-value="form.id_ano_etapa ?? undefined"
                        @update:modelValue="form.id_ano_etapa = $event"
                        class="md:col-span-1"
                    >
                         <option value="" disabled>Selecione...</option>
                         <option v-for="ae in anosEtapa" :key="ae.id" :value="ae.id">{{ ae.nome }}</option>
                    </ManagerField>

                    <!-- Escola Selector (Optional, for segmentation) -->
                    <ManagerField 
                        v-if="form.escopo === 'Ano_Etapa'"
                        label="Escola (Opcional)" 
                        type="select" 
                        :model-value="form.id_escola ?? undefined"
                        @update:modelValue="form.id_escola = $event"
                        class="md:col-span-1"
                    >
                         <option value="">Todas as Escolas da Rede</option>
                         <option v-for="e in escolas" :key="e.id" :value="e.id">{{ e.nome }}</option>
                    </ManagerField>

                    <!-- Modelo -->
                    <ManagerField 
                        label="Modelo de Divisão" 
                        type="select" 
                        :model-value="form.id_modelo_calendario ?? undefined"
                        @update:modelValue="form.id_modelo_calendario = $event"
                        class="md:col-span-2"
                    >
                        <option value="" disabled>Selecione o modelo...</option>
                        <option v-for="m in modelos" :key="m.id" :value="m.id">{{ m.nome }}</option>
                    </ManagerField>
                </div>

                <!-- Periods Builder -->
                <div v-if="form.periodos.length > 0" class="flex flex-col gap-3">
                    <div class="text-xs font-bold text-secondary uppercase tracking-wider mb-1">Definição dos Períodos</div>
                    
                    <div 
                        v-for="(p, idx) in form.periodos" 
                        :key="idx"
                        class="grid grid-cols-12 gap-4 items-center bg-white dark:bg-surface p-3 rounded-lg border border-secondary/10 shadow-sm"
                    >
                        <div class="col-span-12 md:col-span-2 text-sm font-bold text-primary">
                            {{ p.numero }}º Período
                        </div>
                        <div class="col-span-6 md:col-span-5">
                            <ManagerField label="Início" type="date" v-model="p.data_inicio" />
                        </div>
                        <div class="col-span-6 md:col-span-5">
                            <ManagerField label="Fim" type="date" v-model="p.data_fim" />
                        </div>
                    </div>
                </div>

            </div>

            <!-- Footer -->
            <div class="p-4 border-t border-secondary/10 bg-white dark:bg-surface flex justify-end gap-2">
                <button 
                    @click="$emit('close')" 
                    class="px-4 py-2 text-sm font-bold text-secondary hover:bg-div-10 rounded transition-colors"
                >
                    Cancelar
                </button>
                <button 
                    @click="handleSave" 
                    :disabled="loading"
                    class="btn-primary px-6 py-2 rounded text-sm font-bold shadow-lg shadow-primary/20 disabled:opacity-50"
                >
                    {{ loading ? 'Salvando...' : 'Salvar Calendário' }}
                </button>
            </div>
        </div>
    </div>
</template>
