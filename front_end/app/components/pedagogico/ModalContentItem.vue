<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps<{
    isOpen: boolean
    initialData?: any
    folderId?: string
}>()

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

// State
const activeTab = ref('config') // config, perguntas
const books = ref<any[]>([])
const selectedBook = ref<any>(null)
let bookSearchTimer: any

const itemTypes = ['Material', 'Tarefa', 'Questionário']
const questionTypes = ['Dissertativa', 'Múltipla Escolha']
const imageBaseUrl = ref('')

const fetchImageHash = async () => {
    try {
        const data = await $fetch('/api/biblioteca/hash') as any
        if (data && data.url) {
            imageBaseUrl.value = data.url
        }
    } catch (e) {
        console.error('Error fetching image hash:', e)
    }
}

interface Option {
    id: any
    texto: string
    correta: boolean
    ordem: number
}

interface Question {
    id: any
    enunciado: string
    tipo: string
    obrigatoria: boolean
    ordem: number
    opcoes: Option[]
}

const form = ref({
    tipo: 'Material',
    titulo: '',
    descricao: '', // rich_text in legacy
    url_externa: '',
    video_link: '',
    id_bbtk_edicao: null as string | null,
    pontuacao_maxima: 0,
    tempo_questionario: undefined as number | undefined,
    data_disponivel: '',
    data_entrega_limite: '',
    perguntas: [] as Question[]
})

// --- Logic for Livro Search ---
const isSearchingBooks = ref(false)
const searchBooks = async (term: string) => {
    if (!term || term.length < 3) return
    isSearchingBooks.value = true
    try {
        const result = await $fetch('/api/biblioteca/livros/busca', {
            params: {
                id_empresa: appStore.company?.empresa_id,
                busca: term,
                limite: 10
            }
        }) as any
        books.value = result.items || []
    } catch (e) {
        console.error(e)
        books.value = []
    } finally {
        isSearchingBooks.value = false
    }
}

const onBookSearch = (val: string) => {
    clearTimeout(bookSearchTimer)
    bookSearchTimer = setTimeout(() => searchBooks(val), 500)
}

const selectBook = (book: any) => {
    selectedBook.value = book
    form.value.id_bbtk_edicao = book.id_edicao
    books.value = []
}

const removeBook = () => {
    selectedBook.value = null
    form.value.id_bbtk_edicao = null
}

const getBookCoverUrl = (capa: string) => {
    if (!capa) return ''
    if (capa.startsWith('http')) return capa
    
    if (imageBaseUrl.value) {
        return `${imageBaseUrl.value}${capa}`
    }

    const baseUrl = 'https://caruaru.conectetecnologia.app' // Fallback hardcoded
    return `${baseUrl}/storage/v1/object/public/bbtk-capas/${capa}`
}

// --- Logic for Questions ---
const addQuestion = () => {
    form.value.perguntas.push({
        id: null,
        enunciado: '',
        tipo: 'Dissertativa',
        obrigatoria: true,
        ordem: form.value.perguntas.length + 1,
        opcoes: []
    })
}

const removeQuestion = (index: number) => {
    form.value.perguntas.splice(index, 1)
}

const addOption = (question: any) => {
    if (!question.opcoes) question.opcoes = []
    question.opcoes.push({
        id: null,
        texto: '',
        correta: false,
        ordem: question.opcoes.length + 1
    })
}

const removeOption = (question: any, idx: number) => {
    question.opcoes.splice(idx, 1)
}

const moveQuestion = (index: number, direction: number) => {
    const newIndex = index + direction
    if (newIndex >= 0 && newIndex < form.value.perguntas.length) {
        const item = form.value.perguntas.splice(index, 1)[0]
        if (item) {
            form.value.perguntas.splice(newIndex, 0, item)
            // Reorder
            form.value.perguntas.forEach((p, i) => p.ordem = i + 1)
        }
    }
}

// Watchers
watch(() => props.isOpen, (val) => {
    if (val) {
        fetchImageHash()
        if (props.initialData) {
            // Populate form
            form.value = {
                tipo: props.initialData.tipo || 'Material',
                titulo: props.initialData.titulo,
                descricao: props.initialData.rich_text || '',
                url_externa: props.initialData.url_externa || '',
                video_link: props.initialData.video_link || '',
                id_bbtk_edicao: props.initialData.id_bbtk_edicao,
                pontuacao_maxima: props.initialData.pontuacao_maxima || 0,
                tempo_questionario: props.initialData.tempo_questionario ?? undefined,
                data_disponivel: props.initialData.data_disponivel ? props.initialData.data_disponivel.slice(0, 16) : '',
                data_entrega_limite: props.initialData.data_entrega_limite ? props.initialData.data_entrega_limite.slice(0, 16) : '',
                perguntas: props.initialData.perguntas || []
            }
        } else {
            // Reset
            form.value = {
                tipo: 'Material',
                titulo: '',
                descricao: '',
                url_externa: '',
                video_link: '',
                id_bbtk_edicao: null,
                pontuacao_maxima: 0,
                tempo_questionario: undefined,
                data_disponivel: '',
                data_entrega_limite: '',
                perguntas: []
            }
            activeTab.value = 'config'
            selectedBook.value = null
        }
    }
})

// Mock save for now as requested "não vamos fazer ele enviar nada ainda"
const handleSave = () => {
    console.log('Save triggered with payload:', form.value)
    // emit('success') // Uncomment when ready
    toast.showToast('Funcionalidade de salvar será implementada em breve.', 'info')
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-[110] flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" @click.self="emit('close')">
        <div class="bg-background w-full max-w-4xl rounded shadow-2xl border border-[#6B82A71A] flex flex-col h-[90vh] overflow-hidden transform transition-all animate-in fade-in zoom-in duration-200">
            
            <!-- Header -->
            <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between shrink-0 bg-div-15">
                <div class="flex items-center gap-4">
                    <div class="w-10 h-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center shadow-sm text-xl">
                        {{ initialData ? '📝' : '✨' }}
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-text">{{ initialData ? 'Editar Item' : 'Novo Recurso' }}</h2>
                        <p class="text-xs text-secondary font-medium mt-0.5">Recursos & Atividades</p>
                    </div>
                </div>
                <button @click="emit('close')" class="p-2 text-secondary hover:text-danger hover:bg-danger/10 rounded-lg transition-colors">
                     <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Top Level Tabs (Type Selection) -->
            <div class="flex items-center px-6 border-b border-div-15 bg-div-05 shrink-0">
                <button 
                    v-for="t in itemTypes" 
                    :key="t"
                    @click="form.tipo = t"
                    class="px-4 py-3 text-sm font-bold border-b-2 transition-colors relative"
                    :class="form.tipo === t ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'"
                >
                    {{ t }}
                </button>
            </div>

            <!-- Sub Tabs for Questionnaire (Only if Type == Questionário) -->
            <div v-if="form.tipo === 'Questionário'" class="px-6 border-b border-[#6B82A71A] shrink-0 bg-background text-xs">
                <div class="flex gap-6">
                    <button 
                        @click="activeTab = 'config'" 
                        class="relative py-3 transition-all border-b-2"
                        :class="activeTab === 'config' ? 'text-primary border-primary font-bold' : 'text-secondary border-transparent hover:text-text font-medium'"
                    >
                        Configurações
                    </button>
                    <button 
                        @click="activeTab = 'perguntas'" 
                        class="relative py-3 transition-all border-b-2"
                        :class="activeTab === 'perguntas' ? 'text-primary border-primary font-bold' : 'text-secondary border-transparent hover:text-text font-medium'"
                    >
                        Perguntas ({{ form.perguntas.length }})
                    </button>
                </div>
            </div>

            <!-- Body -->
            <div class="p-6 overflow-y-auto flex-1 scrollbar-thin flex flex-col gap-6">
                
                <!-- Tab: Configurations -->
                <div v-show="activeTab === 'config' || form.tipo !== 'Questionário'" class="flex flex-col gap-6 animate-in fade-in slide-in-from-top-2 duration-200">


                    <div class="flex flex-col gap-6">
                        <!-- Row 1: Title -->
                         <div class="w-full">
                            <ManagerField 
                                label="Título do Recurso"
                                v-model="form.titulo"
                                placeholder="Ex: Leitura do Capítulo 01"
                            />
                         </div>

                        <!-- Row 2: Description -->
                        <div class="w-full">
                            <ManagerField 
                                label="Conteúdo / Instruções"
                                v-model="form.descricao"
                                type="textarea"
                                placeholder="Descreva os objetivos, orientações ou cole o texto aqui..."
                            />
                        </div>

                         <!-- Row 3: Links (Side by Side) -->
                        <div v-if="form.tipo !== 'Questionário'" class="grid grid-cols-1 sm:grid-cols-2 gap-5">
                             <ManagerField 
                                label="Mídia Externa (Vídeo)"
                                v-model="form.video_link"
                                placeholder="URL do YouTube ou Vimeo"
                            />
                            <ManagerField 
                                label="Link Complementar (URL)"
                                v-model="form.url_externa"
                                placeholder="https://exemplo.com"
                            />
                        </div>

                        <!-- Row 4: Settings (Deadlines/Score) - Moved Up & Solid BG -->
                        <div v-if="form.tipo !== 'Material'" class="p-4 bg-div-15 rounded border border-[#6B82A71A] flex flex-col gap-4">
                             <div class="flex items-center gap-2">
                                <div class="w-1 h-4 bg-primary rounded-full"></div>
                                <h4 class="text-[10px] font-black text-text uppercase tracking-widest">Prazos & Avaliação</h4>
                            </div>
                            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                                <ManagerField 
                                    label="Início (Acesso)"
                                    v-model="form.data_disponivel"
                                    type="datetime-local"
                                />
                                <ManagerField 
                                    label="Fim (Entrega)"
                                    v-model="form.data_entrega_limite"
                                    type="datetime-local"
                                />
                                <ManagerField 
                                    label="Nota Máxima"
                                    v-model="form.pontuacao_maxima"
                                    type="number"
                                    placeholder="0"
                                />
                                 <div v-if="form.tipo === 'Questionário'">
                                    <ManagerField 
                                        label="Tempo (Min)"
                                        v-model="form.tempo_questionario"
                                        type="number"
                                        placeholder="Livre"
                                    />
                                 </div>
                            </div>
                        </div>

                        <!-- Row 5: Library Integration (Full Width) - Moved Down -->
                         <div v-if="form.tipo === 'Material' || form.tipo === 'Tarefa'" class="w-full flex flex-col gap-2">
                            <label class="text-[10px] font-black text-secondary uppercase tracking-[0.15em] pl-1">Vincular Livro Digital</label>
                            
                            <div v-if="!selectedBook" class="relative group">
                                 <input 
                                    type="text" 
                                    placeholder="Buscar no acervo digital..." 
                                    @input="(e) => onBookSearch((e.target as HTMLInputElement).value)"
                                    class="w-full px-4 py-3 bg-background border border-[#6B82A71A] rounded text-text text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 transition-all pl-11"
                                >
                                <span class="absolute left-4 top-3.5 text-secondary/40">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                </span>

                                <div v-if="books.length > 0" class="absolute z-10 w-full mt-1 bg-background border border-[#6B82A71A] rounded shadow-xl overflow-hidden max-h-60 overflow-y-auto">
                                    <!-- Book items here -->
                                    <div 
                                        v-for="b in books" 
                                        :key="b.id_edicao" 
                                        @click="selectBook(b)" 
                                        class="p-3 hover:bg-div-15 cursor-pointer flex gap-3 border-b border-div-15 last:border-0 items-start"
                                    >
                                        <div class="w-8 h-12 bg-div-30 rounded shrink-0 overflow-hidden border border-[#6B82A71A]">
                                             <img v-if="b.capa" :src="getBookCoverUrl(b.capa)" class="w-full h-full object-cover">
                                             <div v-else class="w-full h-full flex items-center justify-center text-[6px] text-secondary font-black">CAPA</div>
                                        </div>
                                        <div class="flex flex-col">
                                            <span class="text-xs font-bold text-text uppercase">{{ b.titulo_principal }}</span>
                                            <span class="text-[10px] text-secondary">{{ b.autor_principal }}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- Selected Book Card -->
                            <div v-else class="p-4 bg-div-15/50 border border-primary/20 rounded relative flex gap-4 items-center group">
                                <div class="w-12 h-16 bg-background rounded overflow-hidden shrink-0 border border-[#6B82A71A] shadow-sm">
                                     <img v-if="selectedBook.capa" :src="getBookCoverUrl(selectedBook.capa)" class="w-full h-full object-cover">
                                     <div v-else class="w-full h-full flex items-center justify-center text-[8px] text-secondary font-black bg-div-30">CAPA</div>
                                </div>
                                <div class="flex flex-col min-w-0">
                                     <span class="text-[9px] font-black text-primary uppercase tracking-widest">Livro Vinculado</span>
                                     <h4 class="font-bold text-text text-sm leading-tight uppercase mt-0.5">{{ selectedBook.titulo_principal }}</h4>
                                     <span class="text-[10px] text-secondary mt-0.5">{{ selectedBook.autor_principal }}</span>
                                </div>
                                <button @click="removeBook" class="ml-auto p-2 text-secondary hover:text-danger hover:bg-danger/10 rounded transition-all opacity-0 group-hover:opacity-100">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                </button>
                            </div>
                         </div>

                    </div>

                </div>

                <!-- Tab: Questions -->
                <div v-show="activeTab === 'perguntas'" class="flex flex-col gap-4 animate-in fade-in slide-in-from-top-2 duration-200">
                     <div v-for="(pergunta, idx) in form.perguntas" :key="idx" class="relative group/q bg-background border border-[#6B82A71A] rounded overflow-hidden p-5 space-y-4 hover:border-primary/30 transition-all">
                        <div class="flex justify-between items-start">
                             <div class="flex items-center gap-3">
                                 <div class="flex items-center justify-center w-6 h-6 rounded bg-primary/10 text-primary font-bold text-xs">
                                     {{ idx + 1 }}
                                 </div>
                                 <h4 class="text-[10px] font-black text-secondary uppercase tracking-[0.15em]">Questão</h4>
                             </div>
                             <div class="flex gap-2">
                                <button @click="removeQuestion(idx)" class="text-xs font-bold text-danger hover:underline">Excluir</button>
                             </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                             <div class="md:col-span-2">
                                <ManagerField 
                                    label="Enunciado"
                                    v-model="pergunta.enunciado"
                                    type="textarea"
                                    placeholder="Qual a pergunta?"
                                />
                             </div>
                             <div class="flex flex-col gap-3">
                                <ManagerField 
                                    label="Tipo"
                                    v-model="pergunta.tipo"
                                    type="select"
                                    :options="questionTypes.map(t => ({ value: t, label: t }))"
                                />
                                <div class="flex items-center justify-between px-3 py-2 bg-div-15 rounded border border-[#6B82A71A]">
                                    <span class="text-[10px] font-black text-secondary uppercase">Obrigatória</span>
                                    <input type="checkbox" v-model="pergunta.obrigatoria" class="toggle toggle-primary toggle-sm">
                                </div>
                             </div>
                        </div>
                        
                        <!-- Options if Multiple Choice -->
                        <div v-if="pergunta.tipo === 'Múltipla Escolha'" class="pt-3 border-t border-[#6B82A71A] flex flex-col gap-2">
                             <div class="flex justify-between">
                                 <label class="text-[10px] font-black text-primary uppercase">Alternativas</label>
                                 <button @click="addOption(pergunta)" class="text-[10px] font-black text-primary uppercase hover:underline">+ Adicionar</button>
                             </div>
                             <div v-for="(opt, optionIndex) in pergunta.opcoes" :key="optionIndex" class="flex items-center gap-3 bg-div-15/30 p-2 rounded border border-[#6B82A71A]">
                                 <input type="radio" :name="'correct-'+idx" :checked="opt.correta" @change="pergunta.opcoes.forEach((o) => o.correta = false); opt.correta = true" class="radio radio-primary radio-sm">
                                 <input v-model="opt.texto" type="text" class="flex-1 bg-transparent border-none text-xs font-bold text-text focus:outline-none" placeholder="Texto da alternativa...">
                                 <button @click="removeOption(pergunta, optionIndex)" class="text-secondary hover:text-danger">✕</button>
                             </div>
                        </div>

                     </div>

                     <button @click="addQuestion" class="w-full py-4 border border-dashed border-[#6B82A71A] rounded bg-background text-secondary hover:border-primary hover:bg-primary/5 hover:text-primary transition-all flex items-center justify-center gap-2">
                        <span class="text-lg font-bold">+</span>
                        <span class="text-xs font-black uppercase tracking-[0.15em]">Nova Pergunta</span>
                     </button>
                </div>

            </div>

            <!-- Footer -->
            <div class="px-6 py-4 border-t border-[#6B82A71A] bg-div-15 flex justify-end gap-3 shrink-0">
                <button @click="emit('close')" class="px-6 py-2.5 rounded hover:bg-div-30 transition-colors text-sm font-bold text-secondary">Cancelar</button>
                <button @click="handleSave" class="px-6 py-2.5 rounded bg-primary text-white font-bold hover:brightness-110 shadow-lg shadow-primary/20 transition-all text-sm">
                    {{ initialData ? 'Salvar Edição' : 'Criar Recurso' }}
                </button>
            </div>

        </div>
    </div>
</template>

<style scoped>
/* Scrollbar */
.scrollbar-thin::-webkit-scrollbar {
  width: 4px;
}
.scrollbar-thin::-webkit-scrollbar {
  width: 4px;
}
.scrollbar-thin::-webkit-scrollbar-thumb {
  background: rgba(107, 130, 167, 0.2);
  border-radius: 4px;
}
</style>
