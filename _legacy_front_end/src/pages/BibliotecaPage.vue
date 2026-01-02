<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import FullPageMenu from '../components/FullPageMenu.vue'
import ModalDetalhesLivro from '../components/ModalDetalhesLivro.vue'
import ModalReserva from '../components/ModalReserva.vue'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const appStore = useAppStore()
const toast = useToastStore()

const items = ref([])
const totalItens = ref(0)
const totalPaginas = ref(0)
const paginaAtual = ref(1)
const limitePorPagina = ref(12)
const busca = ref('')
const tipoLivro = ref('Digital') // Default request
const isLoading = ref(false)
const isMenuOpen = ref(false)

// Modals
const showDetalhesModal = ref(false)
const showReservaModal = ref(false)
const selectedItem = ref(null)

const imageBaseUrl = ref('')

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
    }
}

const fetchItems = async () => {
    isLoading.value = true
    try {
        if (!imageBaseUrl.value) {
            await fetchImageHash()
        }

        const { data, error } = await supabase.rpc('bbtk_edicao_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: paginaAtual.value,
            p_limite_itens_pagina: limitePorPagina.value,
            p_termo_busca: busca.value || null,
            p_tipo_livro: tipoLivro.value,
            p_user_uuid: appStore.user?.id || null 
        })
        
        if (error) throw error
        
        const result = Array.isArray(data) ? data[0] : data
        // Map items
        // Fields from bbtk_edicao_get_paginado: id_edicao, id_obra, titulo_principal, autor_principal, editora, ano_edicao, capa, pdf, isbn, possui_reserva...
        items.value = (result.itens || []).map(item => ({
            ...item,
            id: item.id_edicao, // Use edition ID as key
            titulo: item.titulo_principal,
            nome_autor: item.autor_principal,
            capaUrl: item.capa && imageBaseUrl.value 
                ? `${imageBaseUrl.value}${item.capa}` 
                : null,
            pdfUrl: item.pdf && imageBaseUrl.value
                ? `${imageBaseUrl.value}${item.pdf}`
                : null,
            reservado: item.possui_reserva // boolean
        }))
        
        totalItens.value = result.qtd_itens || 0
        totalPaginas.value = result.qtd_paginas || 0
    } catch (error) {
        toast.showToast('Erro ao carregar acervo', 'error')
        console.error(error)
    } finally {
        isLoading.value = false
    }
}

onMounted(() => {
    fetchItems()
})

watch([paginaAtual, tipoLivro], fetchItems)

let debounceTimeout = null
watch(busca, () => {
    if (debounceTimeout) clearTimeout(debounceTimeout)
    debounceTimeout = setTimeout(() => { paginaAtual.value = 1; fetchItems() }, 300)
})

const proxPagina = () => { if (paginaAtual.value < totalPaginas.value) paginaAtual.value++ }
const antPagina = () => { if (paginaAtual.value > 1) paginaAtual.value-- }

// Actions
const handleVerLivro = (item) => {
    selectedItem.value = item
    showDetalhesModal.value = true
}

const handleReservar = (item) => {
    selectedItem.value = item
    showReservaModal.value = true
}

const handleCancelarReserva = async (item) => {
    if (!confirm('Deseja cancelar a reserva deste exemplar?')) return
    
    isLoading.value = true
    try {
        const { error } = await supabase.rpc('bbtk_reserva_cancel', {
            p_id_empresa: appStore.id_empresa,
            p_user_uuid: appStore.user.id,
            p_edicao_uuid: item.id_edicao
        })
        
        if (error) throw error
        
        toast.showToast('Reserva cancelada com sucesso.', 'success')
        fetchItems()
    } catch (e) {
        console.error(e)
        toast.showToast('Erro ao cancelar reserva.', 'error')
        isLoading.value = false
    }
}

const handleGenericClick = (item) => {
    if (tipoLivro.value === 'Digital') {
        handleVerLivro(item)
    } else {
        if (item.reservado) {
             handleCancelarReserva(item)
        } else {
             handleReservar(item)
        }
    }
}

</script>

<template>
    <div class="min-h-screen bg-background p-6 flex flex-col gap-6">
        <!-- Header -->
        <div class="sticky top-0 z-30 bg-div-15 backdrop-blur-2xl p-4 rounded-xl border border-secondary shadow-sm flex flex-col gap-6">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-4">
                     <div class="w-12 h-12 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-2xl">🏛️</div>
                     <div><h1 class="text-xl font-bold text-text">Biblioteca</h1><p class="text-sm text-secondary">Acervo Digital e Impresso</p></div>
                </div>
                
                <div class="flex items-center gap-4">
                    <button @click="isMenuOpen = !isMenuOpen" class="p-2 text-secondary hover:text-primary"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg></button>
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

                <!-- Type Selector (Moved Here) -->
                <div class="bg-background rounded-lg p-1 border border-secondary/20 flex shrink-0">
                     <button 
                        @click="tipoLivro = 'Impresso'" 
                        class="px-4 py-1.5 rounded-md text-sm font-medium transition-all"
                        :class="tipoLivro === 'Impresso' ? 'bg-primary text-white shadow-sm' : 'text-secondary hover:text-text'"
                     >
                        Impresso
                     </button>
                     <button 
                        @click="tipoLivro = 'Digital'" 
                        class="px-4 py-1.5 rounded-md text-sm font-medium transition-all"
                        :class="tipoLivro === 'Digital' ? 'bg-primary text-white shadow-sm' : 'text-secondary hover:text-text'"
                     >
                        Digital
                     </button>
                </div>

                <!-- Search -->
                <div class="relative flex-1 w-full">
                     <input 
                        type="text" 
                        v-model="busca"
                        placeholder="Buscar por título, autor..." 
                        class="w-full pl-10 pr-4 py-2 bg-div-15 border border-secondary rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary/70"
                     >
                     <span class="absolute left-3 top-2.5 text-secondary">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                     </span>
                </div>
            </div>
        </div>

        <!-- Content Grid -->
        <div v-if="isLoading && items.length === 0" class="flex items-center justify-center p-12">
            <div class="text-secondary animate-pulse">Carregando estante...</div>
        </div>
        
        <div v-else class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-6 content-start">
            <div 
                v-for="item in items" 
                :key="item.id_edicao" 
                @click="handleGenericClick(item)"
                class="group relative bg-div-15 rounded-xl border border-secondary/20 overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 hover:-translate-y-1 cursor-pointer flex flex-col h-full"
            >
                <!-- Cover Image -->
                <div class="aspect-[3/4] w-full bg-div-30/30 relative overflow-hidden p-4">
                    <img 
                        v-if="item.capaUrl" 
                        :src="item.capaUrl" 
                        alt="Capa do livro" 
                        class="w-full h-full object-cover rounded shadow-md transition-transform duration-500 group-hover:scale-105"
                    />
                    <div v-else class="w-full h-full flex flex-col items-center justify-center text-secondary bg-div-30 rounded border border-secondary/10">
                        <span class="text-2xl mb-2 opacity-50">📘</span>
                        <span class="text-[10px]">Sem capa</span>
                    </div>
                </div>

                <!-- Info Section -->
                <div class="px-3 pb-3 pt-2 flex flex-col gap-1 flex-1">
                    <h3 class="font-bold text-[0.95rem] text-text line-clamp-2 leading-tight" :title="item.titulo">
                        {{ item.titulo || 'Sem título' }}
                    </h3>
                    <p class="text-[11px] text-secondary line-clamp-1" :title="item.nome_autor">
                        {{ item.nome_autor || 'Autor desconhecido' }}
                    </p>
                    
                    <div class="mt-auto pt-3">
                         <button 
                            v-if="tipoLivro === 'Digital'"
                            @click.stop="handleVerLivro(item)"
                            class="w-full py-1.5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold transition-colors flex items-center justify-center gap-1"
                         >
                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                            Ver Livro
                         </button>
                         <button 
                            v-else
                            @click.stop="handleGenericClick(item)"
                            class="w-full py-1.5 rounded-lg text-white text-xs font-bold transition-colors flex items-center justify-center gap-1"
                            :class="item.reservado ? 'bg-yellow-600 hover:bg-yellow-700' : 'bg-green-600 hover:bg-green-700'"
                         >
                            <svg v-if="!item.reservado" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
                            <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                            {{ item.reservado ? 'Cancelar Reserva' : 'Reservar' }}
                         </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modals -->
        <ModalDetalhesLivro 
            :isOpen="showDetalhesModal" 
            :item="selectedItem" 
            :imageBaseUrl="imageBaseUrl" 
            @close="showDetalhesModal = false" 
        />
        
        <ModalReserva 
            :isOpen="showReservaModal" 
            :item="selectedItem" 
            @close="showReservaModal = false"
            @success="fetchItems" 
        />
        
        <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />
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
  -moz-appearance: textfield;
  appearance: none;
  margin: 0;
}
.no-arrows {
    appearance: none;
}
</style>
