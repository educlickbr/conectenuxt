import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const query = getQuery(event)
    const { busca, id_empresa, pagina = 1, limite = 10 } = query

    if (!busca || String(busca).length < 3) {
        return { items: [] }
    }

    const { data, error } = await client.rpc('bbtk_edicao_get_paginado', {
        p_id_empresa: id_empresa,
        p_pagina: Number(pagina),
        p_limite_itens_pagina: Number(limite),
        p_termo_busca: String(busca),
        p_tipo_livro: 'Digital'
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return {
        items: data?.itens || [],
        total: data?.total_registros || 0
    }
})
