<script setup>
const store = useAppStore()
</script>

<template>
  <div class="h-screen bg-background flex flex-col gap-4 p-5 overflow-hidden font-sans">
    
    <!-- Row 1: Header Area + Top Right Info -->
    <!-- The Left side contains Header (and optionally tabs if placed there) to match height of Right side -->
    <div class="shrink-0 flex flex-col md:flex-row gap-4">
        
        <!-- Top Left: Header + Tabs Wrapper -->
        <!-- Transparent wrapper to allow children to simulate manager.vue layout -->
        <div class="flex-1 flex flex-col gap-3 transition-all relative">
            
            <!-- Header (Styled like manager.vue) -->
            <header class="bg-div-15 px-4 py-3 rounded border border-secondary/5 flex items-center justify-between shrink-0">
                 <div class="flex items-center gap-4">
                     <slot name="header-icon" />
                     <div class="min-w-0">
                        <h1 class="text-xl font-bold text-text leading-tight tracking-tight flex items-center gap-3">
                            <slot name="header-title" />
                        </h1>
                        <p class="text-xs text-secondary font-medium mt-0.5 opacity-60">
                            <slot name="header-subtitle" />
                        </p>
                     </div>
                 </div>

                 <div class="flex items-center gap-4">
                     <slot name="header-actions" />
                     
                     <!-- Global Controls -->
                     <div class="flex items-center gap-2 ml-2 border-l border-white/5 pl-2">
                        <button @click="store.toggleTheme()" class="w-9 h-9 flex items-center justify-center rounded text-secondary hover:text-primary hover:bg-white/5 transition-all">
                             <svg v-if="!store.isDark" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
                             <svg v-else xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
                        </button>
                        <button @click="store.toggleMenu()" class="w-9 h-9 flex items-center justify-center rounded text-secondary hover:text-primary hover:bg-white/5 transition-all">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
                        </button>
                     </div>
                 </div>
            </header>
            
            <!-- Tabs (Below header, transparent strip) -->
            <nav v-if="$slots.tabs" class="flex items-center gap-1 border-b border-primary px-2 overflow-x-auto no-scrollbar shrink-0 min-h-[40px] mt-auto">
                <slot name="tabs" />
            </nav>
        </div>

        <!-- Top Right Quadrant (Info) -->
        <aside v-if="$slots['top-right']" class="flex w-full md:w-[320px] lg:w-[380px] bg-div-15 rounded border border-secondary/5 flex-col p-5 shadow-sm relative overflow-hidden">
             <slot name="top-right">
                <div class="flex items-center justify-center h-full text-secondary text-xs">Slot: top-right</div>
             </slot>
        </aside>
    </div>

    <!-- Row 2: Sidebar (Left) + Main Content (Right) -->
    <div class="flex-1 flex flex-col md:flex-row gap-4 overflow-hidden">
        
        <!-- Sidebar (Left) - MOVED HERE -->
        <aside class="flex w-full md:w-[320px] lg:w-[380px] bg-div-15 rounded border border-secondary/5 p-5 overflow-y-auto custom-scrollbar flex-col gap-4 shadow-sm">
             <slot name="sidebar">
                <div class="text-secondary text-xs text-center">Slot: sidebar</div>
             </slot>
        </aside>

        <!-- Main Content (Right) -->
        <main class="flex-1 flex flex-col h-full overflow-hidden rounded border border-secondary/5 bg-background relative">
             <div class="flex-1 overflow-y-auto p-5 custom-scrollbar bg-surface/30">
                 <slot />
             </div>
        </main>

    </div>
    
    <slot name="modals" />
  </div>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar { display: none; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(var(--color-secondary-rgb), 0.1); border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
</style>
