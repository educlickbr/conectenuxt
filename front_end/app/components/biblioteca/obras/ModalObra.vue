<script setup lang="ts">
import { ref, watch } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps<{
    isOpen: boolean
    initialData?: any // { id: string } or null
    imageBaseUrl?: string
}>()

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

// State
const isLoading = ref(false)
const isSaving = ref(false)
const activeTab = ref<'obra' | 'edicoes'>('obra')

// Data
const formObra = ref({
    uuid: null as string | null,
    titulo_principal: '',
    sub_titulo_principal: '',
    categoria_uuid: '',
    cdu_uuid: '',
    id_autoria: ''
})

const edicoes = ref<any[]>([])

// Dropdowns
const categorias = ref<any[]>([])
const cdus = ref<any[]>([])
const autores = ref<any[]>([])
const editoras = ref<any[]>([])

// Helpers
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
    activeTab.value = 'obra'
}

const loadData = async () => {
    isLoading.value = true
    try {
        const obraId = props.initialData?.id || 'novo'
        
        const data: any = await $fetch(`/api/biblioteca/obras/${obraId}`, {
            params: { id_empresa: appStore.company?.empresa_id }
        })

        if (!data) return

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
        edicoes.value = (data.edicoes || []).map((ed: any) => ({
            ...ed,
            ano_lancamento: ed.ano_lancamento ? String(ed.ano_lancamento).split('-')[0] : '',
            expanded: false
        }))

    } catch (e: any) {
        toast.showToast(e.message || 'Erro ao carregar dados.', 'error')
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

const handleSave = async () => {
    if (!formObra.value.titulo_principal) {
        activeTab.value = 'obra'
        toast.showToast('Título principal é obrigatório.', 'error')
        return
    }

    isSaving.value = true
    try {
        await $fetch('/api/biblioteca/obras', {
            method: 'POST',
            body: {
                payload: {
                    obra: formObra.value,
                    edicoes: edicoes.value
                },
                id_empresa: appStore.company?.empresa_id
            }
        })
        
        emit('success')
        emit('close')
        toast.showToast('Obra salva com sucesso.', 'success')

    } catch (e: any) {
        toast.showToast(e.message || 'Erro ao salvar.', 'error')
    } finally {
        isSaving.value = false
    }
}

const handleCancel = () => {
    emit('close')
}

// Edition Management
const addEdicao = () => {
    edicoes.value.unshift({
        uuid: null, 
        tempId: Date.now(),
        ano_lancamento: '',
        isbn: '',
        editora_uuid: '',
        tipo_livro: 'Físico',
        livro_retiravel: true,
        livro_recomendado: false,
        expanded: true
    })
    activeTab.value = 'edicoes'
}

const removeEdicao = (index: number) => {
    edicoes.value.splice(index, 1)
}

const toggleExpand = (ed: any) => {
    ed.expanded = !ed.expanded
}

const getEditoraName = (uuid: string) => {
    return editoras.value.find(e => e.uuid === uuid)?.nome || 'Selecione Editora'
}
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-6">
            <!-- Backdrop -->
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="handleCancel"></div>
            
            <!-- Modal Content -->
            <div class="relative bg-background w-full max-w-4xl max-h-[90vh] flex flex-col rounded shadow-2xl border border-[#6B82A71A] overflow-hidden transform transition-all animate-in zoom-in-95 duration-200">
                
                <!-- Header -->
                <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between bg-div-15">
                    <div>
                        <h2 class="text-xl font-bold text-text">{{ formObra.uuid ? 'Editar Obra' : 'Nova Obra' }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Gerenciamento completo do livro e suas edições.</p>
                    </div>
                    <button @click="handleCancel" class="p-2 rounded-full hover:bg-div-30 text-secondary transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Tabs -->
                <div class="flex border-b border-[#6B82A71A] bg-div-15/50 px-6 gap-6 shrink-0">
                    <button 
                        @click="activeTab = 'obra'" 
                        class="py-3 text-sm font-bold border-b-2 transition-colors flex items-center gap-2" 
                        :class="activeTab === 'obra' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'"
                    >
                        Dados da Obra
                    </button>
                    <button 
                        @click="activeTab = 'edicoes'" 
                        class="py-3 text-sm font-bold border-b-2 transition-colors flex items-center gap-2" 
                        :class="activeTab === 'edicoes' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'"
                    >
                        Edições <span class="bg-div-30 text-xs px-1.5 py-0.5 rounded-full">{{ edicoes.length }}</span>
                    </button>
                </div>

                <!-- Body -->
                <div class="flex-1 overflow-y-auto p-6 bg-surface relative">
                    
                    <div v-if="isLoading" class="absolute inset-0 flex items-center justify-center bg-surface/50 backdrop-blur-[1px] z-10">
                        <div class="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                    </div>

                    <!-- Tab: Obra -->
                    <div v-show="activeTab === 'obra'" class="space-y-5 max-w-3xl mx-auto">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-5">
                            <ManagerField
                                v-model="formObra.titulo_principal"
                                label="Título Principal"
                                placeholder="Ex: Dom Casmurro"
                                :required="true"
                                class="col-span-1 md:col-span-2"
                            />
                            
                            <ManagerField
                                v-model="formObra.sub_titulo_principal"
                                label="Subtítulo"
                                placeholder="Ex: Um romance..."
                                class="col-span-1 md:col-span-2"
                            />

                            <div class="col-span-1 flex flex-col gap-1.5">
                                <label class="text-xs font-bold text-secondary uppercase tracking-wider">Autor Principal</label>
                                <div class="relative">
                                    <select v-model="formObra.id_autoria" class="w-full h-10 px-3 pl-3 pr-8 bg-input-bg border border-div-15 rounded-lg text-sm text-text appearance-none cursor-pointer focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all">
                                        <option value="" disabled>Selecione um autor</option>
                                        <option v-for="a in autores" :key="a.uuid" :value="a.uuid">{{ a.nome_completo }}</option>
                                    </select>
                                    <span class="absolute right-3 top-3 text-secondary pointer-events-none">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                    </span>
                                </div>
                            </div>

                            <div class="col-span-1 flex flex-col gap-1.5">
                                <label class="text-xs font-bold text-secondary uppercase tracking-wider">Categoria</label>
                                <div class="relative">
                                    <select v-model="formObra.categoria_uuid" class="w-full h-10 px-3 pl-3 pr-8 bg-input-bg border border-div-15 rounded-lg text-sm text-text appearance-none cursor-pointer focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all">
                                        <option value="" disabled>Selecione uma categoria</option>
                                        <option v-for="c in categorias" :key="c.uuid" :value="c.uuid">{{ c.nome }}</option>
                                    </select>
                                    <span class="absolute right-3 top-3 text-secondary pointer-events-none">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                    </span>
                                </div>
                            </div>

                            <div class="col-span-1 md:col-span-2 flex flex-col gap-1.5">
                                <label class="text-xs font-bold text-secondary uppercase tracking-wider">CDU</label>
                                <div class="relative">
                                    <select v-model="formObra.cdu_uuid" class="w-full h-10 px-3 pl-3 pr-8 bg-input-bg border border-div-15 rounded-lg text-sm text-text appearance-none cursor-pointer focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all">
                                        <option value="" disabled>Selecione um CDU</option>
                                        <option v-for="d in cdus" :key="d.uuid" :value="d.uuid">{{ d.codigo }} - {{ d.nome }}</option>
                                    </select>
                                    <span class="absolute right-3 top-3 text-secondary pointer-events-none">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Tab: Edicoes -->
                    <div v-show="activeTab === 'edicoes'" class="space-y-4 max-w-3xl mx-auto">
                        <button 
                            @click="addEdicao" 
                            class="w-full py-3 border-2 border-dashed border-[#6B82A71A] rounded-xl flex items-center justify-center gap-2 text-secondary hover:text-primary hover:border-primary/50 hover:bg-primary/5 transition-all font-bold text-sm"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                            Adicionar Nova Edição
                        </button>

                        <div v-for="(ed, index) in edicoes" :key="ed.uuid || ed.tempId" class="bg-surface rounded-xl border border-[#6B82A71A] overflow-hidden shadow-sm transition-shadow hover:shadow-md">
                             <!-- Edition Header -->
                             <div @click="toggleExpand(ed)" class="p-4 flex items-center justify-between cursor-pointer hover:bg-div-05 transition-colors select-none group">
                                 <div class="flex items-center gap-4">
                                     <div class="flex flex-col">
                                         <span class="font-bold text-text text-sm group-hover:text-primary transition-colors">{{ getEditoraName(ed.editora_uuid) }}</span>
                                         <span class="text-xs text-secondary mt-0.5">{{ ed.ano_lancamento || 'Sem ano' }} • {{ ed.isbn || 'Sem ISBN' }}</span>
                                     </div>
                                     <span class="px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider border" :class="ed.tipo_livro === 'Digital' ? 'bg-indigo-500/10 text-indigo-500 border-indigo-500/10' : 'bg-emerald-500/10 text-emerald-500 border-emerald-500/10'">
                                         {{ ed.tipo_livro || 'LIVRO' }}
                                     </span>
                                 </div>
                                 <div class="flex items-center gap-2">
                                    <button @click.stop="removeEdicao(index)" class="p-2 text-secondary hover:text-red-500 hover:bg-red-500/10 rounded-full transition-colors" title="Remover edição">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                    </button>
                                    <div class="p-2 text-secondary group-hover:bg-div-15 rounded-full transition-colors">
                                        <svg :class="{'rotate-180': ed.expanded}" class="transition-transform duration-200" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                    </div>
                                 </div>
                             </div>
                             
                             <!-- Edition Body -->
                             <div v-show="ed.expanded" class="p-5 border-t border-[#6B82A71A] bg-div-05/30 grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-5">
                                <div class="col-span-1 flex flex-col gap-1.5">
                                    <label class="text-xs font-bold text-secondary uppercase tracking-wider">Editora</label>
                                    <div class="relative">
                                        <select v-model="ed.editora_uuid" class="w-full h-10 px-3 pl-3 pr-8 bg-input-bg border border-div-15 rounded-lg text-sm text-text appearance-none cursor-pointer focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all">
                                            <option value="" disabled>Selecione</option>
                                            <option v-for="e in editoras" :key="e.uuid" :value="e.uuid">{{ e.nome }}</option>
                                        </select>
                                        <span class="absolute right-3 top-3 text-secondary pointer-events-none">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                        </span>
                                    </div>
                                </div>

                                <div class="col-span-1 flex flex-col gap-1.5">
                                    <label class="text-xs font-bold text-secondary uppercase tracking-wider">Ano Lançamento</label>
                                    <input v-model="ed.ano_lancamento" type="number" class="w-full h-10 px-3 bg-input-bg border border-div-15 rounded-lg text-sm text-text focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all">
                                </div>

                                <div class="col-span-1 flex flex-col gap-1.5">
                                    <label class="text-xs font-bold text-secondary uppercase tracking-wider">ISBN</label>
                                    <input v-model="ed.isbn" type="text" class="w-full h-10 px-3 bg-input-bg border border-div-15 rounded-lg text-sm text-text focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all">
                                </div>

                                <div class="col-span-1 flex flex-col gap-1.5">
                                    <label class="text-xs font-bold text-secondary uppercase tracking-wider">Tipo</label>
                                    <div class="relative">
                                        <select v-model="ed.tipo_livro" class="w-full h-10 px-3 pl-3 pr-8 bg-input-bg border border-div-15 rounded-lg text-sm text-text appearance-none cursor-pointer focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all">
                                            <option value="Impresso">Impresso</option>
                                            <option value="Digital">Digital</option>
                                        </select>
                                        <span class="absolute right-3 top-3 text-secondary pointer-events-none">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                        </span>
                                    </div>
                                </div>

                                <div class="col-span-1 md:col-span-2 flex gap-6 pt-2">
                                    <label class="flex items-center gap-2 cursor-pointer select-none group">
                                        <div class="relative flex items-center">
                                            <input type="checkbox" v-model="ed.livro_retiravel" class="peer h-4 w-4 rounded border-secondary/30 text-primary focus:ring-primary cursor-pointer transition-all">
                                        </div>
                                        <span class="text-sm text-text group-hover:text-primary transition-colors">Permite Retirada</span>
                                    </label>
                                    <label class="flex items-center gap-2 cursor-pointer select-none group">
                                        <div class="relative flex items-center">
                                            <input type="checkbox" v-model="ed.livro_recomendado" class="peer h-4 w-4 rounded border-secondary/30 text-primary focus:ring-primary cursor-pointer transition-all">
                                        </div>
                                        <span class="text-sm text-text group-hover:text-primary transition-colors">Obra Recomendada</span>
                                    </label>
                                 </div>
                             </div>
                        </div>
                    </div>

                </div>

                 <!-- Footer -->
                <div class="px-6 py-4 border-t border-[#6B82A71A] flex items-center justify-end gap-3 bg-div-15 shrink-0">
                    <button 
                        @click="handleCancel"
                        class="px-5 py-2.5 rounded text-secondary font-semibold text-sm hover:bg-div-30 transition-colors"
                    >
                        Cancelar
                    </button>
                    <button 
                        @click="handleSave"
                        :disabled="isSaving"
                        class="px-8 py-2.5 rounded bg-primary text-white font-bold text-sm hover:brightness-110 active:scale-95 disabled:opacity-50 disabled:active:scale-100 transition-all flex items-center gap-2 shadow-lg shadow-[#3571CB33]"
                    >
                        <svg v-if="isSaving" class="animate-spin w-4 h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                        {{ isSaving ? 'Salvando...' : (initialData ? 'Atualizar Obra' : 'Criar Obra') }}
                    </button>
                </div>

            </div>
        </div>
    </Teleport>
</template>
