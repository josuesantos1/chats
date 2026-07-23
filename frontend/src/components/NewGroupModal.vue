<template>
  <div
    class="fixed inset-0 bg-black/40 flex items-center justify-center z-50"
    @click.self="$emit('close')"
  >
    <div class="bg-white rounded-2xl shadow-xl w-full max-w-md mx-4">
      <!-- Header -->
      <div class="flex items-center justify-between px-5 pt-5 pb-4">
        <h2 class="text-lg font-semibold text-gray-900">Novo grupo</h2>
        <button class="text-gray-400 hover:text-gray-600 p-1" @click="$emit('close')">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <div class="px-5 pb-5 space-y-4">
        <!-- Group name -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Nome do grupo</label>
          <input
            v-model="groupName"
            type="text"
            placeholder="Ex: Time de Produto"
            class="w-full text-sm px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-gray-900"
          />
        </div>

        <!-- Members -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Participantes</label>
          <div class="relative mb-2">
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
              v-model="memberSearch"
              type="text"
              placeholder="Buscar contato"
              class="w-full pl-9 pr-3 py-2 text-sm bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-gray-900 border-0"
            />
          </div>

          <!-- Selected members -->
          <div v-if="selectedMembers.length > 0" class="flex flex-wrap gap-2 mb-2">
            <div
              v-for="m in selectedMembers"
              :key="m.id"
              class="flex items-center gap-1 bg-gray-100 rounded-full px-2 py-1 text-xs"
            >
              {{ m.name }}
              <button class="text-gray-400 hover:text-gray-700" @click="removeMember(m.id)">
                ×
              </button>
            </div>
          </div>

          <!-- Contact list -->
          <div class="max-h-48 overflow-y-auto border border-gray-100 rounded-lg">
            <div
              v-for="contact in filteredContacts"
              :key="contact.id"
              class="flex items-center gap-3 px-3 py-2 hover:bg-gray-50 cursor-pointer"
              :class="{ 'opacity-40 pointer-events-none': isSelected(contact.id) }"
              @click="addMember(contact)"
            >
              <UserAvatar :name="contact.name" size="sm" />
              <div>
                <p class="text-sm text-gray-900">{{ contact.name }}</p>
                <p class="text-xs text-gray-400">@{{ contact.username }}</p>
              </div>
            </div>
            <div
              v-if="filteredContacts.length === 0"
              class="text-sm text-gray-400 text-center py-4"
            >
              Nenhum contato encontrado
            </div>
          </div>
        </div>

        <p v-if="error" class="text-xs text-red-500">{{ error }}</p>

        <div class="flex gap-2 pt-1">
          <button
            class="flex-1 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50 transition-colors"
            @click="$emit('close')"
          >
            Cancelar
          </button>
          <button
            class="flex-1 py-2 bg-gray-900 text-white rounded-lg text-sm font-medium hover:bg-gray-700 transition-colors disabled:opacity-50"
            :disabled="loading || !groupName.trim() || selectedMembers.length === 0"
            @click="handleCreate"
          >
            {{ loading ? 'Criando...' : 'Criar grupo' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { useAuthStore } from '@/store/auth'
import { contactsApi, usersApi, groupsApi, conversationsApi } from '@/services/api'
import UserAvatar from './UserAvatar.vue'

const emit = defineEmits<{
  close: []
  created: [conversationId: string]
}>()

const auth = useAuthStore()
const queryClient = useQueryClient()

const groupName = ref('')
const memberSearch = ref('')
const selectedMembers = ref<{ id: string; name: string; username: string }[]>([])
const error = ref('')
const loading = ref(false)

const { data: contacts } = useQuery({
  queryKey: ['contacts'],
  queryFn: () => contactsApi.list(),
})

const { data: users } = useQuery({
  queryKey: ['users'],
  queryFn: () => usersApi.list(),
})

const myContacts = computed(() => {
  if (!contacts.value || !users.value || !auth.user) return []
  const usersMap = new Map(users.value.map((u) => [u.id, u]))
  return contacts.value
    .filter((c) => c.user_id === auth.user!.id)
    .map((c) => {
      const user = usersMap.get(c.contact_id)
      return user ? { id: user.id, name: user.name, username: user.username } : null
    })
    .filter(Boolean) as { id: string; name: string; username: string }[]
})

const filteredContacts = computed(() => {
  const q = memberSearch.value.toLowerCase()
  return myContacts.value.filter(
    (c) => !q || c.name.toLowerCase().includes(q) || c.username.toLowerCase().includes(q),
  )
})

function isSelected(id: string) {
  return selectedMembers.value.some((m) => m.id === id)
}

function addMember(contact: { id: string; name: string; username: string }) {
  if (!isSelected(contact.id)) {
    selectedMembers.value.push(contact)
  }
}

function removeMember(id: string) {
  selectedMembers.value = selectedMembers.value.filter((m) => m.id !== id)
}

async function handleCreate() {
  if (!groupName.value.trim() || !auth.user) return
  error.value = ''
  loading.value = true
  try {
    const conversation = await conversationsApi.create({ type: 'group' })
    await groupsApi.create({
      name: groupName.value.trim(),
      creator_id: auth.user.id,
      conversation_id: conversation.id,
    })
    // Add all members (including self)
    const memberIds = [auth.user.id, ...selectedMembers.value.map((m) => m.id)]
    await Promise.all(memberIds.map((uid) => conversationsApi.addMember(conversation.id, uid)))
    queryClient.invalidateQueries({ queryKey: ['conversations'] })
    queryClient.invalidateQueries({ queryKey: ['groups'] })
    emit('created', conversation.id)
  } catch {
    error.value = 'Erro ao criar grupo.'
  } finally {
    loading.value = false
  }
}
</script>
