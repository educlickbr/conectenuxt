import { serverSupabaseClient } from '#supabase/server'

interface Body {
    cardapio_grupo_id: string
    ano_etapa_ids: string[]
    id_empresa: string
}

export default defineEventHandler(async (event) => {
    const body = await readBody<Body>(event)
    const client = await serverSupabaseClient(event)

    const { data, error } = await client.rpc('mrd_cardapio_etapa_link', {
        p_id_empresa: body.id_empresa,
        p_cardapio_grupo_id: body.cardapio_grupo_id,
        p_ano_etapa_ids: body.ano_etapa_ids
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return data
})
