<template>
  <div class="min-h-screen flex items-center justify-center bg-background">
    <div class="w-full max-w-sm space-y-6 p-8 border border-border rounded-lg">
      <div>
        <h2 class="text-2xl font-semibold">Create account</h2>
        <p class="text-sm text-muted-foreground mt-1">Fill in your details to get started</p>
      </div>
      <form class="space-y-4" @submit.prevent="onSubmit">
        <div class="space-y-1">
          <label class="text-sm font-medium" for="name">Name</label>
          <input
            id="name"
            v-model="form.name"
            type="text"
            class="w-full px-3 py-2 border border-input rounded-md text-sm bg-background focus:outline-none focus:ring-2 focus:ring-ring"
            required
          />
        </div>
        <div class="space-y-1">
          <label class="text-sm font-medium" for="email">Email</label>
          <input
            id="email"
            v-model="form.email"
            type="email"
            class="w-full px-3 py-2 border border-input rounded-md text-sm bg-background focus:outline-none focus:ring-2 focus:ring-ring"
            required
          />
        </div>
        <div class="space-y-1">
          <label class="text-sm font-medium" for="username">Username</label>
          <input
            id="username"
            v-model="form.username"
            type="text"
            class="w-full px-3 py-2 border border-input rounded-md text-sm bg-background focus:outline-none focus:ring-2 focus:ring-ring"
            required
          />
        </div>
        <button
          type="submit"
          class="w-full bg-primary text-primary-foreground py-2 rounded-md text-sm font-medium hover:opacity-90 transition-opacity"
          :disabled="loading"
        >
          {{ loading ? 'Creating…' : 'Create account' }}
        </button>
        <p v-if="error" class="text-sm text-destructive">{{ error }}</p>
      </form>
      <p class="text-sm text-center text-muted-foreground">
        Already have an account?
        <RouterLink to="/login" class="text-primary hover:underline">Sign in</RouterLink>
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/store/auth'
import { usersApi } from '@/services/api'

const router = useRouter()
const auth = useAuthStore()

const form = ref({ name: '', email: '', username: '' })
const loading = ref(false)
const error = ref('')

async function onSubmit() {
  loading.value = true
  error.value = ''
  try {
    const user = await usersApi.create(form.value)
    auth.setUser(user)
    router.push('/')
  } catch {
    error.value = 'Something went wrong. Try again.'
  } finally {
    loading.value = false
  }
}
</script>
