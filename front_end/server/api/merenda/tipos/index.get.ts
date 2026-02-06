import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const query = getQuery(event)
    
    // Call the Get All (Sorted) RPC
    const { data, error } = await client.rpc('mrd_refeicao_tipo_get_all', {
        p_id_empresa: query.id_empresa
    })

    if (error) {
        throw createError({
            statusCode: 500,
            message: error.message
        })
    }
    
    // Normalize response: RPC returns array directly (or empty array)
    // Some legacy patterns wrap in { data: [] }, but get_all usually returns []
    // Let's check RPC: RETURNS jsonb, SELECT jsonb_agg... RETURN coalesce(..., '[]').
    // So it returns an array.
    // BFF convention usually wraps in { data: [] } for consistency if list, 
    // BUT frontend likely expects `data.value.data` if using useFetch defaults, 
    // OR just `data.value` if API returns array. 
    // ModalEscalaSemanal uses: `refeicoesTipos.value = tiposData.value?.data || []`
    // So I should return { data: [items] } OR assume nuxt wraps it?
    // Nuxt useFetch result .value IS the response. 
    // If I return array, `tiposData.value` is array. `tiposData.value.data` is undefined.
    // The Modal code: `tiposData.value?.data || []` implies it expects an object wrapper.
    // I will wrap it.
    
    return { data: data || [] }
})
