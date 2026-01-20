import { serverSupabaseClient } from '#supabase/server'

interface CopiasBody {
    id_empresa: string
    edicao_uuid: string
    estante_uuid?: string
    status_copia?: string
    doacao_ou_compra?: string
    avaria_flag?: boolean
    descricao_avaria?: string
    quantidade?: number
    uuid?: string // for updates
    registro_bibliotecario?: string
    soft_delete?: boolean
}

export default defineEventHandler(async (event) => {
    const body = await readBody<CopiasBody>(event)
    const client = await serverSupabaseClient(event)

    const { error } = await client.rpc('bbtk_inventario_copia_upsert', {
        p_id_empresa: body.id_empresa,
        p_edicao_uuid: body.edicao_uuid,
        p_estante_uuid: body.estante_uuid,
        p_status_copia: body.status_copia,
        p_doacao_ou_compra: body.doacao_ou_compra,
        p_avaria_flag: body.avaria_flag,
        p_descricao_avaria: body.descricao_avaria,
        p_quantidade: body.quantidade,
        p_uuid: body.uuid,
        p_registro_bibliotecario: body.registro_bibliotecario,
        p_soft_delete: body.soft_delete
    } as any)

    if (error) {
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return { success: true, message: 'Operação realizada com sucesso.' }
})
