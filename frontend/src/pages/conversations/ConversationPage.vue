<template>
  <div class="flex flex-col h-full">
    <!-- Header -->
    <div class="flex items-center gap-3 px-5 py-3 border-b border-gray-200 shrink-0">
      <UserAvatar :name="conversationName" size="md" />
      <div class="flex-1 min-w-0">
        <h2 class="font-semibold text-gray-900 text-sm">{{ conversationName }}</h2>
        <p class="text-xs text-gray-400 truncate">{{ subtitle }}</p>
      </div>
      <button class="text-gray-400 hover:text-gray-600 p-1">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
          />
        </svg>
      </button>
    </div>

    <!-- Messages -->
    <div ref="messagesContainer" class="flex-1 overflow-y-auto px-6 py-4">
      <template v-if="loadingMessages">
        <div class="text-sm text-gray-400 text-center py-8">Carregando mensagens...</div>
      </template>
      <template v-else-if="groupedMessages.length === 0">
        <div class="text-sm text-gray-400 text-center py-8">Nenhuma mensagem ainda</div>
      </template>
      <template v-else>
        <template v-for="group in groupedMessages" :key="group.date">
          <!-- Date separator -->
          <div class="flex justify-center py-3">
            <span class="text-xs text-gray-400 px-3 py-0.5 rounded-full">
              {{ group.date }}
            </span>
          </div>

          <!-- Messages in group -->
          <template v-for="msg in group.messages" :key="msg.id">
            <!-- Sent message -->
            <div v-if="msg.isMine" class="flex justify-end mb-2">
              <div class="max-w-[65%] bg-zinc-900 text-white rounded-2xl rounded-tr-sm px-4 py-2.5">
                <div class="">
                  <p class="text-sm leading-relaxed">{{ msg.content }}</p>
                </div>
                <p class="text-xs text-gray-400 mt-0.5 text-right pr-1">{{ msg.time }}</p>
              </div>
            </div>

            <!-- Received message -->
            <div v-else class="flex items-end gap-2 mb-2">
              <UserAvatar
                v-if="conversation?.type === 'group'"
                :name="msg.authorName"
                size="sm"
              />
              <div class="max-w-[65%] bg-white shadow-sm border border-gray-100 rounded-2xl rounded-tl-sm px-4 py-2.5">
                <p
                  v-if="conversation?.type === 'group'"
                  class="text-xs font-medium text-gray-600 mb-1 ml-1"
                >
                  {{ msg.authorName }}
                </p>
                <div
                  class=""
                >
                  <p class="text-sm leading-relaxed text-gray-900">{{ msg.content }}</p>
                </div>
                <div class="flex justify-end">
                  <p class="text-xs text-gray-400 mt-0.5 pr-1">{{ msg.time }}</p>
                </div>
              </div>
            </div>
          </template>
        </template>
      </template>
    </div>

    <!-- Input -->
    <div class="border-t border-gray-200 px-4 py-3 flex items-center gap-3 shrink-0">
      <input
        v-model="newMessage"
        type="text"
        placeholder="Escreva uma mensagem..."
        class="flex-1 text-sm px-4 py-2.5 bg-gray-50 rounded-xl focus:outline-none focus:ring-2 focus:ring-gray-200 border-0"
        @keyup.enter="handleSend"
      />
      <button
        class="w-10 h-10 bg-zinc-900 text-white rounded-xl flex items-center justify-center hover:bg-zinc-700 transition-colors shrink-0 disabled:opacity-50"
        :disabled="!newMessage.trim() || sending"
        @click="handleSend"
      >
        <svg class="w-4 h-4 rotate-45" fill="currentColor" viewBox="0 0 24 24">
          <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z" />
        </svg>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, nextTick, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { useAuthStore } from '@/store/auth'
import { conversationsApi, groupsApi, usersApi } from '@/services/api'
import { getSocket } from '@/services/socket'
import UserAvatar from '@/components/UserAvatar.vue'
import type { Message, Conversation } from '@/types'

const route = useRoute()
const auth = useAuthStore()
const queryClient = useQueryClient()
const messagesContainer = ref<HTMLElement | null>(null)

const conversationId = computed(() => route.params.id as string)
const newMessage = ref('')
const sending = ref(false)

const localMessages = ref<Message[]>([])

let activeChannel: any = null

function onNewMessage(msg: Message) {
  if (!localMessages.value.find((m) => m.id === msg.id)) {
    localMessages.value.push(msg)
  }
  queryClient.setQueryData(['conversations'], (old: Conversation[] | undefined) => {
    if (!old) return old
    return old.map((c) =>
      c.id === msg.conversation_id
        ? { ...c, last_message: { content: msg.content, inserted_at: msg.inserted_at } }
        : c,
    )
  })
}

watch(
  conversationId,
  (newId, oldId) => {
    if (oldId && activeChannel) {
      activeChannel.leave()
      activeChannel = null
    }
    if (!newId) return
    const channel = getSocket().channel(`conversation:${newId}`)
    channel.on('new_message', (payload: Message) => onNewMessage(payload))
    channel.join().receive('error', (err) => console.error('Channel join error:', err))
    activeChannel = channel
  },
  { immediate: true },
)

onUnmounted(() => {
  activeChannel?.leave()
  activeChannel = null
})

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

const { data: members } = useQuery({
  queryKey: computed(() => ['members', conversationId.value]),
  queryFn: () => conversationsApi.members(conversationId.value),
  enabled: computed(() => !!conversationId.value),
})

const { data: initialMessages, isPending: loadingMessages } = useQuery({
  queryKey: computed(() => ['messages', conversationId.value]),
  queryFn: () => conversationsApi.messages(conversationId.value),
  enabled: computed(() => !!conversationId.value),
})

watch(
  () => initialMessages.value,
  (msgs) => {
    if (msgs) localMessages.value = [...msgs]
  },
  { immediate: true },
)


const conversation = computed(() =>
  allConversations.value?.find((c) => c.id === conversationId.value),
)

const usersMap = computed(() => new Map((users.value ?? []).map((u) => [u.id, u])))

const conversationName = computed(() => {
  if (!conversation.value) return '...'
  if (conversation.value.type === 'group') {
    const group = (groups.value ?? []).find((g) => g.conversation_id === conversationId.value)
    return group?.name ?? 'Grupo'
  }
  const otherMember = (members.value ?? []).find((m) => m.user_id !== auth.user?.id)
  if (otherMember) {
    return usersMap.value.get(otherMember.user_id)?.name ?? 'Usuário'
  }
  return 'Conversa privada'
})

const subtitle = computed(() => {
  if (!conversation.value) return ''
  if (conversation.value.type === 'group') {
    const memberCount = members.value?.length ?? 0
    const memberNames = (members.value ?? [])
      .slice(0, 3)
      .map((m) => {
        const u = usersMap.value.get(m.user_id)
        return m.user_id === auth.user?.id ? 'Você' : u?.name?.split(' ')[0] ?? ''
      })
      .filter(Boolean)
    const extra = memberCount > 3 ? ` +${memberCount - 3}` : ''
    return `${memberCount} membros · ${memberNames.join(', ')}${extra}`
  }
  return ''
})

const enrichedMessages = computed(() => {
  return localMessages.value.map((msg) => ({
    ...msg,
    isMine: msg.author_id === auth.user?.id,
    authorName: usersMap.value.get(msg.author_id)?.name ?? 'Usuário',
    time: formatTime(msg.inserted_at),
    dateKey: formatDateKey(msg.inserted_at),
  }))
})

const groupedMessages = computed(() => {
  const dateGroups: { date: string; messages: (typeof enrichedMessages.value)[number][] }[] = []
  for (const msg of enrichedMessages.value) {
    const existing = dateGroups.find((g) => g.date === msg.dateKey)
    if (existing) {
      existing.messages.push(msg)
    } else {
      dateGroups.push({ date: msg.dateKey, messages: [msg] })
    }
  }
  return dateGroups
})

function formatTime(isoString: string) {
  try {
    const d = new Date(isoString)
    return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
  } catch {
    return ''
  }
}

function formatDateKey(isoString: string) {
  try {
    const d = new Date(isoString)
    const today = new Date()
    const yesterday = new Date(today)
    yesterday.setDate(yesterday.getDate() - 1)
    if (d.toDateString() === today.toDateString()) return 'Hoje'
    if (d.toDateString() === yesterday.toDateString()) return 'Ontem'
    return d.toLocaleDateString('pt-BR')
  } catch {
    return ''
  }
}

async function handleSend() {
  if (!newMessage.value.trim() || !auth.user || sending.value || !activeChannel) return
  sending.value = true
  const content = newMessage.value.trim()
  newMessage.value = ''
  try {
    const msg = await new Promise<Message>((resolve, reject) => {
      activeChannel
        .push('send_message', {
          content,
          author_id: auth.user!.id,
          conversation_id: conversationId.value,
        })
        .receive('ok', (m: Message) => resolve(m))
        .receive('error', (err: unknown) => reject(err))
    })
    onNewMessage(msg)
  } catch {
    newMessage.value = content
  } finally {
    sending.value = false
  }
}

watch(
  () => localMessages.value.length,
  async () => {
    await nextTick()
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  },
)
</script>
