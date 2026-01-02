<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import FullPageMenu from '../components/FullPageMenu.vue'
import ModalGerenciarEscola from '../components/ModalGerenciarEscola.vue'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const appStore = useAppStore()
const toast = useToastStore()

// Estado
const escolas = ref([])
const totalItens = ref(0)
const totalPaginas = ref(0)
const paginaAtual = ref(1)
const limitePorPagina = ref(10)
const busca = ref('')
const isLoading = ref(false)
// const idEmpresa = ref('1') // Removed in favor of store

// UI States
const isMenuOpen = ref(false)
const isModalOpen = ref(false)
const isDeleteModalOpen = ref(false)
const schoolToDelete = ref(null)
const selectedSchool = ref(null)
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
    fetchEscolas()
})

// Theme Logic
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

// Menu Logic
const toggleMenu = () => {
    isMenuOpen.value = !isMenuOpen.value
}

// Data Fetching
const fetchEscolas = async () => {
    isLoading.value = true
    try {
        const { data, error } = await supabase.rpc('escolas_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: paginaAtual.value,
            p_limite_itens_pagina: limitePorPagina.value,
            p_busca: busca.value || null
        })

        if (error) throw error

        if (data) {
             // O retorno é um objeto { qtd_itens, qtd_paginas, itens: [...] }
             // Mas como é RPC, as vezes retorna array se não tiver returns json corretamente definidos, 
             // mas o user confirmou objeto. Vamos manter a robustez.
             const result = Array.isArray(data) ? data[0] : data
             
             escolas.value = result.itens || []
             totalItens.value = result.qtd_itens || 0
             totalPaginas.value = result.qtd_paginas || 0
        } else {
             escolas.value = []
             totalItens.value = 0
             totalPaginas.value = 0
        }

    } catch (error) {
        console.error('Erro ao buscar escolas:', error)
        // Opcional: Mostrar toast de erro
    } finally {
        isLoading.value = false
    }
}

// Actions Handlers
const handleAdd = () => {
    selectedSchool.value = null
    isModalOpen.value = true
}

const handleSuccess = () => {
    fetchEscolas()
}

const handleEdit = (escola) => {
    selectedSchool.value = escola
    isModalOpen.value = true
}

const handleDelete = (escola) => {
    schoolToDelete.value = escola
    isDeleteModalOpen.value = true
}

const confirmDelete = async () => {
    if (!schoolToDelete.value) return

    isDeleting.value = true
    try {
        const { error } = await supabase.rpc('escolas_delete', {
            p_id: schoolToDelete.value.id,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        // Sucesso
        isDeleteModalOpen.value = false
        schoolToDelete.value = null
        fetchEscolas()
        toast.showToast('Ação concluída com sucesso.', 'success')
        
    } catch (err) {
        console.error('Erro ao deletar escola:', err)
        toast.showToast('Houve um erro na solicitação', 'error')
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
        paginaAtual.value = 1 // Resetar para primeira página na busca
        fetchEscolas()
    }, 300)
})

watch(paginaAtual, () => {
    fetchEscolas()
})

</script>

<template>
    <div class="min-h-screen bg-background p-6 flex flex-col gap-6">

        <!-- Combined Header & Control Bar -->
        <div class="sticky top-0 z-30 bg-div-15 backdrop-blur-2xl p-4 rounded-xl border border-secondary shadow-sm flex flex-col gap-6">
            
            <!-- Top Section: Title & Actions -->
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-4">
                     <div class="w-12 h-12 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-2xl">
                        🏢
                     </div>
                     <div>
                         <h1 class="text-xl font-bold text-text">Gestão de Escolas</h1>
                         <p class="text-sm text-secondary">
                            <span v-if="isLoading">Carregando...</span>
                            <span v-else>Gerencie todas as {{ totalItens }} escolas da rede.</span>
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
            
            <!-- Separator -->
            <hr class="border-secondary/20" />

            <!-- Bottom Section: Controls (Pagination & Search) -->
            <div class="flex flex-col md:flex-row gap-4 items-center justify-between">
                
                <!-- Pagination Controls -->
                <div class="flex flex-col items-center md:items-start gap-2 w-full md:w-auto">
                    <div class="flex items-center gap-2 bg-background/50 p-1 rounded-lg border border-secondary/30">
                         <button 
                            @click="antPagina" 
                            :disabled="paginaAtual === 1"
                            class="p-1 text-secondary hover:text-primary disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                         >
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                         </button>
                         
                         <div class="flex flex-col items-center">
                            <input 
                                type="number" 
                                v-model="paginaAtual"
                                class="w-12 text-center bg-transparent text-text font-bold focus:outline-none no-arrows"
                                min="1"
                                :max="totalPaginas"
                            >
                            <span class="text-[10px] text-secondary">{{ totalPaginas }} páginas</span>
                         </div>

                         <button 
                            @click="proxPagina" 
                            :disabled="paginaAtual >= totalPaginas"
                            class="p-1 text-secondary hover:text-primary disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                         >
                             <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                         </button>
                    </div>
                </div>

                <!-- Search and Action -->
                <div class="flex w-full md:flex-1 gap-4">
                    <div class="relative flex-1">
                         <input 
                            type="text" 
                            v-model="busca"
                            placeholder="Buscar por nome" 
                            class="w-full pl-10 pr-4 py-2 bg-div-15 border border-secondary rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/70"
                         >
                         <!-- Search Icon -->
                         <span class="absolute left-3 top-2.5 text-secondary">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                         </span>
                    </div>
                    <button 
                        @click="handleAdd"
                        class="bg-blue-600 hover:bg-blue-700 text-white font-medium px-6 py-2 rounded-lg transition-colors flex items-center gap-2 shadow-sm"
                    >
                        Adicionar
                    </button>
                </div>
            </div>
        </div>

        <!-- FullPageMenu Component -->
        <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />
        
        <!-- Modal Gerenciar Escola -->
        <ModalGerenciarEscola 
            :isOpen="isModalOpen" 
            :initialData="selectedSchool"
            @close="isModalOpen = false"
            @success="handleSuccess"
        />

        <!-- Modal Delete Confirmation -->
        <div v-if="isDeleteModalOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-6" @click.self="isDeleteModalOpen = false">
            <div class="bg-background w-full max-w-md rounded-xl shadow-2xl border border-secondary/20 overflow-hidden">
                <div class="p-6 flex flex-col items-center text-center gap-4">
                    <div class="w-16 h-16 rounded-full bg-red-100 text-red-600 flex items-center justify-center mb-2">
                        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                    </div>
                    <h3 class="text-xl font-bold text-text">Excluir Escola?</h3>
                    <p class="text-secondary">
                        Você tem certeza que deseja deletar este registro? 
                        <br>
                        <b class="text-text">{{ schoolToDelete?.nome }}</b>
                    </p>
                </div>
                <div class="flex items-center gap-3 p-4 bg-div-15 border-t border-secondary/20">
                    <button 
                        @click="isDeleteModalOpen = false" 
                        class="flex-1 py-2.5 rounded-lg text-secondary font-medium hover:bg-div-30 transition-colors"
                    >
                        Cancelar
                    </button>
                    <button 
                        @click="confirmDelete"
                        :disabled="isDeleting"
                        class="flex-1 py-2.5 rounded-lg bg-red-600 text-white font-bold hover:bg-red-700 transition-colors disabled:opacity-50 flex items-center justify-center gap-2"
                    >
                        <span v-if="isDeleting" class="animate-spin">⌛</span>
                        Confirmar Exclusão
                    </button>
                </div>
            </div>
        </div>

        <!-- Schools List -->
        <div class="flex flex-col gap-3">
            <div v-if="isLoading && escolas.length === 0" class="text-center p-8 text-secondary">
                Carregando escolas...
            </div>

            <div v-else-if="escolas.length === 0" class="text-center p-8 text-secondary bg-div-15 rounded-xl border border-secondary border-dashed">
                Nenhuma escola encontrada.
            </div>

            <div 
                v-for="escola in escolas" 
                :key="escola.id" 
                class="bg-div-15 p-4 rounded-xl border-l-4 border-l-transparent hover:border-l-primary transition-all flex items-center justify-between group shadow-sm"
            >
                <div class="flex items-center gap-4">
                     <div class="w-10 h-10 rounded-lg bg-background flex items-center justify-center text-text font-bold border border-secondary/20">
                         🏫
                     </div>
                     <div>
                         <h3 class="font-bold text-text text-lg leading-tight">{{ escola.nome }}</h3>
                         <p class="text-sm text-secondary">{{ escola.endereco || 'Endereço não informado' }}</p>
                     </div>
                </div>

                <div class="flex items-center gap-2 opacity-80 group-hover:opacity-100 transition-opacity">
                    <button 
                        @click="handleEdit(escola)" 
                        class="flex flex-col items-center justify-center w-12 h-12 rounded-lg bg-div-30 hover:bg-blue-50 hover:text-blue-600 text-secondary transition-colors"
                        title="Editar"
                    >
                         <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                         <span class="text-[10px] mt-0.5">Editar</span>
                    </button>

                    <button 
                         @click="handleDelete(escola)"
                         class="flex flex-col items-center justify-center w-12 h-12 rounded-lg bg-div-30 hover:bg-red-500 hover:text-white text-secondary transition-colors"
                         title="Apagar"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                        <span class="text-[10px] mt-0.5">Apagar</span>
                    </button>
                </div>
            </div>
        </div>

    </div>
</template>

<style scoped>
/* Remove numeric inputs arrows */
input[type=number]::-webkit-inner-spin-button, 
input[type=number]::-webkit-outer-spin-button { 
  -webkit-appearance: none; 
  margin: 0; 
}
input[type=number] {
      -moz-appearance: textfield; /* For Firefox compatibility, though 'appearance: none;' is often sufficient */
  appearance: none; /* Standard way to remove default browser styling */
  margin: 0; /* Ensures consistent spacing */
}
.no-arrows {
    appearance: none;
}
</style>
