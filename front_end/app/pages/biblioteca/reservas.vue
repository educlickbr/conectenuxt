<script setup lang="ts">
import { ref, watch, onMounted, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerDashboard from '@/components/ManagerDashboard.vue'
import ModalEntrega from '@/components/biblioteca/reservas/ModalEntrega.vue'

definePageMeta({
    layout: false,
})

const appStore = useAppStore()
const toast = useToastStore()

// State
const items = ref<any[]>([])
const stats = ref({ total: 0, no_prazo: 0, atrasadas: 0 })
const page = ref(1)
const totalPages = ref(0)
const limit = ref(12) 
const search = ref('')
const isLoading = ref(false)

// Modal State
const showDeliveryModal = ref(false)
const selectedReserva = ref<any>(null)
const isDelivering = ref(false)

// Format Date
const formatDate = (dateString: string) => {
    if (!dateString) return '-'
    return new Date(dateString).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

const formatDateShort = (dateString: string) => {
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
const openDeliveryModal = (reserva: any) => {
    selectedReserva.value = reserva
    showDeliveryModal.value = true
}

const handleConfirmDelivery = async () => {
    if (!selectedReserva.value) return
    isDelivering.value = true
    
    try {
        await $fetch('/api/biblioteca/reservas/entregar', {
            method: 'POST',
            body: {
                reserva_uuid: selectedReserva.value.uuid,
                id_empresa: appStore.company?.empresa_id
            }
        })
        
        toast.showToast('Livro entregue com sucesso.', 'success')
        showDeliveryModal.value = false
        selectedReserva.value = null
        fetchItems()
        fetchStats()
        
    } catch (e: any) {
        toast.showToast(e.message || 'Erro ao entregar livro.', 'error')
    } finally {
        isDelivering.value = false
    }
}

// Init
onMounted(() => {
    fetchStats()
    fetchItems()
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

// Dashboard Stats Computed
const dashboardStats = computed(() => [
  { label: 'Total', value: stats.value.total },
  { label: 'No Prazo', value: stats.value.no_prazo },
  { label: 'Atrasadas', value: stats.value.atrasadas }
])
</script>

<template>
    <NuxtLayout name="manager">
        <!-- Header Slots -->
        <template #header-icon>
            <div class="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center text-primary">
                <span class="text-xl">📕</span>
            </div>
        </template>
        <template #header-title>Reservas</template>
        <template #header-subtitle>Gestão de empréstimos e devoluções.</template>
        
        <template #header-actions>
            <div class="relative w-64">
                <input 
                    v-model="search"
                    type="text" 
                    placeholder="Buscar reserva..." 
                    class="w-full h-9 pl-9 pr-4 bg-surface border border-div-15 rounded text-sm text-text focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all shadow-sm"
                >
                <span class="absolute left-3 top-2.5 text-secondary/50">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                </span>
            </div>
        </template>

        <!-- Sidebar Slot -->
        <template #sidebar>
            <ManagerDashboard title="Dashboard Reservas" :stats="dashboardStats">
                <template #visualization>
                    <div class="h-full flex flex-col items-center justify-center gap-2 opacity-50">
                        <span class="text-4xl">📊</span>
                        <p class="text-[10px] font-bold uppercase tracking-widest text-secondary">Estatísticas em breve</p>
                    </div>
                </template>

                <template #extra>
                     <div class="p-4 bg-primary/5 border border-primary/10 rounded-lg">
                        <h4 class="text-xs font-bold text-primary mb-1">Dica</h4>
                        <p class="text-[11px] text-secondary leading-normal">
                             Clique em "Entregar" para registrar a devolução de um item e torná-lo disponível novamente.
                        </p>
                     </div>
                </template>
            </ManagerDashboard>
        </template>

        <!-- Content Slot -->
        <div class="h-full flex flex-col">
            
            <!-- Modal Confirmation -->
            <ModalEntrega 
                v-if="showDeliveryModal" 
                :reserva="selectedReserva" 
                :is-loading="isDelivering"
                @close="showDeliveryModal = false"
                @confirm="handleConfirmDelivery"
            />

            <!-- Loading/Empty States -->
            <div v-if="isLoading && items.length === 0" class="h-full flex flex-col items-center justify-center text-secondary gap-3">
                 <div class="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                 Carregando reservas...
            </div>

            <div v-else-if="items.length === 0" class="h-full flex flex-col items-center justify-center text-secondary">
                 <div class="text-4xl mb-2 opacity-50">📂</div>
                 <p>Nenhuma reserva encontrada.</p>
            </div>

            <!-- Horizontal List View -->
            <div v-else class="flex-1 overflow-y-auto flex flex-col gap-2 pr-2 pb-4">
                
                 <!-- Header Row (Optional, for clarity) -->
                <div class="grid grid-cols-12 gap-4 px-4 py-2 text-[10px] font-bold uppercase tracking-wider text-secondary">
                    <div class="col-span-4 pl-12">Obra / Usuário</div>
                    <div class="col-span-2">Datas</div>
                    <div class="col-span-2">Localização</div>
                    <div class="col-span-2">Status</div>
                    <div class="col-span-2 text-right">Ações</div>
                </div>

                <div 
                    v-for="res in items" 
                    :key="res.uuid"
                    class="group relative bg-surface rounded-lg border border-div-15 hover:border-primary/30 transition-all shadow-sm grid grid-cols-12 gap-4 items-center p-3"
                >   
                    <!-- Icon / Image -->
                     <div class="col-span-1 hidden sm:flex items-center justify-center">
                        <div class="w-10 h-14 bg-div-05 rounded overflow-hidden border border-div-15 shrink-0">
                            <img v-if="res.livro_capa" :src="res.livro_capa" class="w-full h-full object-cover">
                            <div v-else class="w-full h-full flex items-center justify-center text-secondary text-xs">📘</div>
                        </div>
                    </div>

                    <!-- Col 1: Book & User info -->
                    <div class="col-span-4 sm:col-span-3 flex flex-col justify-center min-w-0">
                        <h3 class="font-bold text-sm text-text truncate" :title="res.livro_titulo">{{ res.livro_titulo }}</h3>
                        <div class="flex items-center gap-2 mt-0.5">
                            <span class="text-xs text-secondary truncate" :title="res.usuario_nome">👤 {{ res.usuario_nome }}</span>
                            <span class="text-[10px] bg-div-05 px-1.5 py-0.5 rounded text-secondary/70 font-mono hidden xl:inline-block">Reg: {{ res.copia_registro || 'N/A' }}</span>
                        </div>
                    </div>

                    <!-- Col 2: Dates -->
                    <div class="col-span-2 flex flex-col justify-center text-xs">
                         <div class="text-secondary">Início: <span class="text-text">{{ formatDateShort(res.data_inicio) }}</span></div>
                         <div class="text-secondary mt-0.5">
                            Devolução: 
                            <span class="font-bold" :class="{'text-danger': res.status_calculado === 'Atrasado'}">
                                {{ formatDateShort(res.data_prevista_devolucao) }}
                            </span>
                         </div>
                    </div>

                    <!-- Col 3: Location -->
                    <div class="col-span-2 flex flex-col justify-center text-xs">
                        <div class="flex items-center gap-1.5 text-secondary">
                            <span>📍</span>
                            <span class="text-text truncate" :title="res.copia_estante || 'Não informado'">{{ res.copia_estante || 'Geral' }}</span>
                        </div>
                    </div>

                    <!-- Col 4: Status / Audit -->
                    <div class="col-span-2 flex flex-col justify-center">
                         <div v-if="res.status_calculado !== 'Entregue'" class="flex items-center gap-2">
                            <span class="relative flex h-2.5 w-2.5">
                                <span v-if="res.status_calculado === 'Atrasado'" class="animate-ping absolute inline-flex h-full w-full rounded-full bg-danger opacity-75"></span>
                                <span class="relative inline-flex rounded-full h-2.5 w-2.5" :class="res.status_calculado === 'Atrasado' ? 'bg-danger' : 'bg-primary'"></span>
                            </span>
                            <span class="text-xs font-bold" :class="res.status_calculado === 'Atrasado' ? 'text-danger' : 'text-primary'">
                                {{ res.status_calculado }}
                            </span>
                         </div>
                         <div v-else class="flex flex-col">
                            <span class="text-xs font-bold text-success flex items-center gap-1">✅ Entregue</span>
                            <span v-if="res.recebido_por_nome" class="text-[10px] text-secondary truncate mt-0.5" :title="'Recebido por ' + res.recebido_por_nome">
                                Por: {{ res.recebido_por_nome.split(' ')[0] }}
                            </span>
                         </div>
                    </div>

                    <!-- Col 5: Actions -->
                    <div class="col-span-2 flex items-center justify-end">
                        <button 
                            v-if="res.status_calculado !== 'Entregue' && res.status_calculado !== 'Cancelado'"
                            @click="openDeliveryModal(res)" 
                            class="px-3 py-1.5 rounded bg-surface border border-div-15 text-xs font-bold text-text hover:bg-success hover:text-white hover:border-success transition-all shadow-sm flex items-center gap-1.5 group/btn"
                        >
                            <span class="group-hover/btn:scale-110 transition-transform">✅</span>
                            Entregar
                        </button>
                        <div v-else class="text-[10px] text-secondary text-right">
                             {{ formatDate(res.recebido_em || res.modificado_em) }}
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
    </NuxtLayout>
</template>
