<script setup>
import { ref, watch, onMounted, computed } from 'vue'
import { supabase } from '../lib/supabase'
import { useAppStore } from '../stores/app'
import { useToastStore } from '../stores/toast'
import { validateCPF } from '../utils/validators'
import { formatCPF } from '../utils/formatters'

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    },
    initialData: {
        type: Object, // Se null, é CRIAÇÃO. Se tem objeto (com ID), pode ser EDIÇÃO.
        default: null
    }
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

// State
const isLoading = ref(false)
const isSaving = ref(false)
const errorMessage = ref('')
const isLoadingCep = ref(false)
const activeTab = ref('dados') // 'dados', 'escola', 'endereco', 'componentes'

// Data Lists
const listaPerguntas = ref([])
const listaComponentes = ref([])

// Form Data
const formDados = ref({
    nome_completo: '',
    email: '',
    telefone: '',
    matricula: '',
    status: 'Ativo'
})

// Respostas: { id_pergunta: { resposta: '...', tipo: '...', id_resposta: '...' } }
const formRespostas = ref({})

// Componentes: Set of IDs
const formComponentes = ref(new Set())
// Mapeamento para saber se já existia (para mandar o ID do vinculo se houver)
const componentesDetalhes = ref({}) // { id_componente: { id_professor_componente, ano_referencia } }
const isProfessorNaoAplica = ref(false)

// Slots para perguntas especificas
const questionSlots = ref({
    rg: null,
    cpf: null,
    nascimento: null,
    genero: null,
    admissao: null,
    cep: null,
    endereco: null,
    numero: null,
    complemento: null,
    bairro: null,
    cidade: null,
    habilitacao_infantil: null,
    acumulo: null,
    afastamento: null,
    tempo_afastamento: null,
    horas_trabalho: null,
    tipo_contrato: null
})
// Lista de perguntas que SOBRARAM sem slot (vão pra aba Escola)
const perguntasGerais = ref([])

// Papéis para buscar perguntas (Professor e Professor Função Extra)
const PAPEIS_PROFESSOR = [
    "3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1", 
    "07028505-01d7-4986-800e-9d71cab5dd6c"
]

// --- Initialization ---

const resetForm = () => {
    formDados.value = {
        nome_completo: '',
        email: '',
        telefone: '',
        matricula: '',
        status: 'Ativo'
    }
    formRespostas.value = {}
    formComponentes.value = new Set()
    componentesDetalhes.value = {}
    isProfessorNaoAplica.value = false
    activeTab.value = 'dados'
    errorMessage.value = ''
    isLoadingCep.value = false
    
    // Reset slots
    Object.keys(questionSlots.value).forEach(k => questionSlots.value[k] = null)
    perguntasGerais.value = []
}

// Helper para categorizar perguntas
const categorizeQuestions = (perguntas) => {
    const slots = { ...questionSlots.value } // copy
    const gerais = []

    perguntas.forEach(p => {
        const label = (p.label || p.pergunta || '').toLowerCase()
        
        if (label.includes('rg')) slots.rg = p
        else if (label.includes('cpf')) slots.cpf = p
        else if (label.includes('nascimento')) slots.nascimento = p
        else if (label.includes('gênero') || label.includes('genero')) slots.genero = p
        else if (label.includes('admissão') || label.includes('admissao')) slots.admissao = p
        else if (label.includes('cep')) slots.cep = p
        else if (label.includes('endereço') || label.includes('endereco') || label.includes('logradouro')) slots.endereco = p
        else if (label.includes('número') || label.includes('numero')) slots.numero = p
        else if (label.includes('complemento')) slots.complemento = p
        else if (label.includes('bairro')) slots.bairro = p
        else if (label.includes('cidade') || label.includes('município')) slots.cidade = p
        
        // Novos campos Escola
        else if (label.includes('infantil')) slots.habilitacao_infantil = p
        else if (label.includes('acúmulo') || label.includes('acumulo')) slots.acumulo = p
        else if (label.includes('tempo') && label.includes('afastamento')) slots.tempo_afastamento = p
        else if (label.includes('afastamento')) slots.afastamento = p
        else if (label.includes('horas') || label.includes('carga horária')) slots.horas_trabalho = p
        else if (label.includes('tipo') && label.includes('contrato')) slots.tipo_contrato = p
        
        else gerais.push(p)
    })

    questionSlots.value = slots
    perguntasGerais.value = gerais
}

const fetchAuxiliaryData = async () => {
    isLoading.value = true
    try {
        // 1. Perguntas
        const { data: perguntas, error: errorPerguntas } = await supabase.rpc('perguntas_get', {
            p_id_empresa: appStore.id_empresa,
            p_papeis: PAPEIS_PROFESSOR
        })
        if (errorPerguntas) throw errorPerguntas
        // Categorizar
        categorizeQuestions(perguntas || [])
        
        // Initialize formRespostas
        const initialRespostas = {}
        const allQuestions = perguntas || []
        
        allQuestions.forEach(p => {
             // Tentar manter existente se ja tiver carregado
             initialRespostas[p.id] = { 
                 resposta: '', 
                 tipo: p.tipo 
             }
        })
        formRespostas.value = { ...initialRespostas, ...formRespostas.value }

        // 2. Componentes
        const { data: componentes, error: errorComponentes } = await supabase.rpc('componentes_get', {
            p_id_empresa: appStore.id_empresa
        })
        if (errorComponentes) throw errorComponentes
        listaComponentes.value = componentes || []

    } catch (error) {
        console.error('Erro ao carregar dados auxiliares:', error)
        errorMessage.value = 'Erro ao carregar formulário.'
    } finally {
        isLoading.value = false
    }
}

const loadDetails = async (idProfessor) => {
    isLoading.value = true
    try {
        const { data, error } = await supabase.rpc('professor_get_detalhes_cpx', {
            p_id_empresa: appStore.id_empresa,
            p_id_professor: idProfessor
        })

        if (error) throw error

        if (data) {
            // 1. Dados Gerais
            if (data.dados_gerais) {
                formDados.value = {
                    id: data.dados_gerais.user_expandido_id, 
                    nome_completo: data.dados_gerais.nome_completo,
                    email: data.dados_gerais.email,
                    telefone: data.dados_gerais.telefone, 
                    matricula: data.dados_gerais.matricula,
                    status: data.dados_gerais.status
                }
            }

            // 2. Respostas
            const respostasMap = {}
            if (data.respostas) {
                data.respostas.forEach(r => {
                    respostasMap[r.id_pergunta] = {
                        resposta: r.resposta,
                        tipo: r.tipo,
                        id_resposta: r.id_resposta
                    }
                })
            }
            // Merge com default para nao perder references reativas das perguntas q nao tem resposta salva ainda
            formRespostas.value = { ...formRespostas.value, ...respostasMap }


            // 3. Componentes
            const componentesSet = new Set()
            const detalhesMap = {}
            if (data.componentes && data.componentes.length > 0) {
                isProfessorNaoAplica.value = false
                data.componentes.forEach(c => {
                    componentesSet.add(c.id_componente)
                    detalhesMap[c.id_componente] = {
                        id_professor_componente: c.id_professor_componente,
                        ano_referencia: c.ano_referencia
                    }
                })
            } else {
                 // Se veio detalhe mas sem componentes, pode ser 'Nao Aplica' ou simplesmente 'Sem nada'.
                 // A logica "Nao Aplica" é puramente frontend checkbox state se a lista estiver vazia. 
                 // Vamos assumir false por padrao, usuario marca se quiser.
            }
            
            formComponentes.value = componentesSet
            componentesDetalhes.value = detalhesMap
        }

    } catch (error) {
        console.error('Erro ao carregar detalhes do professor:', error)
        errorMessage.value = 'Erro ao carregar dados do professor.'
    } finally {
        isLoading.value = false
    }
}


watch(() => props.isOpen, async (newVal) => {
    if (newVal) {
        resetForm()
        await fetchAuxiliaryData()
        
        if (props.initialData) {
            await loadDetails(props.initialData.user_expandido_id)
        }
    }
})

// --- Logic for Special Fields ---

const handleCpfInput = (e, perguntaId) => {
    const raw = e.target.value
    const formatted = formatCPF(raw)
    formRespostas.value[perguntaId].resposta = formatted
}

const handleCepInput = (e, perguntaId) => {
    // Pega o valor atual
    let value = e.target.value
    
    // Remove tudo que não é dígito
    let clean = value.replace(/\D/g, '')
    
    // Limita a 8 dígitos
    if (clean.length > 8) clean = clean.slice(0, 8)
    
    // Mascara: 00000-000
    let formatted = clean
    if (clean.length > 5) {
        formatted = clean.slice(0, 5) + '-' + clean.slice(5)
    }
    
    // Atualiza o modelo
    if (formRespostas.value[perguntaId]) {
        formRespostas.value[perguntaId].resposta = formatted
    }
    
    // Se tiver 8 digitos, busca o CEP
    if (clean.length === 8 && !isLoadingCep.value) {
        fetchCep(clean)
    }
}

const fetchCep = async (cep) => {
    isLoadingCep.value = true
    try {
        const res = await fetch(`https://viacep.com.br/ws/${cep}/json/`)
        const data = await res.json()
        if (!data.erro) {
            // Preencher slots
            
            // 2. Preencher Endereço
            if (questionSlots.value.endereco && formRespostas.value[questionSlots.value.endereco.id]) {
                formRespostas.value[questionSlots.value.endereco.id].resposta = data.logradouro
            }
            if (questionSlots.value.bairro && formRespostas.value[questionSlots.value.bairro.id]) {
                formRespostas.value[questionSlots.value.bairro.id].resposta = data.bairro
            }
            if (questionSlots.value.cidade && formRespostas.value[questionSlots.value.cidade.id]) {
                formRespostas.value[questionSlots.value.cidade.id].resposta = data.localidade
            }
            
            // Focar numero?
            setTimeout(() => {
                document.getElementById('numero')?.focus()
            }, 100)
        }
    } catch (e) {
        console.error('Erro ViaCEP', e)
    } finally {
        isLoadingCep.value = false
    }
}


// --- Actions ---

const handleClose = () => {
    resetForm()
    emit('close')
}

const handleSave = async () => {
    // 1. Validacao Nome
    if (!formDados.value.nome_completo) {
        errorMessage.value = 'Nome completo é obrigatório.'
        activeTab.value = 'dados'
        return
    }
    // 2. Validacao CPF (se existir slot)
    if (questionSlots.value.cpf) {
        const cpfVal = formRespostas.value[questionSlots.value.cpf.id]?.resposta
        if (cpfVal && !validateCPF(cpfVal)) {
            errorMessage.value = 'CPF inválido.'
            activeTab.value = 'dados'
            return
        }
    }

    isSaving.value = true
    errorMessage.value = ''

    try {
        // Montar JSON Payload
        const respostasArray = Object.keys(formRespostas.value).map(idPergunta => ({
            id_pergunta: idPergunta,
            resposta: formRespostas.value[idPergunta].resposta,
            tipo: formRespostas.value[idPergunta].tipo
        }))
        
        let componentesArray = []
        if (!isProfessorNaoAplica.value) {
            componentesArray = Array.from(formComponentes.value).map(idComponente => {
                const detalhe = componentesDetalhes.value[idComponente] || {}
                return {
                    id_componente: idComponente,
                    id_professor_componente: detalhe.id_professor_componente,
                    ano_referencia: detalhe.ano_referencia || new Date().getFullYear().toString()
                }
            })
        }

        const payload = {
            ...formDados.value,
            respostas: respostasArray,
            componentes: componentesArray
        }
        
        const { error } = await supabase.rpc('professor_upsert', {
            p_data: payload,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        toast.showToast('Professor salvo com sucesso!', 'success')
        emit('success')
        emit('close')

    } catch (error) {
        console.error('Erro ao salvar professor:', error)
        errorMessage.value = 'Erro ao salvar. Verifique os dados.'
        toast.showToast('Erro ao salvar.', 'error')
    } finally {
        isSaving.value = false
    }
}

const toggleComponente = (idComponente) => {
    if (isProfessorNaoAplica.value) return 
    
    if (formComponentes.value.has(idComponente)) {
        formComponentes.value.delete(idComponente)
    } else {
        formComponentes.value.add(idComponente)
    }
}

const toggleNaoAplica = () => {
    isProfessorNaoAplica.value = !isProfessorNaoAplica.value
    if (isProfessorNaoAplica.value) {
        formComponentes.value.clear()
    }
}

// Helpers par Renderização
const activeProximo = computed(() => {
   if (activeTab.value === 'dados') return 'escola'
   if (activeTab.value === 'escola') return 'endereco'
   if (activeTab.value === 'endereco') return 'componentes'
   return null
})

const activeAnterior = computed(() => {
   if (activeTab.value === 'componentes') return 'endereco'
   if (activeTab.value === 'endereco') return 'escola'
   if (activeTab.value === 'escola') return 'dados'
   return null
})
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-0 md:p-6" @click.self="handleClose">
        <!-- 90% Width Layout -->
        <div class="bg-background flex flex-col w-full h-full md:w-[90%] md:h-[90%] md:rounded-xl overflow-hidden shadow-2xl border border-secondary/20">
            
            <!-- Header -->
            <div class="flex items-center justify-between p-4 border-b border-secondary/20 bg-div-15 shrink-0">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Professor' : 'Novo Professor' }}</h2>
                <button @click="handleClose" class="p-2 text-secondary hover:text-text hover:bg-div-30 rounded-lg">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <!-- Tabs -->
            <div class="flex border-b border-secondary/20 bg-div-15/50 overflow-x-auto">
                <button @click="activeTab = 'dados'" class="min-w-[120px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'dados' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Dados Pessoais
                </button>
                <button @click="activeTab = 'escola'" class="min-w-[120px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'escola' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Dados Escola
                </button>
                 <button @click="activeTab = 'endereco'" class="min-w-[120px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'endereco' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Endereço
                </button>
                <button @click="activeTab = 'componentes'" class="min-w-[120px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'componentes' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Componentes
                </button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-6 bg-background">
                
                <div v-if="isLoading && !isSaving" class="flex flex-col items-center justify-center py-10 text-secondary">
                    <div class="animate-spin text-2xl mb-2">⌛</div>
                    <p>Carregando informações...</p>
                </div>

                <div v-else>
                     <!-- Tab: Dados Pessoais -->
                     <div v-show="activeTab === 'dados'" class="space-y-4">
                        <!-- Linha 1: Nome Completo (Full) -->
                        <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Nome Completo <span class="text-red-500">*</span></label>
                            <input v-model="formDados.nome_completo" type="text" class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary" placeholder="Nome do Professor">
                        </div>

                        <!-- Linha 2: RG e CPF -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                             <!-- RG -->
                             <div class="flex flex-col gap-1">
                                 <label class="text-sm font-medium text-secondary">RG</label>
                                 <input 
                                    v-if="questionSlots.rg"
                                    v-model="formRespostas[questionSlots.rg.id].resposta" 
                                    type="text" 
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                 >
                                 <div v-else class="text-xs text-secondary/50 italic">Campo não configurado</div>
                             </div>
                             <!-- CPF -->
                             <div class="flex flex-col gap-1">
                                 <label class="text-sm font-medium text-secondary">
                                    CPF <span v-if="questionSlots.cpf?.obrigatorio" class="text-red-500">*</span>
                                </label>
                                 <input 
                                    v-if="questionSlots.cpf"
                                    :value="formRespostas[questionSlots.cpf.id].resposta" 
                                    @input="(e) => handleCpfInput(e, questionSlots.cpf.id)"
                                    type="text" 
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                    placeholder="000.000.000-00"
                                 >
                                 <div v-else class="text-xs text-secondary/50 italic">Campo não configurado</div>
                             </div>
                        </div>

                        <!-- Linha 3: Telefone e Email -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div class="flex flex-col gap-1">
                                <label class="text-sm font-medium text-secondary">Telefone</label>
                                <input v-model="formDados.telefone" type="text" class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary" placeholder="(00) 00000-0000">
                            </div>
                            <div class="flex flex-col gap-1">
                                <label class="text-sm font-medium text-secondary">Email</label>
                                <input v-model="formDados.email" type="email" class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary" placeholder="email@exemplo.com">
                            </div>
                        </div>

                        <!-- Linha 4: Nascimento e Gênero -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <!-- Nascimento -->
                            <div class="flex flex-col gap-1">
                                <label class="text-sm font-medium text-secondary">Data de Nascimento</label>
                                <input 
                                    v-if="questionSlots.nascimento"
                                    v-model="formRespostas[questionSlots.nascimento.id].resposta" 
                                    type="date" 
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                >
                                <div v-else class="text-xs text-secondary/50 italic">Campo não configurado</div>
                            </div>
                             <!-- Gênero -->
                             <div class="flex flex-col gap-1">
                                 <label class="text-sm font-medium text-secondary">Gênero</label>
                                 <select 
                                    v-if="questionSlots.genero && questionSlots.genero.opcoes"
                                    v-model="formRespostas[questionSlots.genero.id].resposta"
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                 >
                                     <option value="" disabled>Selecione</option>
                                     <option v-for="opt in questionSlots.genero.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                 </select>
                                 <input 
                                    v-else-if="questionSlots.genero"
                                    v-model="formRespostas[questionSlots.genero.id].resposta"
                                    type="text"
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                 >
                                 <div v-else class="text-xs text-secondary/50 italic">Campo não configurado</div>
                             </div>
                        </div>
                     </div>

                     <!-- Tab: Dados Escola -->
                     <div v-show="activeTab === 'escola'" class="space-y-4">
                         <!-- Linha 1: Matrícula e Admissão -->
                         <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div class="flex flex-col gap-1">
                                <label class="text-sm font-medium text-secondary">Matrícula</label>
                                <input v-model="formDados.matricula" type="text" class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary" placeholder="Matrícula">
                            </div>
                            <div class="flex flex-col gap-1">
                                <label class="text-sm font-medium text-secondary">Data de Admissão</label>
                                <input 
                                    v-if="questionSlots.admissao"
                                    v-model="formRespostas[questionSlots.admissao.id].resposta" 
                                    type="date" 
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                >
                                <div v-else class="text-xs text-secondary/50 italic">Campo não configurado</div>
                            </div>
                         </div>

                         <!-- Linha 2: Habilitação Infantil e Acúmulo -->
                         <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <!-- Habilitação Infantil -->
                            <div class="flex flex-col gap-1">
                                 <label class="text-sm font-medium text-secondary">Habilitação Infantil</label>
                                 <select 
                                    v-if="questionSlots.habilitacao_infantil && questionSlots.habilitacao_infantil.opcoes"
                                    v-model="formRespostas[questionSlots.habilitacao_infantil.id].resposta"
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                 >
                                     <option value="" disabled>Selecione</option>
                                     <option v-for="opt in questionSlots.habilitacao_infantil.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                 </select>
                                 <div v-else class="text-xs text-secondary/50 italic">Campo não configurado</div>
                             </div>
                             <!-- Acúmulo -->
                             <div class="flex flex-col gap-1">
                                 <label class="text-sm font-medium text-secondary">Acúmulo</label>
                                 <select 
                                    v-if="questionSlots.acumulo && questionSlots.acumulo.opcoes"
                                    v-model="formRespostas[questionSlots.acumulo.id].resposta"
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                 >
                                     <option value="" disabled>Selecione</option>
                                     <option v-for="opt in questionSlots.acumulo.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                 </select>
                                 <div v-else class="text-xs text-secondary/50 italic">Campo não configurado</div>
                             </div>
                         </div>

                         <!-- Linha 3: Afastamento e Tempo Afastamento -->
                         <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                             <!-- Afastamento -->
                             <div class="flex flex-col gap-1">
                                 <label class="text-sm font-medium text-secondary">Afastamento</label>
                                 <select 
                                    v-if="questionSlots.afastamento && questionSlots.afastamento.opcoes"
                                    v-model="formRespostas[questionSlots.afastamento.id].resposta"
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                 >
                                     <option value="" disabled>Selecione</option>
                                     <option v-for="opt in questionSlots.afastamento.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                 </select>
                                 <div v-else class="text-xs text-secondary/50 italic">Campo não configurado</div>
                             </div>
                             <!-- Tempo Afastamento -->
                             <div class="flex flex-col gap-1">
                                 <label class="text-sm font-medium text-secondary">Tempo de Afastamento</label>
                                 <select 
                                    v-if="questionSlots.tempo_afastamento && questionSlots.tempo_afastamento.opcoes"
                                    v-model="formRespostas[questionSlots.tempo_afastamento.id].resposta"
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                 >
                                     <option value="" disabled>Selecione</option>
                                     <option v-for="opt in questionSlots.tempo_afastamento.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                 </select>
                                 <div v-else class="text-xs text-secondary/50 italic">Campo não configurado</div>
                             </div>
                         </div>

                         <!-- Linha 4: Horas de Trabalho (Full) -->
                         <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Horas de Trabalho</label>
                             <input 
                                v-if="questionSlots.horas_trabalho"
                                v-model="formRespostas[questionSlots.horas_trabalho.id].resposta" 
                                type="text" 
                                class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                            >
                             <div v-else class="text-xs text-secondary/50 italic">Campo não configurado</div>
                         </div>

                         <!-- Linha 5: Status e Tipo de Contrato -->
                         <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                              <div class="flex flex-col gap-1">
                                <label class="text-sm font-medium text-secondary">Status do Contrato</label>
                                <select v-model="formDados.status" class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary">
                                    <option value="Ativo">Ativo</option>
                                    <option value="Exonerado">Exonerado</option>
                                    <option value="Aposentado">Aposentado</option>
                                </select>
                            </div>
                            <div class="flex flex-col gap-1">
                                <label class="text-sm font-medium text-secondary">Tipo de Contrato</label>
                                <select 
                                    v-if="questionSlots.tipo_contrato && questionSlots.tipo_contrato.opcoes"
                                    v-model="formRespostas[questionSlots.tipo_contrato.id].resposta"
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                >
                                     <option value="" disabled>Selecione</option>
                                     <option v-for="opt in questionSlots.tipo_contrato.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                 </select>
                                <div v-else class="text-xs text-secondary/50 italic">Campo não configurado</div>
                            </div>
                         </div>
                         
                         <!-- Demais Perguntas (se sobrarem) -->
                         <div v-if="perguntasGerais.length > 0" class="pt-4 border-t border-secondary/10 mt-4">
                             <h3 class="text-sm font-bold text-secondary mb-3">Outras Informações</h3>
                             <div class="grid grid-cols-1 gap-4">
                                 <div v-for="pergunta in perguntasGerais" :key="pergunta.id" class="flex flex-col gap-1">
                                     <label class="text-sm font-medium text-secondary">
                                         {{ pergunta.label || pergunta.pergunta }}
                                         <span v-if="pergunta.obrigatorio" class="text-red-500">*</span>
                                     </label>
                                     <select 
                                        v-if="(pergunta.tipo === 'select' || pergunta.tipo === 'opcao') && pergunta.opcoes"
                                        v-model="formRespostas[pergunta.id].resposta"
                                        class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                     >
                                         <option value="" disabled>Selecione</option>
                                         <option v-for="opt in pergunta.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                     </select>
                                     <textarea 
                                        v-else-if="pergunta.tipo === 'textarea'"
                                        v-model="formRespostas[pergunta.id].resposta"
                                        class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary h-24 resize-none"
                                     ></textarea>
                                     <input 
                                        v-else
                                        type="text"
                                        v-model="formRespostas[pergunta.id].resposta"
                                        class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                     >
                                 </div>
                             </div>
                         </div>
                     </div>

                     <!-- Tab: Endereço -->
                     <div v-show="activeTab === 'endereco'" class="space-y-4">
                         <!-- Linha 1: CEP (Busca) + Bairro (Readonly) -->
                         <div class="grid grid-cols-2 gap-4">
                             <div v-if="questionSlots.cep" class="flex flex-col gap-1 relative">
                                 <label class="text-sm font-medium text-secondary">CEP</label>
                                 <input 
                                    :value="formRespostas[questionSlots.cep.id].resposta" 
                                    @input="(e) => handleCepInput(e, questionSlots.cep.id)"
                                    type="text" 
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                    placeholder="00000-000"
                                 >
                                 <span v-if="isLoadingCep" class="absolute right-3 top-9 animate-spin text-primary">⌛</span>
                             </div>
                             <div v-if="questionSlots.bairro" class="flex flex-col gap-1">
                                 <label class="text-sm font-medium text-secondary">Bairro</label>
                                 <input 
                                    v-model="formRespostas[questionSlots.bairro.id].resposta" 
                                    readonly
                                    type="text" 
                                    class="w-full px-3 py-2 bg-div-30 border border-div-30 rounded-lg text-text focus:outline-none cursor-default opacity-80"
                                 >
                             </div>
                         </div>
                         
                         <!-- Linha 2: Endereço (Full) -->
                         <div v-if="questionSlots.endereco" class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Endereço</label>
                             <input 
                                v-model="formRespostas[questionSlots.endereco.id].resposta" 
                                readonly
                                type="text" 
                                class="w-full px-3 py-2 bg-div-30 border border-div-30 rounded-lg text-text focus:outline-none cursor-default opacity-80"
                             >
                         </div>

                         <!-- Linha 3: Numero + Complemento -->
                         <div class="grid grid-cols-2 gap-4">
                             <div v-if="questionSlots.numero" class="flex flex-col gap-1">
                                 <label class="text-sm font-medium text-secondary">Número</label>
                                 <input 
                                    id="numero"
                                    v-model="formRespostas[questionSlots.numero.id].resposta" 
                                    type="text" 
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                 >
                             </div>
                             <div v-if="questionSlots.complemento" class="flex flex-col gap-1">
                                 <label class="text-sm font-medium text-secondary">Complemento</label>
                                 <input 
                                    v-model="formRespostas[questionSlots.complemento.id].resposta" 
                                    type="text" 
                                    class="w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary"
                                 >
                             </div>
                         </div>

                         <!-- Linha 4: Cidade -->
                         <div v-if="questionSlots.cidade" class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Cidade</label>
                             <input 
                                v-model="formRespostas[questionSlots.cidade.id].resposta" 
                                readonly
                                type="text" 
                                class="w-full px-3 py-2 bg-div-30 border border-div-30 rounded-lg text-text focus:outline-none cursor-default opacity-80"
                             >
                         </div>
                     </div>

                     <!-- Tab: Componentes -->
                     <div v-show="activeTab === 'componentes'" class="space-y-4">
                         
                         <div class="flex items-center gap-3 p-3 bg-div-30/50 rounded-lg border border-secondary/20">
                             <input 
                                type="checkbox" 
                                :checked="isProfessorNaoAplica" 
                                @change="toggleNaoAplica"
                                class="w-5 h-5 rounded border-secondary text-primary focus:ring-primary"
                             >
                             <span class="text-text font-medium">Não se aplica (Não leciona disciplinas curriculares)</span>
                         </div>

                         <div v-if="!isProfessorNaoAplica" class="grid grid-cols-1 md:grid-cols-2 gap-2 max-h-[400px] overflow-y-auto">
                             <div 
                                v-for="comp in listaComponentes" 
                                :key="comp.uuid"
                                @click="toggleComponente(comp.uuid)"
                                class="flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all hover:bg-div-30"
                                :class="formComponentes.has(comp.uuid) ? 'bg-primary/10 border-primary' : 'bg-div-15 border-secondary/20'"
                             >
                                 <div 
                                    class="w-5 h-5 rounded border flex items-center justify-center shrink-0 transition-colors"
                                    :class="formComponentes.has(comp.uuid) ? 'bg-primary border-primary text-white' : 'border-secondary bg-background'"
                                 >
                                     <svg v-if="formComponentes.has(comp.uuid)" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                 </div>
                                 <span class="text-sm font-medium text-text">{{ comp.nome }}</span>
                             </div>
                         </div>
                         <div v-else class="text-center text-secondary py-10 opacity-60">
                             Nenhum componente selecionado.
                         </div>
                     </div>
                </div>

                <div v-if="errorMessage" class="mt-4 p-3 bg-red-500/10 text-red-500 rounded-lg text-sm border border-red-500/20">
                    {{ errorMessage }}
                </div>
            </div>

            <!-- Footer -->
            <div class="flex items-center justify-between p-4 border-t border-secondary/20 bg-div-15 shrink-0">
                
                <div class="flex gap-2">
                     <button 
                        v-if="activeAnterior"
                        @click="activeTab = activeAnterior"
                        class="px-4 py-2 text-secondary hover:text-text font-medium text-sm transition-colors"
                    >
                        &larr; Voltar
                    </button>
                </div>

                <div class="flex gap-2">
                    <button 
                        v-if="activeProximo"
                        @click="activeTab = activeProximo"
                        class="px-4 py-2 bg-div-30 hover:bg-div-30 text-text font-medium text-sm rounded-lg transition-colors border border-secondary"
                    >
                        Próximo &rarr;
                    </button>

                    <button 
                        v-else
                        @click="handleSave"
                        :disabled="isSaving || isLoading"
                        class="px-6 py-2 bg-primary text-white font-bold text-sm rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                    >
                        <span v-if="isSaving" class="animate-spin">⌛</span>
                        Salvar
                    </button>
                </div>
            </div>

        </div>
    </div>
</template>
