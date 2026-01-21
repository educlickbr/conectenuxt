import { serverSupabaseClient } from '#supabase/server'
import { serverSupabaseUser } from '#supabase/server'

interface DeliverBody {
    reserva_uuid: string
    id_empresa: string
}

export default defineEventHandler(async (event) => {
    const body = await readBody<DeliverBody>(event)
    const client = await serverSupabaseClient(event)
    const user = await serverSupabaseUser(event)

    if (!user) throw createError({ statusCode: 401, statusMessage: 'Unauthorized' })

    const { error } = await client.rpc('bbtk_reserva_entregar', {
        p_reserva_uuid: body.reserva_uuid,
        p_id_empresa: body.id_empresa
    } as any)

    if (error) {
        console.error('[Reserva] Error delivering book:', error)
        throw createError({
            statusCode: 500,
            statusMessage: error.message || 'Erro ao realizar entrega.'
        })
    }

    return { success: true }
})
