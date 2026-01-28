<script setup>
import { ref, watch, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'
import ManagerField from '@/components/ManagerField.vue'

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    },
    type: {
        type: String,
        default: 'tutor' // 'tutor' | 'integrante'
    },
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

// State
const isSaving = ref(false)
const errorMessage = ref('')
const isLoadingGroups = ref(false)
const isLoadingUsers = ref(false)

// Data
const groupsOptions = ref([]) 
const usersOptions = ref([])

// Form
const formData = ref({
    id_grupo: '',
    id_user: '',
    ano: new Date().getFullYear(),
    status: 'ATIVO'
})

// Config based on Type
const config = computed(() => {
    return props.type === 'tutor' 
        ? { title: 'Vincular Tutor', userLabel: 'Tutor', resource: 'tutores', candidateResource: 'candidatos_tutores' }
        : { title: 'Vincular Integrante', userLabel: 'Aluno', resource: 'integrantes', candidateResource: 'candidatos_integrantes' }
})

// Groups Fetch
const fetchGroups = async () => {
    isLoadingGroups.value = true
    try {
        const { items } = await $fetch(`/api/estrutura_academica/grupos`, {
            query: {
                id_empresa: appStore.company.empresa_id,
                limite: 100,
                status: 'ATIVO'
            }
        })
        
        groupsOptions.value = (items || []).map(g => ({
            value: g.id,
            label: `${g.nome_grupo} (${g.ano || '-'})`
        }))
        
    } catch (err) {
        console.error(err)
        toast.showToast('Erro ao carregar grupos', 'error')
    } finally {
        isLoadingGroups.value = false
    }
}

// Users Fetch (for Dropdown)
const fetchUsers = async () => {
    isLoadingUsers.value = true
    try {
        const { items } = await $fetch(`/api/estrutura_academica/${config.value.candidateResource}`, {
            query: {
                id_empresa: appStore.company.empresa_id,
                limite: 200 // Fetch a good amount for the dropdown
            }
        })
        
        usersOptions.value = (items || []).map(u => ({
            value: u.id || u.user_expandido_id, // Candidates RPC returns `id` (which is user_id from user_expandido)
            label: `${u.nome_completo}`
        }))
        
    } catch (err) {
        console.error(err)
        toast.showToast(`Erro ao carregar ${config.value.userLabel}s`, 'error')
    } finally {
        isLoadingUsers.value = false
    }
}

const resetForm = () => {
    formData.value = {
        id_grupo: '',
        id_user: '',
        ano: new Date().getFullYear(),
        status: 'ATIVO'
    }
    errorMessage.value = ''
    // We can reload options to be fresh
}

watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        resetForm()
        fetchGroups()
        fetchUsers() 
    }
})

// Watch type change to reload users if modal is kept open (unlikely but good practice)
watch(() => props.type, () => {
    if (props.isOpen) fetchUsers()
})


// Save
const handleSave = async () => {
    errorMessage.value = ''
    if (!formData.value.id_grupo) {
        errorMessage.value = 'Selecione um Grupo.'
        return
    }
    if (!formData.value.id_user) {
        errorMessage.value = `Selecione um ${config.value.userLabel}.`
        return
    }

    isSaving.value = true
    try {
        const payload = {
            id_grupo: formData.value.id_grupo,
            id_user: formData.value.id_user,
            ano: formData.value.ano,
            status: formData.value.status
        }
        
        const res = await $fetch(`/api/estrutura_academica/${config.value.resource}`, {
            method: 'POST',
            body: {
                id_empresa: appStore.company.empresa_id,
                data: payload 
            }
        })

        if (res && res.success) {
            toast.showToast('Vínculo criado com sucesso!')
            emit('success')
            emit('close')
        } else {
            errorMessage.value = res?.message || 'Erro ao salvar.'
        }
    } catch (err) {
        console.error(err)
        errorMessage.value = err.data?.message || err.message || 'Erro ao salvar.'
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <Teleport to="body">
        <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-6">
             <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="emit('close')"></div>
             
             <div class="relative bg-background w-full max-w-lg flex flex-col rounded shadow-2xl border border-[#6B82A71A] overflow-hidden min-h-[400px]">
                 <!-- Header -->
                <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between bg-div-15">
                    <div>
                        <h2 class="text-xl font-bold text-text">{{ config.title }}</h2>
                        <p class="text-xs text-secondary mt-0.5">Selecione o grupo e o usuário para vincular.</p>
                    </div>
                </div>

                <!-- Body -->
                <div class="p-6 space-y-6 flex-1 overflow-visible">
                    <div v-if="errorMessage" class="p-3 rounded bg-red-500/5 text-red-500 text-xs text-center border border-red-500/10">{{ errorMessage }}</div>

                    <!-- Group Select -->
                    <ManagerField 
                        v-model="formData.id_grupo"
                        label="Grupo de Estudo"
                        type="select"
                        :options="groupsOptions"
                        :disabled="isLoadingGroups"
                        required
                        placeholder="Selecione um grupo..."
                    />

                    <!-- User Select -->
                    <ManagerField 
                        v-model="formData.id_user"
                        :label="config.userLabel"
                        type="select"
                        :options="usersOptions"
                        :disabled="isLoadingUsers"
                        required
                        placeholder="Selecione um usuário..."
                    />

                    <div class="grid grid-cols-2 gap-4">
                         <ManagerField 
                            v-model="formData.ano"
                            label="Ano Letivo"
                            type="number"
                         />
                           <div class="flex flex-col gap-1.5">
                                <label class="text-[11px] font-bold text-secondary uppercase tracking-wider">Status</label>
                                <select v-model="formData.status" class="w-full px-3 py-2 bg-div-15 border border-[#6B82A71A] rounded text-sm outline-none focus:border-[#3571CB80] focus:ring-4 focus:ring-[#3571CB0D] transition-all">
                                    <option value="ATIVO">Ativo</option>
                                    <option value="INATIVO">Inativo</option>
                                </select>
                           </div>
                    </div>

                </div>

                 <!-- Footer -->
                <div class="px-6 py-4 border-t border-[#6B82A71A] flex items-center justify-end gap-3 bg-div-15">
                    <button @click="emit('close')" class="px-5 py-2.5 rounded text-secondary font-semibold text-sm hover:bg-div-30 transition-colors">Cancelar</button>
                    <button @click="handleSave" :disabled="isSaving" class="px-8 py-2.5 rounded bg-primary text-white font-bold text-sm hover:brightness-110 shadow-lg shadow-[#3571CB33] transition-all flex items-center gap-2">
                         <svg v-if="isSaving" class="animate-spin w-4 h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                         {{ isSaving ? 'Salvando...' : 'Vincular' }}
                    </button>
                </div>

             </div>
        </div>
    </Teleport>
</template>
