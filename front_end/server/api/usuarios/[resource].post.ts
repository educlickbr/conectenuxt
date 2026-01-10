import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const body = await readBody(event)
    const client = await serverSupabaseClient(event)

    const rpcMap: Record<string, string> = {
        professores: 'professor_upsert',
        alunos: 'aluno_upsert',
        familias: 'familia_upsert',
        admins: 'admin_upsert' // Assuming this exists, need to verify legacy ModalGerenciarAdmin
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso desconhecido para escrita: ${resource}`
        })
    }

    try {
        // Prepare params
        // Most upserts take (p_data, p_id_empresa)
        const params = {
            p_data: body.data,
            p_id_empresa: body.id_empresa
        }

        const { data, error } = await (client as any).rpc(rpcName, params)

        if (error) throw error

        return { success: true, data }

    } catch (err: any) {
        console.error(`[API Users Post] Erro ao salvar ${resource}:`, err)
        throw createError({
            statusCode: 500,
            statusMessage: err.message || `Erro ao salvar ${resource}`
        })
    }
})
