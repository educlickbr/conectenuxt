<script setup>
import { ref, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps({
    isOpen: { type: Boolean, default: false },
    initialData: { type: Object, default: null }
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

const formData = ref({ nome: '', id_escola: null })
const isSaving = ref(false)
const errorMessage = ref('')
const escolas = ref([])
const isLoadingEscolas = ref(false)

const fetchEscolas = async () => {
    if (!appStore.company?.empresa_id) return
    isLoadingEscolas.value = true
    try {
        const res = await $fetch('/api/infra/escolas', {
          query: { 
            id_empresa: appStore.company.empresa_id,
            limite: 100
          }
        })
        escolas.value = res.items || []
    } catch (err) {
        console.error('Erro ao buscar escolas:', err)
    } finally {
        isLoadingEscolas.value = false
    }
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        fetchEscolas()
        if (props.initialData) {
            formData.value = { ...props.initialData }
        } else {
            formData.value = { nome: '', id_escola: null }
        }
        errorMessage.value = ''
    }
})

const handleSave = async () => {
    errorMessage.value = ''
    if (!formData.value.nome || !formData.value.nome.trim()) {
        errorMessage.value = 'O campo "Nome" é obrigatório.'
        return
    }

    isSaving.value = true
    try {
        const payload = {
            uuid: formData.value.uuid || null,
            nome: formData.value.nome,
            id_escola: formData.value.id_escola || null
        }
        
        const res = await $fetch('/api/infra/predios', {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload
            }
        })

        if (res && res.success) {
            toast.showToast('Prédio salvo com sucesso!')
            emit('success')
            emit('close')
        } else {
            errorMessage.value = res?.message || 'Erro ao salvar prédio.'
        }
    } catch (err) {
        console.error('Erro ao salvar prédio:', err)
        errorMessage.value = err.statusMessage || 'Erro ao salvar.'
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="$emit('close')"></div>
            
            <div class="relative bg-background w-full max-w-lg rounded shadow-2xl border border-secondary/10 overflow-hidden transform transition-all">
                <!-- Header -->
                <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-div-15">
                    <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Prédio' : 'Novo Prédio' }}</h2>
                    <button @click="$emit('close')" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="p-6 flex flex-col gap-5">
                    <div v-if="errorMessage" class="p-4 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-sm flex items-start gap-3">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 mt-0.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                        <span>{{ errorMessage }}</span>
                    </div>

                    <ManagerField
                        v-model="formData.id_escola"
                        label="Escola"
                        type="select"
                        placeholder="Selecione uma escola..."
                        :options="escolas.map(e => ({ value: e.id, label: e.nome }))"
                    />

                    <ManagerField
                        v-model="formData.nome"
                        label="Nome do Prédio"
                        required
                        placeholder="Ex: Bloco A, Ala Norte..."
                    />
                </div>

                <!-- Footer -->
                <div class="px-6 py-4 border-t border-secondary/10 flex items-center justify-end gap-3 bg-div-15">
                    <button @click="$emit('close')" class="px-5 py-2.5 rounded text-secondary font-semibold text-sm hover:bg-div-30 transition-colors">Cancelar</button>
                    <button 
                        @click="handleSave" 
                        :disabled="isSaving" 
                        class="px-8 py-2.5 rounded bg-primary text-white font-bold text-sm hover:brightness-110 active:scale-95 disabled:opacity-50 disabled:active:scale-100 transition-all flex items-center gap-2 shadow-lg shadow-primary/20"
                    >
                        <svg v-if="isSaving" class="animate-spin w-4 h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                        {{ isSaving ? 'Salvando...' : 'Salvar Prédio' }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
