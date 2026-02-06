import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3'
import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'
import { generateUuidFileName } from '../../../utils/file'

export default defineEventHandler(async (event) => {
    // 1. Check Auth
    const user = await serverSupabaseUser(event)
    if (!user) {
        throw createError({ statusCode: 401, message: 'Unauthorized' })
    }

    // 2. Parse Multipart Form
    const formData = await readMultipartFormData(event)
    if (!formData || formData.length === 0) {
        throw createError({ statusCode: 400, message: 'No file uploaded' })
    }

    const file = formData.find(f => f.name === 'file')
    const type = formData.find(f => f.name === 'type')?.data.toString() || 'document' // 'document' or 'image'
    // Optional: scope for global_arquivos could be passed, defaulting to 'biblioteca_cliente'
    const scope = 'biblioteca_cliente'

    if (!file || !file.filename) {
        throw createError({ statusCode: 400, message: 'Invalid file' })
    }

    // 3. Configure R2 Client (Server-side)
    const config = useRuntimeConfig()
    const S3 = new S3Client({
        region: 'auto',
        endpoint: config.r2Endpoint,
        credentials: {
            accessKeyId: config.r2AccessKeyId,
            secretAccessKey: config.r2SecretAccessKey,
        },
    })

    // 4. Prepare Upload
    const filename = generateUuidFileName(file.filename) // e.g. "uuid.pdf"
    const r2Path = `${scope}/${filename}`
    
    // 5. Upload body to R2
    try {
        await S3.send(new PutObjectCommand({
            Bucket: config.r2Bucket,
            Key: r2Path,
            Body: file.data,
            ContentType: file.type,
            // ACL: 'public-read' // R2 is private by default, usually handled by Worker or Public Bucket setting
        }))
    } catch (e: any) {
        console.error('R2 Upload Error:', e)
        throw createError({ statusCode: 500, message: 'Failed to upload file to storage' })
    }

    // 6. Record in global_arquivos
    const client = await serverSupabaseClient(event)
    const { data: fileRecord, error: dbError } = await client
        .from('global_arquivos')
        .insert({
            path: r2Path,
            bucket: 'r2',
            tamanho_bytes: file.data.length,
            mimetype: file.type,
            nome_original: file.filename,
            escopo: scope
        } as any)
        .select('id, path')
        .single()

    if (dbError) {
        console.error('DB Insert Error:', dbError)
        throw createError({ statusCode: 500, message: 'Failed to record file in database' })
    }

    return {
        success: true,
        file: fileRecord
    }
})
