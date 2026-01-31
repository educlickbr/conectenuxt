
import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const query = getQuery(event)
    const { id_empresa, id_turma, id_ano_etapa } = query

    if (!id_empresa || !id_turma || !id_ano_etapa) {
        throw createError({
            statusCode: 400,
            message: 'Missing required parameters: id_empresa, id_turma, id_ano_etapa'
        })
    }

    const { data, error } = await client.rpc('mtz_matriz_curricular_get_merged', {
        p_id_empresa: id_empresa,
        p_id_ano_etapa: id_ano_etapa,
        p_id_turma: id_turma
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            message: error.message
        })
    }

    return data
})
