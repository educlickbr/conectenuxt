import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = event.context.params?.resource
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    // Map resources to RPCs
    const rpcMap: Record<string, string> = {
        editoras: 'bbtk_dim_editora_get_paginado',
        autoria: 'bbtk_dim_autoria_get_paginado',
        categoria: 'bbtk_dim_categoria_get_paginado',
        cdu: 'bbtk_dim_cdu_get_paginado',
        metadado: 'bbtk_dim_metadado_get_paginado',
        doador: 'bbtk_dim_doador_get_paginado'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: 'Recurso de catálogo inválido.'
        })
    }

    const { data, error } = await client.rpc(rpcName, {
        p_id_empresa: query.id_empresa,
        p_pagina: Number(query.page || 1),
        p_limite_itens_pagina: Number(query.limit || 10),
        p_busca: query.search || null
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    // RPCs return either [{ itens: [], ... }] or [ { itens: [], ... } ]
    const result = (Array.isArray(data) ? data[0] : data) as any 
    
    return {
        items: result?.itens || [],
        total: result?.qtd_itens || 0,
        pages: result?.qtd_paginas || 0
    } 
})
