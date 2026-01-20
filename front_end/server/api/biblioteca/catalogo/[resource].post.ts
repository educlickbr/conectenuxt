import { serverSupabaseClient } from '#supabase/server'

interface CatalogoBody {
    action?: 'delete'
    id?: string
    id_empresa: string
    data?: any
}

export default defineEventHandler(async (event) => {
    const resource = event.context.params?.resource
    const body = await readBody<CatalogoBody>(event)
    const client = await serverSupabaseClient(event)

    // Map resources to RPCs
    const rpcMap: Record<string, { upsert: string, delete: string }> = {
        editoras: { upsert: 'bbtk_dim_editora_upsert', delete: 'bbtk_dim_editora_delete' },
        autoria: { upsert: 'bbtk_dim_autoria_upsert', delete: 'bbtk_dim_autoria_delete' },
        categoria: { upsert: 'bbtk_dim_categoria_upsert', delete: 'bbtk_dim_categoria_delete' },
        cdu: { upsert: 'bbtk_dim_cdu_upsert', delete: 'bbtk_dim_cdu_delete' },
        metadado: { upsert: 'bbtk_dim_metadado_upsert', delete: 'bbtk_dim_metadado_delete' },
        doador: { upsert: 'bbtk_dim_doador_upsert', delete: 'bbtk_dim_doador_delete' }
    }

    const config = rpcMap[resource as string]

    if (!config) {
        throw createError({ statusCode: 400, statusMessage: 'Recurso de catálogo inválido.' })
    }

    try {
        // DELETE Action
        if (body.action === 'delete') {
             if (!body.id) throw new Error('ID obrigatório para deleção.')

             const { error } = await client.rpc(config.delete, {
                 p_id: body.id,
                 p_id_empresa: body.id_empresa
             } as any)
             if (error) throw error
             return { success: true, message: 'Removido com sucesso.' }
        }
        
        // UPSERT Action (Default)
        const { error } = await client.rpc(config.upsert, {
            p_data: body.data,
            p_id_empresa: body.id_empresa
        } as any)

        if (error) throw error
        return { success: true, message: 'Salvo com sucesso.' }

    } catch (err: any) {
        throw createError({
            statusCode: 500,
            statusMessage: err.message
        })
    }
})
