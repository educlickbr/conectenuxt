import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
    const user = await serverSupabaseUser(event)
    const client = await serverSupabaseClient(event)
    const body = await readBody(event)
    const config = useRuntimeConfig()
    
    // Validate User
    if (!user) {
        throw createError({
            statusCode: 401,
            statusMessage: 'Usuário não autenticado'
        })
    }

    // Default company ID
    const id_empresa = body.id_empresa || null

    console.log(`[Submit Enc] User: ${user?.id}, Type: ${body.type}, Item: ${body.itemId}`)

    if (body.type === 'quiz') {
        const { data, error } = await client.rpc('lms_quiz_submit_batch', {
            p_user_id: user.id,
            p_item_id: body.itemId,
            p_respostas: body.answers, // JSON Array of { id_pergunta, id_resposta_possivel, texto_resposta }
            p_id_empresa: id_empresa
        } as any)

        if (error) {
            console.error('Quiz Submit Error:', error)
            throw createError({ statusCode: 500, statusMessage: error.message })
        }
        return data
    } 
    
    else if (body.type === 'task') {
        const { data, error } = await client.rpc('lms_task_submit', {
            p_user_id: user.id,
            p_item_id: body.itemId,
            p_texto: body.text || null,
            p_arquivo: body.fileUrl || null,
            p_id_empresa: id_empresa
        } as any)

        if (error) {
            console.error('Task Submit Error:', error)
            throw createError({ statusCode: 500, statusMessage: error.message })
        }
        return data
    }

    else {
        throw createError({
            statusCode: 400,
            statusMessage: 'Tipo de submissão inválido'
        })
    }
})
