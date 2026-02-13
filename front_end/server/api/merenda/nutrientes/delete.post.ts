import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const body = await readBody(event)
    const { id, id_empresa } = body

    const { data, error } = await client.rpc('mrd_nutriente_delete', {
        p_id: id,
        p_empresa_id: id_empresa
    })

    if (error) {
        return { success: false, message: error.message }
    }

    return data // Expected { success: true/false, message: '...' }
})
