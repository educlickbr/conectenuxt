<script setup>
import { computed } from 'vue'

const props = defineProps({
    isOpen: Boolean,
    item: Object, // Edition object from bbtk_edicao_get_paginado
    imageBaseUrl: String
})

const emit = defineEmits(['close'])

const coverUrl = computed(() => {
    if (props.item && props.item.capa && props.imageBaseUrl) {
        return `${props.imageBaseUrl}${props.item.capa}`
    }
    return null
})

const pdfUrl = computed(() => {
    if (props.item && props.item.pdf && props.imageBaseUrl) {
        return `${props.imageBaseUrl}${props.item.pdf}`
    }
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
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-fade-in" @click.self="$emit('close')">
        <div class="bg-background w-full max-w-4xl max-h-[90vh] rounded-xl shadow-2xl border border-secondary/20 flex flex-col overflow-hidden animate-slide-up">
            
            <!-- Header -->
            <div class="bg-div-15 p-4 border-b border-secondary/20 flex items-center justify-between shrink-0">
                <h2 class="text-xl font-bold text-text">Detalhes da Obra</h2>
                <button @click="$emit('close')" class="p-2 hover:bg-div-30 rounded-lg text-secondary transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-6 md:p-8 flex flex-col md:flex-row gap-8">
                
                <!-- Cover Column -->
                <div class="w-full md:w-1/3 flex-shrink-0 flex flex-col gap-4">
                    <div class="aspect-[2/3] w-full rounded-xl overflow-hidden shadow-lg border border-secondary/20 bg-div-30 relative group">
                        <img v-if="coverUrl" :src="coverUrl" class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" alt="Capa">
                        <div v-else class="w-full h-full flex flex-col items-center justify-center text-secondary">
                            <span class="text-4xl mb-2">📕</span>
                            <span class="text-sm">Sem Capa</span>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="flex flex-col gap-2">
                        <button v-if="pdfUrl" @click="openPdf" class="w-full py-3 bg-primary hover:bg-primary-dark text-white rounded-lg font-bold shadow-lg shadow-primary/20 transition-all flex items-center justify-center gap-2">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                            Ler Livro (PDF)
                        </button>
                        <button v-if="coverUrl" @click="openCover" class="w-full py-2 bg-div-30 hover:bg-div-30/80 text-text rounded-lg font-medium border border-secondary/20 transition-all flex items-center justify-center gap-2">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                            Ver Capa Ampliada
                        </button>
                    </div>
                </div>

                <!-- Info Column -->
                <div class="flex-1 space-y-6">
                    <div>
                        <h1 class="text-2xl md:text-3xl font-bold text-text leading-tight mb-2">{{ item?.titulo_principal }}</h1>
                        <h2 v-if="item?.subtitulo" class="text-xl text-secondary font-medium">{{ item.subtitulo }}</h2>
                    </div>

                    <div class="flex flex-wrap gap-4 text-sm">
                        <div class="bg-div-15 px-3 py-1.5 rounded-lg border border-secondary/20 flex items-center gap-2">
                            <span class="text-secondary">Autor:</span>
                            <span class="font-bold text-text">{{ item?.autor_principal || 'Desconhecido' }}</span>
                        </div>
                        <div class="bg-div-15 px-3 py-1.5 rounded-lg border border-secondary/20 flex items-center gap-2">
                            <span class="text-secondary">Editora:</span>
                            <span class="font-bold text-text">{{ item?.editora || 'N/A' }}</span>
                        </div>
                        <div class="bg-div-15 px-3 py-1.5 rounded-lg border border-secondary/20 flex items-center gap-2">
                            <span class="text-secondary">Ano:</span>
                            <span class="font-bold text-text">{{ item?.ano_edicao || 'N/A' }}</span>
                        </div>
                         <div v-if="item?.isbn" class="bg-div-15 px-3 py-1.5 rounded-lg border border-secondary/20 flex items-center gap-2">
                            <span class="text-secondary">ISBN:</span>
                            <span class="font-mono text-text">{{ item.isbn }}</span>
                        </div>
                    </div>

                    <div class="space-y-2">
                        <h3 class="text-sm font-bold text-secondary uppercase tracking-wider">Sinopse / Descrição</h3>
                        <p class="text-text/80 leading-relaxed text-sm md:text-base whitespace-pre-line bg-div-15/30 p-4 rounded-xl border border-secondary/10">
                            {{ item?.descricao || 'Nenhuma descrição disponível para esta obra.' }}
                        </p>
                    </div>

                    <div class="pt-4 border-t border-secondary/10 grid grid-cols-2 gap-4">
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

<style scoped>
.animate-fade-in { animation: fadeIn 0.2s ease-out; }
.animate-slide-up { animation: slideUp 0.3s ease-out; }
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
@keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
</style>
