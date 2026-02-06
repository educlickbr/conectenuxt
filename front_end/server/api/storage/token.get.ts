import crypto from "crypto";

export default defineEventHandler(async (event) => {
    // 1. Config
    const config = useRuntimeConfig();
    
    // Read from runtimeConfig (server-side only)
    const WORKER_URL = config.workerUrl;
    const SECRET = config.workerAuthSecret;

    if (!SECRET || !WORKER_URL) {
        throw createError({
            statusCode: 500,
            statusMessage:
                "Configuração de Segurança Ausente (WORKER_URL ou WORKER_AUTH_SECRET)",
        });
    }

    // 2. Define Scope and Expiry
    // Scope '/' allows access to all files.
    // We optionally allow passing a specific scope via query param if needed in future
    const query = getQuery(event);
    const scope = (query.scope as string) || "/";
    
    // Expires in 1 Hour (3600000 ms)
    const expires = Date.now() + 3600000;

    // 3. Generate Signature
    // Format must match Worker: HMAC_SHA256(secret, scope + expires)
    const dataToSign = scope + expires;
    const signature = crypto
        .createHmac("sha256", SECRET)
        .update(dataToSign)
        .digest("base64");

    // 4. Return params
    return {
        worker_url: WORKER_URL,
        token: signature,
        expires: expires,
        scope: scope,
        refreshed_at: new Date().toISOString(),
    };
});
