import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const body = await readBody(event)
    const client = await serverSupabaseClient(event)

    // Map resource to RPC names for upsert
    const rpcMap: Record<string, string> = {
        escolas: 'escolas_upsert',
        predios: 'bbtk_dim_predio_upsert',
        salas: 'bbtk_dim_sala_upsert',
        estantes: 'bbtk_dim_estante_upsert'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso desconhecido para salvamento: ${resource}`
        })
    }

    // Validation
    const id_empresa = body.id_empresa
    const payload = body.data

    if (!id_empresa) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID da empresa é obrigatório para salvar registros.'
        })
    }

    if (!payload) {
        throw createError({
            statusCode: 400,
            statusMessage: 'Dados (payload) não fornecidos para salvamento.'
        })
    }

    try {
        const { data, error } = await (client as any).rpc(rpcName, {
            p_data: payload,
            p_id_empresa: id_empresa as string
        })

        if (error) {
            console.error(`[API Infra POST] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        return {
            success: true,
            data,
            message: `${resource} salvo com sucesso.`
        }
    } catch (err: any) {
        console.error(`[API Infra POST] Erro ao salvar ${resource}:`, err)
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.statusMessage || `Erro ao salvar dados de ${resource}`
        })
    }
})
