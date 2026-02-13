<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import FullPageMenu from '../components/FullPageMenu.vue'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const appStore = useAppStore()
const toast = useToastStore()

// State
const submissoes = ref([])
const isLoading = ref(false)
const isMenuOpen = ref(false)
const isDark = ref(false)

// Filters State
const filtros = ref({
    status: 'pendente', // 'pendente', 'avaliado', or null/'' for all
    turma_id: null,
    escopo: null, // 'Global', 'Turma', 'Aluno'
    aluno_id: null
})

// Options for dropdowns
const turmasOptions = ref([])

// UI State for Modal/Expanded Grading
const selectedSubmissao = ref(null)
const isGradingModalOpen = ref(false)
const gradeForm = ref({
    nota: 0,
    comentario: ''
})

// Init
onMounted(() => {
    initTheme()
    fetchTurmas()
    fetchAvaliacoes()
})

const initTheme = () => {
    const savedTheme = localStorage.getItem('theme')
    if (savedTheme) {
        isDark.value = savedTheme === 'dark'
    } else {
        isDark.value = window.matchMedia('(prefers-color-scheme: dark)').matches
    }
    applyTheme()
}

const applyTheme = () => {
    if (isDark.value) {
        document.documentElement.setAttribute('data-theme', 'dark')
    } else {
        document.documentElement.removeAttribute('data-theme')
    }
}

const toggleTheme = () => {
    isDark.value = !isDark.value
    localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
    applyTheme()
}

const toggleMenu = () => {
    isMenuOpen.value = !isMenuOpen.value
}

// Data Fetching
const fetchTurmas = async () => {
    // Fetch active turmas for filter dropdown
    const { data, error } = await supabase.from('turmas')
        .select('id, ano, classe(nome)')
        .eq('id_empresa', appStore.id_empresa)
        .order('ano', { ascending: false })
    
    if (data) {
        turmasOptions.value = data.map(t => ({
            id: t.id,
            label: `${t.ano} - ${t.classe?.nome || 'Sem Classe'}`
        }))
    }
}

const fetchAvaliacoes = async () => {
    isLoading.value = true
    try {
        const { data, error } = await supabase.rpc('lms_avaliacoes_get', {
            p_id_empresa: appStore.id_empresa,
            p_user_id: appStore.user.id,
            p_filtro_status: filtros.value.status || null,
            p_filtro_turma_id: filtros.value.turma_id || null,
            p_filtro_aluno_id: null, // Not implementing specific student filter yet for simplicity
            p_filtro_escopo: filtros.value.escopo || null
        })

        if (error) throw error
        submissoes.value = data || []

    } catch (error) {
        console.error('Erro ao buscar avaliações:', error)
        toast.showToast('Erro ao carregar submissões.', 'error')
    } finally {
        isLoading.value = false
    }
}

// Actions
const openGradeModal = (submissao) => {
    selectedSubmissao.value = submissao
    gradeForm.value = {
        nota: submissao.nota || 0,
        comentario: submissao.comentario_professor || ''
    }
    isGradingModalOpen.value = true
}

const closeGradeModal = () => {
    isGradingModalOpen.value = false
    selectedSubmissao.value = null
}

const saveGrade = async () => {
    if (!selectedSubmissao.value) return

    try {
        const { data, error } = await supabase.rpc('lms_avaliacao_upsert', {
            p_id_empresa: appStore.id_empresa,
            p_user_id: appStore.user.id,
            p_id_submissao: selectedSubmissao.value.id_submissao,
            p_nota: gradeForm.value.nota,
            p_comentario: gradeForm.value.comentario,
            p_status: 'avaliado'
        })

        if (error) throw error

        toast.showToast('Avaliação salva com sucesso!', 'success')
        closeGradeModal()
        fetchAvaliacoes()

    } catch (error) {
        console.error('Erro ao salvar avaliação:', error)
        toast.showToast('Erro ao salvar nota.', 'error')
    }
}

// Watchers
watch(filtros, () => {
    fetchAvaliacoes()
}, { deep: true })

// Helpers
const formatDate = (dateString) => {
    if (!dateString) return '-'
    return new Date(dateString).toLocaleString()
}

const getStatusBadge = (status) => {
    if (status === 'avaliado') return 'bg-green-100 text-green-700'
    if (status === 'pendente' || !status) return 'bg-yellow-100 text-yellow-700'
    return 'bg-gray-100 text-gray-700'
}

</script>

<template>
    <div class="min-h-screen bg-background p-8 flex flex-col gap-8">
        
        <!-- Header -->
        <div class="sticky top-0 z-30 bg-div-15 backdrop-blur-2xl p-4 rounded-xl border border-secondary shadow-sm flex flex-col md:flex-row items-center justify-between gap-4">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 rounded-full bg-orange-100 text-orange-600 flex items-center justify-center font-bold text-2xl">
                    📝
                </div>
                <div>
                    <h1 class="text-xl font-bold text-text">Avaliação de Conteúdo</h1>
                    <p class="text-sm text-secondary">Gerencie notas e feedbacks das atividades.</p>
                </div>
            </div>

            <div class="flex items-center gap-3">
                 <button @click="toggleTheme" class="p-2 text-secondary hover:text-primary hover:bg-div-30 rounded-lg transition-colors">
                    <svg v-if="isDark" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
                    <svg v-else xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
                </button>
                <button @click="toggleMenu" class="p-2 text-secondary hover:text-primary hover:bg-div-30 rounded-lg transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="bg-div-15 p-4 rounded-xl border border-secondary/10 flex flex-wrap gap-4 items-center">
            
            <!-- Status Filter -->
            <div class="flex flex-col gap-1">
                <label class="text-xs font-bold text-secondary uppercase">Status</label>
                <select v-model="filtros.status" class="bg-background border border-secondary/20 rounded-lg px-3 py-2 text-sm text-text focus:outline-none focus:border-primary">
                    <option :value="null">Todos</option>
                    <option value="pendente">Pendentes</option>
                    <option value="avaliado">Avaliados</option>
                </select>
            </div>

            <!-- Scope Filter -->
            <div class="flex flex-col gap-1">
                <label class="text-xs font-bold text-secondary uppercase">Escopo</label>
                <select v-model="filtros.escopo" class="bg-background border border-secondary/20 rounded-lg px-3 py-2 text-sm text-text focus:outline-none focus:border-primary">
                    <option :value="null">Todos</option>
                    <option value="Global">Global</option>
                    <option value="Turma">Turma</option>
                    <option value="Aluno">Individual</option>
                </select>
            </div>

            <!-- Turma Filter -->
            <div class="flex flex-col gap-1 min-w-[200px]">
                <label class="text-xs font-bold text-secondary uppercase">Turma</label>
                <select v-model="filtros.turma_id" class="bg-background border border-secondary/20 rounded-lg px-3 py-2 text-sm text-text focus:outline-none focus:border-primary">
                    <option :value="null">Todas as Turmas</option>
                    <option v-for="t in turmasOptions" :key="t.id" :value="t.id">{{ t.label }}</option>
                </select>
            </div>

             <div class="ml-auto">
                <button @click="fetchAvaliacoes" class="p-2 bg-primary/10 text-primary hover:bg-primary hover:text-white rounded-lg transition-colors" title="Atualizar">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 4v6h-6"></path><path d="M1 20v-6h6"></path><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
                </button>
            </div>
        </div>

        <!-- List -->
        <div class="flex flex-col gap-4">
             <div v-if="isLoading" class="text-center py-20 text-secondary">
                <div class="animate-spin text-3xl mb-4">⌛</div>
                <p>Carregando submissões...</p>
             </div>
             
             <div v-else-if="submissoes.length === 0" class="text-center py-20 bg-div-15/50 rounded-2xl border-2 border-dashed border-secondary/10 text-secondary">
                 <div class="text-5xl mb-4 opacity-30">📭</div>
                 <p>Nenhuma submissão encontrada com estes filtros.</p>
             </div>

             <div v-else class="grid grid-cols-1 gap-4">
                 <div v-for="sub in submissoes" :key="sub.id_submissao" class="bg-div-15 p-4 rounded-xl border border-secondary/10 shadow-sm hover:shadow-md transition-shadow flex flex-col md:flex-row items-start md:items-center gap-4">
                     
                     <!-- Student Info -->
                     <div class="flex items-center gap-3 min-w-[200px]">
                         <div class="w-10 h-10 rounded-full bg-div-30 flex items-center justify-center font-bold text-text border border-secondary/10 overflow-hidden">
                             <img v-if="sub.aluno_avatar" :src="sub.aluno_avatar" class="w-full h-full object-cover">
                             <span v-else>{{ sub.aluno_nome ? sub.aluno_nome.charAt(0) : '?' }}</span>
                         </div>
                         <div class="flex flex-col">
                             <span class="font-bold text-text leading-tight">{{ sub.aluno_nome }}</span>
                             <span class="text-xs text-secondary">{{ sub.turma_nome || 'Sem Turma' }}</span>
                         </div>
                     </div>

                     <!-- Content Info -->
                     <div class="flex-1">
                         <div class="flex items-center gap-2 mb-1">
                             <span class="text-xs font-bold px-2 py-0.5 rounded bg-div-30 text-secondary border border-secondary/10">{{ sub.escopo }}</span>
                             <span class="text-xs text-secondary">{{ sub.conteudo_titulo }}</span>
                         </div>
                         <h3 class="font-bold text-lg text-primary">{{ sub.item_titulo }}</h3>
                         <p class="text-xs text-secondary mt-1">Enviado em: {{ formatDate(sub.data_envio) }}</p>
                     </div>

                     <!-- Grading Info -->
                     <div class="flex flex-col items-end gap-2 min-w-[150px]">
                         <span :class="getStatusBadge(sub.status)" class="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider">
                             {{ sub.status || 'Pendente' }}
                         </span>
                         <div v-if="sub.nota !== null" class="font-bold text-text text-lg">
                             {{ sub.nota }} <span class="text-sm text-secondary font-normal">/ {{ sub.pontuacao_maxima }}</span>
                         </div>
                         <div v-else class="text-sm text-secondary italic">Sem nota</div>
                     </div>

                     <!-- Action -->
                     <button @click="openGradeModal(sub)" class="p-2 bg-primary/10 hover:bg-primary text-primary hover:text-white rounded-lg transition-colors" title="Avaliar">
                         <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                     </button>
                 </div>
             </div>
        </div>

        <!-- Grade Modal -->
        <div v-if="isGradingModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
            <div class="bg-background rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden border border-secondary/20">
                <div class="p-6 border-b border-secondary/10 flex justify-between items-center">
                    <h2 class="text-xl font-bold text-text">Avaliar Atividade</h2>
                    <button @click="closeGradeModal" class="text-secondary hover:text-danger"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                </div>
                
                <div class="p-6 flex flex-col gap-6">
                    <!-- Summary -->
                    <div class="bg-div-15 p-4 rounded-xl border border-secondary/10">
                        <div class="flex justify-between mb-2">
                             <span class="font-bold text-text">{{ selectedSubmissao.aluno_nome }}</span>
                             <span class="text-xs text-secondary">{{ formatDate(selectedSubmissao.data_envio) }}</span>
                        </div>
                        <p class="text-sm text-secondary">{{ selectedSubmissao.item_titulo }}</p>
                    </div>

                    <!-- Grade Input -->
                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-bold text-secondary">Nota (Máx: {{ selectedSubmissao.pontuacao_maxima }})</label>
                        <input type="number" v-model="gradeForm.nota" class="w-full bg-div-15 border border-secondary/20 rounded-xl px-4 py-3 text-text focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20" :max="selectedSubmissao.pontuacao_maxima" min="0">
                    </div>

                    <!-- Comment Input -->
                    <div class="flex flex-col gap-2">
                        <label class="text-sm font-bold text-secondary">Comentário do Professor</label>
                        <textarea v-model="gradeForm.comentario" rows="4" class="w-full bg-div-15 border border-secondary/20 rounded-xl px-4 py-3 text-text focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 resize-none" placeholder="Escreva um feedback para o aluno..."></textarea>
                    </div>

                </div>

                <div class="p-6 border-t border-secondary/10 flex justify-end gap-3 bg-background">
                    <button @click="closeGradeModal" class="px-6 py-2 rounded-xl text-secondary hover:bg-div-30 transition-colors font-bold">Cancelar</button>
                    <button @click="saveGrade" class="px-6 py-2 rounded-xl bg-primary text-white hover:bg-primary-dark transition-colors font-bold shadow-lg shadow-primary/20">Salvar Avaliação</button>
                </div>
            </div>
        </div>

        <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />

    </div>
</template>
