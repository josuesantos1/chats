<template>
  <div class="flex h-screen bg-white overflow-hidden">
    <!-- Left sidebar -->
    <aside class="w-[280px] border-r border-gray-200 flex flex-col shrink-0">
      <!-- Top buttons -->
      <div class="flex gap-2 p-3 border-b border-gray-100">
        <button
          class="flex-1 flex items-center justify-center gap-1.5 text-sm text-gray-700 border border-gray-200 rounded-lg py-1.5 hover:bg-gray-50 transition-colors"
          @click="ui.openNewGroupModal"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"
            />
          </svg>
          Novo grupo
        </button>
        <button
          class="flex-1 flex items-center justify-center gap-1.5 text-sm text-gray-700 border border-gray-200 rounded-lg py-1.5 hover:bg-gray-50 transition-colors"
          @click="ui.openContactsModal"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
            />
          </svg>
          Contatos
        </button>
      </div>

      <!-- Search -->
      <div class="px-3 py-2">
        <div class="relative">
          <svg
            class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Buscar"
            class="w-full pl-9 pr-3 py-1.5 text-sm bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-gray-300 border-0"
          />
        </div>
      </div>

      <!-- Conversation list -->
      <div class="flex-1 overflow-y-auto">
        <template v-if="loadingConversations">
          <div class="text-sm text-gray-400 text-center py-8">Carregando...</div>
        </template>
        <template v-else-if="filteredConversations.length === 0">
          <div class="text-sm text-gray-400 text-center py-8">Nenhuma conversa</div>
        </template>
        <!--  ConversationItem component for each conversation -->
        <ConversationItem
          v-for="item in filteredConversations"
          :key="item.id"
          :display-name="item.displayName"
          :preview="item.preview"
          :last-message-time="item.lastMessageTime"
          :active="currentConversationId === item.id"
          @select="selectConversation(item.id)"
        />
      </div>
    </aside>

    <!-- Right panel -->
    <main class="flex-1 flex flex-col overflow-hidden">
      <RouterView />
    </main>
  </div>

  <!-- Modals -->
  <ContactsModal
    v-if="ui.contactsModalOpen"
    @close="ui.closeContactsModal"
    @start-conversation="onStartPrivateConversation"
    @open-add-contact="ui.closeContactsModal(); addContactModalOpen = true"
  />
  <AddContactModal
    v-if="addContactModalOpen"
    @back="addContactModalOpen = false; ui.openContactsModal()"
    @added="addContactModalOpen = false; ui.openContactsModal()"
  />
  <NewGroupModal
    v-if="ui.newGroupModalOpen"
    @close="ui.closeNewGroupModal"
    @created="onGroupCreated"
  />
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { useUiStore } from '@/store/ui'
import { useAuthStore } from '@/store/auth'
import { conversationsApi, groupsApi, usersApi } from '@/services/api'
import ConversationItem from '@/components/ConversationItem.vue'
import ContactsModal from '@/components/ContactsModal.vue'
import NewGroupModal from '@/components/NewGroupModal.vue'
import AddContactModal from '@/components/AddContactModal.vue'

const ui = useUiStore()
const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

const queryClient = useQueryClient()
const searchQuery = ref('')
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const addContactModalOpen = ref(false)

const currentConversationId = computed(() => route.params.id as string | undefined)

const { data: conversations, isPending: loadingConversations } = useQuery({
  queryKey: ['conversations'],
  queryFn: () => conversationsApi.list(),
  enabled: computed(() => !!auth.user),
})

const { data: groups } = useQuery({
  queryKey: ['groups'],
  queryFn: () => groupsApi.list(),
  enabled: computed(() => !!auth.user),
})

const { data: users } = useQuery({
  queryKey: ['users'],
  queryFn: () => usersApi.list(),
  enabled: computed(() => !!auth.user),
})

const enrichedConversations = computed(() => {
  if (!conversations.value) return []
  const groupsMap = new Map((groups.value ?? []).map((g) => [g.conversation_id, g]))
  const usersMap = new Map((users.value ?? []).map((u) => [u.id, u]))
  return conversations.value
    .map((conv) => {
      const displayName =
        conv.type === 'group'
          ? (groupsMap.get(conv.id)?.name ?? 'Grupo')
          : (() => {
              const otherId = conv.member_ids.find((id) => id !== auth.user?.id)
              return otherId ? (usersMap.get(otherId)?.name ?? 'Usuário') : 'Conversa privada'
            })()
      const preview = conv.last_message?.content ?? ''
      const lastMessageTime = conv.last_message
        ? formatTime(conv.last_message.inserted_at)
        : undefined
      return {
        id: conv.id,
        type: conv.type,
        displayName,
        preview,
        lastMessageTime,
        _sortKey: conv.last_message?.inserted_at ?? '',
      }
    })
    .sort((a, b) => b._sortKey.localeCompare(a._sortKey))
})

const filteredConversations = computed(() => {
  if (!searchQuery.value) return enrichedConversations.value
  const q = searchQuery.value.toLowerCase()
  return enrichedConversations.value.filter((c) => c.displayName.toLowerCase().includes(q))
})

function formatTime(isoString: string): string {
  const date = new Date(isoString)

  if (Number.isNaN(date.getTime())) {
    return ''
  }

  const today = new Date()
  const yesterday = new Date(today)
  yesterday.setDate(today.getDate() - 1)

  if (date.toDateString() === today.toDateString()) {
    return date.toLocaleTimeString('pt-BR', {
      hour: '2-digit',
      minute: '2-digit',
    })
  }

  if (date.toDateString() === yesterday.toDateString()) {
    return 'Ontem'
  }

  return date.toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
  })
}

function selectConversation(id: string) {
  router.push({ name: 'conversation', params: { id } })
}

function onGroupCreated(conversationId: string) {
  ui.closeNewGroupModal()
  router.push({ name: 'conversation', params: { id: conversationId } })
}

async function onStartPrivateConversation(contactUserId: string) {
  if (!auth.user) return
  ui.closeContactsModal()
  const conversation = await conversationsApi.create({ type: 'private' })
  await Promise.all([
    conversationsApi.addMember(conversation.id, auth.user.id),
    conversationsApi.addMember(conversation.id, contactUserId),
  ])
  queryClient.invalidateQueries({ queryKey: ['conversations'] })
  router.push({ name: 'conversation', params: { id: conversation.id } })
}
</script>
