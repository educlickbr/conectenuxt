<script setup>
import { ref, watch, computed } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const props = defineProps({
    isOpen: Boolean,
    conteudoId: String,
    initialData: Object
})

const emit = defineEmits(['close', 'success'])

const appStore = useAppStore()
const toast = useToastStore()

const isLoading = ref(false)
const activeTab = ref('config') // config, perguntas

// Form Data
const formData = ref({
    tipo: 'Material', // Material, Video, Tarefa, Questionário
    titulo: '',
    rich_text: '',
    url_externa: '',
    video_link: '',
    id_bbtk_edicao: null,
    caminho_arquivo: null, // Placeholder logic
    pontuacao_maxima: 0,
    tempo_questionario: null,
    data_disponivel: null,
    data_entrega_limite: null,
    perguntas: []
})

// Lists & Helpers
const livros = ref([])
const isSearchingLivros = ref(false)

// Init
const resetForm = () => {
    formData.value = {
        tipo: 'Material',
        titulo: '',
        rich_text: '',
        url_externa: '',
        video_link: '',
        id_bbtk_edicao: null,
        caminho_arquivo: null,
        pontuacao_maxima: 0,
        tempo_questionario: null,
        data_disponivel: null,
        data_entrega_limite: null,
        perguntas: []
    }
    activeTab.value = 'config'
    livros.value = []
    selectedBook.value = null
}

// watch removed, consolidated into the one below

// --- Logic for Livro Search ---
let livroTimer = null
const searchLivros = async (term) => {
    if (!term || term.length < 3) return
    isSearchingLivros.value = true
    const { data } = await supabase.rpc('bbtk_edicao_get_paginado', {
        p_id_empresa: appStore.id_empresa,
        p_pagina: 1,
        p_limite_itens_pagina: 10,
        p_termo_busca: term,
        p_tipo_livro: 'Digital'
    })
    
    if (data && data.itens) {
        livros.value = data.itens
    } else {
        livros.value = []
    }
    isSearchingLivros.value = false
}

const onSearchLivro = (e) => {
    clearTimeout(livroTimer)
    livroTimer = setTimeout(() => {
        searchLivros(e.target.value)
    }, 500)
}

// --- Logic for Questions ---
const addQuestion = () => {
    formData.value.perguntas.push({
        id: null, // New
        enunciado: '',
        tipo: 'Dissertativa',
        obrigatoria: true,
        ordem: formData.value.perguntas.length + 1,
        opcoes: []
    })
}

const removeQuestion = (index) => {
    formData.value.perguntas.splice(index, 1)
}

const addOption = (question) => {
    if (!question.opcoes) question.opcoes = []
    question.opcoes.push({
        id: null,
        texto: '',
        correta: false,
        ordem: question.opcoes.length + 1
    })
}

const removeOption = (question, idx) => {
    question.opcoes.splice(idx, 1)
}

const moveQuestion = (index, direction) => {
    const newIndex = index + direction
    if (newIndex >= 0 && newIndex < formData.value.perguntas.length) {
        const item = formData.value.perguntas.splice(index, 1)[0]
        formData.value.perguntas.splice(newIndex, 0, item)
        // Reorder
        formData.value.perguntas.forEach((p, i) => p.ordem = i + 1)
    }
}

// --- Save ---
const handleSave = async () => {
    if (!formData.value.titulo) return toast.showToast('Título é obrigatório', 'warning')

    isLoading.value = true
    try {
        const payload = {
            p_id: props.initialData?.id || null,
            p_id_empresa: appStore.id_empresa,
            p_criado_por: appStore.user.id,
            p_id_lms_conteudo: props.conteudoId,
            p_tipo: formData.value.tipo,
            p_titulo: formData.value.titulo,
            p_caminho_arquivo: formData.value.caminho_arquivo,
            p_url_externa: formData.value.url_externa,
            p_video_link: formData.value.video_link,
            p_rich_text: formData.value.rich_text,
            p_pontuacao_maxima: formData.value.pontuacao_maxima,
            p_id_bbtk_edicao: formData.value.id_bbtk_edicao,
            p_ordem: props.initialData?.ordem || 99, // Backend handles better? Or we should pass correct order. For now append likely.
            p_data_disponivel: formData.value.data_disponivel || null,
            p_data_entrega_limite: formData.value.data_entrega_limite || null,
            p_tempo_questionario: formData.value.tipo === 'Questionário' ? formData.value.tempo_questionario : null,
            p_perguntas: formData.value.tipo === 'Questionário' ? formData.value.perguntas : null
        }

        const { error } = await supabase.rpc('lms_item_upsert', payload)

        if (error) throw error

        toast.showToast('Item salvo com sucesso!', 'success')
        emit('success')
        emit('close')

    } catch (error) {
        console.error('Erro ao salvar item:', error)
        toast.showToast('Erro ao salvar item', 'error')
    } finally {
        isLoading.value = false
    }
}

const selectedBook = ref(null)
const imageBaseUrl = ref('')

const fetchImageHash = async () => {
    try {
        const { data: { session } } = await supabase.auth.getSession()

        const { data, error } = await supabase.functions.invoke('hash_pasta_conecte', {
            body: { 
                path: '/biblio/',
                user_id: session?.user?.id
            },
            headers: session ? {
                Authorization: `Bearer ${session.access_token}`
            } : {}
        })
        if (error) throw error
        if (data && data.url) {
            imageBaseUrl.value = data.url
        }
    } catch (err) {
        console.error('Error fetching image hash:', err)
    }
}

const selectBook = (book) => {
    selectedBook.value = book
    formData.value.id_bbtk_edicao = book.id_edicao
    livros.value = []
}

const removeBook = () => {
    selectedBook.value = null
    formData.value.id_bbtk_edicao = null
}

const getBookCoverUrl = (capa) => {
    if (!capa) return ''
    if (capa.startsWith('http')) return capa
    
    // Use fetched hash URL if available
    if (imageBaseUrl.value) {
        return `${imageBaseUrl.value}${capa}`
    }

    // Fallback? Or maybe just return empty strings until hash loads?
    // Let's keep the old fallback just in case the edge function fails entirely or hasn't loaded yet.
    // Ideally we should wait for hash, but UI shouldn't crash.
    const baseUrl = appStore.empresa_local || 'https://caruaru.conectetecnologia.app'
    return `${baseUrl}/storage/v1/object/public/bbtk-capas/${capa}`
}

watch(() => props.isOpen, async (newVal) => {
    if (newVal) {
        // 1. Fetch Image Hash for covers
        fetchImageHash()

        // 2. Reset form
        resetForm()

        // 3. Load data if editing
        if (props.initialData) {
            isLoading.value = true
            try {
                // Fetch full details (including nested questions)
                const { data, error } = await supabase.rpc('lms_item_get_detalhes', {
                    p_id_item: props.initialData.id
                })
                if (error) throw error
                
                if (data) {
                    formData.value = {
                        ...data,
                        data_disponivel: data.data_disponivel ? data.data_disponivel.slice(0, 16) : null, // datetime-local format
                        data_entrega_limite: data.data_entrega_limite ? data.data_entrega_limite.slice(0, 16) : null,
                        tempo_questionario: data.tempo_questionario,
                        perguntas: data.perguntas || []
                    }
                    if (data.livro_digital) {
                        // Pre-populate selected book object (Partial data until full fetch or acceptable fallback)
                        selectedBook.value = {
                            id_edicao: data.id_bbtk_edicao,
                            titulo_principal: data.livro_digital.titulo || data.livro_digital.titulo_obra, // Check fallback
                            capa: data.livro_digital.capa, // If available from get_detalhes
                            editora: 'Carregado...', // Placeholder as detais might not have everything
                            autor_principal: '',
                            ano_edicao: ''
                        }
                    }
                }
            } catch (err) {
                console.error(err)
                toast.showToast('Erro ao carregar detalhes do item', 'error')
            } finally {
                isLoading.value = false
            }
        }
    }
})

const questionTypes = ['Dissertativa', 'Múltipla Escolha']

</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-[110] flex items-center justify-center p-4 sm:p-6 backdrop-blur-md bg-black/40" @click.self="emit('close')">
        <div class="bg-background w-full max-w-4xl rounded-3xl shadow-2xl border border-secondary/20 flex flex-col h-[90vh] font-inter overflow-hidden transform transition-all animate-in fade-in zoom-in duration-300">
            
            <!-- Chic Header -->
            <div class="px-8 py-6 border-b border-secondary/10 flex items-center justify-between shrink-0 bg-div-15/50">
                <div class="flex items-center gap-4">
                    <div class="w-12 h-12 rounded-2xl bg-primary/10 text-primary flex items-center justify-center shadow-inner">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect></svg>
                    </div>
                    <div>
                        <h2 class="text-xl font-black text-text tracking-tight">{{ initialData ? 'Editar Item' : 'Novo Item Acadêmico' }}</h2>
                        <p class="text-[10px] text-secondary font-bold uppercase tracking-[0.2em] mt-0.5">Recursos & Atividades</p>
                    </div>
                </div>
                <button @click="emit('close')" class="p-3 text-secondary hover:text-danger hover:bg-danger/5 rounded-2xl transition-all">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Modern Tabs -->
            <div v-if="formData.tipo === 'Questionário'" class="px-8 bg-div-15/30 border-b border-secondary/10 shrink-0">
                <div class="flex gap-8">
                    <button 
                        @click="activeTab = 'config'" 
                        class="relative py-4 text-xs font-black uppercase tracking-widest transition-all"
                        :class="activeTab === 'config' ? 'text-primary' : 'text-secondary hover:text-text'"
                    >
                        Configurações
                        <div v-if="activeTab === 'config'" class="absolute bottom-0 left-0 w-full h-1 bg-primary rounded-t-full shadow-[0_-2px_8px_rgba(var(--primary-rgb),0.5)]"></div>
                    </button>
                    <button 
                        @click="activeTab = 'perguntas'" 
                        class="relative py-4 text-xs font-black uppercase tracking-widest transition-all"
                        :class="activeTab === 'perguntas' ? 'text-primary' : 'text-secondary hover:text-text'"
                    >
                        Perguntas ({{ formData.perguntas.length }})
                        <div v-if="activeTab === 'perguntas'" class="absolute bottom-0 left-0 w-full h-1 bg-primary rounded-t-full shadow-[0_-2px_8px_rgba(var(--primary-rgb),0.5)]"></div>
                    </button>
                </div>
            </div>

            <!-- Body -->
            <div class="p-8 overflow-y-auto flex-1 scrollbar-thin space-y-8">
                
                <!-- Tab: Configurations -->
                <div v-show="activeTab === 'config'" class="space-y-8 animate-in fade-in slide-in-from-top-2 duration-300">
                    
                    <!-- Type Selection: Card Style -->
                    <div class="space-y-3">
                        <label class="text-[10px] font-black text-secondary uppercase tracking-[0.2em] pl-1">Tipo de Recurso</label>
                        <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                            <button 
                                v-for="t in ['Material', 'Tarefa', 'Questionário']" 
                                :key="t"
                                @click="formData.tipo = t"
                                class="p-4 rounded-2xl border-2 transition-all flex flex-col items-center gap-2 group"
                                :class="formData.tipo === t ? 'border-primary bg-primary/5 text-primary shadow-sm' : 'border-secondary/10 bg-div-15 text-secondary hover:border-secondary/30'"
                            >
                                <div class="w-10 h-10 rounded-xl bg-background flex items-center justify-center text-2xl shadow-inner group-hover:scale-110 transition-transform">
                                    {{ t === 'Tarefa' ? '📝' : t === 'Questionário' ? '❓' : '📄' }}
                                </div>
                                <span class="text-xs font-black uppercase tracking-tighter">{{ t }}</span>
                            </button>
                        </div>
                    </div>

                    <!-- Main Fields Group -->
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                        
                        <!-- Left Side: Basic Info -->
                        <div class="space-y-6">
                            <div class="space-y-2">
                                <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Título do Recurso</label>
                                <div class="relative group">
                                    <input v-model="formData.titulo" type="text" placeholder="Ex: Leitura do Capítulo 01" class="w-full px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl text-text font-bold text-sm focus:outline-none focus:border-primary/50 focus:ring-4 focus:ring-primary/5 transition-all shadow-sm">
                                </div>
                            </div>

                            <div class="space-y-2">
                                <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Conteúdo / Instruções</label>
                                <textarea v-model="formData.rich_text" rows="5" class="w-full px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl text-text text-sm focus:outline-none focus:border-primary/50 transition-all shadow-sm resize-none" placeholder="Descreva os objetivos, orientações ou cole o texto aqui..."></textarea>
                            </div>
                        </div>

                        <!-- Right Side: Links & Assets -->
                        <div class="space-y-6">
                            <div v-if="formData.tipo !== 'Questionário'" class="space-y-4">
                                <div class="space-y-2">
                                    <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Mídia Externa (Vídeo)</label>
                                    <div class="relative">
                                        <input v-model="formData.video_link" type="text" placeholder="URL do YouTube ou Vimeo" class="w-full px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl text-text text-sm focus:outline-none focus:border-primary/50 transition-all shadow-sm">
                                        <span class="absolute right-4 top-3 text-secondary/30">🎥</span>
                                    </div>
                                </div>

                                <div class="space-y-2">
                                    <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Link Complementar (URL)</label>
                                    <div class="relative">
                                        <input v-model="formData.url_externa" type="text" placeholder="https://exemplo.com" class="w-full px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl text-text text-sm focus:outline-none focus:border-primary/50 transition-all shadow-sm">
                                        <span class="absolute right-4 top-3 text-secondary/30">🔗</span>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Library Integration -->
                            <div v-if="formData.tipo === 'Material' || formData.tipo === 'Tarefa'" class="space-y-2">
                                 <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Vincular Livro Digital</label>
                                 
                                 <div v-if="!selectedBook" class="relative group">
                                    <input 
                                        type="text" 
                                        placeholder="Buscar no acervo digital..." 
                                        @input="onSearchLivro"
                                        class="w-full px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl text-text text-sm focus:outline-none focus:border-primary/50 transition-all shadow-sm pl-11"
                                    >
                                    <span class="absolute left-4 top-3.5 text-secondary/40 group-focus-within:text-primary transition-colors">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                    </span>
                                    
                                    <div v-if="livros.length > 0" class="absolute z-10 w-full mt-2 bg-background border border-secondary/10 rounded-2xl shadow-2xl overflow-hidden max-h-60 overflow-y-auto animate-in fade-in slide-in-from-top-2">
                                        <div 
                                            v-for="l in livros" 
                                            :key="l.id_edicao"
                                            @click="selectBook(l)"
                                            class="p-4 cursor-pointer hover:bg-primary/5 transition-all flex items-start gap-4 border-b border-secondary/5 last:border-0"
                                        >
                                            <div class="w-12 h-16 bg-div-30 rounded-lg overflow-hidden flex-shrink-0 border border-secondary/10 shadow-sm">
                                                <img v-if="l.capa" :src="getBookCoverUrl(l.capa)" class="w-full h-full object-cover">
                                                <div v-else class="w-full h-full flex items-center justify-center text-[8px] text-secondary text-center p-1 font-black">NAO CAPA</div>
                                            </div>
                                            <div class="flex flex-col min-w-0">
                                                <span class="font-black text-text text-xs leading-tight truncate uppercase">{{ l.titulo_principal }}</span>
                                                <span class="text-[10px] text-secondary font-bold mt-1">{{ l.autor_principal }}</span>
                                                <div class="flex items-center gap-2 mt-2">
                                                    <span class="text-[8px] font-black text-primary/70 uppercase tracking-widest bg-primary/5 px-1.5 py-0.5 rounded">{{ l.editora }}</span>
                                                    <span class="text-[8px] font-black text-secondary/50 uppercase">{{ l.ano_edicao }}</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Selected Book (Premium Card) -->
                                <div v-else class="p-5 bg-div-15 border border-primary/20 rounded-2xl relative group flex gap-5 items-center shadow-lg shadow-primary/5">
                                    <div class="w-16 h-24 bg-background rounded-xl overflow-hidden flex-shrink-0 border border-secondary/10 shadow-md group-hover:scale-105 transition-transform duration-300">
                                        <img v-if="selectedBook.capa" :src="getBookCoverUrl(selectedBook.capa)" class="w-full h-full object-cover">
                                        <div v-else class="w-full h-full flex items-center justify-center text-[10px] text-secondary text-center p-2 bg-div-30 font-black">NAO CAPA</div>
                                    </div>
                                    <div class="flex flex-col min-w-0">
                                        <span class="text-[9px] font-black text-primary uppercase tracking-[0.2em]">Acervo Digital</span>
                                        <h4 class="font-black text-text text-sm leading-tight mt-1 truncate uppercase">{{ selectedBook.titulo_principal }}</h4>
                                        <span class="text-[10px] text-secondary font-bold mt-1">{{ selectedBook.autor_principal || 'Autor Desconhecido' }}</span>
                                        <div class="flex items-center gap-2 mt-3">
                                            <span class="text-[8px] font-black text-button-text bg-secondary/80 px-2 py-0.5 rounded uppercase">{{ selectedBook.editora || 'N/A' }}</span>
                                        </div>
                                    </div>
                                    <button @click="removeBook" class="absolute -top-2 -right-2 p-2 bg-background border border-danger/20 text-danger hover:bg-danger hover:text-white rounded-full shadow-lg transition-all scale-0 group-hover:scale-100">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Scheduling & Scoring Group -->
                    <div v-if="formData.tipo !== 'Material'" class="p-6 bg-div-15 rounded-3xl border border-secondary/10 space-y-6">
                        <div class="flex items-center gap-3 mb-2">
                            <div class="w-1.5 h-6 bg-primary rounded-full"></div>
                            <h4 class="text-[10px] font-black text-text uppercase tracking-widest">Prazos & Avaliação</h4>
                        </div>
                        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                            <div class="space-y-2">
                                <label class="text-[11px] font-black text-secondary uppercase tracking-tighter pl-1">Início (Acesso)</label>
                                <input v-model="formData.data_disponivel" type="datetime-local" class="w-full px-4 py-3 bg-background border border-secondary/10 rounded-2xl text-text font-bold text-sm focus:outline-none focus:border-primary/50 shadow-inner">
                            </div>
                            <div class="space-y-2">
                                <label class="text-[11px] font-black text-secondary uppercase tracking-tighter pl-1">Fim (Entrega)</label>
                                <input v-model="formData.data_entrega_limite" type="datetime-local" class="w-full px-4 py-3 bg-background border border-secondary/10 rounded-2xl text-text font-bold text-sm focus:outline-none focus:border-primary/50 shadow-inner">
                            </div>
                            <div class="space-y-2">
                                <label class="text-[11px] font-black text-secondary uppercase tracking-tighter pl-1">Nota Máxima</label>
                                <div class="relative">
                                    <input v-model="formData.pontuacao_maxima" type="number" step="0.5" class="w-full px-4 py-3 bg-background border border-secondary/10 rounded-2xl text-text font-bold text-sm focus:outline-none focus:border-primary/50 shadow-inner">
                                    <span class="absolute right-4 top-3.5 text-xs text-secondary/30">🏆</span>
                                </div>
                            </div>
                            <div v-if="formData.tipo === 'Questionário'" class="space-y-2">
                                <label class="text-[11px] font-black text-secondary uppercase tracking-tighter pl-1">Tempo (Min)</label>
                                <div class="relative">
                                    <input v-model="formData.tempo_questionario" type="number" step="1" min="1" placeholder="Livre" class="w-full px-4 py-3 bg-background border border-secondary/10 rounded-2xl text-text font-bold text-sm focus:outline-none focus:border-primary/50 shadow-inner">
                                    <span class="absolute right-4 top-3.5 text-xs text-secondary/30">🕙</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tab: Questionnaire Builder -->
                <div v-show="activeTab === 'perguntas'" class="space-y-8 animate-in fade-in slide-in-from-top-2 duration-300">
                     
                     <div v-for="(pergunta, idx) in formData.perguntas" :key="idx" class="relative group/q bg-background border border-secondary/10 rounded-3xl overflow-hidden shadow-sm hover:shadow-xl hover:border-primary/20 transition-all">
                        
                        <!-- Question Header Indicator -->
                        <div class="h-2 w-full bg-secondary/5 group-hover/q:bg-primary/20 transition-colors"></div>
                        
                        <!-- Controls -->
                        <div class="absolute right-6 top-6 flex items-center gap-2 opacity-100 lg:opacity-0 group-hover/q:opacity-100 transition-all">
                            <div class="flex items-center gap-1 bg-div-15 p-1 rounded-xl shadow-inner border border-secondary/10">
                                <button @click="moveQuestion(idx, -1)" :disabled="idx === 0" class="p-2 text-secondary hover:text-primary disabled:opacity-30 rounded-lg hover:bg-background transition-all">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg>
                                </button>
                                <button @click="moveQuestion(idx, 1)" :disabled="idx === formData.perguntas.length -1" class="p-2 text-secondary hover:text-primary disabled:opacity-30 rounded-lg hover:bg-background transition-all">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                </button>
                            </div>
                            <button @click="removeQuestion(idx)" class="p-3 bg-danger/5 text-danger hover:bg-danger hover:text-white rounded-xl transition-all shadow-sm">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                            </button>
                        </div>
                        
                        <div class="p-8 pt-6 space-y-6">
                             
                             <div class="flex items-center gap-3">
                                 <div class="flex items-center justify-center w-8 h-8 rounded-full bg-primary/10 text-primary font-black text-xs shadow-inner">
                                     {{ idx + 1 }}
                                 </div>
                                 <h4 class="text-[10px] font-black text-secondary uppercase tracking-[0.2em]">Configurações da Questão</h4>
                             </div>

                             <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                                 <div class="md:col-span-2 space-y-2">
                                     <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Enunciado da Questão</label>
                                     <textarea v-model="pergunta.enunciado" rows="3" class="w-full px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl text-text font-bold text-sm focus:outline-none focus:border-primary/50 transition-all shadow-sm resize-none" placeholder="Qual a pergunta a ser feita?"></textarea>
                                 </div>
                                 <div class="space-y-6">
                                    <div class="space-y-2">
                                        <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1">Tipo de Resposta</label>
                                        <select v-model="pergunta.tipo" class="w-full px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl text-text font-bold text-xs focus:outline-none focus:border-primary/50 transition-all shadow-sm appearance-none">
                                            <option v-for="t in questionTypes" :key="t" :value="t">{{ t }}</option>
                                        </select>
                                    </div>
                                    <div class="flex items-center justify-between px-4 py-3 bg-div-15 border border-secondary/10 rounded-2xl shadow-sm">
                                        <span class="text-[10px] font-black text-secondary uppercase">Obrigatória</span>
                                        <label class="relative inline-flex items-center cursor-pointer">
                                            <input type="checkbox" v-model="pergunta.obrigatoria" class="sr-only peer">
                                            <div class="w-10 h-5 bg-secondary/20 rounded-full peer peer-checked:bg-primary after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:after:translate-x-full"></div>
                                        </label>
                                    </div>
                                 </div>
                             </div>

                             <!-- Dynamic Logic: Options -->
                             <div v-if="pergunta.tipo === 'Múltipla Escolha'" class="space-y-4 pt-4 border-t border-secondary/5">
                                 <div class="flex items-center justify-between px-2">
                                     <label class="text-[10px] font-black text-primary uppercase tracking-widest">Opções & Gabarito</label>
                                     <button @click="addOption(pergunta)" class="text-[10px] font-black text-primary hover:text-primary-hover flex items-center gap-2 tracking-widest uppercase">
                                         + Adicionar Alternativa
                                     </button>
                                 </div>
                                 <div class="grid grid-cols-1 gap-3">
                                     <div v-for="(opt, optIdx) in pergunta.opcoes" :key="optIdx" class="group/opt flex items-center gap-3 bg-div-15/50 p-3 rounded-2xl border border-secondary/5 transition-all hover:bg-div-15 hover:border-primary/20">
                                         <div class="relative">
                                            <input type="radio" :name="'correct-'+idx" :checked="opt.correta" @change="pergunta.opcoes.forEach(o => o.correta = false); opt.correta = true" class="w-5 h-5 accent-primary cursor-pointer">
                                         </div>
                                         <input v-model="opt.texto" type="text" class="flex-1 bg-transparent border-none text-sm font-bold text-text focus:ring-0 placeholder-secondary/30" placeholder="Digite a alternativa...">
                                         <button @click="removeOption(pergunta, optIdx)" class="p-2 opacity-0 group-hover/opt:opacity-100 transition-opacity text-secondary hover:text-danger">
                                             <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                         </button>
                                     </div>
                                 </div>
                             </div>
                             
                             <!-- Media Support -->
                             <div class="space-y-2 pt-4 border-t border-secondary/5">
                                <label class="text-[10px] font-black text-secondary uppercase tracking-widest pl-1 flex items-center gap-2">
                                    Imagem de Referência
                                    <span class="font-normal text-[8px] opacity-50 lowercase tracking-normal">(opcional)</span>
                                </label>
                                <div class="relative group">
                                    <input v-model="pergunta.caminho_imagem" type="text" placeholder="Cole o link da imagem aqui..." class="w-full px-4 py-2.5 bg-div-15 border border-secondary/10 rounded-xl text-text font-bold text-[10px] focus:outline-none focus:border-primary/50 shadow-inner">
                                    <span class="absolute right-4 top-2.5 opacity-30">🖼️</span>
                                </div>
                             </div>
                        </div>
                     </div>

                     <button @click="addQuestion" class="group w-full py-8 border-2 border-dashed border-secondary/20 rounded-3xl text-secondary hover:border-primary hover:bg-primary/5 hover:text-primary transition-all duration-300 flex flex-col items-center justify-center gap-3">
                        <div class="w-12 h-12 rounded-full bg-secondary/10 group-hover:bg-primary/20 flex items-center justify-center transition-colors">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                        </div>
                        <span class="text-xs font-black uppercase tracking-[0.3em]">Nova Pergunta Acadêmica</span>
                     </button>
                </div>

            </div>

            <!-- Chic Footer -->
            <div class="px-8 py-6 border-t border-secondary/10 flex items-center justify-between bg-div-15/50 shrink-0">
                <div class="hidden sm:flex items-center gap-3">
                    <div class="w-1.5 h-1.5 rounded-full bg-primary animate-pulse"></div>
                    <span class="text-[10px] font-black text-secondary uppercase tracking-widest">Status: Pronto para salvar</span>
                </div>
                <div class="flex items-center gap-4 w-full sm:w-auto">
                    <button @click="emit('close')" class="flex-1 sm:flex-none px-6 py-3 text-secondary font-black text-xs uppercase tracking-widest hover:text-text transition-colors">Descartar</button>
                    <button 
                        @click="handleSave" 
                        :disabled="isLoading" 
                        class="flex-1 sm:flex-none px-12 py-3 bg-primary text-white font-black text-xs uppercase tracking-widest rounded-2xl hover:bg-primary-hover shadow-lg shadow-primary/20 hover:shadow-primary/30 transform hover:scale-[1.02] transition-all flex items-center justify-center gap-3 disabled:opacity-50"
                    >
                        <span v-if="isLoading" class="animate-spin text-lg">⌛</span>
                        <span>{{ initialData ? 'Salvar Edição' : 'Criar Recurso' }}</span>
                    </button>
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

select {
 background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
 background-repeat: no-repeat;
 background-position: right 1rem center;
 background-size: 1rem;
}

.animate-fadeIn {
    animation: fadeIn 0.3s ease-out;
}
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(-5px); }
    to { opacity: 1; transform: translateY(0); }
}
.field-sizing-content {
    field-sizing: content;
    min-height: 80px;
}
</style>
