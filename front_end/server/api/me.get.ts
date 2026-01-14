import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event) as any
    let user = null
    try {
        user = await serverSupabaseUser(event)
    } catch (error) {
        // Token might be expired or invalid
    }

    // Auth fallback
    let altUser = null
    if (!user) {
        try {
            const { data: { user: u } } = await client.auth.getUser()
            altUser = u
        } catch (e) {
            // Fallback fails silently
        }
    }

    const effectiveUser = user || altUser

    // 1. Resolve domain for company lookup
    const host = getRequestHeader(event, 'host') || ''
    const protocol = getRequestHeader(event, 'x-forwarded-proto') || 'http'
    const origin = `${protocol}://${host}`

    // Note: Handle localhost if needed (for dev)
    let lookupDomain = origin
    if (host.includes('localhost')) {
        // In dev, we might want to hardcode or use a query param
        // The legacy app used store.empresa_local
        lookupDomain = 'https://escolamodelo.conectetecnologia.app'
    }

    // 2. Fetch Company Data
    const { data: companyData, error: companyError } = await client.rpc('buscar_empresa_por_dominio_publico', {
        p_dominio: lookupDomain
    })

    const company = companyData?.[0] || null

    // 3. Fetch User Profile & Role (if logged in)
    let role = null
    let profile = null
    if (effectiveUser) {
        // Fetch Role
        const { data: roleData } = await client.rpc('papeis_user_auth_get_my_role')
        role = roleData?.[0] || null

        // Fetch Profile from user_expandido
        const { data: profileData } = await client
            .from('user_expandido')
            .select('*')
            .eq('user_id', effectiveUser.id)
            .single()

        profile = profileData || null
    }

    return {
        user: effectiveUser,
        profile,
        company,
        role,
        server_time: new Date().toISOString()
    }
})
