<script setup>
import { useAppStore } from '../stores/app'
import { ref, onMounted } from 'vue'

const store = useAppStore()

// Tema local (carrega do store ou fallback)
const theme = ref(store.theme || 'light')

// Aplica o tema ao <html>
function applyTheme() {
  document.documentElement.setAttribute('data-theme', theme.value)
  store.theme = theme.value  // opcional: mantém sincronizado
}

function toggleTheme() {
  theme.value = theme.value === 'light' ? 'dark' : 'light'
  applyTheme()
}

// Aplica tema ao carregar página
onMounted(() => {
  applyTheme()
})
</script>

<template>
  <div class="home">
    <h1>Home Page</h1>

    <p>Welcome to the building blocks of your new app.</p>

    <p>Count: {{ store.count }}</p>
    <button @click="store.increment">Increment</button>

    <br /><br />

    <!-- Botão de tema -->
    <button class="theme-toggle" @click="toggleTheme">
      Tema atual: {{ theme }}
    </button>
  </div>
</template>

<style scoped>
.home {
  text-align: center;
  padding: 2rem;
}

/* Botão do tema */
.theme-toggle {
  padding: 0.6rem 1rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;

  background: var(--color-primary);
  color: var(--color-background);
  font-weight: 600;
  transition: background 0.2s;
}

.theme-toggle:hover {
  background: var(--color-primary-hover);
}
</style>

