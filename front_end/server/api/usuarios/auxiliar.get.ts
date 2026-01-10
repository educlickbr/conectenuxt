import { serverSupabaseClient } from '#supabase/server'
import fs from 'node:fs'
import path from 'node:path'


export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const client = await serverSupabaseClient(event)

    const type = query.type as string // 'perguntas' | 'componentes'
    const id_empresa = query.id_empresa as string

    if (!id_empresa) {
        throw createError({ statusCode: 400, statusMessage: 'ID Empresa obrigatório' })
    }

    try {
        if (type === 'perguntas') {
            // Papeis comes as comma separated string or array?
            // Legacy uses: p_papeis which is uuid[]
            let papeis: string[] = []
            if (query.papeis) {
                papeis = Array.isArray(query.papeis) ? query.papeis : (query.papeis as string).split(',')
            }



            console.log('[API Auxiliar] Requesting perguntas for:', { id_empresa, papeis })
            const { data, error } = await (client as any).rpc('perguntas_get', {
                p_id_empresa: id_empresa,
                p_papeis: papeis
            })
            console.log('[API Auxiliar] Perguntas result:', { count: data?.length, error, firstItem: data?.[0] })

            // Double check write after fetch



            if (error) throw error
            return data
        }

        else if (type === 'componentes') {
            const { data, error } = await (client as any).rpc('componentes_get', {
                p_id_empresa: id_empresa
            })
            if (error) throw error
            return data
        }

        throw createError({ statusCode: 400, statusMessage: 'Tipo inválido' })

    } catch (err: any) {
        console.error(`[API Users Aux] Erro ao buscar ${type}:`, err)
        throw createError({ statusCode: 500, statusMessage: err.message })
    }
})
