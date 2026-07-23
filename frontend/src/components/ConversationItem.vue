<template>
  <button
    class="w-full flex items-center gap-3 px-3 py-3 hover:bg-gray-100 transition-colors text-left"
    :class="{ 'bg-gray-100': active }"
    @click="$emit('select')"
  >
    <UserAvatar :name="displayName" size="md" />
    <div class="flex-1 min-w-0">
      <div class="flex items-baseline justify-between gap-2">
        <span class="font-medium text-sm text-gray-900 truncate">{{ displayName }}</span>
        <span v-if="lastMessageTime" class="text-xs text-gray-400 shrink-0">
          {{ lastMessageTime }}
        </span>
      </div>
      <p class="text-xs text-gray-500 truncate mt-0.5">{{ preview }}</p>
    </div>
  </button>
</template>

<script setup lang="ts">
import UserAvatar from './UserAvatar.vue'

defineProps<{
  displayName: string
  preview: string
  lastMessageTime?: string
  active?: boolean
}>()

defineEmits<{
  select: []
}>()
</script>
