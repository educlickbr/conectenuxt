import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const query = getQuery(event)
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
        matriz_curricular: 'mtz_matriz_curricular_delete'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso desconhecido: ${resource}`
        })
    }

    // Validation
    const { id, id_empresa } = await readBody(event)

    if (!id || !id_empresa) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID do registro e ID da empresa são obrigatórios para exclusão.'
        })
    }

    // Special parameter ordering for 'turmas_delete' if it follows the (id_empresa, id) signature
    // but the SQL wrapper usually handles named params.
    // The Migration defined: turmas_delete(p_id_empresa, p_id)
    // The others defined: name(p_id, p_id_empresa)
    // We will use named parameters to be safe.

    const rpcParams: any = {
        p_id: id,
        p_id_empresa: id_empresa
    }

    // Special case handling if needed for param names, but usually named params work best
    // Feriados/Eventos follow (p_id, p_id_empresa) which fits the standard mapping if using positional,
    // but with named params (object) supabase handles it cleanly.

    try {
        const { data, error } = await (client as any).rpc(rpcName, rpcParams)

        if (error) {
            console.error(`[API Estrutura Acadêmica DELETE] Erro no RPC ${rpcName}:`, error)
            // Create a user-friendly error from the database error if possible
            throw error
        }

        // The RPC returns a JSONB object: { status, message, id }
        // We pass this through to the frontend

        if (data && data.status === 'error') {
            throw createError({
                statusCode: 400,
                // We use data.message to pass the specific dependency error (e.g., "Turma vinculada")
                message: data.message,
                data: data // Pass full data object
            })
        }

        return {
            success: true,
            message: data?.message || 'Registro excluído com sucesso.',
            data
        }

    } catch (err: any) {
        console.error(`[API Estrutura Acadêmica DELETE] Erro ao processar ${resource}:`, err)

        // Ensure we propagate the specific message from the RPC if it was thrown above
        const statusCode = err.statusCode || 500
        const message = err.message || `Erro ao excluir ${resource}`

        throw createError({
            statusCode,
            message, // Use 'message' field which Nuxt/H3 communicates well
            data: err.data
        })
    }
})
