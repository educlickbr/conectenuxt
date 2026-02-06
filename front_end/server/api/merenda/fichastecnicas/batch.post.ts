import { serverSupabaseClient } from '#supabase/server'

interface Body {
    prato_id: string
    itens: any[] // Array of FichaTecnica Items
    id_empresa: string
}

export default defineEventHandler(async (event) => {
    const body = await readBody<Body>(event)
    const client = await serverSupabaseClient(event)

    const { data, error } = await client.rpc('mrd_ficha_tecnica_upsert_batch', {
        p_id_empresa: body.id_empresa,
        p_prato_id: body.prato_id,
        p_itens: body.itens
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return data
})
