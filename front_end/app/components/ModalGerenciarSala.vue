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

const formData = ref({ nome: '', predio_uuid: null, escola_id: null })
const isSaving = ref(false)
const errorMessage = ref('')

const escolas = ref([])
const fetchEscolas = async () => {
    if (!appStore.company?.empresa_id) return
    try {
        const { data } = await useFetch('/api/infra/escolas', {
          query: { 
            id_empresa: appStore.company.empresa_id,
            limite: 100
          }
        })
        escolas.value = data.value?.items || []
    } catch (err) { console.error(err) }
}

// Cascading Logic for Predio
const predios = ref([])
const selectedPredioName = ref('')

const fetchPredios = async () => {
    if (!formData.value.escola_id) {
        predios.value = []
        return
    }
    try {
        const res = await $fetch('/api/infra/predios', {
            query: {
                id_empresa: appStore.company.empresa_id,
                pagina: 1,
                limite: 100,
                id_escola: formData.value.escola_id // Correct parameter name for BFF
            }
        })
        predios.value = res.items || []
    } catch (e) { console.error(e) }
}

const onEscolaChange = async () => {
    formData.value.predio_uuid = null
    selectedPredioName.value = ''
    await fetchPredios()
}

watch(() => props.isOpen, async (newVal) => {
    if (newVal) {
        await fetchEscolas()
        if (props.initialData) {
            formData.value = { 
                nome: props.initialData.nome,
                predio_uuid: props.initialData.predio_uuid,
                escola_id: props.initialData.escola_id 
            }
            selectedPredioName.value = props.initialData.predio_nome || props.initialData.nome_predio || props.initialData.predio?.nome || 'Prédio Selecionado'
            // If we have a school but no building list yet, fetch it
            if (formData.value.escola_id) await fetchPredios()
        } else {
            formData.value = { nome: '', predio_uuid: null, escola_id: null }
            selectedPredioName.value = ''
            predios.value = []
        }
        errorMessage.value = ''
    }
})

const handleSave = async () => {
    errorMessage.value = ''
    if (!formData.value.escola_id) return errorMessage.value = 'Selecione uma Escola.'
    if (!formData.value.predio_uuid) return errorMessage.value = 'Selecione um Prédio.'
    if (!formData.value.nome?.trim()) return errorMessage.value = 'Nome da Sala é obrigatório.'

    isSaving.value = true
    try {
        const payload = { 
            uuid: props.initialData?.uuid,
            nome: formData.value.nome,
            predio_uuid: formData.value.predio_uuid
        }
        const res = await $fetch('/api/infra/salas', {
            method: 'POST',
            body: { id_empresa: appStore.company.empresa_id, data: payload }
        })

        if (res && res.success) {
            toast.showToast('Sala salva com sucesso!')
            emit('success')
            emit('close')
        } else {
            errorMessage.value = res?.message || 'Erro ao salvar sala.'
        }
    } catch (err) {
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
            
            <div class="relative bg-background w-full max-w-lg rounded shadow-2xl border border-[#6B82A71A] overflow-hidden transform transition-all">
                <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between bg-div-15">
                    <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Sala' : 'Nova Sala' }}</h2>
                    <button @click="$emit('close')" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <div class="p-6 flex flex-col gap-5">
                    <div v-if="errorMessage" class="p-4 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-sm">
                        {{ errorMessage }}
                    </div>

                    <ManagerField
                        v-model="formData.escola_id"
                        label="Escola"
                        type="select"
                        placeholder="Selecione uma escola..."
                        :options="escolas.map(e => ({ value: e.id, label: e.nome }))"
                        @change="onEscolaChange"
                    />

                    <div class="flex flex-col gap-1.5">
                        <label class="text-[10px] font-black text-secondary uppercase tracking-[0.15em] ml-1">Prédio</label>
                        <div v-if="formData.predio_uuid && selectedPredioName" class="flex items-center gap-2 p-3 bg-[#3571CB0D] border border-[#3571CB33] rounded">
                            <span class="flex-1 text-sm font-bold text-text">{{ selectedPredioName }}</span>
                            <button @click="formData.predio_uuid = null; fetchPredios()" class="p-1.5 rounded hover:bg-red-500/10 text-red-500 transition-colors" title="Trocar">
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                            </button>
                        </div>
                        <ManagerField
                            v-else
                            v-model="formData.predio_uuid"
                            type="select"
                            placeholder="Selecione o prédio..."
                            :disabled="!formData.escola_id"
                            :options="predios.map(p => ({ value: p.uuid, label: p.nome }))"
                            @change="(val) => { 
                                const p = predios.find(x => x.uuid === val); 
                                if (p) selectedPredioName = p.nome;
                            }"
                        />
                    </div>

                    <ManagerField
                        v-model="formData.nome"
                        label="Nome da Sala"
                        required
                        placeholder="Ex: Sala 101, Auditório..."
                    />
                </div>

                <div class="px-6 py-4 border-t border-[#6B82A71A] flex items-center justify-end gap-3 bg-div-15">
                    <button @click="$emit('close')" class="px-5 py-2.5 rounded text-secondary font-semibold text-sm hover:bg-div-30">Cancelar</button>
                    <button @click="handleSave" :disabled="isSaving" class="px-8 py-2.5 rounded bg-primary text-white font-bold text-sm shadow-lg shadow-primary/20">
                        {{ isSaving ? 'Salvando...' : 'Salvar Sala' }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
