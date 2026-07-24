<template>
  <div
    class="fixed inset-0 bg-black/40 flex items-center justify-center z-50"
    @click.self="$emit('close')"
  >
    <div class="bg-white rounded-2xl shadow-xl w-full max-w-md mx-4 flex flex-col max-h-[80vh]">
      <!-- Header -->
      <div class="flex items-center px-5 pt-5 pb-4 shrink-0">
        <button
          class="text-gray-400 hover:text-gray-600 p-1 border rounded-lg shrink-0"
          @click="$emit('close')"
        >
          <v-icon name="hi-solid-arrow-left" class="h-5 w-5" />
        </button>
        <h2 class="text-lg font-semibold text-gray-900 mx-3">
          {{ conversation?.type === 'group' ? 'Sobre o grupo' : 'Sobre o contato' }}
        </h2>
      </div>

      <div class="flex flex-col items-center px-5 pb-5 shrink-0">
        <UserAvatar :name="title" size="xl" />
        <h3 class="mt-3 text-xl font-semibold text-gray-900">{{ title }}</h3>
        <p v-if="conversation?.type === 'group'" class="text-sm text-gray-400 mt-0.5">
          {{ members?.length ?? 0 }} membros
        </p>
        <p v-else class="text-sm text-gray-400 mt-0.5">@{{ otherUser?.username }}</p>
      </div>

      <div class="border-t border-gray-100 shrink-0" />

      <template v-if="conversation?.type === 'group'">
        <div class="px-5 pt-4 pb-2 shrink-0">
          <p class="text-xs font-semibold text-gray-400 uppercase tracking-wide">Participantes</p>
        </div>
        <div class="flex-1 overflow-y-auto px-5 pb-5">
          <div v-if="loadingMembers" class="text-sm text-gray-400 text-center py-6">
            Carregando...
          </div>
          <div
            v-for="member in enrichedMembers"
            v-else
            :key="member.user_id"
            class="flex items-center gap-3 py-2.5"
          >
            <UserAvatar :name="member.name" size="sm" />
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900">
                {{ member.name }}
                <span v-if="member.isMe" class="text-xs text-gray-400 font-normal">(você)</span>
              </p>
              <p class="text-xs text-gray-400">@{{ member.username }}</p>
            </div>
            <span
              v-if="member.isCreator"
              class="text-xs text-white bg-zinc-700 rounded-full px-2 py-0.5 shrink-0"
            >
              Admin
            </span>
          </div>
        </div>
      </template>

      <template v-else>
        <div class="px-5 pt-4 pb-5">
          <p class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-3">
            Informações
          </p>
          <div class="space-y-3">
            <div class="flex items-center gap-3">
              <v-icon name="hi-user" class="w-4 h-4 text-gray-400 shrink-0" />
              <span class="text-sm text-gray-700">{{ otherUser?.name }}</span>
            </div>
            <div class="flex items-center gap-3">
              <v-icon name="hi-at-symbol" class="w-4 h-4 text-gray-400 shrink-0" />
              <span class="text-sm text-gray-700">{{ otherUser?.username }}</span>
            </div>
            <div class="flex items-center gap-3">
              <v-icon name="hi-mail" class="w-4 h-4 text-gray-400 shrink-0" />
              <span class="text-sm text-gray-700">{{ otherUser?.email }}</span>
            </div>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { useAuthStore } from '@/store/auth'
import { conversationsApi, groupsApi, usersApi } from '@/services/api'
import UserAvatar from './UserAvatar.vue'

const props = defineProps<{ conversationId: string }>()
defineEmits<{ close: [] }>()

const auth = useAuthStore()

const { data: allConversations } = useQuery({
  queryKey: ['conversations'],
  queryFn: () => conversationsApi.list(),
})

const { data: groups } = useQuery({
  queryKey: ['groups'],
  queryFn: () => groupsApi.list(),
})

const { data: users } = useQuery({
  queryKey: ['users'],
  queryFn: () => usersApi.list(),
})

const { data: members, isPending: loadingMembers } = useQuery({
  queryKey: computed(() => ['members', props.conversationId]),
  queryFn: () => conversationsApi.members(props.conversationId),
  enabled: computed(() => !!props.conversationId),
})

const conversation = computed(() =>
  allConversations.value?.find((c) => c.id === props.conversationId),
)

const group = computed(() =>
  groups.value?.find((g) => g.conversation_id === props.conversationId),
)

const usersMap = computed(() => new Map((users.value ?? []).map((u) => [u.id, u])))

const otherUser = computed(() => {
  const other = (members.value ?? []).find((m) => m.user_id !== auth.user?.id)
  return other ? usersMap.value.get(other.user_id) : undefined
})

const title = computed(() => {
  if (conversation.value?.type === 'group') return group.value?.name ?? 'Grupo'
  return otherUser.value?.name ?? '...'
})

const enrichedMembers = computed(() =>
  (members.value ?? []).map((m) => ({
    ...m,
    name: usersMap.value.get(m.user_id)?.name ?? 'Usuário',
    username: usersMap.value.get(m.user_id)?.username ?? '',
    isMe: m.user_id === auth.user?.id,
    isCreator: m.user_id === group.value?.creator_id,
  })).sort((a, b) => {
    if (a.isCreator && !b.isCreator) return -1
    if (!a.isCreator && b.isCreator) return 1
    return a.name.localeCompare(b.name,  'pt-BR', {
  numeric: true,
})
  }),
)
</script>
