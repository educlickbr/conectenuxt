<script setup>
import { ref, onMounted, watch } from "vue";
import { supabase } from "../lib/supabase";
import FullPageMenu from "../components/FullPageMenu.vue";
import ModalGerenciarProfessor from "../components/ModalGerenciarProfessor.vue";
import { useAppStore } from "../stores/app";
import { useToastStore } from "../stores/toast";

const appStore = useAppStore();
const toast = useToastStore();

// State
const professores = ref([]);
const totalItens = ref(0);
const totalPaginas = ref(0);
const paginaAtual = ref(1);
const limitePorPagina = ref(10);
const busca = ref("");
const isLoading = ref(false);

// UI States
const isMenuOpen = ref(false);
const isModalOpen = ref(false);
const isDeleteModalOpen = ref(false);
const professorToDelete = ref(null);
const selectedProfessor = ref(null);
const isDeleting = ref(false);

const isInviting = ref(false);
const isInviteModalOpen = ref(false);
const professorToInvite = ref(null);
const isDark = ref(false);

// Init Theme
onMounted(() => {
  const savedTheme = localStorage.getItem("theme");
  if (savedTheme) {
    isDark.value = savedTheme === "dark";
  } else {
    isDark.value = window.matchMedia("(prefers-color-scheme: dark)").matches;
  }
  applyTheme();
  fetchProfessores();
});

const applyTheme = () => {
  if (isDark.value) {
    document.documentElement.setAttribute("data-theme", "dark");
  } else {
    document.documentElement.removeAttribute("data-theme");
  }
};

const toggleTheme = () => {
  isDark.value = !isDark.value;
  localStorage.setItem("theme", isDark.value ? "dark" : "light");
  applyTheme();
};

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value;
};

// Data Fetching
const fetchProfessores = async () => {
  isLoading.value = true;
  try {
    const { data, error } = await supabase.rpc("professor_get_paginado", {
      p_id_empresa: appStore.id_empresa,
      p_pagina: paginaAtual.value,
      p_limite_itens_pagina: limitePorPagina.value,
      p_busca: busca.value || null,
      p_id_escola: null, // Opcional
      p_status: null, // Opcional
    });

    if (error) throw error;

    if (data) {
      const result = Array.isArray(data) ? data[0] : data;
      professores.value = result.itens || [];
      totalItens.value = result.qtd_itens || 0;
      totalPaginas.value = result.qtd_paginas || 0;
    } else {
      professores.value = [];
      totalItens.value = 0;
      totalPaginas.value = 0;
    }
  } catch (error) {
    console.error("Erro ao buscar professores:", error);
    toast.showToast("Erro ao carregar professores", "error");
  } finally {
    isLoading.value = false;
  }
};

// Actions Handlers
const handleAdd = () => {
  selectedProfessor.value = null;
  isModalOpen.value = true;
};

const handleSuccess = () => {
  fetchProfessores();
};

const handleEdit = (professor) => {
  selectedProfessor.value = professor;
  isModalOpen.value = true;
};

const handleDelete = (professor) => {
  professorToDelete.value = professor;
  isDeleteModalOpen.value = true;
};

const confirmDelete = async () => {
  if (!professorToDelete.value) return;

  isDeleting.value = true;
  try {
    const { error } = await supabase.rpc("professor_delete", {
      p_id: professorToDelete.value.user_expandido_id,
      p_id_empresa: appStore.id_empresa,
    });

    if (error) throw error;

    isDeleteModalOpen.value = false;
    professorToDelete.value = null;
    fetchProfessores();
    toast.showToast("Professor removido com sucesso.", "success");
  } catch (err) {
    console.error("Erro ao deletar professor:", err);
    toast.showToast("Erro ao remover professor", "error");
  } finally {
    isDeleting.value = false;
  }
};

// Invite Handlers
const handleInvite = (professor) => {
  if (!professor.email) {
    toast.showToast("Email não encontrado para este professor.", "warning");
    return;
  }
  professorToInvite.value = professor;
  isInviteModalOpen.value = true;
};

const confirmInvite = async () => {
  if (!professorToInvite.value) return;

  isInviting.value = true;
  try {
    const payload = {
      professores: [
        {
          email: professorToInvite.value.email,
          papel_id: "3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1",
          empresa_id: appStore.id_empresa,
        },
      ],
    };

    const { error } = await supabase.functions.invoke(
      "convidar_user_expandido",
      {
        body: payload,
      }
    );

    if (error) throw error;

    toast.showToast("Convite enviado com sucesso!", "success");
    isInviteModalOpen.value = false;
    professorToInvite.value = null;
  } catch (error) {
    console.error("Erro ao convidar professor:", error);
    toast.showToast("Erro ao enviar convite.", "error");
  } finally {
    isInviting.value = false;
  }
};

// Pagination Handlers
const proxPagina = () => {
  if (paginaAtual.value < totalPaginas.value) {
    paginaAtual.value++;
  }
};

const antPagina = () => {
  if (paginaAtual.value > 1) {
    paginaAtual.value--;
  }
};

// Watchers
let debounceTimeout = null;
watch(busca, (newVal) => {
  if (debounceTimeout) clearTimeout(debounceTimeout);
  debounceTimeout = setTimeout(() => {
    paginaAtual.value = 1;
    fetchProfessores();
  }, 300);
});

watch(paginaAtual, () => {
  fetchProfessores();
});
</script>

<template>
  <div
    class="h-screen bg-background p-4 md:p-6 flex flex-col md:flex-row gap-4 overflow-hidden"
  >
    <!-- Left Panel: Header & List (Flexible Width) -->
    <div class="flex-1 flex flex-col gap-4 h-full overflow-hidden">
      <!-- Compact Header -->
      <div
        class="flex flex-col sm:flex-row items-center justify-between gap-4 bg-div-15 p-3 rounded-xl border border-secondary/20 shadow-sm shrink-0"
      >
        <div class="flex items-center gap-3 w-full sm:w-auto">
          <div
            class="w-10 h-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center font-bold text-xl"
          >
            👨‍🏫
          </div>
          <div>
            <h1 class="text-lg font-bold text-text leading-tight">
              Professores
            </h1>
            <p class="text-xs text-secondary">{{ totalItens }} registros</p>
          </div>
        </div>

        <div
          class="flex items-center gap-2 w-full sm:w-auto flex-1 justify-end"
        >
          <!-- Search -->
          <div class="relative w-full sm:max-w-xs">
            <input
              type="text"
              v-model="busca"
              placeholder="Buscar..."
              class="w-full pl-9 pr-3 py-1.5 text-sm bg-background border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary transition-all placeholder-secondary/70"
            />
            <span class="absolute left-3 top-2 text-secondary/70"
              ><svg
                xmlns="http://www.w3.org/2000/svg"
                width="14"
                height="14"
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
            class="bg-primary hover:bg-primary-hover text-white text-sm font-medium px-4 py-1.5 rounded-lg transition-colors whitespace-nowrap shadow-sm"
          >
            + Novo
          </button>

          <div class="h-6 w-[1px] bg-secondary/20 mx-1"></div>

          <button
            @click="toggleTheme"
            class="p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors"
          >
            <svg
              v-if="isDark"
              xmlns="http://www.w3.org/2000/svg"
              width="18"
              height="18"
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
              width="18"
              height="18"
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
              width="18"
              height="18"
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

      <!-- List Area -->
      <div
        class="flex-1 overflow-y-auto pr-1 flex flex-col gap-2 scrollbar-thin scrollbar-thumb-secondary/20 scrollbar-track-transparent"
      >
        <div
          v-if="isLoading && professores.length === 0"
          class="text-center p-8 text-secondary text-sm"
        >
          Carregando lista...
        </div>

        <div
          v-else-if="professores.length === 0"
          class="text-center p-8 text-secondary bg-div-15 rounded-xl border border-secondary/20 border-dashed text-sm"
        >
          Nenhum professor encontrado.
        </div>

        <div
          v-for="prof in professores"
          :key="prof.user_expandido_id"
          class="relative bg-div-15 py-3 px-6 rounded-md border-l-4 border-l-transparent hover:border-l-primary transition-all flex flex-col sm:flex-row sm:items-center justify-between group shadow-sm gap-4 hover:shadow-md"
        >
          <div class="flex items-center gap-3 overflow-hidden">
            <div
              class="w-8 h-8 rounded bg-background flex shrink-0 items-center justify-center text-text text-sm font-bold border border-secondary/10"
            >
              {{ prof.nome_completo.charAt(0).toUpperCase() }}
            </div>
            <div class="min-w-0">
              <h3
                class="font-semibold text-text text-sm truncate leading-tight"
              >
                {{ prof.nome_completo }}
              </h3>
              <div
                class="flex items-center gap-2 text-xs text-secondary mt-0.5"
              >
                <span class="truncate" title="Escola">
                  {{ prof.nome_escola || "Sem escola" }}
                </span>
                <span
                  class="w-1 h-1 rounded-full bg-secondary/40 shrink-0"
                ></span>
                <span
                  :class="
                    prof.status === 'Ativo' ? 'text-green-500' : 'text-red-500'
                  "
                  class="font-medium text-[10px] uppercase tracking-wider"
                  >{{ prof.status }}</span
                >
              </div>
            </div>
          </div>

          <div
            class="flex items-center gap-1 self-end sm:self-auto sm:opacity-0 sm:group-hover:opacity-100 transition-opacity"
          >
            <button
              @click="handleInvite(prof)"
              class="w-8 h-8 flex items-center justify-center rounded bg-purple-50 text-purple-600 hover:bg-purple-100 transition-colors"
              title="Convidar"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="14"
                height="14"
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
            </button>
            <button
              @click="handleEdit(prof)"
              class="w-8 h-8 flex items-center justify-center rounded bg-blue-50 text-blue-600 hover:bg-blue-100 transition-colors"
              title="Editar"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="14"
                height="14"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path
                  d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"
                ></path>
                <path
                  d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"
                ></path>
              </svg>
            </button>
            <button
              @click="handleDelete(prof)"
              class="w-8 h-8 flex items-center justify-center rounded bg-red-50 text-red-600 hover:bg-red-100 transition-colors"
              title="Apagar"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="14"
                height="14"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <polyline points="3 6 5 6 21 6"></polyline>
                <path
                  d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"
                ></path>
                <line x1="10" y1="11" x2="10" y2="17"></line>
                <line x1="14" y1="11" x2="14" y2="17"></line>
              </svg>
            </button>
          </div>
        </div>

        <!-- Pagination (Bottom of list) -->
        <div class="flex items-center justify-center gap-4 mt-2 py-2">
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

    <!-- Right Panel: Data & Insights (Fixed Width on Desktop) -->
    <div
      class="hidden md:flex w-80 lg:w-96 flex-col bg-div-15 rounded-xl border border-secondary/20 p-5 shadow-sm shrink-0 gap-6"
    >
      <div class="flex items-center justify-between">
        <h2 class="font-bold text-text text-lg">Visão Geral</h2>
        <div
          class="p-1.5 bg-background rounded-lg text-secondary cursor-pointer hover:text-primary transition-colors"
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
            <circle cx="12" cy="12" r="1"></circle>
            <circle cx="19" cy="12" r="1"></circle>
            <circle cx="5" cy="12" r="1"></circle>
          </svg>
        </div>
      </div>

      <!-- Cards -->
      <div class="grid grid-cols-2 gap-3">
        <div
          class="bg-background p-3 rounded-xl border border-secondary/10 flex flex-col"
        >
          <span
            class="text-[10px] text-secondary uppercase font-bold tracking-wider"
            >Total</span
          >
          <span class="text-2xl font-bold text-primary mt-1">{{
            totalItens
          }}</span>
        </div>
        <div
          class="bg-background p-3 rounded-xl border border-secondary/10 flex flex-col"
        >
          <span
            class="text-[10px] text-secondary uppercase font-bold tracking-wider"
            >Ativos</span
          >
          <!-- Dummy value roughly based on total -->
          <span class="text-2xl font-bold text-green-500 mt-1">{{
            Math.floor(totalItens * 0.9)
          }}</span>
        </div>
      </div>

      <!-- Dummy Chart Section -->
      <div class="flex-1 flex flex-col gap-3">
        <h3 class="text-sm font-semibold text-text/80">Carga Horária Média</h3>
        <div
          class="flex-1 bg-background/50 rounded-xl border border-secondary/10 p-4 flex items-end justify-between gap-2 relative overflow-hidden"
        >
          <!-- Dummy Bars -->
          <div
            class="w-full bg-primary/20 h-[40%] rounded-t-sm hover:bg-primary/40 transition-colors relative group"
          >
            <div
              class="absolute -top-6 left-1/2 -translate-x-1/2 bg-text text-background text-[10px] px-1 rounded opacity-0 group-hover:opacity-100 transition-opacity"
            >
              12h
            </div>
          </div>
          <div
            class="w-full bg-primary/20 h-[65%] rounded-t-sm hover:bg-primary/40 transition-colors relative group"
          >
            <div
              class="absolute -top-6 left-1/2 -translate-x-1/2 bg-text text-background text-[10px] px-1 rounded opacity-0 group-hover:opacity-100 transition-opacity"
            >
              24h
            </div>
          </div>
          <div
            class="w-full bg-primary h-[85%] rounded-t-sm hover:bg-primary/80 transition-colors relative group shadow-lg shadow-primary/20"
          >
            <div
              class="absolute -top-6 left-1/2 -translate-x-1/2 bg-text text-background text-[10px] px-1 rounded opacity-0 group-hover:opacity-100 transition-opacity"
            >
              40h
            </div>
          </div>
          <div
            class="w-full bg-primary/20 h-[50%] rounded-t-sm hover:bg-primary/40 transition-colors relative group"
          >
            <div
              class="absolute -top-6 left-1/2 -translate-x-1/2 bg-text text-background text-[10px] px-1 rounded opacity-0 group-hover:opacity-100 transition-opacity"
            >
              30h
            </div>
          </div>
          <div
            class="w-full bg-primary/20 h-[30%] rounded-t-sm hover:bg-primary/40 transition-colors relative group"
          >
            <div
              class="absolute -top-6 left-1/2 -translate-x-1/2 bg-text text-background text-[10px] px-1 rounded opacity-0 group-hover:opacity-100 transition-opacity"
            >
              8h
            </div>
          </div>
        </div>
        <p class="text-[10px] text-center text-secondary">
          Dados fictícios para visualização
        </p>
      </div>

      <!-- Recent Activity Mini List -->
      <div class="mt-auto">
        <h3 class="text-sm font-semibold text-text/80 mb-3">
          Atividades Recentes
        </h3>
        <div class="space-y-3">
          <div class="flex items-center gap-3 text-xs">
            <div class="w-2 h-2 rounded-full bg-green-500"></div>
            <span class="text-secondary flex-1 truncate"
              >Novo professor cadastrado</span
            >
            <span class="text-secondary/50">2h</span>
          </div>
          <div class="flex items-center gap-3 text-xs">
            <div class="w-2 h-2 rounded-full bg-blue-500"></div>
            <span class="text-secondary flex-1 truncate"
              >Alteração de contrato</span
            >
            <span class="text-secondary/50">1d</span>
          </div>
          <div class="flex items-center gap-3 text-xs">
            <div class="w-2 h-2 rounded-full bg-purple-500"></div>
            <span class="text-secondary flex-1 truncate">Convite enviado</span>
            <span class="text-secondary/50">2d</span>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Modals (Outside the grid) -->
  <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />

  <ModalGerenciarProfessor
    :isOpen="isModalOpen"
    :initialData="selectedProfessor"
    @close="isModalOpen = false"
    @success="handleSuccess"
  />

  <!-- Delete Modal -->
  <div
    v-if="isDeleteModalOpen"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-6 backdrop-blur-sm"
    @click.self="isDeleteModalOpen = false"
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
          <h3 class="text-lg font-bold text-text">Demitir Professor?</h3>
          <p class="text-xs text-secondary mt-1">
            Atenção: Esta ação realizará uma exclusão lógica de
            <b class="text-text">{{ professorToDelete?.nome_completo }}</b
            >.
          </p>
        </div>
      </div>
      <div
        class="flex items-center gap-3 p-4 bg-div-15 border-t border-secondary/20"
      >
        <button
          @click="isDeleteModalOpen = false"
          class="flex-1 py-2 rounded-lg text-secondary text-sm font-medium hover:bg-div-30 transition-colors"
        >
          Cancelar
        </button>
        <button
          @click="confirmDelete"
          :disabled="isDeleting"
          class="flex-1 py-2 rounded-lg bg-red-600 text-white text-sm font-bold hover:bg-red-700 transition-colors disabled:opacity-50 flex items-center justify-center gap-2"
        >
          <span v-if="isDeleting" class="animate-spin">⌛</span>
          Sim, Demitir
        </button>
      </div>
    </div>
  </div>

  <!-- Invite Confirmation Modal -->
  <div
    v-if="isInviteModalOpen"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-6 backdrop-blur-sm"
    @click.self="isInviteModalOpen = false"
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
            Será enviado um email para
            <b class="text-text">{{ professorToInvite?.email }}</b> com
            instruções de acesso.
          </p>
        </div>
      </div>
      <div
        class="flex items-center gap-3 p-4 bg-div-15 border-t border-secondary/20"
      >
        <button
          @click="isInviteModalOpen = false"
          class="flex-1 py-2 rounded-lg text-secondary text-sm font-medium hover:bg-div-30 transition-colors"
        >
          Cancelar
        </button>
        <button
          @click="confirmInvite"
          :disabled="isInviting"
          class="flex-1 py-2 rounded-lg bg-purple-600 text-white text-sm font-bold hover:bg-purple-700 transition-colors flex items-center justify-center gap-2 shadow-lg shadow-purple-600/20"
        >
          <span v-if="isInviting" class="animate-spin">⌛</span>
          Confirmar
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Sleek scrollbar for the list */
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
