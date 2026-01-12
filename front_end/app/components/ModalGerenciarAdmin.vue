<script setup>
import { ref, watch, onMounted } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'

const props = defineProps({
    isOpen: { type: Boolean, default: false },
    initialData: { type: Object, default: null }
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

const isSaving = ref(false)
const form = ref({ id: null, nome_completo: '', email: '', telefone: '' })

// onMounted: Handle when modal is created with v-if already in open state
onMounted(() => {
    if (props.isOpen) {
        if (props.initialData) {
            form.value = {
                id: props.initialData.id,
                nome_completo: props.initialData.nome_completo,
                email: props.initialData.email,
                telefone: props.initialData.telefone
            }
        } else {
            form.value = { id: null, nome_completo: '', email: '', telefone: '' }
        }
    }
})

watch(() => props.isOpen, (val) => {
    if (val) {
        if (props.initialData) {
            form.value = {
                id: props.initialData.id,
                nome_completo: props.initialData.nome_completo,
                email: props.initialData.email,
                telefone: props.initialData.telefone
            }
        } else {
            form.value = { id: null, nome_completo: '', email: '', telefone: '' }
        }
    }
})

const handleSave = async () => {
    if (!form.value.nome_completo) return toast.showToast("Nome é obrigatório", "error")
    if (!form.value.email) return toast.showToast("Email é obrigatório", "error")

    isSaving.value = true
    try {
        await $fetch('/api/usuarios/admins', {
            method: 'POST',
            body: {
                data: form.value,
                id_empresa: appStore.company.empresa_id
            }
        })
        toast.showToast("Admin salvo com sucesso!", "success")
        emit('success')
        emit('close')
    } catch (e) {
        toast.showToast(e.data?.message || "Erro ao salvar", "error")
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-6">
        <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="emit('close')"></div>
        <div class="relative bg-background w-full max-w-lg flex flex-col rounded shadow-2xl border border-secondary/10 overflow-hidden">
            
            <div class="px-6 py-4 border-b border-secondary/10 flex items-center justify-between bg-div-15">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Admin' : 'Novo Admin' }}</h2>
                <button @click="emit('close')" class="p-2 rounded hover:bg-div-30"><span class="text-xl">×</span></button>
            </div>

            <div class="p-6 space-y-4">
                <div class="flex flex-col gap-1">
                    <label class="text-xs font-bold text-secondary uppercase">Nome Completo</label>
                    <input v-model="form.nome_completo" class="input-theme" />
                </div>
                <div class="flex flex-col gap-1">
                    <label class="text-xs font-bold text-secondary uppercase">Email</label>
                    <input v-model="form.email" type="email" class="input-theme" />
                </div>
                <div class="flex flex-col gap-1">
                    <label class="text-xs font-bold text-secondary uppercase">Telefone</label>
                    <input v-model="form.telefone" class="input-theme" />
                </div>
            </div>

            <div class="p-4 border-t border-secondary/10 flex justify-end gap-3 bg-div-15">
                <button @click="emit('close')" class="px-4 py-2 text-xs font-bold text-secondary hover:text-text">Cancelar</button>
                <button @click="handleSave" :disabled="isSaving" class="px-6 py-2 bg-primary text-white rounded text-xs font-bold hover:brightness-110 disabled:opacity-50">
                    {{ isSaving ? 'Salvando...' : 'Salvar Admin' }}
                </button>
            </div>
        </div>
    </div>
</template>

<style scoped>
.input-theme {
    @apply w-full px-3 py-2 bg-background border border-[#6B82A74D] rounded text-sm text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder:text-[#6B82A780];
}
</style>
