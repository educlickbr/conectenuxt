import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const { data, error } = await client.rpc('bbtk_inventario_copia_get_paginado', {
        p_id_empresa: query.id_empresa,
        p_edicao_uuid: query.edicao_uuid,
        p_pagina: Number(query.page || 1),
        p_limite_itens_pagina: Number(query.limit || 50)
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    const result = (Array.isArray(data) ? data[0] : data) as any
    
    return {
        items: result?.itens || [],
        total: result?.qtd_itens || 0,
        pages: result?.qtd_paginas || 0
    }
})
