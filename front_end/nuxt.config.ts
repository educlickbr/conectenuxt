// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',

  // Ativando os módulos
  modules: [
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt',
    '@nuxtjs/supabase'
  ],

  supabase: {
    redirectOptions: {
      login: '/login',
      callback: '/confirm',
      exclude: ['/', '/login', '/admin_teste_26', '/tailwind-test'],
    }
  },

  css: ['~/assets/css/style.css'],

  future: {
    compatibilityVersion: 4,
  },
  devtools: { enabled: true }
})
