/** @type {import('tailwindcss').Config} */
export default {
    content: [
        // Garante que o Tailwind escaneie todos os arquivos do projeto
        "./index.html",
        "./src/**/*.{vue,js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                // -----------------------------------------------------------
                // 1. CORES BASE
                // -----------------------------------------------------------
                'text': 'var(--color-text)',           // Para text-text
                'background': 'var(--color-background)', // Para bg-background

                // -----------------------------------------------------------
                // 2. CORES PRIMÁRIAS (Principalmente para o botão "ENTRAR")
                // -----------------------------------------------------------
                // Usa 'primary' para bg-primary e hover:bg-primary-dark
                'primary': 'var(--color-primary)',
                'primary-dark': 'var(--color-primary-hover)', // Usado para o estado de hover

                // -----------------------------------------------------------
                // 3. CORES SECUNDÁRIAS (Inclui a cor da caixa de Login)
                // -----------------------------------------------------------
                'secondary': 'var(--color-secondary)',
                'secondary-hover': 'var(--color-secondary-hover)',

                // Mapeia a classe da div de Login (bg-div-15) para a variável CSS
                // que contém a transparência (#6B82A715)
                'div-15': 'var(--color-secondary-surface)',
                'div-30': 'var(--color-secondary-surface-hover)',

                // -----------------------------------------------------------
                // 4. CORES DE ESTADO
                // -----------------------------------------------------------
                'danger': 'var(--color-danger)',          // Para classes de erro (como o erro na tela de login)
                'success': 'var(--color-success)',
                'warning': 'var(--color-warning)',
            },

            // Você pode querer mapear a font-family também
            fontFamily: {
                'sans': ['Inter', 'system-ui', 'Avenir', 'Helvetica', 'Arial', 'sans-serif'],
            }
        },
    },
    plugins: [],
}