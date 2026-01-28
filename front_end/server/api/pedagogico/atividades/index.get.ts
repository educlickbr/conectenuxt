import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const query = getQuery(event)

    // Params
    const id_empresa = query.id_empresa as string
    const page = parseInt(query.page as string || '1')
    const limit = parseInt(query.limit as string || '10')
    const search = query.search as string || null
    const escopo = query.escopo as string || null
    const id_turma = query.id_turma as string || null
    const id_aluno = query.id_aluno as string || null

    if (!id_empresa) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID Empresa inválido'
        })
    }

    try {
        const { data, error } = await client.rpc('lms_conteudo_get_paginado', {
            p_id_empresa: id_empresa,
            p_page: page,
            p_limit: limit,
            p_search: search,
            p_escopo: escopo,
            p_id_turma: id_turma,
            p_id_aluno: id_aluno
        } as any)

        if (error) throw error

        return data
    } catch (e: any) {
        throw createError({
            statusCode: 500,
            statusMessage: e.message
        })
    }
})
