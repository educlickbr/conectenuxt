<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import FullPageMenu from '../components/FullPageMenu.vue'
import ModalLmsQuiz from '../components/ModalLmsQuiz.vue' // Import Modal
import { useToastStore } from '../stores/toast'

const appStore = useAppStore()
const toast = useToastStore()

// Data
const contents = ref([])
const isLoading = ref(true)
const isMenuOpen = ref(false)
const user = ref(null)
const itemsLoading = ref({})
const activeItem = ref(null)
const activeContent = ref(null) // Track parent content
const imageBaseUrl = ref('')

const showQuizModal = ref(false) // Modal State

const fetchImageHash = async () => {
    try {
        const { data: { session } } = await supabase.auth.getSession()
        
        const { data, error } = await supabase.functions.invoke('hash_pasta_conecte', {
            body: { 
                path: '/biblio/',
                user_id: user.value?.id 
            },
            headers: session ? {
                Authorization: `Bearer ${session.access_token}`
            } : {}
        })
        
        if (data && data.url) {
            imageBaseUrl.value = data.url
        }
    } catch (e) {
        console.error('Error fetching image hash', e)
    }
}

const fetchContents = async () => {
    isLoading.value = true
    try {
        const { data: { user: authUser } } = await supabase.auth.getUser()
        if (!authUser) throw new Error('Usuário não autenticado')
        user.value = authUser

        await fetchImageHash()

        const { data, error } = await supabase.rpc('lms_consumo_get', {
            p_id_empresa: appStore.id_empresa,
            p_user_id: authUser.id
        })

        if (error) throw error
        contents.value = (data || []).map(c => ({
            ...c,
            isOpen: false,
            items: [],
            itemsLoaded: false
        }))
    } catch (error) {
        console.error(error)
        toast.showToast('Erro ao carregar conteúdos', 'error')
    } finally {
        isLoading.value = false
    }
}

const toggleContent = async (content, forceRefresh = false) => {
    // If we click the same open content, close it (unless forcing refresh)
    if (content.isOpen && !forceRefresh) {
        content.isOpen = false
        if (activeContent.value?.id === content.id) activeContent.value = null
        return
    }

    content.isOpen = true
    activeContent.value = content // Set active content parent

    if (!content.itemsLoaded || forceRefresh) {
        itemsLoading.value[content.id] = true
        try {
            const { data, error } = await supabase.rpc('lms_itens_get', {
                p_id_empresa: appStore.id_empresa,
                p_user_id: user.value.id,
                p_conteudo_id: content.id
            })

            if (error) throw error
            content.items = (data || []).map(item => {
                // Map Book URLs using hash
                if (item.livro) {
                    // Capa
                    if (item.livro.capa) {
                         if (item.livro.capa.startsWith('http')) {
                             item.livro.capaUrl = item.livro.capa
                         } else if (imageBaseUrl.value) {
                             item.livro.capaUrl = `${imageBaseUrl.value}${item.livro.capa}`
                         }
                    }
                    // PDF
                    if (item.livro.arquivo_pdf) {
                         if (item.livro.arquivo_pdf.startsWith('http')) {
                             item.livro.pdfUrl = item.livro.arquivo_pdf
                         } else if (imageBaseUrl.value) {
                             item.livro.pdfUrl = `${imageBaseUrl.value}${item.livro.arquivo_pdf}`
                         }
                    }
                }
                return item
            })
            content.itemsLoaded = true
            
            // If activeItem exists, update it references from new list to keep UI in sync
            if (activeItem.value) {
                 const found = content.items.find(i => i.id === activeItem.value.id)
                 if(found) activeItem.value = found
            }

        } catch (error) {
            console.error(error)
            toast.showToast('Erro ao carregar itens', 'error')
        } finally {
            itemsLoading.value[content.id] = false
        }
    }
}

const handleItemClick = (item) => {
    activeItem.value = item
    // Reset modal state just in case
    showQuizModal.value = false
}

const closePlayer = () => {
    activeItem.value = null
}

const openExternal = (url) => {
    if(url) window.open(url, '_blank')
}

// Open Quiz Modal
const openQuiz = () => {
    showQuizModal.value = true
}

const handleQuizClose = () => {
    showQuizModal.value = false
    // Refresh content to update status
    if (activeContent.value) {
        toggleContent(activeContent.value, true)
    }
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
        <main class="flex-1 flex overflow-hidden gap-6">
            
            <!-- List Container (Sidebar Left) -->
            <div 
                class="flex-shrink-0 transition-all duration-500 ease-in-out scrollbar-thin overflow-y-auto"
                :class="activeItem ? 'w-full md:w-[320px] lg:w-[350px] border-r border-secondary/10 pr-4' : 'w-full max-w-4xl mx-auto p-2'"
            >
                <!-- Loading State -->
                <div v-if="isLoading" class="flex justify-center p-10">
                    <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
                </div>

                <!-- Empty State -->
                <div v-else-if="contents.length === 0" class="flex flex-col items-center justify-center p-12 text-secondary opacity-50">
                     <p>Nenhum conteúdo disponível.</p>
                </div>

                <!-- Simple List -->
                <div v-else class="flex flex-col gap-4">
                    <div 
                        v-for="content in contents" 
                        :key="content.id"
                        class="bg-div-15 rounded-lg border transition-all duration-300 overflow-hidden"
                        :class="content.isOpen ? 'border-primary/50 ring-1 ring-primary/20 shadow-lg' : 'border-secondary/20 hover:border-secondary/40'"
                    >
                        <!-- Header (Toggle) -->
                        <div 
                            @click="toggleContent(content)"
                            class="p-4 flex items-center justify-between cursor-pointer select-none hover:bg-div-20 transition-colors"
                        >
                            <div class="flex items-center gap-3">
                                <span class="font-medium text-text text-sm sm:text-base">{{ content.titulo }}</span>
                            </div>
                            <!-- Chevron -->
                            <div class="text-secondary transition-transform duration-300" :class="{ 'rotate-180': content.isOpen }">
                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                            </div>
                        </div>

                        <!-- Items List -->
                        <div v-show="content.isOpen" class="border-t border-secondary/10 bg-background/30">
                            <!-- Items Loading -->
                            <div v-if="itemsLoading[content.id]" class="p-4 flex justify-center">
                                <div class="animate-spin h-5 w-5 text-primary border-2 border-primary border-t-transparent rounded-full"></div>
                            </div>
                            
                            <!-- Empty Items -->
                            <div v-else-if="content.items.length === 0" class="p-4 text-center text-secondary text-sm italic">
                                Nenhum item neste conteúdo.
                            </div>

                            <!-- List -->
                            <div v-else class="flex flex-col">
                                <div 
                                    v-for="item in content.items" 
                                    :key="item.id"
                                    @click="handleItemClick(item)"
                                    class="p-3 border-b border-secondary/5 last:border-0 hover:bg-div-20 flex justify-between items-center cursor-pointer transition-colors"
                                    :class="{'bg-primary/10 border-l-2 border-l-primary scale-[1.01] shadow-md': activeItem?.id === item.id}"
                                >
                                    <div>
                                        <p class="text-sm font-medium text-text" :class="{'text-primary': activeItem?.id === item.id}">{{ item.titulo }}</p>
                                        <p class="text-xs text-secondary">{{ item.tipo }}</p>
                                    </div>
                                    <div class="text-xs px-2 py-1 bg-div-30 rounded text-secondary">{{ item.submissao?.status || 'Não iniciado' }}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Detail Area (Right) -->
            <transition 
                enter-active-class="transition-all duration-500 ease-out"
                enter-from-class="translate-x-10 opacity-0"
                enter-to-class="translate-x-0 opacity-100"
            >
                <div v-if="activeItem" class="flex-1 overflow-y-auto pl-4 lg:pl-8 relative">
                   
                    <div class="w-full flex flex-col gap-6 pb-20"> <!-- Full width -->

                        <!-- Mobile Back & Close Button Container -->
                        <div class="flex items-center justify-between mb-4">
                            <button @click="closePlayer" class="md:hidden flex items-center gap-2 text-secondary">
                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
                                Voltar
                            </button>
                            
                             <!-- Close Button (Desktop aligned right) -->
                             <button 
                                @click="closePlayer" 
                                class="hidden md:flex ml-auto p-2 text-secondary hover:text-primary hover:bg-div-15 rounded-full transition-colors items-center gap-2 text-sm font-bold uppercase tracking-wider"
                            >
                                Fechar
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                            </button>
                        </div>

                        <!-- Item Content -->
                        <div class="flex flex-col gap-10">
                            
                            <!-- Header Info -->
                            <div class="border-b border-secondary/10 pb-6">
                                <div class="text-xs font-bold text-primary uppercase tracking-wider mb-2">{{ activeItem.tipo }}</div>
                                <h2 class="text-4xl font-bold text-text mb-4 leading-tight">{{ activeItem.titulo }}</h2>
                                
                                <!-- Dates -->
                                <div class="flex flex-wrap gap-6 text-sm text-secondary">
                                    <div v-if="activeItem.data_disponivel" class="flex items-center gap-2">
                                        <div class="w-2 h-2 rounded-full bg-primary/60"></div>
                                        <span>Disponível: <strong class="text-text">{{ new Date(activeItem.data_disponivel).toLocaleDateString() }}</strong></span>
                                    </div>
                                    <div v-if="activeItem.data_entrega_limite" class="flex items-center gap-2">
                                        <div class="w-2 h-2 rounded-full bg-red-400/60"></div>
                                        <span>Entrega: <strong class="text-text">{{ new Date(activeItem.data_entrega_limite).toLocaleDateString() }}</strong></span>
                                    </div>
                                    <div v-else-if="activeItem.submissao?.data_inicio" class="flex items-center gap-2">
                                        <div class="w-2 h-2 rounded-full bg-emerald-400/60"></div>
                                        <span>Iniciado: <strong class="text-text">{{ new Date(activeItem.submissao.data_inicio).toLocaleDateString() }}</strong></span>
                                    </div>
                                </div>
                            </div>

                            <!-- Description (Borderless Box) -->
                            <div class="flex flex-col gap-2">
                                <label class="text-xs font-bold text-secondary uppercase tracking-wider flex items-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="21" y1="10" x2="3" y2="10"></line><line x1="21" y1="6" x2="3" y2="6"></line><line x1="21" y1="14" x2="3" y2="14"></line><line x1="21" y1="18" x2="3" y2="18"></line></svg>
                                    Descrição / Conteúdo
                                </label>
                                <div class="bg-div-15 rounded-lg p-4 min-h-[50px]">
                                    <div v-if="activeItem.rich_text" class="prose prose-invert max-w-none text-text/90 text-sm sm:text-base">
                                        <div class="whitespace-pre-wrap leading-relaxed">{{ activeItem.rich_text }}</div>
                                    </div>
                                    <div v-else class="text-secondary/40 italic text-sm">Sem descrição disponível.</div>
                                </div>
                            </div>

                            <!-- Video Link (Compact Form Style) -->
                            <div class="flex flex-col gap-2">
                                <label class="text-xs font-bold text-secondary uppercase tracking-wider flex items-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="23 7 16 12 23 17 23 7"></polygon><rect x="1" y="5" width="15" height="14" rx="2" ry="2"></rect></svg>
                                    Vídeo
                                </label>
                                <div class="bg-div-15 rounded-lg p-4 flex flex-col gap-4">
                                     <!-- Link / Button -->
                                     <div v-if="activeItem.video_link" class="flex flex-wrap items-center justify-between gap-2">
                                        <span class="text-sm font-mono text-primary truncate max-w-full">{{ activeItem.video_link }}</span>
                                        <button @click="openExternal(activeItem.video_link)" class="text-xs bg-primary text-white hover:brightness-110 px-3 py-1.5 rounded transition-colors font-medium">
                                            Abrir Externo
                                        </button>
                                     </div>
                                     <!-- Embed -->
                                     <div v-if="activeItem.video_link" class="aspect-video rounded overflow-hidden bg-black/20 shadow-lg mt-2">
                                        <iframe 
                                            class="w-full h-full"
                                            :src="activeItem.video_link.includes('youtube') ? activeItem.video_link.replace('watch?v=', 'embed/') : activeItem.video_link" 
                                            frameborder="0" 
                                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                                            allowfullscreen
                                        ></iframe>
                                     </div>
                                     
                                     <!-- Empty State -->
                                     <div v-else class="text-secondary/40 italic text-sm">Nenhum vídeo vinculado.</div>
                                </div>
                            </div>

                            <!-- External URL (Compact Form Style) -->
                            <div class="flex flex-col gap-2">
                                <label class="text-xs font-bold text-secondary uppercase tracking-wider flex items-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                                    URL Externa / Arquivo
                                </label>
                                <div class="bg-div-15 rounded-lg p-4 flex items-center justify-between min-h-[50px]">
                                    <div v-if="activeItem.url_externa" class="flex items-center gap-3 overflow-hidden flex-1">
                                        <span class="text-sm text-text font-mono truncate">{{ activeItem.url_externa }}</span>
                                    </div>
                                    
                                    <button v-if="activeItem.url_externa" @click="openExternal(activeItem.url_externa)" class="px-3 py-1.5 bg-primary text-white hover:brightness-110 rounded text-xs font-bold transition-colors shrink-0 ml-4">
                                        Acessar
                                    </button>

                                    <div v-else class="text-secondary/40 italic text-sm">Nenhum link ou arquivo vinculado.</div>
                                </div>
                            </div>

                            <!-- Book Card (Compact Form Style) -->
                            <div class="flex flex-col gap-2">
                                <label class="text-xs font-bold text-secondary uppercase tracking-wider flex items-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                    Livro Digital
                                </label>
                                <div class="bg-div-15 rounded-lg p-4 min-h-[50px]">
                                    <div v-if="activeItem.livro || activeItem.id_bbtk_edicao" class="flex flex-col sm:flex-row gap-4 w-full">
                                         <!-- Cover -->
                                         <div class="w-20 h-28 bg-black/20 rounded shadow-sm shrink-0 overflow-hidden relative group">
                                             <img v-if="activeItem.livro && activeItem.livro.capaUrl" :src="activeItem.livro.capaUrl" class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105">
                                             <div v-else class="w-full h-full flex flex-col items-center justify-center text-secondary/40 bg-div-30/50">
                                                 <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" class="mb-1"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                                             </div>
                                         </div>

                                         <div class="flex-1 py-1" v-if="activeItem.livro">
                                             <h4 class="text-base font-bold text-text mb-1">{{ activeItem.livro.titulo }}</h4>
                                             <p class="text-secondary text-xs mb-3">{{ activeItem.livro.autores || 'Autor desconhecido' }}</p>
                                             
                                             <button 
                                                v-if="activeItem.livro.arquivo_pdf" 
                                                @click="openExternal(activeItem.livro.pdfUrl || activeItem.livro.arquivo_pdf)"
                                                class="bg-primary text-white hover:brightness-110 px-4 py-2 rounded-lg text-xs font-bold shadow-lg shadow-primary/20 transition-all flex items-center gap-2 w-fit"
                                             >
                                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                                Ler Agora
                                             </button>
                                         </div>
                                         <div v-else class="flex-1 flex items-center text-secondary/40 italic text-sm">
                                             Dados do livro não disponíveis.
                                         </div>
                                    </div>
                                    <div v-else class="text-secondary/40 italic text-sm flex items-center h-full">Nenhum livro vinculado.</div>
                                </div>
                            </div>
                            
                            <!-- Tarefa Upload Section (Condition: Tipo == 'Tarefa') -->
                            <div v-if="activeItem.tipo && activeItem.tipo.toLowerCase() === 'tarefa'" class="flex flex-col gap-2">
                                <label class="text-xs font-bold text-secondary uppercase tracking-wider flex items-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
                                    Enviar Tarefa
                                </label>
                                <div class="bg-div-15 rounded-lg p-6 flex flex-col items-center justify-center gap-4 text-center">
                                    <div class="w-full border-2 border-dashed border-secondary/20 hover:border-primary/50 rounded-lg p-8 transition-colors cursor-pointer bg-background/50 group">
                                        <div class="flex flex-col items-center gap-3">
                                            <div class="w-12 h-12 rounded-full bg-div-30 group-hover:bg-primary/10 flex items-center justify-center transition-colors">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-secondary group-hover:text-primary transition-colors"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
                                            </div>
                                            <div>
                                                <p class="text-sm font-bold text-text mb-1">Clique para selecionar</p>
                                                <p class="text-xs text-secondary">ou arraste o arquivo aqui</p>
                                            </div>
                                        </div>
                                    </div>
                                    <button class="w-full bg-primary text-white font-bold py-3 rounded-lg hover:brightness-110 shadow-lg shadow-primary/20 transition-all active:scale-[0.98]">
                                        Enviar Arquivo
                                    </button>
                                </div>
                            </div>

                            <!-- Quiz Section (Open Modal) -->
                            <div v-if="activeItem.tipo && (activeItem.tipo.toLowerCase() === 'questionário' || activeItem.tipo.toLowerCase() === 'questionario')" class="flex flex-col gap-2">
                                <label class="text-xs font-bold text-secondary uppercase tracking-wider flex items-center gap-2">
                                     <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                                    Questionário
                                </label>
                                <div class="bg-div-15 rounded-lg p-4 flex flex-col sm:flex-row items-center justify-between gap-4">
                                    <div class="flex items-center gap-4 text-center sm:text-left">
                                        <div class="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-xl shrink-0">
                                            📝
                                        </div>
                                        <div>
                                            <h3 class="text-base font-bold text-text">Questionário Disponível</h3>
                                            <p class="text-xs text-secondary">Clique para responder.</p>
                                        </div>
                                    </div>
                                    <div v-if="activeItem.submissao?.status === 'concluido' || activeItem.submissao?.data_envio" class="flex items-center gap-2 px-4 py-2 bg-yellow-500/10 text-yellow-500 rounded-lg border border-yellow-500/20">
                                        <div class="w-2 h-2 rounded-full bg-yellow-500 animate-pulse"></div>
                                        <span class="text-sm font-bold">Aguardando Avaliação</span>
                                    </div>
                                    <button 
                                        v-else
                                        @click="openQuiz" 
                                        class="bg-primary text-white text-sm font-bold px-6 py-2.5 rounded-lg hover:brightness-110 shadow-lg shadow-primary/20 transition-all active:scale-95 w-full sm:w-auto"
                                    >
                                        Responder
                                    </button>
                                </div>
                            </div>


                        </div>

                    </div>
                </div>
            </transition>
        </main>
        
        <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />
        
        <!-- Quiz Modal -->
        <ModalLmsQuiz 
            :isOpen="showQuizModal" 
            :item="activeItem" 
            @close="handleQuizClose"
        />
        
    </div>
</template>

<style scoped>
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
