import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const body = await readBody(event)
    const client = await serverSupabaseClient(event)

    const rpcMap: Record<string, string> = {
        matriculas: 'matricula_delete'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso secretaria desconhecido: ${resource}`
        })
    }

    try {
        const { data, error } = await (client as any).rpc(rpcName, {
            p_id: body.id,
            p_id_empresa: body.id_empresa
        })

        if (error) {
            console.error(`[API Secretaria] Erro ao deletar ${resource}:`, error)
            throw error
        }

        return {
            success: data.status === 'success',
            message: data.message,
            id: data.id
        }

    } catch (err: any) {
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.message || `Erro ao deletar ${resource}`
        })
    }
})
