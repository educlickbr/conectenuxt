<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { useToastStore } from '@/stores/toast'

const props = defineProps<{
    isOpen: boolean
    submission: any
}>()

const emit = defineEmits(['close', 'success'])
const toast = useToastStore()

const isLoading = ref(false)
const form = ref({
    nota: 0,
    comentario: ''
})

// Sync with submission
watch(() => props.submission, (newVal) => {
    if (newVal) {
        form.value.nota = Number(newVal.nota) || 0
        form.value.comentario = newVal.comentario_professor || ''
    }
}, { immediate: true })

const handleSubmit = async () => {
    if (form.value.nota < 0 || form.value.nota > (props.submission?.pontuacao_maxima || 100)) {
        toast.showToast(`A nota deve ser entre 0 e ${props.submission?.pontuacao_maxima || 100}`, 'error')
        return
    }

    isLoading.value = true
    try {
        await $fetch('/api/lms/grade', {
            method: 'POST',
            body: {
                id_submissao: props.submission.id_submissao,
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
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-in fade-in duration-200">
        <div class="bg-surface w-full max-w-lg rounded-xl shadow-2xl border border-div-15 flex flex-col max-h-[90vh] overflow-hidden animate-in zoom-in-95 duration-200">
            
            <!-- Header -->
            <div class="p-4 border-b border-div-15 flex items-center justify-between bg-div-05">
                <div>
                    <h2 class="font-bold text-text text-lg">Corrigir Atividade</h2>
                    <p class="text-xs text-secondary">{{ submission?.aluno_nome }} • {{ submission?.turma_nome }}</p>
                </div>
                <button @click="$emit('close')" class="p-2 hover:bg-div-15 rounded-lg transition-colors text-secondary hover:text-text">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Scrollable Content -->
            <div class="flex-1 overflow-y-auto p-6 space-y-6">
                <!-- Info Card -->
                <div class="bg-div-05/50 border border-div-15 rounded-lg p-4 space-y-2">
                    <div class="flex justify-between items-start">
                        <div>
                            <span class="text-[10px] uppercase font-black tracking-widest text-secondary block mb-1">Atividade</span>
                            <span class="font-bold text-text">{{ submission?.item_titulo }}</span>
                        </div>
                        <div class="text-right">
                             <span class="text-[10px] uppercase font-black tracking-widest text-secondary block mb-1">Enviado em</span>
                             <span class="text-xs text-text">{{ submission?.data_envio ? new Date(submission.data_envio).toLocaleString() : '-' }}</span>
                        </div>
                    </div>
                </div>

                <!-- Answer Preview -->
                <div class="space-y-2">
                    <span class="text-xs font-bold text-secondary uppercase tracking-wider">Resposta do Aluno</span>
                    <div v-if="submission?.status?.includes('quiz')" class="p-4 bg-div-05 rounded border border-div-15 text-sm text-secondary italic">
                        (Questionário - Correção automática ou revisão manual)
                        <div v-if="submission?.nota !== null" class="mt-2 font-bold text-text">Nota Automática: {{ submission.nota }}</div>
                    </div>
                     <!-- Assuming we might fetch full details or text is separate. Wait, RPC lms_avaliacoes_get DOES NOT return 'texto_resposta' yet. 
                          I will fetch details OR just allow grading blindly/based on external view.
                          Actually, the RPC returns `id_submissao`. 
                          Wait! I should probably fetch the TEXT of the submission to display here.
                          OR Add it to the RPC. 
                          For now I'll add a placeholder or assume the user looks elsewhere?
                          User expectation: "Corrigir" implies seeing the answer.
                          I should update RPC `lms_avaliacoes_get` to return `texto_resposta`? 
                          OR fetch it separately.
                          Let's stick to the RPC change plan if needed, but for now I'll implement the inputs.
                     -->
                     <div class="p-4 bg-surface rounded border border-div-15 text-sm text-text min-h-[100px] flex items-center justify-center text-secondary/50">
                        <span class="italic">Visualização da resposta não carregada na lista.</span>
                        <!-- TODO: Enhance RPC to return text/file link -->
                     </div>
                </div>

                <!-- Grading Inputs -->
                <div class="grid grid-cols-2 gap-4">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-secondary uppercase tracking-wider">Nota (Máx: {{ submission?.pontuacao_maxima || 100 }})</label>
                        <input 
                            v-model="form.nota"
                            type="number" 
                            min="0"
                            :max="submission?.pontuacao_maxima || 100"
                            class="w-full bg-background border border-div-15 rounded-lg p-2.5 text-text focus:border-primary focus:outline-none transition-colors font-bold text-lg"
                        >
                    </div>
                </div>

                <div class="space-y-2">
                    <label class="text-xs font-bold text-secondary uppercase tracking-wider">Comentário / Feedback</label>
                    <textarea 
                        v-model="form.comentario"
                        rows="4"
                        placeholder="Escreva um feedback para o aluno..."
                        class="w-full bg-background border border-div-15 rounded-lg p-3 text-sm text-text focus:border-primary focus:outline-none transition-colors resize-none"
                    ></textarea>
                </div>

            </div>

            <!-- Footer -->
            <div class="p-4 border-t border-div-15 bg-div-05 flex justify-end gap-3">
                <button @click="$emit('close')" class="px-4 py-2 rounded-lg text-sm font-bold text-secondary hover:bg-div-15 transition-colors">
                    Cancelar
                </button>
                <button 
                    @click="handleSubmit" 
                    :disabled="isLoading"
                    class="px-6 py-2 rounded-lg text-sm font-bold bg-primary text-white hover:bg-primary-hover shadow-lg hover:shadow-primary/20 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                >
                    <span v-if="isLoading" class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
                    <span>{{ isLoading ? 'Salvando...' : 'Salvar Avaliação' }}</span>
                </button>
            </div>

        </div>
    </div>
</template>
