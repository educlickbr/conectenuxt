<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'

const props = defineProps<{
    isOpen: boolean
    item: any
}>()

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

const loading = ref(false)
const saving = ref(false)
const copies = ref<any[]>([])

// Logic for Grouping
const groupedCopies = computed(() => {
    const groups: Record<string, any[]> = {}
    copies.value.forEach(copy => {
        const key = `${copy.nome_escola} - ${copy.nome_sala} (Estante: ${copy.nome_estante})`
        if (!groups[key]) {
            groups[key] = []
        }
        groups[key].push(copy)
    })
    return groups
})

const selectedLocationKey = ref<string>('')

// Dates
// Helper to strip time and get YYYY-MM-DD for input[date]
// Helper to strip time and get YYYY-MM-DD for input[date]
const formatDateIso = (d: any) => {
    if (!d) return ''
    try {
        const dateObj = typeof d === 'string' ? new Date(d) : d
        return dateObj.toISOString().split('T')[0] || ''
    } catch {
        return ''
    }
}

// Display format (DD/MM/YYYY)
const formatDateBr = (isoDate: string) => {
     if (!isoDate) return ''
     const parts = isoDate.split('-')
     if (parts.length === 3) return `${parts[2]}/${parts[1]}/${parts[0]}`
     return isoDate
}

const reservaDate = ref<string>(formatDateIso(new Date()))
const deliveryDate = ref<string>('')

const updateDelivery = () => {
    if (!reservaDate.value) {
        deliveryDate.value = ''
        return
    }
    try {
        const d = new Date(reservaDate.value)
        // Add 7 days
        d.setDate(d.getDate() + 7)
        deliveryDate.value = formatDateIso(d)
    } catch (e) {
        deliveryDate.value = ''
    }
}

const formattedDelivery = computed(() => {
    return formatDateBr(deliveryDate.value)
})

watch(reservaDate, updateDelivery, { immediate: true })

const fetchCopies = async () => {
    loading.value = true
    selectedLocationKey.value = ''
    try {
        const data: any = await $fetch('/api/biblioteca/acervo/copias', {
            params: {
                 id_empresa: appStore.company?.empresa_id,
                 edicao_uuid: props.item?.id || props.item?.id_edicao
            }
        })
        
        copies.value = data || []
        
        // Select first group if available
        const keys: string[] = Object.keys(groupedCopies.value)
        if (keys.length > 0) {
            selectedLocationKey.value = keys[0] as string
        }

    } catch (e) {
        console.error(e)
    } finally {
        loading.value = false
    }
}

watch(() => props.isOpen, (newVal) => {
    if (newVal && props.item) {
        // Reset date
        reservaDate.value = formatDateIso(new Date())
        fetchCopies()
    }
})

const handleReserve = async () => {
    if (!selectedLocationKey.value) return
    const group = groupedCopies.value[selectedLocationKey.value]
    if (!group || group.length === 0) return
    const selectedCopyId = group[0].id_copia

    saving.value = true
    try {
        await $fetch('/api/biblioteca/reservas/create', {
            method: 'POST',
            body: {
                copia_uuid: selectedCopyId,
                id_empresa: appStore.company?.empresa_id,
                data_inicio: reservaDate.value // Sending YYYY-MM-DD (Input Date) - Backend/RPC should handle casting or append time if needed.
            }
        })
        
        toast.showToast('Reserva realizada com sucesso!', 'success')
        emit('success')
        emit('close')
    } catch (e: any) {
        toast.showToast(e.message || 'Erro ao reservar.', 'error')
    } finally {
        saving.value = false
    }
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200" @click.self="$emit('close')">
        <div class="bg-surface w-full md:w-[90%] md:h-[90%] max-w-5xl rounded-xl shadow-2xl border border-div-15 flex flex-col overflow-hidden animate-in zoom-in-95 duration-200">
            
            <!-- Header -->
            <div class="bg-div-05 p-4 border-b border-div-15 flex items-center justify-between shrink-0">
                <h2 class="text-xl font-bold text-text flex items-center gap-2">
                    <span class="text-2xl">📅</span> Reservar Livro
                </h2>
                <button @click="$emit('close')" class="p-2 hover:bg-div-15 rounded-lg text-secondary transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-8 space-y-8">
                <!-- Book Info -->
                <div class="flex flex-col sm:flex-row gap-6 items-start bg-div-05/50 p-6 rounded-xl border border-div-15">
                    <div class="w-24 h-36 bg-div-15 rounded-lg border border-div-15 flex-shrink-0 flex items-center justify-center overflow-hidden shadow-sm self-center sm:self-start">
                        <img v-if="item?.capaUrl" :src="item.capaUrl" class="w-full h-full object-cover">
                        <span v-else class="text-4xl text-secondary/50">📘</span>
                    </div>
                    <div>
                        <h3 class="font-bold text-text text-xl leading-tight mb-1">{{ item?.titulo || item?.titulo_principal }}</h3>
                        <p class="text-base text-secondary font-medium">{{ item?.nome_autor || item?.autor_principal }}</p>
                        <div class="flex items-center gap-3 mt-3">
                            <span class="text-xs bg-div-15 px-2 py-1 rounded text-secondary border border-div-15">{{ item?.editora }}</span>
                            <span class="text-xs bg-div-15 px-2 py-1 rounded text-secondary border border-div-15">{{ item?.ano_edicao }}</span>
                        </div>
                    </div>
                </div>

                <div v-if="loading" class="py-12 flex flex-col items-center justify-center text-secondary gap-3">
                    <div class="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
                    <span class="font-medium">Verificando disponibilidade...</span>
                </div>

                <div v-else-if="copies.length === 0" class="bg-danger/5 p-6 rounded-xl border border-danger/20 text-center">
                    <p class="text-danger font-bold text-lg mb-2">Indisponível</p>
                    <p class="text-danger/80">Não há cópias físicas disponíveis para reserva neste momento.</p>
                </div>

                <div v-else class="space-y-6 max-w-3xl mx-auto">
                    <div class="bg-success/5 p-4 rounded-xl border border-success/20 flex items-start gap-4">
                        <div class="bg-success/10 text-success p-2 rounded-full mt-0.5">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                        </div>
                        <div>
                            <p class="text-success font-bold text-base">Disponível para Reserva</p>
                            <p class="text-sm text-success/80 mt-1">Selecione a data de retirada e o local.</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                         <div class="bg-div-05 p-4 rounded-xl border border-div-15">
                            <label class="block text-xs text-secondary uppercase tracking-wider font-bold mb-2">Data de Retirada (Reserva)</label>
                            <input 
                                type="date" 
                                v-model="reservaDate" 
                                :min="formatDateIso(new Date())"
                                class="w-full bg-input-bg border border-div-15 rounded-lg px-3 py-2 text-text font-medium focus:ring-1 focus:ring-primary focus:border-primary outline-none"
                            >
                         </div>
                         <div class="bg-div-05 p-4 rounded-xl border border-div-15 opacity-80">
                            <label class="block text-xs text-secondary uppercase tracking-wider font-bold mb-2">Devolução Prevista</label>
                            <div class="w-full bg-input-bg/50 border border-div-15 rounded-lg px-3 py-2 text-text font-medium">
                                {{ formattedDelivery }}
                            </div>
                         </div>
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-secondary mb-2 uppercase tracking-wider">Localização / Disponibilidade</label>
                        <select v-model="selectedLocationKey" class="w-full p-4 rounded-xl border border-div-15 bg-input-bg text-text focus:outline-none focus:border-primary transition-colors text-base shadow-sm">
                            <option v-for="(group, key) in groupedCopies" :key="key" :value="key">
                                {{ key }} ({{ group.length }} disponíveis)
                            </option>
                        </select>
                    </div>

                    <p class="text-xs text-secondary text-center pt-4 border-t border-div-15">
                        Ao confirmar, uma das cópias deste local será reservada em seu nome a partir da data de retirada selecionada.
                    </p>
                </div>
            </div>

            <!-- Footer -->
            <div class="p-4 bg-div-05 border-t border-div-15 flex justify-end gap-3 shrink-0">
                <button @click="$emit('close')" class="px-6 py-2.5 rounded-xl text-secondary hover:bg-div-15 font-medium transition-colors">Cancelar</button>
                <button 
                    @click="handleReserve" 
                    :disabled="loading || copies.length === 0 || !selectedLocationKey || saving"
                    class="px-8 py-2.5 rounded-xl bg-primary text-white font-bold hover:bg-primary-hover transition-colors shadow-lg shadow-primary/20 flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                    <span v-if="saving" class="animate-spin text-sm">⌛</span>
                    Confirmar Reserva
                </button>
            </div>

        </div>
    </div>
</template>
