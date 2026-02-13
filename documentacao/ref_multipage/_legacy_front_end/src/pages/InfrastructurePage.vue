<script setup>
// multi_pagina_mestre
import { ref, onMounted, watch, computed } from "vue";
import { useRouter, useRoute } from "vue-router";
import { supabase } from "../lib/supabase";
import { useAppStore } from "../stores/app";
import { useToastStore } from "../stores/toast";

// Shared Components
import FullPageMenu from "../components/FullPageMenu.vue";
import UsrListItem from "../components/usr_components/UsrListItem.vue";
import UsrDashboard from "../components/usr_components/UsrDashboard.vue";

// Modals
import ModalGerenciarEscola from "../components/ModalGerenciarEscola.vue";
import ModalGerenciarBbtkPredio from "../components/ModalGerenciarBbtkPredio.vue";
import ModalGerenciarBbtkSala from "../components/ModalGerenciarBbtkSala.vue";
import ModalGerenciarBbtkEstante from "../components/ModalGerenciarBbtkEstante.vue";

const appStore = useAppStore();
const toast = useToastStore();
const router = useRouter();
const route = useRoute();

// --- State ---
const currentTab = ref("escolas"); // 'escolas', 'predio', 'sala', 'estante'
const items = ref([]);
const totalItens = ref(0);
const totalPaginas = ref(0);
const paginaAtual = ref(1);
const limitePorPagina = ref(10);
const busca = ref("");
const isLoading = ref(false);
const isMenuOpen = ref(false);
const isDark = ref(false);

// Modal States
const modalState = ref({
  isOpen: false,
  isDeleteOpen: false,
  selectedItem: null,
  itemToDelete: null,
  isProcessing: false,
});

// --- Constants ---
const TABS = [
  { id: "escolas", label: "Escolas" },
  { id: "predios", label: "Prédios" },
  { id: "salas", label: "Salas" },
  { id: "estantes", label: "Estantes" }, // Changed IDs to match plural/singular consistency if desired, keeping simple
];

// --- Computed ---
const activeModalComponent = computed(() => {
  switch (currentTab.value) {
    case "escolas":
      return ModalGerenciarEscola;
    case "predios":
      return ModalGerenciarBbtkPredio;
    case "salas":
      return ModalGerenciarBbtkSala;
    case "estantes":
      return ModalGerenciarBbtkEstante;
    default:
      return null;
  }
});

// Reuse dashboard logic if needed, or just standard type
const dashboardType = computed(() => {
  return "admin"; // Using generic admin style for now or customize UsrDashboard later
});

const itemType = computed(() => {
  switch (currentTab.value) {
    case "escolas":
      return "escola";
    case "predios":
      return "predio";
    case "salas":
      return "sala";
    case "estantes":
      return "estante";
    default:
      return "escola";
  }
});

// --- Init ---
onMounted(() => {
  initTheme();
  syncTabWithRoute();
});

const syncTabWithRoute = () => {
  const name = route.name;
  // Map route names to tab IDs
  if (name === "infra_predios") currentTab.value = "predios";
  else if (name === "infra_salas") currentTab.value = "salas";
  else if (name === "infra_estantes") currentTab.value = "estantes";
  else currentTab.value = "escolas"; // default route 'infra_escolas' or just 'infra'

  fetchData();
};

watch(
  () => route.name,
  () => {
    syncTabWithRoute();
  }
);

const initTheme = () => {
  const savedTheme = localStorage.getItem("theme");
  isDark.value =
    savedTheme === "dark" ||
    (!savedTheme && window.matchMedia("(prefers-color-scheme: dark)").matches);
  applyTheme();
};

const applyTheme = () => {
  if (isDark.value) document.documentElement.setAttribute("data-theme", "dark");
  else document.documentElement.removeAttribute("data-theme");
};

const toggleTheme = () => {
  isDark.value = !isDark.value;
  localStorage.setItem("theme", isDark.value ? "dark" : "light");
  applyTheme();
};

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value;
};

// --- Data Fetching ---
const fetchData = async () => {
  isLoading.value = true;
  items.value = [];

  try {
    let rpcName = "";
    let params = {
      p_id_empresa: appStore.id_empresa,
      p_pagina: paginaAtual.value,
      p_limite_itens_pagina: limitePorPagina.value,
      p_busca: busca.value || null,
    };

    if (currentTab.value === "escolas") {
      rpcName = "escolas_get_paginado";
    } else if (currentTab.value === "predios") {
      rpcName = "bbtk_dim_predio_get_paginado";
    } else if (currentTab.value === "salas") {
      rpcName = "bbtk_dim_sala_get_paginado";
    } else if (currentTab.value === "estantes") {
      rpcName = "bbtk_dim_estante_get_paginado";
    }

    const { data, error } = await supabase.rpc(rpcName, params);

    if (error) throw error;

    let resultList = [];
    let total = 0;
    let pages = 0;

    if (data) {
      // Normalize RPC return
      const result = Array.isArray(data) ? data[0] : data;
      let rawItems = result.itens || [];

      // Normalize Fields for UsrListItem
      resultList = rawItems.map((item) => ({
        ...item,
        // Normalize *_nome to nome_*
        nome_escola: item.nome_escola || item.escola_nome,
        nome_predio: item.nome_predio || item.predio_nome,
        nome_sala: item.nome_sala || item.sala_nome,
        // Ensure ID consistency if needed (some use uuid, some id)
        // But UsrListItem doesn't use ID for display, only for actions which pass the whole object back
      }));

      total = result.qtd_itens || 0;
      pages = result.qtd_paginas || 0;
    }

    items.value = resultList;
    totalItens.value = total;
    totalPaginas.value = pages;
  } catch (error) {
    console.error(`Erro ao buscar ${currentTab.value}:`, error);
    toast.showToast(`Erro ao carregar ${currentTab.value}`, "error");
  } finally {
    isLoading.value = false;
  }
};

// --- Action Handlers ---

const switchTab = (tabId) => {
  if (tabId === "escolas") router.push({ name: "infra_escolas" });
  else if (tabId === "predios") router.push({ name: "infra_predios" });
  else if (tabId === "salas") router.push({ name: "infra_salas" });
  else if (tabId === "estantes") router.push({ name: "infra_estantes" });
};

const handleAdd = () => {
  modalState.value.selectedItem = null;
  modalState.value.isOpen = true;
};

const handleEdit = (item) => {
  modalState.value.selectedItem = item;
  modalState.value.isOpen = true;
};

const handleDelete = (item) => {
  modalState.value.itemToDelete = item;
  modalState.value.isDeleteOpen = true;
};

const handleSuccess = () => {
  modalState.value.isOpen = false;
  fetchData();
};

// --- Confirm Logic ---

const confirmDelete = async () => {
  if (!modalState.value.itemToDelete) return;
  modalState.value.isProcessing = true;

  try {
    let rpcName = "";
    let idParamName = "p_id";
    let idValue = modalState.value.itemToDelete.id; // Default

    // Handle ID differences
    // Escolas uses 'id' (int8?) or uuid? check EscolasPage.vue: p_id: schoolToDelete.value.id
    // Predio/Sala/Estante use 'uuid'? check BbtkPredioPage.vue: p_id: itemToDelete.value.uuid

    if (currentTab.value === "escolas") {
      rpcName = "escolas_delete";
      idValue = modalState.value.itemToDelete.id;
    } else if (currentTab.value === "predios") {
      rpcName = "bbtk_dim_predio_delete";
      idValue = modalState.value.itemToDelete.uuid;
    } else if (currentTab.value === "salas") {
      rpcName = "bbtk_dim_sala_delete";
      idValue = modalState.value.itemToDelete.uuid;
    } else if (currentTab.value === "estantes") {
      rpcName = "bbtk_dim_estante_delete";
      idValue = modalState.value.itemToDelete.uuid;
    }

    const { error } = await supabase.rpc(rpcName, {
      [idParamName]: idValue,
      p_id_empresa: appStore.id_empresa,
    });

    if (error) throw error;

    toast.showToast("Registro removido com sucesso.", "success");
    modalState.value.isDeleteOpen = false;
    modalState.value.itemToDelete = null;
    fetchData();
  } catch (err) {
    console.error("Erro ao deletar:", err);
    toast.showToast("Erro ao remover registro.", "error");
  } finally {
    modalState.value.isProcessing = false;
  }
};

// --- Pagination & Search ---
const proxPagina = () => {
  if (paginaAtual.value < totalPaginas.value) {
    paginaAtual.value++;
    fetchData();
  }
};
const antPagina = () => {
  if (paginaAtual.value > 1) {
    paginaAtual.value--;
    fetchData();
  }
};

let debounceTimeout = null;
watch(busca, () => {
  if (debounceTimeout) clearTimeout(debounceTimeout);
  debounceTimeout = setTimeout(() => {
    paginaAtual.value = 1;
    fetchData();
  }, 300);
});
</script>

<template>
  <div
    class="h-screen bg-background p-4 flex flex-col md:flex-row gap-4 overflow-hidden font-inter"
  >
    <!-- Left Panel: Header & List -->
    <div class="flex-1 flex flex-col gap-3 h-full overflow-hidden">
      <!-- 1. Main Header (Context & Actions) -->
      <div
        class="bg-div-15 p-3 rounded-xl border border-secondary/20 shadow-sm shrink-0 flex flex-col md:flex-row md:items-center justify-between gap-4"
      >
        <!-- Context: Title & Icon & (Mobile Controls) -->
        <div class="flex items-center justify-between w-full md:w-auto gap-3">
          <!-- Left: Icon & Title -->
          <div class="flex items-center gap-3">
            <div
              class="w-10 h-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center shadow-sm shrink-0"
            >
              <!-- Dynamic Monochrome Icon based on Tab -->
              <svg
                v-if="currentTab === 'escolas'"
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M3 21h18" />
                <path d="M5 21V7l8-4 8 4v14" />
                <path d="M8 14h1v4h-1z" />
                <path d="M12 14h1v4h-1z" />
                <path d="M16 14h1v4h-1z" />
              </svg>
              <svg
                v-if="currentTab === 'predios'"
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <rect x="4" y="2" width="16" height="20" rx="2" ry="2"></rect>
                <line x1="9" y1="22" x2="9" y2="22.01"></line>
                <line x1="15" y1="22" x2="15" y2="22.01"></line>
                <line x1="12" y1="22" x2="12" y2="22.01"></line>
                <line x1="12" y1="17" x2="12" y2="17.01"></line>
                <line x1="12" y1="12" x2="12" y2="12.01"></line>
                <line x1="12" y1="7" x2="12" y2="7.01"></line>
              </svg>
              <svg
                v-if="currentTab === 'salas'"
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path
                  d="M3 21h18M5 21V7l8-4 8 4v14M8 14h1v4h-1zM12 14h1v4h-1zM16 14h1v4h-1z"
                />
                <!-- Using same icon as school/building for now or specific door icon -->
                <path d="M13 3L21 3 21 21 3 21 3 3 11 3"></path>
                <path d="M13 3L13 21"></path>
              </svg>
              <svg
                v-if="currentTab === 'estantes'"
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path
                  d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"
                ></path>
              </svg>
            </div>
            <div class="min-w-0">
              <h1
                class="text-lg font-bold text-text leading-none capitalize truncate"
              >
                {{
                  TABS.find((t) => t.id === currentTab)?.label ||
                  "Infraestrutura"
                }}
              </h1>
              <p
                class="text-xs text-secondary font-medium mt-0.5 whitespace-nowrap"
              >
                {{ totalItens }} registros
              </p>
            </div>
          </div>

          <!-- Right: Mobile Controls (Theme/Menu) -->
          <div class="flex items-center gap-1 md:hidden">
            <button
              @click="toggleTheme"
              class="p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors"
            >
              <svg
                v-if="isDark"
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path
                  d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"
                ></path>
              </svg>
              <svg
                v-else
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <circle cx="12" cy="12" r="5"></circle>
                <line x1="12" y1="1" x2="12" y2="3"></line>
                <line x1="12" y1="21" x2="12" y2="23"></line>
                <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
                <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
                <line x1="1" y1="12" x2="3" y2="12"></line>
                <line x1="21" y1="12" x2="23" y2="12"></line>
                <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
                <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
              </svg>
            </button>
            <button
              @click="toggleMenu"
              class="p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <line x1="3" y1="12" x2="21" y2="12"></line>
                <line x1="3" y1="6" x2="21" y2="6"></line>
                <line x1="3" y1="18" x2="21" y2="18"></line>
              </svg>
            </button>
          </div>
        </div>

        <!-- Actions (Search & Add) -->
        <div
          class="flex items-center gap-2 w-full md:w-auto flex-1 justify-end"
        >
          <div class="relative w-full sm:max-w-[200px]">
            <input
              type="text"
              v-model="busca"
              placeholder="Buscar..."
              class="w-full pl-8 pr-3 py-1.5 text-xs bg-background border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary transition-all placeholder-secondary/70 shadow-sm"
            />
            <span class="absolute left-2.5 top-1.5 text-secondary/70"
              ><svg
                xmlns="http://www.w3.org/2000/svg"
                width="12"
                height="12"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <circle cx="11" cy="11" r="8"></circle>
                <line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg
            ></span>
          </div>

          <button
            @click="handleAdd"
            class="bg-primary hover:bg-primary-hover text-white text-xs font-bold px-4 py-1.5 rounded-lg transition-all shadow-sm hover:shadow-md flex items-center gap-1 shrink-0"
          >
            <span>+</span> <span class="hidden sm:inline">Novo</span>
          </button>

          <div class="hidden md:block h-6 w-[1px] bg-secondary/10 mx-1"></div>

          <button
            @click="toggleTheme"
            class="hidden md:flex p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors"
          >
            <svg
              v-if="isDark"
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
            </svg>
            <svg
              v-else
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <circle cx="12" cy="12" r="5"></circle>
              <line x1="12" y1="1" x2="12" y2="3"></line>
              <line x1="12" y1="21" x2="12" y2="23"></line>
              <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
              <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
              <line x1="1" y1="12" x2="3" y2="12"></line>
              <line x1="21" y1="12" x2="23" y2="12"></line>
              <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
              <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
            </svg>
          </button>
          <button
            @click="toggleMenu"
            class="hidden md:flex p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <line x1="3" y1="12" x2="21" y2="12"></line>
              <line x1="3" y1="6" x2="21" y2="6"></line>
              <line x1="3" y1="18" x2="21" y2="18"></line>
            </svg>
          </button>
        </div>
      </div>

      <!-- 2. Tabs Row (Sleek Below Header) -->
      <div
        class="flex items-center gap-1 border-b border-secondary/10 px-2 overflow-x-auto scrollbar-hide shrink-0 min-h-[36px]"
      >
        <button
          v-for="tab in TABS"
          :key="tab.id"
          @click="switchTab(tab.id)"
          :class="[
            'relative px-3 py-2 text-sm font-medium transition-all whitespace-nowrap outline-none',
            currentTab === tab.id
              ? 'text-primary'
              : 'text-secondary hover:text-text',
          ]"
        >
          {{ tab.label }}
          <!-- Active Indicator -->
          <span
            v-if="currentTab === tab.id"
            class="absolute bottom-0 left-0 w-full h-[2px] bg-primary rounded-t-full"
          ></span>
        </button>
      </div>

      <!-- 3. List Area -->
      <div
        class="flex-1 overflow-y-auto pr-1 flex flex-col gap-2 scrollbar-thin scrollbar-thumb-secondary/20 scrollbar-track-transparent"
      >
        <div v-if="isLoading" class="text-center p-8 text-secondary text-sm">
          Carregando registros...
        </div>

        <div
          v-else-if="items.length === 0"
          class="text-center p-8 text-secondary bg-div-15 rounded-xl border border-secondary/20 border-dashed text-sm"
        >
          Nenhum registro encontrado em
          {{ TABS.find((t) => t.id === currentTab)?.label }}.
        </div>

        <UsrListItem
          v-for="item in items"
          :key="item.id || item.uuid"
          :user="item"
          :type="itemType"
          @edit="handleEdit"
          @delete="handleDelete"
        />

        <!-- Pagination -->
        <div
          class="flex items-center justify-center gap-4 mt-2 py-2"
          v-if="items.length > 0"
        >
          <button
            @click="antPagina"
            :disabled="paginaAtual === 1"
            class="text-xs text-secondary hover:text-primary disabled:opacity-30 disabled:cursor-not-allowed"
          >
            Anterior
          </button>
          <span class="text-xs text-secondary"
            >{{ paginaAtual }} / {{ totalPaginas }}</span
          >
          <button
            @click="proxPagina"
            :disabled="paginaAtual >= totalPaginas"
            class="text-xs text-secondary hover:text-primary disabled:opacity-30 disabled:cursor-not-allowed"
          >
            Próxima
          </button>
        </div>
      </div>
    </div>

    <!-- Right Panel: Dashboard -->
    <UsrDashboard
      :stats="{ total: totalItens, active: 0 }"
      :type="dashboardType"
    />
  </div>

  <!-- Global Modals -->
  <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />

  <!-- Dynamic Manager Modal -->
  <component
    :is="activeModalComponent"
    :isOpen="modalState.isOpen"
    :initialData="modalState.selectedItem"
    @close="modalState.isOpen = false"
    @success="handleSuccess"
  />

  <!-- Generic Delete Modal -->
  <div
    v-if="modalState.isDeleteOpen"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-6 backdrop-blur-sm"
    @click.self="modalState.isDeleteOpen = false"
  >
    <div
      class="bg-background w-full max-w-sm rounded-2xl shadow-2xl border border-secondary/20 overflow-hidden"
    >
      <div class="p-6 flex flex-col items-center text-center gap-4">
        <div
          class="w-12 h-12 rounded-full bg-red-100 text-red-600 flex items-center justify-center"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path
              d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"
            ></path>
            <line x1="12" y1="9" x2="12" y2="13"></line>
            <line x1="12" y1="17" x2="12.01" y2="17"></line>
          </svg>
        </div>
        <div>
          <h3 class="text-lg font-bold text-text">Confirmar Exclusão</h3>
          <p class="text-xs text-secondary mt-1">
            Esta ação removerá o registro selecionado.
          </p>
        </div>
      </div>
      <div
        class="flex items-center gap-3 p-4 bg-div-15 border-t border-secondary/20"
      >
        <button
          @click="modalState.isDeleteOpen = false"
          class="flex-1 py-2 rounded-lg text-secondary text-sm font-medium hover:bg-div-30 transition-colors"
        >
          Cancelar
        </button>
        <button
          @click="confirmDelete"
          :disabled="modalState.isProcessing"
          class="flex-1 py-2 rounded-lg bg-red-600 text-white text-sm font-bold hover:bg-red-700 transition-colors disabled:opacity-50 flex items-center justify-center gap-2"
        >
          <span v-if="modalState.isProcessing" class="animate-spin">⌛</span>
          Sim, Excluir
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Scrollbar hide */
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>
