<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { useToastStore } from '@/stores/toast'
import { useAppStore } from '@/stores/app'

// Interfaces for better Type Inference
interface Question {
    id_pergunta: string
    enunciado: string
    tipo_pergunta: string
    valor: number
    opcoes: { id: string, texto: string, correta: boolean }[]
    resposta_usuario: { 
        id_resposta_possivel: string | null
        texto_resposta: string | null
        correta: boolean | null
    } | null
}

interface SubmissionDetails {
    submission: {
        id_submissao: string
        aluno_nome: string
        turma_nome: string
        data_envio: string
        item_tipo: string
        item_titulo: string
        texto_resposta: string | null
        caminho_arquivo: string | null
        pontuacao_maxima: number
        nota: number | null
        comentario_professor: string | null
    }
    questions: Question[]
}

const props = defineProps<{
    isOpen: boolean
    submissionId: string | null
    initialData: any
}>()

const emit = defineEmits(['close', 'success'])
const toast = useToastStore()
const appStore = useAppStore()

const isLoading = ref(false)
const details = ref<SubmissionDetails | null>(null)
const isLoadingDetails = ref(false)

const form = ref({
    nota: 0,
    comentario: ''
})

// Fetch Details when submissionId changes
watch(() => props.submissionId, async (newId) => {
    if (newId && props.isOpen) {
        isLoadingDetails.value = true
        try {
            const data = await $fetch<SubmissionDetails>(`/api/lms/submission/${newId}`, {
                params: {
                   id_empresa: appStore.company?.empresa_id ?? ''
                }
            })
            
            details.value = data
            
            // Sync Form
            if (data.submission) {
                form.value.nota = Number(data.submission.nota) || 0
                form.value.comentario = data.submission.comentario_professor || ''
            }
        } catch (error) {
            console.error('Error fetching submission details:', error)
            toast.showToast('Erro ao carregar detalhes do envio.', 'error')
        } finally {
            isLoadingDetails.value = false
        }
    } else {
        details.value = null
    }
}, { immediate: true })

const handleSubmit = async () => {
    if (!details.value?.submission) return

    const maxScore = details.value.submission.pontuacao_maxima || 100
    if (form.value.nota < 0 || form.value.nota > maxScore) {
        toast.showToast(`A nota deve ser entre 0 e ${maxScore}`, 'error')
        return
    }

    isLoading.value = true
    try {
        await $fetch('/api/lms/grade', {
            method: 'POST',
            body: {
                id_submissao: props.submissionId,
                nota: form.value.nota,
                comentario: form.value.comentario
            }
        })

        toast.showToast('Avaliação salva com sucesso!', 'success')
        emit('success')
        emit('close')
    } catch (error: any) {
        console.error('Erro ao avaliar:', error)
        toast.showToast(error.statusMessage || 'Erro ao salvar avaliação', 'error')
    } finally {
        isLoading.value = false
    }
}

// Helpers
const getQuestionTypeLabel = (type: string) => {
    switch(type) {
        case 'Múltipla Escolha': return 'Múltipla Escolha'
        case 'Dissertativa': return 'Dissertativa'
        default: return type
    }
}

const isCorrect = (question: any) => {
    return question.resposta_usuario?.correta === true
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-in fade-in duration-200">
        <div class="bg-surface w-full max-w-4xl rounded-xl shadow-2xl border border-div-15 flex flex-col max-h-[90vh] overflow-hidden animate-in zoom-in-95 duration-200">
            
            <!-- Loading State -->
            <div v-if="isLoadingDetails" class="flex-1 flex flex-col items-center justify-center p-12">
                <span class="loading loading-spinner text-primary w-10 h-10"></span>
                <p class="text-secondary mt-4 text-sm animate-pulse">Carregando detalhes do envio...</p>
            </div>

            <template v-else-if="details && details.submission">
                <!-- Header -->
                <div class="p-5 border-b border-div-15 flex items-start justify-between bg-div-05">
                    <div class="flex items-center gap-4">
                        <div class="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center text-primary text-xl font-bold">
                             {{ details.submission.aluno_nome?.charAt(0) }}
                        </div>
                        <div>
                            <h2 class="font-bold text-text text-lg leading-tight">{{ details.submission.aluno_nome }}</h2>
                            <div class="flex items-center gap-2 text-xs text-secondary mt-1">
                                <span class="bg-surface px-1.5 py-0.5 rounded border border-div-15">{{ details.submission.turma_nome }}</span>
                                <span>•</span>
                                <span>Enviado em {{ new Date(details.submission.data_envio).toLocaleString() }}</span>
                            </div>
                        </div>
                    </div>
                    
                    <button @click="$emit('close')" class="p-2 hover:bg-div-15 rounded-lg transition-colors text-secondary hover:text-text">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <div class="flex flex-col md:flex-row flex-1 overflow-hidden">
                    
                    <!-- Content (Left Panel) -->
                    <div class="flex-1 overflow-y-auto p-6 space-y-6 md:border-r border-div-15 bg-surface/50">
                        
                        <!-- Activity Title -->
                        <div class="mb-2">
                             <span class="text-[10px] uppercase font-black tracking-widest text-secondary block mb-1">{{ details.submission.item_tipo }}</span>
                             <h1 class="text-xl font-bold text-text">{{ details.submission.item_titulo }}</h1>
                        </div>

                        <!-- 1. Text Submission -->
                        <div v-if="details.submission.texto_resposta" class="space-y-2">
                             <h3 class="text-xs font-bold text-secondary uppercase tracking-wider flex items-center gap-2">
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="17" y1="10" x2="3" y2="10"></line><line x1="21" y1="6" x2="3" y2="6"></line><line x1="21" y1="14" x2="3" y2="14"></line><line x1="17" y1="18" x2="3" y2="18"></line></svg>
                                Resposta de Texto
                            </h3>
                            <div class="bg-surface p-4 rounded-lg border border-div-15 text-sm text-text whitespace-pre-wrap leading-relaxed shadow-sm">
                                {{ details.submission.texto_resposta }}
                            </div>
                        </div>

                        <!-- 2. File Submission -->
                        <div v-if="details.submission.caminho_arquivo" class="space-y-2">
                            <h3 class="text-xs font-bold text-secondary uppercase tracking-wider flex items-center gap-2">
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                                Arquivo Anexado
                            </h3>
                            <div class="flex items-center gap-3 p-3 bg-div-05 rounded-lg border border-div-15">
                                <div class="w-10 h-10 bg-primary/10 rounded flex items-center justify-center text-primary">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"></path></svg>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <p class="text-xs font-bold text-text truncate">Documento Enviado</p> <!-- TODO: Extract filename if possible -->
                                    <a :href="details.submission.caminho_arquivo" target="_blank" class="text-[10px] text-primary hover:underline">Baixar Arquivo</a>
                                </div>
                            </div>
                        </div>

                        <!-- 3. Quiz Questions -->
                        <div v-if="['Questionário', 'QUESTIONARIO'].includes(details.submission.item_tipo)" class="space-y-6">
                            <div v-if="!details.questions || details.questions.length === 0" class="p-6 text-center text-secondary opacity-50 italic">
                                Perguntas não carregadas ou questionário vazio.
                            </div>
                            
                            <div 
                                v-for="(q, idx) in details.questions" 
                                :key="q.id_pergunta" 
                                class="bg-surface border border-div-15 rounded-lg p-5 shadow-sm space-y-4"
                            >
                                <!-- Question Header -->
                                <div class="flex items-start justify-between">
                                    <div class="flex items-center gap-2">
                                        <span class="w-6 h-6 flex items-center justify-center bg-div-05 rounded text-xs font-bold text-secondary">{{ idx + 1 }}</span>
                                        <span class="text-[10px] uppercase font-bold text-secondary bg-primary/5 px-2 py-0.5 rounded text-primary">{{ getQuestionTypeLabel(q.tipo_pergunta) }}</span>
                                    </div>
                                    <span class="text-[10px] font-mono text-secondary">{{ q.valor }} pt</span>
                                </div>

                                <!-- Enunciado -->
                                <h3 class="text-sm font-bold text-text leading-snug">{{ q.enunciado }}</h3>

                                <!-- Options / Answer Display -->
                                <div v-if="q.tipo_pergunta === 'Múltipla Escolha'" class="space-y-2">
                                    <div 
                                        v-for="opt in q.opcoes" 
                                        :key="opt.id"
                                        class="p-3 rounded border text-sm flex items-center justify-between gap-3"
                                        :class="[
                                            // User Selected
                                            q.resposta_usuario?.id_resposta_possivel === opt.id 
                                                ? (opt.correta ? 'bg-success/10 border-success' : 'bg-danger/10 border-danger') 
                                                : (opt.correta ? 'bg-success/5 border-success/30 border-dashed' : 'bg-surface border-div-15 opacity-60')
                                        ]"
                                    >
                                        <div class="flex items-center gap-3">
                                            <div class="w-4 h-4 rounded-full border flex items-center justify-center shrink-0"
                                                :class="q.resposta_usuario?.id_resposta_possivel === opt.id ? 'border-current' : 'border-secondary/30'"
                                            >
                                                <div v-if="q.resposta_usuario?.id_resposta_possivel === opt.id" class="w-2 h-2 rounded-full bg-current"></div>
                                            </div>
                                            <span :class="q.resposta_usuario?.id_resposta_possivel === opt.id ? 'font-bold' : ''">{{ opt.texto }}</span>
                                        </div>
                                        
                                        <!-- Feedback Icon -->
                                        <div v-if="opt.correta" class="text-success" title="Resposta Correta">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                        </div>
                                        <div v-else-if="q.resposta_usuario?.id_resposta_possivel === opt.id && !opt.correta" class="text-danger" title="Resposta Incorreta">
                                             <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                        </div>
                                    </div>
                                </div>

                                <!-- Essay Answer -->
                                <div v-else class="space-y-1">
                                    <span class="text-[10px] uppercase font-bold text-secondary">Resposta do Aluno:</span>
                                    <div class="p-3 bg-div-05 rounded border border-div-15 text-sm text-text min-h-[60px]">
                                        {{ q.resposta_usuario?.texto_resposta || '(Sem resposta)' }}
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>

                    <!-- Grading (Right Panel) -->
                    <div class="w-full md:w-80 bg-div-05/50 border-t md:border-t-0 p-6 flex flex-col gap-6">
                        <div>
                            <h3 class="font-bold text-text mb-1">Avaliação</h3>
                            <p class="text-xs text-secondary">Defina a nota e feedback.</p>
                        </div>

                        <!-- Grade Input -->
                         <div class="bg-surface p-4 rounded-xl border border-div-15 shadow-sm">
                             <label class="text-[10px] uppercase font-black tracking-widest text-secondary block mb-2">Nota Final</label>
                             <div class="flex items-center gap-3">
                                 <input 
                                    v-model="form.nota"
                                    type="number" 
                                    min="0"
                                    :max="details.submission.pontuacao_maxima || 100"
                                    class="w-24 text-center bg-background border border-div-15 rounded-lg py-2 text-2xl font-black text-text focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20 transition-all"
                                 >
                                 <span class="text-sm font-bold text-secondary opacity-50">/ {{ details.submission.pontuacao_maxima || 100 }} pts</span>
                             </div>
                         </div>

                         <!-- Feedback Input -->
                         <div class="flex-1 flex flex-col">
                             <label class="text-[10px] uppercase font-black tracking-widest text-secondary block mb-2">Feedback do Professor</label>
                              <textarea 
                                v-model="form.comentario"
                                class="flex-1 w-full bg-surface border border-div-15 rounded-xl p-3 text-sm text-text focus:border-primary focus:outline-none resize-none shadow-sm transition-colors"
                                placeholder="Escreva aqui observações para o aluno..."
                            ></textarea>
                         </div>

                         <!-- Actions -->
                         <div class="flex flex-col gap-3">
                             <button 
                                @click="handleSubmit" 
                                :disabled="isLoading"
                                class="w-full py-3 rounded-lg bg-primary text-white font-bold text-sm shadow-lg shadow-primary/20 hover:bg-primary-hover hover:shadow-primary/30 hover:-translate-y-0.5 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                            >
                                <span v-if="isLoading" class="loading loading-spinner loading-xs"></span>
                                Salvar Avaliação
                            </button>
                            <button @click="$emit('close')" class="w-full py-2 text-xs font-bold text-secondary hover:text-text transition-colors">
                                Cancelar
                            </button>
                         </div>
                    </div>
                </div>
            </template>
        </div>
    </div>
</template>
