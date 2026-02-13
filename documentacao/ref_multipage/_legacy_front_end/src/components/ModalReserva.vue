<script setup>
import { ref, watch, computed } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const props = defineProps({
    isOpen: Boolean,
    item: Object
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

const loading = ref(false)
const saving = ref(false)
const copies = ref([])
// const selectedCopyId = ref('') // No longer direct selection

// Logic for Grouping
const groupedCopies = computed(() => {
    const groups = {}
    copies.value.forEach(copy => {
        const key = `${copy.nome_escola} - ${copy.nome_sala} (Estante: ${copy.nome_estante})`
        if (!groups[key]) {
            groups[key] = []
        }
        groups[key].push(copy)
    })
    return groups
})

const selectedLocationKey = ref('')

// Dates
const today = new Date()
const formatDateIso = (d) => {
    return d.toISOString().split('T')[0]
}
const formatDateBr = (d) => {
     // Check if string "YYYY-MM-DD" or Date object
     if (typeof d === 'string') {
         const parts = d.split('-')
         return `${parts[2]}/${parts[1]}/${parts[0]}`
     }
    return d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

const reservaDate = ref(formatDateIso(today))
const deliveryDate = ref('')

const updateDelivery = () => {
    if (!reservaDate.value) return
    const d = new Date(reservaDate.value)
    d.setDate(d.getDate() + 7)
    // deliveryDate.value = formatDateBr(d) // formatted string for display
    deliveryDate.value = formatDateIso(d) // iso for calculation if needed, but display handles format
}

const formattedDelivery = computed(() => {
    if (!deliveryDate.value) return ''
    return formatDateBr(deliveryDate.value)
})

watch(reservaDate, updateDelivery, { immediate: true })


const fetchCopies = async () => {
    loading.value = true
    selectedLocationKey.value = ''
    try {
        const { data, error } = await supabase.rpc('bbtk_copias_disponiveis_get', {
            p_id_empresa: appStore.id_empresa,
            p_edicao_uuid: props.item?.id_edicao
        })
        if (error) throw error
        copies.value = data || []
        
        // Select first group if available
        const keys = Object.keys(groupedCopies.value)
        if (keys.length > 0) {
            selectedLocationKey.value = keys[0]
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
        // Assume appStore.user is populated.
        if (!appStore.user?.id) {
            toast.showToast('Erro: Usuário não identificado.', 'error')
            return
        }

        const { error } = await supabase.rpc('bbtk_reserva_create', {
            p_copia_uuid: selectedCopyId,
            p_user_uuid: appStore.user.id,
            p_id_empresa: appStore.id_empresa,
            p_data_inicio: reservaDate.value
        })
        if (error) throw error
        
        toast.showToast('Reserva realizada com sucesso!', 'success')
        emit('success')
        emit('close')
    } catch (e) {
        console.error(e)
        toast.showToast('Erro ao reservar: ' + (e.message || 'Desconhecido'), 'error')
    } finally {
        saving.value = false
    }
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-fade-in" @click.self="$emit('close')">
        <!-- Resized to match Professor Modal -->
        <div class="bg-background w-full md:w-[90%] md:h-[90%] rounded-xl shadow-2xl border border-secondary/20 flex flex-col overflow-hidden animate-slide-up">
            
            <!-- Header -->
            <div class="bg-div-15 p-4 border-b border-secondary/20 flex items-center justify-between shrink-0">
                <h2 class="text-xl font-bold text-text flex items-center gap-2">
                    <span class="text-2xl">📅</span> Reservar Livro
                </h2>
                <button @click="$emit('close')" class="p-2 hover:bg-div-30 rounded-lg text-secondary transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-8 space-y-8">
                <!-- Book Info -->
                <div class="flex gap-6 items-start bg-div-15/50 p-6 rounded-xl border border-secondary/10">
                    <div class="w-24 h-36 bg-div-30 rounded-lg border border-secondary/10 flex-shrink-0 flex items-center justify-center overflow-hidden shadow-sm">
                        <img v-if="item?.capaUrl" :src="item.capaUrl" class="w-full h-full object-cover">
                        <span v-else class="text-4xl text-secondary/50">📘</span>
                    </div>
                    <div>
                        <h3 class="font-bold text-text text-xl leading-tight mb-1">{{ item?.titulo_principal }}</h3>
                        <p class="text-base text-secondary font-medium">{{ item?.autor_principal }}</p>
                        <div class="flex items-center gap-3 mt-3">
                            <span class="text-xs bg-div-30 px-2 py-1 rounded text-secondary border border-secondary/10">{{ item?.editora }}</span>
                            <span class="text-xs bg-div-30 px-2 py-1 rounded text-secondary border border-secondary/10">{{ item?.ano_edicao }}</span>
                        </div>
                    </div>
                </div>

                <div v-if="loading" class="py-12 flex flex-col items-center justify-center text-secondary gap-3">
                    <div class="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
                    <span class="font-medium">Verificando disponibilidade...</span>
                </div>

                <div v-else-if="copies.length === 0" class="bg-red-50 p-6 rounded-xl border border-red-100 text-center">
                    <p class="text-red-800 font-bold text-lg mb-2">Indisponível</p>
                    <p class="text-red-600">Não há cópias físicas disponíveis para reserva neste momento.</p>
                </div>

                <div v-else class="space-y-6 max-w-3xl mx-auto">
                    <div class="bg-green-50 p-4 rounded-xl border border-green-100 flex items-start gap-4">
                        <div class="bg-green-100 text-green-700 p-2 rounded-full mt-0.5">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><check-circle cx="12" cy="12" r="10"></check-circle><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                        </div>
                        <div>
                            <p class="text-green-800 font-bold text-base">Disponível para Reserva</p>
                            <p class="text-sm text-green-700 mt-1">Selecione a data de retirada e o local.</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                         <div class="bg-div-15 p-4 rounded-xl border border-secondary/10">
                            <label class="block text-xs text-secondary uppercase tracking-wider font-bold mb-2">Data de Retirada (Reserva)</label>
                            <input 
                                type="date" 
                                v-model="reservaDate" 
                                :min="formatDateIso(new Date())"
                                class="w-full bg-background border border-secondary/30 rounded-lg px-3 py-2 text-text font-medium focus:ring-1 focus:ring-primary focus:border-primary outline-none"
                            >
                         </div>
                         <div class="bg-div-15 p-4 rounded-xl border border-secondary/10 opacity-80">
                            <label class="block text-xs text-secondary uppercase tracking-wider font-bold mb-2">Devolução Prevista</label>
                            <div class="w-full bg-div-30/50 border border-secondary/10 rounded-lg px-3 py-2 text-text font-medium">
                                {{ formattedDelivery }}
                            </div>
                         </div>
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-secondary mb-2 uppercase tracking-wider">Localização / Disponibilidade</label>
                        <select v-model="selectedLocationKey" class="w-full p-4 rounded-xl border border-secondary/30 bg-div-15 text-text focus:outline-none focus:border-primary transition-colors text-base shadow-sm">
                            <option v-for="(group, key) in groupedCopies" :key="key" :value="key">
                                {{ key }} ({{ group.length }} disponíveis)
                            </option>
                        </select>
                    </div>

                    <p class="text-xs text-secondary text-center pt-4 border-t border-secondary/10">
                        Ao confirmar, uma das cópias deste local será reservada em seu nome a partir da data de retirada selecionada.
                    </p>
                </div>
            </div>

            <!-- Footer -->
            <div class="p-4 bg-div-15 border-t border-secondary/20 flex justify-end gap-3 shrink-0">
                <button @click="$emit('close')" class="px-6 py-2.5 rounded-xl text-secondary hover:bg-div-30 font-medium transition-colors">Cancelar</button>
                <button 
                    @click="handleReserve" 
                    :disabled="loading || copies.length === 0 || !selectedLocationKey"
                    class="px-8 py-2.5 rounded-xl bg-primary text-white font-bold hover:bg-primary-dark transition-colors shadow-lg shadow-primary/20 flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                    <span v-if="saving" class="animate-spin text-sm">⌛</span>
                    Confirmar Reserva
                </button>
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
