<script setup>
import { ref, watch } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps({
    isOpen: Boolean,
    initialData: Object
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

// Options for Selects
const UNIT_OPTIONS = [
    { value: 'KG', label: 'Quilograma (KG)' },
    { value: 'GR', label: 'Gramas (GR)' },
    { value: 'LITRO', label: 'Litro (L)' },
    { value: 'ML', label: 'Mililitros (ML)' },
    { value: 'UNIDADE', label: 'Unidade (UN)' },
    { value: 'FARDO', label: 'Fardo' },
    { value: 'CX', label: 'Caixa' }
]

const CATEGORY_OPTIONS = [
    { value: 'Proteína', label: 'Proteína' },
    { value: 'Carboidrato', label: 'Carboidrato' },
    { value: 'Hortifruti', label: 'Hortifruti' },
    { value: 'Estocável', label: 'Estocável' },
    { value: 'Laticínios', label: 'Laticínios' },
    { value: 'Outros', label: 'Outros' }
]

const formData = ref({
    id: null,
    nome: '',
    unidade_medida: 'KG',
    categoria: 'Estocável',
    preco_medio: 0,
    ata_registro_ref: '',
    // Nutritional Info (Flattened for form)
    nutri_kcal: 0,
    nutri_carboidratos: 0,
    nutri_proteinas: 0,
    nutri_gorduras: 0,
    
    ativo: true
})
const isSaving = ref(false)
const errorMessage = ref('')

// Initialize form
const initForm = () => {
    if (props.initialData) {
        const nutri = props.initialData.valor_nutricional_100g || {}
        formData.value = { 
            id: props.initialData.id,
            nome: props.initialData.nome || '',
            unidade_medida: props.initialData.unidade_medida || 'KG',
            categoria: props.initialData.categoria || 'Estocável',
            preco_medio: props.initialData.preco_medio || 0,
            ata_registro_ref: props.initialData.ata_registro_ref || '',
            
            nutri_kcal: nutri.kcal || 0,
            nutri_carboidratos: nutri.carboidratos || 0,
            nutri_proteinas: nutri.proteinas || 0,
            nutri_gorduras: nutri.gorduras || 0,

            ativo: props.initialData.ativo ?? true
        }
    } else {
        formData.value = {
            id: null,
            nome: '',
            unidade_medida: 'KG',
            categoria: 'Estocável',
            preco_medio: 0,
            ata_registro_ref: '',
            nutri_kcal: 0,
            nutri_carboidratos: 0,
            nutri_proteinas: 0,
            nutri_gorduras: 0,
            ativo: true
        }
    }
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        initForm()
        errorMessage.value = ''
    }
})

const handleCancel = () => {
    emit('close')
}

const handleSave = async () => {
    if (!formData.value.nome.trim()) {
        errorMessage.value = 'O nome do alimento é obrigatório.'
        return
    }

    isSaving.value = true
    errorMessage.value = ''

    try {
        // Construct Nutritional JSONB
        const valor_nutricional_100g = {
            kcal: Number(formData.value.nutri_kcal),
            carboidratos: Number(formData.value.nutri_carboidratos),
            proteinas: Number(formData.value.nutri_proteinas),
            gorduras: Number(formData.value.nutri_gorduras)
        }

        const payload = {
            id: formData.value.id,
            nome: formData.value.nome,
            unidade_medida: formData.value.unidade_medida,
            categoria: formData.value.categoria,
            preco_medio: Number(formData.value.preco_medio),
            ata_registro_ref: formData.value.ata_registro_ref,
            valor_nutricional_100g: valor_nutricional_100g,
            ativo: formData.value.ativo
        }

        const { success, message, error } = await $fetch('/api/merenda/alimentos', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                payload: payload
            }
        })

        if (success) {
            toast.showToast('Alimento salvo com sucesso!')
            emit('success')
            emit('close')
        } else {
             if (error) throw new Error(message || 'Erro ao salvar.')
             toast.showToast('Alimento salvo com sucesso!')
             emit('success')
             emit('close')
        }

    } catch (err) {
        console.error('Erro ao salvar alimento:', err)
        errorMessage.value = err.data?.message || err.message || 'Erro ao comunicar com o servidor.'
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-6 text-sm">
            <!-- Backdrop -->
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="handleCancel"></div>
            
            <!-- Modal Content -->
            <div class="relative bg-background w-full max-w-2xl flex flex-col rounded shadow-2xl border border-secondary/10 overflow-hidden transform transition-all max-h-[90vh]">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-div-15 shrink-0">
                    <div>
                        <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Alimento' : 'Novo Alimento' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Cadastre ingredientes e seus detalhes nutricionais.</p>
                    </div>
                     <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body (Scrollable) -->
                <div class="p-6 overflow-y-auto">
                     <!-- Error Alert -->
                    <div v-if="errorMessage" class="p-4 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-xs flex items-start gap-2 mb-4">
                        <span>{{ errorMessage }}</span>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                        <ManagerField 
                            label="Nome do Alimento"
                            v-model="formData.nome"
                            placeholder="Ex: Arroz Branco, Feijão Carioca"
                            required
                            class="md:col-span-2"
                        />

                        <ManagerField 
                            label="Unidade de Medida"
                            v-model="formData.unidade_medida"
                            type="select"
                            :options="UNIT_OPTIONS"
                            required
                        />

                        <ManagerField 
                            label="Categoria"
                            v-model="formData.categoria"
                            type="select"
                            :options="CATEGORY_OPTIONS"
                            required
                        />

                        <ManagerField 
                            label="Preço Médio (R$)"
                            v-model="formData.preco_medio"
                            type="number"
                            step="0.01"
                            placeholder="0.00"
                        />

                        <ManagerField 
                            label="Ref. ATA de Registro (Opcional)"
                            v-model="formData.ata_registro_ref"
                            placeholder="Ex: ATA 123/2024"
                        />
                    </div>

                    <!-- Divider -->
                    <div class="border-t border-div-15 my-4 pt-4">
                        <div class="flex items-center gap-2 mb-4">
                            <span class="text-xs font-bold uppercase tracking-wider text-secondary">Informação Nutricional (por 100g)</span>
                            <div class="h-px bg-div-15 flex-1"></div>
                        </div>

                        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                            <ManagerField 
                                label="Kcal"
                                v-model="formData.nutri_kcal"
                                type="number"
                                placeholder="0"
                            />
                            <ManagerField 
                                label="Carboidratos (g)"
                                v-model="formData.nutri_carboidratos"
                                type="number"
                                step="0.1"
                                placeholder="0.0"
                            />
                            <ManagerField 
                                label="Proteínas (g)"
                                v-model="formData.nutri_proteinas"
                                type="number"
                                step="0.1"
                                placeholder="0.0"
                            />
                            <ManagerField 
                                label="Gorduras (g)"
                                v-model="formData.nutri_gorduras"
                                type="number"
                                step="0.1"
                                placeholder="0.0"
                            />
                        </div>
                    </div>
                </div>

                <!-- Footer -->
                <div class="px-6 py-4 border-t border-secondary/10 flex items-center justify-end gap-3 bg-div-15 shrink-0">
                    <button 
                        @click="handleCancel"
                        class="px-4 py-2 rounded text-secondary font-semibold hover:bg-div-30 transition-colors"
                    >
                        Cancelar
                    </button>
                    <button 
                        @click="handleSave"
                        :disabled="isSaving"
                        class="px-6 py-2 rounded bg-primary text-white font-bold hover:brightness-110 active:scale-95 disabled:opacity-50 transition-all flex items-center gap-2"
                    >
                        <span v-if="isSaving" class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></span>
                        {{ isSaving ? 'Salvando...' : 'Salvar' }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
