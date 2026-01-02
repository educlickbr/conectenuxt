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
        type: Object,
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
const activeTab = ref('dados') // 'dados', 'documentos', 'endereco', 'familia', 'saude', 'outros'

// Data Lists
const listaPerguntas = ref([])

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

// Slots mapping
const questionSlots = ref({
    // Dados Pessoais
    ra: null,
    rg: null,
    cpf: null,
    nascimento: null,
    genero: null,
    etnia: null, // "etnia"
    celular: null,
    permite_sms: null,

    // Documentos & Origem
    data_emissao_rg: null,
    orgao_emissor: null,
    cidade_rg: null,
    documento_rne: null,
    data_emissao_rne: null,
    estrangeiro: null,
    nasceu_outro_pais: null,
    cidade_origem: null,
    obs_origem: null,
    data_registro: null,
    tipo_registro: null,
    data_emissao_registro: null,
    lv: null,
    distrito: null,

    // Endereço
    cep: null,
    endereco: null,
    numero: null,
    complemento: null,
    bairro: null,
    cidade: null,
    iptu: null,

    // Família
    pai: null, 
    mae: null,
    responsavel: null,
    tipo_responsavel: null,
    tem_irmao: null,
    tem_gemeo: null,
    bolsa_familia: null,
    nis: null,

    // Saúde
    mobilidade_reduzida: null,
    necessidades_especiais: null,
    desc_necessidades: null,
    cid: null,
    alergia: null,

    // Outros/Escolar
    tipo_contrato: null,
    rm: null,
    quilombola: null,
    matricula_judicial: null,
    obs_matricula_judicial: null
})

const perguntasGerais = ref([])

// Role Aluno
const PAPEL_ALUNO = ["b7f53d6e-70b5-453b-b564-728aeb4635d5"]

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
    activeTab.value = 'dados'
    errorMessage.value = ''
    isLoadingCep.value = false
    
    // Reset slots
    Object.keys(questionSlots.value).forEach(k => questionSlots.value[k] = null)
    perguntasGerais.value = []
}

// Categorize Questions Logic
const categorizeQuestions = (perguntas) => {
    const slots = { ...questionSlots.value }
    const gerais = []

    perguntas.forEach(p => {
        const labelRaw = (p.label || p.pergunta || '').toLowerCase()
        const label = labelRaw.normalize("NFD").replace(/[\u0300-\u036f]/g, "") // remove accents for easier matching

        // Helper check
        const matches = (str) => label.includes(str)
        const exact = (str) => label === str

        // Mapeamento Direto por ID (ideal) ou Label (fallback)
        // Como IDs podem mudar entre ambientes (dev/prod), label é mais seguro se consistente, ou slug(pergunta)
        const slug = p.pergunta ? p.pergunta.toLowerCase() : ''

        if (slug === 'ra') slots.ra = p
        else if (slug === 'rg') slots.rg = p
        else if (slug === 'cpf') slots.cpf = p
        else if (slug === 'data_nascimento') slots.nascimento = p
        else if (slug === 'genero') slots.genero = p
        else if (slug === 'etnia') slots.etnia = p
        else if (slug === 'celular') slots.celular = p
        else if (slug === 'permite_sms') slots.permite_sms = p

        else if (slug === 'data_emissao_rg') slots.data_emissao_rg = p
        else if (slug === 'orgao_emissor_rg') slots.orgao_emissor = p
        else if (slug === 'cidade_rg') slots.cidade_rg = p
        else if (slug === 'documento_rne') slots.documento_rne = p
        else if (slug === 'data_emissao_rne') slots.data_emissao_rne = p
        else if (slug === 'estrangeiro') slots.estrangeiro = p
        else if (slug === 'nasceu_outro_pais') slots.nasceu_outro_pais = p
        else if (slug === 'cidade_origem') slots.cidade_origem = p
        else if (slug === 'obs_origem') slots.obs_origem = p
        else if (slug === 'data_registro') slots.data_registro = p
        else if (slug === 'tipo_registro') slots.tipo_registro = p
        else if (slug === 'data_emissao_registro') slots.data_emissao_registro = p
        else if (slug === 'lv') slots.lv = p
        else if (slug === 'distrito') slots.distrito = p

        else if (slug === 'cep') slots.cep = p
        else if (slug === 'endereco') slots.endereco = p
        else if (slug === 'numero') slots.numero = p
        else if (slug === 'complemento') slots.complemento = p
        else if (slug === 'bairro') slots.bairro = p
        else if (slug === 'cidade') slots.cidade = p
        else if (slug === 'iptu') slots.iptu = p

        else if (slug === 'pai') slots.pai = p
        else if (slug === 'mae') slots.mae = p
        else if (slug === 'responsavel') slots.responsavel = p
        else if (slug === 'tipo_responsavel') slots.tipo_responsavel = p
        else if (slug === 'tem_irmao') slots.tem_irmao = p
        else if (slug === 'tem_gemeo') slots.tem_gemeo = p
        else if (slug === 'bolsa_familia') slots.bolsa_familia = p
        else if (slug === 'nis') slots.nis = p

        else if (slug === 'mobilidade_reduzida') slots.mobilidade_reduzida = p
        else if (slug === 'necessidades_especiais') slots.necessidades_especiais = p
        else if (slug === 'desc_necessidades_especiais') slots.desc_necessidades = p
        else if (slug === 'cid') slots.cid = p
        else if (slug === 'alergia') slots.alergia = p

        else if (slug === 'tipo_contrato') slots.tipo_contrato = p
        else if (slug === 'rm') slots.rm = p
        else if (slug === 'quilombola') slots.quilombola = p
        else if (slug === 'matricula_judicial') slots.matricula_judicial = p
        else if (slug === 'obs_matricula_judicial') slots.obs_matricula_judicial = p
        
        else gerais.push(p)
    })

    questionSlots.value = slots
    perguntasGerais.value = gerais
}

const fetchAuxiliaryData = async () => {
    isLoading.value = true
    try {
        const { data: perguntas, error: errorPerguntas } = await supabase.rpc('perguntas_get', {
            p_id_empresa: appStore.id_empresa,
            p_papeis: PAPEL_ALUNO
        })
        if (errorPerguntas) throw errorPerguntas
        
        categorizeQuestions(perguntas || [])
        
        const initialRespostas = {}
        const allQuestions = perguntas || []
        
        allQuestions.forEach(p => {
             initialRespostas[p.id] = { 
                 resposta: '', 
                 tipo: p.tipo 
             }
        })
        formRespostas.value = { ...initialRespostas, ...formRespostas.value }

    } catch (error) {
        console.error('Erro ao carregar dados auxiliares:', error)
        errorMessage.value = 'Erro ao carregar formulário.'
    } finally {
        isLoading.value = false
    }
}

const loadDetails = async (idAluno) => {
    isLoading.value = true
    try {
        const { data, error } = await supabase.rpc('aluno_get_detalhes_cpx', {
            p_id_empresa: appStore.id_empresa,
            p_id_aluno: idAluno
        })

        if (error) throw error

        if (data) {
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
            formRespostas.value = { ...formRespostas.value, ...respostasMap }
        }

    } catch (error) {
        console.error('Erro ao carregar detalhes do aluno:', error)
        errorMessage.value = 'Erro ao carregar dados do aluno.'
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
    let value = e.target.value
    let clean = value.replace(/\D/g, '')
    if (clean.length > 8) clean = clean.slice(0, 8)
    let formatted = clean
    if (clean.length > 5) {
        formatted = clean.slice(0, 5) + '-' + clean.slice(5)
    }
    if (formRespostas.value[perguntaId]) {
        formRespostas.value[perguntaId].resposta = formatted
    }
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
            if (questionSlots.value.endereco && formRespostas.value[questionSlots.value.endereco.id]) {
                formRespostas.value[questionSlots.value.endereco.id].resposta = data.logradouro
            }
            if (questionSlots.value.bairro && formRespostas.value[questionSlots.value.bairro.id]) {
                formRespostas.value[questionSlots.value.bairro.id].resposta = data.bairro
            }
            if (questionSlots.value.cidade && formRespostas.value[questionSlots.value.cidade.id]) {
                formRespostas.value[questionSlots.value.cidade.id].resposta = data.localidade
            }
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
    if (!formDados.value.nome_completo) {
        errorMessage.value = 'Nome completo é obrigatório.'
        activeTab.value = 'dados'
        return
    }
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
        const respostasArray = Object.keys(formRespostas.value).map(idPergunta => ({
            id_pergunta: idPergunta,
            resposta: formRespostas.value[idPergunta].resposta,
            tipo: formRespostas.value[idPergunta].tipo
        }))
        
        const payload = {
            ...formDados.value,
            respostas: respostasArray
        }
        
        const { error } = await supabase.rpc('aluno_upsert', {
            p_data: payload,
            p_id_empresa: appStore.id_empresa
        })

        if (error) throw error

        toast.showToast('Aluno salvo com sucesso!', 'success')
        emit('success')
        emit('close')

    } catch (error) {
        console.error('Erro ao salvar aluno:', error)
        errorMessage.value = 'Erro ao salvar. Verifique os dados.'
        toast.showToast('Erro ao salvar.', 'error')
    } finally {
        isSaving.value = false
    }
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-0 md:p-6" @click.self="handleClose">
        <!-- 90% Width Layout -->
        <div class="bg-background flex flex-col w-full h-full md:w-[90%] md:h-[90%] md:rounded-xl overflow-hidden shadow-2xl border border-secondary/20">
            
            <!-- Header -->
            <div class="flex items-center justify-between p-4 border-b border-secondary/20 bg-div-15 shrink-0">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Aluno' : 'Novo Aluno' }}</h2>
                <div class="flex items-center gap-4">
                    <span v-if="errorMessage" class="text-red-500 text-sm font-medium">{{ errorMessage }}</span>
                    <button @click="handleClose" class="p-2 text-secondary hover:text-text hover:bg-div-30 rounded-lg">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>
            </div>

            <!-- Tabs -->
            <div class="flex border-b border-secondary/20 bg-div-15/50 overflow-x-auto">
                <button @click="activeTab = 'dados'" class="min-w-[100px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'dados' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Dados Pessoais
                </button>
                <button @click="activeTab = 'documentos'" class="min-w-[100px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'documentos' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Documentos e Origem
                </button>
                 <button @click="activeTab = 'endereco'" class="min-w-[100px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'endereco' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Endereço
                </button>
                <button @click="activeTab = 'familia'" class="min-w-[100px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'familia' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Família
                </button>
                <button @click="activeTab = 'saude'" class="min-w-[100px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'saude' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Saúde
                </button>
                <button @click="activeTab = 'outros'" class="min-w-[100px] flex-1 py-3 text-sm font-medium border-b-2 transition-colors duration-200 whitespace-nowrap" :class="activeTab === 'outros' ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'">
                    Outros
                </button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-6 bg-background">
                
                <div v-if="isLoading && !isSaving" class="flex flex-col items-center justify-center py-10 text-secondary">
                    <div class="animate-spin text-2xl mb-2">⌛</div>
                    <p>Carregando informações...</p>
                </div>

                <div v-else>
                     
                     <!-- TAB: DADOS PESSOAIS -->
                     <div v-show="activeTab === 'dados'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="col-span-2 flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Nome Completo <span class="text-red-500">*</span></label>
                            <input v-model="formDados.nome_completo" type="text" class="input-theme" placeholder="Nome do Aluno">
                        </div>

                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">RA (Registro do Aluno)</label>
                             <input v-if="questionSlots.ra" v-model="formRespostas[questionSlots.ra.id].resposta" type="text" class="input-theme">
                             <div v-else class="text-xs text-secondary/50 italic">Não configurado</div>
                        </div>
                        
                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">CPF</label>
                             <input v-if="questionSlots.cpf" :value="formRespostas[questionSlots.cpf.id].resposta" @input="(e) => handleCpfInput(e, questionSlots.cpf.id)" type="text" class="input-theme" placeholder="000.000.000-00">
                             <div v-else class="text-xs text-secondary/50 italic">Não configurado</div>
                        </div>

                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Data de Nascimento</label>
                             <input v-if="questionSlots.nascimento" v-model="formRespostas[questionSlots.nascimento.id].resposta" type="date" class="input-theme">
                             <div v-else class="text-xs text-secondary/50 italic">Não configurado</div>
                        </div>

                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Gênero</label>
                             <select v-if="questionSlots.genero?.opcoes" v-model="formRespostas[questionSlots.genero.id].resposta" class="input-theme">
                                 <option value="" disabled>Selecione</option>
                                 <option v-for="opt in questionSlots.genero.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                             </select>
                             <input v-else-if="questionSlots.genero" v-model="formRespostas[questionSlots.genero.id].resposta" type="text" class="input-theme">
                             <div v-else class="text-xs text-secondary/50 italic">Não configurado</div>
                        </div>

                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Etnia</label>
                             <select v-if="questionSlots.etnia?.opcoes" v-model="formRespostas[questionSlots.etnia.id].resposta" class="input-theme">
                                 <option value="" disabled>Selecione</option>
                                 <option v-for="opt in questionSlots.etnia.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                             </select>
                             <div v-else class="text-xs text-secondary/50 italic">Não configurado</div>
                        </div>

                         <!-- Contato merged directly -->
                         <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Email</label>
                             <input v-model="formDados.email" type="email" class="input-theme" placeholder="email@exemplo.com">
                         </div>
                         <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Telefone / Celular</label>
                             <input v-if="questionSlots.celular" v-model="formRespostas[questionSlots.celular.id].resposta" type="text" class="input-theme">
                             <input v-else v-model="formDados.telefone" type="text" class="input-theme">
                         </div>
                         <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Permite SMS?</label>
                              <select v-if="questionSlots.permite_sms?.opcoes" v-model="formRespostas[questionSlots.permite_sms.id].resposta" class="input-theme">
                                  <option value="" disabled>Selecione</option>
                                  <option v-for="opt in questionSlots.permite_sms.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                              </select>
                         </div>
                     </div>

                     <!-- TAB: DOCUMENTOS -->
                     <div v-show="activeTab === 'documentos'" class="space-y-6">
                        <!-- RG Section (Header only, no box) -->
                        <div>
                            <h3 class="font-bold text-text mb-3 flex items-center gap-2 border-b border-secondary/10 pb-2">🪪 Documento de Identidade & Registro</h3>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">RG</label>
                                    <input v-if="questionSlots.rg" v-model="formRespostas[questionSlots.rg.id].resposta" class="input-theme">
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Data Emissão RG</label>
                                    <input v-if="questionSlots.data_emissao_rg" v-model="formRespostas[questionSlots.data_emissao_rg.id].resposta" type="date" class="input-theme">
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Órgão Emissor</label>
                                    <input v-if="questionSlots.orgao_emissor" v-model="formRespostas[questionSlots.orgao_emissor.id].resposta" class="input-theme">
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Cidade do RG</label>
                                    <input v-if="questionSlots.cidade_rg" v-model="formRespostas[questionSlots.cidade_rg.id].resposta" class="input-theme">
                                </div>
                                <!-- Split line if wanted, or just continue grid -->
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Data Registro Civil</label>
                                    <input v-if="questionSlots.data_registro" v-model="formRespostas[questionSlots.data_registro.id].resposta" type="date" class="input-theme">
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Tipo Registro</label>
                                    <input v-if="questionSlots.tipo_registro" v-model="formRespostas[questionSlots.tipo_registro.id].resposta" class="input-theme">
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Data Emissão Registro</label>
                                    <input v-if="questionSlots.data_emissao_registro" v-model="formRespostas[questionSlots.data_emissao_registro.id].resposta" type="date" class="input-theme">
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">LV</label>
                                    <input v-if="questionSlots.lv" v-model="formRespostas[questionSlots.lv.id].resposta" class="input-theme">
                                </div>
                            </div>
                        </div>

                        <!-- Origem Section (Header only, no box) -->
                         <div class="pt-4">
                            <h3 class="font-bold text-text mb-3 flex items-center gap-2 border-b border-secondary/10 pb-2">🌍 Origem e Nacionalidade</h3>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Estrangeiro?</label>
                                    <select v-if="questionSlots.estrangeiro?.opcoes" v-model="formRespostas[questionSlots.estrangeiro.id].resposta" class="input-theme">
                                         <option value="" disabled>Selecione</option>
                                         <option v-for="opt in questionSlots.estrangeiro.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                    </select>
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Nasceu em outro país?</label>
                                    <select v-if="questionSlots.nasceu_outro_pais?.opcoes" v-model="formRespostas[questionSlots.nasceu_outro_pais.id].resposta" class="input-theme">
                                         <option value="" disabled>Selecione</option>
                                         <option v-for="opt in questionSlots.nasceu_outro_pais.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                    </select>
                                </div>
                                 <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Cidade de Origem</label>
                                    <input v-if="questionSlots.cidade_origem" v-model="formRespostas[questionSlots.cidade_origem.id].resposta" class="input-theme">
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">RNE (Se estrangeiro)</label>
                                    <input v-if="questionSlots.documento_rne" v-model="formRespostas[questionSlots.documento_rne.id].resposta" class="input-theme">
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Data Emissão RNE</label>
                                    <input v-if="questionSlots.data_emissao_rne" v-model="formRespostas[questionSlots.data_emissao_rne.id].resposta" type="date" class="input-theme">
                                </div>
                                <div class="flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Quilombola?</label>
                                    <select v-if="questionSlots.quilombola?.opcoes" v-model="formRespostas[questionSlots.quilombola.id].resposta" class="input-theme">
                                        <option value="" disabled>Selecione</option>
                                        <option v-for="opt in questionSlots.quilombola.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                    </select>
                                </div>
                                <div class="col-span-2 flex flex-col gap-1">
                                    <label class="text-sm font-medium text-secondary">Obs. Origem</label>
                                    <textarea v-if="questionSlots.obs_origem" v-model="formRespostas[questionSlots.obs_origem.id].resposta" class="input-theme h-20 resize-none"></textarea>
                                </div>
                            </div>
                         </div>
                     </div>

                     <!-- TAB: ENDERECO -->
                     <div v-show="activeTab === 'endereco'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="flex flex-col gap-1 relative">
                             <label class="text-sm font-medium text-secondary">CEP</label>
                             <input 
                                v-if="questionSlots.cep"
                                :value="formRespostas[questionSlots.cep.id].resposta" 
                                @input="(e) => handleCepInput(e, questionSlots.cep.id)"
                                type="text" 
                                class="input-theme"
                                placeholder="00000-000"
                             >
                             <span v-if="isLoadingCep" class="absolute right-3 top-8 animate-spin text-primary">⌛</span>
                        </div>
                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Bairro</label>
                             <input v-if="questionSlots.bairro" v-model="formRespostas[questionSlots.bairro.id].resposta" readonly class="input-theme bg-div-30 opacity-80 cursor-default">
                        </div>
                         
                        <div class="col-span-2 flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Endereço</label>
                             <input v-if="questionSlots.endereco" v-model="formRespostas[questionSlots.endereco.id].resposta" readonly class="input-theme bg-div-30 opacity-80 cursor-default">
                        </div>

                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Número</label>
                             <input id="numero" v-if="questionSlots.numero" v-model="formRespostas[questionSlots.numero.id].resposta" class="input-theme">
                        </div>
                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Complemento</label>
                             <input v-if="questionSlots.complemento" v-model="formRespostas[questionSlots.complemento.id].resposta" class="input-theme">
                        </div>
                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Cidade</label>
                             <input v-if="questionSlots.cidade" v-model="formRespostas[questionSlots.cidade.id].resposta" readonly class="input-theme bg-div-30 opacity-80 cursor-default">
                        </div>
                         <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Distrito</label>
                             <input v-if="questionSlots.distrito" v-model="formRespostas[questionSlots.distrito.id].resposta" class="input-theme">
                        </div>
                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">IPTU</label>
                             <input v-if="questionSlots.iptu" v-model="formRespostas[questionSlots.iptu.id].resposta" class="input-theme">
                        </div>
                     </div>

                     <!-- TAB: FAMILIA -->
                     <div v-show="activeTab === 'familia'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <!-- Parents (Removed box, kept grid) -->
                        <div class="col-span-2 grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div class="flex flex-col gap-1" v-if="questionSlots.pai">
                                <label class="text-sm font-medium text-secondary">Nome do Pai</label>
                                <input v-model="formRespostas[questionSlots.pai.id].resposta" class="input-theme">
                            </div>
                            <div class="flex flex-col gap-1" v-if="questionSlots.mae">
                                <label class="text-sm font-medium text-secondary">Nome da Mãe</label>
                                <input v-model="formRespostas[questionSlots.mae.id].resposta" class="input-theme">
                            </div>
                            <div class="flex flex-col gap-1" v-if="questionSlots.responsavel">
                                <label class="text-sm font-medium text-secondary">Nome do Responsável</label>
                                <input v-model="formRespostas[questionSlots.responsavel.id].resposta" class="input-theme">
                            </div>
                            <div class="flex flex-col gap-1" v-if="questionSlots.tipo_responsavel">
                                <label class="text-sm font-medium text-secondary">Tipo de Responsável</label>
                                <select v-if="questionSlots.tipo_responsavel?.opcoes" v-model="formRespostas[questionSlots.tipo_responsavel.id].resposta" class="input-theme">
                                    <option value="" disabled>Selecione</option>
                                    <option v-for="opt in questionSlots.tipo_responsavel.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                </select>
                            </div>
                        </div>

                        <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Tem Irmão?</label>
                            <select v-if="questionSlots.tem_irmao?.opcoes" v-model="formRespostas[questionSlots.tem_irmao.id].resposta" class="input-theme">
                                <option value="" disabled>Selecione</option>
                                <option v-for="opt in questionSlots.tem_irmao.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                            </select>
                        </div>
                        <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Tem Gêmeo?</label>
                            <select v-if="questionSlots.tem_gemeo?.opcoes" v-model="formRespostas[questionSlots.tem_gemeo.id].resposta" class="input-theme">
                                <option value="" disabled>Selecione</option>
                                <option v-for="opt in questionSlots.tem_gemeo.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                            </select>
                        </div>
                        <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Bolsa Família?</label>
                            <select v-if="questionSlots.bolsa_familia?.opcoes" v-model="formRespostas[questionSlots.bolsa_familia.id].resposta" class="input-theme">
                                <option value="" disabled>Selecione</option>
                                <option v-for="opt in questionSlots.bolsa_familia.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                            </select>
                        </div>
                        <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">NIS</label>
                            <input v-if="questionSlots.nis" v-model="formRespostas[questionSlots.nis.id].resposta" class="input-theme">
                        </div>
                     </div>

                     <!-- TAB: SAUDE -->
                     <div v-show="activeTab === 'saude'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Mobilidade Reduzida?</label>
                            <select v-if="questionSlots.mobilidade_reduzida?.opcoes" v-model="formRespostas[questionSlots.mobilidade_reduzida.id].resposta" class="input-theme">
                                <option value="" disabled>Selecione</option>
                                <option v-for="opt in questionSlots.mobilidade_reduzida.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                            </select>
                        </div>
                        <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Necessidades Especiais?</label>
                            <select v-if="questionSlots.necessidades_especiais?.opcoes" v-model="formRespostas[questionSlots.necessidades_especiais.id].resposta" class="input-theme">
                                <option value="" disabled>Selecione</option>
                                <option v-for="opt in questionSlots.necessidades_especiais.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                            </select>
                        </div>
                         <div class="col-span-2 flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">CID (Se houver)</label>
                             <input v-if="questionSlots.cid" v-model="formRespostas[questionSlots.cid.id].resposta" class="input-theme">
                        </div>
                        <div class="col-span-2 flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Alergia</label>
                             <textarea v-if="questionSlots.alergia" v-model="formRespostas[questionSlots.alergia.id].resposta" class="input-theme h-24"></textarea>
                        </div>
                        <div class="col-span-2 flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Descrição das Necessidades</label>
                             <textarea v-if="questionSlots.desc_necessidades" v-model="formRespostas[questionSlots.desc_necessidades.id].resposta" class="input-theme h-32"></textarea>
                        </div>
                     </div>

                     <!-- TAB: OUTROS -->
                     <div v-show="activeTab === 'outros'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Matrícula</label>
                             <input v-model="formDados.matricula" class="input-theme">
                        </div>
                        <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">RM</label>
                             <input v-if="questionSlots.rm" v-model="formRespostas[questionSlots.rm.id].resposta" class="input-theme">
                        </div>
                         <div class="flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Status</label>
                             <select v-model="formDados.status" class="input-theme">
                                 <option value="Ativo">Ativo</option>
                                 <option value="Inativo">Inativo</option>
                                 <option value="Transferido">Transferido</option>
                                 <option value="Evadido">Evadido</option>
                             </select>
                        </div>

                         <div class="flex flex-col gap-1">
                            <label class="text-sm font-medium text-secondary">Matrícula Judicial?</label>
                            <select v-if="questionSlots.matricula_judicial?.opcoes" v-model="formRespostas[questionSlots.matricula_judicial.id].resposta" class="input-theme">
                                <option value="" disabled>Selecione</option>
                                <option v-for="opt in questionSlots.matricula_judicial.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                            </select>
                        </div>
                        <div class="col-span-2 flex flex-col gap-1">
                             <label class="text-sm font-medium text-secondary">Obs. Matrícula Judicial</label>
                             <textarea v-if="questionSlots.obs_matricula_judicial" v-model="formRespostas[questionSlots.obs_matricula_judicial.id].resposta" class="input-theme h-24"></textarea>
                        </div>

                        <!-- Generic Leftovers -->
                        <div v-if="perguntasGerais.length > 0" class="col-span-2 pt-4 border-t border-secondary/10 mt-4">
                             <h3 class="text-sm font-bold text-secondary mb-3">Outras Informações</h3>
                             <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                 <div v-for="pergunta in perguntasGerais" :key="pergunta.id" class="flex flex-col gap-1" :class="pergunta.tipo === 'texto_longo' || pergunta.tipo === 'textarea' ? 'col-span-2' : ''">
                                     <label class="text-sm font-medium text-secondary">
                                         {{ pergunta.label || pergunta.pergunta }}
                                         <span v-if="pergunta.obrigatorio" class="text-red-500">*</span>
                                     </label>
                                     <select 
                                        v-if="(pergunta.tipo === 'select' || pergunta.tipo === 'opcao') && pergunta.opcoes"
                                        v-model="formRespostas[pergunta.id].resposta"
                                        class="input-theme"
                                     >
                                         <option value="" disabled>Selecione</option>
                                         <option v-for="opt in pergunta.opcoes" :key="opt" :value="opt">{{ opt }}</option>
                                     </select>
                                     <textarea 
                                        v-else-if="pergunta.tipo === 'texto_longo' || pergunta.tipo === 'textarea'"
                                        v-model="formRespostas[pergunta.id].resposta"
                                        class="input-theme h-24 resize-none"
                                     ></textarea>
                                     <input 
                                        v-else
                                        :type="pergunta.tipo === 'data' ? 'date' : 'text'"
                                        v-model="formRespostas[pergunta.id].resposta"
                                        class="input-theme"
                                     >
                                 </div>
                             </div>
                         </div>
                     </div>

                </div>
            </div>

            <!-- Footer -->
            <div class="p-4 border-t border-secondary/20 bg-div-15 flex justify-end gap-3 shrink-0">
                <button @click="handleClose" class="px-4 py-2 text-secondary font-medium hover:bg-div-30 rounded-lg transition-colors">Cancelar</button>
                <button @click="handleSave" :disabled="isSaving" class="px-6 py-2 bg-primary hover:bg-primary-dark text-white font-bold rounded-lg shadow-lg shadow-primary/20 transition-all transform hover:scale-105 disabled:opacity-50 disabled:scale-100 flex items-center gap-2">
                    <span v-if="isSaving" class="animate-spin">⌛</span>
                    {{ initialData ? 'Salvar Alterações' : 'Cadastrar Aluno' }}
                </button>
            </div>

        </div>
    </div>
</template>

<style scoped>
.input-theme {
    @apply w-full px-3 py-2 bg-div-15 border border-div-30 rounded-lg text-text focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-secondary;
}
</style>
