<script setup>
import { computed } from "vue";

const props = defineProps({
  user: {
    type: Object,
    required: true,
  },
  type: {
    type: String,
    required: true,
    validator: (value) =>
      [
        "professor",
        "aluno",
        "familia",
        "admin",
        "escola",
        "predio",
        "sala",
        "estante",
        "classe", 
        "ano_etapa", 
        "horario", 
        "turma", 
        // Library Types
        "editora",
        "autoria",
        "categoria",
        "cdu",
        "metadado",
        "doador",
      ].includes(value),
  },
});

const emit = defineEmits(["edit", "delete", "invite"]);

// Icon selection
const icon = computed(() => {
  switch (props.type) {
    case "professor":
      return "👨‍🏫";
    case "aluno":
      return "👨‍🎓";
    case "familia":
      return "👨‍👩‍👧‍👦";
    case "admin":
      return "👔";
    case "escola":
      return "🏫";
    case "predio":
      return "🏢";
    case "sala":
      return "🚪";
    case "estante":
      return "📚";
    case "classe": 
      return "📋"; // Added
    case "ano_etapa": 
      return "📅"; // Added
    case "horario": 
      return "⏰"; // Added
    case "turma": 
      return "🎓"; 
      // Library Types
    case "editora": return "📚";
    case "autoria": return "✍️";
    case "categoria": return "🏷️";
    case "cdu": return "🔖";
    case "metadado": return "🔢";
    case "doador": return "🎁";
    default:
      return "👤";
  }
});

// Avatar Color
const avatarClass = computed(() => {
  switch (props.type) {
    case "professor":
      return "bg-primary/10 text-primary";
    case "aluno":
      return "bg-green-100 text-green-600";
    case "familia":
      return "bg-blue-100 text-blue-600";
    case "admin":
      return "bg-purple-100 text-purple-600";
    case "escola":
      return "bg-orange-100 text-orange-600";
    case "predio":
      return "bg-indigo-100 text-indigo-600";
    case "sala":
      return "bg-teal-100 text-teal-600";
    case "estante":
      return "bg-yellow-100 text-yellow-600";
    case "classe": 
      return "bg-blue-100 text-blue-600"; // Added
    case "ano_etapa": 
      return "bg-green-100 text-green-600"; // Added
    case "horario": 
      return "bg-purple-100 text-purple-600"; // Added
    case "turma": 
      return "bg-pink-100 text-pink-600";
      // Library Types
    case "editora": return "bg-amber-100 text-amber-600";
    case "autoria": return "bg-cyan-100 text-cyan-600";
    case "categoria": return "bg-teal-100 text-teal-600";
    case "cdu": return "bg-rose-100 text-rose-600";
    case "metadado": return "bg-slate-100 text-slate-600";
    case "doador": return "bg-emerald-100 text-emerald-600";
    default:
      return "bg-secondary/10 text-secondary";
  }
});

// Name Display
const displayName = computed(() => {
  if (props.type === "familia") return props.user.nome_familia;
  if (
    props.type === "escola" ||
    props.type === "predio" ||
    props.type === "sala" ||
    props.type === "estante" ||
    props.type === "classe" ||
    props.type === "ano_etapa" ||
    props.type === "horario"
  )
    return props.user.nome;
  if (props.type === "turma") return props.user.nome_escola; // Turma uses school name as primary title
  if (props.type === "autoria") return props.user.nome_completo;
  if (!props.user.nome_completo && props.user.nome) return props.user.nome;
  return props.user.nome_completo;
});

// Status/Subtitle Logic
const statusColor = computed(() => {
  if (!props.user.status) return "text-secondary";
  return props.user.status === "Ativo" ? "text-green-500" : "text-red-500";
});
</script>

<template>
  <div
    class="relative bg-div-15 py-3 px-6 rounded-md border-l-4 border-l-transparent hover:border-l-primary transition-all flex flex-col sm:flex-row sm:items-center justify-between group shadow-sm gap-4 hover:shadow-md"
  >
    <div class="flex items-center gap-3 min-w-0 overflow-hidden">
      <!-- Avatar -->
      <div
        :class="[
          'w-8 h-8 rounded bg-background flex shrink-0 items-center justify-center text-sm font-bold border border-secondary/10',
          avatarClass,
        ]"
      >
        <span
          v-if="
            ['professor', 'aluno', 'familia', 'admin'].includes(type) &&
            user.nome_completo
          "
          >{{ user.nome_completo.charAt(0).toUpperCase() }}</span
        >
        <span v-else>{{ icon }}</span>
      </div>

      <!-- Info -->
      <div class="min-w-0">
        <h3 class="font-semibold text-text text-sm truncate leading-tight pr-2">
          {{ displayName }}
        </h3>

        <div
          class="flex flex-wrap items-center gap-x-2 gap-y-1 text-xs text-secondary mt-0.5"
        >
          <!-- Type Specific Fields -->

          <!-- Professor/Aluno: Escola -->
          <span
            v-if="['professor', 'aluno'].includes(type)"
            class="truncate"
            title="Escola"
          >
            {{ user.nome_escola || "Sem escola" }}
          </span>

          <!-- Aluno: Matricula -->
          <span
            v-if="type === 'aluno' && user.matricula"
            class="truncate text-secondary/70"
          >
            • {{ user.matricula }}
          </span>

          <!-- Familia: Responsavel -->
          <span
            v-if="type === 'familia' && user.responsavel_principal"
            class="truncate"
          >
            Resp: {{ user.responsavel_principal }}
          </span>

          <!-- Familia: Qtd Alunos -->
          <span v-if="type === 'familia'" class="truncate">
            • {{ user.qtd_alunos }} alunos
          </span>

          <!-- Admin: Email -->
          <span v-if="type === 'admin'" class="truncate">
            {{ user.email }}
          </span>

          <!-- Infra Specifics -->
          <span v-if="type === 'escola'" class="truncate">
            {{ user.endereco }}
          </span>

          <span
            v-if="
              (type === 'predio' || type === 'sala' || type === 'estante') &&
              user.nome_escola
            "
            class="truncate"
          >
            {{ user.nome_escola }}
          </span>
          <span
            v-if="(type === 'sala' || type === 'estante') && user.nome_predio"
            class="truncate"
          >
            • {{ user.nome_predio }}
          </span>
          <span v-if="type === 'estante' && user.nome_sala" class="truncate">
            • {{ user.nome_sala }}
          </span>

          <!-- Educational Specifics -->
          <span v-if="type === 'classe'" class="text-xs px-2 py-0.5 rounded-full bg-secondary/10 text-secondary">
            Ordem: {{ user.ordem }}
          </span>
          <span v-if="type === 'ano_etapa'" class="flex items-center gap-2">
              <span class="text-xs px-2 py-0.5 rounded-full bg-primary/10 text-primary uppercase font-bold tracking-wider">{{ user.tipo }}</span>
              <span v-if="user.carg_horaria" class="text-xs text-secondary">CH: {{ user.carg_horaria }}h</span>
          </span>
          <span v-if="type === 'horario'" class="text-xs text-secondary">
            {{ user.periodo }} | {{ user.hora_inicio }} - {{ user.hora_fim }}
          </span>
          <span v-if="type === 'turma'" class="flex flex-col items-start gap-1">
               <span class="text-base text-primary font-medium">{{ user.nome_turma }} - {{ user.ano }}</span>
               <span class="text-[10px] text-secondary/80 uppercase tracking-wider font-semibold px-2 py-0.5 rounded bg-secondary/10 w-fit">{{ user.periodo }}</span>
          </span>

          <!-- Library Specifics -->
          <span v-if="type === 'editora' && user.email" class="text-xs text-secondary">{{ user.email }}</span>
          <span v-if="type === 'autoria' && user.codigo_cutter" class="text-xs text-secondary font-mono bg-secondary/5 px-1 rounded">{{ user.codigo_cutter }}</span>
          <span v-if="type === 'cdu' && user.codigo" class="text-xs text-primary font-mono font-bold">{{ user.codigo }}</span>
          <span v-if="type === 'doador' && user.email" class="text-xs text-secondary">{{ user.email }}</span>
          <span v-if="type === 'categoria' && user.descricao" class="text-xs text-secondary truncate max-w-[200px]">{{ user.descricao }}</span>

          <!-- Separator & Status -->
          <span
            v-if="user.status"
            class="hidden sm:inline-block w-1 h-1 rounded-full bg-secondary/40 shrink-0 mx-1"
          ></span>

          <span
            v-if="user.status"
            :class="[
              'font-medium uppercase tracking-wider text-[10px]',
              statusColor,
            ]"
          >
            {{ user.status }}
          </span>
        </div>
      </div>
    </div>

    <!-- Actions -->
    <div
      class="flex items-center gap-1 self-end sm:self-auto sm:opacity-0 sm:group-hover:opacity-100 transition-opacity"
    >
      <button
        @click="$emit('invite', user)"
        class="w-8 h-8 flex items-center justify-center rounded bg-purple-50 text-purple-600 hover:bg-purple-100 transition-colors"
        title="Convidar"
        v-if="type !== 'familia'"
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
        @click="$emit('edit', user)"
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
        @click="$emit('delete', user)"
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
</template>
