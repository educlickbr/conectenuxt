import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const body = await readBody(event)
    const client = await serverSupabaseClient(event)

    const rpcMap: Record<string, string> = {
        professores: 'professor_delete',
        alunos: 'aluno_delete',
        familias: 'familia_delete',
        admins: 'admin_delete'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso desconhecido: ${resource}`
        })
    }

    // Param mapping
    // professor_delete(p_id, p_id_empresa) -> id usually user_expandido_id for prof/aluno?
    // Legacy: 
    // prof: item.user_expandido_id
    // aluno: item.user_expandido_id
    // familia: item.id
    // admin: item.id

    // We expect the body to contain 'id' which is the correct ID for that type
    const rpcParams = {
        p_id: body.id,
        p_id_empresa: body.id_empresa
    }
    console.log(`[API Users Delete] Resource: ${resource}, Body ID: ${body.id}, Payload ID: ${rpcParams.p_id}, Empresa: ${rpcParams.p_id_empresa}`)

    try {
        const { error } = await (client as any).rpc(rpcName, rpcParams)

        if (error) {
            console.error(`[API Users Delete] Erro no RPC ${rpcName}:`, error)
            // Check for specific database errors if needed (integrity etc)
            throw error
        }

        return { success: true, debug: rpcParams }
    } catch (err: any) {
        console.error(`[API Users Delete] Erro ao deletar ${resource}:`, err)
        throw createError({
            statusCode: 500,
            statusMessage: err.message || `Erro ao excluir ${resource}`
        })
    }
})
