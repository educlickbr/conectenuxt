import { serverSupabaseClient, serverSupabaseServiceRole } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const { id_empresa, id_aluno } = query

    const results: any = {}

    // Test with regular client (anon key)
    const clientAnon = await serverSupabaseClient(event)
    const test1 = await (clientAnon as any).rpc('aluno_get_detalhes_cpx', {
        p_id_empresa: id_empresa,
        p_id_aluno: id_aluno
    })
    results.with_anon_key = {
        hasData: !!test1.data,
        data: test1.data,
        error: test1.error?.message
    }

    // Test with service role (bypasses RLS)
    const clientServiceRole = serverSupabaseServiceRole(event)
    const test2 = await (clientServiceRole as any).rpc('aluno_get_detalhes_cpx', {
        p_id_empresa: id_empresa,
        p_id_aluno: id_aluno
    })
    results.with_service_role = {
        hasData: !!test2.data,
        data: test2.data,
        error: test2.error?.message
    }

    return results
})
