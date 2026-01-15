<script setup lang="ts">
const props = withDefaults(defineProps<{
    modelValue: {
        escola_id: string | null
        ano_etapa_id: string | null
        turma_id: string | null
    },
    showTurma?: boolean
}>(), {
    showTurma: true
})

import { useToastStore } from '@/stores/toast'
import { useAppStore } from '@/stores/app'

const emit = defineEmits(['update:modelValue', 'change'])

const client = useSupabaseClient()
const appStore = useAppStore()
const toast = useToastStore()

// Data Lists
const escolas = ref<any[]>([])
const anosEtapa = ref<any[]>([])
const turmas = ref<any[]>([])

// Loading States
const loading = ref({
    escolas: false,
    anos: false,
    turmas: false
})

// Fetch Escolas
const fetchEscolas = async () => {
    loading.value.escolas = true
    try {
        // Use generic API which maps to RPCs (safer for complex permissions/logic usually, though 'escolas' is a table)
        // If 'escolas' is not in API generic list, we use client.
        // Actually earlier 'escolas' wasn't in the generic list explicitly? 
        // Let's check [resource].get.ts. 'escolas' is NOT there. 'turmas', 'ano_etapa' ARE.
        // So for Escola we keep client.from OR add to generic. 
        // RLS for 'escolas' usually requires company_id.
        const { data, error } = await client
            .from('escolas')
            .select('id, nome')
            .eq('id_empresa', appStore.company?.empresa_id)
            .order('nome')
        
        if (error) throw error
        escolas.value = data || []
    } catch (error) {
        console.error('Erro ao buscar escolas:', error)
        toast.showToast('Erro ao carregar escolas', 'error')
    } finally {
        loading.value.escolas = false
    }
}

// Fetch Anos/Etapa
const fetchAnosEtapa = async () => {
    loading.value.anos = true
    try {
        // Use the API for ano_etapa as it calculates things or joins? 
        // In ModalGerenciarEvento we used /api/estrutura_academica/ano_etapa
        // Let's use that for consistency.
        const response: any = await $fetch('/api/estrutura_academica/ano_etapa', {
            params: {
                id_empresa: appStore.company?.empresa_id
            }
        })
        
        // API returns { items: [], ... } or just array? 
        // The generic GET returns { items, total, pages }
        anosEtapa.value = response.items || []

    } catch (error) {
         console.error('Erro ao buscar anos:', error)
         toast.showToast('Erro ao carregar anos', 'error')
    } finally {
        loading.value.anos = false
    }
}

// Fetch Turmas (Filtered)
const fetchTurmas = async () => {
    if (!props.modelValue.escola_id && !props.modelValue.ano_etapa_id) {
        turmas.value = []
        return
    }

    loading.value.turmas = true
    try {
        // Use our new generic API endpoint for 'turmas_simple'
        const { data, error } = await useFetch('/api/estrutura_academica/turmas_simple', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                id_escola: props.modelValue.escola_id,
                id_ano_etapa: props.modelValue.ano_etapa_id
            }
        })

        if (error.value) throw error.value
        turmas.value = (data.value as any)?.items || []
         
    } catch (error) {
        console.error('Erro ao buscar turmas:', error)
        toast.showToast('Erro ao carregar turmas', 'error')
    } finally {
        loading.value.turmas = false
    }
}

// Watchers
watch(() => props.modelValue.escola_id, () => {
    // Reset dependant fields
    emit('update:modelValue', { ...props.modelValue, turma_id: null })
    if (props.showTurma) fetchTurmas()
})

watch(() => props.modelValue.ano_etapa_id, () => {
    emit('update:modelValue', { ...props.modelValue, turma_id: null })
    if (props.showTurma) fetchTurmas()
})

// Initialize
onMounted(() => {
    fetchEscolas()
    fetchAnosEtapa()
    // If initial values exist, fetch turmas
    if ((props.modelValue.escola_id || props.modelValue.ano_etapa_id) && props.showTurma) {
        fetchTurmas()
    }
})

// Update helper
const updateField = (field: 'escola_id' | 'ano_etapa_id' | 'turma_id', value: any) => {
    // Convert empty string or the label text from select to null for UUID fields
    let finalValue = value
    if (field === 'turma_id' && (value === '' || value === 'Geral (Aplicar ao Ano/Etapa)')) {
        finalValue = null
    }

    const newValue = { ...props.modelValue, [field]: finalValue }
    emit('update:modelValue', newValue)
    emit('change', newValue)
}

</script>

<template>
    <div class="grid grid-cols-1 gap-4 mb-6" :class="showTurma ? 'md:grid-cols-3' : 'md:grid-cols-2'">
        <!-- Escola Selector -->
        <ManagerField 
            label="Escola" 
            type="select" 
            :model-value="modelValue.escola_id ?? undefined"
            @update:modelValue="(v: any) => updateField('escola_id', v)"
            :disabled="loading.escolas"
        >
            <option value="">Todas as Escolas</option>
            <option v-for="escola in escolas" :key="escola.id" :value="escola.id">
                {{ escola.nome }}
            </option>
        </ManagerField>

        <!-- Ano/Etapa Selector -->
        <ManagerField 
            label="Ano/Etapa" 
            type="select" 
            :model-value="modelValue.ano_etapa_id ?? undefined"
            @update:modelValue="(v: any) => updateField('ano_etapa_id', v)"
            :disabled="loading.anos"
        >
            <option value="">Todas as Etapas</option>
            <option v-for="ano in anosEtapa" :key="ano.id" :value="ano.id">
                {{ ano.nome }}
            </option>
        </ManagerField>

        <!-- Turma Selector -->
        <ManagerField 
            v-if="showTurma"
            label="Turma (Opcional)" 
            type="select" 
            :model-value="modelValue.turma_id ?? ''" 
            @update:modelValue="(v: any) => updateField('turma_id', v)"
            :disabled="(!modelValue.escola_id && !modelValue.ano_etapa_id) || loading.turmas"
        >
            <option value="">Geral (Aplicar ao Ano/Etapa)</option>
            <option v-if="turmas.length === 0" disabled>Nenhuma turma encontrada</option>
            <option v-for="turma in turmas" :key="turma.id" :value="turma.id">
                {{ turma.nome }}
            </option>
        </ManagerField>
    </div>
</template>
