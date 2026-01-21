import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)

    let imageBaseUrl = ''
    try {
        const { data: hashData, error: hashError } = await client.functions.invoke('hash_pasta_conecte', {
            body: { 
                path: '/biblio/',
            }
        })
        if (!hashError && hashData && hashData.url) {
            imageBaseUrl = hashData.url
        } else {
             console.error('Error fetching hash or invalid data:', hashError || 'No URL returned')
        }
    } catch (e) {
        console.error('Error invoking hash function:', e)
    }

    return {
        url: imageBaseUrl
    }
})
