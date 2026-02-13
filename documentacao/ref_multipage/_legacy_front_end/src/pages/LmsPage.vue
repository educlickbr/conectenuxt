<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import FullPageMenu from '../components/FullPageMenu.vue'
import ModalGerenciarConteudo from '../components/ModalGerenciarConteudo.vue'
import ModalGerenciarItem from '../components/ModalGerenciarItem.vue'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const appStore = useAppStore()
const toast = useToastStore()

// State
const conteudos = ref([])
const totalItens = ref(0)
const totalPaginas = ref(0)
const paginaAtual = ref(1)
const limitePorPagina = ref(10)
const busca = ref('')
const isLoading = ref(false)

// UI States
const isMenuOpen = ref(false)
const isModalConteudoOpen = ref(false)
const isModalItemOpen = ref(false)
const isDeleteModalOpen = ref(false)

const contentToDelete = ref(null)
const selectedContent = ref(null)
const selectedItem = ref(null)
const parentContentId = ref(null) 

const isDeleting = ref(false)
const isDark = ref(false)

// Init Theme
onMounted(() => {
    const savedTheme = localStorage.getItem('theme')
    if (savedTheme) {
        isDark.value = savedTheme === 'dark'
    } else {
        isDark.value = window.matchMedia('(prefers-color-scheme: dark)').matches
    }
    applyTheme()
    fetchConteudos()
})

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
const fetchConteudos = async () => {
    isLoading.value = true
    try {
        const { data, error } = await supabase.rpc('lms_conteudo_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: paginaAtual.value,
            p_limite_itens_pagina: limitePorPagina.value,
            p_termo_busca: busca.value || null,
            p_somente_ativos: false // Admin can see inactive
        })

        if (error) throw error

        if (data) {
             const result = data.dados || []
             conteudos.value = result.map(c => ({...c, isExpanded: false}))
             totalItens.value = data.total || 0
             totalPaginas.value = Math.ceil(totalItens.value / limitePorPagina.value) || 1
        } else {
             conteudos.value = []
             totalItens.value = 0
             totalPaginas.value = 0
        }

    } catch (error) {
        console.error('Erro ao buscar conteúdos:', error)
        toast.showToast('Erro ao carregar conteúdos', 'error')
    } finally {
        isLoading.value = false
    }
}

// Actions Handlers
const handleAddConteudo = () => {
    selectedContent.value = null
    isModalConteudoOpen.value = true
}

const handleEditConteudo = (content) => {
    selectedContent.value = content
    isModalConteudoOpen.value = true
}

const handleAddItem = (contentId) => {
    parentContentId.value = contentId
    selectedItem.value = null
    isModalItemOpen.value = true
}

const handleEditItem = (contentId, item) => {
    parentContentId.value = contentId
    selectedItem.value = item
    isModalItemOpen.value = true
}

const handleDelete = (content) => {
    contentToDelete.value = content
    isDeleteModalOpen.value = true
}

const toggleExpand = (content) => {
    // Toggle expand status
    content.isExpanded = !content.isExpanded
    
    // If we wanted to fetch items strictly on demand, we would do it here. 
    // But our RPC already returns items nested.
}

const confirmDelete = async () => {
    if (!contentToDelete.value) return

    isDeleting.value = true
    try {
        // Implement delete logic later
        toast.showToast('Funcionalidade de deletar em breve', 'info')
        // const { error } = await supabase.from('lms_conteudo').delete().eq('id', contentToDelete.value.id)
        // if (error) throw error
        
        isDeleteModalOpen.value = false
        contentToDelete.value = null
        fetchConteudos()
        // toast.showToast('Conteúdo removido com sucesso.', 'success')
        
    } catch (err) {
        console.error('Erro ao deletar conteúdo:', err)
        toast.showToast('Erro ao remover conteúdo', 'error')
    } finally {
        isDeleting.value = false
    }
}

// Pagination Handlers
const proxPagina = () => {
    if (paginaAtual.value < totalPaginas.value) {
        paginaAtual.value++
    }
}

const antPagina = () => {
    if (paginaAtual.value > 1) {
        paginaAtual.value--
    }
}

// Watchers
let debounceTimeout = null
watch(busca, (newVal) => {
    if (debounceTimeout) clearTimeout(debounceTimeout)
    debounceTimeout = setTimeout(() => {
        paginaAtual.value = 1
        fetchConteudos()
    }, 300)
})

watch(paginaAtual, () => {
    fetchConteudos()
})

const getScopeBadgeClass = (scope) => {
    switch(scope) {
        case 'Turma': return 'bg-blue-100 text-blue-700'
        case 'Aluno': return 'bg-purple-100 text-purple-700'
        case 'Grupo': return 'bg-orange-100 text-orange-700'
        case 'Global': return 'bg-green-100 text-green-700'
        default: return 'bg-gray-100 text-gray-700'
    }
}

const getItemIcon = (tipo) => {
    switch(tipo) {
        case 'Video': return '🎥'
        case 'Material': return '📄'
        case 'Tarefa': return '📝'
        case 'Questionario': return '❓'
        default: return '📎'
    }
}

</script>

<template>
    <div class="h-screen bg-background p-4 flex flex-col md:flex-row gap-4 overflow-hidden font-inter">
        
        <!-- Left Panel: Content & Search -->
        <div class="flex-1 flex flex-col gap-3 h-full overflow-hidden">
            
            <!-- 1. Sleek Header (Floating style) -->
            <header class="bg-div-15 p-3 rounded-xl border border-secondary/20 shadow-sm shrink-0 flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center shadow-sm shrink-0">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                    </div>
                    <div class="min-w-0">
                        <h1 class="text-lg font-bold text-text leading-none truncate">Acadêmico</h1>
                        <p class="text-xs text-secondary font-medium mt-0.5 whitespace-nowrap">
                            {{ totalItens }} folders cadastrados
                        </p>
                    </div>
                </div>

                <div class="flex items-center gap-2 w-full md:w-auto flex-1 justify-end">
                    <div class="relative w-full sm:max-w-[250px]">
                        <input type="text" v-model="busca" placeholder="Filtrar conteúdos..." class="w-full pl-8 pr-3 py-1.5 text-xs bg-background border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary transition-all placeholder-secondary/70 shadow-sm">
                        <span class="absolute left-2.5 top-1.5 text-secondary/70">
                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        </span>
                    </div>

                    <button @click="handleAddConteudo" class="bg-primary hover:bg-primary-hover text-white text-xs font-bold px-4 py-1.5 rounded-lg transition-all shadow-sm flex items-center gap-2">
                        <span>+</span>
                        <span>Novo Folder</span>
                    </button>

                    <div class="hidden md:block h-6 w-[1px] bg-secondary/10 mx-1"></div>

                    <button @click="toggleTheme" class="hidden md:flex p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors">
                        <svg v-if="isDark" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
                        <svg v-else xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
                    </button>
                    <button @click="toggleMenu" class="hidden md:flex p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
                    </button>
                </div>
            </header>

            <!-- 2. Content Area (Iterador) -->
            <div class="flex-1 overflow-y-auto pr-1 flex flex-col gap-3 scrollbar-thin scrollbar-thumb-secondary/20">
                <div v-if="isLoading && conteudos.length === 0" class="text-center p-8 text-secondary text-sm">
                    Carregando conteúdos acadêmicos...
                </div>
                
                <div v-else-if="conteudos.length === 0" class="text-center p-8 text-secondary bg-div-15 rounded-xl border border-secondary/20 border-dashed text-sm">
                    Nenhuma pasta de conteúdo encontrada.
                </div>

                <div v-for="content in conteudos" :key="content.id" class="bg-div-15 rounded-xl border border-secondary/10 shadow-sm overflow-hidden transition-all duration-300 group/card">
                    <!-- Card Header -->
                    <div class="p-4 flex items-center gap-4 cursor-pointer hover:bg-div-30/50" @click="toggleExpand(content)">
                        <div class="w-8 h-8 rounded-lg bg-background border border-secondary/10 flex items-center justify-center text-secondary group-hover/card:text-primary transition-colors">
                            <svg v-if="!content.isExpanded" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                            <svg v-else xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center gap-2">
                                <h3 class="font-bold text-text text-sm truncate group-hover/card:text-primary transition-colors">{{ content.titulo }}</h3>
                                <span :class="getScopeBadgeClass(content.escopo)" class="text-[9px] font-black uppercase tracking-widest px-1.5 py-0.5 rounded border border-black/5">
                                    {{ content.escopo }}
                                </span>
                            </div>
                            <div class="flex items-center gap-3 text-[10px] text-secondary mt-1">
                                <span>🏫 {{ content.nome_turma || 'Geral' }}</span>
                                <span>📅 {{ new Date(content.data_referencia).toLocaleDateString() }}</span>
                            </div>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="text-[10px] font-bold text-secondary bg-background px-2 py-1 rounded-md border border-secondary/10">
                                {{ content.itens ? content.itens.length : 0 }} itens
                            </div>
                            <div class="flex items-center gap-1 opacity-100 lg:opacity-0 lg:group-hover/card:opacity-100 transition-opacity">
                                <button @click.stop="handleEditConteudo(content)" class="p-1.5 hover:bg-primary/10 text-secondary hover:text-primary rounded-md transition-colors">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                </button>
                                <button @click.stop="handleDelete(content)" class="p-1.5 hover:bg-danger/10 text-secondary hover:text-danger rounded-md transition-colors">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Nested Items Area -->
                    <div v-show="content.isExpanded" class="bg-background/20 border-t border-secondary/10 p-4 space-y-2">
                        <div v-for="item in content.itens" :key="item.id" class="bg-div-15 p-3 rounded-lg border border-secondary/5 flex items-center justify-between group/item hover:border-primary/20 transition-all">
                            <div class="flex items-center gap-3">
                                <span class="text-sm shadow-sm p-1.5 bg-background rounded-md">{{ getItemIcon(item.tipo) }}</span>
                                <div class="flex flex-col">
                                    <span class="text-xs font-bold text-text group-hover/item:text-primary transition-colors">{{ item.titulo }}</span>
                                    <div class="flex items-center gap-2 text-[9px] text-secondary font-medium mt-0.5 uppercase tracking-tighter">
                                        <span>{{ item.tipo }}</span>
                                        <span v-if="item.pontuacao_maxima" class="text-orange-500">• {{ item.pontuacao_maxima }} pts</span>
                                    </div>
                                </div>
                            </div>
                            <div class="flex items-center gap-1 opacity-0 group-hover/item:opacity-100 transition-opacity">
                                <button @click="handleEditItem(content.id, item)" class="p-1 text-secondary hover:text-primary transition-colors">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                </button>
                            </div>
                        </div>
                        <button @click="handleAddItem(content.id)" class="w-full py-2 border border-dashed border-secondary/20 rounded-lg text-[10px] font-bold text-secondary hover:text-primary hover:border-primary/40 transition-all uppercase tracking-widest">
                            + Adicionar Atividade
                        </button>
                    </div>
                </div>

                <!-- Pagination Stats -->
                <div class="flex items-center justify-center gap-4 py-4 shrink-0" v-if="conteudos.length > 0">
                    <button @click="antPagina" :disabled="paginaAtual === 1" class="text-xs text-secondary hover:text-primary disabled:opacity-30">Anterior</button>
                    <span class="text-[10px] text-secondary font-bold">{{ paginaAtual }} / {{ totalPaginas }}</span>
                    <button @click="proxPagina" :disabled="paginaAtual >= totalPaginas" class="text-xs text-secondary hover:text-primary disabled:opacity-30">Próxima</button>
                </div>
            </div>
        </div>

        <!-- Right Panel: Dashboard -->
        <aside class="w-full md:w-80 lg:w-96 flex flex-col gap-4 h-full">
            <div class="bg-div-15 rounded-xl border border-secondary/10 p-5 shadow-sm flex flex-col gap-5 h-full overflow-y-auto scrollbar-thin">
                <div>
                    <h3 class="text-xs font-black text-secondary tracking-[0.2em] uppercase mb-4">Dashboard LMS</h3>
                    <div class="space-y-4">
                        <div class="bg-background/40 p-4 rounded-xl border border-secondary/5">
                            <span class="text-2xl font-black text-text">{{ totalItens }}</span>
                            <p class="text-[10px] text-secondary font-bold uppercase tracking-wider mt-1">Total de Folders</p>
                        </div>
                        <div class="grid grid-cols-2 gap-3">
                            <div class="bg-primary/5 p-3 rounded-xl border border-primary/10">
                                <span class="text-lg font-black text-primary">{{ conteudos.filter(c => c.escopo === 'Global').length }}</span>
                                <p class="text-[9px] text-primary/70 font-bold uppercase tracking-tighter mt-1">Global</p>
                            </div>
                            <div class="bg-orange-500/5 p-3 rounded-xl border border-orange-500/10">
                                <span class="text-lg font-black text-orange-500">{{ conteudos.filter(c => c.escopo === 'Turma').length }}</span>
                                <p class="text-[9px] text-orange-500/70 font-bold uppercase tracking-tighter mt-1">Turmas</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="flex-1 min-h-0 overflow-y-auto">
                    <h4 class="text-[10px] font-black text-secondary tracking-widest uppercase mb-3">Dicas de Uso</h4>
                    <div class="space-y-3">
                        <div class="text-[11px] text-secondary leading-relaxed bg-div-30/30 p-3 rounded-lg border border-secondary/5">
                            Organize suas aulas por <b>Folders</b> para facilitar a navegação do aluno.
                        </div>
                        <div class="text-[11px] text-secondary leading-relaxed bg-div-30/30 p-3 rounded-lg border border-secondary/5">
                            Cada folder pode conter múltiplos recursos (vídeos, tarefas, quizzes).
                        </div>
                    </div>
                </div>

            </div>
        </aside>

        <!-- Modals -->
        <ModalGerenciarConteudo 
            :isOpen="isModalConteudoOpen"
            :initialData="selectedContent"
            @close="isModalConteudoOpen = false"
            @success="fetchConteudos"
        />
        <ModalGerenciarItem 
            :isOpen="isModalItemOpen"
            :conteudoId="parentContentId"
            :initialData="selectedItem"
            @close="isModalItemOpen = false"
            @success="fetchConteudos"
        />
        <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />

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
</style>
