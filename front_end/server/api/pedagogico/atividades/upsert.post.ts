
import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const client = await serverSupabaseClient(event)
    const body = await readBody(event)
    const user = await client.auth.getUser()

    if (!user.data.user) {
        throw createError({
            statusCode: 401,
            statusMessage: 'Usuário não autenticado'
        })
    }

    // Body validation
    const {
        id,
        id_empresa,
        folder_id, // p_id_lms_conteudo
        tipo,
        titulo,
        descricao, // rich_text
        url_externa,
        video_link,
        id_bbtk_edicao,
        pontuacao_maxima,
        tempo_questionario,
        data_disponivel,
        data_entrega_limite,
        perguntas,
        ordem
    } = body

    if (!id_empresa || !titulo || !folder_id) {
        throw createError({
            statusCode: 400,
            statusMessage: 'Campos obrigatórios faltando: id_empresa, titulo, folder_id'
        })
    }

    const payload = {
        p_id: id || null,
        p_id_empresa: id_empresa,
        p_criado_por: user.data.user.id,
        p_id_lms_conteudo: folder_id,
        p_tipo: tipo,
        p_titulo: titulo,
        p_caminho_arquivo: null, // Not used for now in this flow
        p_url_externa: url_externa || null,
        p_video_link: video_link || null,
        p_rich_text: descricao || null, // Mapping 'descricao' from front to 'p_rich_text'
        p_pontuacao_maxima: pontuacao_maxima || 0,
        p_id_bbtk_edicao: id_bbtk_edicao || null,
        p_ordem: ordem || 99,
        p_data_disponivel: data_disponivel || null,
        p_data_entrega_limite: data_entrega_limite || null,
        p_tempo_questionario: tempo_questionario || null,
        p_perguntas: perguntas || null
    }

    const { data, error } = await client.rpc('lms_item_upsert', payload as any)

    if (error) {
        console.error('RPC Error:', error)
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return { success: true, id: data }
})
