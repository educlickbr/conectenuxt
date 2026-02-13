<script setup>
import { onMounted, watch } from 'vue'
import Toast from './components/Toast.vue'
import { supabase } from './lib/supabase'
import { useAppStore } from './stores/app'

const appStore = useAppStore()

const updateMeta = () => {
    // Logic for Title
    let companyName = appStore.companyName
    
    if (companyName) {
        // Ensure capitalization for store value
        companyName = companyName.charAt(0).toUpperCase() + companyName.slice(1)
    }

    if (!companyName) {
        // Try to derive from hostname
        const hostname = window.location.hostname
        if (hostname !== 'localhost') {
            const parts = hostname.split('.')
            if (parts.length > 0) {
               companyName = parts[0].charAt(0).toUpperCase() + parts[0].slice(1)
            }
        }
    }

    if (companyName) {
        document.title = `Conecte ${companyName}`
    } else {
        document.title = 'Conecte'
    }

    // Logic for Favicon
    const link = document.querySelector("link[rel~='icon']") || document.createElement('link');
    link.type = 'image/png';
    link.rel = 'icon';
    
    if (appStore.logo_fechado) {
        link.href = `https://conecteedu.b-cdn.net/public/${appStore.logo_fechado}`;
    } else {
        link.href = 'https://conecteedu.b-cdn.net/public/logo_conecte_new.png';
    }
    
    document.getElementsByTagName('head')[0].appendChild(link);
}

onMounted(async () => {
    const { data: { session } } = await supabase.auth.getSession()
    if (session && session.user) {
        appStore.setUser(session.user)
    }

    // Initial meta update
    updateMeta()

    // Listen for auth changes
    supabase.auth.onAuthStateChange((_event, session) => {
        if (session) {
            appStore.setUser(session.user)
        } else {
            appStore.setUser(null)
        }
    })
})

// Watch for changes in store data (e.g. after login fetches company data)
watch(() => [appStore.companyName, appStore.logo_fechado], () => {
    updateMeta()
})
</script>

<template>
  <router-view />
  <Toast />
</template>

<style>
/* Global styles can go here */
</style>
