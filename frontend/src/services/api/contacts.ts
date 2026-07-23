import { api } from './client'
import type { Contact } from '@/types'

export const contactsApi = {
  list: () => api.get<{ data: Contact[] }>('/contacts').then((r) => r.data.data),
  create: (payload: { user_id: string; contact_id: string }) =>
    api.post<{ data: Contact }>('/contacts', { contact: payload }).then((r) => r.data.data),
  delete: (id: string) => api.delete(`/contacts/${id}`),
}
