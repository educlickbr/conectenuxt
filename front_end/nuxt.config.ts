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

  runtimeConfig: {
    workerUrl: process.env.WORKER_URL,
    workerAuthSecret: process.env.WORKER_AUTH_SECRET,
  },

  css: ['~/assets/css/style.css'],

  future: {
    compatibilityVersion: 4,
  },
  devtools: { enabled: true }
})
