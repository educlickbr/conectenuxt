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
import ModalGerenciarProfessor from "../components/ModalGerenciarProfessor.vue";
import ModalGerenciarAluno from "../components/ModalGerenciarAluno.vue";
import ModalGerenciarFamilia from "../components/ModalGerenciarFamilia.vue";
import ModalGerenciarAdmin from "../components/ModalGerenciarAdmin.vue";

const appStore = useAppStore();
const toast = useToastStore();
const router = useRouter();
const route = useRoute();

// --- State ---
const currentTab = ref("professores"); // 'professores', 'alunos', 'familias', 'admins'
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
  isInviteOpen: false,
  selectedItem: null,
  itemToDelete: null,
  itemToInvite: null,
  isProcessing: false, // Generic loading for actions
});

// --- Constants ---
const TABS = [
  { id: "professores", label: "Professores" },
  { id: "alunos", label: "Alunos" },
  { id: "familias", label: "Famílias" },
  { id: "admins", label: "Admins" },
];

// --- Computed ---
const activeModalComponent = computed(() => {
  switch (currentTab.value) {
    case "professores":
      return ModalGerenciarProfessor;
    case "alunos":
      return ModalGerenciarAluno;
    case "familias":
      return ModalGerenciarFamilia;
    case "admins":
      return ModalGerenciarAdmin;
    default:
      return null;
  }
});

const dashboardType = computed(() => {
  switch (currentTab.value) {
    case "professores":
      return "professor";
    case "alunos":
      return "aluno";
    case "familias":
      return "familia";
    case "admins":
      return "admin";
    default:
      return "professor";
  }
});

const itemType = computed(() => {
  switch (currentTab.value) {
    case "professores":
      return "professor";
    case "alunos":
      return "aluno";
    case "familias":
      return "familia";
    case "admins":
      return "admin";
    default:
      return "professor";
  }
});

// --- Init ---
onMounted(() => {
  // Check route for initial tab or default
  // We can pass prop or read logic. For now, read simple logic or default.
  // Ideally we might have /users?tab=professores or /professores redirects here.
  initTheme();
  syncTabWithRoute();
});

// Sync Tab with Route Name
const syncTabWithRoute = () => {
  const name = route.name;
  if (name === "alunos") currentTab.value = "alunos";
  else if (name === "familias") currentTab.value = "familias";
  else if (name === "admin") currentTab.value = "admins";
  else currentTab.value = "professores"; // default

  fetchData();
};

// Watch Route Changes
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
  items.value = []; // clear current list to avoid confusion

  try {
    let rpcName = "";
    let params = {
      p_id_empresa: appStore.id_empresa,
      p_pagina: paginaAtual.value,
      p_limite_itens_pagina: limitePorPagina.value,
      p_busca: busca.value || null,
    };

    // Config per Tab
    if (currentTab.value === "professores") {
      rpcName = "professor_get_paginado";
      params = { ...params, p_id_escola: null, p_status: null };
    } else if (currentTab.value === "alunos") {
      rpcName = "aluno_get_paginado";
      params = { ...params, p_id_escola: null, p_status: null };
    } else if (currentTab.value === "familias") {
      rpcName = "familia_get_paginado";
      // Familia paginado has slightly different params sometimes? Checking FamiliasPage...
      // FamiliasPage uses: p_id_empresa, p_pagina, p_limite_itens_pagina, p_busca. Matches base params.
    } else if (currentTab.value === "admins") {
      rpcName = "admin_get_paginado";
    }

    const { data, error } = await supabase.rpc(rpcName, params);

    if (error) throw error;

    let resultList = [];
    let total = 0;
    let pages = 0;

    if (data) {
      // Handle differences in RPC return structures based on observed files
      // Professor/Aluno: returns array with 1 object containing { itens: [], qtd_itens: ... }
      // Familias/Admin: returns array of items directly, where first item has total_registros?
      // Let's check FamiliasPage: "if (data && data.length > 0) { familias.value = data; totalRegistros.value = data[0].total_registros }"
      // This inconsistency is common. We need to normalize.

      if (["professores", "alunos"].includes(currentTab.value)) {
        const result = Array.isArray(data) ? data[0] : data;
        resultList = result.itens || [];
        total = result.qtd_itens || 0;
        pages = result.qtd_paginas || 0;
      } else {
        // Familias/Admin style
        if (data.length > 0) {
          resultList = data;
          total = data[0].total_registros || 0;
          pages = Math.ceil(total / limitePorPagina.value);
        }
      }
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
  // Navigation updates the route, watcher updates the data
  if (tabId === "professores") router.push({ name: "professores" });
  else if (tabId === "alunos") router.push({ name: "alunos" });
  else if (tabId === "familias") router.push({ name: "familias" });
  else if (tabId === "admins") router.push({ name: "admin" });
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

const handleInvite = (item) => {
  modalState.value.itemToInvite = item;
  modalState.value.isInviteOpen = true;
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
    let idParam = "";

    switch (currentTab.value) {
      case "professores":
        rpcName = "professor_delete";
        idParam = modalState.value.itemToDelete.user_expandido_id;
        break;
      case "alunos":
        rpcName = "aluno_delete";
        idParam = modalState.value.itemToDelete.user_expandido_id;
        break;
      case "familias":
        rpcName = "familia_delete";
        idParam = modalState.value.itemToDelete.id;
        break;
      case "admins":
        rpcName = "admin_delete";
        idParam = modalState.value.itemToDelete.id;
        break;
    }

    const { error } = await supabase.rpc(rpcName, {
      p_id: idParam,
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

const confirmInvite = async () => {
  if (!modalState.value.itemToInvite) return;
  modalState.value.isProcessing = true;

  try {
    let email = modalState.value.itemToInvite.email;
    if (!email) throw new Error("Email não encontrado");

    // Logic split by type
    if (["professores", "alunos"].includes(currentTab.value)) {
      // Use convidar_user_expandido with role
      const roleId =
        currentTab.value === "professores"
          ? "3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1"
          : "b7f53d6e-70b5-453b-b564-728aeb4635d5";

      const payload = {
        professores: [
          {
            // API expects 'professores' key generally?
            email: email,
            papel_id: roleId,
            empresa_id: appStore.id_empresa,
          },
        ],
      };

      const { error } = await supabase.functions.invoke(
        "convidar_user_expandido",
        { body: payload }
      );
      if (error) throw error;
    } else if (currentTab.value === "admins") {
      // Use invite-user
      const { error } = await supabase.functions.invoke("invite-user", {
        body: {
          email: email,
          redirectTo: `${window.location.origin}/reset-password`,
          userType: "admin",
          userId: modalState.value.itemToInvite.id,
        },
      });
      if (error) throw error;
    }

    toast.showToast("Convite enviado com sucesso!", "success");
    modalState.value.isInviteOpen = false;
    modalState.value.itemToInvite = null;
  } catch (err) {
    console.error("Erro ao convidar:", err);
    toast.showToast("Erro ao enviar convite.", "error");
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
                v-if="currentTab === 'professores'"
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
                <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path>
                <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path>
              </svg>
              <svg
                v-if="currentTab === 'alunos'"
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
                <path d="M22 10v6M2 10l10-5 10 5-10 5z"></path>
                <path d="M6 12v5c3 3 9 3 12 0v-5"></path>
              </svg>
              <svg
                v-if="currentTab === 'familias'"
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
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                <circle cx="9" cy="7" r="4"></circle>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
              </svg>
              <svg
                v-if="currentTab === 'admins'"
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
                  d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"
                ></path>
              </svg>
            </div>
            <div class="min-w-0">
              <h1
                class="text-lg font-bold text-text leading-none capitalize truncate"
              >
                {{ currentTab }}
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
          Nenhum registro encontrado em {{ currentTab }}.
        </div>

        <UsrListItem
          v-for="item in items"
          :key="item.id || item.user_expandido_id"
          :user="item"
          :type="itemType"
          @edit="handleEdit"
          @delete="handleDelete"
          @invite="handleInvite"
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

  <!-- Generic Invite Modal -->
  <div
    v-if="modalState.isInviteOpen"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-6 backdrop-blur-sm"
    @click.self="modalState.isInviteOpen = false"
  >
    <div
      class="bg-background w-full max-w-sm rounded-2xl shadow-2xl border border-secondary/20 overflow-hidden"
    >
      <div class="p-6 flex flex-col items-center text-center gap-4">
        <div
          class="w-12 h-12 rounded-full bg-purple-100 text-purple-600 flex items-center justify-center"
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
              d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"
            ></path>
            <polyline points="22,6 12,13 2,6"></polyline>
          </svg>
        </div>
        <div>
          <h3 class="text-lg font-bold text-text">Enviar Convite</h3>
          <p class="text-xs text-secondary mt-1">
            Será enviado um email com instruções de acesso.
          </p>
        </div>
      </div>
      <div
        class="flex items-center gap-3 p-4 bg-div-15 border-t border-secondary/20"
      >
        <button
          @click="modalState.isInviteOpen = false"
          class="flex-1 py-2 rounded-lg text-secondary text-sm font-medium hover:bg-div-30 transition-colors"
        >
          Cancelar
        </button>
        <button
          @click="confirmInvite"
          :disabled="modalState.isProcessing"
          class="flex-1 py-2 rounded-lg bg-purple-600 text-white text-sm font-bold hover:bg-purple-700 transition-colors flex items-center justify-center gap-2"
        >
          <span v-if="modalState.isProcessing" class="animate-spin">⌛</span>
          Confirmar
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
.scrollbar-thin::-webkit-scrollbar {
  width: 4px;
}
.scrollbar-track-transparent::-webkit-scrollbar-track {
  background: transparent;
}
.scrollbar-thumb-secondary\/20::-webkit-scrollbar-thumb {
  background-color: rgb(var(--color-secondary) / 0.2);
  border-radius: 4px;
}
</style>
