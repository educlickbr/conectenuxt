<script setup>
import { ref, watch, onMounted, computed } from 'vue'
import { useAppStore } from '@/stores/app'
import { useToastStore } from '@/stores/toast'

const props = defineProps({
    isOpen: { type: Boolean, default: false },
    initialData: { type: Object, default: null },
    preloadedQuestions: { type: Array, default: () => [] },
    preloadedComponents: { type: Array, default: () => [] }
})

const emit = defineEmits(['close', 'success'])
const appStore = useAppStore()
const toast = useToastStore()

// State
const isLoading = ref(false)
const isSaving = ref(false)
const errorMessage = ref('')
const isLoadingCep = ref(false)
const activeTab = ref('dados')

// Data Lists
const listaComponentes = ref([])

// Form Data
const formDados = ref({
    nome_completo: '',
    email: '',
    telefone: '',
    matricula: '',
    status: 'Ativo'
})
const formRespostas = ref({})
const formComponentes = ref(new Set())
const componentesDetalhes = ref({})
const isProfessorNaoAplica = ref(false)

const questionSlots = ref({
    rg: null, cpf: null, nascimento: null, genero: null, admissao: null,
    cep: null, endereco: null, numero: null, complemento: null, bairro: null, cidade: null,
    habilitacao_infantil: null, acumulo: null, afastamento: null, tempo_afastamento: null,
    horas_trabalho: null, tipo_contrato: null
})
const perguntasGerais = ref([])

const PAPEIS_PROFESSOR = [
    "3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1", 
    "07028505-01d7-4986-800e-9d71cab5dd6c"
]

// --- Utils ---
const formatCPF = (v) => {
    v = v.replace(/\D/g, "")
    if (v.length > 11) v = v.slice(0, 11)
    return v.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4")
}

const categorizeQuestions = (perguntas) => {
    console.log('[ModalProfessor] Categorizing', perguntas?.length || 0, 'questions')
    // Start with a clean slate of slots
    const slots = {
        rg: null, cpf: null, nascimento: null, genero: null, admissao: null,
        cep: null, endereco: null, numero: null, complemento: null, bairro: null, cidade: null,
        habilitacao_infantil: null, acumulo: null, afastamento: null, tempo_afastamento: null,
        horas_trabalho: null, tipo_contrato: null
    }
    const gerais = []

    if (!perguntas) return

    perguntas.forEach(p => {
        // Legacy: label includes logic is very broad. We replicate it.
        // Also fallback to p.pergunta if label missing, just like legacy.
        const text = (p.label || p.pergunta || '').toLowerCase()
        
        if (text.includes('rg')) slots.rg = p
        else if (text.includes('cpf')) slots.cpf = p
        else if (text.includes('nascimento')) slots.nascimento = p
        else if (text.includes('gênero') || text.includes('genero')) slots.genero = p
        else if (text.includes('admissão') || text.includes('admissao')) slots.admissao = p
        else if (text.includes('cep')) slots.cep = p
        else if (text.includes('endereço') || text.includes('endereco') || text.includes('logradouro')) slots.endereco = p
        else if (text.includes('número') || text.includes('numero')) slots.numero = p
        else if (text.includes('complemento')) slots.complemento = p
        else if (text.includes('bairro')) slots.bairro = p
        else if (text.includes('cidade') || text.includes('município')) slots.cidade = p
        
        // Escola
        else if (text.includes('infantil')) slots.habilitacao_infantil = p
        else if (text.includes('acúmulo') || text.includes('acumulo')) slots.acumulo = p
        else if (text.includes('tempo') && text.includes('afastamento')) slots.tempo_afastamento = p
        else if (text.includes('afastamento')) slots.afastamento = p
        else if (text.includes('horas') || text.includes('carga horária')) slots.horas_trabalho = p
        else if (text.includes('tipo') && text.includes('contrato')) slots.tipo_contrato = p
        
        else gerais.push(p)
    })
    
    questionSlots.value = slots
    perguntasGerais.value = gerais
    console.log('[ModalProfessor] Slots assigned:', Object.keys(slots).filter(k => slots[k]).join(', '))
}

// --- Fetching ---
const fetchAuxiliaryData = async () => {
    isLoading.value = true
    try {
        let perguntas = props.preloadedQuestions
        let componentes = props.preloadedComponents

        if ((!perguntas || perguntas.length === 0) && (!componentes || componentes.length === 0)) {
            console.log('[ModalProfessor] No preloaded data, fetching...')
            const companyId = appStore.company?.empresa_id || appStore.company?.id
            if (!companyId) return
            const [p, c] = await Promise.all([
                $fetch('/api/usuarios/auxiliar', {
                    query: { type: 'perguntas', id_empresa: companyId, papeis: PAPEIS_PROFESSOR.join(',') }
                }),
                $fetch('/api/usuarios/auxiliar', {
                    query: { type: 'componentes', id_empresa: companyId }
                })
            ])
            perguntas = p
            componentes = c
        } else {
             console.log('[ModalProfessor] Using preloaded data. Count:', perguntas?.length)
        }

        if (perguntas && perguntas.length > 0) {
            console.table(perguntas.map(p => ({ slug: p.pergunta, label: p.label, tipo: p.tipo })))
        }

        // CRITICAL: Initialize formRespostas BEFORE categorization so refs exist
        const initialRespostas = {}
        ;(perguntas || []).forEach(p => {
             initialRespostas[p.id] = { resposta: '', tipo: p.tipo }
        })
        // Legacy merge order: keep existing data, add new entries
        formRespostas.value = { ...initialRespostas, ...formRespostas.value }

        // Now categorize - template can safely access formRespostas[slot.id]
        categorizeQuestions(perguntas || [])
        
        listaComponentes.value = componentes || []

    } catch (error) {
        console.error('Erro load aux:', error)
        errorMessage.value = 'Erro ao carregar formulário.'
    } finally {
        isLoading.value = false
    }
}

const loadDetails = async (id) => {
    isLoading.value = true
    try {
        const data = await $fetch(`/api/usuarios/professores/detalhes/${id}`, {
            query: { id_empresa: appStore.company.empresa_id || appStore.company.id }
        })

        if (data) {
            // 1. Populate general form data
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
            
            // 2. Process respostas array - contains questions WITH answers
            if (data.respostas && data.respostas.length > 0) {
                console.log('[ModalProfessor] Got', data.respostas.length, 'questions with answers from BFF')
                
                // Initialize formRespostas with all questions AND their answers
                const respostasMap = {}
                data.respostas.forEach(r => {
                    respostasMap[r.id_pergunta] = {
                        resposta: r.resposta || '', 
                        tipo: r.tipo, 
                        id_resposta: r.id_resposta
                    }
                })
                // CRITICAL: MERGE with existing formRespostas (initialized by fetchAuxiliaryData)
                formRespostas.value = { ...formRespostas.value, ...respostasMap }
            }
            
            // 3. Process components
            if (data.componentes && data.componentes.length > 0) {
                const setC = new Set()
                const detMap = {}
                data.componentes.forEach(c => {
                    setC.add(c.id_componente)
                    detMap[c.id_componente] = {
                        id_professor_componente: c.id_professor_componente,
                        ano_referencia: c.ano_referencia
                    }
                })
                formComponentes.value = setC
                componentesDetalhes.value = detMap
                isProfessorNaoAplica.value = false
            }
        }
    } catch (err) {
        console.error('Erro detalhes:', err)
        errorMessage.value = 'Erro ao carregar dados do professor.'
    } finally {
        isLoading.value = false
    }
}

// init
watch(() => props.isOpen, async (newVal) => {
    if (newVal) {
        resetForm()
        
        // ALWAYS fetch auxiliary data (empty questions) - Legacy pattern
        await fetchAuxiliaryData()
        
        // If editing, load details and MERGE with the initialized formRespostas
        if (props.initialData) {
            await loadDetails(props.initialData.user_expandido_id || props.initialData.id)
        }
    }
})



const resetForm = () => {
    formDados.value = { nome_completo: '', email: '', telefone: '', matricula: '', status: 'Ativo' }
    formRespostas.value = {}
    formComponentes.value = new Set()
    componentesDetalhes.value = {}
    isProfessorNaoAplica.value = false
    activeTab.value = 'dados'
    errorMessage.value = ''
    isLoadingCep.value = false
}

// --- Logic ---
const handleCepInput = (e, pId) => {
    let val = e.target.value.replace(/\D/g, '')
    if (val.length > 8) val = val.slice(0, 8)
    let fmt = val
    if (val.length > 5) fmt = val.slice(0, 5) + '-' + val.slice(5)
    if (formRespostas.value[pId]) formRespostas.value[pId].resposta = fmt
    if (val.length === 8 && !isLoadingCep.value) fetchCep(val)
}

const fetchCep = async (cep) => {
    isLoadingCep.value = true
    try {
        const res = await fetch(`https://viacep.com.br/ws/${cep}/json/`)
        const data = await res.json()
        if (!data.erro) {
            const setAnswer = (slot, val) => {
                if (slot && formRespostas.value[slot.id]) formRespostas.value[slot.id].resposta = val
            }
            setAnswer(questionSlots.value.endereco, data.logradouro)
            setAnswer(questionSlots.value.bairro, data.bairro)
            setAnswer(questionSlots.value.cidade, data.localidade)
        }
    } catch(e) { console.error(e) } 
    finally { isLoadingCep.value = false }
}

const handleSave = async () => {
    if (!formDados.value.nome_completo) {
        errorMessage.value = 'Nome completo é obrigatório'
        return
    }
    isSaving.value = true
    errorMessage.value = ''
    try {
        const respostasArray = Object.keys(formRespostas.value).map(k => ({
            id_pergunta: k,
            resposta: formRespostas.value[k].resposta,
            tipo: formRespostas.value[k].tipo
        }))
        let componentesArray = []
        if (!isProfessorNaoAplica.value) {
            componentesArray = Array.from(formComponentes.value).map(id => {
                const d = componentesDetalhes.value[id] || {}
                return {
                    id_componente: id,
                    id_professor_componente: d.id_professor_componente,
                    ano_referencia: d.ano_referencia || new Date().getFullYear().toString()
                }
            })
        }
        const payload = {
            ...formDados.value,
            respostas: respostasArray,
            componentes: componentesArray
        }
        await $fetch('/api/usuarios/professores', {
            method: 'POST',
            body: { 
                data: payload, 
                id_empresa: appStore.company.empresa_id || appStore.company.id
            }
        })
        toast.showToast('Salvo com sucesso!', 'success')
        emit('success')
        emit('close')
    } catch (err) {
        console.error(err)
        errorMessage.value = err.data?.message || 'Erro ao salvar.'
    } finally {
        isSaving.value = false
    }
}

const toggleComponente = (id) => {
    if (isProfessorNaoAplica.value) return
    const s = new Set(formComponentes.value)
    if (s.has(id)) s.delete(id)
    else s.add(id)
    formComponentes.value = s
}
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-6">
        <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="emit('close')"></div>
        <div class="relative bg-background w-full max-w-4xl max-h-[90vh] flex flex-col rounded shadow-2xl border border-[#6B82A71A] overflow-hidden">
            
            <!-- Header -->
            <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between bg-div-15">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Professor' : 'Novo Professor' }}</h2>
                <button @click="emit('close')" class="p-2 rounded hover:bg-div-30"><span class="text-xl">×</span></button>
            </div>

            <!-- Tabs -->
             <div class="flex border-b border-[#6B82A71A] bg-div-15/50 overflow-x-auto">
                 <button v-for="t in ['dados', 'escola', 'endereco', 'componentes']" :key="t" @click="activeTab=t" 
                    class="px-6 py-3 text-sm font-bold capitalize transition-colors border-b-2 whitespace-nowrap"
                    :class="activeTab===t ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'"
                 >
                    {{ t }}
                 </button>
            </div>

            <!-- Body -->
            <div class="flex-1 overflow-y-auto p-6 relative">
                 <div v-if="isLoading" class="absolute inset-0 flex items-center justify-center bg-background/80 z-10"><div class="animate-spin text-3xl text-primary">◌</div></div>
                 
                 <div v-if="errorMessage" class="mb-4 p-3 bg-red-500/10 text-red-500 rounded text-sm">{{ errorMessage }}</div>

                 <!-- TABS CONTENT -->
                 <div v-show="activeTab === 'dados'" class="flex flex-col gap-4">
                     <div class="flex flex-col gap-1">
                         <label class="text-xs font-bold text-secondary uppercase">Nome Completo *</label>
                         <input v-model="formDados.nome_completo" class="input-theme" />
                     </div>
                     <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="flex flex-col gap-1">
                             <label class="text-xs font-bold text-secondary uppercase">CPF *</label>
                             <input v-if="questionSlots.cpf" :value="formRespostas[questionSlots.cpf.id]?.resposta" @input="e => formRespostas[questionSlots.cpf.id].resposta = formatCPF(e.target.value)" class="input-theme" placeholder="000.000.000-00"/>
                             <div v-else class="text-xs text-[#6B82A780]">Não configurado</div>
                        </div>
                        <div class="flex flex-col gap-1">
                             <label class="text-xs font-bold text-secondary uppercase">RG</label>
                             <input v-if="questionSlots.rg" v-model="formRespostas[questionSlots.rg.id].resposta" class="input-theme" />
                             <div v-else class="text-xs text-[#6B82A780]">Não configurado</div>
                        </div>
                     </div>
                     <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                         <div class="flex flex-col gap-1">
                             <label class="text-xs font-bold text-secondary uppercase">Nascimento</label>
                             <input v-if="questionSlots.nascimento" v-model="formRespostas[questionSlots.nascimento.id].resposta" type="date" class="input-theme" />
                         </div>
                         <div class="flex flex-col gap-1">
                             <label class="text-xs font-bold text-secondary uppercase">Gênero</label>
                             <select v-if="questionSlots.genero && questionSlots.genero.opcoes" v-model="formRespostas[questionSlots.genero.id].resposta" class="input-theme">
                                 <option value="" disabled>Selecione</option>
                                 <option v-for="o in questionSlots.genero.opcoes" :key="o" :value="o">{{ o }}</option>
                             </select>
                             <input v-else-if="questionSlots.genero" v-model="formRespostas[questionSlots.genero.id].resposta" class="input-theme" />
                         </div>
                     </div>
                     <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Telefone</label><input v-model="formDados.telefone" class="input-theme" placeholder="(00) 00000-0000"/></div>
                        <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Email</label><input v-model="formDados.email" class="input-theme" placeholder="email@exemplo.com"/></div>
                     </div>
                 </div>

                 <div v-show="activeTab === 'escola'" class="flex flex-col gap-4">
                     <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Matrícula</label><input v-model="formDados.matricula" class="input-theme" /></div>
                        <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Status</label>
                            <select v-model="formDados.status" class="input-theme">
                                <option>Ativo</option><option>Exonerado</option><option>Aposentado</option>
                            </select>
                        </div>
                     </div>
                     <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                         <div class="flex flex-col gap-1">
                             <label class="text-xs font-bold text-secondary uppercase">Admissão</label>
                             <input v-if="questionSlots.admissao" v-model="formRespostas[questionSlots.admissao.id].resposta" type="date" class="input-theme" />
                         </div>
                         <div class="flex flex-col gap-1">
                             <label class="text-xs font-bold text-secondary uppercase">Carga Horária</label>
                             <input v-if="questionSlots.horas_trabalho" v-model="formRespostas[questionSlots.horas_trabalho.id].resposta" class="input-theme" />
                         </div>
                     </div>

                     <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div v-if="questionSlots.habilitacao_infantil" class="flex flex-col gap-1">
                            <label class="text-xs font-bold text-secondary uppercase">{{ questionSlots.habilitacao_infantil.label || 'Habilitação Infantil' }}</label>
                            <select v-if="questionSlots.habilitacao_infantil.opcoes" v-model="formRespostas[questionSlots.habilitacao_infantil.id].resposta" class="input-theme">
                                <option v-for="o in questionSlots.habilitacao_infantil.opcoes" :key="o" :value="o">{{ o }}</option>
                            </select>
                        </div>
                        <div v-if="questionSlots.acumulo" class="flex flex-col gap-1">
                            <label class="text-xs font-bold text-secondary uppercase">{{ questionSlots.acumulo.label || 'Acúmulo' }}</label>
                             <select v-if="questionSlots.acumulo.opcoes" v-model="formRespostas[questionSlots.acumulo.id].resposta" class="input-theme">
                                 <option v-for="o in questionSlots.acumulo.opcoes" :key="o" :value="o">{{ o }}</option>
                             </select>
                        </div>
                     </div>

                     <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div v-if="questionSlots.afastamento" class="flex flex-col gap-1">
                            <label class="text-xs font-bold text-secondary uppercase">{{ questionSlots.afastamento.label || 'Afastamento' }}</label>
                            <select v-if="questionSlots.afastamento.opcoes" v-model="formRespostas[questionSlots.afastamento.id].resposta" class="input-theme">
                                <option v-for="o in questionSlots.afastamento.opcoes" :key="o" :value="o">{{ o }}</option>
                            </select>
                        </div>
                        <div v-if="questionSlots.tempo_afastamento" class="flex flex-col gap-1">
                            <label class="text-xs font-bold text-secondary uppercase">{{ questionSlots.tempo_afastamento.label || 'Tempo Afastamento' }}</label>
                            <select v-if="questionSlots.tempo_afastamento.opcoes" v-model="formRespostas[questionSlots.tempo_afastamento.id].resposta" class="input-theme">
                                <option v-for="o in questionSlots.tempo_afastamento.opcoes" :key="o" :value="o">{{ o }}</option>
                            </select>
                        </div>
                     </div>

                     <div v-if="questionSlots.tipo_contrato" class="flex flex-col gap-1">
                         <label class="text-xs font-bold text-secondary uppercase">{{ questionSlots.tipo_contrato.label || 'Tipo de Contrato' }}</label>
                         <select v-if="questionSlots.tipo_contrato.opcoes" v-model="formRespostas[questionSlots.tipo_contrato.id].resposta" class="input-theme">
                             <option v-for="o in questionSlots.tipo_contrato.opcoes" :key="o" :value="o">{{ o }}</option>
                         </select>
                     </div>

                     <!-- Dynamic Repeater for Other Questions -->
                     <div v-if="perguntasGerais.length > 0" class="pt-4 border-t border-[#6B82A71A] mt-4 flex flex-col gap-4">
                        <h3 class="text-xs font-bold text-secondary uppercase">Outras Informações</h3>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div v-for="p in perguntasGerais" :key="p.id" class="flex flex-col gap-1">
                                <label class="text-xs font-bold text-secondary uppercase">{{ p.label || p.pergunta }} <span v-if="p.obrigatorio" class="text-red-500">*</span></label>
                                <select v-if="p.tipo === 'opcao' || p.tipo === 'select' || p.tipo === 'select-multiple'" v-model="formRespostas[p.id].resposta" class="input-theme">
                                    <option value="" disabled>Selecione</option>
                                    <option v-for="o in p.opcoes" :key="o" :value="o">{{ o }}</option>
                                </select>
                                <input v-else-if="p.tipo === 'data'" type="date" v-model="formRespostas[p.id].resposta" class="input-theme" />
                                <input v-else v-model="formRespostas[p.id].resposta" class="input-theme" />
                            </div>
                        </div>
                    </div>
                 </div>

                 <div v-show="activeTab === 'endereco'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div class="flex flex-col gap-1 relative">
                          <label class="text-xs font-bold text-secondary uppercase">CEP</label>
                          <input v-if="questionSlots.cep" :value="formRespostas[questionSlots.cep.id]?.resposta" @input="e => handleCepInput(e, questionSlots.cep.id)" class="input-theme" placeholder="00000-000"/>
                          <span v-if="isLoadingCep" class="absolute right-2 top-6">⌛</span>
                      </div>
                      <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Bairro</label><input v-if="questionSlots.bairro" v-model="formRespostas[questionSlots.bairro.id].resposta" class="input-theme" readonly/></div>
                      <div class="col-span-2 flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Endereço</label><input v-if="questionSlots.endereco" v-model="formRespostas[questionSlots.endereco.id].resposta" class="input-theme" readonly/></div>
                      <div class="grid grid-cols-2 gap-4">
                          <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Número</label><input v-if="questionSlots.numero" v-model="formRespostas[questionSlots.numero.id].resposta" class="input-theme"/></div>
                          <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Complemento</label><input v-if="questionSlots.complemento" v-model="formRespostas[questionSlots.complemento.id].resposta" class="input-theme"/></div>
                      </div>
                      <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Cidade</label><input v-if="questionSlots.cidade" v-model="formRespostas[questionSlots.cidade.id].resposta" class="input-theme" readonly/></div>
                 </div>
                 
                 <div v-show="activeTab === 'componentes'" class="flex flex-col gap-4">
                     <label class="flex items-center gap-2 text-sm font-bold cursor-pointer">
                         <input type="checkbox" v-model="isProfessorNaoAplica" class="rounded text-primary focus:ring-primary" />
                         Não se aplica (Não leciona)
                     </label>
                     <div v-if="!isProfessorNaoAplica" class="grid grid-cols-1 md:grid-cols-2 gap-3 max-h-[300px] overflow-y-auto">
                         <div v-for="c in listaComponentes" :key="c.uuid" @click="toggleComponente(c.uuid)"
                            class="p-3 rounded border cursor-pointer hover:bg-div-30 flex items-center gap-2"
                            :class="formComponentes.has(c.uuid) ? 'border-primary bg-[#3571CB0D]' : 'border-[#6B82A733] bg-div-15'"
                         >
                            <div class="w-4 h-4 rounded border flex items-center justify-center" :class="formComponentes.has(c.uuid) ? 'bg-primary border-primary text-white' : 'border-secondary'">
                                <span v-if="formComponentes.has(c.uuid)" class="text-[10px]">✓</span>
                            </div>
                            <span class="text-sm font-medium">{{ c.nome }}</span>
                         </div>
                     </div>
                 </div>
            </div>

            <!-- Footer -->
            <div class="p-4 border-t border-[#6B82A71A] flex justify-end gap-3 bg-div-15">
                <button @click="emit('close')" class="px-4 py-2 text-xs font-bold text-secondary hover:text-text">Cancelar</button>
                <button @click="handleSave" :disabled="isSaving" class="px-6 py-2 bg-primary text-white rounded text-xs font-bold hover:brightness-110 disabled:opacity-50">
                    {{ isSaving ? 'Salvando...' : 'Salvar Professor' }}
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
