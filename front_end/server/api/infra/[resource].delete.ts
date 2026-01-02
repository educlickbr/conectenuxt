import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const body = await readBody(event)
    const client = await serverSupabaseClient(event)

    // Map resource to RPC names for delete
    // Note: These RPCs might need verification if they exist or use a generic one
    const rpcMap: Record<string, string> = {
        escolas: 'escolas_delete',
        predios: 'bbtk_dim_predio_delete',
        salas: 'bbtk_dim_sala_delete',
        estantes: 'bbtk_dim_estante_delete'
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

    if (!id && !uuid) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID ou UUID é obrigatório para exclusão.'
        })
    }

    try {
        const params: any = { p_id_empresa: id_empresa }
        // The RPCs (bbtk_dim_sala_delete, etc.) expect 'p_id' regardless of whether we call it id or uuid in the frontend
        if (id) params.p_id = id
        else if (uuid) params.p_id = uuid

        const { data, error } = await (client as any).rpc(rpcName, params)

        if (error) {
            console.error(`[API Infra DELETE] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        // Check for logical error returned by RPC (JSONB)
        if (data && data.status === 'error') {
            throw createError({
                statusCode: 400,
                statusMessage: 'Band Request', // Keep header safe
                message: data.message || `Erro ao excluir ${resource}.` // Unicode message in body
            })
        }

        return {
            success: true,
            data,
            message: data?.message || `${resource} excluído com sucesso.`
        }
    } catch (err: any) {
        console.error(`[API Infra DELETE] Erro ao excluir ${resource}:`, err)

        // Se já for um erro H3 (gerado acima), repassa
        if (err.statusCode) {
            throw err
        }

        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: 'Internal Server Error',
            message: err.message || `Erro ao excluir ${resource}`
        })
    }
})
