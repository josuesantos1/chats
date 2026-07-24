import { api } from './client'
import type { User } from '@/types'

export const usersApi = {
  list: () => api.get<{ data: User[] }>('/users').then((r) => r.data.data),
  get: (id: string) => api.get<{ data: User }>(`/users/${id}`).then((r) => r.data.data),
  get_by_username: (username: string) =>
    api.get<{ data: User }>(`/users/${username}/username/`).then((r) => r.data.data),
  create: (payload: Omit<User, 'id'>) =>
    api.post<{ data: User }>('/users', { user: payload }).then((r) => r.data.data),
  update: (id: string, payload: Partial<Omit<User, 'id'>>) =>
    api.put<{ data: User }>(`/users/${id}`, { user: payload }).then((r) => r.data.data),
  delete: (id: string) => api.delete(`/users/${id}`),
}
