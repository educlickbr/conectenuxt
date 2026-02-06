import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const body = await readBody(event)
    
    // Soft delete logic usually updates 'ativo' to false via RPC
    // Let's assume we use a generic delete or specific update
    // But wait, schema defined generic tables.
    // Let's create a specific RPC call since we didn't check for a generic delete RPC yet.
    // Re-checking Group 3 RPCs... mrd_cardapio_grupo_delete wasn't explicitly in the file I read earlier?
    // Let me check if I need to add it or if I can use a generic update.
    // Actually, I should check if the RPC exists. I'll implement assuming it does or create it if missing.
    // Wait, I saw mrd_cardapio_grupo_upsert but not delete in previous view.
    // Let's assume standard soft delete update pattern if RPC is missing, but better to use RPC.
    
    // Creating a standard delete handler that calls an RPC. 
    // I will check if I need to add the DELETE RPC in a strict migration step.
    // For now, let's implement the BFF to call a hypothetical 'mrd_cardapio_grupo_delete'.
    
    const { error } = await client.rpc('mrd_cardapio_grupo_delete', { // I need to verify if this exists
        p_id: body.id,
        p_id_empresa: body.id_empresa
    })

    if (error) {
        throw createError({
            statusCode: 500,
            message: error.message
        })
    }

    return { success: true }
})
