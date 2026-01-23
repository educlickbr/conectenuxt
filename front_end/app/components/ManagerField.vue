<script setup>
const props = defineProps({
  modelValue: [String, Number],
  label: String,
  type: {
    type: String,
    default: 'text' // or 'select'
  },
  placeholder: String,
  options: {
    type: Array,
    default: () => [] // For select: [{ value: 1, label: 'Option' }]
  },
  disabled: Boolean,
  required: Boolean,
  readonly: Boolean,
  error: String
})

const emit = defineEmits(['update:modelValue', 'change'])

const onInput = (e) => emit('update:modelValue', e.target.value)
const onChange = (e) => emit('change', e.target.value)
</script>

<template>
  <div class="flex flex-col gap-1.5 w-full">
    <label v-if="label" class="text-[10px] font-black text-secondary uppercase tracking-[0.15em] flex items-center gap-1 ml-1">
      {{ label }}
      <span v-if="required" class="text-red-500">*</span>
    </label>

    <div class="relative">
      <!-- SELECT -->
      <template v-if="type === 'select'">
        <select
          :value="modelValue"
          @change="onInput($event); onChange($event)"
          :disabled="disabled"
          class="w-full pl-4 pr-10 py-2.5 bg-background border border-[#6B82A71A] text-text text-sm focus:outline-none focus:border-[#3571CB80] focus:ring-4 focus:ring-[#3571CB0D] transition-all appearance-none cursor-pointer disabled:opacity-50"
          :class="[
            error ? 'border-red-500/50' : 'hover:border-[#6B82A74D]',
            'rounded-[var(--radius-sm)]' 
          ]"
        >
          <slot>
            <option v-if="placeholder" value="" disabled selected>{{ placeholder }}</option>
            <option v-for="opt in options" :key="opt.value" :value="opt.value">
              {{ opt.label }}
            </option>
          </slot>
        </select>
        
        <!-- Custom Arrow for Select -->
        <div class="absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none text-[#6B82A780]">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>
        </div>
      </template>
      
      <!-- CUSTOM (SLOT ONLY) -->
      <template v-else-if="type === 'custom'">
          <slot></slot>
      </template>

      <!-- TEXTAREA -->
      <template v-else-if="type === 'textarea'">
        <textarea
          :value="modelValue"
          @input="onInput"
          :placeholder="placeholder"
          :disabled="disabled"
          :readonly="readonly"
          class="w-full px-4 py-3 bg-div-15 border border-[#6B82A71A] text-text text-sm focus:outline-none focus:border-[#3571CB80] focus:ring-4 focus:ring-[#3571CB0D] transition-all disabled:opacity-50 resize-y min-h-[120px]"
          :class="[
            error ? 'border-red-500/50' : 'hover:border-[#6B82A74D]',
            'rounded-[var(--radius-sm)]'
          ]"
        ></textarea>
      </template>

      <!-- INPUT -->
      <template v-else>
        <input
          :type="type"
          :value="modelValue"
          @input="onInput"
          :placeholder="placeholder"
          :disabled="disabled"
          :readonly="readonly"
          class="w-full px-4 py-2.5 bg-div-15 border border-[#6B82A71A] text-text text-sm focus:outline-none focus:border-[#3571CB80] focus:ring-4 focus:ring-[#3571CB0D] transition-all disabled:opacity-50"
          :class="[
            error ? 'border-red-500/50' : 'hover:border-[#6B82A74D]',
            'rounded-[var(--radius-sm)]'
          ]"
        />
      </template>
    </div>

    <span v-if="error" class="text-[10px] text-red-500 font-bold ml-1">{{ error }}</span>
  </div>
</template>

<style scoped>
/* Ensure the standard focus ring doesn't overlap with our custom one */
select:focus, input:focus {
  outline: none;
}

/* Force native options to follow theme colors more strictly */
select option {
  background-color: rgb(var(--color-background));
  color: rgb(var(--color-text));
}
</style>
