import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    let data, error
    try {
        const response = await client.rpc('bbtk_obra_get_paginado', {
            p_id_empresa: query.id_empresa,
            p_pagina: Number(query.page || 1),
            p_limite_itens_pagina: Number(query.limit || 12),
            p_busca: query.search || null
        } as any)
        data = response.data
        error = response.error
    } catch (e: any) {
        console.error('RPC Error:', e)
        throw createError({
            statusCode: 500,
            statusMessage: 'Database Error',
            message: e.message || 'Unknown RPC error'
        })
    }

    if (error) {
        console.error('RPC Returned Error:', error)
        throw createError({
            statusCode: 500,
            statusMessage: 'Database Error',
            message: error.message || 'Error fetching data'
        })
    }

    const result = (Array.isArray(data) ? data[0] : data) as any
    
    // Get Base URL for images
    let imageBaseUrl = ''
    try {
        const { data: hashData, error: hashError } = await client.functions.invoke('hash_pasta_conecte', {
            body: { 
                path: '/biblio/',
                // we interpret user_id from the context if needed, but the client is already authenticated
            }
        })
        if (!hashError && hashData && hashData.url) {
            imageBaseUrl = hashData.url
        }
    } catch (e) {
        console.error('Error fetching image hash:', e)
    }
    
    return {
        items: result?.itens || [],
        total: result?.qtd_itens || 0,
        pages: result?.qtd_paginas || 0,
        imageBaseUrl
    }
})
