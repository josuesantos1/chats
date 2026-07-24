import { Socket } from 'phoenix'

let socket: Socket | null = null

export function getSocket(): Socket {
  if (!socket) {
    const apiUrl = (import.meta.env.VITE_API_URL as string | undefined) ?? 'http://localhost:9000/api'
    const socketUrl = apiUrl.replace(/^http/, 'ws').replace(/\/api$/, '/socket')

    socket = new Socket(socketUrl, {
      params: () => {
        const userId = localStorage.getItem('user_id')
        return userId ? { user_id: userId } : {}
      },
    })
    socket.connect()
  }
  return socket
}

export function disconnectSocket() {
  socket?.disconnect()
  socket = null
}
