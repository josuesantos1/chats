# Chats

Aplicativo de mensagens em tempo real com suporte a conversas privadas e grupos.

### Considerações

- Ao rodar o projeto, serão criados 20 usuários com nomes aleatórios.
- Todos os usuários criados pelo seed terão o username de `user1` a `user20`.
- Todas as senhas dos usuários gerados pelo seed são `password`.

---

## Pré-requisitos (local)

- Elixir 1.17+
- PostgreSQL 16+
- Node.js 20+ e pnpm

## Pré-requisitos (com Docker)
- Docker

---

## Como rodar com Docker

**macOS / Linux:**

```bash
export SECRET_KEY_BASE=$(cd backend && mix phx.gen.secret)
docker compose up --build
```

**Windows (PowerShell):**

```powershell
$env:SECRET_KEY_BASE = "$(cd backend; mix phx.gen.secret)"
docker compose up --build
```

Aguarde o backend iniciar (ele roda as migrations e popula o seed automaticamente).
Acesse `http://localhost:5173`.

Para parar e remover os containers e volumes (banco de dados):

```bash
docker compose down -v
```

---

## Como rodar localmente

### Backend

```bash
cd backend
mix deps.get
mix ecto.setup          # cria banco, roda migrations e seeds
mix phx.server          # sobe na porta 9000
```

### Frontend

Em outro terminal:

```bash
cd frontend
pnpm install
pnpm dev                # sobe na porta 5173
```

Acesse `http://localhost:5173`.

---

## Funcionalidades

- [x] Registro de usuário
- [x] Login com username e senha
- [x] Listagem de usuários
- [x] Gerenciamento de contatos (adicionar, listar, remover)
- [x] Conversas privadas (1-para-1)
- [x] Criação de grupos com múltiplos membros
- [x] Informações do grupo (modal com membros e criador ao clicar no avatar do grupo)
- [x] Histórico de mensagens persistido
- [x] Mensagens em tempo real via WebSocket (Phoenix Channels)
- [x] Notificações de novas mensagens em conversas não abertas
- [x] Busca de mensagens dentro de uma conversa
- [x] Lista de conversas ordenada pela mensagem mais recente

---

## Decisões de design

### Decisões no Backend

- **Phoenix Channels** para mensagens em tempo real: cada conversa tem um canal `conversation:<id>`. O cliente entra no canal ao abrir uma conversa e recebe o evento `new_message` para todos na sala.
- **Autenticação por senha**: o login valida username e senha via bcrypt. Após autenticado, o `id` do usuário é enviado no header `x-user-id` em todas as requisições protegidas. O `AuthPlug` valida o ID em todas as rotas autenticadas. Optei por não usar JWT para manter a implementação simples, facilitando os testes da solução.
- **Estrutura de conversas unificada**: `Conversation` é o modelo central — tanto privadas quanto de grupo são do mesmo tipo, diferenciadas pelo campo `type`. Isso simplifica a listagem e o canal de WebSocket.
- **Separação Conversation/Group**: grupos têm um registro separado (`Group`) com nome e criador, vinculado a uma `Conversation` via `conversation_id`. Assim a lógica de mensagens não precisa saber se é grupo ou privado.
- **Elixir Release no Docker**: o build de produção usa `mix release`, gerando uma imagem mínima sem Elixir/Mix instalados. Migrations e seed rodam via `Backend.Release` antes de iniciar o servidor.

### Decisões no Frontend

- **TanStack Query** para cache de dados: todas as listas (conversas, grupos, usuários, contatos) são cacheadas e invalidadas pontualmente após mutações, evitando refetch desnecessário.
- **Local messages + WebSocket**: as mensagens já carregadas ficam em `localMessages` (ref local). Novas mensagens chegam pelo canal e são adicionadas localmente sem precisar refazer o fetch. Isso garante baixa latência visual.
- **oh-vue-icons** para ícones: biblioteca leve que permite registrar apenas os ícones usados.
- **nginx no Docker**: o frontend de produção é servido via `nginx:alpine` com `try_files` configurado para suportar o Vue Router em modo histórico.

---

## O que faria diferente com mais tempo

### Paginação de mensagens

O histórico atualmente é carregado integralmente ao abrir uma conversa. Para conversas muito grandes, utilizaria paginação baseada em cursor com carregamento incremental (infinite scroll), reduzindo consumo de memória e tempo de resposta.

### Cache

As mensagens são recuperadas diretamente do banco. Em um ambiente de produção, adicionaria uma camada de cache para reduzir latência e aliviar carga no banco de dados.

### Busca full-text

A busca de mensagens atualmente é feita no frontend sobre as mensagens já carregadas. Para grandes volumes de dados, utilizaria elastic ou Sonic para pesquisa indexada no servidor.

### CI/CD

Atualmente não há pipeline automatizada de testes e deploy. Implementaria uma pipeline com GitHub Actions para:

- **Backend**: rodar `mix ci`
- **Frontend**: rodar lint e testes de componentes com Vitest
- **Deploy**: build das imagens Docker e publicação automática em talvez fly.io
