export default defineNuxtRouteMiddleware(async (to, from) => {
    const store = useAppStore()
    const user = useSupabaseUser()

    // On the server, we might not have the full profile/role yet, 
    // but we can check the presence of the user session.

    // 1. Root Orchestration
    if (to.path === '/') {
        return navigateTo(user.value ? '/inicio' : '/login')
    }

    // 2. Protected Routes
    const isPublic = ['/login', '/tailwind-test'].includes(to.path)
    if (!isPublic && !user.value) {
        return navigateTo('/login')
    }

    // 3. Prevent logged in users from visiting /login
    if (to.path === '/login' && user.value) {
        return navigateTo('/inicio')
    }
})
