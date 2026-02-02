export default defineNuxtRouteMiddleware((to, from) => {
    const appStore = useAppStore()
    const toast = useToastStore()

    // Check if the route has a required permission defined in meta
    const requiredPermission = to.meta.permission as string | undefined

    if (requiredPermission) {
        if (!appStore.hasPermission(requiredPermission)) {
            if (process.client) {
                toast.showToast('Você não tem permissão para acessar esta página.', 'error')
            }
            return navigateTo('/')
        }
    }
})
