import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const body = await readBody(event)
    
    // Pass etapas_ids to the updated RPC
    // Body structure from ModalCiclo: { id_empresa, data: {...}, etapas_ids: [...] }
    
    const { data, error } = await client.rpc('mrd_cardapio_grupo_upsert', {
        p_id_empresa: body.id_empresa,
        p_data: body.data,
        p_etapas_ids: body.etapas_ids || null
    })

    if (error) {
        throw createError({
            statusCode: 500,
            message: error.message
        })
    }

    return { success: true, data }
})
