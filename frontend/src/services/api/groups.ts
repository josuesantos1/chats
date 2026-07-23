import { api } from './client'
import type { Group } from '@/types'

export const groupsApi = {
  list: () => api.get<{ data: Group[] }>('/groups').then((r) => r.data.data),
  create: (payload: Omit<Group, 'id'>) =>
    api.post<{ data: Group }>('/groups', { group: payload }).then((r) => r.data.data),
  update: (id: string, payload: Partial<Omit<Group, 'id'>>) =>
    api.put<{ data: Group }>(`/groups/${id}`, { group: payload }).then((r) => r.data.data),
  delete: (id: string) => api.delete(`/groups/${id}`),
}
