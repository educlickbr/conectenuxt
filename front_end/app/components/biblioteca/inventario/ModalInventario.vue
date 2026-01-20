<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'

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
const statusOptions = ['Disponível', 'Emprestado', 'Manutenção', 'Extraviado', 'Reservado', 'Perdido']
const originOptions = ['Compra', 'Doação']

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
            soft_delete: !copy.soft_delete
        }
        
        await $fetch('/api/biblioteca/inventario/copias', {
            method: 'POST',
            body: payload
        })
        
        toast.showToast(copy.soft_delete ? 'Cópia restaurada' : 'Cópia removida', 'success')
        fetchCopies()

    } catch (e: any) {
        toast.showToast('Erro ao atualizar status', 'error')
    }
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
        <div class="bg-surface w-full max-w-5xl h-[85vh] rounded-xl shadow-2xl border border-div-15 flex flex-col overflow-hidden animate-in zoom-in-95 duration-200">
            
            <!-- Header -->
            <div class="bg-div-05 p-4 border-b border-div-15 flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center font-bold text-xl">
                        📦
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-text leading-tight">Gerenciar Inventário</h2>
                        <p class="text-xs text-secondary" v-if="edicao">
                            {{ edicao.titulo_principal }} - {{ edicao.editora || 'Editora N/A' }}
                        </p>
                    </div>
                </div>
                <button @click="$emit('close')" class="p-2 hover:bg-div-15 rounded-lg text-secondary transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Body (Split View) -->
            <div class="flex-1 overflow-hidden flex flex-col lg:flex-row">
                
                <!-- Left: List -->
                <div class="flex-1 flex flex-col border-r border-div-15 min-w-0 bg-surface">
                    <div class="p-3 border-b border-div-15 flex justify-between items-center bg-div-05/50">
                        <span class="text-xs font-bold text-secondary uppercase tracking-wider">Cópias Existentes</span>
                        <div class="flex gap-2">
                             <button @click="fetchCopies" class="p-1 text-secondary hover:text-primary" title="Atualizar">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 4v6h-6"></path><path d="M1 20v-6h6"></path><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
                             </button>
                             <button v-if="!showForm" @click="showForm = true" class="text-xs bg-primary text-white px-3 py-1.5 rounded-md font-medium shadow-sm hover:bg-primary-hover transition-colors">
                                Nova Cópia
                             </button>
                        </div>
                    </div>

                    <div class="flex-1 overflow-y-auto p-3 space-y-2">
                        <div v-if="loading && copies.length === 0" class="text-center p-8 text-secondary text-sm">Carregando...</div>
                        <div v-else-if="copies.length === 0" class="text-center p-8 text-secondary text-sm border-2 border-dashed border-div-15 rounded-lg">Nenhuma cópia registrada.</div>
                        
                        <div 
                            v-for="copy in copies" 
                            :key="copy.id_copia"
                            class="bg-div-05/30 p-3 rounded-lg border border-div-15 hover:border-primary/30 transition-all group flex items-start gap-3 relative"
                            :class="{'opacity-60 grayscale bg-red-50/10': copy.soft_delete}"
                        >
                            <!-- Status Indicator -->
                            <div class="w-1.5 self-stretch rounded-full flex-shrink-0"
                                :class="{
                                    'bg-success': copy.status_copia === 'Disponível' && !copy.soft_delete,
                                    'bg-warning': copy.status_copia === 'Emprestado' && !copy.soft_delete,
                                    'bg-danger': (copy.status_copia === 'Extraviado' || copy.status_copia === 'Perdido') && !copy.soft_delete,
                                    'bg-secondary': copy.soft_delete
                                }"
                            ></div>

                            <div class="flex-1 min-w-0">
                                <div class="flex items-center gap-2 mb-1">
                                    <span class="font-mono text-xs font-bold bg-surface px-1.5 py-0.5 rounded border border-div-15">{{ copy.registro_bibliotecario }}</span>
                                    <span v-if="copy.soft_delete" class="text-[10px] bg-danger/10 text-danger px-1 rounded font-bold uppercase">Removido</span>
                                    <span class="text-xs text-secondary ml-auto">{{ copy.doacao_ou_compra }}</span>
                                </div>
                                
                                <div class="text-sm text-text font-medium flex items-center gap-1">
                                     <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-secondary"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                                     <span class="truncate">{{ copy.nome_escola }} &raquo; {{ copy.nome_predio }} &raquo; {{ copy.nome_sala }} &raquo; {{ copy.nome_estante }}</span>
                                </div>

                                <div v-if="copy.avaria_flag" class="mt-2 text-xs bg-danger/5 text-danger p-2 rounded border border-danger/10">
                                    <strong>Avaria:</strong> {{ copy.descricao_avaria }}
                                </div>
                            </div>

                            <div class="flex flex-col gap-1 items-end pl-2 border-l border-div-15 ml-2">
                                <button @click="handleEdit(copy)" class="p-1.5 text-secondary hover:text-primary hover:bg-primary/5 rounded transition-colors" title="Editar">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                </button>
                                <button @click="toggleDelete(copy)" 
                                    class="p-1.5 text-secondary hover:bg-danger/5 rounded transition-colors"
                                    :class="copy.soft_delete ? 'text-success hover:text-success-hover' : 'text-danger hover:text-danger-hover'" 
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
                <div v-if="showForm" class="w-full lg:w-96 bg-surface flex flex-col border-l border-div-15 shadow-xl overflow-y-auto">
                    <div class="p-4 border-b border-div-15 font-bold text-text flex justify-between items-center bg-div-05">
                        <span>{{ editingId ? 'Editar Cópia' : 'Nova(s) Cópia(s)' }}</span>
                    </div>
                    
                    <div class="p-4 space-y-4 flex-1">
                        
                        <!-- Location Cascade -->
                        <div class="space-y-3 p-3 bg-div-05/30 rounded-lg border border-div-15">
                            <label class="text-xs font-bold text-secondary uppercase tracking-wider block mb-2">Localização</label>
                            
                            <div>
                                <label class="block text-xs font-medium text-secondary mb-1">Escola</label>
                                <select v-model="formData.id_escola" class="w-full p-2 rounded border border-div-15 bg-input-bg text-sm focus:border-primary outline-none">
                                    <option value="" disabled>Selecione a Escola</option>
                                    <option v-for="s in schools" :key="s.id" :value="s.id">{{ s.nome }}</option>
                                </select>
                            </div>

                            <div>
                                <label class="block text-xs font-medium text-secondary mb-1">Prédio</label>
                                <select v-model="formData.predio_uuid" :disabled="!formData.id_escola" class="w-full p-2 rounded border border-div-15 bg-input-bg text-sm focus:border-primary outline-none disabled:opacity-50">
                                    <option value="" disabled>Selecione o Prédio</option>
                                    <option v-for="b in buildings" :key="b.uuid" :value="b.uuid">{{ b.nome }}</option>
                                </select>
                            </div>

                            <div>
                                <label class="block text-xs font-medium text-secondary mb-1">Sala</label>
                                <select v-model="formData.sala_uuid" :disabled="!formData.predio_uuid" class="w-full p-2 rounded border border-div-15 bg-input-bg text-sm focus:border-primary outline-none disabled:opacity-50">
                                    <option value="" disabled>Selecione a Sala</option>
                                    <option v-for="r in rooms" :key="r.uuid" :value="r.uuid">{{ r.nome }}</option>
                                </select>
                            </div>

                            <div>
                                <label class="block text-xs font-medium text-secondary mb-1">Estante</label>
                                <select v-model="formData.estante_uuid" :disabled="!formData.sala_uuid" class="w-full p-2 rounded border border-div-15 bg-input-bg text-sm focus:border-primary outline-none disabled:opacity-50 border-l-4 border-l-primary/50">
                                    <option value="" disabled>Selecione a Estante (Obrigatório)</option>
                                    <option v-for="s in shelves" :key="s.uuid" :value="s.uuid">{{ s.nome }}</option>
                                </select>
                            </div>
                        </div>

                        <!-- Details -->
                        <div class="space-y-3">
                             <div>
                                <label class="block text-xs font-medium text-secondary mb-1">Origem</label>
                                <select v-model="formData.doacao_ou_compra" class="w-full p-2 rounded border border-div-15 bg-input-bg text-sm focus:border-primary outline-none">
                                    <option v-for="opt in originOptions" :key="opt" :value="opt">{{ opt }}</option>
                                </select>
                            </div>

                            <div v-if="!editingId">
                                <label class="block text-xs font-medium text-secondary mb-1">Quantidade de Cópias</label>
                                <input type="number" v-model="formData.quantidade" min="1" max="100" class="w-full p-2 rounded border border-div-15 bg-input-bg text-sm font-bold focus:border-primary outline-none">
                                <p class="text-[10px] text-secondary mt-1">Cria múltiplas cópias idênticas para o mesmo local.</p>
                            </div>

                            <div v-if="editingId">
                                <label class="block text-xs font-medium text-secondary mb-1">Registro (Código)</label>
                                <input type="text" v-model="formData.registro_bibliotecario" class="w-full p-2 rounded border border-div-15 bg-input-bg text-sm focus:border-primary outline-none">
                            </div>

                            <div class="bg-danger/5 p-2 rounded border border-danger/10">
                                <label class="flex items-center gap-2 cursor-pointer mb-2">
                                    <input type="checkbox" v-model="formData.avaria_flag" class="accent-danger w-4 h-4">
                                    <span class="text-sm font-bold text-danger">Possui Avaria?</span>
                                </label>
                                <textarea v-if="formData.avaria_flag" v-model="formData.descricao_avaria" rows="2" placeholder="Descreva a avaria..." class="w-full p-2 text-sm border border-danger/20 rounded bg-input-bg text-text resize-none focus:border-danger outline-none"></textarea>
                            </div>
                        </div>

                    </div>
                    
                    <div class="p-4 bg-div-05 border-t border-div-15 flex justify-end gap-2 shrink-0">
                         <button @click="resetForm" class="px-3 py-2 rounded text-secondary hover:bg-div-15 transition-colors text-xs mr-auto">Limpar</button>
                         <button @click="showForm = false" class="px-4 py-2 rounded text-secondary hover:bg-div-15 transition-colors text-sm">Fechar</button>
                         <button @click="handleSave" class="px-6 py-2 rounded bg-primary text-white font-bold hover:bg-primary-hover transition-colors text-sm flex items-center gap-2">
                             <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
                             Salvar
                         </button>
                    </div>
                </div>

            </div>
        </div>
    </div>
</template>
