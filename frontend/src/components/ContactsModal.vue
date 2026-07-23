<template>
  <!-- Backdrop -->
  <div
    class="fixed inset-0 bg-black/40 flex items-center justify-center z-50"
    @click.self="$emit('close')"
  >
    <div class="bg-white rounded-2xl shadow-xl w-full max-w-md mx-4 flex flex-col max-h-[80vh]">
      <!-- Header -->
      <div class="flex items-center justify-between px-5 pt-5 pb-4">
        <h2 class="text-lg font-semibold text-gray-900">Contatos</h2>
        <div class="flex items-center gap-2">
          <button
            class="flex items-center gap-1.5 bg-gray-900 text-white text-sm font-medium px-3 py-1.5 rounded-lg hover:bg-gray-700 transition-colors"
            @click="addingContact = true"
          >
            <span class="text-base leading-none">+</span>
            Adicionar
          </button>
          <button class="text-gray-400 hover:text-gray-600 p-1" @click="$emit('close')">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>
      </div>

      <!-- Add contact form -->
      <div v-if="addingContact" class="px-5 pb-3">
        <div class="flex gap-2">
          <input
            v-model="searchUsername"
            type="text"
            placeholder="Username do contato"
            class="flex-1 text-sm px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-gray-900"
            @keyup.enter="handleAddContact"
          />
          <button
            class="text-sm px-3 py-2 bg-gray-900 text-white rounded-lg hover:bg-gray-700 transition-colors"
            :disabled="addLoading"
            @click="handleAddContact"
          >
            {{ addLoading ? '...' : 'Ok' }}
          </button>
          <button
            class="text-sm px-3 py-2 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
            @click="((addingContact = false), (searchUsername = ''))"
          >
            Cancelar
          </button>
        </div>
        <p v-if="addError" class="text-xs text-red-500 mt-1">{{ addError }}</p>
      </div>

      <!-- Search -->
      <div class="px-5 pb-3">
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
                class="text-gray-400 hover:text-blue-500 p-1 transition-colors mr-1"
                title="Iniciar conversa"
                @click="emit('startConversation', contact.id)"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.5"
                    d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                  />
                </svg>
              </button>
              <button
                class="text-gray-400 hover:text-red-500 p-1 transition-colors"
                @click="handleDelete(contact.contactId)"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.5"
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                  />
                </svg>
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
}>()

const auth = useAuthStore()
const queryClient = useQueryClient()

const searchQuery = ref('')
const addingContact = ref(false)
const searchUsername = ref('')
const addError = ref('')
const addLoading = ref(false)

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

async function handleAddContact() {
  if (!searchUsername.value.trim() || !auth.user) return
  addError.value = ''
  addLoading.value = true
  try {
    const allUsers = users.value ?? []
    const target = allUsers.find((u) => u.username === searchUsername.value.trim())
    if (!target) {
      addError.value = 'Usuário não encontrado.'
      return
    }
    if (target.id === auth.user.id) {
      addError.value = 'Você não pode se adicionar.'
      return
    }
    await contactsApi.create({ user_id: auth.user.id, contact_id: target.id })
    queryClient.invalidateQueries({ queryKey: ['contacts'] })
    addingContact.value = false
    searchUsername.value = ''
  } catch {
    addError.value = 'Erro ao adicionar contato.'
  } finally {
    addLoading.value = false
  }
}

async function handleDelete(contactId: string) {
  await contactsApi.delete(contactId)
  queryClient.invalidateQueries({ queryKey: ['contacts'] })
}
</script>
