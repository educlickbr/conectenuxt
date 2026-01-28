
import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const id = getRouterParam(event, 'id')

    if (!id) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID é obrigatório'
        })
    }

    const { data, error } = await client.rpc('lms_item_get_detalhes', {
        p_id_item: id
    } as any)

    if (error) {
        console.error('Error fetching details:', error)
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return data
})
