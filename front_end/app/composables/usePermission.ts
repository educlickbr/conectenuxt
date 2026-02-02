import { useAppStore } from '@/stores/app'

export const usePermission = () => {
    const appStore = useAppStore()

    const hasPermission = (permissionKey: string) => {
        return appStore.hasPermission(permissionKey)
    }

    const hasRole = (allowedRoles: string[]) => {
        return appStore.hasRole(allowedRoles)
    }

    return {
        hasPermission,
        hasRole
    }
}
