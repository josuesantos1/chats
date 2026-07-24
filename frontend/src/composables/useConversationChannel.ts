import { ref, watch, onUnmounted } from 'vue'
import type { Ref } from 'vue'
import { getSocket } from '@/services/socket'
import type { Message } from '@/types'

export function useConversationChannel(
  conversationId: Ref<string>,
  onMessage: (msg: Message, received: boolean) => void,
) {
  const activeChannel = ref<ReturnType<ReturnType<typeof getSocket>['channel']> | null>(null)

  watch(
    conversationId,
    (newId, oldId) => {
      if (oldId && activeChannel.value) {
        activeChannel.value.leave()
        activeChannel.value = null
      }
      if (!newId) return
      const channel = getSocket().channel(`conversation:${newId}`)
      channel.on('new_message', (payload: Message) => onMessage(payload, true))
      channel.join().receive('error', (err: unknown) => console.error('Channel join error:', err))
      activeChannel.value = channel
    },
    { immediate: true },
  )

  onUnmounted(() => {
    activeChannel.value?.leave()
    activeChannel.value = null
  })

  function push(event: string, payload: object): Promise<Message> {
    return new Promise((resolve, reject) => {
      activeChannel.value
        ?.push(event, payload)
        .receive('ok', (m: Message) => resolve(m))
        .receive('error', (err: unknown) => reject(err))
    })
  }

  return { push, activeChannel }
}
