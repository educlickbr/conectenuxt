import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    // Map resource to RPC names
    // Based on legacy system/schema analysis
    const rpcMap: Record<string, string> = {
        classes: 'classe_get_paginado',
        ano_etapa: 'ano_etapa_get_paginado',
        horarios: 'horarios_escola_get_paginado',
        turmas: 'turmas_get_paginado'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso educacional desconhecido: ${resource}`
        })
    }

    // Validation
    const id_empresa = query.id_empresa
    if (!id_empresa) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID da empresa é obrigatório para esta consulta.'
        })
    }

    // Prepare RPC parameters
    // Standard signature: (p_id_empresa, p_pagina, p_limite_itens_pagina, p_busca)
    const rpcParams: any = {
        p_id_empresa: id_empresa as string,
        p_pagina: parseInt(query.pagina as string) || 1,
        p_limite_itens_pagina: parseInt(query.limite as string) || 10,
        p_busca: (query.busca as string) || null
    }

    try {
        const { data, error } = await (client as any).rpc(rpcName, rpcParams)

        if (error) {
            console.error(`[API Educacional] Erro no RPC ${rpcName}:`, error)
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
        }

        return {
            items,
            total,
            pages,
            resource
        }

    } catch (err: any) {
        console.error(`[API Educacional] Erro ao processar ${resource}:`, err)
        // Differentiate Supabase errors from generic ones
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.message || `Erro ao carregar dados de ${resource}`
        })
    }
})
