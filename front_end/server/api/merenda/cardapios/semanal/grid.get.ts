import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const query = getQuery(event)
    
    // Check required params
    if (!query.id_empresa || !query.cardapio_grupo_id || !query.ano || !query.semana_iso) {
        throw createError({ statusCode: 400, message: 'Parâmetros insuficientes' })
    }

    const { data, error } = await client.rpc('mrd_cardapio_semanal_get', {
        p_id_empresa: query.id_empresa,
        p_cardapio_grupo_id: query.cardapio_grupo_id,
        p_ano: parseInt(query.ano as string),
        p_semana_iso: parseInt(query.semana_iso as string)
    })

    if (error) {
        throw createError({
            statusCode: 500,
            message: error.message
        })
    }

    return data
})
