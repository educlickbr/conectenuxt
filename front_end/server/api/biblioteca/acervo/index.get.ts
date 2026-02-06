import { serverSupabaseClient } from '#supabase/server'
import { serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)
    const user = await serverSupabaseUser(event)

    const limit = Number(query.limit || 12)
    const page = Number(query.page || 1)
    
    // Legacy mapping uses p_pagina, not offset for this RPC
    const type = query.tipo || 'Digital'

    const { data, error } = await client.rpc('bbtk_edicao_get_paginado', {
        p_id_empresa: query.id_empresa,
        p_pagina: page,
        p_limite_itens_pagina: limit,
        p_termo_busca: query.search || null,
        p_tipo_livro: type,
        p_user_uuid: user?.id || null 
    } as any)

    if (error) {
         throw createError({
            statusCode: 500,
            statusMessage: (error as any).message
        })
    }

    const result = (Array.isArray(data) ? data[0] : data) as any

    // Get Base URL for images


    return {
        items: result?.itens || [],
        total: result?.qtd_itens || 0,
        pages: result?.qtd_paginas || 0,

    }
})
