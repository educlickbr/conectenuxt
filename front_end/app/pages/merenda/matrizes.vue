<script setup lang="ts">
import { useAppStore } from '@/stores/app'

definePageMeta({
    permission: 'botao:merenda_matrizes'
})

const appStore = useAppStore()
</script>

<template>
    <div class="flex flex-col h-full bg-background">
         <!-- Header -->
        <header class="flex items-center justify-between px-8 py-6 bg-white border-b border-div-15 shrink-0">
            <div>
                <h1 class="text-2xl font-bold text-text">Matrizes e Públicos</h1>
                <p class="text-sm text-secondary">Vínculo de Cardápios a Etapas Escolares</p>
            </div>
        </header>

        <!-- Content -->
        <main class="flex-1 p-8 overflow-y-auto">
            <div class="p-8 border border-dashed border-div-30 rounded-lg flex items-center justify-center h-64 bg-div-15/50">
                <p class="text-secondary font-medium">Em construção: Seleção de Grupo de Cardápio e Vínculo com Ano/Etapa.</p>
            </div>
        </main>
    </div>
</template>
