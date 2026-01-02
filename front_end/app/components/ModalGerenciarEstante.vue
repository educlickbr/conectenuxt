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

const formData = ref({ nome: '', sala_uuid: null, predio_uuid: null, escola_id: null })
const isSaving = ref(false)
const errorMessage = ref('')

const escolas = ref([])
const fetchEscolas = async () => {
    if (!appStore.company?.empresa_id) return
    try {
        const { data } = await useFetch('/api/infra/escolas', { query: { id_empresa: appStore.company.empresa_id, limite: 100 } })
        escolas.value = data.value?.items || []
    } catch (err) { console.error(err) }
}

// --- Predio Logic ---
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
                id_escola: formData.value.escola_id 
            } 
        })
        predios.value = res.items || []
    } catch (e) { console.error(e) }
}

// --- Sala Logic ---
const salas = ref([])
const selectedSalaName = ref('')
const fetchSalas = async () => {
    if (!formData.value.predio_uuid) {
        salas.value = []
        return
    }
    try {
        const res = await $fetch('/api/infra/salas', { 
            query: { 
                id_empresa: appStore.company.empresa_id, 
                pagina: 1, 
                limite: 100, 
                predio_uuid: formData.value.predio_uuid 
            } 
        })
        salas.value = res.items || []
    } catch (e) { console.error(e) }
}

const onEscolaChange = async () => {
    formData.value.predio_uuid = null
    formData.value.sala_uuid = null
    selectedPredioName.value = ''
    selectedSalaName.value = ''
    await fetchPredios()
    salas.value = []
}

const onPredioChange = async () => {
    formData.value.sala_uuid = null
    selectedSalaName.value = ''
    await fetchSalas()
}

watch(() => props.isOpen, async (newVal) => {
    if (newVal) {
        await fetchEscolas()
        if (props.initialData) {
            formData.value = { ...props.initialData }
            selectedPredioName.value = props.initialData.predio_nome || props.initialData.nome_predio || props.initialData.predio?.nome || 'Prédio Selecionado'
            selectedSalaName.value = props.initialData.sala_nome || props.initialData.nome_sala || props.initialData.sala?.nome || 'Sala Selecionada'
            
            // Fetch cascading data if needed
            if (formData.value.escola_id) await fetchPredios()
            if (formData.value.predio_uuid) await fetchSalas()
        } else {
            formData.value = { nome: '', sala_uuid: null, predio_uuid: null, escola_id: null }
            selectedPredioName.value = ''
            selectedSalaName.value = ''
            predios.value = []
            salas.value = []
        }
    }
})

const handleSave = async () => {
    if (!formData.value.sala_uuid || !formData.value.nome?.trim()) return errorMessage.value = 'Preencha todos os campos.'
    isSaving.value = true
    try {
        const res = await $fetch('/api/infra/estantes', { 
            method: 'POST', 
            body: { id_empresa: appStore.company.empresa_id, data: formData.value } 
        })
        if (res && res.success) {
            toast.showToast('Estante salva com sucesso!')
            emit('success')
            emit('close')
        } else {
            errorMessage.value = res?.message || 'Erro ao salvar estante.'
        }
    } catch (e) { 
        errorMessage.value = e.statusMessage || 'Erro ao salvar.' 
    } finally { 
        isSaving.value = false 
    }
}
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="$emit('close')"></div>
            <div class="relative bg-background w-full max-w-lg rounded shadow-2xl overflow-hidden border border-secondary/10">
                <div class="px-6 py-4 bg-div-15 border-b border-secondary/10 flex justify-between items-center">
                    <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Estante' : 'Nova Estante' }}</h2>
                    <button @click="$emit('close')" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>
                <div class="p-6 flex flex-col gap-5">
                    <div v-if="errorMessage" class="p-4 rounded bg-red-500/5 border border-red-500/20 text-red-500 text-sm flex items-start gap-3">
                         <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 mt-0.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                        <span>{{ errorMessage }}</span>
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
                        <div v-if="formData.predio_uuid && selectedPredioName" class="flex items-center gap-2 p-3 bg-primary/5 border border-primary/20 rounded">
                            <span class="flex-1 text-sm font-bold text-text">{{ selectedPredioName }}</span>
                            <button @click="formData.predio_uuid = null; formData.sala_uuid = null; selectedPredioName = ''; selectedSalaName = ''; fetchPredios()" class="p-1.5 rounded hover:bg-red-500/10 text-red-500 transition-colors" title="Trocar">
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
                                onPredioChange();
                            }"
                        />
                    </div>

                    <div class="flex flex-col gap-1.5">
                        <label class="text-[10px] font-black text-secondary uppercase tracking-[0.15em] ml-1">Sala</label>
                        <div v-if="formData.sala_uuid && selectedSalaName" class="flex items-center gap-2 p-3 bg-primary/5 border border-primary/20 rounded">
                            <span class="flex-1 text-sm font-bold text-text">{{ selectedSalaName }}</span>
                            <button @click="formData.sala_uuid = null; selectedSalaName = ''; fetchSalas()" class="p-1.5 rounded hover:bg-red-500/10 text-red-500 transition-colors" title="Trocar">
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                            </button>
                        </div>
                        <ManagerField
                            v-else
                            v-model="formData.sala_uuid"
                            type="select"
                            placeholder="Selecione a sala..."
                            :disabled="!formData.predio_uuid"
                            :options="salas.map(s => ({ value: s.uuid, label: s.nome }))"
                            @change="(val) => {
                                const s = salas.find(x => x.uuid === val);
                                if (s) selectedSalaName = s.nome;
                            }"
                        />
                    </div>

                    <ManagerField
                        v-model="formData.nome"
                        label="Nome da Estante"
                        required
                        placeholder="Ex: Estante 01..."
                    />
                </div>
                <div class="px-6 py-4 bg-div-15 border-t border-secondary/10 flex justify-end gap-3">
                    <button @click="$emit('close')" class="px-5 py-2.5 rounded text-secondary font-semibold text-sm hover:bg-div-30 transition-colors">Cancelar</button>
                    <button @click="handleSave" :disabled="isSaving" class="px-8 py-2.5 bg-primary text-white font-bold rounded shadow-lg shadow-primary/20 hover:brightness-110 active:scale-95 transition-all text-sm">
                        {{ isSaving ? 'Salvando...' : 'Salvar Estante' }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
