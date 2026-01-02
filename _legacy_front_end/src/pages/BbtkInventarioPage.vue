<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

// Components
import FullPageMenu from '../components/FullPageMenu.vue'
import ModalGerenciarInventario from '../components/ModalGerenciarInventario.vue'

const appStore = useAppStore()
const toast = useToastStore()

// State
const edicoes = ref([])
const totalItens = ref(0)
const totalPaginas = ref(0)
const paginaAtual = ref(1)
const limitePorPagina = ref(10)
const busca = ref('')
const isLoading = ref(false)
const tipoPublicacao = ref('Impresso') 

// UI States
const isMenuOpen = ref(false)
const isDark = ref(false)
const isInventarioModalOpen = ref(false)
const selectedEdicaoInventario = ref(null)

// Init Theme
onMounted(() => {
    initTheme()
    fetchEdicoes()
})

const initTheme = () => {
    const savedTheme = localStorage.getItem('theme')
    isDark.value = savedTheme === 'dark' || (!savedTheme && window.matchMedia('(prefers-color-scheme: dark)').matches)
    applyTheme()
}

const applyTheme = () => {
    if (isDark.value) document.documentElement.setAttribute('data-theme', 'dark')
    else document.documentElement.removeAttribute('data-theme')
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
const fetchEdicoes = async () => {
    isLoading.value = true
    try {
        const { data, error } = await supabase.rpc('bbtk_edicao_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: paginaAtual.value,
            p_limite_itens_pagina: limitePorPagina.value,
            p_termo_busca: busca.value || null,
            p_tipo_livro: tipoPublicacao.value
        })

        if (error) throw error

        if (data) {
             const result = Array.isArray(data) ? data[0] : data
             edicoes.value = result.itens || []
             totalItens.value = result.qtd_itens || 0
             totalPaginas.value = result.qtd_paginas || 0
        } else {
             edicoes.value = []
             totalItens.value = 0
             totalPaginas.value = 0
        }

    } catch (error) {
        console.error('Erro ao buscar edições:', error)
        toast.showToast('Erro ao carregar edições', 'error')
    } finally {
        isLoading.value = false
    }
}

// Actions Handlers
const handleGerenciarInventario = (edicao) => {
    selectedEdicaoInventario.value = edicao
    isInventarioModalOpen.value = true
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
        fetchEdicoes()
    }, 300)
})

watch(paginaAtual, () => {
    fetchEdicoes()
})

</script>

<template>
  <div class="h-screen bg-background p-4 flex flex-col md:flex-row gap-4 overflow-hidden font-inter">
    
    <!-- Left Panel: Header & List -->
    <div class="flex-1 flex flex-col gap-3 h-full overflow-hidden">
        
        <!-- Header -->
        <div class="bg-div-15 p-3 rounded-xl border border-secondary/20 shadow-sm shrink-0 flex flex-col md:flex-row md:items-center justify-between gap-4">
            
            <!-- Context -->
            <div class="flex items-center justify-between w-full md:w-auto gap-3">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center shadow-sm shrink-0">
                        <span class="text-xl">📦</span>
                    </div>
                    <div class="min-w-0">
                         <h1 class="text-lg font-bold text-text leading-none capitalize truncate">
                            Inventário
                        </h1>
                         <p class="text-xs text-secondary font-medium mt-0.5 whitespace-nowrap">
                            {{ totalItens }} edições
                        </p>
                    </div>
                </div>

                <!-- Mobile Controls -->
                <div class="flex items-center gap-1 md:hidden">
                    <button @click="toggleTheme" class="p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors">
                        <svg v-if="isDark" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
                        <svg v-else xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
                    </button>
                    <button @click="toggleMenu" class="p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
                    </button>
                </div>
            </div>

            <!-- Actions -->
            <div class="flex items-center gap-2 w-full md:w-auto flex-1 justify-end">
                <div class="relative w-full sm:max-w-[200px]">
                    <input type="text" v-model="busca" placeholder="Buscar obra..." class="w-full pl-8 pr-3 py-1.5 text-xs bg-background border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary transition-all placeholder-secondary/70 shadow-sm" />
                    <span class="absolute left-2.5 top-1.5 text-secondary/70">
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    </span>
                </div>

                <div class="hidden md:block h-6 w-[1px] bg-secondary/10 mx-1"></div>

                 <button @click="toggleTheme" class="hidden md:flex p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors">
                     <svg v-if="isDark" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
                     <svg v-else xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
                </button>
                <button @click="toggleMenu" class="hidden md:flex p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors">
                     <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
                </button>
            </div>
        </div>

        <!-- List -->
        <div class="flex-1 overflow-y-auto pr-1 flex flex-col gap-2 scrollbar-thin scrollbar-thumb-secondary/20 scrollbar-track-transparent">
            
            <div v-if="isLoading && edicoes.length === 0" class="text-center p-8 text-secondary text-sm">
                Carregando edições...
            </div>

            <div v-else-if="edicoes.length === 0" class="text-center p-8 text-secondary bg-div-15 rounded-xl border border-secondary/20 border-dashed text-sm">
                Nenhuma edição encontrada.
            </div>

            <div v-for="edicao in edicoes" :key="edicao.id_edicao" class="bg-div-15 p-3 rounded-lg border border-secondary/10 hover:border-primary/30 transition-all flex flex-col md:flex-row items-center justify-between group shadow-sm gap-3">
                 <!-- Left Details -->
                 <div class="flex items-center gap-3 min-w-0 flex-1">
                     <!-- Icon indicating Printed Book -->
                     <div class="w-10 h-10 flex-shrink-0 bg-primary/5 rounded border border-secondary/20 flex items-center justify-center text-primary">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                     </div>

                    <div class="flex-1 min-w-0 flex flex-col gap-0.5">
                         <h3 class="font-bold text-text text-sm leading-tight truncate" :title="edicao.titulo_principal">{{ edicao.titulo_principal }}</h3>
                         <div class="flex items-center gap-2 text-xs text-secondary/70 truncate">
                            <span class="truncate">{{ edicao.editora }}</span>
                            <span v-if="edicao.ano_edicao" class="w-1 h-1 rounded-full bg-secondary/50"></span>
                            <span v-if="edicao.ano_edicao">{{ edicao.ano_edicao }}</span>
                         </div>
                         <div class="text-[10px] text-secondary/50 truncate">
                            {{ edicao.autor_principal || 'Sem autor' }}
                         </div>
                    </div>
                </div>

                <!-- Right Actions -->
                <div class="flex items-center gap-2">
                     <button @click="handleGerenciarInventario(edicao)" class="bg-blue-500/10 hover:bg-blue-500/20 text-blue-500 px-3 py-1.5 rounded text-xs font-bold transition-colors flex items-center gap-1">
                          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                          Gerenciar
                     </button>
                </div>
            </div>

              <!-- Pagination -->
            <div class="flex items-center justify-center gap-4 mt-2 py-2" v-if="edicoes.length > 0">
                <button @click="antPagina" :disabled="paginaAtual === 1" class="text-xs text-secondary hover:text-primary disabled:opacity-30 disabled:cursor-not-allowed">
                    Anterior
                </button>
                <span class="text-xs text-secondary">{{ paginaAtual }} / {{ totalPaginas }}</span>
                <button @click="proxPagina" :disabled="paginaAtual >= totalPaginas" class="text-xs text-secondary hover:text-primary disabled:opacity-30 disabled:cursor-not-allowed">
                    Próxima
                </button>
            </div>

        </div>
    </div>

    <!-- Right Panel: Dashboard -->
    <div class="hidden md:flex w-72 flex-col gap-4 h-full overflow-hidden shrink-0">
         <div class="bg-div-15 rounded-xl border border-secondary/20 shadow-sm p-4 h-full flex flex-col gap-4 overflow-y-auto scrollbar-hide">
            
            <h2 class="text-sm font-bold text-text mb-2">Visão Geral</h2>
            
            <!-- Cards -->
            <div class="flex flex-col gap-3">
                 <div class="bg-gradient-to-br from-primary/20 to-primary/5 p-4 rounded-xl border border-primary/20 flex flex-col items-center justify-center gap-1">
                    <span class="text-secondary text-xs uppercase font-medium tracking-wider">Total Obras</span>
                    <span class="text-3xl font-bold text-text">{{ totalItens }}</span>
                </div>
            </div>

            <div class="mt-auto p-4 bg-div-30/50 rounded-lg">
                <p class="text-[10px] text-secondary text-center">
                    Gerencie o inventário de obras impressas. Adicione exemplares e controle o acervo.
                </p>
            </div>
         </div>
    </div>

    <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />
    <ModalGerenciarInventario :isOpen="isInventarioModalOpen" :edicao="selectedEdicaoInventario" @close="isInventarioModalOpen = false" />

  </div>
</template>

<style scoped>
.scrollbar-hide::-webkit-scrollbar {
    display: none;
}
.scrollbar-hide {
    -ms-overflow-style: none;
    scrollbar-width: none;
}
</style>
