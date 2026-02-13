<script setup>
import { ref, watch, onMounted, computed } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'

const props = defineProps({
    isOpen: Boolean,
    initialData: Object
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
    id_responsavel_principal: null // Will be uuid of resp 1 or 2
})

const responsaveis = ref([
    {
        tempId: 1, // Frontend ID
        id: null, // Database ID (if existing)
        nome_completo: '',
        cpf: '',
        email: '',
        telefone: '',
        endereco: '', // Simple string for now or component? Let's use simple fields for mvp
        papel: 'Pai', // Default
        principal: true
    },
    {
        tempId: 2,
        id: null,
        nome_completo: '',
        cpf: '',
        email: '',
        telefone: '',
        endereco: '',
        papel: 'Mãe',
        principal: false
    }
])

const alunosVinculados = ref([]) // Array of student objects

// Options
const papeisOpcoes = ['Pai', 'Mãe', 'Avô', 'Avó', 'Tio', 'Tia', 'Padrasto', 'Madrasta', 'Irmão', 'Irmã', 'Outro']

// Search Alunos State
const searchAlunoQuery = ref('')
const searchAlunosResults = ref([])
const isSearchingAlunos = ref(false)

// Init
watch(() => props.isOpen, (val) => {
    if (val) {
        if (props.initialData) {
            loadFamiliaData(props.initialData.id)
        } else {
            resetForm()
        }
    }
})

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
        // Fetch details (need RPC for this: familia_get_detalhes)
        // For now, mock or implement RPC later.
        // Assuming rpc exists:
         const { data, error } = await supabase.rpc('familia_get_detalhes', { p_id: id })
         if (error) throw error

         if (data) {
             formFamilia.value = {
                 id: data.id,
                 nome_familia: data.nome_familia,
                 id_responsavel_principal: data.id_responsavel_principal
             }
             // Map responsaveis
             if (data.responsaveis && data.responsaveis.length > 0) {
                 // Map existing data to our 2 slots
                 responsaveis.value[0] = { ...data.responsaveis[0], tempId: 1, principal: data.responsaveis[0].id === data.id_responsavel_principal }
                 if (data.responsaveis[1]) {
                     responsaveis.value[1] = { ...data.responsaveis[1], tempId: 2, principal: data.responsaveis[1].id === data.id_responsavel_principal }
                 } else {
                     // Empty slot 2
                     responsaveis.value[1] = { tempId: 2, id: null, nome_completo: '', cpf: '', email: '', telefone: '', endereco: '', papel: 'Mãe', principal: false }
                 }
             }
             // Map alunos
             alunosVinculados.value = data.alunos || []
         }

    } catch (e) {
        console.error(e)
        toast.showToast("Erro ao carregar família", "error")
    } finally {
        isLoading.value = false
    }
}

// Actions
const setPrincipal = (index) => {
    responsaveis.value.forEach((r, i) => r.principal = (i === index))
}

const searchAlunos = async () => {
    if (searchAlunoQuery.value.length < 3) return
    isSearchingAlunos.value = true
    try {
        const { data, error } = await supabase.rpc('aluno_get_paginado', {
            p_id_empresa: appStore.id_empresa,
            p_pagina: 1,
            p_limite_itens_pagina: 5,
            p_busca: searchAlunoQuery.value
        })
        if (error) throw error

        const responseData = Array.isArray(data) ? data[0] : data
        const itens = responseData.itens || []

        searchAlunosResults.value = itens.map(a => ({
            ...a,
            id: a.user_expandido_id 
        }))
    } catch (e) {
        console.error(e)
    } finally {
        isSearchingAlunos.value = false
    }
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
    isSaving.value = true
    try {
        // Construct payload
        // We need to send everything to `familia_upsert`
        
        // Validate
        if (!formFamilia.value.nome_familia) throw new Error("Nome da Família é obrigatório")
        if (!responsaveis.value[0].nome_completo) throw new Error("Responsável 1 é obrigatório")

        const payload = {
            id: formFamilia.value.id,
            nome_familia: formFamilia.value.nome_familia,
            responsaveis: responsaveis.value.filter(r => r.nome_completo).map(r => ({
                id: r.id, // null if new
                nome_completo: r.nome_completo,
                cpf: r.cpf,
                email: r.email,
                telefone: r.telefone,
                endereco: r.endereco,
                papel: r.papel,
                principal: r.principal
            })),
            alunos: alunosVinculados.value.map(a => a.id) // Or use user_expandido_id. Let's verify what `aluno_get_paginado` returns. It returns `user_expandido_id` as `id` (usually). No, check SQL.
        }

        // Check aluno_get_paginado returns: id, nome_completo...
        // Yes, id is uuid.

        // Call RPC
        const { error } = await supabase.rpc('familia_upsert', {
            p_id_empresa: appStore.id_empresa,
            p_data: payload
        })

        if (error) throw error

        toast.showToast("Família salva com sucesso!", "success")
        emit('success')
        emit('close')

    } catch (e) {
        console.error(e)
        toast.showToast(e.message || "Erro ao salvar", "error")
    } finally {
        isSaving.value = false
    }
}

</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-0 md:p-6" @click.self="$emit('close')">
        <div class="bg-background flex flex-col w-full h-full md:w-[90%] md:h-[90%] md:rounded-xl overflow-hidden shadow-2xl border border-secondary/20">
            
            <!-- Header -->
            <div class="flex items-center justify-between p-4 border-b border-div-30 bg-div-15 shrink-0">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Família' : 'Nova Família' }}</h2>
                <button @click="$emit('close')" class="p-2 text-secondary hover:text-text hover:bg-div-30 rounded-lg">✕</button>
            </div>

            <!-- Tabs -->
            <div class="flex border-b border-div-30 bg-div-15/50 overflow-x-auto">
                <button @click="activeTab = 'dados'" class="min-w-[120px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200" :class="activeTab === 'dados' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">Dados Família</button>
                <button @click="activeTab = 'responsaveis'" class="min-w-[120px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200" :class="activeTab === 'responsaveis' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">Responsáveis</button>
                <button @click="activeTab = 'alunos'" class="min-w-[120px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200" :class="activeTab === 'alunos' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">Alunos ({{ alunosVinculados.length }})</button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-6 bg-background text-text">
                
                <!-- Tab: Dados -->
                <div v-if="activeTab === 'dados'" class="max-w-2xl mx-auto space-y-4">
                    <div class="flex flex-col gap-1">
                        <label class="text-sm font-medium text-secondary">Nome da Família</label>
                        <input v-model="formFamilia.nome_familia" class="input-theme" placeholder="Ex: Família Silva">
                        <p class="text-xs text-secondary/70">Um nome para identificar este grupo familiar.</p>
                    </div>
                </div>

                <!-- Tab: Responsaveis -->
                <div v-if="activeTab === 'responsaveis'" class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    <!-- Resp 1 -->
                    <div class="space-y-4 border border-div-30 p-4 rounded-xl bg-div-15/30">
                        <div class="flex items-center justify-between">
                            <h3 class="font-bold text-lg flex items-center gap-2">
                                👤 Responsável 1
                                <span class="text-xs bg-primary/20 text-primary px-2 py-0.5 rounded-full" v-if="responsaveis[0].principal">Principal</span>
                            </h3>
                            <button v-if="!responsaveis[0].principal" @click="setPrincipal(0)" class="text-xs text-secondary hover:text-primary transition-colors">Definir como Principal</button>
                        </div>
                        
                        <!-- Fields Resp 1 -->
                         <div class="grid grid-cols-1 gap-3">
                             <div>
                                 <label class="text-xs text-secondary">Nome Completo</label>
                                 <input v-model="responsaveis[0].nome_completo" class="input-theme">
                             </div>
                             <div class="grid grid-cols-2 gap-3">
                                 <div>
                                     <label class="text-xs text-secondary">CPF</label>
                                     <input v-model="responsaveis[0].cpf" class="input-theme">
                                 </div>
                                 <div>
                                     <label class="text-xs text-secondary">Relacionamento (com alunos)</label>
                                     <select v-model="responsaveis[0].papel" class="input-theme">
                                        <option v-for="p in papeisOpcoes" :key="p" :value="p">{{ p }}</option>
                                     </select>
                                 </div>
                             </div>
                              <div>
                                 <label class="text-xs text-secondary">Email</label>
                                 <input v-model="responsaveis[0].email" class="input-theme">
                             </div>
                             <div>
                                 <label class="text-xs text-secondary">Telefone</label>
                                 <input v-model="responsaveis[0].telefone" class="input-theme">
                             </div>
                         </div>
                    </div>

                    <!-- Resp 2 -->
                    <div class="space-y-4 border border-div-30 p-4 rounded-xl bg-div-15/30">
                        <div class="flex items-center justify-between">
                            <h3 class="font-bold text-lg flex items-center gap-2">
                                👤 Responsável 2 (Opcional)
                                <span class="text-xs bg-primary/20 text-primary px-2 py-0.5 rounded-full" v-if="responsaveis[1].principal">Principal</span>
                            </h3>
                             <button v-if="!responsaveis[1].principal" @click="setPrincipal(1)" class="text-xs text-secondary hover:text-primary transition-colors">Definir como Principal</button>
                        </div>
                        <!-- Fields Resp 2 -->
                        <div class="grid grid-cols-1 gap-3">
                             <div>
                                 <label class="text-xs text-secondary">Nome Completo</label>
                                 <input v-model="responsaveis[1].nome_completo" class="input-theme">
                             </div>
                             <div class="grid grid-cols-2 gap-3">
                                 <div>
                                     <label class="text-xs text-secondary">CPF</label>
                                     <input v-model="responsaveis[1].cpf" class="input-theme">
                                 </div>
                                 <div>
                                     <label class="text-xs text-secondary">Relacionamento</label>
                                     <select v-model="responsaveis[1].papel" class="input-theme">
                                        <option v-for="p in papeisOpcoes" :key="p" :value="p">{{ p }}</option>
                                     </select>
                                 </div>
                             </div>
                              <div>
                                 <label class="text-xs text-secondary">Email</label>
                                 <input v-model="responsaveis[1].email" class="input-theme">
                             </div>
                             <div>
                                 <label class="text-xs text-secondary">Telefone</label>
                                 <input v-model="responsaveis[1].telefone" class="input-theme">
                             </div>
                         </div>
                    </div>
                </div>

                <!-- Tab: Alunos -->
                <div v-if="activeTab === 'alunos'" class="max-w-3xl mx-auto space-y-6">
                    <!-- Search -->
                     <div class="relative">
                        <label class="text-sm font-medium text-secondary mb-1 block">Adicionar Aluno</label>
                        <input 
                            v-model="searchAlunoQuery" 
                            @input="searchAlunos"
                            placeholder="Buscar aluno por nome..." 
                            class="input-theme w-full"
                        >
                        <!-- Results Dropdown -->
                        <div v-if="searchAlunosResults.length > 0" class="absolute top-full left-0 right-0 bg-background border border-div-30 rounded-lg shadow-lg mt-1 max-h-60 overflow-y-auto z-10">
                            <div 
                                v-for="aluno in searchAlunosResults" 
                                :key="aluno.id"
                                @click="addAluno(aluno)"
                                class="p-3 hover:bg-div-15 cursor-pointer flex justify-between items-center transition-colors"
                            >
                                <span class="font-medium">{{ aluno.nome_completo }}</span>
                                <span class="text-xs text-secondary">{{ aluno.matricula }}</span>
                            </div>
                        </div>
                     </div>

                     <!-- List -->
                     <div class="space-y-2">
                        <h3 class="font-bold text-lg text-text">Alunos Vinculados</h3>
                        <div v-if="alunosVinculados.length === 0" class="p-8 text-center text-secondary bg-div-15/30 rounded-lg border border-div-30 border-dashed">
                            Nenhum aluno vinculado ainda.
                        </div>
                        <div v-else class="grid grid-cols-1 gap-2">
                            <div v-for="(aluno, idx) in alunosVinculados" :key="aluno.id" class="flex items-center justify-between p-3 bg-div-15 rounded-lg border border-div-30">
                                <div>
                                    <p class="font-medium text-text">{{ aluno.nome_completo }}</p>
                                    <p class="text-xs text-secondary">Matrícula: {{ aluno.matricula || 'N/A' }}</p>
                                </div>
                                <button @click="removeAluno(idx)" class="text-red-500 hover:text-red-600 p-2">✕</button>
                            </div>
                        </div>
                     </div>
                </div>

            </div>

             <!-- Footer -->
            <div class="flex items-center justify-end p-4 border-t border-div-30 bg-div-15 shrink-0 gap-3">
                <button @click="$emit('close')" class="px-4 py-2 text-secondary hover:text-text hover:bg-div-30 rounded-lg transition-colors font-medium">Cancelar</button>
                <button @click="handleSave" :disabled="isSaving" class="px-6 py-2 bg-primary hover:bg-primary-dark text-white rounded-lg shadow-lg shadow-primary/20 transition-all font-medium disabled:opacity-50 flex items-center gap-2">
                    <span v-if="isSaving" class="animate-spin">⏳</span>
                    <span>{{ isSaving ? 'Salvando...' : 'Salvar Família' }}</span>
                </button>
            </div>

        </div>
    </div>
</template>

<style scoped>
.input-theme {
    @apply w-full px-3 py-2 bg-background border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary;
}
</style>
