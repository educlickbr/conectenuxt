import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const rpcMap: Record<string, string> = {
        matricula_turma: 'matricula_turma_get_historico',
        matriculas: 'matricula_get_paginado',
        atribuicao_turmas: 'atrib_turmas_get_paginado',
        atribuicao_componentes: 'atrib_componentes_get_paginado',
        alunos_turma: 'get_alunos_turma',
        diario_semanal: 'get_diario_semanal_aluno'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({ statusCode: 400, statusMessage: `Recurso secretaria GET desconhecido: ${resource}` })
    }

    const id_empresa = query.id_empresa

    // Validation based on resource
    if (!id_empresa && resource !== 'alunos_turma') { // alunos_turma only needs id_turma
        throw createError({ statusCode: 400, statusMessage: 'ID da empresa é obrigatório.' })
    }

    let rpcParams: any = {}

    if (resource === 'matricula_turma') {
        if (!query.id_matricula) throw createError({ statusCode: 400, statusMessage: 'ID da matrícula é obrigatório.' })
        rpcParams = {
            p_id_empresa: id_empresa,
            p_id_matricula: query.id_matricula
        }
    } else if (resource === 'alunos_turma') {
        if (!query.id_turma) throw createError({ statusCode: 400, statusMessage: 'ID da turma é obrigatório.' })
        rpcParams = {
            p_id_turma: query.id_turma
        }
    } else if (resource === 'diario_semanal') {
         if (!query.id_turma || !query.id_matricula || !query.data_inicio || !query.data_fim) {
            throw createError({ statusCode: 400, statusMessage: 'Faltam parâmetros para o diário semanal.' })
         }
         rpcParams = {
            p_id_empresa: id_empresa,
            p_id_turma: query.id_turma,
            p_id_matricula: query.id_matricula,
            p_data_inicio: query.data_inicio,
            p_data_fim: query.data_fim
         }
    } else if (resource === 'matriculas') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
        }
    } else if (resource === 'atribuicao_turmas' || resource === 'atribuicao_componentes') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
            p_id_turma: query.id_turma || null,
            p_id_professor: query.id_professor || null,
            p_ano: query.ano ? parseInt(query.ano as string) : new Date().getFullYear(),
            p_id_escola: query.id_escola || null,
            p_id_ano_etapa: query.id_ano_etapa || null,
            p_id_classe: query.id_classe || null
        }
    }


    try {
        const { data, error } = await (client as any).rpc(rpcName, rpcParams)

        if (error) throw error

        // Normalize response
        let items: any[] = []
        let total = 0
        let pages = 0

        // RPCs can return { itens: [...], qtd_itens: ... } OR just { itens: ... }
        // For matricula_turma, it returns json, so data IS the object containing 'itens'
        // We cast to any to be safe
        const result = (data as any) || {}

        if (Array.isArray(result)) {
            items = result
        } else {
            items = result.itens || result.items || []
        }

        // Calculate pagination if not explicitly returned
        if (result.qtd_itens !== undefined) {
            total = result.qtd_itens
            pages = result.qtd_paginas || 0
        } else {
            total = items.length
            pages = total > 0 ? 1 : 0
        }

        return {
            items,
            total,
            pages,
            resource,
            debug_info: result.debug_info // Pass through debug info if present
        }
    } catch (err: any) {
        throw createError({ statusCode: 500, statusMessage: err.message })
    }
})
