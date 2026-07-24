<template>
  <!-- Backdrop -->
  <div
    class="fixed inset-0 bg-black/40 flex items-center justify-center z-50"
    @click.self="$emit('close')"
  >
    <div class="bg-white rounded-2xl shadow-xl w-full max-w-md mx-4 flex flex-col max-h-[80vh]">
      <!-- Header -->
      <div class="flex items-center justify-start px-5 pt-5 pb-4">
        <button
          class="text-gray-400 hover:text-gray-600 p-1 border rounded-lg"
          @click="$emit('close')"
        >
          <v-icon name="hi-solid-arrow-left" class="h-5 w-5" />
        </button>
        <div class="mx-2 flex-1">
          <h2 class="text-lg font-semibold text-gray-900">contatos</h2>
        </div>
        <button
          class="flex items-center gap-1.5 text-sm text-white bg-zinc-900 rounded-lg px-3 py-1.5 hover:bg-zinc-700 transition-colors shrink-0"
          @click="$emit('openAddContact')"
        >
          <v-icon name="hi-plus" class="w-4 h-4" />
          Novo contato
        </button>
      </div>

      <!-- Search -->
      <div class="px-5 pb-3">
        <div class="relative">
          <v-icon name="hi-search" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Buscar contato"
            class="w-full pl-9 pr-3 py-2 text-sm bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-gray-900 border-0"
          />
        </div>
      </div>

      <!-- Contact list -->
      <div class="flex-1 overflow-y-auto px-5 pb-5">
        <template v-if="loading">
          <div class="text-sm text-gray-400 text-center py-8">Carregando...</div>
        </template>
        <template v-else-if="groupedContacts.length === 0">
          <div class="text-sm text-gray-400 text-center py-8">Nenhum contato encontrado</div>
        </template>
        <template v-else>
          <div v-for="group in groupedContacts" :key="group.letter" class="mb-2">
            <div class="text-xs font-semibold text-gray-400 py-2">{{ group.letter }}</div>
            <div
              v-for="contact in group.contacts"
              :key="contact.id"
              class="flex items-center gap-3 py-2"
            >
              <UserAvatar :name="contact.username" size="sm" />
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-gray-900">{{ contact.name }}</p>
                <p class="text-xs text-gray-400">@{{ contact.username }}</p>
              </div>
              <button
                class="text-gray-400 hover:text-red-500 py-1 px-2 transition-colors rounded-md border"
                @click="handleDelete(contact.contactId)"
              >
                <v-icon name="hi-trash" class="w-5 h-5" />
              </button>
            </div>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { useAuthStore } from '@/store/auth'
import { contactsApi, usersApi } from '@/services/api'
import UserAvatar from './UserAvatar.vue'

const emit = defineEmits<{
  close: []
  startConversation: [contactUserId: string]
  openAddContact: []
}>()

const auth = useAuthStore()
const queryClient = useQueryClient()

const searchQuery = ref('')

const { data: contacts, isPending: loadingContacts } = useQuery({
  queryKey: ['contacts'],
  queryFn: () => contactsApi.list(),
})

const { data: users, isPending: loadingUsers } = useQuery({
  queryKey: ['users'],
  queryFn: () => usersApi.list(),
})

const loading = computed(() => loadingContacts.value || loadingUsers.value)

const myContacts = computed(() => {
  if (!contacts.value || !users.value || !auth.user) return []
  const usersMap = new Map(users.value.map((u) => [u.id, u]))
  return contacts.value
    .filter((c) => c.user_id === auth.user!.id)
    .map((c) => {
      const user = usersMap.get(c.contact_id)
      return user
        ? { id: user.id, name: user.name, username: user.username, contactId: c.id }
        : null
    })
    .filter(Boolean) as { id: string; name: string; username: string; contactId: string }[]
})

const filteredContacts = computed(() => {
  if (!searchQuery.value) return myContacts.value
  const q = searchQuery.value.toLowerCase()
  return myContacts.value.filter(
    (c) => c.name.toLowerCase().includes(q) || c.username.toLowerCase().includes(q),
  )
})

const groupedContacts = computed(() => {
  const sorted = [...filteredContacts.value].sort((a, b) => a.name.localeCompare(b.name))
  const groups: { letter: string; contacts: typeof sorted }[] = []
  for (const contact of sorted) {
    const letter = contact.name[0].toUpperCase()
    const existing = groups.find((g) => g.letter === letter)
    if (existing) {
      existing.contacts.push(contact)
    } else {
      groups.push({ letter, contacts: [contact] })
    }
  }
  return groups
})

async function handleDelete(contactId: string) {
  await contactsApi.delete(contactId)
  queryClient.invalidateQueries({ queryKey: ['contacts'] })
}
</script>
