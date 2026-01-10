import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const { id_empresa, id_aluno } = query

    console.log('[TEST DETALHES] Calling aluno_get_detalhes_cpx with:', { id_empresa, id_aluno })

    try {
        const { data, error } = await (client as any).rpc('aluno_get_detalhes_cpx', {
            p_id_empresa: id_empresa,
            p_id_aluno: id_aluno
        })

        console.log('[TEST DETALHES] Result:', {
            hasData: !!data,
            hasError: !!error,
            dataType: typeof data,
            errorMsg: error?.message
        })

        if (error) {
            throw error
        }

        return data
    } catch (err: any) {
        console.error('[TEST DETALHES] Error:', err)
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.message || 'Erro ao buscar detalhes do aluno'
        })
    }
})
