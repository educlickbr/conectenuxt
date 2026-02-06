<script setup lang="ts">
import { computed, ref } from 'vue'

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

const isOpeningPdf = ref(false)

const openPdf = () => {
    if (!props.item?.pdfUrl) return
    window.open(props.item.pdfUrl, '_blank')
}

const openCover = () => {
    if (coverUrl.value) window.open(coverUrl.value, '_blank')
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="$emit('close')"></div>
        <div class="relative bg-background w-full max-w-4xl max-h-[90vh] flex flex-col rounded shadow-2xl border border-[#6B82A71A] overflow-hidden animate-in zoom-in-95 duration-200">
            
            <!-- Header -->
            <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between bg-div-15" @click.stop="">
                <h2 class="text-xl font-bold text-text">Detalhes da Obra</h2>
                <button @click="$emit('close')" class="p-2 rounded hover:bg-div-30"><span class="text-xl">×</span></button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-6 md:p-8 flex flex-col md:flex-row gap-8 bg-background">
                
                <!-- Cover Column -->
                <div class="w-full md:w-1/3 flex-shrink-0 flex flex-col gap-4">
                    <div class="aspect-[2/3] w-full border border-[#6B82A74D] bg-div-05 relative group shadow-sm">
                        <img v-if="coverUrl" :src="coverUrl" class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" alt="Capa">
                        <div v-else class="w-full h-full flex flex-col items-center justify-center text-secondary">
                            <span class="text-4xl mb-2">📕</span>
                            <span class="text-sm">Sem Capa</span>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="flex flex-col gap-2">
                        <button v-if="pdfUrl" @click="openPdf" :disabled="isOpeningPdf" class="w-full py-2 bg-primary hover:brightness-110 text-white rounded font-bold shadow-sm transition-all flex items-center justify-center gap-2 text-xs disabled:opacity-70 disabled:cursor-wait">
                            <svg v-if="!isOpeningPdf" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                            <span v-else class="animate-spin">◌</span>
                            {{ isOpeningPdf ? 'Gerando Link...' : 'Ler Livro (PDF)' }}
                        </button>
                        <button v-if="coverUrl" @click="openCover" class="w-full py-1.5 bg-div-05 hover:bg-div-15 text-text rounded font-medium border border-[#6B82A74D] transition-all flex items-center justify-center gap-2 text-xs">
                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                            Ver Capa Ampliada
                        </button>
                    </div>
                </div>

                <!-- Info Column -->
                <div class="flex-1 flex flex-col gap-4">
                    <div>
                        <h1 class="text-2xl md:text-3xl font-bold text-text leading-tight mb-2">{{ item?.titulo || item?.titulo_principal }}</h1>
                        <h2 v-if="item?.subtitulo" class="text-xl text-secondary font-medium">{{ item.subtitulo }}</h2>
                    </div>

                    <div class="flex flex-col gap-4 text-sm">
                        <!-- Row 1: Autor -->
                        <div class="flex flex-col gap-1 w-full">
                            <label class="text-xs font-bold text-secondary uppercase">Autor</label>
                            <span class="text-sm text-text border border-[#6B82A74D] px-3 py-1.5 bg-background block w-full">{{ item?.nome_autor || item?.autor_principal || 'Desconhecido' }}</span>
                        </div>
                        
                        <!-- Row 2: Editora (Flexible) + Ano (Fixed) + ISBN (Fixed) -->
                        <div class="flex gap-4 w-full">
                             <div class="flex-1 flex flex-col gap-1 min-w-0">
                                <label class="text-xs font-bold text-secondary uppercase">Editora</label>
                                <span class="text-sm text-text border border-[#6B82A74D] px-3 py-1.5 bg-background block w-full truncate" :title="item?.editora">{{ item?.editora || 'N/A' }}</span>
                             </div>
                             <div class="w-24 flex-shrink-0 flex flex-col gap-1">
                                <label class="text-xs font-bold text-secondary uppercase">Ano</label>
                                <span class="text-sm text-text border border-[#6B82A74D] px-3 py-1.5 bg-background block w-full text-center">{{ item?.ano_edicao || 'N/A' }}</span>
                             </div>
                             <div v-if="item?.isbn" class="w-32 flex-shrink-0 flex flex-col gap-1">
                                <label class="text-xs font-bold text-secondary uppercase">ISBN</label>
                                <span class="text-sm text-text font-mono border border-[#6B82A74D] px-3 py-1.5 bg-background block w-full text-center truncate" :title="item.isbn">{{ item.isbn }}</span>
                            </div>
                        </div>
                    </div>

                    <div class="flex-1 flex flex-col gap-2 min-h-[150px]">
                        <h3 class="text-xs font-bold text-secondary uppercase">Sinopse / Descrição</h3>
                        <div class="flex-1 text-text/80 leading-relaxed text-sm md:text-base whitespace-pre-line bg-background border border-[#6B82A74D] p-4 overflow-y-auto">
                            {{ item?.descricao || 'Nenhuma descrição disponível para esta obra.' }}
                        </div>
                    </div>

                    <div class="pt-4 border-t border-[#6B82A71A] grid grid-cols-2 gap-4">
                         <div class="flex flex-col gap-1">
                            <label class="text-xs font-bold text-secondary uppercase">Categoria</label>
                            <span class="text-sm font-medium text-text">{{ item?.categoria || '-' }}</span>
                         </div>
                         <div class="flex flex-col gap-1">
                            <label class="text-xs font-bold text-secondary uppercase">CDU</label>
                            <span class="text-sm font-medium text-text" v-if="item?.cdu">{{ item.cdu.codigo }} - {{ item.cdu.nome }}</span>
                            <span class="text-sm font-medium text-text" v-else>-</span>
                         </div>
                    </div>

                </div>
            </div>

            <div class="p-4 border-t border-[#6B82A71A] flex justify-end bg-div-15">
                <button @click="$emit('close')" class="px-6 py-2 bg-primary text-white rounded text-xs font-bold hover:brightness-110">Fechar</button>
            </div>

        </div>
    </div>
</template>
