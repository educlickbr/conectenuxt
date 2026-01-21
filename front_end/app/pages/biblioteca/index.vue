<script setup lang="ts">
import { ref, watch, onMounted, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ModalDetalhesLivro from '@/components/biblioteca/acervo/ModalDetalhesLivro.vue'
import ModalReservar from '@/components/biblioteca/acervo/ModalReservar.vue'
import ManagerDashboard from '@/components/ManagerDashboard.vue'

// Layout
definePageMeta({
    layout: false,
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

const imageBaseUrl = ref('')

const fetchItems = async () => {
    isLoading.value = true
    try {
        const result: any = await $fetch('/api/biblioteca/acervo', {
            params: {
                 id_empresa: appStore.company?.empresa_id,
                 page: page.value,
                 limit: limit.value,
                 search: search.value || undefined,
                 tipo: tipoLivro.value
            }
        })
        
        if (result.imageBaseUrl) {
            imageBaseUrl.value = result.imageBaseUrl
        }

        items.value = (result.items || []).map((item: any) => ({
             ...item,
             id: item.id_edicao, // Ensure id is mapped
             // Construct full URLs if hash is available
             capaUrl: item.capa && imageBaseUrl.value ? `${imageBaseUrl.value}${item.capa}` : null,
             pdfUrl: item.pdf && imageBaseUrl.value ? `${imageBaseUrl.value}${item.pdf}` : null
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

// Watchers
watch([page, tipoLivro], () => {
    fetchItems()
})

// Debounce
let debounceTimer: any
watch(search, () => {
    clearTimeout(debounceTimer)
    debounceTimer = setTimeout(() => {
        page.value = 1
        fetchItems()
    }, 400)
})

// Dashboard Stats Computed
// Dashboard Stats Computed
const dashboardStats = computed(() => [
  { label: 'Obras Listadas', value: items.value.length },
  { label: 'Página Atual', value: page.value }
])

onMounted(() => {
    fetchItems()
})
</script>

<template>
    <NuxtLayout name="manager">
        <!-- Header Slots -->
        <template #header-icon>
            <div class="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center text-primary">
                <span class="text-xl">🏛️</span>
            </div>
        </template>
        <template #header-title>Biblioteca</template>
        <template #header-subtitle>Acervo Digital e Impresso</template>
        
        <template #header-actions>
             <!-- Type Toggle -->
             <div class="bg-surface rounded-lg p-1 border border-div-15 flex shrink-0 self-stretch md:self-auto mr-2">
                 <button 
                    @click="tipoLivro = 'Impresso'" 
                    class="px-3 py-1 rounded-md text-xs font-medium transition-all flex-1 md:flex-none"
                    :class="tipoLivro === 'Impresso' ? 'bg-primary text-white shadow-sm' : 'text-secondary hover:text-text'"
                 >
                    Impresso
                 </button>
                 <button 
                    @click="tipoLivro = 'Digital'" 
                    class="px-3 py-1 rounded-md text-xs font-medium transition-all flex-1 md:flex-none"
                    :class="tipoLivro === 'Digital' ? 'bg-primary text-white shadow-sm' : 'text-secondary hover:text-text'"
                 >
                    Digital
                 </button>
            </div>

            <div class="relative w-48 md:w-64">
                <input 
                    v-model="search"
                    type="text" 
                    placeholder="Buscar por título, autor..." 
                    class="w-full h-9 pl-9 pr-4 bg-surface border border-div-15 rounded text-sm text-text focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all shadow-sm"
                >
                <span class="absolute left-3 top-2.5 text-secondary/50">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                </span>
            </div>
        </template>

        <!-- Sidebar Slot -->
        <template #sidebar>
            <ManagerDashboard title="Dashboard Acervo" :stats="dashboardStats">
                <template #visualization>
                    <div class="h-full flex flex-col items-center justify-center gap-2 opacity-50">
                        <span class="text-4xl">📚</span>
                        <p class="text-[10px] font-bold uppercase tracking-widest text-secondary">Explorar Acervo</p>
                    </div>
                </template>

                <template #extra>
                     <div class="p-4 bg-primary/5 border border-primary/10 rounded-lg">
                        <h4 class="text-xs font-bold text-primary mb-1">Modo Leitura</h4>
                        <p class="text-[11px] text-secondary leading-normal">
                             Clique em "Digital" para acessar e-books instantaneamente.
                        </p>
                     </div>
                </template>
            </ManagerDashboard>
        </template>

        <!-- Content Slot -->
        <div class="h-full flex flex-col">
            
            <div v-if="isLoading && items.length === 0" class="h-full flex flex-col items-center justify-center text-secondary gap-3">
                 <div class="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                 Carregando estante...
            </div>
            
            <div v-else-if="items.length === 0" class="h-full flex flex-col items-center justify-center text-secondary">
                 <div class="text-4xl mb-2 opacity-50">📚</div>
                 <p>Nenhum livro encontrado.</p>
            </div>

            <div v-else class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-7 gap-4 overflow-y-auto pr-2 pb-4 content-start auto-rows-max">
                <div 
                    v-for="item in items" 
                    :key="item.id_edicao" 
                    @click="handleGenericClick(item)"
                    class="flex flex-col bg-surface rounded-lg border border-div-15 overflow-hidden transition-all hover:border-primary/50 group h-full cursor-pointer hover:shadow-lg"
                >
                    <!-- Cover Image Section -->
                    <div class="aspect-[2/3] w-full relative bg-div-05 overflow-hidden border-b border-div-15">
                        <img 
                            v-if="item.capaUrl" 
                            :src="item.capaUrl" 
                            alt="Capa do livro" 
                            class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                        />
                        <div v-else class="w-full h-full flex flex-col items-center justify-center text-secondary bg-surface">
                            <span class="text-3xl opacity-20 mb-2">📘</span>
                            <span class="text-[10px]">Sem capa</span>
                        </div>
                    </div>

                    <!-- Info Section -->
                    <div class="p-3 flex flex-col gap-1.5 bg-div-05/30 flex-1">
                        <div class="flex flex-col gap-0.5">
                            <h3 class="font-bold text-xs text-text leading-tight line-clamp-2" :title="item.titulo || item.titulo_principal">
                                {{ item.titulo || item.titulo_principal || 'Sem título' }}
                            </h3>
                            <p class="text-[10px] text-secondary line-clamp-1" :title="item.nome_autor || item.autor_principal">
                                {{ item.nome_autor || item.autor_principal || 'Autor desconhecido' }}
                            </p>
                        </div>
                        
                        <div class="mt-auto pt-2 border-t border-div-15/50">
                             <button 
                                v-if="tipoLivro === 'Digital'"
                                @click.stop="handleVerLivro(item)"
                                class="w-full py-1.5 rounded bg-primary hover:bg-primary-hover text-white text-[10px] font-bold transition-colors flex items-center justify-center gap-1 shadow-sm"
                             >
                                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                                Ver Livro
                             </button>
                             <button 
                                v-else
                                @click.stop="handleGenericClick(item)"
                                class="w-full py-1.5 rounded text-[10px] font-bold text-white transition-colors flex items-center justify-center gap-1 shadow-sm"
                                :class="item.possui_reserva ? 'bg-warning hover:bg-warning/80' : 'bg-success hover:bg-success-hover'"
                             >
                                <svg v-if="!item.possui_reserva" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
                                <svg v-else xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                                {{ item.possui_reserva ? 'Cancelar' : 'Reservar' }}
                             </button>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Pagination -->
             <div v-if="totalPages > 1" class="flex justify-center shrink-0 pt-4 border-t border-div-15 mt-auto">
                 <div class="flex items-center gap-2 bg-surface p-1 rounded-lg border border-div-15 shadow-sm">
                    <button @click="page--" :disabled="page <= 1" class="p-1.5 rounded hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg></button>
                    <span class="text-xs font-bold text-secondary px-2">{{ page }} / {{ totalPages }}</span>
                    <button @click="page++" :disabled="page >= totalPages" class="p-1.5 rounded hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg></button>
                 </div>
            </div>

        </div>

        <!-- Modals -->
        <template #modals>
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
        </template>
    </NuxtLayout>
</template>
