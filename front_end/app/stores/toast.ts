import { defineStore } from 'pinia'

export const useToastStore = defineStore('toast', {
    state: () => ({
        message: '',
        type: 'success' as 'success' | 'error',
        isVisible: false,
        timeout: null as any
    }),
    actions: {
        showToast(message: string, type: 'success' | 'error' = 'success') {
            this.message = message
            this.type = type
            this.isVisible = true

            if (this.timeout) {
                clearTimeout(this.timeout)
            }

            this.timeout = setTimeout(() => {
                this.hideToast()
            }, 3000)
        },
        hideToast() {
            this.isVisible = false
            this.message = ''
        }
    }
})
