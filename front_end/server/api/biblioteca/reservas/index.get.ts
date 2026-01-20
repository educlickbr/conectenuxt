import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const limit = Number(query.limit || 10)
    const page = Number(query.page || 1)
    const offset = (page - 1) * limit

    const { data, error } = await client.rpc('bbtk_reserva_get_paginado', {
        p_id_empresa: query.id_empresa,
        p_offset: offset,
        p_limit: limit,
        p_filtro: query.search || null
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    const result = data as any

    return {
        items: result?.data || [],
        total: result?.total || 0,
        pages: Math.ceil((result?.total || 0) / limit)
    }
})
