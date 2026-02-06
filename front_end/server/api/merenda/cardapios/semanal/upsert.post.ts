import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const body = await readBody(event)
    
    const { data, error } = await client.rpc('mrd_cardapio_semanal_upsert_batch', {
        p_id_empresa: body.id_empresa,
        p_cardapio_grupo_id: body.cardapio_grupo_id,
        p_ano: body.ano,
        p_semana_iso: body.semana_iso,
        p_itens: body.itens
    })

    if (error) {
        throw createError({
            statusCode: 500,
            message: error.message
        })
    }

    return { success: true, data }
})
