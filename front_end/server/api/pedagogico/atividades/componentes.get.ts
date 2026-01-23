import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const id_empresa = query.id_empresa as string
    const id_ano_etapa = query.id_ano_etapa as string

    if (!id_empresa) {
        throw createError({
            statusCode: 400,
            statusMessage: 'ID da empresa é obrigatório.'
        })
    }

    if (!id_ano_etapa) {
        // Return empty if no ano_etapa provided, or throw? 
        // Logic requires ano_etapa to fetch components via workload.
        return { items: [] } 
    }

    try {
        const { data, error } = await client.rpc('carga_horaria_get', {
            p_id_empresa: id_empresa,
            p_id_ano_etapa: id_ano_etapa
        })

        if (error) throw error

        // Normalize response (carga_horaria_get usually returns the items directly or in .itens depending on version, 
        // but based on [resource].get.ts logic for 'carga_horaria' sharing generic handler, verify structure.)
        // In the generic handler, data is handled as:
        /*
        if (Array.isArray(data)) {
             // ...
        } else if (data.itens) { ... }
        */
        // We'll trust the generic handler's logic logic or simply return mapped items.
        // Assuming data is the array or object. Let's inspect generic handler again mentally...
        // Generic handler handles various formats.
        // I will return standardized items.

        let items: any[] = []
        
        if (Array.isArray(data)) {
             if (data.length > 0 && data[0].itens) {
                 items = data[0].itens
             } else {
                 items = data
             }
        } else if (data && data.itens) {
            items = data.itens
        }

        return {
            items: items.map((item: any) => ({
                id: item.id_componente, // Map internal UUID to standardized 'id'
                nome: item.componente_nome,
                cor: item.componente_cor,
                carga_horaria: item.carga_horaria,
                polivalente: item.polivalente
            }))
        }

    } catch (err: any) {
        console.error('Erro ao buscar componentes (pedagogico):', err)
        throw createError({
            statusCode: 500,
            statusMessage: 'Erro ao buscar componentes.'
        })
    }
})
