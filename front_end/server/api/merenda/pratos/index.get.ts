import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const { data, error } = await client.rpc('mrd_prato_get_paginado', {
        p_id_empresa: query.id_empresa,
        p_pagina: Number(query.page || 1),
        p_limite: Number(query.limit || 10),
        p_busca: query.search || ''
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return data
})
