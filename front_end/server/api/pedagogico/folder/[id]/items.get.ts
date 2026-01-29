
import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const user = await client.auth.getUser()

    if (!user.data.user) {
        throw createError({
            statusCode: 401,
            statusMessage: 'Usuário não autenticado'
        })
    }

    const start_time = Date.now()
    const id = getRouterParam(event, 'id')
    const { id_empresa } = getQuery(event)

    if (!id || !id_empresa) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID do conteúdo e ID da empresa são obrigatórios'
        })
    }

    // Call RPC
    const { data, error } = await client.rpc('lms_itens_get', {
        p_id_empresa: id_empresa,
        p_user_id: user.data.user.id,
        p_conteudo_id: id
    } as any)

    if (error) {
        console.error('Error fetching items:', error)
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return {
        items: data || [],
        meta: {
            duration_ms: Date.now() - start_time
        }
    }
})
