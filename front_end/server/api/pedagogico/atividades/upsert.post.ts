
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

    const {
        id,
        id_empresa,
        titulo,
        descricao,
        escopo,
        id_turma,
        id_aluno,
        data_referencia,
        visivel_para_alunos
    } = body

    if (!id_empresa || !titulo || !escopo) {
        throw createError({
            statusCode: 400,
            statusMessage: 'Campos obrigatórios faltando: id_empresa, titulo, escopo'
        })
    }

    const payload = {
        p_id: id || null,
        p_id_empresa: id_empresa,
        p_criado_por: user.data.user.id,
        p_escopo: escopo,
        p_id_turma: escopo === 'Turma' ? id_turma : null,
        p_id_aluno: escopo === 'Aluno' ? id_aluno : null,
        p_id_meta_turma: null,
        p_id_componente: null,
        p_titulo: titulo,
        p_descricao: descricao || null,
        p_data_referencia: data_referencia,
        p_visivel_para_alunos: visivel_para_alunos,
        p_json_itens: null
    }

    const { error } = await client.rpc('lms_conteudo_upsert', payload)

    if (error) {
        // Handle specific error codes if needed, e.g., foreign key violations
        if (error.code === '23503') {
             throw createError({
                statusCode: 400,
                statusMessage: 'Erro de Permissão: Usuário não vinculado corretamente.'
            })
        }
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        })
    }

    return { success: true }
})
