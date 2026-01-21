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


    // Remove direct user_expandido lookup to rely on SQL function internal resolution
    // This avoids "Perfil de usuário não encontrado" errors due to client-side visibility issues

    const { error } = await client.rpc('bbtk_reserva_create', {
        p_copia_uuid: body.copia_uuid,
        p_id_empresa: body.id_empresa,
        p_data_inicio: body.data_inicio
    } as any)

    if (error) {
        console.error('RPC Error:', error)
        throw createError({
            statusCode: 500,
            statusMessage: (error as any).message || 'Erro ao realizar reserva'
        })
    }

    return { success: true }
})
