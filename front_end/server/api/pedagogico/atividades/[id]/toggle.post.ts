
import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const id = getRouterParam(event, 'id')
    const body = await readBody(event)

    if (!id) {
        throw createError({ statusCode: 400, statusMessage: 'ID inválido' })
    }

    const { ativo } = body

    const { error } = await client.rpc('lms_item_ativar_desativar', {
        p_id: id,
        p_ativo: ativo
    } as any)

    if (error) {
        console.error('Toggle active error:', error)
        throw createError({ statusCode: 500, statusMessage: error.message })
    }

    return { success: true }
})
