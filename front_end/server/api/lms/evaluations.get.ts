import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const user = await serverSupabaseUser(event)
    const client = await serverSupabaseClient(event)
    const query = getQuery(event)
    
    // Validate User
    if (!user) {
        throw createError({
            statusCode: 401,
            statusMessage: 'Usuário não autenticado'
        })
    }

    // Default company ID (should be passed or inferred)
    const id_empresa = query.id_empresa as string

    if (!id_empresa) {
        throw createError({ statusCode: 400, statusMessage: 'ID Empresa is required' })
    }

    // Debug Log
    console.log('Fetching evaluations for:', {
        user_id: user.id,
        id_empresa,
        query
    })

    if (!user.id) {
        console.warn('User ID missing on server user object, relying on auth.uid() default.')
    }

    const { data, error } = await client.rpc('lms_avaliacoes_get', {
        p_id_empresa: id_empresa,
        p_user_id: user.id || undefined,
        p_filtro_status: (query.status as string) || null,
        p_filtro_turma_id: (query.turma_id as string) || null,
        p_filtro_aluno_id: (query.aluno_id as string) || null,
        p_filtro_escopo: (query.escopo as string) || null
    } as any)

    if (error) {
        console.error('Evaluations Get Error:', error)
        throw createError({ statusCode: 500, statusMessage: error.message })
    }

    return data
})
