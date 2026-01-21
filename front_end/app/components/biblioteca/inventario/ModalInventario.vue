<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps<{
    isOpen: boolean
    edicao: any // The edition object
}>()

const emit = defineEmits(['close'])
const appStore = useAppStore()
const toast = useToastStore()

// Data
const copies = ref<any[]>([])
const loading = ref(false)
const showForm = ref(false)
const editingId = ref<string | null>(null)

// Form Data
const formData = ref({
    status_copia: 'Disponível',
    doacao_ou_compra: 'Compra',
    avaria_flag: false,
    descricao_avaria: '',
    quantidade: 1,
    id_escola: '',
    predio_uuid: '',
    sala_uuid: '',
    estante_uuid: '',
    registro_bibliotecario: ''
})

// Location Options
const schools = ref<any[]>([])
const buildings = ref<any[]>([])
const rooms = ref<any[]>([])
const shelves = ref<any[]>([])

// Enums
const statusOptions = ['Disponível', 'Emprestado', 'Manutenção', 'Extraviado', 'Reservado', 'Perdido'].map(opt => ({ label: opt, value: opt }))
const originOptions = ['Compra', 'Doação'].map(opt => ({ label: opt, value: opt }))

// Fetch Data
const fetchCopies = async () => {
    if (!props.edicao) return
    loading.value = true
    try {
        const { data } = await useFetch('/api/biblioteca/inventario/copias', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                edicao_uuid: props.edicao.id_edicao || props.edicao.uuid, // Handle legacy vs new id prop
                limit: 100
            }
        })
        const result = (data.value as any) || {}
        copies.value = result.items || []
    } catch (e: any) {
        toast.showToast('Erro ao buscar cópias', 'error')
    } finally {
        loading.value = false
    }
}

// Location Fetchers
const fetchSchools = async () => {
    try {
        const data: any = await $fetch('/api/biblioteca/localizacao/escolas', {
            params: { id_empresa: appStore.company?.empresa_id }
        })
        schools.value = data || []
    } catch (e) {}
}

const fetchBuildings = async (schoolId: string) => {
    try {
        const data: any = await $fetch('/api/biblioteca/localizacao/predios', {
            params: { id_empresa: appStore.company?.empresa_id, parent_id: schoolId }
        })
        buildings.value = data || []
    } catch (e) {}
}

const fetchRooms = async (buildingId: string) => {
    try {
        const data: any = await $fetch('/api/biblioteca/localizacao/salas', {
            params: { id_empresa: appStore.company?.empresa_id, parent_id: buildingId }
        })
        rooms.value = data || []
    } catch (e) {}
}

const fetchShelves = async (roomId: string) => {
    try {
        const data: any = await $fetch('/api/biblioteca/localizacao/estantes', {
            params: { id_empresa: appStore.company?.empresa_id, parent_id: roomId }
        })
        shelves.value = data || []
    } catch (e) {}
}

// Watchers
watch(() => props.isOpen, (newVal) => {
    if (newVal && props.edicao) {
        fetchCopies()
        fetchSchools()
        resetForm()
    }
})

watch(() => formData.value.id_escola, (newVal) => {
    buildings.value = []
    rooms.value = []
    shelves.value = []
    formData.value.predio_uuid = ''
    formData.value.sala_uuid = ''
    formData.value.estante_uuid = ''
    if (newVal) fetchBuildings(newVal)
})

watch(() => formData.value.predio_uuid, (newVal) => {
    rooms.value = []
    shelves.value = []
    formData.value.sala_uuid = ''
    formData.value.estante_uuid = ''
    if (newVal) fetchRooms(newVal)
})

watch(() => formData.value.sala_uuid, (newVal) => {
    shelves.value = []
    formData.value.estante_uuid = ''
    if (newVal) fetchShelves(newVal)
})

// Actions
const resetForm = () => {
    formData.value = {
        status_copia: 'Disponível',
        doacao_ou_compra: 'Compra',
        avaria_flag: false,
        descricao_avaria: '',
        quantidade: 1,
        id_escola: '',
        predio_uuid: '',
        sala_uuid: '',
        estante_uuid: '',
        registro_bibliotecario: ''
    }
    editingId.value = null
}

const handleEdit = async (copy: any) => {
    editingId.value = copy.id_copia
    
    // Load hierarchy
    if (schools.value.length === 0) await fetchSchools()
    formData.value.id_escola = copy.id_escola
    
    if (copy.id_escola) await fetchBuildings(copy.id_escola)
    formData.value.predio_uuid = copy.id_predio
    
    if (copy.id_predio) await fetchRooms(copy.id_predio)
    formData.value.sala_uuid = copy.id_sala
    
    if (copy.id_sala) await fetchShelves(copy.id_sala)
    formData.value.estante_uuid = copy.id_estante
    
    formData.value.status_copia = copy.status_copia
    formData.value.doacao_ou_compra = copy.doacao_ou_compra
    formData.value.avaria_flag = copy.avaria_flag
    formData.value.descricao_avaria = copy.descricao_avaria || ''
    formData.value.registro_bibliotecario = copy.registro_bibliotecario || ''
    formData.value.quantidade = 1 
    
    showForm.value = true
}

const handleSave = async () => {
    if (!formData.value.estante_uuid) {
        toast.showToast('Selecione uma estante', 'error')
        return
    }

    try {
        const payload = {
            id_empresa: appStore.company?.empresa_id,
            edicao_uuid: props.edicao.id_edicao || props.edicao.uuid,
            estante_uuid: formData.value.estante_uuid,
            status_copia: formData.value.status_copia,
            doacao_ou_compra: formData.value.doacao_ou_compra,
            avaria_flag: formData.value.avaria_flag,
            descricao_avaria: formData.value.avaria_flag ? formData.value.descricao_avaria : null,
            quantidade: editingId.value ? 1 : formData.value.quantidade,
            uuid: editingId.value,
            registro_bibliotecario: editingId.value ? formData.value.registro_bibliotecario : null
        }

        await $fetch('/api/biblioteca/inventario/copias', {
            method: 'POST',
            body: payload
        })
        
        toast.showToast(editingId.value ? 'Cópia atualizada' : 'Cópias geradas', 'success')
        fetchCopies()
        resetForm()
        showForm.value = false
        
    } catch (e: any) {
        toast.showToast(e.message || 'Erro ao salvar.', 'error')
    }
}

const toggleDelete = async (copy: any) => {
    const originalState = copy.soft_delete
    // Optimistic update
    copy.soft_delete = !originalState
    
    try {
        const payload = {
            id_empresa: appStore.company?.empresa_id,
            edicao_uuid: props.edicao.id_edicao || props.edicao.uuid,
            estante_uuid: copy.id_estante,
            status_copia: copy.status_copia,
            doacao_ou_compra: copy.doacao_ou_compra,
            avaria_flag: copy.avaria_flag,
            descricao_avaria: copy.descricao_avaria,
            quantidade: 1,
            uuid: copy.id_copia,
            registro_bibliotecario: copy.registro_bibliotecario,
            soft_delete: copy.soft_delete // Send the new state
        }
        
        await $fetch('/api/biblioteca/inventario/copias', {
            method: 'POST',
            body: payload
        })
        
        toast.showToast(copy.soft_delete ? 'Cópia removida' : 'Cópia restaurada', 'success')
        await fetchCopies() // Ensure we sync with server

    } catch (e: any) {
        // Revert on error
        copy.soft_delete = originalState
        toast.showToast('Erro ao atualizar status', 'error')
    }
}

const handleCancel = () => {
    emit('close')
}
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 md:p-6">
            <!-- Backdrop -->
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="handleCancel"></div>
            
            <div class="relative bg-background w-full max-w-5xl h-[85vh] rounded shadow-2xl border border-[#6B82A71A] flex flex-col overflow-hidden animate-in zoom-in-95 duration-200">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between bg-div-15">
                    <div>
                        <h2 class="text-xl font-bold text-text">Gerenciar Inventário</h2>
                        <p class="text-xs text-secondary mt-0.5" v-if="edicao">
                            {{ edicao.titulo_principal }} - {{ edicao.editora || 'Editora N/A' }}
                        </p>
                    </div>
                    <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body (Split View) -->
                <div class="flex-1 overflow-hidden flex flex-col lg:flex-row bg-surface">
                    
                    <!-- Left: List -->
                    <div class="flex-1 flex flex-col border-r border-[#6B82A71A] min-w-0 bg-surface">
                        <div class="p-3 border-b border-[#6B82A71A] flex justify-between items-center bg-div-05/30">
                            <span class="text-xs font-bold text-secondary uppercase tracking-wider pl-2">Cópias Existentes</span>
                            <div class="flex gap-2">
                                <button @click="fetchCopies" class="p-2 text-secondary hover:text-primary transition-colors" title="Atualizar">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 4v6h-6"></path><path d="M1 20v-6h6"></path><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
                                </button>
                                <button v-if="!showForm" @click="showForm = true" class="text-xs bg-primary text-white px-3 py-1.5 rounded font-medium shadow-sm hover:brightness-110 transition-all">
                                    Nova Cópia
                                </button>
                            </div>
                        </div>

                        <div class="flex-1 overflow-y-auto p-4 space-y-3">
                            <div v-if="loading && copies.length === 0" class="flex flex-col items-center justify-center p-8 text-secondary gap-3">
                                <div class="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                                <span class="text-xs">Carregando...</span>
                            </div>
                            <div v-else-if="copies.length === 0" class="text-center p-8 text-secondary text-sm border-2 border-dashed border-[#6B82A71A] rounded-lg bg-div-05/50">
                                Nenhuma cópia registrada.
                            </div>
                            
                            <div 
                                v-for="copy in copies" 
                                :key="copy.id_copia"
                                class="bg-card p-3 rounded-lg border border-[#6B82A71A] hover:border-primary/30 transition-all group flex items-start gap-3 relative shadow-sm"
                                :class="{'opacity-60 grayscale bg-red-50/10': copy.soft_delete}"
                            >
                                <!-- Status Indicator -->
                                <div class="w-1 self-stretch rounded-full flex-shrink-0 my-1"
                                    :class="{
                                        'bg-success': copy.status_copia === 'Disponível' && !copy.soft_delete,
                                        'bg-warning': copy.status_copia === 'Emprestado' && !copy.soft_delete,
                                        'bg-danger': (copy.status_copia === 'Extraviado' || copy.status_copia === 'Perdido') && !copy.soft_delete,
                                        'bg-secondary': copy.soft_delete
                                    }"
                                ></div>

                                <div class="flex-1 min-w-0">
                                    <div class="flex items-center gap-2 mb-1">
                                        <span class="font-mono text-[10px] font-bold bg-div-15 px-1.5 py-0.5 rounded text-text">{{ copy.registro_bibliotecario || 'S/ Registro' }}</span>
                                        <span v-if="copy.soft_delete" class="text-[10px] bg-red-500/10 text-red-500 px-1 rounded font-bold uppercase">Removido</span>
                                        <span class="text-[10px] text-secondary ml-auto uppercase tracking-wider font-medium">{{ copy.doacao_ou_compra }}</span>
                                    </div>
                                    
                                    <div class="text-xs text-text flex items-center gap-1.5 py-1">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-secondary shrink-0"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                                        <span class="truncate leading-normal">{{ copy.nome_escola }} &raquo; {{ copy.nome_predio }} &raquo; {{ copy.nome_sala }} &raquo; {{ copy.nome_estante }}</span>
                                    </div>

                                    <div v-if="copy.avaria_flag" class="mt-2 text-xs bg-red-500/5 text-red-500 p-2 rounded border border-red-500/10 flex items-start gap-2">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                                        {{ copy.descricao_avaria }}
                                    </div>
                                </div>

                                <div class="flex flex-col gap-1 items-end pl-2 ml-2">
                                    <button @click="handleEdit(copy)" class="p-1.5 text-secondary hover:text-primary hover:bg-primary/5 rounded transition-colors" title="Editar">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                    </button>
                                    <button @click="toggleDelete(copy)" 
                                        class="p-1.5 text-secondary hover:bg-div-15 rounded transition-colors"
                                        :class="copy.soft_delete ? 'text-green-500 hover:text-green-600' : 'text-red-500 hover:text-red-600'" 
                                        :title="copy.soft_delete ? 'Restaurar' : 'Remover'"
                                    >
                                        <svg v-if="copy.soft_delete" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
                                        <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right: Form -->
                    <div v-if="showForm" class="w-full lg:w-96 bg-div-05/30 flex flex-col border-l border-[#6B82A71A] shadow-xl overflow-y-auto">
                        <div class="p-4 border-b border-[#6B82A71A] flex justify-between items-center bg-div-15">
                            <span class="font-bold text-text text-sm">{{ editingId ? 'Editar Cópia' : 'Adicionar Cópia' }}</span>
                            <button @click="showForm = false" class="text-secondary hover:text-text">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                            </button>
                        </div>
                        
                        <div class="p-5 space-y-5 flex-1">
                            
                            <!-- Location Cascade -->
                            <div class="space-y-4">
                                <div class="flex items-center gap-2 mb-2">
                                    <div class="h-px bg-div-15 flex-1"></div>
                                    <span class="text-[10px] font-bold text-secondary uppercase tracking-wider">Localização</span>
                                    <div class="h-px bg-div-15 flex-1"></div>
                                </div>
                                
                                <ManagerField
                                    v-model="formData.id_escola"
                                    type="select"
                                    label="Escola"
                                    placeholder="Selecione a Escola"
                                    :options="schools.map(s => ({ label: s.nome, value: s.id }))"
                                />

                                <ManagerField
                                    v-model="formData.predio_uuid"
                                    type="select"
                                    label="Prédio"
                                    placeholder="Selecione o Prédio"
                                    :options="buildings.map(b => ({ label: b.nome, value: b.uuid }))"
                                    :disabled="!formData.id_escola"
                                />

                                <ManagerField
                                    v-model="formData.sala_uuid"
                                    type="select"
                                    label="Sala"
                                    placeholder="Selecione a Sala"
                                    :options="rooms.map(r => ({ label: r.nome, value: r.uuid }))"
                                    :disabled="!formData.predio_uuid"
                                />

                                <ManagerField
                                    v-model="formData.estante_uuid"
                                    type="select"
                                    label="Estante *"
                                    placeholder="Selecione a Estante"
                                    :options="shelves.map(s => ({ label: s.nome, value: s.uuid }))"
                                    :disabled="!formData.sala_uuid"
                                    :required="true"
                                />
                            </div>

                            <!-- Details -->
                            <div class="space-y-4">
                                <div class="flex items-center gap-2 mb-2">
                                    <div class="h-px bg-div-15 flex-1"></div>
                                    <span class="text-[10px] font-bold text-secondary uppercase tracking-wider">Detalhes</span>
                                    <div class="h-px bg-div-15 flex-1"></div>
                                </div>

                                <ManagerField
                                    v-model="formData.doacao_ou_compra"
                                    type="select"
                                    label="Origem"
                                    :options="originOptions"
                                />
                                
                                <ManagerField
                                    v-model="formData.status_copia"
                                    type="select"
                                    label="Status Inicial"
                                    :options="statusOptions"
                                />

                                <ManagerField
                                    v-if="!editingId"
                                    v-model="formData.quantidade"
                                    type="number"
                                    label="Quantidade de Cópias"
                                    placeholder="1"
                                    min="1"
                                    max="100"
                                />
                                <p v-if="!editingId" class="text-[10px] text-secondary -mt-3 ml-1">Cria múltiplas cópias idênticas.</p>

                                <ManagerField
                                    v-if="editingId"
                                    v-model="formData.registro_bibliotecario"
                                    label="Registro (Código)"
                                    placeholder="Ex: LIV-001"
                                />

                                <div class="bg-red-500/5 p-3 rounded border border-red-500/10">
                                    <label class="flex items-center gap-2 cursor-pointer mb-2 select-none">
                                        <input type="checkbox" v-model="formData.avaria_flag" class="accent-red-500 w-4 h-4 rounded">
                                        <span class="text-xs font-bold text-red-500 uppercase tracking-wider">Possui Avaria?</span>
                                    </label>
                                    <ManagerField
                                        v-if="formData.avaria_flag"
                                        v-model="formData.descricao_avaria"
                                        label="Descrição da Avaria"
                                        placeholder="Descreva o dano..."
                                    />
                                </div>
                            </div>

                        </div>
                        
                        <div class="p-4 bg-div-15 border-t border-[#6B82A71A] flex justify-end gap-3 shrink-0">
                             <button @click="resetForm" class="px-4 py-2 rounded text-secondary font-bold text-xs hover:bg-div-30 transition-colors mr-auto">Limpar</button>
                             <button @click="handleSave" class="px-6 py-2.5 rounded bg-primary text-white font-bold hover:brightness-110 active:scale-95 transition-all text-sm shadow-lg shadow-primary/20">
                                 Salvar
                             </button>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </Teleport>
</template>

