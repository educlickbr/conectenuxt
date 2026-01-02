<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import FullPageMenu from '../components/FullPageMenu.vue'
import ModalGerenciarObra from '../components/ModalGerenciarObra.vue'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const appStore = useAppStore()
const toast = useToastStore()

const items = ref([])
const totalItens = ref(0)
const totalPaginas = ref(0)
const paginaAtual = ref(1)
const limitePorPagina = ref(12) // Slightly higher for grid view
const busca = ref('')
const isLoading = ref(false)
const isMenuOpen = ref(false)
const isModalOpen = ref(false)
const selectedItem = ref(null)
const imageBaseUrl = ref('')
const isDark = ref(false)

// Init Theme
onMounted(() => {
    initTheme()
    fetchItems()
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

const fetchImageHash = async () => {
    try {
        const { data: { session } } = await supabase.auth.getSession()

        const { data, error } = await supabase.functions.invoke('hash_pasta_conecte', {
            body: { 
                path: '/biblio/',
                user_id: session?.user?.id
            },
            headers: session ? {
                Authorization: `Bearer ${session.access_token}`
            } : {}
        })
        if (error) throw error
        
        if (data && data.url) {
            imageBaseUrl.value = data.url
        }
    } catch (err) {
        console.error('Error fetching image hash:', err)
        // Fallback or retry logic if needed
    }
}

const fetchItems = async () => {
    isLoading.value = true
    try {
        // Ensure we have the image base URL
        if (!imageBaseUrl.value) {
            await fetchImageHash()
        }

        const { data, error } = await supabase.rpc('bbtk_obra_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: paginaAtual.value,
            p_limite_itens_pagina: limitePorPagina.value,
            p_busca: busca.value || null
        })
        
        if (error) throw error
        
        const result = Array.isArray(data) ? data[0] : data
        // Map items to include full image URL and normalize fields
        items.value = (result.itens || []).map(item => ({
            ...item,
            id: item.uuid,
            titulo: item.titulo_principal,
            sub_titulo_principal: item.sub_titulo_principal, // Ensure we pass this to modal initialData if needed
            nome_autor: item.autor_principal_nome,
            tipo_publicacao_nome: item.categoria_nome,
            capaUrl: item.capa_imagem && imageBaseUrl.value 
                ? `${imageBaseUrl.value}${item.capa_imagem}` 
                : null,
            pdfUrl: item.arquivo_pdf && imageBaseUrl.value
                ? `${imageBaseUrl.value}${item.arquivo_pdf}`
                : null
        }))
        
        totalItens.value = result.qtd_itens || 0
        totalPaginas.value = result.qtd_paginas || 0
    } catch (error) {
        toast.showToast('Erro ao carregar dados', 'error')
        console.error(error)
    } finally {
        isLoading.value = false
    }
}

watch([paginaAtual], fetchItems)

let debounceTimeout = null
watch(busca, () => {
    if (debounceTimeout) clearTimeout(debounceTimeout)
    debounceTimeout = setTimeout(() => { paginaAtual.value = 1; fetchItems() }, 300)
})

const proxPagina = () => { if (paginaAtual.value < totalPaginas.value) paginaAtual.value++ }
const antPagina = () => { if (paginaAtual.value > 1) paginaAtual.value-- }

const handleAdd = () => { 
    selectedItem.value = null
    isModalOpen.value = true
}

const handleEdit = (item) => {
    selectedItem.value = item
    isModalOpen.value = true
}

const openPdf = (item) => {
    if (item.pdfUrl) {
        window.open(item.pdfUrl, '_blank')
    } else {
        toast.showToast('PDF não disponível para esta obra.', 'info')
    }
}
</script>

<template>
  <div class="h-screen bg-background p-4 flex flex-col md:flex-row gap-4 overflow-hidden font-inter">
    
    <!-- Left Panel: Header & Grid -->
    <div class="flex-1 flex flex-col gap-3 h-full overflow-hidden">
        
        <!-- Header -->
        <div class="bg-div-15 p-3 rounded-xl border border-secondary/20 shadow-sm shrink-0 flex flex-col md:flex-row md:items-center justify-between gap-4">
            
            <!-- Context -->
            <div class="flex items-center justify-between w-full md:w-auto gap-3">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center shadow-sm shrink-0">
                        <span class="text-xl">📚</span>
                    </div>
                    <div class="min-w-0">
                         <h1 class="text-lg font-bold text-text leading-none capitalize truncate">
                            Gestão de Livros
                        </h1>
                         <p class="text-xs text-secondary font-medium mt-0.5 whitespace-nowrap">
                            {{ totalItens }} obras
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
                <div class="relative w-full sm:max-w-[180px]">
                    <input type="text" v-model="busca" placeholder="Buscar..." class="w-full pl-8 pr-3 py-1.5 text-xs bg-background border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary transition-all placeholder-secondary/70 shadow-sm" />
                    <span class="absolute left-2.5 top-1.5 text-secondary/70">
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    </span>
                </div>

                <button @click="handleAdd" class="bg-primary hover:bg-primary/90 text-white p-1.5 rounded-lg transition-colors shadow-sm flex items-center gap-1 text-xs font-bold leading-none h-[30px] px-3">
                   <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                   <span>Nova</span>
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
        </div>

            <!-- Grid Content -->
        <div class="flex-1 overflow-y-auto pr-1 flex flex-col gap-2 scrollbar-thin scrollbar-thumb-secondary/20 scrollbar-track-transparent">
             <div v-if="isLoading && items.length === 0" class="flex items-center justify-center p-12">
                <div class="text-secondary animate-pulse text-sm">Carregando obras...</div>
            </div>
            
            <div v-else class="grid grid-cols-2 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-3 xl:grid-cols-4 gap-8 content-start p-2">
                <div 
                    v-for="item in items" 
                    :key="item.id" 
                    @click="handleEdit(item)"
                    class="group relative bg-div-15 rounded-xl border border-secondary/20 overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 hover:-translate-y-1 cursor-pointer"
                >
                    <!-- Cover Image -->
                    <div class="aspect-[3/4] w-full bg-div-30/30 relative overflow-hidden flex items-center justify-center p-4">
                        <img 
                            v-if="item.capaUrl" 
                            :src="item.capaUrl" 
                            alt="Capa do livro" 
                            class="w-full h-full object-contain shadow-sm transition-transform duration-500 group-hover:scale-105"
                        />
                        <div v-else class="w-full h-full flex flex-col items-center justify-center text-secondary bg-div-30/50 rounded">
                            <span class="text-[10px] uppercase font-bold tracking-widest opacity-50">Sem capa</span>
                        </div>
                        
                        <!-- Gradient Overlay on Hover -->
                        <div class="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/80 to-transparent p-3 pt-8 translate-y-full group-hover:translate-y-0 transition-transform duration-300 flex flex-col justify-end">
                            <span class="text-[10px] text-white/80 font-medium uppercase tracking-wider">{{ item.tipo_publicacao_nome || 'Obra' }}</span>
                        </div>
                    </div>

                    <!-- Info Section -->
                    <div class="p-3 flex flex-col gap-1">
                        <h3 class="font-bold text-sm text-text line-clamp-2 leading-tight min-h-[2.5em]" :title="item.titulo">
                            {{ item.titulo || 'Sem título' }}
                        </h3>
                        <p class="text-[11px] text-secondary line-clamp-1" :title="item.nome_autor">
                            {{ item.nome_autor || 'Autor desconhecido' }}
                        </p>
                    </div>
                </div>
            </div>
             <!-- Pagination Footer -->
            <div class="flex items-center justify-center gap-4 mt-4 py-2" v-if="items.length > 0">
                <button @click="antPagina" :disabled="paginaAtual === 1" class="text-xs text-secondary hover:text-primary disabled:opacity-30 disabled:cursor-not-allowed flex items-center gap-1">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
                    Anterior
                </button>
                <div class="flex items-center gap-2">
                    <span class="text-xs text-secondary font-medium">{{ paginaAtual }} / {{ totalPaginas }}</span>
                </div>
                <button @click="proxPagina" :disabled="paginaAtual >= totalPaginas" class="text-xs text-secondary hover:text-primary disabled:opacity-30 disabled:cursor-not-allowed flex items-center gap-1">
                    Próxima
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
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
                    <span class="text-secondary text-xs uppercase font-medium tracking-wider">Total Acervo</span>
                    <span class="text-3xl font-bold text-text">{{ totalItens }}</span>
                </div>
            </div>

            <div class="mt-auto p-4 bg-div-30/50 rounded-lg">
                <p class="text-[10px] text-secondary text-center">
                    Gerencie o catálogo de obras da biblioteca. Adicione novos títulos e mantenha o acervo atualizado.
                </p>
            </div>
         </div>
    </div>
    
    <ModalGerenciarObra :isOpen="isModalOpen" :initialData="selectedItem" :imageBaseUrl="imageBaseUrl" @close="isModalOpen = false" @success="fetchItems" />
    <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />

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
