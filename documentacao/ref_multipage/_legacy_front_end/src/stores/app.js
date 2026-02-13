import { defineStore } from 'pinia'

export const useAppStore = defineStore('app', {
    state: () => ({
        count: 0, // Keeping original state example
        id_empresa: null,
        logo_aberto: null,
        logo_fechado: null,
        companyName: null,
        // Configuration
        empresa_local: 'https://caruaru.conectetecnologia.app',
        // User State
        user: null,
        user_role_id: null,
        user_role_name: null
    }),
    actions: {
        increment() {
            this.count++
        },
        setCompanyData(data) {
            this.id_empresa = data.empresa_id;
            this.logo_aberto = data.logo_grande;
            this.logo_fechado = data.logo_pequeno;
            this.companyName = data.nome;
        },
        setUser(user) {
            this.user = user;
        },
        async logout(supabase, router, toast) {
            const { error } = await supabase.auth.signOut()

            // Clear local state regardless of server error
            this.user = null
            this.user_role_id = null
            this.user_role_name = null

            if (router) router.push('/')

            if (error) {
                // Ignore session_not_found as it means we are already logged out on server
                if (error.message && !error.message.includes('session_not_found')) {
                    if (toast) toast.showToast(error.message, 'error')
                    return false
                }
            }

            if (toast) toast.showToast('Logout realizado com sucesso.', 'success')
            return true
        },
        async fetchUserRole(supabase) {
            try {
                const { data, error } = await supabase.rpc('papeis_user_auth_get_my_role');
                if (error) throw error;

                if (data && data.length > 0) {
                    this.user_role_id = data[0].papel_id;
                    this.user_role_name = data[0].nome;
                    return data[0];
                } else {
                    console.warn('User has no role assigned.');
                    return null;
                }
            } catch (err) {
                console.error('Error fetching user role:', err);
                return null;
            }
        }
    },
    persist: true,
})
