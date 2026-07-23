<template>
  <div class="flex flex-col h-full">
    <!-- Header -->
    <template v-if="showSearchSection">
      <div class="flex items-center flex-row px-5 py-3 border-b border-gray-200 shrink-0">
        <button
          class="text-gray-400 hover:text-gray-600 p-1 my-1 border-2 border-gray-200 rounded-xl"
          v-on:click="((cancelSearch = true), (searchQuery = ''), (showSearchSection = false))"
        >
          <!-- Cancel search icon -->
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>
        <span
          class="flex flex-1 flex-row text-sm px-4 mx-3 py-2.5 bg-gray-50 rounded-xl focus:outline-none focus:ring-2 focus:ring-gray-200 border-2 border-gray-400"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
          <input
            type="text"
            placeholder="Pesquisar mensagens..."
            class="w-full text-sm bg-gray-50 mx-2 rounded-xl focus:outline-none"
            v-model="searchQuery"
            @input="searchHandler"
          />
        </span>

        <span class="text-sm text-gray-500">
          {{ searchCount !== 0 ? currentSearchIndex + 1 : 0 }} / {{ searchCount }}
        </span>

        <button
          v-on:click="nextSearchResult"
          class="ml-2 p-2 bg-gray-50 rounded-xl focus:outline-none focus:ring-2 focus:ring-gray-200 border-2 border-gray-200 text-gray-500 hover:text-gray-700"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M5 15l7-7 7 7"
            />
          </svg>
        </button>

        <button
          v-on:click="prevSearchResult"
          class="ml-2 p-2 bg-gray-50 rounded-xl focus:outline-none focus:ring-2 focus:ring-gray-200 border-2 border-gray-200 text-gray-500 hover:text-gray-700"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M19 9l-7 7-7-7"
            />
          </svg>
        </button>
      </div>
    </template>
    <template v-else>
      <div class="flex items-center gap-3 px-5 py-3 border-b border-gray-200 shrink-0">
        <UserAvatar :name="conversationName" size="md" />
        <div class="flex-1 min-w-0">
          <h2 class="font-semibold text-gray-900 text-sm">{{ conversationName }}</h2>
          <p class="text-xs text-gray-400 truncate">{{ subtitle }}</p>
        </div>
        <button class="text-gray-400 hover:text-gray-600 p-1" v-on:click="searchHandler">
          <!-- Search icon -->
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
    </template>

    <!-- Messages -->
    <div ref="messagesContainer" class="flex-1 overflow-y-auto px-6 py-4 space-y-1.5">
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
            <div class="w-full/2 max-w-[800px] mx-auto" :data-message-id="msg.id">
              <div v-if="msg.isMine" class="flex justify-end mb-2">
                <div
                  :class="[
                    'max-w-[65%] bg-zinc-900 text-white rounded-2xl rounded-tr-sm px-4 py-2.5 border-2',
                    highlightedMessageId === msg.id ? 'border-yellow-500' : 'border-zinc-900',
                    highlightedMessageId !== msg.id && searchQuery ? 'opacity-50' : '',
                  ]"
                >
                  <div class="">
                    <p class="text-sm leading-relaxed" v-html="highlightContent(msg.content)" />
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
                  :class="highlightedMessageId !== msg.id && searchQuery ? 'opacity-50' : ''"
                />
                <div
                  :class="[
                    'max-w-[65%] bg-white shadow-sm border border-gray-100 rounded-2xl rounded-tl-sm px-4 py-2.5 border-2',
                    highlightedMessageId === msg.id ? 'border-yellow-500' : 'border-gray-100',
                    highlightedMessageId !== msg.id && searchQuery ? 'opacity-50' : '',
                  ]"
                >
                  <p
                    v-if="conversation?.type === 'group'"
                    class="text-xs font-medium text-gray-600 mb-1 ml-1"
                  >
                    {{ msg.authorName }}
                  </p>
                  <div class="">
                    <p
                      class="text-sm leading-relaxed text-gray-900"
                      v-html="highlightContent(msg.content)"
                    />
                  </div>
                  <div class="flex justify-end">
                    <p class="text-xs text-gray-400 mt-0.5 pr-1">{{ msg.time }}</p>
                  </div>
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
        class="flex-1 text-sm px-4 py-2.5 bg-gray-50 rounded-xl focus:outline-none focus:ring-2 focus:ring-gray-200 border-2 border-gray-200"
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

const cancelSearch = ref(false)
const searchQuery = ref('')
const currentSearchIndex = ref(0)
const showSearchSection = ref(false)
const highlightedMessageId = ref<string | null>(null)

const searchResults = computed(() => {
  const q = searchQuery.value.trim().toLowerCase()
  if (!q) return []
  return localMessages.value.filter((m) => m.content.toLowerCase().includes(q)).reverse()
})

const searchCount = computed(() => searchResults.value.length)

const nextSearchResult = () => {
  if (searchResults.value.length === 0) return
  currentSearchIndex.value = (currentSearchIndex.value + 1) % searchResults.value.length
  scrollToSearchResult()
}
const prevSearchResult = () => {
  if (searchResults.value.length === 0) return
  currentSearchIndex.value =
    (currentSearchIndex.value - 1 + searchResults.value.length) % searchResults.value.length
  scrollToSearchResult()
}
const scrollToSearchResult = () => {
  if (searchResults.value.length === 0 || !messagesContainer.value) return
  const msg = searchResults.value[currentSearchIndex.value]
  highlightedMessageId.value = msg.id
  const msgElement = messagesContainer.value.querySelector(
    `[data-message-id="${msg.id}"]`,
  ) as HTMLElement | null
  if (msgElement) {
    msgElement.scrollIntoView({ behavior: 'smooth', block: 'center' })
  }
}

watch(searchQuery, () => {
  currentSearchIndex.value = 0
  highlightedMessageId.value = null
  if (searchResults.value.length > 0) scrollToSearchResult()
})

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
        return m.user_id === auth.user?.id ? 'Você' : (u?.name?.split(' ')[0] ?? '')
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

function searchHandler() {
  showSearchSection.value = true
}

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;')
}

function highlightContent(content: string): string {
  const q = searchQuery.value.trim()
  const escaped = escapeHtml(content)
  if (!q) return escaped
  const escapedQ = escapeHtml(q).replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  const regex = new RegExp(`\\w*${escapedQ}\\w*`, 'gi')
  return escaped.replace(
    regex,
    '<mark class="bg-yellow-300 text-zinc-900 rounded px-0.5">$&</mark>',
  )
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
