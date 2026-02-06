import { serverSupabaseClient } from '#supabase/server'

interface Body {
    cardapio_grupo_id: string
    ano: number
    semana_iso: number
    itens: any[]
    id_empresa: string
}

export default defineEventHandler(async (event) => {
    const body = await readBody<Body>(event)
    const client = await serverSupabaseClient(event)

    const { data, error } = await client.rpc('mrd_cardapio_semanal_upsert_batch', {
        p_id_empresa: body.id_empresa,
        p_cardapio_grupo_id: body.cardapio_grupo_id,
        p_ano: body.ano,
        p_semana_iso: body.semana_iso,
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
