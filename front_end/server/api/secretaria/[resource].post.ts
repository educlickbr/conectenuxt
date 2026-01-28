import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const resource = getRouterParam(event, 'resource')
    const body = await readBody(event)
    const client = await serverSupabaseClient(event)

    const rpcMap: Record<string, string> = {
        matriculas: 'matricula_upsert',
        alocar_turma: 'matricula_alocar_turma',
        atribuicao_turmas: 'atrib_turmas_upsert',
        atribuicao_componentes: 'atrib_componentes_upsert'
    }

    const rpcName = rpcMap[resource as string]

    if (!rpcName) {
        throw createError({
            statusCode: 400,
            statusMessage: `Recurso secretaria desconhecido: ${resource}`
        })
    }

    try {
        let rpcParams: any = {}

        // Attribution resources use direct parameters, not p_data wrapper
        if (resource === 'atribuicao_turmas' || resource === 'atribuicao_componentes') {
            const data = body.data || body
            if (body.id_empresa && !data.id_empresa) data.id_empresa = body.id_empresa

            // Validate required fields
            if (!data.id_turma) throw createError({ statusCode: 400, message: 'ID da Turma é obrigatório' })
            if (!data.id_professor) throw createError({ statusCode: 400, message: 'ID do Professor é obrigatório' })
            if (!data.ano) throw createError({ statusCode: 400, message: 'Ano é obrigatório' })

            rpcParams = {
                p_id: data.id || null,
                p_id_empresa: body.id_empresa,
                p_id_turma: data.id_turma,
                p_id_professor: data.id_professor,
                p_ano: parseInt(data.ano),
                p_data_inicio: data.data_inicio,
                p_data_fim: data.data_fim || null,
                p_motivo_substituicao: data.motivo_substituicao || null,
                p_nivel_substituicao: data.nivel_substituicao || 0
            }
            
            // Add id_carga_horaria for componentes
            if (resource === 'atribuicao_componentes') {
                rpcParams.p_id_carga_horaria = data.id_carga_horaria
            }
        } else {
            // Default behavior for matriculas and alocar_turma
            rpcParams = {
                p_data: body.data,
                p_id_empresa: body.id_empresa
            }
        }

        const { data, error } = await (client as any).rpc(rpcName, rpcParams)

        if (error) {
            console.error(`[API Secretaria] Erro ao salvar ${resource}:`, error)
            throw error
        }

        return {
            success: true,
            data
        }

    } catch (err: any) {
        throw createError({
            statusCode: err.statusCode || 500,
            statusMessage: err.message || `Erro ao salvar ${resource}`
        })
    }
})
