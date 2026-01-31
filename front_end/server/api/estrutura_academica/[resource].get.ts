import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const sanitizeParam = (val: any) => {
        if (!val || val === 'null' || val === 'undefined' || val === '') return null
        return val
    }

    // Consolidated RPC Map
    const rpcMap: Record<string, string> = {
        classes: 'classe_get_paginado',
        ano_etapa: 'ano_etapa_get_paginado',
        horarios: 'horarios_escola_get_paginado',
        turmas: 'atrib_turmas_get_paginado', // UPDATED
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
        plano_itens_contexto: 'pl_plano_itens_get_by_contexto',
        plano_referencias: 'pl_plano_referencias_get_by_aula',
        
        // Grupos de Estudo
        grupos: 'grp_grupo_get_paginado', // NEW
        tutores: 'grp_tutores_get_paginado',
        integrantes: 'grp_integrantes_get_paginado',
        candidatos_tutores: 'grp_candidatos_tutores_get',
        candidatos_integrantes: 'grp_candidatos_integrantes_get',
        diario_validar_dia: 'diario_validar_dia'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso estrutura_academica desconhecido: ${resource}`
        })
    }

    // Auth & Company Validation
    const { data: { user }, error: authError } = await client.auth.getUser()
    if (authError || !user) {
        throw createError({ statusCode: 401, statusMessage: 'Unauthorized' })
    }

    // Company ID Logic
    // Prioritize query param for flexibility, fall back to user metadata if not present?
    // Or strictly force user metadata?
    // Existing code logic: "if (!id_empresa ... throw Error".
    // I will extract from query first as legacy code did: const id_empresa = query.id_empresa
    // But logically, we should try to use the session one if query is missing.
    // However, to minimize side effects on other resources, I will stick to query.id_empresa logic 
    // BUT I will inject it if missing and available in session.
    
    let id_empresa = query.id_empresa as string
    if (!id_empresa && user.user_metadata?.empresa_id) {
        id_empresa = user.user_metadata.empresa_id
    }

    if (!id_empresa && resource !== 'modelo_calendario') {
         throw createError({
            statusCode: 400,
            statusMessage: 'ID da empresa é obrigatório para esta consulta.'
        })
    }

    // Parameters Construction
    let rpcParams: any = {}

    if (resource === 'carga_horaria') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_id_ano_etapa: query.id_ano_etapa
        }
    } else if (resource === 'turmas') {
        const currentYear = new Date().getFullYear()
        rpcParams = {
            p_id_empresa: id_empresa,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
            p_id_ano_etapa: sanitizeParam(query.id_ano_etapa),
            p_id_escola: sanitizeParam(query.id_escola),
            p_id_classe: sanitizeParam(query.id_classe), 
            p_id_turma: sanitizeParam(query.id_turma),
            p_ano: 2026, // Hardcoded for testing as requested
            p_id_professor: sanitizeParam(query.id_professor)
        }
    } else if (resource === 'grupos') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
            p_ano: query.ano ? parseInt(query.ano as string) : null // Groups might care about year too?
        }
    } else if (resource === 'eventos') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
            p_id_ano_etapa: sanitizeParam(query.id_ano_etapa)
        }
    } else if (resource === 'modelo_calendario') {
        rpcParams = {}
    } else if (resource === 'matriz_curricular') {
        if (!query.id_turma) throw createError({ statusCode: 400, statusMessage: 'id_turma obrigatório' })
        rpcParams = {
            p_id_empresa: id_empresa,
            p_id_turma: query.id_turma
        }
    } else if (resource === 'turmas_simple') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_id_escola: sanitizeParam(query.id_escola),
            p_id_ano_etapa: sanitizeParam(query.id_ano_etapa),
            p_busca: (query.busca as string) || null
        }
    } else if (resource === 'calendarios') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
            p_id_ano_etapa: sanitizeParam(query.id_ano_etapa),
            p_id_escola: sanitizeParam(query.id_escola),
            p_modo_visualizacao: query.modo || 'Tudo'
        }
    } else if (resource === 'diario_aulas') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_id_turma: sanitizeParam(query.id_turma),
            p_id_componente: sanitizeParam(query.id_componente),
            p_data_inicio: query.data_inicio || null,
            p_data_fim: query.data_fim || null
        }
    } else if (resource === 'diario_presenca') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_id_turma: query.id_turma,
            p_data: query.data,
            p_id_componente: sanitizeParam(query.id_componente)
        }
    } else if (resource === 'plano_de_aulas_get_paginado') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
            p_id_ano_etapa: sanitizeParam(query.id_ano_etapa),
            p_id_componente: sanitizeParam(query.id_componente)
        }
    } else if (resource === 'plano_itens_get_by_plano') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_id_plano: query.id_plano
        }
    } else if (resource === 'plano_referencias') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_id_aula: query.id_aula
        }
    } else if (resource === 'plano_itens_contexto') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_id_componente: query.id_componente,
            p_id_ano_etapa: query.id_ano_etapa
        }
    } else if (resource === 'tutores' || resource === 'integrantes') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null,
            p_id_grupo: query.id_grupo
        }
    } else if (resource === 'candidatos_tutores' || resource === 'candidatos_integrantes') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_busca: (query.busca as string) || null,
            p_limit: parseInt(query.limite as string) || 20 
        }
    } else if (resource === 'diario_validar_dia') {
        rpcParams = {
            p_id_empresa: id_empresa,
            p_id_turma: query.id_turma,
            p_data: query.data
        }
    } else {
        // Generic fallback
        rpcParams = {
            p_id_empresa: id_empresa,
            p_pagina: parseInt(query.pagina as string) || 1,
            p_limite_itens_pagina: parseInt(query.limite as string) || 10,
            p_busca: (query.busca as string) || null
        }
    }

    // Call RPC
    try {
        const { data, error } = await (client as any).rpc(rpcName, rpcParams)

        if (error) {
            console.error(`[API Estrutura Acadêmica] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        let items: any[] = []
        let total = 0
        let pages = 0

        // Normalize Response
        if (Array.isArray(data)) {
            if (data.length > 0 && data[0].itens && typeof data[0].qtd_itens !== 'undefined') {
                 // JSON wrapped pattern
                 const result = data[0]
                 items = result.itens || []
                 total = result.qtd_itens || 0
                 pages = result.qtd_paginas || 0
            } else if (data.length > 0 && typeof data[0].total_registros !== 'undefined') {
                 // Table/View logic with count
                 items = data
                 total = Number(data[0].total_registros)
                 pages = Math.ceil(total / (parseInt(query.limite as string) || 10))
            } else if (data.length > 0 && data[0].total && data[0].items) {
                 // New JSON pattern (turmas) -> returns { items: [], total: N, pages: M }
                 // Wait, turmas query returns A SINGLE OBJECT in an array? Or just the object?
                 // SQL: RETURNS json. json_build_object.
                 // So client.rpc returns the object directly? or an array?
                 // Postgres functions returning JSON usually return the JSON value.
                 // If scalar, it might be data ignoring array.
                 // But let's handle if it is an array containing the json object.
                 const res = data[0]
                 items = res.items || []
                 total = res.total || 0
                 pages = res.pages || 0
            } else {
                 items = data
                 total = data.length
            }
        } else if (data && data.items) {
            // Direct object return (common for json scalar)
            items = data.items || []
            total = data.total || items.length
            pages = data.pages || 1
        } else if (data && data.itens) {
            items = data.itens || []
            total = data.qtd_itens || 0
            pages = data.qtd_paginas || 0
        }

        return {
            items,
            total,
            pages,
            resource
        }
    } catch (err: any) {
        console.error(`[API Estrutura Acadêmica] Erro ao processar ${resource}:`, err)
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.message || `Erro sistema ao tratar ${resource}`
        })
    }
})
