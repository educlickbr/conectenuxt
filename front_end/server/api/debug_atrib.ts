
import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    // hardcoded params for testing
    const { data, error } = await client.rpc('atrib_turmas_get_paginado', {
        p_id_empresa: 'db5a4c52-074f-47c2-9aba-ac89111039d9',
        p_pagina: 1,
        p_limite_itens_pagina: 1,
        p_ano: 2026
    } as any)
    return { data, error }
})
