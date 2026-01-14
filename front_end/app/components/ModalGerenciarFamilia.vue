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

// State
const activeTab = ref('dados')
const isLoading = ref(false)
const isSaving = ref(false)

const formFamilia = ref({
    id: null,
    nome_familia: '',
    id_responsavel_principal: null
})

const responsaveis = ref([
    { tempId: 1, id: null, nome_completo: '', cpf: '', email: '', telefone: '', endereco: '', papel: 'Pai', principal: true },
    { tempId: 2, id: null, nome_completo: '', cpf: '', email: '', telefone: '', endereco: '', papel: 'Mãe', principal: false }
])

const alunosVinculados = ref([])
const papeisOpcoes = ['Pai', 'Mãe', 'Avô', 'Avó', 'Tio', 'Tia', 'Padrasto', 'Madrasta', 'Irmão', 'Irmã', 'Outro']

// Search Alunos
const searchAlunoQuery = ref('')
const searchAlunosResults = ref([])
const isSearchingAlunos = ref(false)

// Watch for open change
watch(() => props.isOpen, (val) => {
    if (val) {
        initModal()
    }
})

// Also check on mount in case it is rendered with v-if="true"
onMounted(() => {
    if (props.isOpen) {
        initModal()
    }
})

const initModal = () => {
    if (props.initialData) {
        console.log('[ModalFamilia] Opening with data:', props.initialData)
        loadFamiliaData(props.initialData.id)
    } else {
        console.log('[ModalFamilia] Opening new')
        resetForm()
    }
}

const resetForm = () => {
    activeTab.value = 'dados'
    formFamilia.value = { id: null, nome_familia: '', id_responsavel_principal: null }
    responsaveis.value = [
        { tempId: 1, id: null, nome_completo: '', cpf: '', email: '', telefone: '', endereco: '', papel: 'Pai', principal: true },
        { tempId: 2, id: null, nome_completo: '', cpf: '', email: '', telefone: '', endereco: '', papel: 'Mãe', principal: false }
    ]
    alunosVinculados.value = []
    searchAlunoQuery.value = ''
    searchAlunosResults.value = []
}

const loadFamiliaData = async (id) => {
    isLoading.value = true
    try {
        const data = await $fetch(`/api/usuarios/familias/detalhes/${id}`, {
            query: { id_empresa: appStore.company.empresa_id }
        })

        if (data) {
             formFamilia.value = {
                 id: data.id,
                 nome_familia: data.nome_familia,
                 id_responsavel_principal: data.id_responsavel_principal
             }
             
             // Reset responsaveis to empty slots first
             responsaveis.value = [
                { tempId: 1, id: null, nome_completo: '', cpf: '', email: '', telefone: '', endereco: '', papel: 'Pai', principal: true },
                { tempId: 2, id: null, nome_completo: '', cpf: '', email: '', telefone: '', endereco: '', papel: 'Mãe', principal: false }
             ]

             if (data.responsaveis && data.responsaveis.length > 0) {
                 // Sort so principal is first if possible, or just map
                 // The RPC returns responsaveis list. We need to map them to our 2 slots or expand if we allowed more (UI only shows 2 for now)
                 
                 // Strategy: Fill slots. If one is principal, ensure it's marked (though UI sets principal based on index usually? No, UI has 'principal' flag in object).
                 // Actually UI logic: `responsaveis` is array of 2. 
                 
                 data.responsaveis.forEach((r, idx) => {
                     if (idx < 2) {
                         responsaveis.value[idx] = {
                             ...responsaveis.value[idx], // keep tempId
                             id: r.id,
                             nome_completo: r.nome_completo,
                             cpf: r.cpf,
                             email: r.email,
                             telefone: r.telefone,
                             endereco: r.endereco,
                             papel: r.papel,
                             principal: r.id === data.id_responsavel_principal
                         }
                     }
                 })
             }
             
             alunosVinculados.value = data.alunos ? data.alunos.map(a => ({
                 id: a.id,
                 nome_completo: a.nome_completo,
                 matricula: a.matricula
             })) : []
        }
    } catch (e) {
        console.error(e)
        // toast.showToast("Erro ao carregar detalhes", "error") // Optional
        resetForm()
    } finally {
        isLoading.value = false
    }
}

const setPrincipal = (index) => {
    responsaveis.value.forEach((r, i) => r.principal = (i === index))
}

const searchAlunos = async () => {
    if (searchAlunoQuery.value.length < 3) return
    isSearchingAlunos.value = true
    try {
        const data = await $fetch('/api/usuarios/alunos', {
             query: {
                id_empresa: appStore.company.empresa_id,
                pagina: 1,
                limite: 5,
                busca: searchAlunoQuery.value
            }
        })
        const itens = data.itens || []
        searchAlunosResults.value = itens.map(a => ({
            ...a,
            id: a.user_expandido_id 
        }))
    } catch (e) { console.error(e) } 
    finally { isSearchingAlunos.value = false }
}

const addAluno = (aluno) => {
    if (!alunosVinculados.value.find(a => a.id === aluno.id)) {
        alunosVinculados.value.push(aluno)
    }
    searchAlunoQuery.value = ''
    searchAlunosResults.value = []
}

const removeAluno = (index) => {
    alunosVinculados.value.splice(index, 1)
}

const handleSave = async () => {
    if (!formFamilia.value.nome_familia) return toast.showToast("Nome da Família é obrigatório", "error")
    if (!responsaveis.value[0].nome_completo) return toast.showToast("Responsável 1 é obrigatório", "error")

    isSaving.value = true
    try {
        const payload = {
            id: formFamilia.value.id,
            nome_familia: formFamilia.value.nome_familia,
            responsaveis: responsaveis.value.filter(r => r.nome_completo).map(r => ({
                id: r.id, 
                nome_completo: r.nome_completo,
                cpf: r.cpf,
                email: r.email,
                telefone: r.telefone,
                endereco: r.endereco,
                papel: r.papel,
                principal: r.principal
            })),
            alunos: alunosVinculados.value.map(a => a.id) 
        }

        await $fetch('/api/usuarios/familias', {
            method: 'POST',
            body: { data: payload, id_empresa: appStore.company.empresa_id }
        })

        toast.showToast("Família salva com sucesso!", "success")
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
        <div class="relative bg-background w-full max-w-4xl max-h-[90vh] flex flex-col rounded shadow-2xl border border-[#6B82A71A] overflow-hidden">
            
            <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between bg-div-15">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Família' : 'Nova Família' }}</h2>
                <button @click="emit('close')" class="p-2 rounded hover:bg-div-30"><span class="text-xl">×</span></button>
            </div>

            <div class="flex border-b border-[#6B82A71A] bg-div-15/50 overflow-x-auto">
                 <button v-for="t in ['dados', 'responsaveis', 'alunos']" :key="t" @click="activeTab=t" 
                    class="px-6 py-3 text-sm font-bold capitalize transition-colors border-b-2 whitespace-nowrap"
                    :class="activeTab===t ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'"
                 >
                    {{ t }}
                 </button>
            </div>

            <div class="flex-1 overflow-y-auto p-6 relative">
                 <div v-if="isLoading" class="absolute inset-0 flex items-center justify-center bg-background/80 z-10"><div class="animate-spin text-3xl text-primary">◌</div></div>
                 
                 <div v-show="activeTab === 'dados'" class="max-w-2xl mx-auto space-y-4">
                     <div class="flex flex-col gap-1">
                         <label class="text-xs font-bold text-secondary uppercase">Nome da Família</label>
                         <input v-model="formFamilia.nome_familia" class="input-theme" placeholder="Ex: Família Silva" />
                     </div>
                 </div>

                 <div v-show="activeTab === 'responsaveis'" class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div v-for="(resp, idx) in responsaveis" :key="idx" class="space-y-4 border border-[#6B82A733] p-4 rounded bg-div-15/30">
                        <div class="flex items-center justify-between">
                            <h3 class="font-bold flex items-center gap-2">
                                👤 Responsável {{ idx + 1 }}
                                <span v-if="resp.principal" class="text-[10px] bg-[#3571CB33] text-primary px-2 py-0.5 rounded-full">Principal</span>
                            </h3>
                            <button v-if="!resp.principal" @click="setPrincipal(idx)" class="text-xs text-primary hover:underline">Definir Principal</button>
                        </div>
                         <div class="grid grid-cols-1 gap-3">
                             <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Nome</label><input v-model="resp.nome_completo" class="input-theme" /></div>
                             <div class="grid grid-cols-2 gap-3">
                                 <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">CPF</label><input v-model="resp.cpf" class="input-theme" /></div>
                                 <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Papel</label>
                                     <select v-model="resp.papel" class="input-theme"><option v-for="p in papeisOpcoes" :key="p" :value="p">{{ p }}</option></select>
                                 </div>
                             </div>
                             <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Email</label><input v-model="resp.email" class="input-theme" /></div>
                             <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Telefone</label><input v-model="resp.telefone" class="input-theme" /></div>
                             <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Endereço</label><input v-model="resp.endereco" class="input-theme" /></div>
                         </div>
                    </div>
                 </div>

                 <div v-show="activeTab === 'alunos'" class="max-w-3xl mx-auto space-y-6">
                      <div class="relative flex flex-col gap-1">
                        <label class="text-xs font-bold text-secondary uppercase">Adicionar Aluno</label>
                        <input v-model="searchAlunoQuery" @input="searchAlunos" placeholder="Buscar aluno..." class="input-theme" />
                        <div v-if="searchAlunosResults.length > 0" class="absolute top-full left-0 right-0 bg-background border border-[#6B82A733] rounded shadow-lg mt-1 max-h-60 overflow-y-auto z-20">
                            <div v-for="a in searchAlunosResults" :key="a.id" @click="addAluno(a)" class="p-3 hover:bg-div-15 cursor-pointer flex justify-between items-center bg-background border-b border-[#6B82A71A]">
                                <span class="font-bold">{{ a.nome_completo }}</span><span class="text-xs text-secondary">{{ a.matricula }}</span>
                            </div>
                        </div>
                      </div>
                      <div class="space-y-2">
                        <h3 class="font-bold text-sm text-secondary uppercase">Alunos Vinculados</h3>
                        <div v-if="alunosVinculados.length === 0" class="p-8 text-center text-sm text-secondary bg-div-15/30 rounded border border-dashed border-[#6B82A733]">Nenhum aluno.</div>
                        <div v-else class="grid grid-cols-1 gap-2">
                            <div v-for="(a, idx) in alunosVinculados" :key="a.id" class="flex items-center justify-between p-3 bg-div-15 rounded border border-[#6B82A71A]">
                                <div><p class="font-bold">{{ a.nome_completo }}</p><p class="text-xs text-secondary">{{ a.matricula }}</p></div>
                                <button @click="removeAluno(idx)" class="text-red-500 hover:text-red-400">✕</button>
                            </div>
                        </div>
                      </div>
                 </div>
            </div>

            <div class="p-4 border-t border-[#6B82A71A] flex justify-end gap-3 bg-div-15">
                <button @click="emit('close')" class="px-4 py-2 text-xs font-bold text-secondary hover:text-text">Cancelar</button>
                <button @click="handleSave" :disabled="isSaving" class="px-6 py-2 bg-primary text-white rounded text-xs font-bold hover:brightness-110 disabled:opacity-50">
                    {{ isSaving ? 'Salvando...' : 'Salvar Família' }}
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
