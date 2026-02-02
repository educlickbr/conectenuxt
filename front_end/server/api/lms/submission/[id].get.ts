import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const user = await serverSupabaseUser(event)
    const client = await serverSupabaseClient(event)
    const id = getRouterParam(event, 'id')
    const query = getQuery(event)
    
    // Validate User
    if (!user) {
        throw createError({
            statusCode: 401,
            statusMessage: 'Usuário não autenticado'
        })
    }

    if (!id) {
        throw createError({ statusCode: 400, statusMessage: 'ID Submissão is required' }) 
    }

    // Default company ID (should be passed or inferred)
    const id_empresa = query.id_empresa as string

    if (!id_empresa) {
        throw createError({ statusCode: 400, statusMessage: 'ID Empresa is required' })
    }

    // Call RPC
    const { data, error } = await client.rpc('lms_get_submission_details', {
        p_id_submissao: id,
        p_id_empresa: id_empresa
    } as any)

    if (error) {
        console.error('Submission Details Error:', error)
        throw createError({ statusCode: 500, statusMessage: error.message })
    }

    if (!data) {
        throw createError({ statusCode: 404, statusMessage: 'Submissão não encontrada' })
    }

    return data
})
