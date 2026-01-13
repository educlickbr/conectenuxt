import type { Config } from 'tailwindcss'

export default <Partial<Config>>{
    theme: {
        extend: {
            colors: {
                // Base colors with opacity support
                'text': 'rgb(var(--color-text) / <alpha-value>)',
                'background': 'rgb(var(--color-background) / <alpha-value>)',
                'primary': 'rgb(var(--color-primary) / <alpha-value>)',
                'primary-dark': 'rgb(var(--color-primary-hover) / <alpha-value>)', // Alias for backward compat?
                'primary-hover': 'rgb(var(--color-primary-hover) / <alpha-value>)',

                'secondary': 'rgb(var(--color-secondary) / <alpha-value>)',
                'secondary-hover': 'rgb(var(--color-secondary-hover) / <alpha-value>)',

                // Fixed opacity layers
                'div-15': 'rgb(var(--color-secondary-surface) / 0.15)',
                'div-30': 'rgb(var(--color-secondary-surface-hover) / 0.30)',

                'surface': 'rgb(var(--color-surface) / <alpha-value>)',

                'danger': 'rgb(var(--color-danger) / <alpha-value>)',
                'danger-hover': 'rgb(var(--color-danger-hover) / <alpha-value>)',

                'success': 'rgb(var(--color-success) / <alpha-value>)',
                'success-hover': 'rgb(var(--color-success-hover) / <alpha-value>)',

                'warning': 'rgb(var(--color-warning) / <alpha-value>)',
                'warning-hover': 'rgb(var(--color-warning-hover) / <alpha-value>)',
            },
            fontFamily: {
                'sans': ['Inter', 'system-ui', 'Avenir', 'Helvetica', 'Arial', 'sans-serif'],
            }
        }
    },
    plugins: [],
    content: [
        `app/components/**/*.{vue,js,ts}`,
        `app/layouts/**/*.vue`,
        `app/pages/**/*.vue`,
        `app/composables/**/*.{js,ts}`,
        `app/plugins/**/*.{js,ts}`,
        `app/utils/**/*.{js,ts}`,
        `app/App.{js,ts,vue}`,
        `app/app.{js,ts,vue}`,
        `app/Error.{js,ts,vue}`,
        `app/error.{js,ts,vue}`,
        `app/app.config.{js,ts}`
    ]
}
