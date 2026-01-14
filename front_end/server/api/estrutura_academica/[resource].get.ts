import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const sanitizeParam = (val: any) => {
        if (!val || val === 'null' || val === 'undefined' || val === '') return null
        return val
    }

    // Map resource to RPC names
    // Based on legacy system/schema analysis
    // Map resource to RPC names
    // Based on legacy system/schema analysis
    const rpcMap: Record<string, string> = {
        classes: 'classe_get_paginado',
        ano_etapa: 'ano_etapa_get_paginado',
        horarios: 'horarios_escola_get_paginado',
        turmas: 'turmas_get_paginado',
        componentes: 'componente_get_paginado',
        carga_horaria: 'carga_horaria_get',
        feriados: 'mtz_feriados_get_paginado',
        eventos: 'mtz_eventos_get_paginado',
        modelo_calendario: 'mtz_modelo_calendario_get',
        matriz_curricular: 'mtz_matriz_curricular_get_by_turma',
        turmas_simple: 'turmas_get_simple',
        calendarios: 'mtz_calendario_anual_get_paginado',
        diario_aulas: 'diario_aula_get_paginado',
        diario_aulas_upsert: 'diario_aula_upsert',
        diario_presenca: 'diario_presenca_get_por_turma',
        diario_presenca_upsert: 'diario_presenca_upsert_batch',
        plano_de_aulas_get_paginado: 'pl_plano_de_aulas_get_paginado',
        plano_itens_get_by_plano: 'pl_plano_itens_get_by_plano',
        plano_referencias: 'pl_plano_referencias_get_by_aula'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso estrutura_academica desconhecido: ${resource}`
        })
    }

    // Validation
    const id_empresa = query.id_empresa
    if (!id_empresa && resource !== 'modelo_calendario') {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID da empresa é obrigatório para esta consulta.'
        })
    }

    // Prepare RPC parameters
    let rpcParams: any = {}

    if (resource === 'carga_horaria') {
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_id_ano_etapa: query.id_ano_etapa as string
        }
    } else if (resource === 'turmas') {
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
            p_id_ano_etapa: query.id_ano_etapa as string || null,
            p_ano: query.ano ? parseInt(query.ano as string) : null
        }
    } else if (resource === 'eventos') {
        // eventos needs p_id_ano_etapa optional
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
            p_id_ano_etapa: query.id_ano_etapa as string || null
        }
    } else if (resource === 'modelo_calendario') {
        rpcParams = {} // No parameters
    } else if (resource === 'matriz_curricular') {
        if (!query.id_turma) {
            throw createError({ statusCode: 400, statusMessage: 'id_turma obrigatório' })
        }
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_id_turma: query.id_turma as string
        }
    } else if (resource === 'turmas_simple') {
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_id_escola: sanitizeParam(query.id_escola),
            p_id_ano_etapa: sanitizeParam(query.id_ano_etapa)
        }
    } else if (resource === 'calendarios') {
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
            p_id_ano_etapa: sanitizeParam(query.id_ano_etapa),
            p_id_escola: sanitizeParam(query.id_escola),
            p_modo_visualizacao: query.modo || 'Tudo'
        }
    } else if (resource === 'diario_aulas') {
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_id_turma: sanitizeParam(query.id_turma),
            p_id_componente: sanitizeParam(query.id_componente),
            p_data_inicio: query.data_inicio || null,
            p_data_fim: query.data_fim || null
        }
    } else if (resource === 'diario_presenca') {
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_id_turma: query.id_turma as string,
            p_data: query.data as string,
            p_id_componente: sanitizeParam(query.id_componente)
        }
    } else if (resource === 'plano_de_aulas_get_paginado') {
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
            p_id_ano_etapa: sanitizeParam(query.id_ano_etapa),
            p_id_componente: sanitizeParam(query.id_componente)
        }
    } else if (resource === 'plano_itens_get_by_plano') {
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_id_plano: query.id_plano as string
        }
    } else if (resource === 'plano_referencias') {
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_id_aula: query.id_aula as string
        }
    } else {
        // Standard signature: (p_id_empresa, p_pagina, p_limite_itens_pagina, p_busca)
        rpcParams = {
            p_id_empresa: id_empresa as string,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null
        }
    }

    // Debug Auth and Params
    const { data: authData } = await client.auth.getUser()
    console.log(`[API Debug] Resource: ${resource}`)
    console.log(`[API Debug] User: ${authData.user?.id || 'ANON'}`)
    console.log(`[API Debug] RPC: ${rpcName}`)
    console.log(`[API Debug] Raw Query:`, JSON.stringify(query))
    console.log(`[API Debug] Params:`, JSON.stringify(rpcParams))

    try {
        const { data, error } = await (client as any).rpc(rpcName, rpcParams)

        if (error) {
            console.error(`[API Estrutura Acadêmica] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        // Normalize response
        // Handling both direct array return (if simplified) or legacy tuple style
        // RPCs ending in _get_paginado usually return a JSONB or Table that needs handling
        // Looking at schema: returns "json" (ano_etapa, horarios) or TABLE (classes, turmas)

        // If it returns JSON (common in this project's optimization), it might be wrapped
        // If it returns TABLE, Supabase checks return array of objects.

        let items: any[] = []
        let total = 0
        let pages = 0

        // Handle inconsistent return types if necessary
        // Assuming standard Supabase+Postgres behavior:
        if (Array.isArray(data)) {
            // Check if it's the "single object with itens array" pattern (common in JSON RPCs here)
            if (data.length > 0 && data[0].itens && typeof data[0].qtd_itens !== 'undefined') {
                // Format: [{ itens: [...], qtd_itens: X, qtd_paginas: Y }]
                const result = data[0]
                items = result.itens || []
                total = result.qtd_itens || 0
                pages = result.qtd_paginas || 0
            } else if (data.length > 0 && (data[0].total_registros !== undefined)) {
                // Table return with total_registros in every row
                items = data
                total = Number(data[0].total_registros)
                pages = Math.ceil(total / rpcParams.p_limite_itens_pagina)
            } else {
                // Just an array of items without pagination metadata embedded or empty
                items = data
                total = data.length // Fallback
            }
        } else if (data && data.itens) {
            // Direct object return
            items = data.itens || []
            total = data.qtd_itens || 0
            pages = data.qtd_paginas || 0
        } else if (data && data.items) {
            // Standardized 'items' return (e.g. from Matriz RPC)
            items = data.items || []
            total = items.length
            pages = 1
        }

        return {
            items,
            total,
            pages,
            resource
        }

    } catch (err: any) {
        console.error(`[API Estrutura Acadêmica] Erro ao processar ${resource}:`, err)
        // Differentiate Supabase errors from generic ones
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.message || `Erro ao carregar dados de ${resource}`
        })
    }
})
