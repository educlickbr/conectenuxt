import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const query = getQuery(event)
    const { id_empresa, search } = query

    const { data, error } = await client.rpc('mrd_nutriente_get', {
        p_empresa_id: id_empresa,
        p_search: search || null
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return data
})
