<script setup lang="ts">
import { ref } from 'vue'
import { generateUuidFileName } from '../../utils/file'

definePageMeta({
    layout: false
})

const fileInput = ref<HTMLInputElement | null>(null)
const status = ref('')
const isUploading = ref(false)
const uploadedKey = ref('')

const handleUpload = async () => {
    const input = fileInput.value
    if (!input || !input.files || input.files.length === 0) {
        status.value = 'Selecione um arquivo primeiro.'
        return
    }

    const file = input.files[0]
    if (!file) return // Should not happen given length check

    // Generate UUID name (sanitization)
    const newFileName = generateUuidFileName(file.name)

    const formData = new FormData()
    // Append with the NEW name
    formData.append('file', file, newFileName)

    isUploading.value = true
    status.value = 'Enviando...'
    uploadedKey.value = ''

    try {
        const res = await $fetch('/api/upload-test', {
            method: 'POST',
            body: formData
        }) as any

        status.value = `Sucesso: ${res.message}`
        uploadedKey.value = res.key
        
        // Auto-set the test path for immediate testing
        testPath.value = res.key
    } catch (error: any) {
        console.error(error)
        status.value = `Erro: ${error.data?.statusMessage || error.message}`
    } finally {
        isUploading.value = false
    }
}

// R2 Test Logic
const testPath = ref('uploads/1770137090301_WhatsApp Image 2026-02-03 at 08.26.07 (2).jpeg')

const handleOpenR2 = async () => {
    if (!testPath.value) {
        alert("Informe o caminho do arquivo")
        return
    }

    try {
        const tokenData = await $fetch('/api/storage/token', {
            query: { scope: '/' } // Using root scope for simplicity as per implementation
        }) as any

        // Construct URL matching Worker expectations
        const fileUrl = `${tokenData.worker_url}/${testPath.value}?token=${encodeURIComponent(tokenData.token)}&expires=${tokenData.expires}&scope=${encodeURIComponent(tokenData.scope)}`

        window.open(fileUrl, '_blank')
        console.log("Opened URL:", fileUrl)

    } catch (err: any) {
        console.error(err)
        alert("Erro ao gerar token: " + err.message)
    }
}


// Migration Logic
const isMigrating = ref(false)
const migrationResult = ref<any[]>([])
const currentOffset = ref(0)
const BATCH_SIZE = 5

const handleMigration = async () => {
    isMigrating.value = true
    currentOffset.value = 0 // Reset to start from beginning
    migrationResult.value = [] // Clear previous results
    
    try {
        while (isMigrating.value) {
            const res: any = await $fetch('/api/migration/bunny-to-r2', {
                method: 'POST',
                body: { limit: BATCH_SIZE, offset: currentOffset.value }
            })

            // Append results LOG only (don't keep everything in memory if huge)
            // Or just keep the last batch to show progress
            migrationResult.value = [res, ...migrationResult.value]
            
            if (res.results && res.results.length > 0) {
                 currentOffset.value += BATCH_SIZE
                 console.log(`Processed batch starting at ${currentOffset.value}`)
            } else {
                alert("Migração Concluída! Nenhum registro restante.")
                isMigrating.value = false
                break
            }
        }
    } catch (err: any) {
        console.error(err)
        alert('Erro na migração: ' + err.message)
        isMigrating.value = false
    } 
}

const stopMigration = () => {
    isMigrating.value = false
}

</script>

<template>
    <div class="min-h-screen bg-base-100 flex items-center justify-center p-4">
        <div class="bg-surface border border-div-15 rounded-lg p-8 w-full max-w-md shadow-lg">
            <h1 class="text-2xl font-bold text-text mb-6">Teste Upload R2</h1>
            
            <div class="space-y-4">
                <input 
                    type="file" 
                    ref="fileInput" 
                    class="file-input file-input-bordered file-input-primary w-full" 
                />
                
                <button 
                    @click="handleUpload" 
                    :disabled="isUploading"
                    class="btn btn-primary w-full font-bold"
                >
                    <span v-if="isUploading" class="loading loading-spinner"></span>
                    {{ isUploading ? 'Enviando...' : 'Fazer Upload' }}
                </button>
            </div>

            <div v-if="status" class="mt-6 p-4 rounded-lg bg-div-05 border border-div-15 text-sm font-medium">
                <p :class="status.startsWith('Erro') ? 'text-error' : 'text-success'">
                    {{ status }}
                </p>
                <div v-if="uploadedKey" class="mt-2 text-secondary text-xs">
                    Key: <span class="font-mono bg-base-100 px-1 rounded">{{ uploadedKey }}</span>
                </div>
            </div>

            <!-- R2 Access Test Section -->
            <div class="mt-8 pt-6 border-t border-div-15">
                <h2 class="text-lg font-bold text-text mb-4">Testar Acesso R2 (Secure)</h2>
                
                <div class="space-y-4">
                    <div class="form-control">
                        <label class="label"><span class="label-text">Caminho do Arquivo (Key)</span></label>
                        <input 
                            v-model="testPath" 
                            type="text" 
                            class="input input-bordered input-sm w-full font-mono"
                            placeholder="uploads/seu-arquivo.jpg"
                        />
                    </div>
                     <button 
                        @click="handleOpenR2" 
                        class="btn btn-secondary btn-sm w-full font-bold"
                    >
                        Abrir Arquivo Seguro (Nova Aba)
                    </button>
                    <div class="text-[10px] text-gray-500 text-center">
                        Gera token temporário via /api/storage/token e redireciona.
                    </div>
                </div>
            </div>


            <!-- Migration Test Section -->
            <div class="mt-8 pt-6 border-t border-div-15">
                <h2 class="text-lg font-bold text-text mb-4">Migração Bunny -> R2</h2>
                <div class="space-y-4">
                     <button 
                        @click="handleMigration" 
                        class="btn btn-accent btn-sm w-full font-bold"
                        :disabled="isMigrating"
                    >
                        <span v-if="isMigrating" class="loading loading-spinner"></span>
                        {{ isMigrating ? `Migrando... (Offset: ${currentOffset})` : 'Iniciar Migração Contínua' }}
                    </button>
                    
                     <button 
                        v-if="isMigrating"
                        @click="stopMigration" 
                        class="btn btn-error btn-sm w-full font-bold mt-2"
                    >
                        Parar Migração
                    </button>
                    <div v-if="migrationResult" class="text-xs bg-base-100 p-2 rounded max-h-40 overflow-auto whitespace-pre-wrap">
                        {{ JSON.stringify(migrationResult, null, 2) }}
                    </div>
                </div>
            </div>

             <div class="mt-8 text-center">
                 <NuxtLink to="/" class="text-xs text-secondary hover:text-primary transition-colors">
                     Voltar para Home
                 </NuxtLink>
             </div>
        </div>
    </div>
</template>
