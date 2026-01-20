import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const id = event.context.params?.id
    const query = getQuery(event) // to get id_empresa
    const client = await serverSupabaseClient(event)

    // If id is 'new' or 'novo', pass null to RPC
    const uuid = (id === 'novo' || id === 'new') ? null : id

    const { data, error } = await client.rpc('bbtk_obra_get_detalhes_cpx', {
        p_uuid: uuid,
        p_id_empresa: query.id_empresa
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return data
})
