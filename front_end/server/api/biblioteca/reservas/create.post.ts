import { serverSupabaseClient } from '#supabase/server'
import { serverSupabaseUser } from '#supabase/server'

interface CreateReservaBody {
    copia_uuid: string
    id_empresa: string
    data_inicio: string
}

export default defineEventHandler(async (event) => {
    const body = await readBody<CreateReservaBody>(event)
    const client = await serverSupabaseClient(event)
    const user = await serverSupabaseUser(event)
    
    if (!user) throw createError({ statusCode: 401, statusMessage: 'Unauthorized' })

    const { error } = await client.rpc('bbtk_reserva_create', {
        p_copia_uuid: body.copia_uuid,
        p_user_uuid: user.id,
        p_id_empresa: body.id_empresa,
        p_data_inicio: body.data_inicio
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: (error as any).message
        })
    }

    return { success: true }
})
