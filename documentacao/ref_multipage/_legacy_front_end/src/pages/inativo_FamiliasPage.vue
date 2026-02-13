<script setup>
import { ref, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'
import FullPageMenu from '../components/FullPageMenu.vue'
import ModalGerenciarFamilia from '../components/ModalGerenciarFamilia.vue'

const appStore = useAppStore()
const toast = useToastStore()

// Estado
const familias = ref([])
const isLoading = ref(false)
const busca = ref('')
const pagina = ref(1)
const totalPaginas = ref(1)
const itensPorPagina = 10
const totalRegistros = ref(0)
const isModalOpen = ref(false)
const selectedFamilia = ref(null)

// Carregar dados
const fetchFamilias = async () => {
    isLoading.value = true
    try {
        const { data, error } = await supabase.rpc('familia_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: pagina.value,
            p_limite_itens_pagina: itensPorPagina,
            p_busca: busca.value || null
        })

        if (error) throw error

        if (data && data.length > 0) {
            familias.value = data
            totalRegistros.value = data[0].total_registros
            totalPaginas.value = Math.ceil(totalRegistros.value / itensPorPagina)
        } else {
            familias.value = []
            totalRegistros.value = 0
            totalPaginas.value = 1
        }

    } catch (error) {
        console.error('Erro ao buscar famílias:', error)
        toast.showToast('Erro ao carregar lista de famílias.', 'error')
    } finally {
        isLoading.value = false
    }
}

// Paginação
const proxPagina = () => {
    if (pagina.value < totalPaginas.value) {
        pagina.value++
        fetchFamilias()
    }
}

const antPagina = () => {
    if (pagina.value > 1) {
        pagina.value--
        fetchFamilias()
    }
}

// Ações
const handleAdd = () => {
    selectedFamilia.value = null
    isModalOpen.value = true
}

const handleEdit = (familia) => {
    selectedFamilia.value = familia
    isModalOpen.value = true
}

const handleDelete = async (familia) => {
    if (!confirm(`Tem certeza que deseja excluir a família "${familia.nome_familia}"? Todos os vínculos serão removidos.`)) return

    try {
        const { error } = await supabase.rpc('familia_delete', {
            p_id: familia.id,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        toast.showToast('Família excluída com sucesso!', 'success')
        fetchFamilias()
    } catch (error) {
        console.error('Erro ao excluir família:', error)
        toast.showToast('Erro ao excluir família.', 'error')
    }
}

const handleModalSuccess = () => {
    fetchFamilias()
}

// Watchers
let searchTimeout
watch(busca, () => {
    clearTimeout(searchTimeout)
    searchTimeout = setTimeout(() => {
        pagina.value = 1
        fetchFamilias()
    }, 500)
})

// UI States
const isMenuOpen = ref(false)
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
    fetchFamilias()
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
</script>

<template>
    <div class="min-h-screen bg-background p-6 flex flex-col gap-6 font-inter">

        <!-- Header Block -->
        <div class="sticky top-0 z-30 bg-div-15 backdrop-blur-2xl p-4 rounded-xl border border-secondary shadow-sm flex flex-col gap-6">
            
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-4">
                     <div class="w-12 h-12 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-2xl">
                        👨‍👩‍👧‍👦
                     </div>
                     <div>
                         <h1 class="text-xl font-bold text-text">Gerenciar Famílias</h1>
                         <p class="text-sm text-secondary">
                            <span v-if="isLoading">Carregando...</span>
                            <span v-else>Total de {{ totalRegistros }} famílias cadastradas.</span>
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
                     <button @click="antPagina" :disabled="pagina === 1" class="p-1 text-secondary hover:text-primary disabled:opacity-50 disabled:cursor-not-allowed transition-colors"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="8" y1="12" x2="16" y2="12"></line></svg></button>
                     <div class="flex flex-col items-center">
                        <input type="number" v-model="pagina" class="w-12 text-center bg-transparent text-text font-bold focus:outline-none no-arrows" min="1" :max="totalPaginas">
                        <span class="text-[10px] text-secondary">{{ totalPaginas }} pág.</span>
                     </div>
                     <button @click="proxPagina" :disabled="pagina >= totalPaginas" class="p-1 text-secondary hover:text-primary disabled:opacity-50 disabled:cursor-not-allowed transition-colors"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg></button>
                </div>

                <!-- Search -->
                <div class="flex w-full md:flex-1 gap-4">
                    <div class="relative flex-1">
                         <input type="text" v-model="busca" placeholder="Buscar família..." class="w-full pl-10 pr-4 py-2 bg-div-15 border border-secondary rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary">
                         <span class="absolute left-3 top-2.5 text-secondary"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg></span>
                    </div>
                    <button @click="handleAdd" class="bg-blue-600 hover:bg-blue-700 text-white font-medium px-6 py-2 rounded-lg transition-colors flex items-center gap-2 shadow-sm">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                        <span>Nova Família</span>
                    </button>
                </div>
            </div>
        </div>

        <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />


                <!-- Table -->
                <div class="bg-background rounded-xl shadow-sm border border-div-30 overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-div-15 border-b border-div-30">
                                    <th class="py-4 px-6 font-semibold text-secondary text-sm uppercase tracking-wider">Família</th>
                                    <th class="py-4 px-6 font-semibold text-secondary text-sm uppercase tracking-wider">Responsável Principal</th>
                                    <th class="py-4 px-6 font-semibold text-secondary text-sm uppercase tracking-wider text-center">Alunos</th>
                                    <th class="py-4 px-6 font-semibold text-secondary text-sm uppercase tracking-wider text-right">Ações</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-div-30">
                                <tr v-if="isLoading" class="animate-pulse">
                                    <td colspan="4" class="py-8 text-center text-secondary">
                                        <div class="flex items-center justify-center gap-2">
                                            <div class="w-2 h-2 bg-secondary rounded-full animate-bounce"></div>
                                            <div class="w-2 h-2 bg-secondary rounded-full animate-bounce delay-100"></div>
                                            <div class="w-2 h-2 bg-secondary rounded-full animate-bounce delay-200"></div>
                                        </div>
                                    </td>
                                </tr>
                                <tr v-else-if="familias.length === 0">
                                    <td colspan="4" class="py-12 text-center text-secondary">
                                        Nenhuma família encontrada.
                                    </td>
                                </tr>
                                <tr v-else v-for="fam in familias" :key="fam.id" class="hover:bg-div-15/50 transition-colors group">
                                    <td class="py-4 px-6">
                                        <div class="flex items-center gap-3">
                                            <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 font-bold text-lg">
                                                {{ fam.nome_familia.charAt(0).toUpperCase() }}
                                            </div>
                                            <div>
                                                <p class="font-medium text-text">{{ fam.nome_familia }}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="py-4 px-6">
                                        <div v-if="fam.responsavel_principal" class="text-sm text-text font-medium">
                                            {{ fam.responsavel_principal }}
                                        </div>
                                        <div v-else class="text-sm text-secondary italic">--</div>
                                    </td>
                                    <td class="py-4 px-6 text-center">
                                        <span class="inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-blue-100 bg-blue-600 rounded-full">
                                            {{ fam.qtd_alunos }}
                                        </span>
                                    </td>
                                    <td class="py-4 px-6 text-right">
                                        <div class="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                            <button @click="handleEdit(fam)" class="p-2 text-secondary hover:text-primary hover:bg-div-30 rounded-lg transition-colors" title="Editar">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                            </button>
                                            <button @click="handleDelete(fam)" class="p-2 text-secondary hover:text-red-500 hover:bg-div-30 rounded-lg transition-colors" title="Apagar">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <ModalGerenciarFamilia
                :is-open="isModalOpen"
                :initial-data="selectedFamilia"
                @close="isModalOpen = false"
                @success="handleModalSuccess"
            />
</template>
