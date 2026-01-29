import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const user = await serverSupabaseUser(event)
    const client = await serverSupabaseClient(event)
    const body = await readBody(event)

    if (!user) {
        throw createError({ statusCode: 401, statusMessage: 'Unauthorized' })
    }

    const { id_submissao, nota, comentario } = body

    if (!id_submissao) {
         throw createError({ statusCode: 400, statusMessage: 'ID Submissão is required' })
    }

    const { data, error } = await client.rpc('lms_submissao_avaliar', {
        p_id_submissao: id_submissao,
        p_nota: nota,
        p_comentario: comentario,
        p_user_id: user.id
    } as any)

    if (error) {
        throw createError({ statusCode: 500, statusMessage: error.message })
    }

    const result = data as any

    if (result?.status === 'error') {
         throw createError({ statusCode: 403, statusMessage: result.message })
    }

    return { success: true, message: result?.message }
})
