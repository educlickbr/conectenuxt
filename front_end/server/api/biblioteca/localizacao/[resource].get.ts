import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = event.context.params?.resource
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const rpcMap: Record<string, string> = {
        escolas: 'escolas_com_predio_get', // Special case: might not need paginado or different sig
        predios: 'bbtk_dim_predio_get_paginado',
        salas: 'bbtk_dim_sala_get_paginado',
        estantes: 'bbtk_dim_estante_get_paginado'
    }

    const rpcName = rpcMap[resource as string]
    if (!rpcName) {
        throw createError({ statusCode: 400, statusMessage: 'Recurso de localização inválido.' })
    }

    // Build payload based on resource
    const payload: any = { p_id_empresa: query.id_empresa }

    if (resource === 'escolas') {
        // No extra params usually
    } else if (resource === 'predios') {
        payload.p_id_escola = query.parent_id
        payload.p_limite_itens_pagina = 100
    } else if (resource === 'salas') {
        payload.p_predio_uuid = query.parent_id
        payload.p_limite_itens_pagina = 100
    } else if (resource === 'estantes') {
        payload.p_sala_uuid = query.parent_id
        payload.p_limite_itens_pagina = 100
    }

    const { data, error } = await client.rpc(rpcName, payload as any)

    if (error) {
         throw createError({ statusCode: 500, statusMessage: error.message })
    }

    // Adapt response: escolas returns generic array, others return paginated object
    if (resource === 'escolas') {
        return data || []
    }
    
    // For paginated resources
    const result = (Array.isArray(data) ? data[0] : data) as any
    return result?.itens || []
})
