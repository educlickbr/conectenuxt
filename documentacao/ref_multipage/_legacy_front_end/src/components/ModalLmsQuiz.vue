<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const props = defineProps({
    isOpen: Boolean,
    item: Object
})

const emit = defineEmits(['close'])

const appStore = useAppStore()
const toast = useToastStore()

const loading = ref(true)
const submitting = ref(false)
const quizData = ref(null)
const currentQuestionIndex = ref(0) // Optional: for stepper view, or just render all
// User asked to "render questions... ignored other timer instructions", basically a form.
// So we will render all questions in a list for now, as initially implemented.

const fetchQuizData = async () => {
    if (!props.item) return
    loading.value = true
    try {
        // 1. Ensure Quiz Started / Resume
        const { error: startError } = await supabase.rpc('lms_quiz_start', {
            p_user_id: (await supabase.auth.getUser()).data.user.id,
            p_item_id: props.item.id,
            p_id_empresa: appStore.id_empresa
        })
        if (startError) throw startError

        // 2. Fetch Content
        const { data, error: contentError } = await supabase.rpc('lms_quiz_get_content', {
            p_item_id: props.item.id,
            p_user_id: (await supabase.auth.getUser()).data.user.id,
            p_id_empresa: appStore.id_empresa
        })
        if (contentError) throw contentError

        // Initialize user answers if null
        if (data && data.perguntas) {
            data.perguntas.forEach(p => {
                if (!p.resposta_usuario) {
                    p.resposta_usuario = { texto_resposta: '', id_resposta_possivel: null }
                }
            })
        }

        quizData.value = data
    } catch (err) {
        console.error('Error loading quiz:', err)
        toast.showToast('Erro ao carregar questionário', 'error')
        emit('close')
    } finally {
        loading.value = false
    }
}

const selectOption = async (question, option) => {
    // Local state update only
    question.resposta_usuario = { 
        ...question.resposta_usuario, 
        id_resposta_possivel: option.id 
    }
}

const saveDissertativa = async (question) => {
    // Local state update only (v-model handles the value)
}

const submitQuiz = async () => {
    if(!confirm('Tem certeza que deseja finalizar e entregar o questionário?')) return

    submitting.value = true
    try {
        const user = (await supabase.auth.getUser()).data.user
        
        // 1. Save all answers
        const answersToSave = quizData.value.perguntas.filter(p => 
            p.resposta_usuario && (p.resposta_usuario.id_resposta_possivel || p.resposta_usuario.texto_resposta)
        )

        // Save in parallel
        const savePromises = answersToSave.map(q => {
            return supabase.rpc('lms_resposta_upsert', {
                p_user_id: user.id,
                p_id_item: props.item.id,
                p_id_pergunta: q.id,
                p_id_resposta_possivel: q.resposta_usuario.id_resposta_possivel,
                p_texto_resposta: q.resposta_usuario.texto_resposta,
                p_id_empresa: appStore.id_empresa
            })
        })

        await Promise.all(savePromises)

        // 2. Submit/Finish
        const { data, error } = await supabase.rpc('lms_quiz_submit', {
            p_user_id: user.id,
            p_item_id: props.item.id,
            p_id_empresa: appStore.id_empresa
        })
        
        if (error) throw error
        
        toast.showToast(`Questionário entregue! Nota: ${parseFloat(data.nota).toFixed(1)} / ${data.maxima}`, 'success')
        emit('close')
    } catch (err) {
        console.error('Submit error:', err)
        toast.showToast(err.message || 'Erro ao entregar questionário', 'error')
    } finally {
        submitting.value = false
    }
}

watch(() => props.isOpen, (newVal) => {
    if (newVal && props.item) {
        fetchQuizData()
    } else {
        quizData.value = null
        loading.value = true
    }
})
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-fade-in">
        <div class="bg-background w-full max-w-5xl h-[90vh] rounded-xl shadow-2xl flex flex-col overflow-hidden relative"> <!-- Main Modal Card -->
        
        <!-- Toolbar -->
        <div class="flex-shrink-0 h-16 border-b border-secondary/10 bg-div-15 px-6 flex items-center justify-between">
            <div class="flex items-center gap-4">
                <div class="w-10 h-10 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-xl">
                    📝
                </div>
                <div>
                   <h2 class="text-lg font-bold text-text line-clamp-1">{{ item?.titulo }}</h2>
                   <p v-if="loading" class="text-xs text-secondary">Carregando...</p>
                   <p v-else class="text-xs text-secondary">{{ quizData?.perguntas?.length || 0 }} Perguntas</p>
                </div>
            </div>
            
            <button @click="$emit('close')" class="p-2 hover:bg-div-30 rounded-full text-secondary transition-colors" title="Fechar (Salva automaticamente)">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
            </button>
        </div>

        <!-- Content -->
        <div class="flex-1 overflow-y-auto p-4 sm:p-8 scrollbar-thin">
            <div class="max-w-3xl mx-auto flex flex-col gap-8 pb-20">
                
                <div v-if="loading" class="flex flex-col items-center justify-center py-20 gap-4">
                    <div class="animate-spin h-10 w-10 border-4 border-primary border-t-transparent rounded-full"></div>
                    <p class="text-secondary animate-pulse">Preparando questionário...</p>
                </div>

                <div v-else-if="!quizData?.perguntas || quizData.perguntas.length === 0" class="text-center py-20 text-secondary">
                    <p class="text-xl font-bold mb-2">Nenhuma pergunta encontrada.</p>
                    <p>Este questionário parece estar vazio.</p>
                </div>

                <div v-else class="flex flex-col gap-10">
                    <!-- Intro Text -->
                    <div v-if="quizData.rich_text" class="bg-div-15 p-6 rounded-xl prose prose-invert max-w-none text-sm">
                        <div class="whitespace-pre-wrap">{{ quizData.rich_text }}</div>
                    </div>

                    <!-- Questions Loop -->
                    <div v-for="(question, index) in quizData.perguntas" :key="question.id" class="bg-div-15 rounded-xl p-6 sm:p-8 relative border border-transparent hover:border-secondary/10 transition-colors">
                        
                        <!-- Header -->
                        <div class="flex gap-4 mb-6">
                            <span class="flex-shrink-0 w-8 h-8 rounded bg-primary text-white font-bold flex items-center justify-center text-sm shadow-lg shadow-primary/20">
                                {{ index + 1 }}
                            </span>
                            <div class="flex-1 pt-1">
                                <h3 class="text-lg font-medium text-text leading-relaxed">{{ question.enunciado }}</h3>
                                <!-- Image -->
                                <div v-if="question.caminho_imagem" class="mt-4 rounded-lg overflow-hidden bg-black/20 max-h-[400px]">
                                    <img :src="question.caminho_imagem" class="w-full h-full object-contain">
                                </div>
                            </div>
                        </div>

                        <!-- Answer Area -->
                        <div class="pl-12">
                            <!-- Multiple Choice -->
                            <div v-if="question.tipo === 'Múltipla Escolha'" class="flex flex-col gap-3">
                                <div 
                                v-for="opt in question.opcoes" 
                                :key="opt.id"
                                @click="selectOption(question, opt)"
                                class="p-4 rounded-lg border-2 cursor-pointer transition-all flex items-center gap-4 hover:brightness-110 active:scale-[0.99]"
                                :class="question.resposta_usuario?.id_resposta_possivel === opt.id ? 'border-primary bg-primary/10 shadow-sm' : 'border-secondary/10 bg-div-30/50 hover:bg-div-30'"
                                >
                                    <div class="w-6 h-6 rounded-full border-2 border-secondary flex items-center justify-center shrink-0 transition-colors"
                                        :class="{'border-primary bg-primary': question.resposta_usuario?.id_resposta_possivel === opt.id}"
                                    >
                                        <div v-if="question.resposta_usuario?.id_resposta_possivel === opt.id" class="w-2.5 h-2.5 rounded-full bg-white"></div>
                                    </div>
                                    <span class="text-text font-medium">{{ opt.texto }}</span>
                                </div>
                            </div>

                            <!-- Dissertativa -->
                            <div v-else-if="question.tipo === 'Dissertativa'" class="relative">
                                <textarea 
                                    v-model="question.resposta_usuario.texto_resposta"
                                    @blur="saveDissertativa(question)"
                                    rows="5"
                                    class="w-full bg-background/50 border-2 border-secondary/10 rounded-xl p-4 text-text focus:border-primary focus:outline-none transition-all resize-y shadow-inner"
                                    placeholder="Digite sua resposta detalhada aqui..."
                                ></textarea>
                            </div>
                        </div>

                    </div>
                    
                    <!-- Submit Footer -->
                    <div class="flex flex-col items-center gap-4 pt-10 border-t border-secondary/10">
                        <button 
                            @click="submitQuiz"
                            :disabled="submitting"
                            class="bg-primary hover:brightness-110 text-white font-bold py-3 px-8 rounded-lg shadow-lg shadow-primary/20 transition-all active:scale-95 text-sm flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            <span v-if="submitting" class="animate-spin h-5 w-5 border-2 border-white border-t-transparent rounded-full"></span>
                            {{ submitting ? 'Entregando...' : 'Finalizar o Questionário' }}
                        </button>

                    </div>

                </div>
            </div>
        </div>

        </div> <!-- End Main Modal Card -->
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
