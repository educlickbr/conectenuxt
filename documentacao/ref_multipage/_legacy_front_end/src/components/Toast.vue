<script setup>
import { useToastStore } from '../stores/toast'

const store = useToastStore()
</script>

<template>
  <transition name="toast">
    <div 
      v-if="store.isVisible"
      class="fixed bottom-5 right-5 z-50 px-6 py-4 rounded-lg shadow-lg text-white font-medium flex items-center gap-3 min-w-[300px]"
      :class="store.type === 'error' ? 'bg-danger' : 'bg-success'"
    >
      <!-- Icon (Optional, simple SVG based on type) -->
      <span v-if="store.type === 'error'">⚠️</span>
      <span v-else>✅</span>

      <span>{{ store.message }}</span>

      <!-- Close Button -->
      <button @click="store.hideToast" class="ml-auto text-white hover:text-opacity-80">
        ✕
      </button>
    </div>
  </transition>
</template>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateY(20px);
}
</style>
