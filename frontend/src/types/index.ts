export interface User {
  id: string
  name: string
  email: string
  username: string
}

export interface Contact {
  id: string
  user_id: string
  contact_id: string
}

export interface Conversation {
  id: string
  type: 'private' | 'group'
}

export interface ConversationMember {
  user_id: string
}

export interface Group {
  id: string
  name: string
  creator_id: string
  conversation_id: string
}

export interface Message {
  id: string
  content: string
  author_id: string
  conversation_id: string
  inserted_at: string
}
