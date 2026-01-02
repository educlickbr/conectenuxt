import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    // Map resource to Schema RPC names
    // Only 'escolas' currently uses dynamic schema in legacy
    const rpcMap: Record<string, string> = {
        escolas: 'escolas_get_schema'
        // Others might use static schemas or generic ones later
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        // Fallback or static schema if needed? 
        // For now, if not in map, return empty or error
        return {
            fields: []
        }
    }

    try {
        const { data, error } = await (client as any).rpc(rpcName, {
            p_id_empresa: query.id_empresa as string
        })

        if (error) {
            console.error(`[API Schema] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        return {
            fields: data || []
        }
    } catch (err: any) {
        console.error(`[API Schema] Erro ao buscar schema para ${resource}:`, err)
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.statusMessage || `Erro ao carregar schema de ${resource}`
        })
    }
})
