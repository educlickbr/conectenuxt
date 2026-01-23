
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
        id_ano_etapa,
        id_componente,
        data_disponivel,
        liberar_por,
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
        p_id_turma: (escopo === 'Turma' || escopo === 'Componente' || escopo === 'Aluno') ? id_turma : null,
        p_id_aluno: escopo === 'Aluno' ? id_aluno : null,
        p_id_ano_etapa: id_ano_etapa || null,
        p_id_componente: escopo === 'Componente' ? id_componente : null,
        p_id_meta_turma: null,
        p_titulo: titulo,
        p_descricao: descricao || null,
        p_visivel_para_alunos: visivel_para_alunos,
        p_data_disponivel: data_disponivel || null,
        p_liberar_por: liberar_por || 'Conteúdo'
    }

    const { data, error } = await client.rpc('lms_conteudo_upsert', payload)

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

    // Check for application-level errors captured by the RPC's exception handler
    const result = data as any
    if (result && result.success === false) {
        throw createError({
            statusCode: 500,
            statusMessage: result.message || 'Erro desconhecido ao salvar conteúdo.',
            data: result.detail
        })
    }

    return { success: true }
})
