import { serverSupabaseServiceRole } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = serverSupabaseServiceRole(event)
    const { data, error } = await client.from('perguntas_user').select('id, label, pergunta, papel')
    return { data, error }
})
