<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
    isOpen: boolean
    item: any
    imageBaseUrl?: string
}>()

const emit = defineEmits(['close'])

// In legacy, imageBaseUrl was passed. For now we assume we might not have it or use relative if fixed.
// But let's keep the logic.
const coverUrl = computed(() => {
    // If item already has full url (mapped in parent), use it.
    if (props.item?.capaUrl) return props.item.capaUrl
    return null
})

const pdfUrl = computed(() => {
     if (props.item?.pdfUrl) return props.item.pdfUrl
     return null
})

const openPdf = () => {
    if (pdfUrl.value) window.open(pdfUrl.value, '_blank')
}

const openCover = () => {
    if (coverUrl.value) window.open(coverUrl.value, '_blank')
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200" @click.self="$emit('close')">
        <div class="bg-surface w-full max-w-4xl max-h-[90vh] rounded-xl shadow-2xl border border-div-15 flex flex-col overflow-hidden animate-in zoom-in-95 duration-200">
            
            <!-- Header -->
            <div class="bg-div-05 p-4 border-b border-div-15 flex items-center justify-between shrink-0">
                <h2 class="text-xl font-bold text-text">Detalhes da Obra</h2>
                <button @click="$emit('close')" class="p-2 hover:bg-div-15 rounded-lg text-secondary transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-6 md:p-8 flex flex-col md:flex-row gap-8">
                
                <!-- Cover Column -->
                <div class="w-full md:w-1/3 flex-shrink-0 flex flex-col gap-4">
                    <div class="aspect-[2/3] w-full rounded-xl overflow-hidden shadow-lg border border-div-15 bg-div-05 relative group">
                        <img v-if="coverUrl" :src="coverUrl" class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" alt="Capa">
                        <div v-else class="w-full h-full flex flex-col items-center justify-center text-secondary">
                            <span class="text-4xl mb-2">📕</span>
                            <span class="text-sm">Sem Capa</span>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="flex flex-col gap-2">
                        <button v-if="pdfUrl" @click="openPdf" class="w-full py-3 bg-primary hover:bg-primary-hover text-white rounded-lg font-bold shadow-lg shadow-primary/20 transition-all flex items-center justify-center gap-2">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                            Ler Livro (PDF)
                        </button>
                        <button v-if="coverUrl" @click="openCover" class="w-full py-2 bg-div-05 hover:bg-div-15 text-text rounded-lg font-medium border border-div-15 transition-all flex items-center justify-center gap-2">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                            Ver Capa Ampliada
                        </button>
                    </div>
                </div>

                <!-- Info Column -->
                <div class="flex-1 space-y-6">
                    <div>
                        <h1 class="text-2xl md:text-3xl font-bold text-text leading-tight mb-2">{{ item?.titulo || item?.titulo_principal }}</h1>
                        <h2 v-if="item?.subtitulo" class="text-xl text-secondary font-medium">{{ item.subtitulo }}</h2>
                    </div>

                    <div class="flex flex-wrap gap-4 text-sm">
                        <div class="bg-div-05 px-3 py-1.5 rounded-lg border border-div-15 flex items-center gap-2">
                            <span class="text-secondary">Autor:</span>
                            <span class="font-bold text-text">{{ item?.nome_autor || item?.autor_principal || 'Desconhecido' }}</span>
                        </div>
                        <div class="bg-div-05 px-3 py-1.5 rounded-lg border border-div-15 flex items-center gap-2">
                            <span class="text-secondary">Editora:</span>
                            <span class="font-bold text-text">{{ item?.editora || 'N/A' }}</span>
                        </div>
                        <div class="bg-div-05 px-3 py-1.5 rounded-lg border border-div-15 flex items-center gap-2">
                            <span class="text-secondary">Ano:</span>
                            <span class="font-bold text-text">{{ item?.ano_edicao || 'N/A' }}</span>
                        </div>
                         <div v-if="item?.isbn" class="bg-div-05 px-3 py-1.5 rounded-lg border border-div-15 flex items-center gap-2">
                            <span class="text-secondary">ISBN:</span>
                            <span class="font-mono text-text">{{ item.isbn }}</span>
                        </div>
                    </div>

                    <div class="space-y-2">
                        <h3 class="text-sm font-bold text-secondary uppercase tracking-wider">Sinopse / Descrição</h3>
                        <p class="text-text/80 leading-relaxed text-sm md:text-base whitespace-pre-line bg-div-05/50 p-4 rounded-xl border border-div-15">
                            {{ item?.descricao || 'Nenhuma descrição disponível para esta obra.' }}
                        </p>
                    </div>

                    <div class="pt-4 border-t border-div-15 grid grid-cols-2 gap-4">
                         <div>
                            <span class="text-xs text-secondary block mb-1">Categoria</span>
                            <span class="text-sm font-medium text-text">{{ item?.categoria || '-' }}</span>
                         </div>
                         <div>
                            <span class="text-xs text-secondary block mb-1">CDU</span>
                            <span class="text-sm font-medium text-text" v-if="item?.cdu">{{ item.cdu.codigo }} - {{ item.cdu.nome }}</span>
                            <span class="text-sm font-medium text-text" v-else>-</span>
                         </div>
                    </div>

                </div>
            </div>

        </div>
    </div>
</template>
