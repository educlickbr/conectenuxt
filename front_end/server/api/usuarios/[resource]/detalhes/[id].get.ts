import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const resource = getRouterParam(event, 'resource')
    const id = getRouterParam(event, 'id')
    const query = getQuery(event)
    const { id_empresa } = query

    console.log('[BFF Detalhes] Called for:', { resource, id, id_empresa })

    if (!id) {
        throw createError({
            statusCode: 400,
            message: 'ID is required'
        })
    }

    // Map resource to RPC function and params
    const rpcMap: Record<string, { rpc: string, params: any }> = {
        professores: {
            rpc: 'professor_get_detalhes_cpx',
            params: {
                p_id_empresa: id_empresa,
                p_id_professor: id
            }
        },
        alunos: {
            rpc: 'aluno_get_detalhes_cpx',
            params: {
                p_id_empresa: id_empresa,
                p_id_aluno: id
            }
        },
        familias: {
            rpc: 'familia_get_detalhes',
            params: { p_id: id }
        }
    }

    const config = rpcMap[resource as string]

    if (!config) {
        throw createError({
            statusCode: 400,
            message: `Unknown resource: ${resource}`
        })
    }

    // For professors and alunos, id_empresa is required
    if ((resource === 'professores' || resource === 'alunos') && !id_empresa) {
        throw createError({
            statusCode: 400,
            message: 'id_empresa is required for this resource'
        })
    }

    try {
        console.log(`[BFF Detalhes] Calling ${config.rpc} with:`, config.params)
        const { data, error } = await (client as any).rpc(config.rpc, config.params)

        if (error) {
            console.error(`[BFF Detalhes] RPC error:`, error)
            throw error
        }

        console.log(`[BFF Detalhes] Success! Has data:`, !!data)
        return data

    } catch (err: any) {
        console.error(`[BFF Detalhes] Error:`, err)
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.message || `Failed to fetch ${resource} details`
        })
    }
})
