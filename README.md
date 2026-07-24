# Chat — Teste Prático Full-Stack (Elixir + TypeScript)

Aplicativo de mensagens em tempo real com suporte a conversas privadas e grupos.

### Considerações
```
- Ao rodar o projeto, sera criado 20 usuários com nomes aleatórios.
- Todos usuarios criados por seed terão o username de user1 a user20.
- Todas as senhas dos usuários gerados pelo seed são `password`.

```

## Pré-requisitos

- Elixir 1.17+
- PostgreSQL 16+
- Node.js 20+ e pnpm

## Como rodar com Docker

```bash
docker compose up --build
```

Aguarde o backend iniciar (ele cria o banco e popula o seed).
Acesse `http://localhost:5173`.

## Como rodar localmente

### Backend

```bash
cd backend
mix deps.get
mix ecto.setup          # cria banco, roda migrations e seeds
mix phx.server          # sobe na porta 9000
```

### Frontend
em outro terminal
```bash
cd frontend
pnpm install
pnpm dev                # sobe na porta 5173
```

Acesse `http://localhost:5173`. O seed cria 20 usuários para testes.

## Decisões de design

### Decisões no Backend

- **Phoenix Channels** para mensagens em tempo real: cada conversa tem um canal `conversation:<id>`. O cliente entra no canal ao abrir uma conversa e recebe o evento `new_message` para todos na sala.
- **Autenticação por senha**: o login valida username e senha via bcrypt. Após autenticado, o `id` do usuário é enviado no header `x-user-id` em todas as requisições protegidas. O `AuthPlug` valida o ID em todas as rotas autenticadas. Optei por não usar JWT para manter a implementação simples, facilitando os testes da solução.
- **Estrutura de conversas unificada**: `Conversation` é o modelo central — tanto privadas quanto de grupo são do mesmo tipo, diferenciadas pelo campo `type`. Isso simplifica a listagem e o canal de WebSocket.
- **Separação Conversation/Group**: grupos têm um registro separado (`Group`) com nome e criador, vinculado a uma `Conversation` via `conversation_id`. Assim a lógica de mensagens não precisa saber se é grupo ou privado.

### Decisões no Frontend

- **TanStack Query** para cache de dados: todas as listas (conversas, grupos, usuários, contatos) são cacheadas e invalidadas pontualmente após mutações, evitando refetch desnecessário.
- **Local messages + WebSocket**: as mensagens já carregadas ficam em `localMessages` (ref local). Novas mensagens chegam pelo canal e são adicionadas localmente sem precisar refazer o fetch. Isso garante baixa latência visual.
- **oh-vue-icons** para ícones: biblioteca leve que permite registrar apenas os ícones usados.

## O que faria diferente com mais tempo

### Paginação de mensagens

O histórico atualmente é carregado integralmente ao abrir uma conversa. Para conversas muito grandes, utilizaria paginação baseada em cursor com carregamento incremental (infinite scroll), reduzindo consumo de memória e tempo de resposta.

### Testes

Implementaria testes unitários e de integração utilizando ExUnit e Ecto Sandbox no backend, além de testes de componentes com Vitest no frontend para aumentar a confiabilidade da aplicação.

### Cache

As mensagens são recuperadas diretamente do banco. Em um ambiente de produção, adicionaria uma camada de cache para reduzir latência e aliviar carga no banco de dados.

### Busca

A busca de mensagens atualmente dependeria de consultas SQL. Para grandes volumes de dados, utilizaria Elastc ou Sonic para pesquisa.

## Funcionalidades

- [x] Login
- [x] Criação de usuario
- [x] Listagem de usuários
- [x] Gerenciamento de contatos
- [x] Conversas privadas
- [x] Criação de grupos
- [x] Histórico persistido
- [x] Mensagens em tempo real
- [x] Seed com usuários
- [x] Docker Compose
