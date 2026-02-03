// @ts-ignore
import { defineNuxtRouteMiddleware, navigateTo } from '#app'
import type { RouteLocationNormalized } from 'vue-router'
import { useAppStore } from '../app/stores/app'
import { useToastStore } from '../app/stores/toast'

export default defineNuxtRouteMiddleware((to: RouteLocationNormalized, from: RouteLocationNormalized) => {
    const appStore = useAppStore()
    const toast = useToastStore()

    // Check if the route has a required permission defined in meta
    const requiredPermission = to.meta.permission as string | undefined

    if (requiredPermission) {
        if (!appStore.hasPermission(requiredPermission)) {
            if (typeof window !== 'undefined') {
                toast.showToast('Você não tem permissão para acessar esta página.', 'error')
            }
            return navigateTo('/')
        }
    }
})
