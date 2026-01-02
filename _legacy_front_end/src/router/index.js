import { createRouter, createWebHistory } from "vue-router";
import { supabase } from "../lib/supabase";
import Home from "../pages/Home.vue";
import Login from "../pages/Login.vue";
import Dashboard from "../pages/Dashboard.vue";
import Inicio from "../pages/Inicio.vue";
import FunctionTester from "../pages/function_tester.vue";


import BbtkObraPage from "../pages/BbtkObraPage.vue";
import BbtkInventarioPage from "../pages/BbtkInventarioPage.vue";

import PedagogicoPage from "../pages/PedagogicoPage.vue";

import BibliotecaPage from "../pages/BibliotecaPage.vue";
import BbtkReservasPage from "../pages/BbtkReservasPage.vue";

const routes = [
  { path: "/", name: "login", component: Login },
  { path: "/home", component: Home },
  {
    path: "/dashboard",
    name: "dashboard",
    component: Dashboard,
    meta: { requiresAuth: true },
  },
  {
    path: "/inicio",
    name: "inicio",
    component: Inicio,
    meta: { requiresAuth: true },
  },
  { path: "/function-tester", component: FunctionTester },

  // Library Catalog Routes (Unified)
  {
    path: "/biblioteca/catalogo",
    name: "bbtk_catalogo_editoras",
    component: () => import("../pages/CatalogPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/biblioteca/catalogo/autoria",
    name: "bbtk_catalogo_autoria",
    component: () => import("../pages/CatalogPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/biblioteca/catalogo/categoria",
    name: "bbtk_catalogo_categoria",
    component: () => import("../pages/CatalogPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/biblioteca/catalogo/cdu",
    name: "bbtk_catalogo_cdu",
    component: () => import("../pages/CatalogPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/biblioteca/catalogo/metadado",
    name: "bbtk_catalogo_metadado",
    component: () => import("../pages/CatalogPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/biblioteca/catalogo/doador",
    name: "bbtk_catalogo_doador",
    component: () => import("../pages/CatalogPage.vue"),
    meta: { requiresAuth: true },
  },
  // Educational Routes (Unified)
  {
    path: "/educacional",
    name: "edu_classes",
    component: () => import("../pages/EducationalPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/educacional/ano-etapa",
    name: "edu_ano_etapa",
    component: () => import("../pages/EducationalPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/educacional/horarios",
    name: "edu_horarios",
    component: () => import("../pages/EducationalPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/educacional/turmas",
    name: "edu_turmas",
    component: () => import("../pages/EducationalPage.vue"),
    meta: { requiresAuth: true },
  },

  // Infrastructure Routes (Unified)
  {
    path: "/infraestrutura",
    name: "infra_escolas",
    component: () => import("../pages/InfrastructurePage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/infraestrutura/predios",
    name: "infra_predios",
    component: () => import("../pages/InfrastructurePage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/infraestrutura/salas",
    name: "infra_salas",
    component: () => import("../pages/InfrastructurePage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/infraestrutura/estantes",
    name: "infra_estantes",
    component: () => import("../pages/InfrastructurePage.vue"),
    meta: { requiresAuth: true },
  },

  {
    path: "/usuarios",
    name: "professores",
    component: () => import("../pages/UserManagementPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/usuarios/alunos",
    name: "alunos",
    component: () => import("../pages/UserManagementPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/usuarios/familias",
    name: "familias",
    component: () => import("../pages/UserManagementPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/usuarios/admin",
    name: "admin",
    component: () => import("../pages/UserManagementPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/lms",
    name: "lms",
    component: () => import("../pages/LmsPage.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/lms-consumo",
    name: "lms_consumo",
    component: () => import("../pages/LmsConsumoPageV2.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/lms-v2",
    name: "lms_consumo_v2",
    component: () => import("../pages/LmsConsumoPageV2.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/lms-avaliacao",
    name: "lms_avaliacao",
    component: () => import("../pages/LmsAvaliacaoPage.vue"),
    meta: { requiresAuth: true },
  },
  // Library Operations Routes
  {
    path: "/biblioteca/reservas",
    name: "bbtk_reservas",
    component: BbtkReservasPage,
    meta: { requiresAuth: true },
  },
  {
    path: "/biblioteca/obras",
    name: "bbtk_obra",
    component: BbtkObraPage,
    meta: { requiresAuth: true },
  },
  {
    path: "/biblioteca/inventario",
    name: "bbtk_inventario",
    component: BbtkInventarioPage,
    meta: { requiresAuth: true },
  },
  {
    path: "/biblioteca",
    name: "biblioteca",
    component: BibliotecaPage,
    meta: { requiresAuth: true },
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach(async (to, from, next) => {
  const {
    data: { session },
  } = await supabase.auth.getSession();

  if (to.meta.requiresAuth && !session) {
    next("/");
  } else if (to.path === "/" && session) {
    next("/inicio");
  } else {
    next();
  }
});

export default router;
