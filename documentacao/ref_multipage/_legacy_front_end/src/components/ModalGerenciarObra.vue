<script setup>
import { ref, watch, onMounted, computed } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const props = defineProps({
    isOpen: { type: Boolean, default: false },
    initialData: { type: Object, default: null }, // { id: ... } or null
    imageBaseUrl: { type: String, default: '' }
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

// State
const isLoading = ref(false)
const isSaving = ref(false)
const activeTab = ref('obra') // 'obra', 'edicoes'

// Data
const formObra = ref({
    uuid: null,
    titulo_principal: '',
    sub_titulo_principal: '',
    categoria_uuid: '',
    cdu_uuid: '',
    id_autoria: ''
})

const edicoes = ref([]) // List of edition objects
const edicaoEmEdicao = ref(null) // ID or index of edition being edited, or 'new'

// Dropdowns
const categorias = ref([])
const cdus = ref([])
const autores = ref([])
const editoras = ref([])

// Initialization
const resetForm = () => {
    formObra.value = {
        uuid: null,
        titulo_principal: '',
        sub_titulo_principal: '',
        categoria_uuid: '',
        cdu_uuid: '',
        id_autoria: ''
    }
    edicoes.value = []
    edicaoEmEdicao.value = null
    activeTab.value = 'obra'
}

const loadData = async () => {
    isLoading.value = true
    try {
        const obraUuid = props.initialData ? props.initialData.id : null

        const { data, error } = await supabase.rpc('bbtk_obra_get_detalhes_cpx', {
            p_uuid: obraUuid,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        // Fill Dropdowns
        categorias.value = data.categorias || []
        cdus.value = data.cdus || []
        autores.value = data.autores || []
        editoras.value = data.editoras || []

        // Fill Obra
        if (data.obra) {
            formObra.value = {
                uuid: data.obra.uuid,
                titulo_principal: data.obra.titulo_principal,
                sub_titulo_principal: data.obra.sub_titulo_principal,
                categoria_uuid: data.obra.categoria_uuid,
                cdu_uuid: data.obra.cdu_uuid,
                id_autoria: data.obra.id_autoria
            }
        }

        // Fill Edicoes
        edicoes.value = (data.edicoes || []).map(ed => ({
            ...ed,
            // Extract year if it's a full date string (e.g. 2023-01-01 -> 2023)
            ano_lancamento: ed.ano_lancamento ? String(ed.ano_lancamento).split('-')[0] : '',
            expanded: false
        }))

    } catch (error) {
        console.error(error)
        toast.showToast('Erro ao carregar dados.', 'error')
    } finally {
        isLoading.value = false
    }
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        resetForm()
        loadData()
    }
})

// Actions
const handleClose = () => {
    resetForm()
    emit('close')
}

const handleSave = async () => {
    // Validate Obra
    if (!formObra.value.titulo_principal) {
        toast.showToast('Título principal é obrigatório.', 'warning')
        activeTab.value = 'obra'
        return
    }

    isSaving.value = true
    try {
        // Construct Payload
        const payload = {
            obra: formObra.value,
            edicoes: edicoes.value
        }

        const { data, error } = await supabase.rpc('bbtk_obra_upsert_cpx', { 
            p_data: payload,
            p_id_empresa: appStore.id_empresa 
        })
        
        if (error) throw error

        toast.showToast('Obra salva com sucesso!', 'success')
        emit('success')
        emit('close')

    } catch (error) {
        console.error(error)
        toast.showToast('Erro ao salvar obra.', 'error')
    } finally {
        isSaving.value = false
    }
}

// Edicoes Logic
const addEdicao = () => {
    const newEd = {
        uuid: null, // New
        tempId: Date.now(), // For UI tracking
        ano_lancamento: '',
        isbn: '',
        editora_uuid: '',
        tipo_livro: 'Físico',
        livro_retiravel: true,
        livro_recomendado: false,
        expanded: true
    }
    edicoes.value.unshift(newEd)
}

const toggleExpand = (ed) => {
    ed.expanded = !ed.expanded
}

const removeEdicao = (index) => {
    if (confirm('Tem certeza que deseja remover esta edição?')) {
        edicoes.value.splice(index, 1)
    }
}

const viewPdf = (ed) => {
    if (!props.imageBaseUrl) return
    if (ed.arquivo_pdf) {
        window.open(`${props.imageBaseUrl}${ed.arquivo_pdf}`, '_blank')
    } else {
        toast.showToast('PDF não disponível.', 'info')
    }
}

const viewCover = (ed) => {
    if (!props.imageBaseUrl) return
    if (ed.arquivo_capa) {
        window.open(`${props.imageBaseUrl}${ed.arquivo_capa}`, '_blank')
    } else {
        toast.showToast('Capa não disponível.', 'info')
    }
}

</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-0 md:p-6" @click.self="handleClose">
        <div class="bg-background flex flex-col w-full h-full md:w-[90%] md:h-[90%] md:rounded-xl overflow-hidden shadow-2xl border border-secondary/20">
            
            <!-- Header -->
            <div class="flex items-center justify-between p-4 border-b border-secondary/20 bg-div-15 shrink-0">
                <h2 class="text-xl font-bold text-text">{{ formObra.uuid ? 'Editar Obra' : 'Nova Obra' }}</h2>
                <button @click="handleClose" class="p-2 text-secondary hover:text-text hover:bg-div-30 rounded-lg">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Tabs -->
            <div class="flex border-b border-secondary/20 bg-div-15/50 overflow-x-auto">
                <button @click="activeTab = 'obra'" class="min-w-[120px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'obra' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Obra
                </button>
                <button @click="activeTab = 'edicoes'" class="min-w-[120px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'edicoes' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Edições ({{ edicoes.length }})
                </button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-6 bg-background">
                <div v-show="activeTab === 'obra'" class="space-y-4 max-w-4xl mx-auto">
                    <!-- Title -->
                    <div class="flex flex-col gap-1">
                        <label class="text-sm font-medium text-secondary">Título Principal <span class="text-red-500">*</span></label>
                        <input v-model="formObra.titulo_principal" type="text" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/50" placeholder="Ex: Dom Casmurro">
                    </div>
                    
                    <!-- Subtitle -->
                    <div class="flex flex-col gap-1">
                        <label class="text-sm font-medium text-secondary">Subtítulo</label>
                        <input v-model="formObra.sub_titulo_principal" type="text" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/50" placeholder="Ex: Um romance...">
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <!-- Autor -->
                        <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Autor Principal</label>
                            <select v-model="formObra.id_autoria" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/50">
                                <option value="" disabled>Selecione</option>
                                <option v-for="a in autores" :key="a.uuid" :value="a.uuid">{{ a.nome_completo }}</option>
                            </select>
                        </div>

                        <!-- Categoria -->
                        <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Categoria</label>
                            <select v-model="formObra.categoria_uuid" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/50">
                                <option value="" disabled>Selecione</option>
                                <option v-for="c in categorias" :key="c.uuid" :value="c.uuid">{{ c.nome }}</option>
                            </select>
                        </div>
                    </div>

                    <!-- CDU -->
                    <div class="flex flex-col gap-1">
                        <label class="text-sm font-medium text-secondary">CDU</label>
                        <select v-model="formObra.cdu_uuid" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/50">
                            <option value="" disabled>Selecione</option>
                            <option v-for="d in cdus" :key="d.uuid" :value="d.uuid">{{ d.codigo }} - {{ d.nome }}</option>
                        </select>
                    </div>
                </div>

                <div v-show="activeTab === 'edicoes'" class="space-y-4 max-w-4xl mx-auto">
                    <button @click="addEdicao" class="w-full py-3 border-2 border-dashed border-secondary/30 rounded-xl flex items-center justify-center gap-2 text-secondary hover:text-primary hover:border-primary hover:bg-primary/5 transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                        Adicionar Edição
                    </button>

                    <div v-for="(ed, index) in edicoes" :key="ed.uuid || ed.tempId" class="bg-div-15 rounded-xl border border-secondary/20 overflow-hidden">
                        <!-- Header / Summary -->
                        <div @click="toggleExpand(ed)" class="p-4 flex items-center justify-between cursor-pointer bg-div-30/20 hover:bg-div-30/40 transition-colors">
                            <div class="flex flex-col gap-1">
                                <div class="flex items-center gap-2">
                                    <!-- Editora (Title) -->
                                    <h4 class="font-bold text-text text-base leading-none">
                                        {{ editoras.find(e => e.uuid === ed.editora_uuid)?.nome || 'Editora N/A' }}
                                    </h4>
                                    <!-- Year -->
                                    <span class="text-xs font-medium text-secondary bg-div-15 px-2 py-0.5 rounded-full border border-secondary/10">
                                        {{ ed.ano_lancamento || 'Ano N/A' }}
                                    </span>
                                </div>
                                <div class="flex items-center gap-2 mt-0.5">
                                    <!-- Type -->
                                    <span class="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded bg-blue-500/10 text-blue-500 border border-blue-500/10">
                                        {{ ed.tipo_livro || 'LIVRO' }}
                                    </span>
                                    <!-- ISBN -->
                                    <span v-if="ed.isbn" class="text-xs text-secondary">ISBN: {{ ed.isbn }}</span>
                                </div>
                            </div>
                            <div class="flex items-center gap-2">
                                <button @click.stop="removeEdicao(index)" class="p-2 text-secondary hover:text-danger hover:bg-danger/10 rounded-full transition-colors" title="Remover Edição">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                </button>
                                <button class="p-2 text-secondary hover:bg-div-30 rounded-full transition-colors">
                                     <svg :class="{'rotate-180': ed.expanded}" class="transition-transform duration-200" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                </button>
                            </div>
                        </div>

                        <!-- Expanded Form -->
                        <div v-show="ed.expanded" class="p-4 border-t border-secondary/10 bg-background/50 space-y-4">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div class="flex flex-col gap-1">
                                    <label class="text-xs font-bold text-secondary">Editora</label>
                                    <select v-model="ed.editora_uuid" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text text-sm">
                                        <option value="" disabled>Selecione</option>
                                        <option v-for="e in editoras" :key="e.uuid" :value="e.uuid">{{ e.nome }}</option>
                                    </select>
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-xs font-bold text-secondary">Ano Lançamento</label>
                                    <input v-model="ed.ano_lancamento" type="number" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text text-sm">
                                </div>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div class="flex flex-col gap-1">
                                    <label class="text-xs font-bold text-secondary">ISBN</label>
                                    <input v-model="ed.isbn" type="text" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text text-sm">
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-xs font-bold text-secondary">Tipo do Livro</label>
                                    <select v-model="ed.tipo_livro" class="w-full px-3 py-2 bg-div-15 border border-secondary/30 rounded-lg text-text text-sm">
                                        <option value="Impresso">Impresso</option>
                                        <option value="Digital">Digital</option>
                                    </select>
                                </div>
                            </div>

                            <!-- File Uploads / Actions -->
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-2">
                                <!-- PDF Section (Only Digital) -->
                                <div v-if="ed.tipo_livro === 'Digital'" class="flex flex-col gap-2">
                                    <label class="text-xs font-bold text-secondary">Arquivo do Livro (PDF)</label>
                                    <div v-if="ed.arquivo_pdf" class="flex items-center gap-2">
                                        <button @click.stop="viewPdf(ed)" class="flex-1 py-3 px-4 bg-primary/10 text-primary border border-primary/20 rounded-lg font-bold hover:bg-div-30 transition-colors flex items-center justify-center gap-2">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                                            Visualizar PDF
                                        </button>
                                        <button class="p-3 text-secondary hover:text-danger hover:bg-danger/10 rounded-lg transition-colors" title="Remover PDF">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                        </button>
                                    </div>
                                    <div v-else class="relative">
                                        <input type="file" disabled class="w-full text-xs text-secondary file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-xs file:font-semibold file:bg-div-30 file:text-text hover:file:bg-secondary/20 cursor-not-allowed border border-secondary/20 rounded-lg p-1 opacity-60">
                                    </div>
                                </div>
                                
                                <!-- Cover Section -->
                                <div class="flex flex-col gap-2">
                                    <label class="text-xs font-bold text-secondary">Capa do Livro</label>
                                    <div v-if="ed.arquivo_capa" class="flex items-center gap-2">
                                        <button @click.stop="viewCover(ed)" class="flex-1 py-3 px-4 bg-primary/10 text-primary border border-primary/20 rounded-lg font-bold hover:bg-div-30 transition-colors flex items-center justify-center gap-2">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                                            Visualizar Capa
                                        </button>
                                        <button class="p-3 text-secondary hover:text-danger hover:bg-danger/10 rounded-lg transition-colors" title="Remover Capa">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                        </button>
                                    </div>
                                    <div v-else class="relative">
                                        <input type="file" disabled class="w-full text-xs text-secondary file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-xs file:font-semibold file:bg-div-30 file:text-text hover:file:bg-secondary/20 cursor-not-allowed border border-secondary/20 rounded-lg p-1 opacity-60">
                                    </div>
                                </div>
                            </div>

                            <!-- Options -->
                            <div class="flex flex-wrap gap-4 pt-2">
                                <label class="flex items-center gap-2 cursor-pointer">
                                    <input type="checkbox" v-model="ed.livro_retiravel" class="rounded border-secondary text-primary focus:ring-primary">
                                    <span class="text-sm text-text">Retirável</span>
                                </label>
                                <label class="flex items-center gap-2 cursor-pointer">
                                    <input type="checkbox" v-model="ed.livro_recomendado" class="rounded border-secondary text-primary focus:ring-primary">
                                    <span class="text-sm text-text">Recomendado</span>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

             <!-- Footer -->
             <div class="p-4 bg-div-15 border-t border-secondary/20 flex justify-end gap-3 shrink-0">
                <button @click="handleClose" class="px-6 py-2 rounded-lg text-secondary hover:bg-div-30 font-medium transition-colors">Cancelar</button>
                <button @click="handleSave" :disabled="isSaving" class="px-6 py-2 rounded-lg bg-green-600 text-white font-medium hover:bg-green-700 transition-colors shadow-lg shadow-green-900/20 flex items-center gap-2">
                    <span v-if="isSaving" class="animate-spin">⌛</span>
                    Salvar Tudo
                </button>
            </div>

        </div>
    </div>
</template>
