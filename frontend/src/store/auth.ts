import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/types'

export const useAuthStore = defineStore('auth', () => {
  const stored = localStorage.getItem('user')
  const user = ref<User | null>(stored ? (JSON.parse(stored) as User) : null)

  const isAuthenticated = computed(() => user.value !== null)

  function setUser(u: User) {
    user.value = u
    localStorage.setItem('user_id', u.id)
    localStorage.setItem('user', JSON.stringify(u))
  }

  function logout() {
    user.value = null
    localStorage.removeItem('user_id')
    localStorage.removeItem('user')
  }

  return { user, isAuthenticated, setUser, logout }
})
