import { api } from './client'
import type { Message } from '@/types'

export const messagesApi = {
  create: (payload: { content: string; author_id: string; conversation_id: string }) =>
    api.post<{ data: Message }>('/messages', { message: payload }).then((r) => r.data.data),
}
