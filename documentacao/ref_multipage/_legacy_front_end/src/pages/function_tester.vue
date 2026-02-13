<script setup>
    import { ref } from 'vue'
    import { supabase } from '../lib/supabase' // Certifique-se que o caminho está correto

    // --- Variáveis de Estado ---
    const functionName = ref('buscar_empresa_por_dominio_publico')
    // Parâmetros em formato String JSON (para fácil edição no input)
    const functionParamsString = ref(JSON.stringify({
        p_dominio: "https://caruaru.conectetecnologia.app/"
    }, null, 2))

    const resultJson = ref(null)
    const isLoading = ref(false)
    const testError = ref(null)

    /**
     * Executa a função RPC no Supabase com os parâmetros fornecidos.
     */
    const executeFunction = async () => {
        isLoading.value = true
        resultJson.value = null
        testError.value = null
        let paramsObject = {}

        // 1. Validar e parsear os parâmetros
        try {
            paramsObject = JSON.parse(functionParamsString.value)
        } catch (e) {
            testError.value = "Erro no formato JSON dos Parâmetros: " + e.message
            isLoading.value = false
            return
        }

        // 2. Executar o RPC
        try {
            console.log(`Chamando RPC: ${functionName.value} com`, paramsObject)

            // Chamada RPC
            const { data, error: rpcError } = await supabase.rpc(functionName.value, paramsObject)

            if (rpcError) {
                throw rpcError
            }

            // 3. Exibir o resultado em JSON formatado
            resultJson.value = JSON.stringify(data, null, 2)

        } catch (err) {
            console.error("Erro na execução do RPC:", err)
            testError.value = `Erro de RPC/Supabase: ${err.message || JSON.stringify(err)}`

        } finally {
            isLoading.value = false
        }
    }
</script>

<template>
    <div class="min-h-screen w-full flex justify-center py-12 bg-background text-text">
        <div class="w-full max-w-3xl bg-div-15 p-8 rounded-xl shadow-2xl space-y-6">

            <h1 class="text-3xl font-bold text-center border-b pb-4 border-secondary/20">
                🧪 Testador de Funções RPC Supabase
            </h1>

            <div class="space-y-4">
                <label class="block font-medium">Nome da Função (RPC Name):</label>
                <input type="text" v-model="functionName" placeholder="Ex: buscar_empresa_por_dominio_publico"
                    class="w-full px-4 py-2 rounded-lg bg-background border border-secondary border-opacity-30 focus:border-primary focus:ring-2 focus:ring-primary outline-none transition-all" />

                <label class="block font-medium pt-2">Parâmetros (JSON Object):</label>
                <textarea v-model="functionParamsString" rows="5" placeholder='{"p_dominio": "..."}'
                    class="w-full p-4 rounded-lg bg-background border border-secondary border-opacity-30 focus:border-primary focus:ring-2 focus:ring-primary outline-none transition-all font-mono"></textarea>
            </div>

            <button @click="executeFunction" :disabled="isLoading"
                class="w-full py-3 px-4 bg-primary hover:bg-primary-dark text-white font-bold rounded-lg transition-colors duration-200 uppercase tracking-wide disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center">
                <span v-if="isLoading">
                    <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg"
                        fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
                        </circle>
                        <path class="opacity-75" fill="currentColor"
                            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                        </path>
                    </svg>
                    Executando...
                </span>
                <span v-else>EXECUTAR RPC</span>
            </button>

            <div class="pt-6 border-t border-secondary/20 space-y-3">
                <h2 class="text-xl font-semibold">Resultado:</h2>

                <div v-if="testError" class="p-4 bg-red-100 text-red-700 border border-red-500 rounded-lg">
                    <p class="font-bold">ERRO DETECTADO:</p>
                    <p class="text-sm break-all">{{ testError }}</p>
                </div>

                <div v-else-if="resultJson">
                    <pre
                        class="bg-gray-900 text-green-400 p-4 rounded-lg overflow-x-auto text-sm font-mono whitespace-pre-wrap">{{ resultJson }}</pre>
                </div>

                <p v-else-if="!isLoading" class="text-secondary/70 italic">
                    Clique em EXECUTAR RPC para testar a função.
                </p>
            </div>

        </div>
    </div>
</template>