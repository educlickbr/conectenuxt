import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const body = await readBody(event)
    const client = await serverSupabaseClient(event)

    // Map resource to RPC names for upsert
    const rpcMap: Record<string, string> = {
        modelos: 'avaliacao_modelo_upsert',
        grupos: 'avaliacao_grupo_upsert',
        criterios: 'avaliacao_criterio_upsert',
        itens_criterio: 'itens_criterio_upsert',
        itens_avaliacao: 'itens_avaliacao_upsert',
        assoc_ano_etapa: 'avaliacao_assoc_upsert',
        registros: 'avaliacao_aluno_registrar_completa_wrapper'
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
            console.error(`[API Avaliacao POST] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        return {
            success: true,
            data,
            message: `${resource} salvo com sucesso.`
        }
    } catch (err: any) {
        console.error(`[API Avaliacao POST] Erro ao salvar ${resource}:`, err)
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.statusMessage || `Erro ao salvar dados de ${resource}`
        })
    }
})
