import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const { data, error } = await client.rpc('bbtk_reserva_stats', {
        p_id_empresa: query.id_empresa
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return data || { total: 0, no_prazo: 0, atrasadas: 0 }
})
