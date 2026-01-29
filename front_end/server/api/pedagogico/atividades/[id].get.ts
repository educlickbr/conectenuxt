
import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const id = getRouterParam(event, 'id')

    if (!id) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID é obrigatório'
        })
    }

    const { data: itemData, error } = await client.rpc('lms_item_get_detalhes', {
        p_id_item: id
    } as any)

    if (error) {
        console.error('Error fetching details:', error)
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    // Hash Logic for Library Content (Covers/Files)
    let imageBaseUrl = ''
    try {
        const { data: hashData } = await client.functions.invoke('hash_pasta_conecte', {
            body: { path: '/biblio/' }
        })
        if (hashData && hashData.url) {
            imageBaseUrl = hashData.url
        }
    } catch (e) {
        console.error('Error fetching hash:', e)
    }

    if (!itemData) {
        throw createError({ statusCode: 404, statusMessage: 'Item not found' })
    }

    return {
        ...(typeof itemData === 'object' ? itemData : {}),
        imageBaseUrl
    }
})
