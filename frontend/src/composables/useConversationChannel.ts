import { onUnmounted } from 'vue'
import type { Channel } from 'phoenix'
import { getSocket } from '@/services/socket'
import type { Message } from '@/types'

export function useConversationChannel(
  conversationId: string,
  onNewMessage: (msg: Message) => void,
) {
  let channel: Channel | null = null

  function join() {
    const socket = getSocket()
    channel = socket.channel(`conversation:${conversationId}`)

    channel.on('new_message', (payload: Message) => {
      onNewMessage(payload)
    })

    channel.join().receive('error', (err) => {
      console.error('Channel join error:', err)
    })
  }

  function sendMessage(payload: { conversation_id: string; author_id: string; content: string }) {
    return new Promise<Message>((resolve, reject) => {
      channel
        ?.push('send_message', payload)
        .receive('ok', (msg: Message) => resolve(msg))
        .receive('error', (err: unknown) => reject(err))
    })
  }

  function leave() {
    channel?.leave()
    channel = null
  }

  onUnmounted(leave)

  return { join, sendMessage, leave }
}
