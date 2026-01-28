import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const client = await serverSupabaseClient(event)

    // Map resource to RPC names
    const rpcMap: Record<string, string> = {
        classes: 'classe_delete',
        ano_etapa: 'ano_etapa_delete',
        horarios: 'horarios_escola_delete',
        turmas: 'turmas_delete',
        componentes: 'componente_delete',
        carga_horaria: 'carga_horaria_delete',
        feriados: 'mtz_feriados_delete',
        eventos: 'mtz_eventos_delete',
        matriz_curricular: 'mtz_matriz_curricular_delete',
        plano_de_aulas: 'pl_plano_de_aulas_delete',
        plano_de_aulas_itens: 'pl_plano_itens_delete',
        // Grupos de Estudo
        grupos: 'grp_grupo_soft_delete', // Soft Delete
        tutores: 'grp_tutor_remove', // Remove Logic
        integrantes: 'grp_integrante_remove' // Remove Logic
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso desconhecido: ${resource}`
        })
    }

    // Validation
    const body = await readBody(event)
    const { id, id_empresa, id_grupo, id_user } = body

    if (!id_empresa) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID da empresa é obrigatório para exclusão.'
        })
    }

    // Specific validation based on resource
    let rpcParams: any = {}

    if (resource === 'tutores' || resource === 'integrantes') {
        if (!id_grupo || !id_user) {
            throw createError({
                statusCode: 400,
                statusMessage: 'IDs do grupo e usuário são obrigatórios para remoção.'
            })
        }
        rpcParams = {
            p_id_grupo: id_grupo,
            p_id_user: id_user
        }
    } else {
        // Standard Case
        if (!id) {
            throw createError({
                statusCode: 400,
                statusMessage: 'ID do registro é obrigatório para exclusão.'
            })
        }
        rpcParams = {
            p_id: id,
            p_id_empresa: id_empresa
        }
    }

    try {
        const { data, error } = await (client as any).rpc(rpcName, rpcParams)

        if (error) {
            console.error(`[API Estrutura Acadêmica DELETE] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        if (data && data.status === 'error') {
            throw createError({
                statusCode: 400,
                message: data.message,
                data: data
            })
        }

        return {
            success: true,
            message: data?.message || 'Registro excluído com sucesso.',
            data
        }

    } catch (err: any) {
        console.error(`[API Estrutura Acadêmica DELETE] Erro ao processar ${resource}:`, err)

        const statusCode = err.statusCode || 500
        const message = err.message || `Erro ao excluir ${resource}`

        throw createError({
            statusCode,
            message,
            data: err.data
        })
    }
})
