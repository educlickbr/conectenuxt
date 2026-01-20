import { serverSupabaseClient } from '#supabase/server'
import { serverSupabaseUser } from '#supabase/server'

interface CancelReservaBody {
    id_empresa: string
    edicao_uuid: string
}

export default defineEventHandler(async (event) => {
    const body = await readBody<CancelReservaBody>(event)
    const client = await serverSupabaseClient(event)
    const user = await serverSupabaseUser(event)

    if (!user) throw createError({ statusCode: 401, statusMessage: 'Unauthorized' })

    const { error } = await client.rpc('bbtk_reserva_cancel', {
        p_id_empresa: body.id_empresa,
        p_user_uuid: user.id,
        p_edicao_uuid: body.edicao_uuid
    } as any)

     if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: (error as any).message
        })
    }

    return { success: true }
})
