<script setup>
// multi_pagina_mestre
import { ref, onMounted, watch, computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import { supabase } from "../lib/supabase";
import { useAppStore } from "../stores/app";
import { useToastStore } from "../stores/toast";
import FullPageMenu from "../components/FullPageMenu.vue";
import UsrListItem from "../components/usr_components/UsrListItem.vue";
import UsrDashboard from "../components/usr_components/UsrDashboard.vue";

// Modals
import ModalGerenciarBbtkEditora from "../components/ModalGerenciarBbtkEditora.vue";
import ModalGerenciarBbtkAutoria from "../components/ModalGerenciarBbtkAutoria.vue";
import ModalGerenciarBbtkCategoria from "../components/ModalGerenciarBbtkCategoria.vue";
import ModalGerenciarBbtkCdu from "../components/ModalGerenciarBbtkCdu.vue";
import ModalGerenciarBbtkMetadado from "../components/ModalGerenciarBbtkMetadado.vue";
import ModalGerenciarBbtkDoador from "../components/ModalGerenciarBbtkDoador.vue";

const route = useRoute();
const router = useRouter();
const appStore = useAppStore();
const toast = useToastStore();

// UI State
const isMenuOpen = ref(false);
const isModalOpen = ref(false);
const isDeleteModalOpen = ref(false);
const isLoading = ref(false);
const isDeleting = ref(false);

// Data State
const currentTab = ref("editoras");
const items = ref([]);
const totalItens = ref(0);
const totalPaginas = ref(0);
const paginaAtual = ref(1);
const limitePorPagina = ref(10);
const busca = ref("");
const selectedItem = ref(null);
const itemToDelete = ref(null);

// Tab Definitions
const tabs = [
  { id: "editoras", label: "Editoras" },
  { id: "autoria", label: "Autoria" },
  { id: "categoria", label: "Categoria" },
  { id: "cdu", label: "CDU" },
  { id: "metadado", label: "Metadado" },
  { id: "doador", label: "Doador" },
];

const currentTabLabel = computed(
  () => tabs.find((t) => t.id === currentTab.value)?.label || "Editoras"
);

// RPC & Modal Mapping
const getRpcName = () => {
  switch (currentTab.value) {
    case "editoras": return "bbtk_dim_editora_get_paginado";
    case "autoria": return "bbtk_dim_autoria_get_paginado";
    case "categoria": return "bbtk_dim_categoria_get_paginado";
    case "cdu": return "bbtk_dim_cdu_get_paginado";
    case "metadado": return "bbtk_dim_metadado_get_paginado";
    case "doador": return "bbtk_dim_doador_get_paginado";
    default: return "";
  }
};

const getDeleteRpcName = () => {
    switch (currentTab.value) {
    case "editoras": return "bbtk_dim_editora_delete";
    case "autoria": return "bbtk_dim_autoria_delete";
    case "categoria": return "bbtk_dim_categoria_delete";
    case "cdu": return "bbtk_dim_cdu_delete";
    case "metadado": return "bbtk_dim_metadado_delete";
    case "doador": return "bbtk_dim_doador_delete";
    default: return "";
  }
}

// Sync Tab with Route
const syncTabWithRoute = () => {
  const name = route.name;
  if (name === "bbtk_catalogo_autoria") currentTab.value = "autoria";
  else if (name === "bbtk_catalogo_categoria") currentTab.value = "categoria";
  else if (name === "bbtk_catalogo_cdu") currentTab.value = "cdu";
  else if (name === "bbtk_catalogo_metadado") currentTab.value = "metadado";
  else if (name === "bbtk_catalogo_doador") currentTab.value = "doador";
  else currentTab.value = "editoras";

  fetchItems();
};

watch(() => route.name, syncTabWithRoute);

// Tab Switching
const switchTab = (tabId) => {
  currentTab.value = tabId;
  const routeMap = {
    editoras: "bbtk_catalogo_editoras",
    autoria: "bbtk_catalogo_autoria",
    categoria: "bbtk_catalogo_categoria",
    cdu: "bbtk_catalogo_cdu",
    metadado: "bbtk_catalogo_metadado",
    doador: "bbtk_catalogo_doador",
  };
  router.push({ name: routeMap[tabId] });
};

// Data Fetching
const fetchItems = async () => {
  isLoading.value = true;
  items.value = []; // Clear items mostly to avoid flicker of old data
  try {
    const rpcName = getRpcName();
    if (!rpcName) return;

    const { data, error } = await supabase.rpc(rpcName, {
      p_id_empresa: appStore.id_empresa,
      p_pagina: paginaAtual.value,
      p_limite_itens_pagina: limitePorPagina.value,
      p_busca: busca.value || null,
    });

    if (error) throw error;
    
    // Some RPCs might return array directly, others might return [{itens: [], ...}]
    // Based on previous pages, they seem to follow the [{itens: ..., qtd_itens: ...}] pattern
    const result = Array.isArray(data) ? data[0] : data;
    
    if (result) {
        items.value = result.itens || [];
        totalItens.value = result.qtd_itens || 0;
        totalPaginas.value = result.qtd_paginas || 0;
    } else {
         items.value = [];
         totalItens.value = 0;
         totalPaginas.value = 0;
    }

  } catch (error) {
    console.error("Error fetching items:", error);
    toast.showToast("Erro ao carregar dados", "error");
  } finally {
    isLoading.value = false;
  }
};

// Search handling with debounce
let debounceTimeout = null;
watch(busca, () => {
  if (debounceTimeout) clearTimeout(debounceTimeout);
  debounceTimeout = setTimeout(() => {
    paginaAtual.value = 1;
    fetchItems();
  }, 300);
});

watch(paginaAtual, fetchItems);

// CRUD
const handleAdd = () => {
  selectedItem.value = null;
  isModalOpen.value = true;
};

const handleEdit = (item) => {
  selectedItem.value = item;
  isModalOpen.value = true;
};

const handleDelete = (item) => {
  itemToDelete.value = item;
  isDeleteModalOpen.value = true;
};

const confirmDelete = async () => {
    if (!itemToDelete.value) return;
    isDeleting.value = true;
    try {
        const rpcName = getDeleteRpcName();
        if(!rpcName) throw new Error("Delete RPC not found");

        const { error } = await supabase.rpc(rpcName, {
            p_id: itemToDelete.value.uuid, // Assuming all use uuid
            p_id_empresa: appStore.id_empresa
        });

        if (error) throw error;

        toast.showToast("Removido com sucesso.", "success");
        isDeleteModalOpen.value = false;
        fetchItems();
    } catch (error) {
        console.error("Error deleting:", error);
        toast.showToast("Erro ao remover.", "error");
    } finally {
        isDeleting.value = false;
    }
};

// Lifecycle
onMounted(() => {
  syncTabWithRoute();
});

// Mapping item type for UsrListItem
// Since we used 'editora', 'autoria', etc. as tab IDs, we can probably use those or map them if UsrListItem expects something else.
// UsrListItem expects: 'classe', 'ano_etapa', etc. 
// We will simply pass the currentTab.value as the type, but with handling for plural 'editoras' -> 'editora' if needed.
// Actually, let's keep it 'editora' (singular) to match UsrListItem logic if we implement it that way.
// Our tabs are: editoras, autoria, categoria, cdu, metadado, doador.
// Let's use computed property for type.
const itemType = computed(() => {
    if (currentTab.value === 'editoras') return 'editora';
    return currentTab.value;
});

// For Dashboard
const dashboardType = computed(() => {
    // We can just reuse what we have or pass something specific if dashboard logic varies
    // For now simple mapping
    return itemType.value;
});

</script>

<template>
  <div class="h-screen bg-background p-4 flex flex-col md:flex-row gap-4 overflow-hidden font-inter">
    
    <!-- Left Panel: Header & List -->
    <div class="flex-1 flex flex-col gap-3 h-full overflow-hidden">
      
      <!-- 1. Main Header (Context & Actions) -->
      <div class="bg-div-15 p-3 rounded-xl border border-secondary/20 shadow-sm shrink-0 flex flex-col md:flex-row md:items-center justify-between gap-4">
        
        <!-- Context: Title & Icon -->
        <div class="flex items-center justify-between w-full md:w-auto gap-3">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center shadow-sm shrink-0">
              <span v-if="currentTab === 'editoras'" class="text-xl">📚</span>
              <span v-if="currentTab === 'autoria'" class="text-xl">✍️</span>
              <span v-if="currentTab === 'categoria'" class="text-xl">🏷️</span>
              <span v-if="currentTab === 'cdu'" class="text-xl">🔖</span>
              <span v-if="currentTab === 'metadado'" class="text-xl">🔢</span>
              <span v-if="currentTab === 'doador'" class="text-xl">🎁</span>
            </div>
            <div class="min-w-0">
              <h1 class="text-lg font-bold text-text leading-none capitalize truncate">
                {{ currentTabLabel }}
              </h1>
              <p class="text-xs text-secondary font-medium mt-0.5 whitespace-nowrap">
                {{ totalItens }} registros
              </p>
            </div>
          </div>

          <!-- Mobile Controls -->
          <div class="flex items-center gap-1 md:hidden">
             <!-- Theme Toggle handled globally or add logic here if needed, keeping simple for now -->
             <button @click="isMenuOpen = !isMenuOpen" class="p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors">
               <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
             </button>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex items-center gap-2 w-full md:w-auto flex-1 justify-end">
          <div class="relative w-full sm:max-w-[200px]">
            <input
              type="text"
              v-model="busca"
              placeholder="Buscar..."
              class="w-full pl-8 pr-3 py-1.5 text-xs bg-background border border-secondary/30 rounded-lg text-text focus:outline-none focus:border-primary transition-all placeholder-secondary/70 shadow-sm"
            />
            <span class="absolute left-2.5 top-1.5 text-secondary/70">
              <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            </span>
          </div>

          <button
            @click="handleAdd"
            class="bg-primary hover:bg-primary-hover text-white text-xs font-bold px-4 py-1.5 rounded-lg transition-all shadow-sm hover:shadow-md flex items-center gap-1 shrink-0"
          >
            <span>+</span> <span class="hidden sm:inline">Novo</span>
          </button>

          <div class="hidden md:block h-6 w-[1px] bg-secondary/10 mx-1"></div>

          <!-- Menu Desktop -->
          <button @click="isMenuOpen = !isMenuOpen" class="hidden md:flex p-1.5 text-secondary hover:text-primary hover:bg-div-30 rounded-md transition-colors">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
          </button>
        </div>
      </div>

      <!-- 2. Tabs Row -->
      <div class="flex items-center gap-1 border-b border-secondary/10 px-2 overflow-x-auto scrollbar-hide shrink-0 min-h-[36px]">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          @click="switchTab(tab.id)"
          class="relative px-3 py-2 text-sm font-medium transition-all whitespace-nowrap outline-none"
          :class="currentTab === tab.id ? 'text-primary' : 'text-secondary hover:text-text'"
        >
          {{ tab.label }}
          <span v-if="currentTab === tab.id" class="absolute bottom-0 left-0 w-full h-[2px] bg-primary rounded-t-full"></span>
        </button>
      </div>

      <!-- 3. List Area -->
      <div class="flex-1 overflow-y-auto pr-1 flex flex-col gap-2 scrollbar-thin scrollbar-thumb-secondary/20 scrollbar-track-transparent">
        
        <div v-if="isLoading && items.length === 0" class="flex flex-col items-center justify-center h-64 text-secondary gap-3">
           <div class="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
           <span class="text-sm">Carregando...</span>
        </div>

        <div v-else-if="items.length === 0" class="text-center p-8 text-secondary bg-div-15 rounded-xl border border-secondary/20 border-dashed text-sm">
           <span class="block text-2xl mb-2">📭</span>
           Nenhum registro encontrado em {{ currentTabLabel }}.
           <button @click="handleAdd" class="text-xs text-primary hover:underline ml-1">Adicionar novo</button>
        </div>

        <div v-else class="flex flex-col gap-2">
           <UsrListItem
             v-for="item in items"
             :key="item.uuid || item.id"
             :user="item"
             :type="itemType"
             @edit="handleEdit"
             @delete="handleDelete"
           />

           <!-- Pagination -->
           <div class="flex items-center justify-center gap-4 mt-2 py-2">
             <button 
               @click="paginaAtual--" 
               :disabled="paginaAtual === 1"
               class="text-xs text-secondary hover:text-primary disabled:opacity-30 disabled:cursor-not-allowed"
             >
               Anterior
             </button>
             <span class="text-xs text-secondary">{{ paginaAtual }} / {{ totalPaginas }}</span>
             <button 
               @click="paginaAtual++" 
               :disabled="paginaAtual >= totalPaginas"
               class="text-xs text-secondary hover:text-primary disabled:opacity-30 disabled:cursor-not-allowed"
             >
               Próxima
             </button>
           </div>
        </div>
      </div>
    </div>

    <!-- Right Panel: Dashboard -->
    <UsrDashboard
      :user-type="dashboardType"
      :total-users="totalItens"
      :active-users="totalItens" 
      :pending-users="0"
      class="hidden lg:flex w-80 border-l border-secondary/20 bg-background"
    />

    <!-- Modals -->
    <ModalGerenciarBbtkEditora v-if="currentTab === 'editoras'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen = false" @success="fetchItems" />
    <ModalGerenciarBbtkAutoria v-if="currentTab === 'autoria'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen = false" @success="fetchItems" />
    <ModalGerenciarBbtkCategoria v-if="currentTab === 'categoria'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen = false" @success="fetchItems" />
    <ModalGerenciarBbtkCdu v-if="currentTab === 'cdu'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen = false" @success="fetchItems" />
    <ModalGerenciarBbtkMetadado v-if="currentTab === 'metadado'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen = false" @success="fetchItems" />
    <ModalGerenciarBbtkDoador v-if="currentTab === 'doador'" :isOpen="isModalOpen" :initialData="selectedItem" @close="isModalOpen = false" @success="fetchItems" />

    <!-- Delete Modal -->
    <div v-if="isDeleteModalOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4" @click.self="isDeleteModalOpen = false">
      <div class="bg-background w-full max-w-sm rounded-xl shadow-2xl border border-secondary/20 overflow-hidden transform transition-all scale-100">
        <div class="p-6 flex flex-col items-center text-center gap-4">
          <div class="w-16 h-16 rounded-full bg-red-100 text-red-600 flex items-center justify-center mb-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
          </div>
          <h3 class="text-xl font-bold text-text">Excluir Registro?</h3>
          <p class="text-secondary text-sm">
            Tem certeza que deseja remover este item?
            <br>Essa ação não pode ser desfeita.
          </p>
        </div>
        <div class="flex items-center gap-3 p-4 bg-div-15 border-t border-secondary/20">
          <button 
            @click="isDeleteModalOpen = false" 
            class="flex-1 py-2.5 rounded-lg text-secondary font-medium hover:bg-div-30 transition-colors"
          >
            Cancelar
          </button>
          <button 
            @click="confirmDelete" 
            :disabled="isDeleting"
            class="flex-1 py-2.5 rounded-lg bg-red-600 text-white font-bold hover:bg-red-700 transition-colors shadow-lg shadow-red-600/20 disabled:opacity-50 flex items-center justify-center gap-2"
          >
            <span v-if="isDeleting" class="w-4 h-4 border-2 border-white/50 border-t-white rounded-full animate-spin"></span>
            <span>{{ isDeleting ? 'Excluindo...' : 'Excluir' }}</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Full Page Menu -->
    <FullPageMenu :isOpen="isMenuOpen" @close="isMenuOpen = false" />
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
</style>
