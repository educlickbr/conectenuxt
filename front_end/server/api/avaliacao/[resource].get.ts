import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    // Map resource to RPC names
    const rpcMap: Record<string, string> = {
        modelos: 'avaliacao_modelo_get_paginado',
        grupos: 'avaliacao_grupo_get_by_modelo',
        criterios: 'avaliacao_criterio_get_paginado',
        itens_criterio: 'itens_criterio_get_by_criterio',
        itens_avaliacao: 'itens_avaliacao_get_by_grupo',
        assoc_ano_etapa: 'avaliacao_assoc_get_by_ano_etapa',
        grid: 'avaliacao_diario_get_grid'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso desconhecido: ${resource}`
        })
    }

    // Validation
    const id_empresa = query.id_empresa
    if (!id_empresa) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID da empresa é obrigatório para esta consulta.'
        })
    }

    // Prepare RPC parameters
    // Note: Different RPCs accept different parameters. We'll construct a superset or conditional params.
    const rpcParams: any = {
        p_id_empresa: id_empresa as string
    }

    // Parameters for Paginado RPCs (modelos, criterios)
    if (['modelos', 'criterios'].includes(resource as string)) {
        rpcParams.p_pagina = parseInt(query.pagina as string) || 1
        rpcParams.p_limite_itens_pagina = parseInt(query.limite as string) || 10
        rpcParams.p_busca = (query.busca as string) || ''
    }

    // Specific params
    if (resource === 'criterios' && query.tipo) {
        rpcParams.p_tipo = query.tipo
    }
    if (resource === 'grupos' && query.id_modelo) {
        rpcParams.p_id_modelo = query.id_modelo
    } else if (resource === 'grupos' && !query.id_modelo) {
        // Some specific check if needed, but RPC might fail or return empty if param missing
    }

    if (resource === 'itens_criterio' && query.id_criterio) {
        rpcParams.p_id_criterio = query.id_criterio
    }

    if (resource === 'itens_avaliacao' && query.id_grupo) {
        rpcParams.p_id_grupo = query.id_grupo
    }

    if (resource === 'assoc_ano_etapa' && query.id_ano_etapa) {
        rpcParams.p_id_ano_etapa = query.id_ano_etapa
    }

    if (resource === 'grid') {
        rpcParams.p_id_turma = query.id_turma
        rpcParams.p_id_modelo = query.id_modelo
    }

    try {
        const { data, error } = await (client as any).rpc(rpcName, rpcParams)

        if (error) {
            console.error(`[API Avaliacao GET] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        // Normalize response
        // Paginado returns object { itens, ... }, List returns Array
        if (['modelos', 'criterios'].includes(resource as string)) {
            // Should be paginated response
            const result = Array.isArray(data) ? data[0] : data
            return {
                items: result?.itens || [],
                total: result?.qtd_itens || 0,
                pages: result?.qtd_paginas || 0,
                resource
            }
        } else {
            // Should be list response (array of objects or array of jsonb if using jsonb_agg)
            // If the RPC returns jsonb which is just an array, Supabase client parses it as array.
            return {
                items: data || [],
                total: Array.isArray(data) ? data.length : 0,
                pages: 1,
                resource
            }
        }

    } catch (err: any) {
        console.error(`[API Avaliacao GET] Erro ao processar ${resource}:`, err)
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.statusMessage || `Erro ao carregar dados de ${resource}`
        })
    }
})
