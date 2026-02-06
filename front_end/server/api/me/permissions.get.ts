import { serverSupabaseUser, serverSupabaseClient } from '#supabase/server'
import { createError } from 'h3'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const user = await serverSupabaseUser(event)

    if (!user) {
        throw createError({ statusCode: 401, message: 'Unauthorized' })
    }

    console.log('[PERMISSIONS] Authenticated User:', user.id)

    // 1. Resolve Company Context (Same logic as me.get.ts)
    const host = getRequestHeader(event, 'host') || ''
    const protocol = getRequestHeader(event, 'x-forwarded-proto') || 'http'
    let lookupDomain = `${protocol}://${host}`
    
    // Dev/Localhost handling
    if (host.includes('localhost')) {
        lookupDomain = 'https://escolamodelo.conectetecnologia.app'
    }

    // Fetch Company via RPC
    const { data: companyData, error: companyError } = await client.rpc('buscar_empresa_por_dominio_publico', {
        p_dominio: lookupDomain
    } as any)

    if (companyError) {
        console.error('[PERMISSIONS] Company RPC Error:', companyError)
    }

    const company = companyData?.[0] as any
    // Note: The RPC returns objects, check if 'id' or 'empresa_id' is the column
    const id_empresa = company?.id || company?.empresa_id

    // 2. Fetch Role Context via RPC
    const { data: roleData, error: roleError } = await client.rpc('papeis_user_auth_get_my_role')

    if (roleError) {
        console.error('[PERMISSIONS] Role RPC Error:', roleError)
    }

    const role = roleData?.[0] as any
    const papel_id = role?.papel_id

    console.log('[PERMISSIONS] Context Resolved:', { 
        id_empresa, 
        papel_id,
        user_id: user.id 
    })

    if (!id_empresa || !papel_id) {
        console.warn('[PERMISSIONS] Failed to resolve context. Permissions might be empty.')
        // We can throw or return empty. Returning empty is safer.
        return { permissions: [] }
    }

    // 3. Debug: Check table existence/access simple query
    const { data: testData, error: testError } = await client
        .from('app_permissoes')
        .select('id')
        .limit(1)

    if (testError) {
        console.error('[PERMISSIONS] Table Access Error (Simple Select):', testError)
        throw createError({ 
            statusCode: 500, 
            message: `Error accessing app_permissoes table: ${testError.message} (${testError.code})`,
            data: testError
        })
    }

    // 3. Fetch Permissions matched by Role AND Company
    // using .filter('col', 'cs', value) with explicit JSON string to avoid client serialization issues
    const { data: permissions, error: permError } = await client
        .from('app_permissoes')
        .select('ilha, botao, escopo, entidade_pai')
        .filter('papeis', 'cs', JSON.stringify([papel_id]))
        .filter('empresas', 'cs', JSON.stringify([id_empresa]))

    if (permError) {
        console.error('[PERMISSIONS] Filter Query Error:', permError)
        throw createError({ 
            statusCode: 500, 
            message: `Error filtering permissions: ${permError.message}`,
            data: permError 
        })
    }

    console.log('[PERMISSIONS] Found count:', permissions?.length)

    return {
        permissions: permissions || []
    }
})
