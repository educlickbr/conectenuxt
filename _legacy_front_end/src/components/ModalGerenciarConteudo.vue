<script setup>
import { ref, watch, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    },
    initialData: {
        type: Object,
        default: null
    }
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

// State
const isLoading = ref(false)
const isSaving = ref(false)
const errorMessage = ref('')
const isSearchingAlunos = ref(false)

// Lists
const turmas = ref([])
const alunos = ref([])

// Form Data
const form = ref({
    escopo: 'Turma',
    id_turma: '',
    id_aluno: '',
    titulo: '',
    descricao: '',
    data_referencia: new Date().toISOString().split('T')[0],
    visivel_para_alunos: true
})

// Fetch Lists
const fetchTurmas = async () => {
    const { data } = await supabase.rpc('turmas_get_paginado', {
        p_id_empresa: appStore.id_empresa,
        p_pagina: 1,
        p_limite_itens_pagina: 100
    })
    if (data && data.itens) turmas.value = data.itens // Adjust based on pagination return
    else if (Array.isArray(data)) turmas.value = data
}

const searchAlunos = async (term) => {
    if (!term || term.length < 3) return
    isSearchingAlunos.value = true
    const { data } = await supabase.rpc('aluno_get_paginado', {
        p_id_empresa: appStore.id_empresa,
        p_pagina: 1,
        p_limite_itens_pagina: 20,
        p_busca: term
    })
    
    if (data) {
        const responseData = Array.isArray(data) ? data[0] : data
        const itens = responseData.itens || []
        alunos.value = itens.map(a => ({
             ...a,
             id: a.user_expandido_id,
             nome: a.nome_completo
        }))
    } else {
        alunos.value = []
    }
    isSearchingAlunos.value = false
}

// Reset
const resetForm = () => {
    form.value = {
        escopo: 'Turma',
        id_turma: '',
        id_aluno: '',
        titulo: '',
        descricao: '',
        data_referencia: new Date().toISOString().split('T')[0],
        visivel_para_alunos: true
    }
    alunos.value = []
    errorMessage.value = ''
}

// Watchers
watch(() => props.isOpen, async (newVal) => {
    if (newVal) {
        resetForm()
        await fetchTurmas()
        
        if (props.initialData) {
            form.value = {
                escopo: props.initialData.escopo,
                id_turma: props.initialData.id_turma || '',
                id_aluno: props.initialData.id_aluno || '',
                titulo: props.initialData.titulo,
                descricao: props.initialData.descricao,
                data_referencia: props.initialData.data_referencia ? props.initialData.data_referencia.split('T')[0] : new Date().toISOString().split('T')[0],
                visivel_para_alunos: props.initialData.visivel_para_alunos
            }
            // Logic to fetch specific student name if needed could go here
        }
    }
})

// Save
const handleSave = async () => {
    errorMessage.value = ''
    if (!form.value.titulo) {
        errorMessage.value = 'O título é obrigatório.'
        return
    }
    if (form.value.escopo === 'Turma' && !form.value.id_turma) {
        errorMessage.value = 'Selecione uma turma.'
        return
    }
    if (form.value.escopo === 'Aluno' && !form.value.id_aluno) {
        errorMessage.value = 'Selecione um aluno.'
        return
    }

    isSaving.value = true
    
    // Prepare payload
    const payload = {
        p_id: props.initialData?.id || null,
        p_id_empresa: appStore.id_empresa,
        p_criado_por: appStore.user.id,
        p_escopo: form.value.escopo,
        p_id_turma: form.value.escopo === 'Turma' ? form.value.id_turma : null,
        p_id_aluno: form.value.escopo === 'Aluno' ? form.value.id_aluno : null,
        p_id_meta_turma: null, // Future
        p_id_componente: null,
        p_titulo: form.value.titulo,
        p_descricao: form.value.descricao,
        p_data_referencia: form.value.data_referencia,
        p_visivel_para_alunos: form.value.visivel_para_alunos,
        p_json_itens: null
    }

    try {
        const { error } = await supabase.rpc('lms_conteudo_upsert', payload)

        if (error) throw error

        toast.showToast('Conteúdo salvo com sucesso!', 'success')
        emit('success')
        emit('close')

    } catch (error) {
        console.error('Erro ao salvar:', error)
        if (error.code === '23503') {
            errorMessage.value = 'Erro de Permissão: Seu usuário não está cadastrado corretamente na tabela de equipe (user_expandido).'
        } else {
            errorMessage.value = 'Erro ao salvar conteúdo: ' + (error.message || error.details)
        }
    } finally {
        isSaving.value = false
    }
}

// Aluno Search Debounce
let timer = null
const onSearchAluno = (e) => {
    clearTimeout(timer)
    timer = setTimeout(() => {
        searchAlunos(e.target.value)
    }, 500)
}

const handleClose = () => {
    emit('close')
}

</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-[110] flex items-center justify-center p-4 sm:p-6 backdrop-blur-md bg-black/40" @click.self="handleClose">
        <div class="bg-background flex flex-col w-full max-w-2xl max-h-[90vh] rounded-3xl overflow-hidden shadow-2xl border border-secondary/20 font-inter transform transition-all animate-in fade-in zoom-in duration-300">
            
            <!-- Chic Header -->
            <div class="flex items-center justify-between p-6 pb-4 shrink-0">
                <div class="flex items-center gap-4">
                    <div class="w-12 h-12 rounded-2xl bg-primary/10 text-primary flex items-center justify-center shadow-inner">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                    </div>
                    <div>
                        <h2 class="text-xl font-black text-text tracking-tight">{{ initialData ? 'Editar Folder' : 'Novo Folder' }}</h2>
                        <p class="text-[10px] text-secondary font-bold uppercase tracking-[0.2em] mt-0.5">Gestão Acadêmica</p>
                    </div>
                </div>
                <button @click="handleClose" class="p-3 text-secondary hover:text-danger hover:bg-danger/5 rounded-2xl transition-all">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-8 pt-2 space-y-8 scrollbar-thin">
                 <div v-if="errorMessage" class="p-4 bg-danger/10 border border-danger/20 text-danger rounded-2xl text-xs font-bold flex items-center gap-3">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                    {{ errorMessage }}
                 </div>

                 <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                    
                    <!-- Left Section: Basic Info -->
                    <div class="space-y-6">
                        <div class="space-y-2">
                             <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Identificação</label>
                             <div class="relative group">
                                <input v-model="form.titulo" type="text" placeholder="Nome do Folder (ex: Aula 01)" class="w-full px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl text-text font-bold text-sm focus:outline-none focus:border-primary/50 focus:ring-4 focus:ring-primary/5 transition-all shadow-sm">
                                <span class="absolute right-4 top-3 text-secondary/30 group-focus-within:text-primary transition-colors">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path></svg>
                                </span>
                             </div>
                        </div>

                        <div class="space-y-2">
                            <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Descrição</label>
                            <textarea v-model="form.descricao" rows="4" placeholder="Breve resumo sobre o conteúdo..." class="w-full px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl text-text text-sm focus:outline-none focus:border-primary/50 transition-all shadow-sm resize-none"></textarea>
                        </div>
                    </div>

                    <!-- Right Section: Scope & Settings -->
                    <div class="space-y-6">
                        <div class="space-y-2">
                             <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Escopo de Acesso</label>
                             <div class="grid grid-cols-1 gap-2">
                                 <button 
                                    v-for="opt in ['Turma', 'Aluno', 'Global']" 
                                    :key="opt"
                                    @click="form.escopo = opt"
                                    class="flex items-center justify-between px-4 py-3 rounded-2xl border transition-all text-sm font-bold"
                                    :class="form.escopo === opt ? 'bg-primary/10 border-primary text-primary shadow-sm' : 'bg-div-15 border-secondary/10 text-secondary hover:bg-div-30'"
                                 >
                                    <span>{{ opt === 'Global' ? 'Global (Escola)' : opt }}</span>
                                    <div v-if="form.escopo === opt" class="w-2 h-2 rounded-full bg-primary shadow-lg shadow-primary/50"></div>
                                 </button>
                             </div>
                        </div>

                        <!-- Condicionais -->
                        <div v-if="form.escopo === 'Turma'" class="space-y-2 animate-in fade-in slide-in-from-top-2 duration-300">
                            <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Selecionar Turma</label>
                            <select v-model="form.id_turma" class="w-full px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl text-text font-bold text-sm focus:outline-none focus:border-primary/50 transition-all shadow-sm appearance-none">
                                <option value="">Escolha uma turma...</option>
                                <option v-for="t in turmas" :key="t.id" :value="t.id">{{ t.nome_turma }}</option>
                            </select>
                        </div>

                        <div v-if="form.escopo === 'Aluno'" class="space-y-2 animate-in fade-in slide-in-from-top-2 duration-300">
                             <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Buscar Estudante</label>
                             <div class="relative">
                                <input type="text" @input="onSearchAluno" placeholder="Nome do aluno..." class="w-full px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl text-text font-bold text-sm focus:outline-none focus:border-primary/50 transition-all shadow-sm">
                                <div v-if="alunos.length > 0" class="absolute z-10 w-full mt-2 bg-background border border-secondary/10 rounded-2xl shadow-xl overflow-hidden max-h-48 overflow-y-auto">
                                    <div v-for="aluno in alunos" :key="aluno.id" @click="form.id_aluno = aluno.id; alunos = []" class="p-3 text-xs font-bold cursor-pointer hover:bg-primary/5 transition-colors border-b border-secondary/5 last:border-0" :class="form.id_aluno === aluno.id ? 'text-primary' : 'text-text'">
                                        {{ aluno.nome }}
                                    </div>
                                </div>
                             </div>
                        </div>
                    </div>
                 </div>

                 <div class="pt-6 border-t border-secondary/10 grid grid-cols-1 md:grid-cols-2 gap-6 items-center">
                    <div class="flex items-center gap-4">
                         <div class="flex-1 space-y-2">
                             <label class="text-[11px] font-black text-secondary uppercase tracking-widest pl-1">Data de Referência</label>
                             <input v-model="form.data_referencia" type="date" class="w-full px-4 py-2.5 bg-div-15 border border-secondary/10 rounded-xl text-text font-bold text-sm focus:outline-none focus:border-primary/50 transition-all shadow-sm">
                         </div>
                         <div class="flex flex-col items-center justify-center pt-5">
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" v-model="form.visivel_para_alunos" class="sr-only peer">
                                <div class="w-11 h-6 bg-secondary/20 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                            </label>
                            <span class="text-[8px] font-black text-secondary uppercase tracking-tighter mt-1">{{ form.visivel_para_alunos ? 'Visível' : 'Oculto' }}</span>
                         </div>
                    </div>

                    <div class="flex items-center justify-end gap-3">
                         <button @click="handleClose" class="px-6 py-3 text-secondary font-black text-xs uppercase tracking-widest hover:text-text transition-colors">Cancelar</button>
                         <button 
                            @click="handleSave" 
                            :disabled="isSaving"
                            class="px-10 py-3 bg-primary text-white font-black text-xs uppercase tracking-widest rounded-2xl hover:bg-primary-hover shadow-lg shadow-primary/20 hover:shadow-primary/30 transform hover:scale-[1.02] transition-all flex items-center gap-3 disabled:opacity-50"
                         >
                            <span v-if="isSaving" class="animate-spin text-lg">⌛</span>
                            <span>{{ initialData ? 'Atualizar' : 'Criar Folder' }}</span>
                         </button>
                    </div>
                 </div>

            </div>
        </div>
    </div>
</template>

<style scoped>
/* Scrollbar Refinement */
.scrollbar-thin::-webkit-scrollbar {
  width: 4px;
}
.scrollbar-thin::-webkit-scrollbar-thumb {
  background: rgba(var(--secondary-rgb), 0.1);
  border-radius: 10px;
}

@keyframes zoom-in {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}
.animate-in {
  animation: zoom-in 0.2s ease-out forwards;
}
</style>
