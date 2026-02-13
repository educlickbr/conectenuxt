<script setup>
import { ref, onMounted, watch, computed } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

// Components
import FullPageMenu from '../components/FullPageMenu.vue'
import UsrDashboard from '../components/usr_components/UsrDashboard.vue'

const appStore = useAppStore()
const toast = useToastStore()

// State
const reservas = ref([])
const stats = ref({ total: 0, no_prazo: 0, atrasadas: 0 })
const totalItens = ref(0)
const totalPaginas = ref(0)
const paginaAtual = ref(1)
const limitePorPagina = ref(10)
const busca = ref('')
const isLoading = ref(false)
const isLoadingStats = ref(false)

// UI States
const isMenuOpen = ref(false)
const isDark = ref(false)
const isDelivering = ref(false)
const reservationToDeliver = ref(null)

// Init Theme
onMounted(() => {
    initTheme()
    fetchStats()
    fetchReservas()
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
const fetchStats = async () => {
    isLoadingStats.value = true
    try {
        const { data, error } = await supabase.rpc('bbtk_reserva_stats', {
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        if (data) {
            stats.value = data
        }
    } catch (error) {
        console.error('Erro ao buscar estatísticas:', error)
    } finally {
        isLoadingStats.value = false
    }
}

const fetchReservas = async () => {
    isLoading.value = true
    try {
        const { data, error } = await supabase.rpc('bbtk_reserva_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_offset: (paginaAtual.value - 1) * limitePorPagina.value,
            p_limit: limitePorPagina.value,
            p_filtro: busca.value || null
        })

        if (error) throw error

        if (data) {
             reservas.value = data.data || []
             totalItens.value = data.total || 0
             totalPaginas.value = Math.ceil(totalItens.value / limitePorPagina.value) || 0
        } else {
             reservas.value = []
             totalItens.value = 0
             totalPaginas.value = 0
        }

    } catch (error) {
        console.error('Erro ao buscar reservas:', error)
        toast.showToast('Erro ao carregar reservas', 'error')
    } finally {
        isLoading.value = false
    }
}

const handleDeliver = async (reserva) => {
    if (isDelivering.value) return
    isDelivering.value = true
    reservationToDeliver.value = reserva.uuid
    try {
        const { error } = await supabase.rpc('bbtk_reserva_release', {
            p_interacao_uuid: reserva.uuid
        })

        if (error) throw error

        toast.showToast('Livro entregue com sucesso!', 'success')
        fetchReservas()
        fetchStats()
    } catch (error) {
        console.error('Erro ao entregar livro:', error)
        toast.showToast('Erro ao registrar entrega', 'error')
    } finally {
        isDelivering.value = false
        reservationToDeliver.value = null
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

const formatDate = (dateString) => {
    if (!dateString) return '-'
    return new Date(dateString).toLocaleDateString('pt-BR')
}

// Watchers
let debounceTimeout = null
watch(busca, (newVal) => {
    if (debounceTimeout) clearTimeout(debounceTimeout)
    debounceTimeout = setTimeout(() => {
        paginaAtual.value = 1
        fetchReservas()
    }, 300)
})

watch(paginaAtual, () => {
    fetchReservas()
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
                        <span class="text-xl">📕</span>
                    </div>
                    <div class="min-w-0">
                        <h1 class="text-lg font-bold text-text leading-none capitalize truncate">
                            Reservas
                        </h1>
                        <p class="text-xs text-secondary font-medium mt-0.5 whitespace-nowrap">
                            {{ totalItens }} registros
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
                    <input type="text" v-model="busca" placeholder="Buscar..." class="w-full pl-8 pr-3 py-1.5 text-xs bg-background border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary transition-all placeholder-secondary/70 shadow-sm" />
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
            
            <div v-if="isLoading && reservas.length === 0" class="text-center p-8 text-secondary text-sm">
                Carregando...
            </div>

            <div v-else-if="reservas.length === 0" class="text-center p-8 text-secondary bg-div-15 rounded-xl border border-secondary/20 border-dashed text-sm">
                Nenhuma reserva encontrada.
            </div>

            <div v-for="res in reservas" :key="res.uuid" class="bg-div-15 p-3 rounded-lg border border-secondary/10 hover:border-primary/30 transition-all flex flex-col md:flex-row md:items-center justify-between group shadow-sm gap-3">
                <div class="flex items-center gap-3 min-w-0">
                    <div class="w-10 h-14 rounded bg-background flex items-center justify-center text-secondary overflow-hidden border border-secondary/20 flex-shrink-0">
                        <img v-if="res.livro_capa" :src="res.livro_capa" alt="Capa" class="w-full h-full object-cover">
                        <span v-else class="text-lg">📖</span>
                    </div>
                    <div class="min-w-0 flex flex-col gap-0.5">
                        <div class="font-bold text-text text-sm leading-tight truncate" :title="res.livro_titulo">{{ res.livro_titulo }}</div>
                         <div class="flex flex-col gap-0.5">
                            <span class="text-xs text-secondary flex items-center gap-1">👤 <span class="truncate">{{ res.usuario_nome }}</span></span>
                            <span class="text-[10px] text-secondary/60">🆔 {{ res.usuario_matricula }}</span>
                        </div>
                    </div>
                </div>

                <div class="flex items-center gap-2 self-start md:self-center flex-wrap md:flex-nowrap">
                     <span class="bg-blue-500/10 text-blue-500 px-2 py-0.5 rounded text-[10px] font-medium whitespace-nowrap">
                        {{ formatDate(res.data_inicio) }}
                    </span>
                    <span v-if="res.status_calculado !== 'Entregue'" 
                            :class="res.status_calculado === 'Atrasado' ? 'bg-red-500/10 text-red-500' : 'bg-green-500/10 text-green-500'"
                            class="px-2 py-0.5 rounded text-[10px] font-medium whitespace-nowrap">
                        Até {{ formatDate(res.data_prevista_devolucao) }}
                    </span>
                    
                     <div class="ml-2">
                        <span v-if="res.status_calculado === 'Entregue'" class="text-xs font-bold text-gray-500 flex items-center gap-1 bg-div-30 px-2 py-1 rounded">
                            Entregue
                        </span>
                        <button v-else @click="handleDeliver(res)" :disabled="isDelivering && reservationToDeliver === res.uuid" class="bg-green-600 hover:bg-green-700 text-white text-xs font-bold px-3 py-1.5 rounded transition-colors flex items-center gap-1 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed">
                            <span v-if="isDelivering && reservationToDeliver === res.uuid" class="animate-spin">⌛</span>
                            <span v-else>✅</span>
                            Entregar
                        </button>
                    </div>
                </div>
            </div>

             <!-- Pagination -->
            <div class="flex items-center justify-center gap-4 mt-2 py-2" v-if="reservas.length > 0">
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
                    <span class="text-secondary text-xs uppercase font-medium tracking-wider">Ativas</span>
                    <span class="text-3xl font-bold text-text">{{ stats.total }}</span>
                </div>
                <div class="bg-gradient-to-br from-green-500/20 to-green-500/5 p-4 rounded-xl border border-green-500/20 flex flex-col items-center justify-center gap-1">
                    <span class="text-secondary text-xs uppercase font-medium tracking-wider">No Prazo</span>
                    <span class="text-3xl font-bold text-green-500">{{ stats.no_prazo }}</span>
                </div>
                <div class="bg-gradient-to-br from-red-500/20 to-red-500/5 p-4 rounded-xl border border-red-500/20 flex flex-col items-center justify-center gap-1">
                    <span class="text-secondary text-xs uppercase font-medium tracking-wider">Atrasadas</span>
                    <span class="text-3xl font-bold text-red-500">{{ stats.atrasadas }}</span>
                </div>
            </div>

            <div class="mt-auto p-4 bg-div-30/50 rounded-lg">
                <p class="text-[10px] text-secondary text-center">
                    Gerencie os empréstimos e devoluções. Use o botão de entrega para baixar reservas.
                </p>
            </div>
         </div>
    </div>

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
