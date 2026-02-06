<script setup lang="ts">
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerListItem from '@/components/ManagerListItem.vue'
import ModalConfirmacao from '@/components/ModalConfirmacao.vue'

definePageMeta({
    permission: 'botao:merenda_receituario',
    layout: false
})

const appStore = useAppStore()
const toast = useToastStore()

// --- Data Fetching ---
const search = ref('')
const page = ref(1)
const limit = ref(10)

const { data: fichasData, pending, refresh } = await useFetch('/api/merenda/fichastecnicas', {
    query: computed(() => ({
        id_empresa: appStore.company?.empresa_id
    })),
    watch: [() => appStore.company?.empresa_id]
})

const allFichas = computed(() => fichasData.value || [])

// Filter by search
const fichas = computed(() => {
    if (!search.value) return allFichas.value
    return allFichas.value.filter(f => 
        f.prato_nome.toLowerCase().includes(search.value.toLowerCase())
    )
})

const isLoading = computed(() => pending.value)

// --- Modal State ---
import ModalFichaTecnica from '@/components/merenda/receituario/ModalFichaTecnica.vue'

const isModalOpen = ref(false)
const selectedFicha = ref(null)

const handleNew = () => {
    toast.showToast('Selecione um prato existente para editar sua ficha técnica', 'info')
}

const handleEdit = (ficha) => {
    selectedFicha.value = ficha
    isModalOpen.value = true
}

const handleSuccess = () => {
    refresh()
}

// --- Delete Logic ---
const isConfirmOpen = ref(false)
const isDeleting = ref(false)
const fichaToDelete = ref(null)

const handleDelete = (ficha) => {
    fichaToDelete.value = ficha
    isConfirmOpen.value = true
}

const confirmDelete = async () => {
    // For now, just show a message - deletion is handled via batch upsert
    toast.showToast('Para remover ingredientes, edite a ficha técnica', 'info')
    isConfirmOpen.value = false
}

// Stats
const dashboardStats = computed(() => [
    { label: 'Total de Pratos', value: fichas.value.length },
    { label: 'Com Receita', value: fichas.value.filter(f => f.ingredientes_count > 0).length }
])
</script>

<template>
    <NuxtLayout name="manager">
        <!-- Header Icon -->
        <template #header-icon>
            <div class="w-10 h-10 rounded bg-primary/10 text-primary flex items-center justify-center shrink-0">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 3h5v5"/><path d="M8 3H3v5"/><path d="M12 22v-8.3a4 4 0 0 0-1.172-2.872L3 3"/><path d="m15 9 6-6"/><path d="M3 21h18"/></svg>
            </div>
        </template>

        <!-- Header Title -->
        <template #header-title>
            Receituário
        </template>

        <!-- Header Subtitle -->
        <template #header-subtitle>
            Fichas Técnicas e Composição de Pratos
        </template>

        <!-- Header Actions -->
        <template #header-actions>
            <div class="relative w-full sm:max-w-[180px]">
                <input 
                    type="text" 
                    v-model="search" 
                    placeholder="Buscar..." 
                    class="w-full pl-8 pr-3 py-1.5 text-xs bg-background border border-secondary/30 rounded text-text focus:outline-none focus:border-primary transition-all placeholder:text-secondary/70 shadow-sm"
                >
                <div class="absolute left-2.5 top-1/2 -translate-y-1/2 text-secondary/70">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                </div>
            </div>
        </template>

        <!-- Sidebar -->
        <template #sidebar>
            <div class="bg-div-15 p-6 rounded border border-div-30">
                <h3 class="text-[10px] font-black text-secondary uppercase tracking-[0.2em] mb-4">Estatísticas</h3>
                <div class="flex flex-col gap-3">
                    <div v-for="stat in dashboardStats" :key="stat.label" class="flex items-center justify-between">
                        <span class="text-xs text-secondary">{{ stat.label }}</span>
                        <span class="text-lg font-black text-primary">{{ stat.value }}</span>
                    </div>
                </div>
            </div>

            <div class="bg-orange-500/5 p-4 rounded border border-orange-500/10 mt-4">
                <h4 class="text-[10px] font-black text-orange-500 uppercase tracking-[0.2em] mb-2">Receituário</h4>
                <p class="text-[11px] text-orange-500/70 leading-relaxed font-medium">
                    Gerencie os ingredientes e quantidades de cada prato. Clique em um prato para editar sua ficha técnica.
                </p>
            </div>
        </template>

        <!-- Content -->
        <div class="w-full p-6">
            <!-- Loading State -->
            <div v-if="isLoading && fichas.length === 0" class="flex flex-col items-center justify-center py-20 gap-4 opacity-50">
                <div class="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin" />
                <p class="text-xs font-bold uppercase tracking-widest text-secondary">Carregando Fichas...</p>
            </div>

            <!-- Empty State -->
            <div v-else-if="!isLoading && fichas.length === 0" class="flex flex-col items-center justify-center py-20 text-center text-secondary bg-div-15 rounded border border-div-30/50">
                <div class="w-16 h-16 bg-div-15 rounded-full flex items-center justify-center mb-4 text-secondary text-2xl">
                    📋
                </div>
                <p>Nenhum prato encontrado. Cadastre pratos na Base de Dados primeiro.</p>
            </div>

            <!-- Data List -->
            <div v-else class="flex flex-col gap-2">
                <ManagerListItem
                    v-for="(ficha, index) in fichas"
                    :key="ficha.prato_id || index"
                    :item="ficha"
                    :title="ficha.prato_nome"
                    @edit="handleEdit(ficha)"
                    @delete="handleDelete(ficha)"
                >
                    <template #icon>
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-primary"><path d="M16 3h5v5"/><path d="M8 3H3v5"/><path d="M12 22v-8.3a4 4 0 0 0-1.172-2.872L3 3"/><path d="m15 9 6-6"/><path d="M3 21h18"/></svg>
                    </template>
                    <template #metadata>
                        <span class="text-[10px] bg-div-15 px-2 py-0.5 rounded text-secondary font-black uppercase tracking-wider">
                            {{ ficha.ingredientes_count || 0 }} Ingredientes
                        </span>
                        <span v-if="ficha.total_gramagem" class="text-[10px] text-secondary font-medium">
                            Total: {{ ficha.total_gramagem }}g
                        </span>
                    </template>
                </ManagerListItem>
            </div>
        </div>

        <!-- Modals -->
        <template #modals>
            <ModalFichaTecnica
                :is-open="isModalOpen"
                :initial-data="selectedFicha"
                @close="isModalOpen = false"
                @success="handleSuccess"
            />

            <ModalConfirmacao
                :is-open="isConfirmOpen"
                title="Excluir Ficha?"
                :message="`Deseja realmente excluir a ficha técnica de <b>${fichaToDelete?.prato_nome || 'este prato'}</b>?`"
                confirm-text="Sim, excluir"
                :is-loading="isDeleting"
                @close="isConfirmOpen = false"
                @confirm="confirmDelete"
            />
        </template>
    </NuxtLayout>
</template>
