import { defineStore } from 'pinia'

export const useToastStore = defineStore('toast', {
    state: () => ({
        message: '',
        type: 'success', // 'success' | 'error'
        isVisible: false,
        timeout: null
    }),
    actions: {
        showToast(message, type = 'success') {
            this.message = message
            this.type = type
            this.isVisible = true

            // Clear existing timeout if present
            if (this.timeout) {
                clearTimeout(this.timeout)
            }

            // Auto hide after 3 seconds
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
