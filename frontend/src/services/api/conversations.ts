import { api } from './client'
import type { Conversation, ConversationMember, Message } from '@/types'

export const conversationsApi = {
  list: () =>
    api.get<{ data: Conversation[] }>('/conversations').then((r) => r.data.data),
  create: (payload: { type: 'private' | 'group' }) =>
    api
      .post<{ data: Conversation }>('/conversations', { conversation: payload })
      .then((r) => r.data.data),
  messages: (id: string) =>
    api.get<{ data: Message[] }>(`/conversations/${id}/messages`).then((r) => r.data.data),
  members: (id: string) =>
    api
      .get<{ data: ConversationMember[] }>(`/conversations/${id}/members`)
      .then((r) => r.data.data),
  addMember: (id: string, userId: string) =>
    api
      .post<{ data: ConversationMember[] }>(`/conversations/${id}/members`, {
        member: { user_id: userId },
      })
      .then((r) => r.data.data),
}
