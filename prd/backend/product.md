# Product Requirements Document (PRD)

# Real-Time Messaging Application - Backend

**Version:** 1.0

**Status:** Draft

**Owner:** Backend Engineering

**Technology Stack:** Elixir, Phoenix, PostgreSQL

---

# 1. Overview

## Purpose

Build the backend for a real-time messaging application that supports:

* Private conversations
* Group conversations
* Contact management
* Persistent message history
* Real-time communication using WebSockets

The backend will expose REST APIs for resource management and Phoenix Channels for real-time messaging.

---

# 2. Goals

The system must allow users to:

* Manage contacts
* Start private conversations
* Create group conversations
* Send and receive messages
* View conversation history
* Receive new messages instantly without refreshing the application

---

# 3. Out of Scope

The following features are intentionally excluded from this project:

* Authentication
* Authorization
* User registration
* File uploads
* Voice messages
* Video calls
* Push notifications
* Message editing
* Message deletion
* Read receipts
* Presence tracking
* Search
* Typing indicators
* Mobile support

---

# 4. Functional Requirements

## FR-01 — Users

The system shall maintain registered users.

Each user contains:

* UUID
* Name
* Email
* Phone Number

---

## FR-02 — Contacts

Users can:

* Add contacts
* Remove contacts
* List contacts

A contact must always reference another registered user.

Duplicate contacts are not allowed.

---

## FR-03 — Private Conversations

A user can start a private conversation with one of their contacts.

If a conversation already exists between two users, it must be reused instead of creating a duplicate.

A private conversation always contains exactly two participants.

---

## FR-04 — Groups

Users can create groups.

Each group contains:

* Name
* Creator
* Members

All members must be selected from the creator's contact list.

Each group is associated with exactly one conversation.

---

## FR-05 — Messages

Users can send messages to:

* Private conversations
* Group conversations

Each message contains:

* UUID
* Conversation
* Author
* Message content
* Creation timestamp

Messages must be permanently stored.

---

## FR-06 — Conversation History

Users can retrieve the complete message history of a conversation.

Messages must be returned in chronological order.

---

## FR-07 — Real-Time Messaging

Whenever a new message is created:

1. The message is validated.
2. The message is persisted in PostgreSQL.
3. The server broadcasts the message to every connected participant.

Clients should receive new messages instantly.

---

# 5. Non-Functional Requirements

## NFR-01

Backend must be developed using:

* Elixir 1.20+
* Phoenix Framework

---

## NFR-02

Database:

* PostgreSQL 16+

---

## NFR-03

Communication protocol:

* REST APIs
* Phoenix Channels (WebSockets)

---

## NFR-04

Responses must be returned as JSON.

---

## NFR-05

The project should follow Phoenix Contexts architecture.

---

## NFR-06

Database integrity must be enforced using Ecto Changesets.

---

## NFR-07

Messages must always be persisted before broadcasting.

---

# 6. Architecture

## Contexts

### Accounts

Responsible for user management.

Responsibilities:

* Users
* User queries

---

### Contacts

Responsible for contact management.

Responsibilities:

* Add contact
* Remove contact
* List contacts

---

### Conversations

Responsible for conversations.

Responsibilities:

* Create private conversations
* Retrieve conversations

---

### Groups

Responsible for group management.

Responsibilities:

* Create groups
* Manage members

---

### Messages

Responsible for messaging.

Responsibilities:

* Persist messages
* Retrieve history

---

### Realtime

Responsible for WebSocket communication.

Responsibilities:

* Phoenix Channels
* Broadcasting messages

---

# 7. Data Model

## Users

| Field | Type   |
| ----- | ------ |
| id    | UUID   |
| name  | String |
| email | String |
| phone | String |

---

## Contacts

| Field      | Type |
| ---------- | ---- |
| id         | UUID |
| user_id    | UUID |
| contact_id | UUID |

---

## Conversations

| Field | Type            |
| ----- | --------------- |
| id    | UUID            |
| type  | private / group |

---

## Conversation Members

| Field           | Type |
| --------------- | ---- |
| id              | UUID |
| conversation_id | UUID |
| user_id         | UUID |

---

## Groups

| Field           | Type   |
| --------------- | ------ |
| id              | UUID   |
| conversation_id | UUID   |
| creator_id      | UUID   |
| name            | String |

---

## Messages

| Field           | Type      |
| --------------- | --------- |
| id              | UUID      |
| conversation_id | UUID      |
| author_id       | UUID      |
| content         | Text      |
| inserted_at     | Timestamp |

---

# 8. REST API

## Users

### GET

```http
GET /users
```

Returns all users.

---

## Contacts

### GET

```http
GET /contacts
```

Returns the user's contacts.

### POST

```http
POST /contacts
```

Adds a new contact.

### DELETE

```http
DELETE /contacts/{id}
```

Removes a contact.

---

## Conversations

### GET

```http
GET /conversations
```

Returns all conversations for the current user.

### POST

```http
POST /conversations/private
```

Creates or retrieves an existing private conversation.

---

## Groups

### GET

```http
GET /groups
```

Returns all groups.

### POST

```http
POST /groups
```

Creates a new group.

---

## Messages

### GET

```http
GET /conversations/{id}/messages
```

Returns the conversation history.

### POST

```http
POST /messages
```

Creates a new message.

---

# 9. WebSocket

## Endpoint

```text
/socket
```

---

## Channel

```text
conversation:{conversation_id}
```

---

## Client Events

### send_message

```json
{
  "conversation_id": "uuid",
  "author_id": "uuid",
  "content": "Hello!"
}
```

---

## Server Events

### new_message

```json
{
  "id": "uuid",
  "conversation_id": "uuid",
  "author_id": "uuid",
  "content": "Hello!",
  "inserted_at": "2026-07-21T18:30:00Z"
}
```

---

# 10. Message Flow

1. Client sends a message.
2. Server validates the payload.
3. Message is persisted.
4. Server broadcasts the event through the conversation channel.
5. Every connected participant immediately receives the new message.

---

# 11. Acceptance Criteria

The backend is considered complete when:

* Users can manage contacts.
* Private conversations can be created.
* Groups can be created.
* Messages are persisted successfully.
* Conversation history is returned in chronological order.
* Messages are delivered in real time.
* All REST endpoints return valid JSON responses.
* The application runs locally using PostgreSQL without additional infrastructure.

---

# 12. Future Enhancements

* JWT Authentication
* Authorization and permissions
* Online presence
* Typing indicators
* Read receipts
* Message editing
* Message deletion
* File attachments
* Media messages
* Search
* Pagination
* Push notifications
* Redis caching
* Rate limiting
* OpenTelemetry
* Distributed PubSub
* Horizontal scaling
* End-to-end encryption

mix phx.gen.json Conversations ConversationMember conversation_members  id:uuid  conversation:references:conversations  user:references:users