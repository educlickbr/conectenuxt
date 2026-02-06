import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const { data, error } = await client.rpc('mrd_ficha_tecnica_get_by_prato', {
        p_id_empresa: query.id_empresa,
        p_prato_id: query.prato_id
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return data
})
