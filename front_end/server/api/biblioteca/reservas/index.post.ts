import { serverSupabaseClient } from '#supabase/server'

interface ReservasBody {
    action: 'deliver'
    id: string
    id_empresa: string
}

export default defineEventHandler(async (event) => {
    const body = await readBody<ReservasBody>(event)
    const client = await serverSupabaseClient(event)
    
    // Action handling
    const action = body.action

    if (action === 'deliver') {
        const { error } = await client.rpc('bbtk_reserva_release', {
            p_interacao_uuid: body.id
        } as any)

         if (error) {
            throw createError({
                statusCode: 500,
                statusMessage: error.message
            })
        }
        return { success: true }
    }

    throw createError({ statusCode: 400, statusMessage: 'Ação inválida' })
})
