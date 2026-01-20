import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const { data, error } = await client.rpc('bbtk_edicao_get_paginado', {
        p_id_empresa: query.id_empresa,
        p_pagina: Number(query.page || 1),
        p_limite_itens_pagina: Number(query.limit || 10),
        p_termo_busca: query.search || null,
        p_tipo_livro: query.tipo || 'Impresso'
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    const result = Array.isArray(data) ? data[0] : data as any
    
    return {
        items: result?.itens || [],
        total: result?.qtd_itens || 0,
        pages: result?.qtd_paginas || 0
    }
})
