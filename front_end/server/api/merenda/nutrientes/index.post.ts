import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const body = await readBody(event)
    const { id_empresa, payload } = body

    // Payload: { id, nome, unidade, active }

    const { data, error } = await client.rpc('mrd_nutriente_upsert', {
        p_id: payload.id || null,
        p_empresa_id: id_empresa,
        p_nome: payload.nome,
        p_unidade: payload.unidade,
        p_active: payload.active
    })

    if (error) {
        return { success: false, message: error.message }
    }

    return { success: true, data: data }
})
