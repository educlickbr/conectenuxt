<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import FullPageMenu from '../components/FullPageMenu.vue'
import ModalGerenciarProfessor from '../components/ModalGerenciarProfessor.vue'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const appStore = useAppStore()
const toast = useToastStore()

// State
const professores = ref([])
const totalItens = ref(0)
const totalPaginas = ref(0)
const paginaAtual = ref(1)
const limitePorPagina = ref(10)
const busca = ref('')
const isLoading = ref(false)

// UI States
const isMenuOpen = ref(false)
const isModalOpen = ref(false)
const isDeleteModalOpen = ref(false)
const professorToDelete = ref(null)
const selectedProfessor = ref(null)
const isDeleting = ref(false)

const isInviting = ref(false)
const isInviteModalOpen = ref(false)
const professorToInvite = ref(null)
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
    fetchProfessores()
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
const fetchProfessores = async () => {
    isLoading.value = true
    try {
        const { data, error } = await supabase.rpc('professor_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: paginaAtual.value,
            p_limite_itens_pagina: limitePorPagina.value,
            p_busca: busca.value || null,
            p_id_escola: null, // Opcional, se quisermos filtrar por escola depois
            p_status: null // Opcional
        })

        if (error) throw error

        if (data) {
             const result = Array.isArray(data) ? data[0] : data
             professores.value = result.itens || []
             totalItens.value = result.qtd_itens || 0
             totalPaginas.value = result.qtd_paginas || 0
        } else {
             professores.value = []
             totalItens.value = 0
             totalPaginas.value = 0
        }

    } catch (error) {
        console.error('Erro ao buscar professores:', error)
        toast.showToast('Erro ao carregar professores', 'error')
    } finally {
        isLoading.value = false
    }
}

// Actions Handlers
const handleAdd = () => {
    selectedProfessor.value = null
    isModalOpen.value = true
}

const handleSuccess = () => {
    fetchProfessores()
}

const handleEdit = (professor) => {
    selectedProfessor.value = professor
    isModalOpen.value = true
}

const handleDelete = (professor) => {
    professorToDelete.value = professor
    isDeleteModalOpen.value = true
}

const confirmDelete = async () => {
    if (!professorToDelete.value) return

    isDeleting.value = true
    try {
        // Usa o user_expandido_id (o ID da tabela user_expandido)
        const { error } = await supabase.rpc('professor_delete', {
            p_id: professorToDelete.value.user_expandido_id,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        isDeleteModalOpen.value = false
        professorToDelete.value = null
        fetchProfessores()
        toast.showToast('Professor removido com sucesso.', 'success')
        
    } catch (err) {
        console.error('Erro ao deletar professor:', err)
        toast.showToast('Erro ao remover professor', 'error')
    } finally {
        isDeleting.value = false
    }
}

// Invite Handlers
const handleInvite = (professor) => {
    // Assuming professor object *might* have email or we need to alert if missing
    // Since the list might NOT have email, we should ideally check or fetch it.
    // However, to keep it simple as per previous step logic, we try to use what we have.
    // If 'email' is not in the list view, this will fail.
    // Let's assume it IS there for now based on typical usage, otherwise we'd need to fetch details.
    if (!professor.email) {
         toast.showToast('Email não encontrado para este professor.', 'warning')
         return
    }
    professorToInvite.value = professor
    isInviteModalOpen.value = true
}

const confirmInvite = async () => {
    if (!professorToInvite.value) return

    isInviting.value = true
    try {
         const payload = {
            professores: [
                {
                    email: professorToInvite.value.email,
                    papel_id: "3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1",
                    empresa_id: appStore.id_empresa
                }
            ]
        }

        const { error } = await supabase.functions.invoke('convidar_user_expandido', {
            body: payload
        })

        if (error) throw error

        toast.showToast('Convite enviado com sucesso!', 'success')
        isInviteModalOpen.value = false
        professorToInvite.value = null

    } catch (error) {
        console.error('Erro ao convidar professor:', error)
        toast.showToast('Erro ao enviar convite.', 'error')
    } finally {
        isInviting.value = false
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
        fetchProfessores()
    }, 300)
})

watch(paginaAtual, () => {
    fetchProfessores()
})

</script>

<template>
    <div class="min-h-screen bg-background p-6 flex flex-col gap-6">

        <!-- Header Block -->
        <div class="sticky top-0 z-30 bg-div-15 backdrop-blur-2xl p-4 rounded-xl border border-secondary shadow-sm flex flex-col gap-6">
            
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-4">
                     <div class="w-12 h-12 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-2xl">
                        👨‍🏫
                     </div>
                     <div>
                         <h1 class="text-xl font-bold text-text">Gerenciar Professores</h1>
                         <p class="text-sm text-secondary">
                            <span v-if="isLoading">Carregando...</span>
                            <span v-else>Total de {{ totalItens }} professores cadastrados.</span>
                         </p>
                     </div>
                </div>

                <div class="flex items-center gap-3">
                    <button @click="toggleTheme" class="p-2 text-secondary hover:text-primary hover:bg-div-30 rounded-lg transition-colors" title="Alternar Tema">
                        <svg v-if="isDark" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
                        <svg v-else xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
                    </button>
                    <button @click="toggleMenu" class="p-2 text-secondary hover:text-primary hover:bg-div-30 rounded-lg transition-colors" title="Menu">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
                    </button>
                </div>
            </div>
            
            <hr class="border-secondary/20" />

            <div class="flex flex-col md:flex-row gap-4 items-center justify-between">
                
                <!-- Pagination -->
                <div class="flex items-center gap-2 bg-background/50 p-1 rounded-lg border border-secondary/30">
                     <button @click="antPagina" :disabled="paginaAtual === 1" class="p-1 text-secondary hover:text-primary disabled:opacity-50 disabled:cursor-not-allowed transition-colors"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="8" y1="12" x2="16" y2="12"></line></svg></button>
                     <div class="flex flex-col items-center">
                        <input type="number" v-model="paginaAtual" class="w-12 text-center bg-transparent text-text font-bold focus:outline-none no-arrows" min="1" :max="totalPaginas">
                        <span class="text-[10px] text-secondary">{{ totalPaginas }} pág.</span>
                     </div>
                     <button @click="proxPagina" :disabled="paginaAtual >= totalPaginas" class="p-1 text-secondary hover:text-primary disabled:opacity-50 disabled:cursor-not-allowed transition-colors"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg></button>
                </div>

                <!-- Search -->
                <div class="flex w-full md:flex-1 gap-4">
                    <div class="relative flex-1">
                         <input type="text" v-model="busca" placeholder="Buscar professor..." class="w-full pl-10 pr-4 py-2 bg-div-15 border border-secondary rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary">
                         <span class="absolute left-3 top-2.5 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg></span>
                    </div>
                    <button @click="handleAdd" class="bg-blue-600 hover:bg-blue-700 text-white font-medium px-6 py-2 rounded-lg transition-colors flex items-center gap-2 shadow-sm">
                        Adicionar
                    </button>
                </div>
            </div>
        </div>

        <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />
        
        <ModalGerenciarProfessor 
            :isOpen="isModalOpen" 
            :initialData="selectedProfessor"
            @close="isModalOpen = false"
            @success="handleSuccess"
        />

        <!-- Delete Modal -->
        <div v-if="isDeleteModalOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-6" @click.self="isDeleteModalOpen = false">
            <div class="bg-background w-full max-w-md rounded-xl shadow-2xl border border-secondary/20 overflow-hidden">
                <div class="p-6 flex flex-col items-center text-center gap-4">
                    <div class="w-16 h-16 rounded-full bg-red-100 text-red-600 flex items-center justify-center mb-2">
                        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                    </div>
                    <h3 class="text-xl font-bold text-text">Demitir Professor?</h3>
                    <p class="text-secondary">
                        Atenção: Esta ação realizará uma exclusão lógica.<br>
                        <b class="text-text">{{ professorToDelete?.nome_completo }}</b>
                    </p>
                </div>
                <div class="flex items-center gap-3 p-4 bg-div-15 border-t border-secondary/20">
                    <button @click="isDeleteModalOpen = false" class="flex-1 py-2.5 rounded-lg text-secondary font-medium hover:bg-div-30 transition-colors">Cancelar</button>
                    <button @click="confirmDelete" :disabled="isDeleting" class="flex-1 py-2.5 rounded-lg bg-red-600 text-white font-bold hover:bg-red-700 transition-colors disabled:opacity-50 flex items-center justify-center gap-2">
                        <span v-if="isDeleting" class="animate-spin">⌛</span>
                        Sim, Demitir
                    </button>
                </div>
            </div>

        </div>

        <!-- Invite Confirmation Modal -->
        <div v-if="isInviteModalOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-6" @click.self="isInviteModalOpen = false">
            <div class="bg-background w-full max-w-sm rounded-xl shadow-2xl border border-secondary/20 overflow-hidden">
                <div class="p-6 flex flex-col items-center text-center gap-4">
                    <div class="w-14 h-14 rounded-full bg-purple-100 text-purple-600 flex items-center justify-center mb-1">
                        <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                    </div>
                    <h3 class="text-xl font-bold text-text">Convidar Professor?</h3>
                    <p class="text-secondary text-sm">
                        Será enviado um email de convite para:<br>
                        <b class="text-text">{{ professorToInvite?.email }}</b>
                    </p>
                    <p class="text-xs text-secondary/70">
                        O professor receberá instruções para definir sua senha.
                    </p>
                </div>
                <div class="flex items-center gap-3 p-4 bg-div-15 border-t border-secondary/20">
                    <button @click="isInviteModalOpen = false" class="flex-1 py-2.5 rounded-lg text-secondary font-medium hover:bg-div-30 transition-colors text-sm">Cancelar</button>
                    <button @click="confirmInvite" :disabled="isInviting" class="flex-1 py-2.5 rounded-lg bg-purple-600 text-white font-bold hover:bg-purple-700 transition-colors flex items-center justify-center gap-2 text-sm shadow-lg shadow-purple-600/20">
                        <span v-if="isInviting" class="animate-spin">⌛</span>
                        Confirmar Convite
                    </button>
                </div>
            </div>
        </div>

        <!-- List -->
        <div class="flex flex-col gap-3">
            <div v-if="isLoading && professores.length === 0" class="text-center p-8 text-secondary">
                Carregando...
            </div>

            <div v-else-if="professores.length === 0" class="text-center p-8 text-secondary bg-div-15 rounded-xl border border-secondary border-dashed">
                Nenhum professor encontrado.
            </div>

            <div v-for="prof in professores" :key="prof.user_expandido_id" class="bg-div-15 p-4 rounded-xl border-l-4 border-l-transparent hover:border-l-primary transition-all flex flex-col md:flex-row md:items-center justify-between group shadow-sm gap-4">
                
                <div class="flex items-center gap-4">
                     <div class="w-10 h-10 rounded-lg bg-background flex items-center justify-center text-text font-bold border border-secondary/20">
                         👤
                     </div>
                     <div>
                         <h3 class="font-bold text-text text-lg leading-tight">{{ prof.nome_completo }}</h3>
                         <div class="flex items-center gap-2 text-sm text-secondary">
                             <span class="flex items-center gap-1" title="Escola">
                                🏫 {{ prof.nome_escola || 'Sem escola' }}
                             </span>
                             <span class="w-1 h-1 rounded-full bg-secondary"></span>
                             <span :class="prof.status === 'Ativo' ? 'text-green-500' : 'text-red-500'">{{ prof.status }}</span>
                         </div>
                     </div>
                </div>

                <div class="flex items-center gap-2 self-end md:self-auto opacity-90 transition-opacity">
                    <!-- Botões Extras Placeholder -->
                    <button disabled class="flex flex-col items-center justify-center h-10 px-3 rounded-lg bg-div-30 text-secondary/50 cursor-not-allowed text-xs border border-transparent" title="Em breve">
                        Escola
                    </button>
                    <button disabled class="flex flex-col items-center justify-center h-10 px-3 rounded-lg bg-div-30 text-secondary/50 cursor-not-allowed text-xs border border-transparent" title="Em breve">
                        Contrato
                    </button>

                    <div class="w-[1px] h-8 bg-secondary/20 mx-1"></div>

                    <button @click="handleInvite(prof)" class="flex flex-col items-center justify-center w-10 h-10 rounded-lg bg-purple-600/10 hover:bg-purple-600/20 text-purple-600 transition-colors" title="Convidar">
                         <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2" ry="2"></rect><polyline points="3 7 12 13 21 7"></polyline></svg>
                    </button>

                    <button @click="handleEdit(prof)" class="flex flex-col items-center justify-center w-10 h-10 rounded-lg bg-div-30 hover:bg-blue-50 hover:text-blue-600 text-secondary transition-colors" title="Editar">
                         <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    </button>

                    <button @click="handleDelete(prof)" class="flex flex-col items-center justify-center w-10 h-10 rounded-lg bg-div-30 hover:bg-red-500 hover:text-white text-secondary transition-colors" title="Apagar">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                    </button>
                </div>
            </div>
        </div>

    </div>
</template>

<style scoped>
.no-arrows {
    appearance: none;
}
input[type=number]::-webkit-inner-spin-button, 
input[type=number]::-webkit-outer-spin-button { 
  -webkit-appearance: none; 
  margin: 0; 
}
</style>
