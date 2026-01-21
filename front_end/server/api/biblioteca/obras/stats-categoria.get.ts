import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)
    const id_empresa = query.id_empresa as string

    if (!id_empresa) {
        throw createError({
            statusCode: 400,
            statusMessage: 'Bad Request',
            message: 'id_empresa is required'
        })
    }

    const { data, error } = await client.rpc('bbtk_dashboard_get_obras_por_categoria', {
        p_id_empresa: id_empresa
    })

    if (error) {
        console.error('RPC Error bbtk_dashboard_get_obras_por_categoria:', error)
        throw createError({
            statusCode: 500,
            statusMessage: 'Database Error',
            message: error.message || 'Unknown RPC error'
        })
    }

    return data
})
