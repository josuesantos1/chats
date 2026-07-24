<template>
  <div
    class="flex items-center justify-center rounded-full bg-gray-200 text-gray-700 font-medium shrink-0 select-none"
    :class="sizeClass"
  >
    {{ initials }}
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(
  defineProps<{
    name: string
    size?: 'sm' | 'md' | 'lg' | 'xl'
  }>(),
  { size: 'md' },
)

const initials = computed(() => {
  const words = props.name.trim().split(/\s+/)
  if (words.length === 1) return words[0].slice(0, 2).toUpperCase()
  return (words[0][0] + words[1][0]).toUpperCase()
})

const sizeClass = computed(() => {
  if (props.size === 'sm') return 'w-8 h-8 text-xs'
  if (props.size === 'lg') return 'w-12 h-12 text-base'
  if (props.size === 'xl') return 'w-20 h-20 text-2xl'
  return 'w-10 h-10 text-sm'
})
</script>
