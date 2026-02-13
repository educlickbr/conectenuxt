<script setup>
const props = defineProps({
    items: {
        type: Array,
        default: () => []
    },
    isLoading: Boolean
})

const emit = defineEmits(['edit', 'delete'])

const handleEdit = (item) => {
    emit('edit', item)
}

const handleDelete = (item) => {
    emit('delete', item)
}
</script>

<template>
    <div class="bg-background rounded shadow-sm border border-secondary/10 overflow-hidden">
        <!-- Loading State -->
        <div v-if="isLoading" class="p-8 text-center text-secondary">
            <div class="inline-block w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin mb-2"></div>
            <p class="text-xs">Carregando nutrientes...</p>
        </div>

        <!-- Empty State -->
        <div v-else-if="items.length === 0" class="p-12 text-center text-secondary">
            <div class="w-12 h-12 bg-secondary/10 rounded-full flex items-center justify-center mx-auto mb-3">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
            </div>
            <p class="text-sm font-medium">Nenhum nutriente encontrado</p>
            <p class="text-xs opacity-70 mt-1">Cadastre novos nutrientes para começar.</p>
        </div>

        <!-- List -->
        <div v-else class="divide-y divide-secondary/10">
            <div 
                v-for="item in items" 
                :key="item.id"
                class="p-4 flex items-center justify-between hover:bg-div-15 transition-colors group"
            >
                <div class="flex items-center gap-4">
                    <div class="w-10 h-10 rounded bg-green-500/10 text-green-600 flex items-center justify-center font-bold text-xs shrink-0">
                        {{ item.unidade }}
                    </div>
                    <div>
                        <h3 class="text-sm font-bold text-text">{{ item.nome }}</h3>
                        <p class="text-[11px] text-secondary" v-if="!item.empresa_id">
                            <span class="inline-flex items-center gap-1 bg-blue-500/10 text-blue-600 px-1.5 py-0.5 rounded-[3px] font-bold uppercase tracking-wider text-[9px]">Global</span>
                        </p>
                    </div>
                </div>

                <div class="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                    <div v-if="!item.empresa_id" class="text-[10px] text-secondary/50 font-medium px-2 py-1 bg-secondary/5 rounded select-none cursor-help" title="Nutrientes globais não podem ser editados.">
                        Padrão do Sistema
                    </div>

                    <button 
                        v-if="item.empresa_id"
                        @click="handleEdit(item)"
                        class="p-1.5 text-secondary hover:text-primary hover:bg-primary/10 rounded transition-colors"
                        title="Editar"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg>
                    </button>
                    
                    <button 
                        v-if="item.empresa_id" 
                        @click="handleDelete(item)"
                        class="p-1.5 text-secondary hover:text-red-500 hover:bg-red-500/10 rounded transition-colors"
                        title="Excluir"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>
