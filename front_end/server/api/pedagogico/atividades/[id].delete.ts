
import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const id = getRouterParam(event, 'id')
    const { id_empresa } = getQuery(event)

    if (!id || !id_empresa) {
        throw createError({ statusCode: 400, statusMessage: 'ID e Empresa obrigatórios' })
    }

    const { error } = await client.rpc('lms_item_delete', {
        p_id: id,
        p_id_empresa: id_empresa
    } as any)

    if (error) {
        console.error('Delete item error:', error)
        throw createError({ statusCode: 500, statusMessage: error.message })
    }

    return { success: true }
})
