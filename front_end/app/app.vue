<script setup>
const store = useAppStore()
const user = useSupabaseUser()

// Use useFetch with a custom key to prevent duplicate calls during hydration
// Removed await and set lazy: true to avoid blocking the initial render/hydration
const { data: bffData, refresh: refreshBff, status: bffStatus } = useFetch('/api/me', {
  key: 'bff-session',
  lazy: true
})

// Client-side session sync: Refresh BFF data when the Supabase user changes
if (import.meta.client) {
  watch(user, async (newUser, oldUser) => {
    // Only refresh if the identity actually changed to avoid redundant calls
    if (newUser?.id !== oldUser?.id) {
      await refreshBff()
    }
  })
}

// Update store when bffData changes (works for both SSR and Client)
watch(bffData, (newData) => {
  if (newData) {
    store.user = newData.user
    store.profile = newData.profile
    store.company = newData.company
    store.role = newData.role
  }
}, { immediate: true })

// Mark as initialized when the status is no longer 'idle' or 'pending'
watch(bffStatus, (newStatus) => {
  if (newStatus === 'success' || newStatus === 'error') {
    store.initialized = true
  }
}, { immediate: true })

// Client-only initialization and transition management
const isInitialLoading = useState('global-loading', () => true)
const nuxtApp = useNuxtApp()

// Combined loading state
const showLoading = computed(() => isInitialLoading.value || store.isLoading)

// Robust loading finisher
const finishLoading = (source = 'unknown') => {
  setTimeout(() => {
    isInitialLoading.value = false
    store.setLoading(false)
  }, 400)
}

if (import.meta.client) {
  // Ultra-safety: If nothing happens in 4s, just show the app
  onMounted(() => {
    setTimeout(() => {
      if (isInitialLoading.value) {
        store.initialized = true
        finishLoading('force-timeout')
      }
    }, 4000)
    
    // Initialize Theme
    store.initTheme()

    if (store.initialized) {
      finishLoading('onMounted')
    } else {
      const unwatch = watch(() => store.initialized, (isInit) => {
        if (isInit) {
          finishLoading('watcher')
          unwatch()
        }
      })
    }
  })

  // Page transition hooks
  nuxtApp.hook('page:start', () => {
    store.setLoading(true)
    
    // Safety: If navigation takes too long or fails to mount, force close loading
    setTimeout(() => {
      if (store.isLoading) {
        store.setLoading(false)
        console.warn('Loading overlay closed by safety timeout after navigation delay.')
      }
    }, 5000)
  })

  nuxtApp.hook('page:finish', () => {
    finishLoading('navigation')
  })
}
</script>

<template>
  <div>
    <LoadingOverlay :show="showLoading" />
    <FullPageMenu :isOpen="store.isMenuOpen" @close="store.isMenuOpen = false" />
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
    <Toast />
  </div>
</template>
