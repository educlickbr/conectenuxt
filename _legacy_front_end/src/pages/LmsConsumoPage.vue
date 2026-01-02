<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'
import FullPageMenu from '../components/FullPageMenu.vue'
import { useRouter } from 'vue-router'

const appStore = useAppStore()
const toast = useToastStore()
const router = useRouter()

// Data
const contents = ref([])
const isLoading = ref(true)
const isMenuOpen = ref(false)
const itemsLoading = ref({})

// State
const user = ref(null)
const activeItem = ref(null) // The item currently being "played"
const isLoadingContent = ref(false)
const answers = ref({}) // Stores user answers locally before submission

const fetchContents = async () => {
    isLoading.value = true
    try {
        const { data: { user: authUser } } = await supabase.auth.getUser()
        if (!authUser) throw new Error('Usuário não autenticado')
        user.value = authUser

        const { data, error } = await supabase.rpc('lms_consumo_get', {
            p_id_empresa: appStore.id_empresa,
            p_user_id: authUser.id
        })

        if (error) throw error
        // Initialize state
        contents.value = (data || []).map(c => ({ 
            ...c, 
            items: [], 
            itemsLoaded: false,
            isOpen: false 
        }))
    } catch (error) {
        toast.showToast('Erro ao carregar conteúdos', 'error')
        console.error(error)
    } finally {
        isLoading.value = false
    }
}

const toggleContent = async (content) => {
    // Toggle logic
    if (content.isOpen) {
        content.isOpen = false
        return
    }

    // Open logic
    content.isOpen = true

    // Load items if not loaded
    if (!content.itemsLoaded) {
        itemsLoading.value[content.id] = true
        try {
            const { data, error } = await supabase.rpc('lms_itens_get', {
                p_id_empresa: appStore.id_empresa,
                p_user_id: user.value.id,
                p_conteudo_id: content.id
            })
            
            if (error) throw error
            content.items = data || []
            content.itemsLoaded = true
        } catch (err) {
            console.error(err)
            toast.showToast('Erro ao carregar itens', 'error')
            content.isOpen = false // Revert open on error
        } finally {
            itemsLoading.value[content.id] = false
        }
    }
}

// Action Handlers
const handleItemClick = async (item) => {
    // Set active item to switch layout to "Player Mode"
    // Shallow copy first to show title immediately
    activeItem.value = { ...item }
    
    // Fetch full details (especially for Quizzes or if we need more info not in list)
    if (item.tipo === 'Questionário' || item.tipo === 'Questionario') {
         await fetchQuizDetails(item.id)
    }
}

const fetchQuizDetails = async (itemId) => {
    isLoadingContent.value = true
    try {
        const { data, error } = await supabase.rpc('lms_quiz_get_content', {
            p_item_id: itemId,
            p_user_id: user.value.id,
            p_id_empresa: appStore.id_empresa
        })
        
        if (error) throw error
        
        // Merge details into activeItem
        if (activeItem.value && activeItem.value.id === itemId) {
            activeItem.value = { ...activeItem.value, ...data }
            
            // Initialize answers structure
            answers.value = {} // Reset for this item
            
            if (activeItem.value.perguntas) {
                activeItem.value.perguntas.forEach(p => {
                    // Populate local answers from backend if available (resume)
                    if (p.resposta_usuario && (p.resposta_usuario.id_resposta_possivel || p.resposta_usuario.texto_resposta)) {
                        answers.value[p.id] = { ...p.resposta_usuario }
                    } else {
                        // Empty init
                        answers.value[p.id] = { id_resposta_possivel: null, texto_resposta: '' }
                    }
                })
            }
        }
    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao carregar detalhes do quiz', 'error')
    } finally {
        isLoadingContent.value = false
    }
}

const closePlayer = () => {
    activeItem.value = null
    answers.value = {}
}

const startQuiz = async (item) => {
    if (!confirm(`Deseja iniciar o questionário "${item.titulo}"?`)) return

    try {
        const { data, error } = await supabase.rpc('lms_quiz_start', {
            p_user_id: user.value.id,
            p_item_id: item.id,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        if (data.status === 'created' || data.status === 'exists' || data.status === 'resumed') {
             toast.showToast('Questionário iniciado!', 'success')
             // Refresh details to get questions and status update
             await fetchQuizDetails(item.id)
        }
    } catch (error) {
        toast.showToast('Erro ao iniciar questionário', 'error')
        console.error(error)
    }
}

const submitQuiz = async (item) => {
    if (!confirm('Deseja finalizar o questionário? Você não poderá alterar suas respostas depois.')) return

    // Prepare batch payload
    const respostasParaEnviar = []
    
    if (activeItem.value && activeItem.value.perguntas) {
        activeItem.value.perguntas.forEach(p => {
             const ans = answers.value[p.id]
             if (ans) {
                 respostasParaEnviar.push({
                     id_pergunta: p.id,
                     id_resposta_possivel: ans.id_resposta_possivel,
                     texto_resposta: ans.texto_resposta
                 })
             }
        })
    }

    try {
        const { data, error } = await supabase.rpc('lms_quiz_submit_batch', {
            p_user_id: user.value.id,
            p_item_id: item.id,
            p_respostas: respostasParaEnviar,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        toast.showToast(`Quiz finalizado! Nota: ${data.nota}`, 'success')
        await fetchQuizDetails(item.id)

    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao finalizar quiz', 'error')
    }
}

const resetQuiz = async (item) => {
    if (!confirm('Deseja reiniciar este questionário? Todo o progresso será perdido.')) return

    try {
        const { error } = await supabase.rpc('lms_quiz_reset', {
            p_user_id: user.value.id,
            p_item_id: item.id,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        toast.showToast('Questionário reiniciado.', 'success')
        activeItem.value.submissao = null // Reset local state force
        await fetchQuizDetails(item.id)

    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao reiniciar quiz', 'error')
    }
}

const openExternal = (url) => {
    if(url) window.open(url, '_blank')
}

onMounted(() => {
    fetchContents()
})
</script>

<template>
    <div class="h-screen bg-background p-6 flex flex-col gap-6 relative overflow-hidden">
        
        <!-- Header -->
        <div class="shrink-0 z-30 bg-div-15 backdrop-blur-2xl p-4 rounded-xl border border-secondary shadow-sm flex items-center justify-between transition-all duration-300">
            <div class="flex items-center gap-4">
                 <div class="w-12 h-12 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-2xl">
                    🎓
                 </div>
                 <div>
                    <h1 class="text-xl font-bold text-text">Conteúdo Digital</h1>
                    <p class="text-sm text-secondary">Acesse seus cursos e materiais.</p>
                 </div>
            </div>
            
            <button @click="isMenuOpen = !isMenuOpen" class="p-2 text-secondary hover:text-primary hover:bg-div-30 rounded-lg transition-colors" title="Menu">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
            </button>
        </div>

        <!-- Main Workspace -->
        <main class="flex-1 flex overflow-hidden">
            
            <!-- Navigation Sidebar / Center List -->
            <!-- Transitions smoothly between centered list and sidebar -->
            <div 
                class="flex-shrink-0 transition-all duration-500 ease-in-out scrollbar-thin overflow-y-auto p-6"
                :class="activeItem ? 'w-full md:w-[400px] border-r border-secondary/10' : 'w-full max-w-4xl mx-auto'"
            >
                <!-- Loading State -->
                <div v-if="isLoading" class="flex justify-center p-10">
                    <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
                </div>

                <!-- Empty State -->
                <div v-else-if="contents.length === 0" class="flex flex-col items-center justify-center p-12 text-secondary opacity-50">
                     <p>Nenhum conteúdo disponível.</p>
                </div>

                <!-- Accordion List -->
                <div v-else class="flex flex-col gap-4">
                    <div 
                        v-for="content in contents" 
                        :key="content.id"
                        class="bg-div-15 rounded-lg border transition-all duration-300 overflow-hidden"
                        :class="[
                            content.isOpen ? 'border-primary/50 ring-1 ring-primary/20 shadow-lg shadow-primary/5' : 'border-secondary/20 hover:border-secondary/40'
                        ]"
                    >
                        <!-- Content Header (Toggle) -->
                        <div 
                            @click="toggleContent(content)"
                            class="p-4 flex items-center justify-between cursor-pointer select-none group"
                        >
                            <div class="flex items-center gap-3">
                                <!-- Drag/Grip Icon (Visual only) -->
                                <svg class="text-secondary/30 group-hover:text-secondary/60 transition-colors" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="12" r="1"></circle><circle cx="9" cy="5" r="1"></circle><circle cx="9" cy="19" r="1"></circle><circle cx="15" cy="12" r="1"></circle><circle cx="15" cy="5" r="1"></circle><circle cx="15" cy="19" r="1"></circle></svg>
                                
                                <span class="font-medium text-text text-sm sm:text-base">{{ content.titulo }}</span>
                            </div>
                            
                            <!-- Chevron -->
                            <div class="text-secondary transition-transform duration-300" :class="{ 'rotate-180': content.isOpen }">
                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                            </div>
                        </div>

                        <!-- Content Items (Expanded) -->
                        <div v-show="content.isOpen" class="bg-background/30 border-t border-secondary/10">
                            <!-- Items Loading -->
                            <div v-if="itemsLoading[content.id]" class="p-4 flex justify-center">
                                <div class="animate-spin h-5 w-5 text-primary border-2 border-primary border-t-transparent rounded-full"></div>
                            </div>
                             
                            <!-- Items List -->
                            <div v-else-if="content.items.length > 0" class="flex flex-col">
                                <div 
                                    v-for="item in content.items" 
                                    :key="item.id"
                                    @click="handleItemClick(item)"
                                    class="px-4 py-3 flex items-center gap-3 hover:bg-div-20 cursor-pointer border-b border-secondary/5 last:border-0 transition-colors group relative"
                                    :class="{ 'bg-primary/5': activeItem?.id === item.id }"
                                >
                                    <!-- Selection Indicator -->
                                    <div v-if="activeItem?.id === item.id" class="absolute left-0 top-0 bottom-0 w-1 bg-primary"></div>

                                    <!-- Icon -->
                                    <div class="text-secondary group-hover:text-primary transition-colors">
                                        <!-- Different icons based on type -->
                                        <svg v-if="item.tipo === 'Questionário' || item.tipo === 'Questionario'" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                                        <svg v-else-if="item.livro || item.id_bbtk_edicao" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                                        <svg v-else-if="item.video_link" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="23 7 16 12 23 17 23 7"></polygon><rect x="1" y="5" width="15" height="14" rx="2" ry="2"></rect></svg>
                                        <svg v-else xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                                    </div>

                                    <!-- Text Info -->
                                    <div class="flex-1 min-w-0">
                                        <p class="text-sm text-text font-medium truncate">{{ item.titulo }}</p>
                                        <div class="flex items-center gap-2 mt-0.5">
                                            <span v-if="item.duracao_minutos" class="text-[10px] text-secondary bg-secondary/10 px-1.5 py-0.5 rounded">{{ item.duracao_minutos }} min</span>
                                            
                                            <!-- Status Bubbles -->
                                            <span v-if="item.submissao?.status === 'concluido'" class="text-[10px] text-green-500 flex items-center gap-1">
                                                <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                                Feito
                                            </span>
                                            <span v-else-if="item.submissao?.status === 'em_andamento'" class="text-[10px] text-orange-500">Em andamento</span>
                                        </div>
                                    </div>
                                    
                                    <!-- Action Icon (play/arrow) -->
                                    <div class="text-secondary/30 group-hover:text-primary transition-colors">
                                         <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                                    </div>
                                </div>
                            </div>
                            <div v-else class="p-4 text-xs text-secondary text-center italic">
                                Vazio
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Player / Content Viewer Panel (Right Side) -->
            <transition 
                enter-active-class="transform transition ease-out duration-300" 
                enter-from-class="translate-x-full opacity-0" 
                enter-to-class="translate-x-0 opacity-100"
                leave-active-class="transform transition ease-in duration-300"
                leave-from-class="translate-x-0 opacity-100"
                leave-to-class="translate-x-full opacity-0"
            >
                <div v-if="activeItem" class="flex-1 bg-div-15 border-l border-secondary/10 relative flex flex-col h-full overflow-hidden shadow-2xl z-20">
                    <!-- Player Header -->
                    <div class="p-4 border-b border-secondary/10 flex items-center justify-between bg-div-15/95 backdrop-blur">
                         <div>
                             <h2 class="text-lg font-bold text-text">{{ activeItem.titulo }}</h2>
                             <span class="text-xs text-secondary">{{ activeItem.tipo }}</span>
                         </div>
                         <button @click="closePlayer" class="p-2 hover:bg-div-30 rounded-full text-secondary transition-colors">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                         </button>
                    </div>

                    <!-- Player Body (Scrollable) -->
                    <div class="flex-1 overflow-y-auto p-6 flex flex-col items-center">
                        
                        <!-- Quiz Context -->
                        <div v-if="activeItem.tipo === 'Questionário' || activeItem.tipo === 'Questionario'" class="w-full max-w-2xl flex flex-col gap-6">
                            
                            <!-- Loading -->
                            <div v-if="isLoadingContent" class="flex flex-col items-center justify-center py-20 text-secondary gap-4">
                                <div class="animate-spin h-8 w-8 border-2 border-primary border-t-transparent rounded-full"></div>
                                <p>Carregando quiz...</p>
                            </div>

                            <!-- Intro / Start Screen -->
                            <div v-else-if="!activeItem.submissao || activeItem.submissao.status === 'created'" class="bg-primary/5 border border-primary/20 rounded-xl p-6 text-center animate-fadeIn">
                                <div class="w-16 h-16 bg-primary/20 text-primary rounded-full flex items-center justify-center mx-auto mb-4 text-3xl">📝</div>
                                <h3 class="text-xl font-bold text-text mb-2">Hora do Quiz!</h3>
                                <p class="text-secondary mb-6">{{ activeItem.rich_text || 'Este questionário irá avaliar seus conhecimentos sobre o módulo.' }}</p>
                                
                                <div class="flex justify-center flex-col items-center gap-2">
                                     <button @click="startQuiz(activeItem)" class="bg-primary text-white px-8 py-3 rounded-xl font-bold shadow-lg shadow-primary/20 hover:bg-primary-dark hover:-translate-y-1 transition-all">
                                        Começar Agora
                                     </button>
                                     <span v-if="activeItem.tempo_questionario" class="text-xs text-secondary">⏱ Tempo limite: {{ activeItem.tempo_questionario }} min</span>
                                </div>
                            </div>

                            <!-- Questions List (Ongoing) -->
                            <div v-else-if="activeItem.submissao.status === 'em_andamento' || activeItem.submissao.status === 'resumed'" class="space-y-8 pb-20 animate-fadeIn">
                                
                                <div v-if="activeItem.perguntas && activeItem.perguntas.length > 0">
                                    <div v-for="(perg, idx) in activeItem.perguntas" :key="perg.id" class="flex flex-col gap-3 mb-8">
                                        <div class="flex items-start gap-3">
                                            <span class="bg-div-30 text-secondary font-bold text-sm px-2 py-1 rounded w-8 text-center shrink-0">{{ idx + 1 }}</span>
                                            <div class="space-y-4 w-full">
                                                <p class="font-medium text-text text-lg leading-relaxed">{{ perg.enunciado }}</p>
                                                
                                                <img v-if="perg.caminho_imagem" :src="perg.caminho_imagem" class="max-w-full rounded-lg border border-secondary/20 shadow-sm">

                                                <!-- Options (Multiple Choice) -->
                                                <div v-if="perg.tipo === 'Múltipla Escolha'" class="flex flex-col gap-2">
                                                    <label 
                                                        v-for="opt in perg.opcoes" 
                                                        :key="opt.id"
                                                        class="flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all hover:bg-div-20"
                                                        :class="answers[perg.id]?.id_resposta_possivel === opt.id ? 'border-primary bg-primary/5' : 'border-secondary/20'"
                                                    >
                                                        <input 
                                                            type="radio" 
                                                            :name="'q-'+perg.id" 
                                                            :value="opt.id"
                                                            v-model="answers[perg.id].id_resposta_possivel"
                                                            class="text-primary w-4 h-4 focus:ring-primary"
                                                        >
                                                        <span class="text-text text-sm">{{ opt.texto }}</span>
                                                    </label>
                                                </div>

                                                <!-- Text Area (Dissertativa) -->
                                                <div v-else>
                                                    <textarea 
                                                        v-model="answers[perg.id].texto_resposta"
                                                        rows="4" 
                                                        class="w-full bg-background border border-secondary/30 rounded-lg p-3 text-text focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all"
                                                        placeholder="Digite sua resposta aqui..."
                                                    ></textarea>
                                                </div>
                                            </div>
                                        </div>
                                        <div v-if="idx < activeItem.perguntas.length - 1" class="h-px bg-secondary/10 w-full my-4"></div>
                                    </div>

                                    <!-- Submit Footer -->
                                    <div class="flex justify-end pt-6 border-t border-secondary/20">
                                        <button @click="submitQuiz(activeItem)" class="bg-green-600 hover:bg-green-700 text-white px-8 py-3 rounded-xl font-bold shadow-lg transition-all flex items-center gap-2">
                                            <span>✅</span> Finalizar e Enviar
                                        </button>
                                    </div>
                                </div>
                                <div v-else class="text-center py-10 text-secondary border border-dashed border-secondary/20 rounded-xl">
                                    <p>Nenhuma pergunta cadastrada para este questionário.</p>
                                </div>
                            </div>

                            <!-- Completed -->
                            <div v-else-if="activeItem.submissao.status === 'concluido'" class="bg-green-500/10 border border-green-500/20 rounded-xl p-8 text-center animate-fadeIn">
                                <div class="w-20 h-20 bg-green-500/20 text-green-500 rounded-full flex items-center justify-center mx-auto mb-6 text-4xl">🏆</div>
                                <h3 class="text-2xl font-bold text-text mb-2">Parabéns!</h3>
                                <p class="text-secondary mb-6">Você completou este questionário.</p>
                                
                                <div class="bg-background rounded-xl p-6 border border-secondary/10 inline-block min-w-[200px] shadow-sm mb-6">
                                    <span class="block text-secondary text-sm uppercase tracking-wider mb-1">Sua Nota</span>
                                    <span class="text-4xl font-bold text-primary">{{ activeItem.submissao.nota }}</span>
                                    <span class="text-4xl font-bold text-primary" v-if="activeItem.submissao.nota === undefined || activeItem.submissao.nota === null">--</span>
                                    <span class="text-secondary text-sm"> / {{ activeItem.pontuacao_maxima || 10 }}</span>
                                </div>

                                <div class="flex justify-center mb-8">
                                    <button @click="resetQuiz(activeItem)" class="text-sm text-secondary hover:text-primary underline">
                                        Refazer Questionário (Reiniciar)
                                    </button>
                                </div>

                                <p class="mb-4 text-sm text-secondary font-bold uppercase tracking-wider text-left">Suas Respostas</p>
                                
                                <!-- Read Only View -->
                                <div class="text-left space-y-6 opacity-75">
                                    <div v-for="(perg, idx) in activeItem.perguntas" :key="perg.id" class="flex flex-col gap-2">
                                        <p class="font-bold text-text">{{ idx + 1 }}. {{ perg.enunciado }}</p>
                                        
                                        <div v-if="perg.tipo === 'Múltipla Escolha'">
                                            <div v-for="opt in perg.opcoes" :key="opt.id" class="flex items-center gap-2 text-sm p-2 rounded"
                                             :class="perg.resposta_usuario?.id_resposta_possivel === opt.id ? 'bg-primary/10 text-primary font-bold' : 'text-secondary'">
                                                <span v-if="perg.resposta_usuario?.id_resposta_possivel === opt.id">●</span>
                                                <span v-else>○</span>
                                                {{ opt.texto }}
                                            </div>
                                        </div>
                                        <div v-else class="p-3 bg-div-20 rounded-lg text-sm italic border border-secondary/10">
                                            {{ perg.resposta_usuario?.texto_resposta || 'Sem resposta.' }}
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </div>

                        <!-- Book Context -->
                        <div v-else-if="activeItem.livro || activeItem.id_bbtk_edicao" class="w-full max-w-3xl flex flex-col gap-6 items-center">
                             <div class="w-full aspect-[16/9] bg-div-30 rounded-xl flex items-center justify-center text-secondary">
                                 <!-- PDF Preview Placeholder -->
                                 <div class="text-center">
                                     <svg class="mx-auto mb-4 w-16 h-16 opacity-30" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                                     <p>Visualizador de PDF</p>
                                     <button v-if="activeItem.livro?.arquivo_pdf" @click="openExternal(activeItem.livro.arquivo_pdf)" class="mt-4 text-primary hover:underline">Abrir em nova aba</button>
                                 </div>
                             </div>
                             <div class="w-full text-left">
                                 <h3 class="font-bold text-lg mb-2">Sobre o livro</h3>
                                 <p class="text-secondary">{{ activeItem.rich_text || 'Sem descrição adicional.' }}</p>
                             </div>
                        </div>

                        <!-- Generic/Video Context -->
                        <div v-else class="w-full max-w-3xl">
                             <div v-if="activeItem.video_link" class="w-full aspect-video bg-black rounded-xl overflow-hidden mb-6 shadow-lg relative group">
                                 <iframe 
                                    class="w-full h-full"
                                    :src="activeItem.video_link.includes('youtube') ? activeItem.video_link.replace('watch?v=', 'embed/') : activeItem.video_link" 
                                    frameborder="0" 
                                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                                    allowfullscreen
                                 ></iframe>
                             </div>
                             
                             <div class="prose prose-invert max-w-none">
                                 <h3 class="text-xl font-bold mb-4">{{ activeItem.titulo }}</h3>
                                 <div v-if="activeItem.rich_text" v-html="activeItem.rich_text" class="text-secondary"></div>
                                 
                                 <div v-if="activeItem.caminho_arquivo || activeItem.url_externa" class="mt-6 p-4 bg-div-20 rounded-lg border border-secondary/10 flex items-center justify-between">
                                     <div class="flex items-center gap-3">
                                         <div class="w-10 h-10 rounded-lg bg-blue-500/20 text-blue-500 flex items-center justify-center">
                                             <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"></path></svg>
                                         </div>
                                         <div>
                                             <div class="font-bold text-sm">Material Complementar</div>
                                             <div class="text-xs text-secondary">Clique para acessar</div>
                                         </div>
                                     </div>
                                     <button @click="openExternal(activeItem.caminho_arquivo || activeItem.url_externa)" class="bg-div-30 hover:bg-div-40 px-4 py-2 rounded-lg text-sm font-medium transition-colors">
                                         Acessar
                                     </button>
                                 </div>
                             </div>
                        </div>

                    </div>
                </div>
            </transition>

        </main>

        <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />
    </div>
</template>

<style scoped>
/* Scrollbar styling for the sidebar list */
.scrollbar-thin::-webkit-scrollbar {
  width: 6px;
}
.scrollbar-thin::-webkit-scrollbar-track {
  background: transparent;
}
.scrollbar-thin::-webkit-scrollbar-thumb {
  background-color: rgba(156, 163, 175, 0.3);
  border-radius: 20px;
}
</style>

