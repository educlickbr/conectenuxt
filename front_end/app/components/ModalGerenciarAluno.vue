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

// Form Data
const formDados = ref({
    nome_completo: '', email: '', telefone: '', matricula: '', status: 'Ativo'
})
const formRespostas = ref({})
const questionSlots = ref({
    ra: null, rg: null, cpf: null, nascimento: null, genero: null, etnia: null, celular: null, permite_sms: null,
    cep: null, endereco: null, numero: null, complemento: null, bairro: null, cidade: null, iptu: null, distrito: null,
    pai: null, mae: null, responsavel: null, tipo_responsavel: null,
    data_emissao_rg: null, orgao_emissor: null, cidade_rg: null,
    // Docs & Origem
    data_registro: null, tipo_registro: null, data_emissao_registro: null, lv: null,
    estrangeiro: null, nasceu_outro_pais: null, cidade_origem: null, obs_origem: null,
    documento_rne: null, data_emissao_rne: null, quilombola: null,
    // Familia extras
    tem_irmao: null, tem_gemeo: null, bolsa_familia: null, nis: null,
    // Saude
    mobilidade_reduzida: null, necessidades_especiais: null, desc_necessidades: null, cid: null, alergia: null,
    // Outros
    rm: null, matricula_judicial: null, obs_matricula_judicial: null
})
const perguntasGerais = ref([])

const PAPEL_ALUNO = ["b7f53d6e-70b5-453b-b564-728aeb4635d5"]

// Utils
const formatCPF = (v) => {
    v = v.replace(/\D/g, "")
    if (v.length > 11) v = v.slice(0, 11)
    return v.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4")
}

const categorizeQuestions = (perguntas) => {
    console.log('[ModalAluno] Categorizing', perguntas?.length || 0, 'questions')
    const slots = {
        ra: null, rg: null, cpf: null, nascimento: null, genero: null, etnia: null, celular: null, permite_sms: null,
        cep: null, endereco: null, numero: null, complemento: null, bairro: null, cidade: null, iptu: null, distrito: null,
        pai: null, mae: null, responsavel: null, tipo_responsavel: null,
        data_emissao_rg: null, orgao_emissor: null, cidade_rg: null,
        data_registro: null, tipo_registro: null, data_emissao_registro: null, lv: null,
        estrangeiro: null, nasceu_outro_pais: null, cidade_origem: null, obs_origem: null,
        documento_rne: null, data_emissao_rne: null, quilombola: null,
        tem_irmao: null, tem_gemeo: null, bolsa_familia: null, nis: null,
        mobilidade_reduzida: null, necessidades_especiais: null, desc_necessidades: null, cid: null, alergia: null,
        rm: null, matricula_judicial: null, obs_matricula_judicial: null
    }

    const gerais = []
    
    if (!perguntas) return

    perguntas.forEach(p => {
        const text = (p.label || p.pergunta || '').toLowerCase()

        if (text.includes('ra')) slots.ra = p
        else if (text.includes('rg') && !text.includes('emissão') && !text.includes('cidade') && !text.includes('órgão')) slots.rg = p
        else if (text.includes('cpf')) slots.cpf = p
        else if (text.includes('nascimento')) slots.nascimento = p
        else if (text.includes('gênero') || text.includes('genero')) slots.genero = p
        else if (text.includes('etnia')) slots.etnia = p
        else if (text.includes('celular') || text.includes('telefone')) slots.celular = p
        else if (text.includes('cep')) slots.cep = p
        else if (text.includes('endereço') || text.includes('endereco') || text.includes('logradouro')) slots.endereco = p
        else if (text.includes('número') || text.includes('numero')) slots.numero = p
        else if (text.includes('complemento')) slots.complemento = p
        else if (text.includes('bairro')) slots.bairro = p
        else if (text.includes('cidade') && !text.includes('rg') && !text.includes('origem')) slots.cidade = p
        
        else if (text.includes('pai')) slots.pai = p
        else if (text.includes('mãe') || text.includes('mae')) slots.mae = p
        else if (text.includes('tipo') && text.includes('responsável')) slots.tipo_responsavel = p
        else if (text.includes('responsável') || text.includes('responsavel')) slots.responsavel = p
        
        else if (text.includes('bolsa') && text.includes('família')) slots.bolsa_familia = p
        else if (text.includes('nis')) slots.nis = p
        else if (text.includes('mobilidade')) slots.mobilidade_reduzida = p
        else if (text.includes('descrição') && text.includes('necessidades')) slots.desc_necessidades = p
        else if (text.includes('necessidades')) slots.necessidades_especiais = p
        else if (text.includes('cid')) slots.cid = p
        else if (text.includes('alergia')) slots.alergia = p
        
        else if (text.includes('emissão') && text.includes('rg')) slots.data_emissao_rg = p
        else if (text.includes('emissor')) slots.orgao_emissor = p
        else if (text.includes('cidade') && text.includes('rg')) slots.cidade_rg = p
        
        else if (text.includes('data') && text.includes('registro')) slots.data_registro = p
        else if (text.includes('tipo') && text.includes('registro')) slots.tipo_registro = p
        else if (text.includes('emissão') && text.includes('registro')) slots.data_emissao_registro = p
        else if (text.includes('livro') || text.includes('folha') || text.includes('lv')) slots.lv = p
        else if (text.includes('estrangeiro')) slots.estrangeiro = p
        else if (text.includes('nasceu') && text.includes('outro')) slots.nasceu_outro_pais = p
        else if (text.includes('cidade') && text.includes('origem')) slots.cidade_origem = p
        else if (text.includes('obs') && text.includes('origem')) slots.obs_origem = p
        else if (text.includes('rne')) {
             if (text.includes('data') || text.includes('emissão')) slots.data_emissao_rne = p
             else slots.documento_rne = p
        }
        else if (text.includes('quilombola')) slots.quilombola = p
        else if (text.includes('irmão') || text.includes('irmao')) slots.tem_irmao = p
        else if (text.includes('gêmeo') || text.includes('gemeo')) slots.tem_gemeo = p
        else if (text.includes('rm')) slots.rm = p
        else if (text.includes('obs') && text.includes('judicial')) slots.obs_matricula_judicial = p
        else if (text.includes('judicial')) slots.matricula_judicial = p
        else gerais.push(p)
    })
    
    questionSlots.value = slots
    perguntasGerais.value = gerais
    console.log('[ModalAluno] Slots assigned:', Object.keys(slots).filter(k => slots[k]).join(', '))
}

// Fetching
const fetchAuxiliaryData = async () => {
    isLoading.value = true
    try {
        let perguntas = props.preloadedQuestions
        
        if (!perguntas || perguntas.length === 0) {
            console.log('[ModalAluno] No preloaded data, fetching...')
            const companyId = appStore.company?.empresa_id || appStore.company?.id
            if (!companyId) return
            const p = await $fetch('/api/usuarios/auxiliar', {
                query: { type: 'perguntas', id_empresa: companyId, papeis: PAPEL_ALUNO.join(',') }
            })
            perguntas = p
        } else {
             console.log('[ModalAluno] Using preloaded data. Count:', perguntas?.length)
        }

        if (perguntas && perguntas.length > 0) {
            console.table(perguntas.map(p => ({ slug: p.pergunta, label: p.label, tipo: p.tipo })))
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
        
    } catch(e) {
        console.error(e)
        errorMessage.value = 'Erro ao carregar formulário.'
    } finally {
        isLoading.value = false
    }
}

const loadDetails = async (id) => {
    isLoading.value = true
    try {
        const data = await $fetch(`/api/usuarios/alunos/detalhes/${id}`, {
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
                console.log('[ModalAluno] Got', data.respostas.length, 'questions with answers from BFF')
                
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
        }
    } catch(e){
        console.error(e)
        errorMessage.value = 'Erro ao carregar dados do aluno.'
    } finally {
        isLoading.value = false
    }
}

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
    activeTab.value = 'dados'
    errorMessage.value = ''
    isLoadingCep.value = false
}

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
    } catch(e) {} 
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
        const payload = {
            ...formDados.value,
            respostas: respostasArray
        }
        await $fetch('/api/usuarios/alunos', {
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
</script>

<template>
    <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-6">
        <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" @click="emit('close')"></div>
        <div class="relative bg-background w-full max-w-4xl max-h-[90vh] flex flex-col rounded shadow-2xl border border-[#6B82A71A] overflow-hidden">
            
            <div class="px-6 py-4 border-b border-[#6B82A71A] flex items-center justify-between bg-div-15" @click.stop="">
                <h2 class="text-xl font-bold text-text">{{ initialData ? 'Editar Aluno' : 'Novo Aluno' }}</h2>
                <button @click="emit('close')" class="p-2 rounded hover:bg-div-30"><span class="text-xl">×</span></button>
            </div>

             <div class="flex border-b border-[#6B82A71A] bg-div-15/50 overflow-x-auto">
                 <button v-for="t in ['dados', 'familia', 'endereco', 'documentos', 'saude', 'outros']" :key="t" @click="activeTab=t" 
                    class="px-6 py-3 text-sm font-bold capitalize transition-colors border-b-2 whitespace-nowrap"
                    :class="activeTab===t ? 'border-primary text-primary' : 'border-transparent text-secondary hover:text-text'"
                 >
                    {{ t }}
                 </button>
            </div>

            <div class="flex-1 overflow-y-auto p-6 relative">
                 <div v-if="isLoading" class="absolute inset-0 flex items-center justify-center bg-background/80 z-10"><div class="animate-spin text-3xl text-primary">◌</div></div>
                 <div v-if="errorMessage" class="mb-4 p-3 bg-red-500/10 text-red-500 rounded text-sm">{{ errorMessage }}</div>

                 <!-- DADOS -->
                 <div v-show="activeTab === 'dados'" class="flex flex-col gap-4">
                     <div class="flex flex-col gap-1">
                         <label class="text-xs font-bold text-secondary uppercase">Nome Completo *</label>
                         <input v-model="formDados.nome_completo" class="input-theme" />
                     </div>
                      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                         <div class="flex flex-col gap-1">
                             <label class="text-xs font-bold text-secondary uppercase">RA</label>
                             <input v-if="questionSlots.ra" v-model="formRespostas[questionSlots.ra.id].resposta" class="input-theme" />
                             <div v-else class="text-xs text-[#6B82A780]">Não configurado</div>
                         </div>
                         <div class="flex flex-col gap-1">
                             <label class="text-xs font-bold text-secondary uppercase">CPF</label>
                             <input v-if="questionSlots.cpf" :value="formRespostas[questionSlots.cpf.id]?.resposta" @input="e => formRespostas[questionSlots.cpf.id].resposta = formatCPF(e.target.value)" class="input-theme" placeholder="000.000.000-00"/>
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
                          <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Email</label><input v-model="formDados.email" class="input-theme" placeholder="email@exemplo.com"/></div>
                          <div class="flex flex-col gap-1">
                              <label class="text-xs font-bold text-secondary uppercase">Celular / Telefone</label>
                              <input v-if="questionSlots.celular" v-model="formRespostas[questionSlots.celular.id].resposta" class="input-theme" placeholder="(00) 00000-0000"/>
                              <input v-else v-model="formDados.telefone" class="input-theme" placeholder="(00) 00000-0000"/>
                         </div>
                     </div>
                 </div>
                 
                 <!-- FAMILIA -->
                 <div v-show="activeTab === 'familia'" class="flex flex-col gap-4">
                     <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Mãe</label><input v-if="questionSlots.mae" v-model="formRespostas[questionSlots.mae.id].resposta" class="input-theme" /></div>
                        <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Pai</label><input v-if="questionSlots.pai" v-model="formRespostas[questionSlots.pai.id].resposta" class="input-theme" /></div>
                        
                        <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Responsável</label><input v-if="questionSlots.responsavel" v-model="formRespostas[questionSlots.responsavel.id].resposta" class="input-theme" /></div>
                        <div class="flex flex-col gap-1">
                            <label class="text-xs font-bold text-secondary uppercase">Tipo Responsável</label>
                            <select v-if="questionSlots.tipo_responsavel && questionSlots.tipo_responsavel.opcoes" v-model="formRespostas[questionSlots.tipo_responsavel.id].resposta" class="input-theme">
                                <option value="" disabled>Selecione</option>
                                <option v-for="o in questionSlots.tipo_responsavel.opcoes" :key="o" :value="o">{{ o }}</option>
                            </select>
                        </div>
                     </div>
                     <div class="grid grid-cols-1 md:grid-cols-3 gap-4 border-t border-[#6B82A71A] pt-4">
                         <div v-if="questionSlots.bolsa_familia" class="flex flex-col gap-1">
                             <label class="text-xs font-bold text-secondary uppercase">Bolsa Família?</label>
                              <select v-if="questionSlots.bolsa_familia.opcoes" v-model="formRespostas[questionSlots.bolsa_familia.id].resposta" class="input-theme">
                                <option v-for="o in questionSlots.bolsa_familia.opcoes" :key="o" :value="o">{{ o }}</option>
                            </select>
                         </div>
                         <div v-if="questionSlots.nis" class="flex flex-col gap-1">
                             <label class="text-xs font-bold text-secondary uppercase">NIS</label>
                             <input v-model="formRespostas[questionSlots.nis.id].resposta" class="input-theme" />
                         </div>
                     </div>
                 </div>

                 <!-- ENDERECO -->
                 <div v-show="activeTab === 'endereco'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                       <div class="flex flex-col gap-1 relative">
                           <label class="text-xs font-bold text-secondary uppercase">CEP</label>
                           <input v-if="questionSlots.cep" :value="formRespostas[questionSlots.cep.id]?.resposta" @input="e => handleCepInput(e, questionSlots.cep.id)" class="input-theme" placeholder="00000-000"/>
                           <span v-if="isLoadingCep" class="absolute right-2 top-6">⌛</span>
                       </div>
                       <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Cidade</label><input v-if="questionSlots.cidade" v-model="formRespostas[questionSlots.cidade.id].resposta" class="input-theme" readonly/></div>
                       <div class="col-span-2 flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Endereço</label><input v-if="questionSlots.endereco" v-model="formRespostas[questionSlots.endereco.id].resposta" class="input-theme" readonly/></div>
                       <div class="grid grid-cols-2 gap-4 col-span-2">
                         <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Número</label><input v-if="questionSlots.numero" v-model="formRespostas[questionSlots.numero.id].resposta" class="input-theme"/></div>
                         <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Complemento</label><input v-if="questionSlots.complemento" v-model="formRespostas[questionSlots.complemento.id].resposta" class="input-theme"/></div>
                       </div>
                       <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Bairro</label><input v-if="questionSlots.bairro" v-model="formRespostas[questionSlots.bairro.id].resposta" class="input-theme" readonly/></div>
                 </div>

                  <!-- DOCUMENTOS -->
                  <div v-show="activeTab === 'documentos'" class="flex flex-col gap-6">
                      <!-- RG -->
                      <div class="flex flex-col gap-3">
                          <h3 class="text-sm font-bold text-primary border-b border-[#3571CB33] pb-1">Identidade (RG)</h3>
                          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                               <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">RG</label><input v-if="questionSlots.rg" v-model="formRespostas[questionSlots.rg.id].resposta" class="input-theme"/></div>
                               <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Emissão RG</label><input v-if="questionSlots.data_emissao_rg" type="date" v-model="formRespostas[questionSlots.data_emissao_rg.id].resposta" class="input-theme"/></div>
                               <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Órgão Emissor</label><input v-if="questionSlots.orgao_emissor" v-model="formRespostas[questionSlots.orgao_emissor.id].resposta" class="input-theme"/></div>
                               <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Cidade RG</label><input v-if="questionSlots.cidade_rg" v-model="formRespostas[questionSlots.cidade_rg.id].resposta" class="input-theme"/></div>
                          </div>
                      </div>
                      
                      <!-- Certidao -->
                       <div class="flex flex-col gap-3">
                           <h3 class="text-sm font-bold text-primary border-b border-primary/20 pb-1">Certidão / Registro</h3>
                           <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                               <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Tipo Registro</label><input v-if="questionSlots.tipo_registro" v-model="formRespostas[questionSlots.tipo_registro.id].resposta" class="input-theme"/></div>
                               <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Data Registro</label><input v-if="questionSlots.data_registro" type="date" v-model="formRespostas[questionSlots.data_registro.id].resposta" class="input-theme"/></div>
                               <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Data Emissão</label><input v-if="questionSlots.data_emissao_registro" type="date" v-model="formRespostas[questionSlots.data_emissao_registro.id].resposta" class="input-theme"/></div>
                               <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Livro/Folha (LV)</label><input v-if="questionSlots.lv" v-model="formRespostas[questionSlots.lv.id].resposta" class="input-theme"/></div>
                           </div>
                       </div>

                       <!-- Estrangeiro -->
                        <div class="flex flex-col gap-3">
                           <h3 class="text-sm font-bold text-primary border-b border-primary/20 pb-1">Origem</h3>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                               <div class="flex flex-col gap-1" v-if="questionSlots.estrangeiro">
                                    <label class="text-xs font-bold text-secondary uppercase">Estrangeiro?</label>
                                    <select v-if="questionSlots.estrangeiro.opcoes" v-model="formRespostas[questionSlots.estrangeiro.id].resposta" class="input-theme">
                                        <option v-for="o in questionSlots.estrangeiro.opcoes" :key="o" :value="o">{{ o }}</option>
                                    </select>
                               </div>
                               <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Cidade Origem</label><input v-if="questionSlots.cidade_origem" v-model="formRespostas[questionSlots.cidade_origem.id].resposta" class="input-theme"/></div>
                            </div>
                        </div>
                  </div>

                  <!-- SAUDE -->
                  <div v-show="activeTab === 'saude'" class="flex flex-col gap-4">
                      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                          <div class="flex flex-col gap-1" v-if="questionSlots.mobilidade_reduzida">
                                <label class="text-xs font-bold text-secondary uppercase">Mobilidade Reduzida?</label>
                                <select v-if="questionSlots.mobilidade_reduzida.opcoes" v-model="formRespostas[questionSlots.mobilidade_reduzida.id].resposta" class="input-theme">
                                    <option v-for="o in questionSlots.mobilidade_reduzida.opcoes" :key="o" :value="o">{{ o }}</option>
                                </select>
                           </div>
                           <div class="flex flex-col gap-1" v-if="questionSlots.necessidades_especiais">
                                <label class="text-xs font-bold text-secondary uppercase">Necessidades Especiais?</label>
                                <select v-if="questionSlots.necessidades_especiais.opcoes" v-model="formRespostas[questionSlots.necessidades_especiais.id].resposta" class="input-theme">
                                    <option v-for="o in questionSlots.necessidades_especiais.opcoes" :key="o" :value="o">{{ o }}</option>
                                </select>
                           </div>
                           <div class="flex flex-col gap-1 md:col-span-2"><label class="text-xs font-bold text-secondary uppercase">Descrição Necessidades</label><input v-if="questionSlots.desc_necessidades" v-model="formRespostas[questionSlots.desc_necessidades.id].resposta" class="input-theme"/></div>
                           <div class="flex flex-col gap-1 md:col-span-2"><label class="text-xs font-bold text-secondary uppercase">Alergias</label><input v-if="questionSlots.alergia" v-model="formRespostas[questionSlots.alergia.id].resposta" class="input-theme"/></div>
                      </div>
                  </div>

                  <!-- OUTROS -->
                  <div v-show="activeTab === 'outros'" class="flex flex-col gap-4">
                      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                          <div class="flex flex-col gap-1"><label class="text-xs font-bold text-secondary uppercase">Status</label>
                            <select v-model="formDados.status" class="input-theme">
                                <option>Ativo</option><option>Inativo</option><option>Transferido</option><option>Evadido</option>
                            </select>
                          </div>
                      </div>
                       <div v-if="questionSlots.matricula_judicial" class="flex flex-col gap-1">
                            <label class="text-xs font-bold text-secondary uppercase">Matrícula Judicial?</label>
                            <select v-if="questionSlots.matricula_judicial.opcoes" v-model="formRespostas[questionSlots.matricula_judicial.id].resposta" class="input-theme">
                                <option v-for="o in questionSlots.matricula_judicial.opcoes" :key="o" :value="o">{{ o }}</option>
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

            </div>

            <div class="p-4 border-t border-[#6B82A71A] flex justify-end gap-3 bg-div-15">
                <button @click="emit('close')" class="px-4 py-2 text-xs font-bold text-secondary hover:text-text">Cancelar</button>
                <button @click="handleSave" :disabled="isSaving" class="px-6 py-2 bg-primary text-white rounded text-xs font-bold hover:brightness-110 disabled:opacity-50">
                    {{ isSaving ? 'Salvando...' : 'Salvar Aluno' }}
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
