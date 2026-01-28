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
        plano_referencias_batch: 'pl_plano_referencias_upsert_batch',
        // Grupos de Estudo
        grupos: 'grp_grupo_upsert',
        tutores: 'grp_tutor_upsert', // Add Tutor Link
        integrantes: 'grp_integrante_upsert' // Add Member Link
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
            params = {
                p_id_empresa: id_empresa,
                p_id_aula: body.id_aula || payload?.id_aula,
                p_itens: body.itens || payload?.itens
            }
        } else if (resource === 'tutores' || resource === 'integrantes') {
            // Linkage Ops: grp_tutor_upsert(p_id_empresa, p_id_grupo, p_id_user, p_ano)
            // Expecting payload to be the direct object with these fields if data: payload is used
            params = {
                p_id_empresa: id_empresa,
                p_id_grupo: payload.id_grupo,
                p_id_user: payload.id_user,
                p_ano: payload.ano || null,
                p_status: payload.status || 'ATIVO'
            }
        } else if (resource === 'grupos') {
            // grp_grupo_upsert(p_id, p_id_empresa, p_nome_grupo, p_descricao, p_status)
            params = {
                p_id: payload.id || null,
                p_id_empresa: id_empresa,
                p_nome_grupo: payload.nome_grupo,
                p_descricao: payload.descricao,
                p_status: payload.status || 'ATIVO',
                p_ano: payload.ano || new Date().getFullYear()
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
