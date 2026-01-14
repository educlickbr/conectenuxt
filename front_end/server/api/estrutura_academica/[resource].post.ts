import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const body = await readBody(event)
    const client = await serverSupabaseClient(event)

    // Map resource to UPSERT RPC names
    const rpcMap: Record<string, string> = {
        classes: 'classe_upsert',
        ano_etapa: 'ano_etapa_upsert',
        horarios: 'horarios_escola_upsert',
        turmas: 'turmas_upsert',
        componentes: 'upsert_componentes',
        carga_horaria: 'upsert_carga_horaria',
        feriados: 'mtz_feriados_upsert',
        eventos: 'mtz_eventos_upsert',
        matriz_curricular: 'mtz_matriz_curricular_upsert',
        calendarios: 'mtz_calendario_anual_upsert',
        diario_aulas: 'diario_aula_upsert',
        diario_presenca: 'diario_presenca_upsert_batch',
        plano_de_aulas: 'pl_plano_de_aulas_upsert',
        plano_de_aulas_itens: 'pl_plano_itens_upsert',
        plano_referencias_batch: 'pl_plano_referencias_upsert_batch'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso desconhecido para gravação: ${resource}`
        })
    }

    const { id_empresa, data: payload } = body

    if (!id_empresa) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID da empresa é obrigatório para gravação.'
        })
    }

    try {
        // Prepare RPC parameters
        // Standard signature for these legacy upserts: (p_data jsonb, p_id_empresa uuid)
        // Except 'turmas_upsert' which might use p_turma instead of p_data

        let params: any = {}

        if (resource === 'turmas') {
            // turmas_upsert(p_id_empresa, p_turma)
            params = {
                p_id_empresa: id_empresa,
                p_turma: payload
            }
        } else if (resource === 'diario_presenca') {
            // diario_presenca_upsert_batch(p_id_empresa, p_payload)
            params = {
                p_id_empresa: id_empresa,
                p_payload: payload
            }
        } else if (resource === 'plano_referencias_batch') {
            // pl_plano_referencias_upsert_batch(p_id_empresa, p_id_aula, p_itens)
            // Payload structure from ModalGerenciarAula: { id_aula, itens: [...] }
            params = {
                p_id_empresa: id_empresa,
                p_id_aula: body.id_aula || payload.id_aula, // Check how payload is structured logic below
                p_itens: payload.itens // Modal passes { id_empresa, id_aula, itens: [...] } 
                // Wait, index.post default extracts 'data' as 'payload'. 
                // Modal sends: body: { id_empresa, id_aula, itens }. 
                // So readBody(event) result 'body' has these keys.
                // code line 35: const { id_empresa, data: payload } = body
                // Modal line 210: body: { id_empresa, id_aula, itens: refPayload } -> NO 'data' key wrapping it?
                // Modal code check: 
                // await $fetch(..., { body: { id_empresa, id_aula, itens: ... } })
                // So 'data' extraction line 35 will be undefined if strict. 
                // But let's look at index.post code again.
            }
            // Correction: I need to verify payload structure.
            // If body = { id_empresa, id_aula, itens }, then 'data' is undefined.
            // But line 35 'const { id_empresa, data: payload } = body' implies standard structure expected is { id_empresa, data: ... }.
            // I should update ModalGerenciarAula to conform or adjust here.
            // Adjusting here is harder if 'payload' is const.
            // Actually, I should update this block to use 'body' directly if needed.
            // Let's assume for now I fix the mapping here but I might need to fix the Modal call structure or read from 'body' safely.
            params = {
                p_id_empresa: id_empresa,
                p_id_aula: body.id_aula,
                p_itens: body.itens
            }
        } else {
            // Standard: (p_data, p_id_empresa)
            params = {
                p_data: payload,
                p_id_empresa: id_empresa
            }
        }

        const { data, error } = await (client as any).rpc(rpcName, params)

        if (error) {
            console.error(`[API Estrutura Acadêmica POST] Erro no RPC ${rpcName}:`, error)
            throw error
        }

        // Check for logical error in JSON response
        // Legacy RPCs often return object with 'status': 'error'
        if (data && data.status === 'error') {
            throw createError({
                statusCode: 400,
                message: data.message || `Erro ao salvar ${resource}.`
            })
        }

        return {
            success: true,
            data,
            message: 'Registro salvo com sucesso.'
        }

    } catch (err: any) {
        console.error(`[API Estrutura Acadêmica POST] Erro ao processar ${resource}:`, err)
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.message || `Erro ao salvar ${resource}`
        })
    }
})
