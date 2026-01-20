import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const { data, error } = await client.rpc('bbtk_copias_disponiveis_get', {
        p_id_empresa: query.id_empresa,
        p_edicao_uuid: query.edicao_uuid
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: (error as any).message
        })
    }

    return data || []
})
