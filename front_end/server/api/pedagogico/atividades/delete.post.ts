import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const body = await readBody(event)

    if (!body.id || !body.id_empresa) {
        throw createError({ statusCode: 400, statusMessage: 'ID e ID Empresa obrigatórios' })
    }

    try {
        const { data, error } = await client.rpc('lms_conteudo_delete', {
            p_id: body.id,
            p_id_empresa: body.id_empresa
        })

        if (error) throw error
        return data
    } catch (e: any) {
        throw createError({
            statusCode: 500,
            statusMessage: e.message
        })
    }
})
