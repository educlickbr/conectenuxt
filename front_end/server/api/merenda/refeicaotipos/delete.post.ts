import { serverSupabaseClient } from '#supabase/server'

interface Body {
    id: string
    id_empresa: string
}

export default defineEventHandler(async (event) => {
    const body = await readBody<Body>(event)
    const client = await serverSupabaseClient(event)

    const { error } = await client.rpc('mrd_refeicao_tipo_delete', {
        p_id: body.id,
        p_id_empresa: body.id_empresa
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return { success: true }
})
