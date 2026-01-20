<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ModalDetalhesLivro from '@/components/biblioteca/acervo/ModalDetalhesLivro.vue'
import ModalReservar from '@/components/biblioteca/acervo/ModalReservar.vue'

// Layout
definePageMeta({
    layout: 'default' as any,

})

const appStore = useAppStore()
const toast = useToastStore()

// State
const items = ref<any[]>([])
const page = ref(1)
const totalPages = ref(0)
const limit = ref(12)
const search = ref('')
const isLoading = ref(false)
const tipoLivro = ref<'Digital' | 'Impresso'>('Digital')

// Modals
const showDetalhesModal = ref(false)
const showReservaModal = ref(false)
const selectedItem = ref<any>(null)

const fetchItems = async () => {
    isLoading.value = true
    try {
        const { data } = await useFetch('/api/biblioteca/acervo', {
            params: {
                 id_empresa: appStore.company?.empresa_id,
                 page: page.value,
                 limit: limit.value,
                 search: search.value || undefined,
                 tipo: tipoLivro.value
            },
            watch: [page, search, tipoLivro]
        })
        
        const result = (data.value as any) || {}
        // Map items if needed, but API should return clean structure
        items.value = (result.items || []).map((item: any) => ({
             ...item,
             id: item.id_edicao, // Ensure id is mapped
             capaUrl: item.capa ? item.capa : null // Legacy used full hash url, if we don't have it we might need to rely on what backend sends or just keep it minimal
        }))
        totalPages.value = result.pages || 0

    } catch (e: any) {
        toast.showToast(e.message || 'Erro ao carregar acervo.', 'error')
    } finally {
        isLoading.value = false
    }
}

// Handlers
const handleVerLivro = (item: any) => {
    selectedItem.value = item
    showDetalhesModal.value = true
}

const handleReservar = (item: any) => {
    selectedItem.value = item
    showReservaModal.value = true
}

const handleCancelarReserva = async (item: any) => {
    if (!confirm('Deseja cancelar a reserva deste exemplar?')) return
    
    // Optimistic loading?
    isLoading.value = true // Force reload indicator overlay
    try {
        await $fetch('/api/biblioteca/reservas/cancel', {
            method: 'POST',
            body: {
                id_empresa: appStore.company?.empresa_id,
                edicao_uuid: item.id_edicao
            }
        })
        
        toast.showToast('Reserva cancelada com sucesso.', 'success')
        fetchItems()
    } catch (e: any) {
        toast.showToast('Erro ao cancelar reserva.', 'error')
        isLoading.value = false
    }
}

const handleGenericClick = (item: any) => {
    if (tipoLivro.value === 'Digital') {
        handleVerLivro(item)
    } else {
        if (item.possui_reserva) {
             handleCancelarReserva(item)
        } else {
             handleReservar(item)
        }
    }
}

// Debounce
let debounceTimer: any
watch(search, () => {
    clearTimeout(debounceTimer)
    debounceTimer = setTimeout(() => {
        page.value = 1
        fetchItems()
    }, 400)
})
</script>

<template>
    <div class="h-full flex flex-col p-4 md:p-6 gap-6">
        
        <!-- Header -->
        <header class="flex flex-col md:flex-row md:items-center justify-between gap-4 shrink-0 bg-div-05 p-4 rounded-xl border border-div-15">
             <div class="flex items-center gap-4">
                 <div class="w-12 h-12 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-2xl">🏛️</div>
                 <div>
                    <h1 class="text-xl font-bold text-text">Biblioteca</h1>
                    <p class="text-sm text-secondary">Acervo Digital e Impresso</p>
                 </div>
            </div>

            <div class="flex flex-col md:flex-row items-center gap-3 w-full md:w-auto">
                 
                 <!-- Type Toggle -->
                 <div class="bg-surface rounded-lg p-1 border border-div-15 flex shrink-0 self-stretch md:self-auto">
                     <button 
                        @click="tipoLivro = 'Impresso'" 
                        class="px-4 py-1.5 rounded-md text-sm font-medium transition-all flex-1 md:flex-none"
                        :class="tipoLivro === 'Impresso' ? 'bg-primary text-white shadow-sm' : 'text-secondary hover:text-text'"
                     >
                        Impresso
                     </button>
                     <button 
                        @click="tipoLivro = 'Digital'" 
                        class="px-4 py-1.5 rounded-md text-sm font-medium transition-all flex-1 md:flex-none"
                        :class="tipoLivro === 'Digital' ? 'bg-primary text-white shadow-sm' : 'text-secondary hover:text-text'"
                     >
                        Digital
                     </button>
                </div>

                 <!-- Search -->
                 <div class="relative flex-1 md:w-64 w-full">
                    <input 
                        v-model="search"
                        type="text" 
                        placeholder="Buscar por título, autor..." 
                        class="w-full h-10 pl-10 pr-4 bg-surface border border-div-15 rounded-lg text-sm text-text focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all shadow-sm"
                    >
                    <span class="absolute left-3 top-2.5 text-secondary/50">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    </span>
                 </div>
            </div>
        </header>

        <!-- Content Grid -->
        <div class="flex-1 overflow-y-auto min-h-0">
            
            <div v-if="isLoading" class="flex flex-col items-center justify-center p-12 text-secondary gap-3 h-full">
                 <div class="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                 Carregando estante...
            </div>
            
            <div v-else-if="items.length === 0" class="flex flex-col items-center justify-center p-12 text-secondary h-full">
                 <div class="text-4xl mb-2 opacity-50">📚</div>
                 <p>Nenhum livro encontrado.</p>
            </div>

            <div v-else class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-6 pb-6">
                <div 
                    v-for="item in items" 
                    :key="item.id_edicao" 
                    @click="handleGenericClick(item)"
                    class="group relative bg-surface rounded-xl border border-div-15 overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 hover:-translate-y-1 cursor-pointer flex flex-col h-full"
                >
                    <!-- Cover Image -->
                    <div class="aspect-[3/4] w-full bg-div-05 relative overflow-hidden p-4">
                        <img 
                            v-if="item.capaUrl" 
                            :src="item.capaUrl" 
                            alt="Capa do livro" 
                            class="w-full h-full object-cover rounded shadow-md transition-transform duration-500 group-hover:scale-105"
                        />
                        <div v-else class="w-full h-full flex flex-col items-center justify-center text-secondary bg-surface rounded border border-div-15">
                            <span class="text-2xl mb-2 opacity-30">📘</span>
                            <span class="text-[10px]">Sem capa</span>
                        </div>
                    </div>

                    <!-- Info Section -->
                    <div class="px-3 pb-3 pt-2 flex flex-col gap-1 flex-1">
                        <h3 class="font-bold text-[0.95rem] text-text line-clamp-2 leading-tight" :title="item.titulo || item.titulo_principal">
                            {{ item.titulo || item.titulo_principal || 'Sem título' }}
                        </h3>
                        <p class="text-[11px] text-secondary line-clamp-1" :title="item.nome_autor || item.autor_principal">
                            {{ item.nome_autor || item.autor_principal || 'Autor desconhecido' }}
                        </p>
                        
                        <div class="mt-auto pt-3">
                             <button 
                                v-if="tipoLivro === 'Digital'"
                                @click.stop="handleVerLivro(item)"
                                class="w-full py-1.5 rounded-lg bg-primary hover:bg-primary-hover text-white text-xs font-bold transition-colors flex items-center justify-center gap-1 shadow-sm"
                             >
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                                Ver Livro
                             </button>
                             <button 
                                v-else
                                @click.stop="handleGenericClick(item)"
                                class="w-full py-1.5 rounded-lg text-white text-xs font-bold transition-colors flex items-center justify-center gap-1 shadow-sm"
                                :class="item.possui_reserva ? 'bg-warning hover:bg-warning/80' : 'bg-success hover:bg-success-hover'"
                             >
                                <svg v-if="!item.possui_reserva" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
                                <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                                {{ item.possui_reserva ? 'Cancelar Reserva' : 'Reservar' }}
                             </button>
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="flex justify-center shrink-0">
             <div class="flex items-center gap-2 bg-surface p-2 rounded-xl border border-div-15 shadow-sm">
                <button @click="page--" :disabled="page <= 1" class="p-2 rounded-lg hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg></button>
                <span class="text-sm font-bold text-secondary px-2">{{ page }} / {{ totalPages }}</span>
                <button @click="page++" :disabled="page >= totalPages" class="p-2 rounded-lg hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg></button>
             </div>
        </div>

        <!-- Modals -->
        <ModalDetalhesLivro 
            :isOpen="showDetalhesModal" 
            :item="selectedItem" 
            @close="showDetalhesModal = false" 
        />
        
        <ModalReservar 
            :isOpen="showReservaModal" 
            :item="selectedItem" 
            @close="showReservaModal = false"
            @success="fetchItems" 
        />

    </div>
</template>
