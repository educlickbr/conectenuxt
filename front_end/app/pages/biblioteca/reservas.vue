<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'

// Layout
definePageMeta({
    layout: 'default' as any,

})

const appStore = useAppStore()
const toast = useToastStore()

// State
const items = ref<any[]>([])
const stats = ref({ total: 0, no_prazo: 0, atrasadas: 0 })
const page = ref(1)
const totalPages = ref(0)
const limit = ref(10)
const search = ref('')
const isLoading = ref(false)
const isDelivering = ref(false)
const deliveryId = ref<string | null>(null)

// Format Date
const formatDate = (dateString: string) => {
    if (!dateString) return '-'
    return new Date(dateString).toLocaleDateString('pt-BR')
}

// Fetch Data
const fetchStats = async () => {
    try {
        const data: any = await $fetch('/api/biblioteca/reservas/stats', {
            params: { id_empresa: appStore.company?.empresa_id }
        })
        stats.value = data || { total: 0, no_prazo: 0, atrasadas: 0 }
    } catch (e) {}
}

const fetchItems = async () => {
    isLoading.value = true
    try {
        const result = await $fetch('/api/biblioteca/reservas', {
             params: {
                id_empresa: appStore.company?.empresa_id,
                page: page.value,
                limit: limit.value,
                search: search.value || undefined
            }
        }) as any
        items.value = result.items || []
        totalPages.value = result.pages || 0

    } catch (e: any) {
        toast.showToast(e.message || 'Erro ao carregar dados.', 'error')
    } finally {
        isLoading.value = false
    }
}

// Actions
const handleDeliver = async (reserva: any) => {
    if (isDelivering.value) return
    isDelivering.value = true
    deliveryId.value = reserva.uuid
    
    try {
        await $fetch('/api/biblioteca/reservas', {
            method: 'POST',
            body: {
                action: 'deliver',
                id: reserva.uuid,
                id_empresa: appStore.company?.empresa_id
            }
        })
        
        toast.showToast('Livro entregue com sucesso.', 'success')
        fetchItems()
        fetchStats()
        
    } catch (e: any) {
        toast.showToast('Erro ao entregar livro.', 'error')
    } finally {
        isDelivering.value = false
        deliveryId.value = null
    }
}

// Init
onMounted(() => {
    fetchStats()
})

// Debounce Search
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
        <header class="flex flex-col md:flex-row md:items-center justify-between gap-4 shrink-0">
             <div>
                 <h1 class="text-2xl font-bold text-text flex items-center gap-2">
                    <span class="text-3xl">📕</span>
                    Reservas
                 </h1>
                 <p class="text-sm text-secondary mt-1">Gestão de empréstimos e devoluções.</p>
            </div>

            <div class="flex items-center gap-3 w-full md:w-auto">
                 <div class="relative flex-1 md:w-64">
                    <input 
                        v-model="search"
                        type="text" 
                        placeholder="Buscar reserva..." 
                        class="w-full h-10 pl-10 pr-4 bg-surface border border-div-15 rounded-lg text-sm text-text focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all shadow-sm"
                    >
                    <span class="absolute left-3 top-2.5 text-secondary/50">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    </span>
                 </div>
            </div>
        </header>

        <div class="flex flex-col md:flex-row gap-6 h-full min-h-0">
            
            <!-- Main List -->
            <div class="flex-1 overflow-y-auto min-h-0 bg-surface border border-div-15 rounded-xl p-4 shadow-sm flex flex-col">
                
                <div v-if="isLoading && items.length === 0" class="flex-1 flex flex-col items-center justify-center text-secondary gap-3">
                     <div class="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                     Carregando reservas...
                </div>

                <div v-else-if="items.length === 0" class="flex-1 flex flex-col items-center justify-center text-secondary">
                     <div class="text-4xl mb-2 opacity-50">📂</div>
                     <p>Nenhuma reserva encontrada.</p>
                </div>

                <div v-else class="flex flex-col gap-3">
                    <div 
                        v-for="res in items" 
                        :key="res.uuid"
                        class="bg-div-05/50 p-3 rounded-xl border border-div-15 hover:border-primary/30 transition-all flex flex-col md:flex-row items-center justify-between gap-4 group"
                    >
                        <div class="flex items-center gap-3 min-w-0 flex-1">
                             <div class="w-10 h-14 rounded bg-surface flex items-center justify-center text-secondary overflow-hidden border border-div-15 flex-shrink-0">
                                <img v-if="res.livro_capa" :src="res.livro_capa" alt="Capa" class="w-full h-full object-cover">
                                <span v-else class="text-xl">📖</span>
                            </div>
                            <div class="min-w-0 flex flex-col gap-0.5">
                                <h3 class="font-bold text-text text-sm leading-tight truncate" :title="res.livro_titulo">{{ res.livro_titulo }}</h3>
                                <div class="flex flex-col gap-0.5">
                                    <span class="text-xs text-secondary flex items-center gap-1">👤 <span class="truncate">{{ res.usuario_nome }}</span></span>
                                    <span class="text-[10px] text-secondary/60">🆔 {{ res.usuario_matricula }}</span>
                                </div>
                            </div>
                        </div>

                         <div class="flex items-center gap-3 self-end md:self-center flex-wrap justify-end">
                            <span class="px-2 py-1 rounded bg-info/10 text-info text-xs font-bold">
                                {{ formatDate(res.data_inicio) }}
                            </span>
                            
                            <span v-if="res.status_calculado !== 'Entregue'" 
                                class="px-2 py-1 rounded text-xs font-bold"
                                :class="res.status_calculado === 'Atrasado' ? 'bg-danger/10 text-danger' : 'bg-success/10 text-success'"
                            >
                                Até {{ formatDate(res.data_prevista_devolucao) }}
                            </span>

                            <div v-if="res.status_calculado === 'Entregue'" class="px-2 py-1 rounded bg-secondary/10 text-secondary text-xs font-bold flex items-center gap-1">
                                ✅ Entregue
                            </div>
                            <button v-else @click="handleDeliver(res)" :disabled="isDelivering && deliveryId === res.uuid" class="px-3 py-1.5 rounded bg-success text-white text-xs font-bold hover:bg-success-hover transition-colors flex items-center gap-1 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed">
                                <span v-if="isDelivering && deliveryId === res.uuid" class="w-3 h-3 border-2 border-white/50 border-t-white rounded-full animate-spin"></span>
                                <span v-else>✅</span>
                                Entregar
                            </button>
                        </div>
                    </div>
                </div>

                 <!-- Pagination -->
                <div v-if="totalPages > 1" class="flex justify-center shrink-0 mt-4 border-t border-div-15 pt-4">
                     <div class="flex items-center gap-2 bg-surface p-1 rounded-lg border border-div-15 shadow-sm">
                        <button @click="page--" :disabled="page <= 1" class="p-1.5 rounded hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg></button>
                        <span class="text-xs font-bold text-secondary px-2">{{ page }} / {{ totalPages }}</span>
                        <button @click="page++" :disabled="page >= totalPages" class="p-1.5 rounded hover:bg-div-05 disabled:opacity-50 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg></button>
                     </div>
                </div>

            </div>

             <!-- Stats Sidebar -->
            <div class="hidden md:flex w-64 flex-col gap-4 shrink-0">
                <div class="bg-surface rounded-xl border border-div-15 shadow-sm p-4 h-full flex flex-col gap-4">
                    <h2 class="text-sm font-bold text-text uppercase tracking-wider">Visão Geral</h2>
                    
                    <div class="grid grid-cols-1 gap-3">
                        <div class="bg-div-05 p-4 rounded-xl border border-div-15 flex flex-col items-center justify-center gap-1">
                            <span class="text-secondary text-xs uppercase font-bold tracking-wider">Ativas</span>
                            <span class="text-3xl font-bold text-text">{{ stats.total }}</span>
                        </div>
                        <div class="bg-success/5 p-4 rounded-xl border border-success/20 flex flex-col items-center justify-center gap-1">
                            <span class="text-success text-xs uppercase font-bold tracking-wider">No Prazo</span>
                            <span class="text-3xl font-bold text-success">{{ stats.no_prazo }}</span>
                        </div>
                        <div class="bg-danger/5 p-4 rounded-xl border border-danger/20 flex flex-col items-center justify-center gap-1">
                            <span class="text-danger text-xs uppercase font-bold tracking-wider">Atrasadas</span>
                            <span class="text-3xl font-bold text-danger">{{ stats.atrasadas }}</span>
                        </div>
                    </div>

                    <div class="mt-auto p-4 bg-div-05 rounded-lg border border-div-15">
                        <p class="text-[10px] text-secondary text-center leading-relaxed">
                            Acompanhe as reservas e realize a baixa dos livros devolvidos utilizando o botão de entrega.
                        </p>
                    </div>
                </div>
            </div>

        </div>

    </div>
</template>
