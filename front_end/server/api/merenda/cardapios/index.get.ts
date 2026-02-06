import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const query = getQuery(event)
    
    // Default to cardapio_grupo endpoint logic
    const { data, error } = await client.rpc('mrd_cardapio_grupo_get_paginado', {
        p_id_empresa: query.id_empresa,
        p_pagina: query.page ? parseInt(query.page as string) : 1,
        p_limite: query.limit ? parseInt(query.limit as string) : 10,
        p_busca: query.search || ''
    })

    if (error) {
        throw createError({
            statusCode: 500,
            message: error.message
        })
    }

    return data
})
