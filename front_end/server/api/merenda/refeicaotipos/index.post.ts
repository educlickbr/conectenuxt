import { serverSupabaseClient } from '#supabase/server'

interface Body {
    payload: any
    id_empresa: string
}

export default defineEventHandler(async (event) => {
    const body = await readBody<Body>(event)
    const client = await serverSupabaseClient(event)

    const { data, error } = await client.rpc('mrd_refeicao_tipo_upsert', {
        p_data: body.payload,
        p_id_empresa: body.id_empresa
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return data
})
