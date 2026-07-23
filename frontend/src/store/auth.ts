import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/types'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)

  const isAuthenticated = computed(() => user.value !== null)

  function setUser(u: User) {
    user.value = u
    localStorage.setItem('user_id', u.id)
  }

  function logout() {
    user.value = null
    localStorage.removeItem('user_id')
  }

  return { user, isAuthenticated, setUser, logout }
})
