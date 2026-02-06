import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3'
import { serverSupabaseClient } from '#supabase/server'
import crypto from 'crypto'

export default defineEventHandler(async (event) => {
    const supabase = await serverSupabaseClient(event)
    const body = await readBody(event)
    
    // Optional: limit processing
    const limit = body?.limit || 10
    const offset = body?.offset || 0

    // 1. Fetch records from bbtk_edicao
    const { data: records, error } = await supabase
        .from('bbtk_edicao')
        .select('*')
        .range(offset, offset + limit - 1)

    if (error) {
        throw createError({ statusCode: 500, statusMessage: error.message })
    }

    if (!records || records.length === 0) {
        return { message: "No records found to migrate." }
    }

    // 2. Configure S3/R2 Client
    const R2_ACCESS_KEY_ID = process.env.R2_ACCESS_KEY_ID
    const R2_SECRET_ACCESS_KEY = process.env.R2_SECRET_ACCESS_KEY
    const R2_BUCKET = process.env.R2_BUCKET
    const R2_ENDPOINT = process.env.R2_ENDPOINT

    if (!R2_ACCESS_KEY_ID || !R2_SECRET_ACCESS_KEY || !R2_ENDPOINT || !R2_BUCKET) {
        throw createError({ statusCode: 500, statusMessage: 'R2 Credentials missing' })
    }

    const s3Client = new S3Client({
        region: 'auto',
        endpoint: R2_ENDPOINT,
        credentials: {
            accessKeyId: R2_ACCESS_KEY_ID,
            secretAccessKey: R2_SECRET_ACCESS_KEY,
        },
    })

    const results = []

    // Helper to process a single file field
    const processFile = async (record: any, fieldName: string, escopo: string) => {
        const originalFilename = record[fieldName]
        if (!originalFilename) return null // No file to migrate

        try {
             // 3. Download from Bunny
            const bunnyUrl = `https://conecteappzone.b-cdn.net/biblio/${originalFilename}`
            const response = await fetch(bunnyUrl)
            
            if (!response.ok) {
                return { error: `Failed to fetch from Bunny: ${response.statusText}`, file: originalFilename }
            }

            const arrayBuffer = await response.arrayBuffer()
            const buffer = Buffer.from(arrayBuffer)
            const contentType = response.headers.get('content-type') || 'application/octet-stream'

            // 4. Generate new UUID path
            const ext = originalFilename.split('.').pop()
            const newKey = `biblioteca_conecte/${crypto.randomUUID()}.${ext}`

            // 5. Upload to R2
            await s3Client.send(new PutObjectCommand({
                Bucket: R2_BUCKET,
                Key: newKey,
                Body: buffer,
                ContentType: contentType,
            }))

            // 6. Insert into global_arquivos
            const { data: inserted, error: dbError } = await supabase
                .from('global_arquivos')
                .insert({
                    empresa_id: record.id_empresa,
                    path: newKey,
                    bucket: 'conecte',
                    tamanho_bytes: buffer.length,
                    mimetype: contentType,
                    nome_original: originalFilename,
                    escopo: escopo,
                } as any)
                .select()
                .single()

            if (dbError) {
                throw createError({
                    statusCode: 500,
                    statusMessage: dbError.message || 'Database Insert Error'
                })
            }

            return { success: true, old: originalFilename, new: newKey, id: (inserted as any)?.id }

        } catch (err: any) {
            return { error: err.message, file: originalFilename }
        }
    }

    // Loop records
    for (const record of (records as any[]) || []) {
        const resCapa = await processFile(record, 'arquivo_capa', 'biblioteca_capa')
        const resPdf = await processFile(record, 'arquivo_pdf', 'biblioteca_arquivo')
        
        results.push({
            isbn: record.isbn,
            uuid: record.uuid,
            capa: resCapa,
            pdf: resPdf
        })
    }

    return {
        processed: records.length,
        results
    }
})
