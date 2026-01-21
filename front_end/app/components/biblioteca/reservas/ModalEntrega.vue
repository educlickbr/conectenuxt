<script setup lang="ts">
import { ref, computed } from 'vue'
import { useAppStore } from '@/stores/app'

const props = defineProps<{
    reserva: any
    isLoading: boolean
}>()

const emit = defineEmits(['close', 'confirm'])

const appStore = useAppStore()

const currentUser = computed(() => appStore.profile?.nome_completo || appStore.user?.email || 'Usuário Atual')
const currentDate = new Date().toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' })

</script>

<template>
    <Teleport to="body">
        <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
            <!-- Backdrop -->
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm transition-opacity" @click="$emit('close')"></div>

            <!-- Modal Content -->
            <div class="relative w-full max-w-md bg-background rounded-xl border border-div-15 shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
                
                <!-- Header -->
                <div class="flex items-center justify-between px-5 py-4 border-b border-div-15 bg-surface">
                    <h3 class="font-bold text-text text-lg flex items-center gap-2">
                        <span class="text-success">✅</span>
                        Confirmar Entrega
                    </h3>
                    <button @click="$emit('close')" class="p-1 rounded-lg text-secondary hover:bg-div-05 hover:text-text transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="p-6 flex flex-col gap-6 overflow-y-auto">
                    
                    <div class="flex flex-col gap-2 text-center">
                        <div class="w-16 h-16 bg-success/10 rounded-full flex items-center justify-center mx-auto text-3xl mb-2 text-success border border-success/20">
                            📖
                        </div>
                        <h4 class="text-lg font-bold text-text">Devolução de Livro</h4>
                        <p class="text-secondary text-sm">Confirme o recebimento do item abaixo.</p>
                    </div>

                    <!-- Summary Card -->
                    <div class="bg-surface rounded-lg border border-div-15 p-4 flex flex-col gap-3 shadow-sm">
                        
                        <!-- Book -->
                        <div class="flex items-start gap-3">
                            <div class="w-10 h-14 bg-div-05 rounded overflow-hidden shrink-0 border border-div-15">
                                <img v-if="reserva.livro_capa" :src="reserva.livro_capa" class="w-full h-full object-cover">
                                <div v-else class="w-full h-full flex items-center justify-center text-secondary text-xs">📘</div>
                            </div>
                            <div class="flex flex-col">
                                <span class="text-[10px] uppercase font-bold text-secondary tracking-wider">Obra</span>
                                <span class="font-bold text-sm text-text leading-tight">{{ reserva.livro_titulo }}</span>
                                <span class="text-xs text-secondary mt-0.5 font-mono bg-div-05 px-1 rounded inline-block w-fit">Reg: {{ reserva.copia_registro || 'N/A' }}</span>
                            </div>
                        </div>

                        <div class="h-px bg-div-15/50 w-full my-1"></div>

                        <!-- User -->
                        <div class="grid grid-cols-2 gap-4">
                            <div class="flex flex-col">
                                <span class="text-[10px] uppercase font-bold text-secondary tracking-wider">Reservado por</span>
                                <span class="text-xs font-medium text-text mt-0.5">{{ reserva.usuario_nome }}</span>
                            </div>
                            <div class="flex flex-col">
                                <span class="text-[10px] uppercase font-bold text-secondary tracking-wider">Recebido por</span>
                                <span class="text-xs font-medium text-primary mt-0.5">{{ currentUser }}</span>
                            </div>
                        </div>

                         <!-- Date -->
                         <div class="flex flex-col bg-div-05/50 p-2 rounded border border-div-15/50">
                            <span class="text-[10px] uppercase font-bold text-secondary tracking-wider">Data do Recebimento</span>
                            <span class="text-sm font-bold text-text mt-0.5">{{ currentDate }}</span>
                        </div>
                    </div>

                    <div class="text-[11px] text-secondary text-center px-4">
                        Ao confirmar, o status da reserva será alterado para <strong class="text-success">Entregue</strong> e a cópia ficará <strong class="text-primary">Disponível</strong> no acervo.
                    </div>

                </div>

                <!-- Footer -->
                <div class="p-5 border-t border-div-15 bg-surface flex items-center justify-end gap-3 rounded-b-xl">
                    <button 
                        @click="$emit('close')" 
                        class="px-4 py-2 text-xs font-bold text-secondary hover:text-text transition-colors"
                        :disabled="isLoading"
                    >
                        Cancelar
                    </button>
                    <button 
                        @click="$emit('confirm')" 
                        class="px-6 py-2 bg-success hover:bg-success/90 text-white rounded-lg text-xs font-bold transition-all shadow-sm hover:shadow active:scale-95 flex items-center gap-2"
                        :disabled="isLoading"
                    >
                        <span v-if="isLoading" class="w-3 h-3 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
                        <span v-else>Confirmar Recebimento</span>
                    </button>
                </div>

            </div>
        </div>
    </Teleport>
</template>
