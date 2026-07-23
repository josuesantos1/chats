import { api } from './client'
import type { User } from '@/types'

export const sessionsApi = {
  login: (username: string) =>
    api.post<{ data: User }>('/sessions', { username }).then((r) => r.data.data),
}
