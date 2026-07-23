<template>
  <div
    class="fixed inset-0 bg-black/40 flex items-center justify-center z-50"
    @click.self="$emit('back')"
  >
    <div class="bg-white rounded-2xl shadow-xl w-full max-w-md mx-4">
      <!-- Header -->
      <div class="flex items-center px-5 pt-5 pb-4">
        <button
          class="text-gray-400 hover:text-gray-600 p-1 border rounded-lg shrink-0"
          @click="$emit('back')"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-5 w-5"
            viewBox="0 0 20 20"
            fill="currentColor"
          >
            <path
              fill-rule="evenodd"
              d="M7.707 14.707a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l2.293 2.293a1 1 0 010 1.414z"
              clip-rule="evenodd"
            />
          </svg>
        </button>
        <div class="mx-3">
          <h2 class="text-lg font-semibold text-gray-900">Adicionar contato</h2>
          <p class="text-sm text-gray-500">Informe o @usuário que deseja adicionar</p>
        </div>
      </div>

      <!-- Form -->
      <div class="px-5 pb-6">
        <label class="block text-sm font-medium text-gray-700 mb-1.5">Usuário</label>
        <div class="flex gap-2">
          <div
            class="flex-1 flex items-center border-2 rounded-lg px-3 py-2 transition-colors"
            :class="
              status === 'error' ? 'border-red-400' : 'border-gray-200 focus-within:border-gray-400'
            "
          >
            <span class="text-gray-400 text-sm select-none">@</span>
            <input
              ref="inputRef"
              v-model="username"
              type="text"
              class="flex-1 text-sm focus:outline-none ml-0.5"
              @keyup.enter="handleAdd"
            />
          </div>
          <button
            class="px-4 py-2 bg-zinc-900 text-white text-sm font-medium rounded-lg hover:bg-zinc-700 transition-colors disabled:opacity-50 shrink-0"
            :disabled="loading || !username.trim()"
            @click="handleAdd"
          >
            Adicionar
          </button>
        </div>

        <!-- Success -->
        <div
          v-if="status === 'success'"
          class="mt-3 flex items-start gap-3 bg-green-50 border border-green-200 rounded-xl px-4 py-3"
        >
          <span
            class="shrink-0 mt-0.5 w-5 h-5 rounded-full bg-green-500 flex items-center justify-center"
          >
            <svg class="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="3"
                d="M5 13l4 4L19 7"
              />
            </svg>
          </span>
          <div>
            <p class="text-sm font-semibold text-green-700">Contato adicionado</p>
            <p class="text-xs text-green-600 mt-0.5">
              {{ addedName }} (@{{ addedUsername }}) entrou na sua lista.
            </p>
          </div>
        </div>

        <!-- Error -->
        <div
          v-if="status === 'error'"
          class="mt-3 flex items-start gap-3 bg-red-50 border border-red-200 rounded-xl px-4 py-3"
        >
          <span
            class="shrink-0 mt-0.5 w-5 h-5 rounded-full bg-red-500 flex items-center justify-center"
          >
            <svg class="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="3"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </span>
          <div>
            <p class="text-sm font-semibold text-red-700">Usuário não encontrado</p>
            <p class="text-xs text-red-600 mt-0.5">
              Nenhum usuário com @{{ username }} existe no sistema.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { useAuthStore } from '@/store/auth'
import { contactsApi, usersApi } from '@/services/api'

const emit = defineEmits<{
  back: []
  added: []
}>()

const auth = useAuthStore()
const queryClient = useQueryClient()

const inputRef = ref<HTMLInputElement | null>(null)
const username = ref('')
const loading = ref(false)
const status = ref<'idle' | 'success' | 'error'>('idle')
const addedName = ref('')
const addedUsername = ref('')

const { data: users } = useQuery({
  queryKey: ['users'],
  queryFn: () => usersApi.list(),
})

onMounted(() => inputRef.value?.focus())

async function handleAdd() {
  const q = username.value.trim()
  if (!q || !auth.user) return
  status.value = 'idle'
  loading.value = true
  try {
    const target = (users.value ?? []).find((u) => u.username === q)
    if (!target || target.id === auth.user.id) {
      status.value = 'error'
      return
    }
    await contactsApi.create({ user_id: auth.user.id, contact_id: target.id })
    queryClient.invalidateQueries({ queryKey: ['contacts'] })
    addedName.value = target.name
    addedUsername.value = target.username
    status.value = 'success'
    username.value = ''
    emit('added')
  } catch {
    status.value = 'error'
  } finally {
    loading.value = false
  }
}
</script>
