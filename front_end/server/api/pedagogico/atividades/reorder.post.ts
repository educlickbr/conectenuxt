
import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const body = await readBody(event)
    const { items, id_empresa } = body

    if (!items || !id_empresa) {
        throw createError({ statusCode: 400, statusMessage: 'Bad Request' })
    }

    const { error } = await client.rpc('lms_item_reorder', {
        p_id_empresa: id_empresa,
        p_items: items
    } as any)

    if (error) {
        console.error('Reorder Error:', error)
        throw createError({ statusCode: 500, statusMessage: error.message })
    }

    return { success: true }
})
