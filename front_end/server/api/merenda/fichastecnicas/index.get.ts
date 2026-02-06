import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const query = getQuery(event)
    
    const { data, error } = await client.rpc('mrd_ficha_tecnica_get_all', {
        p_id_empresa: query.id_empresa
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            message: error.message
        })
    }

    return data
})
