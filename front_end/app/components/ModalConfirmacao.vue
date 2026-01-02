<script setup>
const props = defineProps({
    isOpen: Boolean,
    title: { type: String, default: 'Confirmar Ação' },
    message: { type: String, default: 'Você tem certeza que deseja realizar esta ação?' },
    confirmText: { type: String, default: 'Confirmar' },
    cancelText: { type: String, default: 'Cancelar' },
    isLoading: Boolean,
    danger: { type: Boolean, default: true }
})

defineEmits(['close', 'confirm'])
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[200] flex items-center justify-center p-4">
            <!-- Backdrop -->
            <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="$emit('close')"></div>
            
            <!-- Modal Content -->
            <div class="relative bg-background w-full max-w-md rounded shadow-2xl border border-secondary/10 overflow-hidden transform transition-all animate-in fade-in zoom-in duration-200">
                <div class="p-6 flex flex-col items-center text-center gap-4">
                    <!-- Icon -->
                    <div 
                        class="w-16 h-16 rounded-full flex items-center justify-center mb-2 shadow-inner"
                        :class="danger ? 'bg-red-500/10 text-red-500' : 'bg-primary/10 text-primary'"
                    >
                        <svg v-if="danger" xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                        <svg v-else xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                    </div>

                    <h3 class="text-xl font-bold text-text">{{ title }}</h3>
                    <p class="text-secondary text-sm leading-relaxed" v-html="message"></p>
                </div>

                <div class="flex items-center gap-3 p-4 bg-div-15 border-t border-secondary/10">
                    <button 
                        @click="$emit('close')" 
                        :disabled="isLoading"
                        class="flex-1 py-2.5 rounded text-secondary font-semibold text-sm hover:bg-div-30 transition-colors disabled:opacity-50"
                    >
                        {{ cancelText }}
                    </button>
                    <button 
                        @click="$emit('confirm')"
                        :disabled="isLoading"
                        class="flex-1 py-2.5 rounded text-white font-bold text-sm transition-all flex items-center justify-center gap-2 shadow-lg"
                        :class="danger ? 'bg-red-500 hover:bg-red-600 shadow-red-500/20' : 'bg-primary hover:brightness-110 shadow-primary/20'"
                    >
                        <svg v-if="isLoading" class="animate-spin w-4 h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                        {{ isLoading ? 'Processando...' : confirmText }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
