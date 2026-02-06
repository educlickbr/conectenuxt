import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3'

export default defineEventHandler(async (event) => {
  const body = await readMultipartFormData(event)

  if (!body || body.length === 0) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Nenhum arquivo enviado.'
    })
  }

  // Configure Client
  const R2_ACCOUNT_ID = process.env.R2_ACCOUNT_ID
  const R2_ACCESS_KEY_ID = process.env.R2_ACCESS_KEY_ID
  const R2_SECRET_ACCESS_KEY = process.env.R2_SECRET_ACCESS_KEY
  const R2_BUCKET = process.env.R2_BUCKET
  const R2_ENDPOINT = process.env.R2_ENDPOINT

  if (!R2_ACCESS_KEY_ID || !R2_SECRET_ACCESS_KEY || !R2_ENDPOINT || !R2_BUCKET) {
     throw createError({
      statusCode: 500,
      statusMessage: 'Credenciais R2 não configuradas.'
    })
  }

  const s3Client = new S3Client({
    region: 'auto',
    endpoint: R2_ENDPOINT,
    credentials: {
      accessKeyId: R2_ACCESS_KEY_ID,
      secretAccessKey: R2_SECRET_ACCESS_KEY,
    },
  })

  const file = body[0]
  const filename = file.filename || 'unknown'
  const key = `uploads/${Date.now()}_${filename}`

  try {
    await s3Client.send(new PutObjectCommand({
      Bucket: R2_BUCKET,
      Key: key,
      Body: file.data,
      ContentType: file.type,
    }))

    return {
      success: true,
      key: key,
      message: 'Arquivo enviado com sucesso!'
    }

  } catch (error) {
    console.error('Erro no upload R2:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Erro ao enviar arquivo para o R2.'
    })
  }
})
