<script setup lang="ts">
import { ref, computed } from 'vue'
import { useAppStore } from '@/stores/app'

definePageMeta({
    layout: false
})

const appStore = useAppStore()
const currentTab = ref('atividades')
const tabs = [
    { id: 'atividades', label: 'Atividades' },
    { id: 'envios', label: 'Envios' }
]

// State
const selectedItem = ref<any>(null)
const selectedSubmission = ref<any>(null)
const expandedFolders = ref<Set<string>>(new Set())

const selectSubmission = (sub: any) => {
    selectedSubmission.value = sub
}

// Fetch Folders (Top Level)
const { data: activitiesData, pending: isLoading, refresh } = await useFetch('/api/pedagogico/atividades', {
    params: computed(() => ({
        id_empresa: appStore.company?.empresa_id,
        page: 1,
        limit: 100 // Fetch reasonably large number for menu
    }))
})

// Use a local ref to ensure reactivity for client-side state (isExpanded, itens)
const folders = ref<any[]>([])

// Sync fetch data with local ref
watch(activitiesData, (newData) => {
    if (newData?.items) {
        // Map new items but try to preserve state if id matches (optional, but simpler to just reset for now or shallow merge)
        folders.value = newData.items.map((item: any) => ({
            ...item,
            isExpanded: false,
            itens: [],
            isLoadingItems: false
        }))
    }
}, { immediate: true })

// Toggle Folder Logic
const toggleExpand = async (folder: any) => {
    folder.isExpanded = !folder.isExpanded
    
    if (folder.isExpanded && (!folder.itens || folder.itens.length === 0)) {
        folder.isLoadingItems = true
        try {
            const data = await $fetch(`/api/pedagogico/folder/${folder.id}/items`, {
                params: { id_empresa: appStore.company?.empresa_id }
            }) as any
            
            folder.itens = data.items || []
        } catch (error) {
            console.error('Error fetching items:', error)
        } finally {
            folder.isLoadingItems = false
        }
    }
}

// Select Item Logic
const selectItem = async (item: any) => {
    // Optimistically set title while loading
    selectedItem.value = item
    
    try {
        const { data } = await useFetch(`/api/pedagogico/atividades/${item.id}`, {
            params: { id_empresa: appStore.company?.empresa_id }
        })
        
        if (data.value) {
            selectedItem.value = { ...item, ...data.value }
        }
    } catch (error) {
        console.error('Error fetching item details:', error)
         // Fallback to item (already set) or show error
    }
}
// Quiz Logic
const quizStarted = ref(false)
const isReviewing = ref(false)
const isSuccess = ref(false)
const currentQuestionIndex = ref(0)
const answers = ref<Record<string, any>>({})

const quizQuestions = computed(() => selectedItem.value?.perguntas || [])
const currentQuestion = computed(() => quizQuestions.value[currentQuestionIndex.value])
const answeredCount = computed(() => Object.keys(answers.value).length)

const startQuiz = () => {
    quizStarted.value = true
    isReviewing.value = false
    isSuccess.value = false
    currentQuestionIndex.value = 0
    answers.value = {}
}

const selectAnswer = (questionId: string, optionId: string) => {
    answers.value[questionId] = optionId
}

const nextQuestion = () => {
    if (currentQuestionIndex.value < quizQuestions.value.length - 1) {
        currentQuestionIndex.value++
    }
}

const prevQuestion = () => {
    if (currentQuestionIndex.value > 0) {
        currentQuestionIndex.value--
    }
}

const previewSubmission = () => {
    isReviewing.value = true
}

const confirmSubmission = async () => {
    isReviewing.value = false
    try {
        // Map answers to required format
        const formattedAnswers = Object.entries(answers.value).map(([questionId, answerValue]) => {
             const question = quizQuestions.value.find((q:any) => q.id === questionId)
             const isOption = question?.opcoes && question.opcoes.some((o:any) => o.id === answerValue)
             
             return {
                 id_pergunta: questionId,
                 id_resposta_possivel: isOption ? answerValue : null,
                 texto_resposta: isOption ? null : answerValue
             }
        })

        await $fetch('/api/lms/submit', {
            method: 'POST',
            body: {
                type: 'quiz',
                itemId: selectedItem.value.id,
                answers: formattedAnswers,
                id_empresa: appStore.company?.empresa_id
            }
        })
        
        isSuccess.value = true
        quizStarted.value = false
    } catch (error: any) {
        console.error('Erro ao enviar quiz:', error)
        alert('Erro ao enviar: ' + (error.statusMessage || error.message))
    }
}

// Task Logic
const taskText = ref('')
const isSubmittingTask = ref(false)

const submitTask = async () => {
    if (!taskText.value && !selectedItem.value.fileUrl) { // Logic to be refined with file upload
        alert('Por favor, escreva uma resposta ou anexe um arquivo.')
        return
    }

    if (!confirm('Confirmar envio da tarefa?')) return

    isSubmittingTask.value = true
    try {
        await $fetch('/api/lms/submit', {
            method: 'POST',
            body: {
                type: 'task',
                itemId: selectedItem.value.id,
                text: taskText.value,
                fileUrl: null, // To be implemented with R2
                id_empresa: appStore.company?.empresa_id
            }
        })

        isSuccess.value = true
        taskText.value = ''
        // Optionally fetch status updates or refresh item
    } catch (error: any) {
        console.error('Erro ao enviar tarefa:', error)
        alert('Erro ao enviar: ' + (error.statusMessage || error.message))
    } finally {
        isSubmittingTask.value = false
    }
}

const handleFileUpload = () => {
    alert('Upload de arquivo será configurado em breve com R2.')
}

// Evaluations Logic
const { data: evaluations, pending: pendingEvaluations, refresh: refreshEvaluations } = await useFetch('/api/lms/evaluations', {
    params: computed(() => ({
        id_empresa: appStore.company?.empresa_id,
        // For students, we don't strictly need to pass filters as the BACKEND enforces ownership
        // But we can add it for clarity if needed.
        // The BFF already grabs the user ID from session.
    })),
    watch: [() => currentTab.value], // Refresh when tab changes
    immediate: true,
    server: false
})

watch(evaluations, (val) => {
    console.log('Evaluations Data Updated:', val)
})

// Reset quiz/task state when item changes
watch(selectedItem, () => {
    quizStarted.value = false
    isReviewing.value = false
    isSuccess.value = false
    currentQuestionIndex.value = 0
    answers.value = {}
    taskText.value = '' // Reset task text
})


// Helpers
const getVideoEmbedUrl = (url: string) => {
    if (!url) return ''
    
    // Simple YouTube Regex
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/
    const match = url.match(regExp)
    
    if (match && match[2] && match[2].length === 11) {
        return `https://www.youtube.com/embed/${match[2]}`
    }
    
    return ''
}

const getBookCoverUrl = (path: string) => {
    if (!path || !selectedItem.value?.imageBaseUrl) return ''
    return `${selectedItem.value.imageBaseUrl}${path}`
}

const isOpeningBook = ref(false)

const openBook = async (livro: any) => {
    console.log('OPEN BOOK:', livro)
    const filePath = livro.arquivo || livro.pdf || livro.arquivo_pdf
    if (!filePath) {
         alert('Arquivo do livro não disponível.')
         return
    }

    isOpeningBook.value = true
    
    // Open window immediately to prevent popup blocker
    const newWindow = window.open('', '_blank')
    if (newWindow) {
        newWindow.document.write('<html><head><title>Carregando...</title></head><body style="background:#1e1e1e;color:#fff;font-family:sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;">Carregando documento seguro...</body></html>')
    }

    try {
        const { url } = await $fetch('/api/biblioteca/hash')
        
        if (url && newWindow) {
            newWindow.location.href = `${url}${filePath}`
        } else if (newWindow) {
            newWindow.close()
            alert('Erro ao gerar link seguro.')
        }
    } catch (e) {
        console.error('Error opening Book:', e)
        if (newWindow) newWindow.close()
        alert('Erro ao abrir o documento.')
    } finally {
        isOpeningBook.value = false
    }
}
</script>

<template>
    <NuxtLayout name="layout-secundario">
        <!-- Header Slots -->
        <template #header-icon>
            <div class="w-10 h-10 rounded bg-primary/20 flex items-center justify-center text-primary">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
            </div>
        </template>
        
        <template #header-title>LMS Consumo</template>
        <template #header-subtitle>Visualização de conteúdos e aulas</template>
        
        <template #header-actions>
            <!-- No actions needed for consumption mode usually -->
        </template>



        <!-- Sidebar: Lesson Menu -->
        <template #sidebar>
            <div v-if="currentTab === 'envios'" class="h-full flex flex-col">
                 <div v-if="pendingEvaluations" class="flex justify-center p-8">
                    <span class="loading loading-spinner text-primary"></span>
                 </div>
                 
                 <div v-else-if="!evaluations || evaluations.length === 0" class="flex flex-col items-center justify-center h-full text-center p-6 text-secondary opacity-50 space-y-4">
                     <p class="text-sm">Nenhum envio encontrado.</p>
                 </div>

                 <div v-else class="flex-1 overflow-y-auto p-2 space-y-2">
                    <div 
                        v-for="sub in evaluations" 
                        :key="sub.id_submissao" 
                        @click="selectSubmission(sub)"
                        class="bg-surface border border-div-15 rounded-lg p-3 shadow-sm hover:border-primary/30 transition-colors cursor-pointer group"
                        :class="selectedSubmission?.id_submissao === sub.id_submissao ? 'border-primary ring-1 ring-primary' : ''"
                    >
                        <div class="flex items-start gap-2">
                             <div class="w-8 h-8 rounded bg-div-05 flex items-center justify-center text-secondary shrink-0">
                                <svg v-if="sub.item_titulo.includes('Questionário')" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="9" y1="12" x2="15" y2="12"></line><line x1="9" y1="16" x2="15" y2="16"></line><line x1="9" y1="8" x2="15" y2="8"></line></svg>
                                <svg v-else xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
                            </div>
                            <div class="flex-1 min-w-0">
                                <h3 class="font-bold text-text text-xs truncate group-hover:text-primary transition-colors">{{ sub.item_titulo }}</h3>
                                <p class="text-[10px] text-secondary truncate">{{ sub.conteudo_titulo }}</p>
                                <div class="flex items-center gap-2 mt-1">
                                    <span v-if="sub.status === 'avaliado'" class="text-[10px] font-bold text-success flex items-center gap-1">
                                         <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg> 
                                         {{ sub.nota }} pts
                                    </span>
                                    <span v-else class="text-[10px] font-bold text-orange-500">Pendente</span>
                                    <span class="text-[10px] text-secondary">• {{ new Date(sub.data_envio).toLocaleDateString(undefined, {day:'2-digit', month:'2-digit'}) }}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                 </div>
            </div>
            
            <div v-else class="h-full flex flex-col">
                <div v-if="isLoading" class="flex justify-center py-10">
                <span class="loading loading-spinner text-primary"></span>
            </div>
            <div v-else class="space-y-3">
                <div v-for="folder in folders" :key="folder.id" class="bg-surface rounded border border-div-15 shadow-sm overflow-hidden transition-all duration-300 group hover:border-div-30">
                    <!-- Folder Header -->
                    <div class="p-4 flex items-center gap-3 cursor-pointer hover:bg-div-05/50 transition-colors" @click="toggleExpand(folder)">
                        <button class="p-1 text-secondary hover:text-primary transition-transform duration-200" :class="{'rotate-90': folder.isExpanded}">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                        </button>
                        
                        <div class="flex-1 min-w-0">
                            <h3 class="font-bold text-text text-sm truncate group-hover:text-primary transition-colors">{{ folder.titulo }}</h3>
                            <p class="text-[10px] text-secondary mt-0.5 line-clamp-1">{{ folder.descricao || 'Sem descrição' }}</p>
                        </div>

                        <!-- Item Count Badge -->
                         <div class="text-[9px] font-bold text-secondary bg-div-05 px-1.5 py-0.5 rounded border border-div-15">
                            {{ folder.itens ? folder.itens.length : 0 }}
                        </div>
                    </div>

                    <!-- Nested Items Content -->
                    <div v-show="folder.isExpanded" class="bg-div-05/30 border-t border-div-15 p-3 space-y-2 animate-in slide-in-from-top-2 duration-200">
                        <div v-if="folder.isLoadingItems" class="flex justify-center p-2">
                             <span class="loading loading-dots loading-xs text-secondary"></span>
                        </div>
                        <p v-else-if="!folder.itens || folder.itens.length === 0" class="text-center text-[10px] text-secondary py-2 italic opacity-60">
                            Vazio
                        </p>
                        
                        <!-- Items List -->
                        <div 
                            v-for="item in folder.itens" 
                            :key="item.id"
                            @click="selectItem(item)"
                            class="bg-surface p-3 rounded border flex items-center justify-between group/item transition-all hover:shadow-sm cursor-pointer"
                            :class="selectedItem?.id === item.id ? 'border-primary ring-1 ring-primary' : 'border-div-15 hover:border-primary/30'"
                        >
                            <div class="flex items-center gap-3 overflow-hidden">
                                <div class="w-8 h-8 flex items-center justify-center rounded bg-primary/10 text-primary shrink-0">
                                    <!-- VIDEO -->
                                    <svg v-if="item.tipo === 'VIDEO'" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polygon points="10 8 16 12 10 16 10 8"></polygon></svg>
                                    
                                    <!-- TEXTO -->
                                    <svg v-else-if="item.tipo === 'TEXTO'" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                                    
                                    <!-- PDF -->
                                    <svg v-else-if="item.tipo === 'PDF'" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                                    
                                    <!-- QUESTIONARIO -->
                                    <svg v-else-if="item.tipo === 'Questionário' || item.tipo === 'QUESTIONARIO'" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="9" y1="12" x2="15" y2="12"></line><line x1="9" y1="16" x2="15" y2="16"></line><line x1="9" y1="8" x2="15" y2="8"></line></svg>
                                    
                                    <!-- TAREFA -->
                                    <svg v-else-if="item.tipo === 'Tarefa' || item.tipo === 'TAREFA'" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
                                    
                                    <!-- MATERIAL / DEFAULT -->
                                    <svg v-else xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="16.5" y1="9.4" x2="7.5" y2="4.21"></line><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
                                </div>
                                <div class="flex flex-col min-w-0">
                                    <span class="text-xs font-bold text-text group-hover/item:text-primary transition-colors truncate">{{ item.titulo }}</span>
                                    <div class="flex items-center gap-2 text-[9px] text-secondary font-medium mt-0.5 uppercase tracking-tighter">
                                        <span>{{ item.tipo }}</span>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Right Arrow Action -->
                            <div class="pl-2">
                                <button class="p-1.5 text-secondary hover:text-primary rounded-full hover:bg-primary/10 transition-colors">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            </div>
        </template>

        <!-- Tabs -->
        <template #tabs>
             <button 
                v-for="tab in tabs" 
                :key="tab.id"
                @click="currentTab = tab.id"
                class="px-4 py-3 text-sm font-medium transition-colors border-b-2"
                :class="currentTab === tab.id ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'"
            >
                {{ tab.label }}
            </button>
        </template>

        <!-- Main Content -->
        <div class="h-full flex flex-col">
            <!-- Evaluations Tab -->
            <div v-if="currentTab === 'envios'" class="w-full h-full flex flex-col">
                <div v-if="!selectedSubmission" class="flex-1 flex flex-col items-center justify-center text-secondary opacity-50">
                    <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" class="mb-4"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    <p>Selecione um envio no menu lateral para ver os detalhes.</p>
                </div>

                <div v-else class="w-full max-w-4xl mx-auto space-y-6 p-6 animate-in fade-in duration-300">
                     <!-- Header -->
                     <div class="border-b border-div-15 pb-4">
                        <div class="flex items-center justify-between">
                            <div>
                                 <span class="text-xs font-bold text-secondary uppercase tracking-wider">{{ selectedSubmission.conteudo_titulo }}</span>
                                 <h1 class="text-2xl font-bold text-text mt-1">{{ selectedSubmission.item_titulo }}</h1>
                                 <p class="text-sm text-secondary mt-1">Enviado em {{ new Date(selectedSubmission.data_envio).toLocaleString() }}</p>
                            </div>
                            <div v-if="selectedSubmission.status === 'avaliado'" class="text-right">
                                <div class="text-3xl font-black text-primary">{{ selectedSubmission.nota }}</div>
                                <div class="text-xs text-secondary font-bold uppercase">Nota Final / {{ selectedSubmission.pontuacao_maxima }}</div>
                            </div>
                            <div v-else>
                                <span class="badge badge-warning badge-lg">Aguardando Correção</span>
                            </div>
                        </div>
                     </div>

                     <!-- Feedback Section -->
                     <div v-if="selectedSubmission.comentario_professor" class="bg-surface border border-div-15 rounded-lg p-6 shadow-sm">
                        <h3 class="flex items-center gap-2 text-sm font-bold text-text mb-3">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-primary"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"></path></svg>
                            Feedback do Professor
                        </h3>
                        <div class="bg-div-05 p-4 rounded text-sm text-text italic">
                            "{{ selectedSubmission.comentario_professor }}"
                        </div>
                     </div>

                     <!-- Submission Content (Placeholder for detailed answers view) -->
                     <div class="bg-surface border border-div-15 rounded-lg p-6 shadow-sm opacity-80">
                         <h3 class="text-sm font-bold text-secondary uppercase tracking-wider mb-4 border-b border-div-15 pb-2">Detalhes da Entrega</h3>
                         <div class="space-y-4">
                             <div  v-if="selectedSubmission.texto_resposta">
                                <span class="text-xs font-bold text-secondary block mb-1">Resposta de Texto:</span>
                                <p class="text-sm text-text bg-div-05 p-3 rounded">{{ selectedSubmission.texto_resposta }}</p>
                             </div>
                             <div v-else class="text-center text-sm text-secondary italic">
                                 (Detalhes completos das respostas do questionário disponíveis em breve)
                             </div>
                         </div>
                     </div>
                </div>
            </div>

            <!-- Content Area (Only if NOT Envios) -->
            <div v-else class="h-full flex flex-col">

            <div v-if="!selectedItem" class="flex-1 flex flex-col items-center justify-center text-secondary opacity-50">
                <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" class="mb-4"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                <p>Selecione uma lição no menu lateral para começar.</p>
            </div>
            
            <!-- Success Screen (Shared for Quiz and Task) -->
            <div v-else-if="isSuccess" class="flex-1 flex flex-col items-center justify-center p-8 animate-in zoom-in-95 duration-300">
                 <div class="w-24 h-24 bg-success/10 rounded-full flex items-center justify-center mb-6 text-success ring-8 ring-success/5">
                    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                </div>
                <h2 class="text-2xl font-bold text-text mb-2">Enviado com Sucesso!</h2>
                <p class="text-secondary text-center max-w-md mb-8">
                    Sua tentativa foi registrada. Você pode acompanhar a correção e sua nota na área de avaliações.
                </p>
                <button @click="isSuccess = false; selectedItem = null" class="btn btn-outline border-div-15 hover:bg-div-05 hover:border-primary text-secondary hover:text-primary gap-2 px-8">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
                    Voltar ao Início
                </button>
            </div>
            
            <div v-else class="space-y-4 max-w-4xl mx-auto w-full animate-in fade-in duration-300">
                <!-- Header of Content -->
                <div class="border-b border-div-15 pb-2">
                    <div class="flex items-center gap-2 mb-1">
                        <span class="badge badge-primary badge-outline badge-xs font-bold">{{ selectedItem.tipo }}</span>
                        <span v-if="selectedItem.pontuacao_maxima" class="text-[10px] text-orange-500 font-bold">• {{ selectedItem.pontuacao_maxima }} pts</span>
                    </div>
                    <h1 class="text-xl font-bold text-text">{{ selectedItem.titulo }}</h1>
                </div>

                <!-- Content Body -->
                <div class="space-y-4">
                    
                    <!-- 1. Description (Rich Text) in Box -->
                    <div v-if="selectedItem.rich_text" class="bg-surface rounded-lg p-4 shadow-sm border border-div-15 relative overflow-hidden">
                         <div class="absolute top-0 left-0 w-1 h-full bg-primary/20"></div>
                         <h3 class="text-[10px] font-bold text-secondary uppercase tracking-wider mb-2 flex items-center gap-2">
                            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="17" y1="10" x2="3" y2="10"></line><line x1="21" y1="6" x2="3" y2="6"></line><line x1="21" y1="14" x2="3" y2="14"></line><line x1="17" y1="18" x2="3" y2="18"></line></svg>
                            Descrição
                         </h3>
                         <div class="prose prose-sm max-w-none text-text leading-snug" v-html="selectedItem.rich_text"></div>
                    </div>

                    <!-- 2. External Link (Always show if exists) -->
                    <div v-if="selectedItem.url_externa" class="bg-div-05 rounded-lg border border-div-15 p-3 flex items-center justify-between gap-4 shadow-sm hover:border-primary/30 transition-colors">
                        <div class="flex items-center gap-3 overflow-hidden">
                            <div class="w-8 h-8 rounded bg-surface border border-div-15 flex items-center justify-center shrink-0 text-primary">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg>
                            </div>
                            <div class="flex flex-col min-w-0">
                                <span class="text-[10px] font-bold text-secondary uppercase tracking-wider">Link de Apoio</span>
                                <a :href="selectedItem.url_externa" target="_blank" class="text-xs font-bold text-primary hover:underline truncate block" :title="selectedItem.url_externa">{{ selectedItem.url_externa }}</a>
                            </div>
                        </div>
                        <a :href="selectedItem.url_externa" target="_blank" class="btn btn-xs btn-ghost border border-div-15 hover:border-primary hover:bg-primary/5 hover:text-primary shrink-0">
                            Acessar
                            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
                        </a>
                    </div>
                    
                    <!-- 3. Video Embed (If has video link) -->
                    <div v-if="getVideoEmbedUrl(selectedItem.video_link || selectedItem.url_externa || '')" class="rounded-lg overflow-hidden shadow-lg border border-div-15 aspect-video bg-black">
                        <iframe 
                            :src="getVideoEmbedUrl(selectedItem.video_link || selectedItem.url_externa || '')"
                            title="YouTube video player" 
                            frameborder="0" 
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                            allowfullscreen
                             class="w-full h-full"
                        ></iframe>
                    </div>

                    <!-- 4. Associated Book Card -->
                    <!-- 4. Associated Book Card -->
                     <div v-if="selectedItem.livro || selectedItem.livro_digital" class="bg-surface rounded-lg border border-div-15 p-4 shadow-sm hover:shadow-md transition-shadow">
                         <h3 class="text-[10px] font-bold text-secondary uppercase tracking-wider mb-3 flex items-center gap-2">
                             <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                             Livro Associado
                         </h3>
                         <div class="flex items-start gap-4 cursor-pointer group" @click="!isOpeningBook && openBook(selectedItem.livro || selectedItem.livro_digital)">
                             <!-- Cover -->
                             <div class="w-16 h-24 bg-div-05 rounded border border-div-15 flex items-center justify-center overflow-hidden shrink-0 shadow-sm group-hover:shadow-md transition-all group-hover:scale-105 duration-300">
                                 <img v-if="(selectedItem.livro || selectedItem.livro_digital).capa" :src="getBookCoverUrl((selectedItem.livro || selectedItem.livro_digital).capa)" alt="Capa" class="w-full h-full object-cover" />
                                 <span v-else class="text-2xl opacity-20">📖</span>
                             </div>
                             
                             <div class="flex-1 py-0.5">
                                 <h4 class="font-bold text-text text-sm mb-1 group-hover:text-primary transition-colors">{{ (selectedItem.livro || selectedItem.livro_digital).titulo || 'Título Indisponível' }}</h4>
                                 <p class="text-xs text-secondary mb-3 line-clamp-2 leading-tight">Material didático digital disponível.</p>
                                 <button class="btn btn-xs btn-primary gap-1" :disabled="isOpeningBook">
                                     <span v-if="isOpeningBook" class="loading loading-spinner loading-xs"></span>
                                     {{ isOpeningBook ? 'Abrindo...' : 'Ler Agora' }}
                                     <svg v-if="!isOpeningBook" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                                 </button>
                             </div>
                         </div>
                     </div>
                    
                    <!-- 5. Task Submission Interface -->
                    <div v-if="['Tarefa', 'TAREFA', 'Task'].includes(selectedItem.tipo)" class="bg-surface rounded-lg border border-div-15 p-4 shadow-sm">
                         <h3 class="text-[10px] font-bold text-secondary uppercase tracking-wider mb-3 flex items-center gap-2">
                             <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
                             Sua Entrega
                         </h3>
                         
                         <!-- Status & Due Date -->
                         <div class="flex items-center justify-between mb-4 bg-div-05 p-3 rounded border border-div-15">
                             <div class="flex flex-col">
                                 <span class="text-[10px] uppercase text-secondary font-bold">Status</span>
                                 <span class="text-xs font-bold text-orange-500 flex items-center gap-1">
                                     <span class="w-1.5 h-1.5 rounded-full bg-orange-500"></span> Pendente
                                 </span>
                             </div>
                             <div class="text-right flex flex-col" v-if="selectedItem.data_entrega_limite">
                                 <span class="text-[10px] uppercase text-secondary font-bold">Prazo</span>
                                 <span class="text-xs font-bold text-text">{{ new Date(selectedItem.data_entrega_limite).toLocaleDateString() }} às {{ new Date(selectedItem.data_entrega_limite).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) }}</span>
                             </div>
                         </div>
                         
                         <!-- Submission Input -->
                         <div class="space-y-3">
                             <textarea 
                                 v-model="taskText"
                                 class="textarea textarea-bordered textarea-sm w-full bg-surface text-text focus:border-primary focus:outline-none min-h-[100px]" 
                                 placeholder="Escreva sua resposta ou comentários aqui..."
                             ></textarea>
                             
                             <div class="flex items-center gap-3">
                                 <button @click="handleFileUpload" class="btn btn-sm btn-outline border-div-15 hover:bg-div-05 hover:border-primary text-secondary hover:text-primary gap-2 normal-case font-normal flex-1">
                                     <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
                                     Anexar Arquivo
                                 </button>
                                 <button 
                                     @click="submitTask" 
                                     :disabled="isSubmittingTask"
                                     class="btn btn-sm btn-primary text-white gap-2 flex-1"
                                 >
                                     <span v-if="isSubmittingTask" class="loading loading-spinner loading-xs"></span>
                                     <span v-else>Enviar Tarefa</span>
                                     <svg v-if="!isSubmittingTask" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
                                 </button>
                             </div>
                         </div>
                    </div>

                    <!-- 6. Quiz Interface -->
                    <div v-if="['Questionário', 'QUESTIONARIO'].includes(selectedItem.tipo)" class="space-y-4">
                        
                        <!-- Intro Screen -->
                        <div v-if="!quizStarted" class="bg-surface rounded-lg border border-div-15 p-6 shadow-sm text-center">
                            <div class="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4 text-primary">
                                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                            </div>
                            <h2 class="text-xl font-bold text-text mb-2">Hora de Praticar!</h2>
                            <p class="text-sm text-secondary mb-6 max-w-md mx-auto">
                                Este questionário contém {{ quizQuestions.length }} perguntas. 
                                <span v-if="selectedItem.tempo_questionario">Você tem {{ selectedItem.tempo_questionario }} minutos para concluir.</span>
                            </p>
                            
                            <div class="flex items-center justify-center gap-2 mb-6 text-xs font-bold text-secondary uppercase tracking-wider">
                                <span class="bg-div-05 px-2 py-1 rounded border border-div-15">{{ quizQuestions.length }} Questões</span>
                                <span class="bg-div-05 px-2 py-1 rounded border border-div-15">{{ selectedItem.pontuacao_maxima || 0 }} Pontos</span>
                            </div>

                            <button @click="startQuiz" class="btn btn-primary gap-2 px-8">
                                Iniciar Tentativa
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
                            </button>
                        </div>

                        <!-- Active Quiz -->
                        <div v-else-if="!isReviewing" class="space-y-4">
                            <!-- Question Navigation Tabs -->
                            <div class="flex items-center gap-2 overflow-x-auto no-scrollbar pb-2">
                                <button 
                                    v-for="(q, index) in quizQuestions" 
                                    :key="q.id"
                                    @click="currentQuestionIndex = Number(index)"
                                    class="w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold border shrink-0 transition-all"
                                    :class="currentQuestionIndex === index 
                                        ? 'bg-primary text-white border-primary shadow-md scale-105' 
                                        : answers[q.id] 
                                            ? 'bg-primary/20 text-primary border-primary/30'
                                            : 'bg-surface text-secondary border-div-15 hover:border-primary/50'"
                                >
                                    {{ Number(index) + 1 }}
                                </button>
                            </div>

                            <!-- Question Card -->
                            <div v-if="currentQuestion" class="bg-surface rounded-lg border border-div-15 p-5 shadow-sm min-h-[300px] flex flex-col animate-in fade-in slide-in-from-bottom-2 duration-300">
                                <div class="flex items-start justify-between mb-4">
                                     <span class="text-xs font-bold text-secondary uppercase tracking-wider">Questão {{ currentQuestionIndex + 1 }}</span>
                                     <span class="text-[10px] text-secondary font-mono bg-div-05 px-2 py-0.5 rounded">{{ currentQuestion.valor || 1 }} pt</span>
                                </div>
                                
                                <h3 class="text-lg font-bold text-text mb-6 leading-snug">{{ currentQuestion.enunciado }}</h3>
                                
                                <div class="space-y-3 flex-1">
                                    <!-- Options (Multiple Choice) -->
                                    <div v-if="currentQuestion.opcoes && currentQuestion.opcoes.length > 0">
                                        <div 
                                            v-for="option in currentQuestion.opcoes" 
                                            :key="option.id"
                                            @click="selectAnswer(currentQuestion.id, option.id)"
                                            class="p-4 rounded border cursor-pointer flex items-center gap-4 transition-all group mb-3"
                                            :class="answers[currentQuestion.id] === option.id 
                                                ? 'bg-primary/10 border-primary shadow-sm' 
                                                : 'bg-div-05 border-div-15 hover:border-primary/50 hover:bg-surface'"
                                        >
                                            <div class="w-5 h-5 rounded-full border-2 flex items-center justify-center shrink-0 transition-colors"
                                                :class="answers[currentQuestion.id] === option.id ? 'border-primary' : 'border-secondary/30 group-hover:border-primary/50'"
                                            >
                                                <div v-if="answers[currentQuestion.id] === option.id" class="w-2.5 h-2.5 rounded-full bg-primary"></div>
                                            </div>
                                            <span class="text-sm font-medium" :class="answers[currentQuestion.id] === option.id ? 'text-primary' : 'text-text'">{{ option.texto }}</span>
                                        </div>
                                    </div>

                                    <!-- Essay (Dissertativa) -->
                                    <div v-else class="h-full">
                                        <textarea 
                                            v-model="answers[currentQuestion.id]"
                                            class="textarea textarea-bordered w-full h-40 bg-div-05 text-text focus:border-primary focus:outline-none resize-none p-4" 
                                            placeholder="Digite sua resposta aqui..."
                                        ></textarea>
                                    </div>
                                </div>

                                <!-- Controls -->
                                <div class="flex items-center justify-between mt-8 pt-4 border-t border-div-15">
                                    <button 
                                        @click="prevQuestion" 
                                        :disabled="currentQuestionIndex === 0"
                                        class="btn btn-sm btn-ghost gap-2 text-secondary disabled:opacity-30"
                                    >
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
                                        Anterior
                                    </button>

                                    <button 
                                        v-if="currentQuestionIndex < quizQuestions.length - 1"
                                        @click="nextQuestion"
                                        class="btn btn-sm btn-primary gap-2"
                                    >
                                        Próxima
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
                                    </button>
                                    
                                    <button 
                                        v-else
                                        @click="previewSubmission"
                                        class="btn btn-sm btn-success text-white gap-2"
                                    >
                                        Finalizar
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Review Screen -->
                        <div v-else-if="isReviewing" class="bg-surface rounded-lg border border-div-15 p-6 shadow-sm text-center animate-in fade-in zoom-in-95 duration-200">
                             <div class="w-16 h-16 bg-success/10 rounded-full flex items-center justify-center mx-auto mb-4 text-success">
                                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                            </div>
                            <h2 class="text-xl font-bold text-text mb-2">Confirmar Envio?</h2>
                            <p class="text-sm text-secondary mb-6 max-w-xs mx-auto">
                                Você respondeu <strong class="text-text">{{ answeredCount }}</strong> de <strong class="text-text">{{ quizQuestions.length }}</strong> perguntas.
                            </p>
                            
                            <div class="flex items-center justify-center gap-3">
                                <button @click="isReviewing = false" class="btn btn-sm btn-outline border-div-15 hover:bg-div-05 hover:border-primary text-secondary hover:text-primary gap-2 normal-case font-normal px-6">
                                    Voltar e Revisar
                                </button>
                                <button @click="confirmSubmission" class="btn btn-sm btn-success text-white px-8 gap-2">
                                    Enviar Respostas
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Fallback -->
                    <div v-if="!selectedItem.rich_text && !selectedItem.url_externa && !selectedItem.video_link && !selectedItem.livro_digital && !selectedItem.livro && !['Tarefa', 'TAREFA', 'Task'].includes(selectedItem.tipo) && !['Questionário', 'QUESTIONARIO'].includes(selectedItem.tipo)" class="text-center py-10 text-secondary italic border border-dashed border-div-15 rounded-lg text-xs">
                        Sem conteúdo adicional.
                    </div>
                </div>
            </div>
            <!-- End Content Wrapper -->
            </div>
        </div>

    </NuxtLayout>
</template>
