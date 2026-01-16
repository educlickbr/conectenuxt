import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const body = await readBody(event)
    const client = await serverSupabaseClient(event)

    // Map resource to RPC names for delete
    const rpcMap: Record<string, string> = {
        modelos: 'avaliacao_modelo_delete',
        grupos: 'avaliacao_grupo_delete',
        criterios: 'avaliacao_criterio_delete',
        itens_criterio: 'itens_criterio_delete',
        itens_avaliacao: 'itens_avaliacao_delete',
        assoc_ano_etapa: 'avaliacao_assoc_delete'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso desconhecido para exclusão: ${resource}`
        })
    }

    const { id, uuid, id_empresa } = body

    if (!id_empresa) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID da empresa é obrigatório para exclusão.'
        })
    }

    // Allow usage of 'id' or 'uuid' interchangeably from frontend
    const targetId = id || uuid

    if (!targetId) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID ou UUID é obrigatório para exclusão.'
        })
    }

    try {
        const params: any = {
            p_id_empresa: id_empresa,
            p_id: targetId
        }

        const { data, error } = await (client as any).rpc(rpcName, params)

        if (error) {
            console.error(`[API Avaliacao DELETE] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        if (data && data.status === 'error') {
            throw createError({
                statusCode: 400,
                statusMessage: 'Bad Request',
                message: data.message || `Erro ao excluir ${resource}.`
            })
        }

        return {
            success: true,
            data,
            message: data?.message || `${resource} excluído com sucesso.`
        }
    } catch (err: any) {
        console.error(`[API Avaliacao DELETE] Erro ao excluir ${resource}:`, err)
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.statusMessage || `Erro ao excluir ${resource}`
        })
    }
})
