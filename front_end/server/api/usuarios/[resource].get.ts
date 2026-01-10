import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    // Map resource to RPC names
    // Note: Legacy UserManagementPage.vue
    // professores -> professor_get_paginado
    // alunos -> aluno_get_paginado
    // familias -> familia_get_paginado
    // admins -> admin_get_paginado
    const rpcMap: Record<string, string> = {
        professores: 'professor_get_paginado',
        alunos: 'aluno_get_paginado',
        familias: 'familia_get_paginado',
        admins: 'admin_get_paginado'
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
    // Legacy mapping:
    // p_id_empresa, p_pagina, p_limite_itens_pagina, p_busca
    // Professores/Alunos adds: p_id_escola (null), p_status (null)
    const rpcParams: any = {
        p_id_empresa: id_empresa as string,
        p_pagina: parseInt(query.pagina as string) || 1,
        p_limite_itens_pagina: parseInt(query.limite as string) || 10,
        p_busca: (query.busca as string) || null
    }

    if (resource === 'professores' || resource === 'alunos') {
        rpcParams.p_id_escola = null
        rpcParams.p_status = null
    }

    try {
        const { data, error } = await (client as any).rpc(rpcName, rpcParams)

        if (error) {
            console.error(`[API Users] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        // Normalize response
        // Legacy: 
        // - Professores/Alunos: Array with 1 object { itens: [], qtd_itens: ... }
        // - Familias/Admins: Array of items directly. First item might have total_registros count or we calculate.

        // Wait, reviewing legacy code again:
        // "Famílias/Admin style: if (data.length > 0) ... total = data[0].total_registros"

        let items: any[] = []
        let total = 0
        let pages = 0

        if (resource === 'professores' || resource === 'alunos') {
            const result = Array.isArray(data) ? data[0] : data
            items = result?.itens || []
            if (items.length > 0) console.log(`[API Users Get] ${resource} Item keys:`, Object.keys(items[0]))
            total = result?.qtd_itens || 0
            pages = result?.qtd_paginas || 0
        } else {
            // Familias / Admins
            if (data && data.length > 0) {
                items = data
                total = data[0].total_registros || items.length
                pages = Math.ceil(total / (parseInt(query.limite as string) || 10))
            } else {
                items = []
                total = 0
                pages = 0
            }
        }

        return {
            items,
            total,
            pages,
            resource
        }
    } catch (err: any) {
        console.error(`[API Users] Erro ao processar ${resource}:`, err)
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.statusMessage || `Erro ao carregar dados de ${resource}`
        })
    }
})
