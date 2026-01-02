import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    // Map resource to RPC names
    const rpcMap: Record<string, string> = {
        escolas: 'escolas_get_paginado',
        predios: 'bbtk_dim_predio_get_paginado',
        salas: 'bbtk_dim_sala_get_paginado',
        estantes: 'bbtk_dim_estante_get_paginado'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso desconhecido: ${resource}`
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
    const rpcParams: any = {
        p_id_empresa: id_empresa as string,
        p_pagina: parseInt(query.pagina as string) || 1,
        p_limite_itens_pagina: parseInt(query.limite as string) || 10,
        p_busca: (query.busca as string) || null
    }

    // Add specific filters if present
    if (query.id_escola) rpcParams.p_id_escola = query.id_escola
    if (query.predio_uuid) rpcParams.p_predio_uuid = query.predio_uuid
    if (query.sala_uuid) rpcParams.p_sala_uuid = query.sala_uuid

    try {
        const { data, error } = await (client as any).rpc(rpcName, rpcParams)

        if (error) {
            console.error(`[API Infra] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        // Normalize response
        // Many RPCs return an array with one object { itens, qtd_itens, qtd_paginas }
        const result = Array.isArray(data) ? data[0] : data

        return {
            items: result?.itens || [],
            total: result?.qtd_itens || 0,
            pages: result?.qtd_paginas || 0,
            resource
        }
    } catch (err: any) {
        console.error(`[API Infra] Erro ao processar ${resource}:`, err)
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.statusMessage || `Erro ao carregar dados de ${resource}`
        })
    }
})
