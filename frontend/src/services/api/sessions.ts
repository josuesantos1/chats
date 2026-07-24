import { api } from './client'
import type { User } from '@/types'

export const sessionsApi = {
  login: (username: string, password: string) =>
    api.post<{ data: User }>('/sessions', { username, password }).then((r) => r.data.data),
}
