import { serverSupabaseClient } from '#supabase/server'

interface ObrasBody {
    payload: any // Complex nested object { obra: ..., edicoes: ... }
    id_empresa: string
}

export default defineEventHandler(async (event) => {
    const body = await readBody<ObrasBody>(event)
    const client = await serverSupabaseClient(event)

    const { error } = await client.rpc('bbtk_obra_upsert_cpx', {
        p_data: body.payload,
        p_id_empresa: body.id_empresa
    } as any)

    if (error) {
         throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return { success: true, message: 'Salvo com sucesso.' }
})
