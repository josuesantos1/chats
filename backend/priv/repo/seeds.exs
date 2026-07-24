alias Backend.Repo
alias Backend.Accounts
alias Backend.Contacts
alias Backend.Conversations
alias Backend.Groups
alias Backend.Messages

if Repo.aggregate(Backend.Accounts.User, :count) > 0 do
  IO.puts("Seed already ran, skipping.")
  System.halt(0)
end

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

defmodule Seeds.Helpers do
  def random_message do
    Enum.random([
      "Oi, tudo bem?",
      "Como você está?",
      "O que você acha disso?",
      "Vamos marcar algo essa semana?",
      "Pode me mandar o arquivo?",
      "Entendido, obrigado!",
      "Boa ideia!",
      "Não consigo agora, te falo mais tarde.",
      "Acabei de ver, vou responder em breve.",
      "Combinado!",
      "Me manda o link.",
      "Que horas você chega?",
      "Tá bom, até mais!",
      "Preciso de ajuda com uma coisa.",
      "Já resolveu o problema?",
      "Sim, pode confirmar.",
      "Ainda não vi, deixa eu checar.",
      "Perfeito, obrigado!",
      "Vou ver e te aviso.",
      "Legal, vamos fazer isso!",
      "Não sei, o que você acha?",
      "Pode ser, vamos tentar.",
      "Estou ocupado agora, depois conversamos.",
      "Valeu pela informação!",
      "Vamos nos encontrar no café?",
      "Você viu a última atualização?",
      "Estou animado para o projeto!",
      "Não se preocupe, tudo vai dar certo.",
      "Me avise quando estiver disponível.",
      "Ótimo, vamos em frente!",
      "Não entendi, pode explicar melhor?",
      "Sim, estou de acordo.",
      "Não, prefiro outra opção.",
      "Talvez possamos tentar outra abordagem.",
      "Estou com dúvidas sobre isso.",
      "Vamos discutir isso na reunião.",
      "Obrigado pelo feedback!",
      "Estou feliz com o progresso.",
      "Não tenho certeza, vou pesquisar.",
      "Vamos revisar isso juntos.",
      "Pode me enviar os detalhes?",
      "Estou confiante de que podemos resolver.",
      "Vamos manter contato.",
      "Estou disponível para uma chamada.",
      "Não se esqueça do prazo.",
      "Estou ansioso para a próxima etapa.",
      "Vamos celebrar quando terminar!",
      "Estou impressionado com o trabalho.",
      "Não se preocupe, vamos encontrar uma solução.",
      "Estou satisfeito com os resultados.",
      "Vamos continuar assim!",
      "Estou aberto a sugestões.",
      "Não tenho certeza, vamos discutir.",
      "Estou feliz em ajudar.",
      "Vamos manter o foco no objetivo."
    ])
  end

  def past_timestamp(days_ago, hour_offset \\ 0) do
    DateTime.utc_now()
    |> DateTime.add(-days_ago * 86_400 - hour_offset * 3600, :second)
    |> DateTime.truncate(:second)
  end
end

# ---------------------------------------------------------------------------
# 1. Create 10 users
# ---------------------------------------------------------------------------

usernames = [
  "Josue",
  "Izabella",
  "Gabriel",
  "Mariana",
  "Lucas",
  "Sofia",
  "Mateus",
  "Isabella",
  "Bruna",
  "Rafael",
  "Alice",
  "Bob",
  "Charlie",
  "David",
  "Frank",
  "Ivan",
  "Judy",
]

lastnames = [
  "Silva",
  "Souza",
  "Costa",
  "Oliveira",
  "Pereira",
  "Rodrigues",
  "Almeida",
  "Nascimento",
  "Lima",
  "Araújo",
  "Fernandes",
  "Carvalho",
  "Gomes",
  "Martins",
  "Ribeiro",
  "Mendes",
  "Barbosa",
]

users =
  Enum.map(1..20, fn i ->
    {:ok, user} =
      Accounts.create_user(%{
        name: "#{Enum.random(usernames)} #{Enum.random(lastnames)}",
        username: "user#{i}",
        email: "user#{i}@chat.com",
        password: "password"
      })

    user
  end)

IO.puts("Created #{length(users)} users")

# ---------------------------------------------------------------------------
# 2. Create contacts for each user (3–5 per user)
# ---------------------------------------------------------------------------

Enum.each(users, fn user ->
  others = Enum.reject(users, &(&1.id == user.id))
  contacts = Enum.take(Enum.shuffle(others), Enum.random(3..5))

  Enum.each(contacts, fn contact ->
    Contacts.create_contact(%{user_id: user.id, contact_id: contact.id})
  end)
end)

IO.puts("Created contacts")

# ---------------------------------------------------------------------------
# 3. Create 3–5 private conversations per user with random messages
# ---------------------------------------------------------------------------

created_private_pairs = :ets.new(:private_pairs, [:set, :private])

Enum.each(users, fn user ->
  others = Enum.reject(users, &(&1.id == user.id))
  chat_partners = Enum.take(Enum.shuffle(others), Enum.random(3..5))

  Enum.each(chat_partners, fn partner ->
    pair = Enum.sort([user.id, partner.id])

    unless :ets.member(created_private_pairs, pair) do
      :ets.insert(created_private_pairs, {pair, true})

      {:ok, conv} = Conversations.create_conversation(%{type: "private"})
      Conversations.add_conversation_member(%{conversation_id: conv.id, user_id: user.id})
      Conversations.add_conversation_member(%{conversation_id: conv.id, user_id: partner.id})

      # 1–7 days of messages
      days = Enum.random(1..7)

      Enum.each(0..(days - 1), fn day ->
        msgs_per_day = Enum.random(3..8)

        Enum.each(1..msgs_per_day, fn offset ->
          author = Enum.random([user, partner])
          ts = Seeds.Helpers.past_timestamp(days - day, msgs_per_day - offset)

          Repo.insert!(%Backend.Messages.Message{
            conversation_id: conv.id,
            author_id: author.id,
            content: Seeds.Helpers.random_message(),
            inserted_at: ts,
            updated_at: ts
          })
        end)
      end)
    end
  end)
end)

:ets.delete(created_private_pairs)
IO.puts("Created private conversations with messages")

# ---------------------------------------------------------------------------
# 4. Create 5 groups, each with 4–7 random members and messages
# ---------------------------------------------------------------------------

group_names = [
  "Projeto Alpha",
  "Time de Produto",
  "Geral",
  "Dev Squad",
  "Marketing",
  "Designers",
  "Suporte",
  "RH",
  "Financeiro",
  "Vendas"
]

Enum.each(group_names, fn name ->
  creator = Enum.random(users)

  members = [
    creator
    | Enum.take(Enum.shuffle(Enum.reject(users, &(&1.id == creator.id))), Enum.random(3..6))
  ]

  {:ok, conv} = Conversations.create_conversation(%{type: "group"})

  Enum.each(members, fn member ->
    Conversations.add_conversation_member(%{conversation_id: conv.id, user_id: member.id})
  end)

  Groups.create_group(%{
    name: name,
    creator_id: creator.id,
    conversation_id: conv.id
  })

  # 3–7 days of messages
  days = Enum.random(3..7)

  Enum.each(0..(days - 1), fn day ->
    msgs_per_day = Enum.random(4..10)

    Enum.each(1..msgs_per_day, fn offset ->
      author = Enum.random(members)
      ts = Seeds.Helpers.past_timestamp(days - day, msgs_per_day - offset)

      Repo.insert!(%Backend.Messages.Message{
        conversation_id: conv.id,
        author_id: author.id,
        content: Seeds.Helpers.random_message(),
        inserted_at: ts,
        updated_at: ts
      })
    end)
  end)
end)

IO.puts("Created 5 groups with messages")
IO.puts("Seed complete!")
IO.puts("")
IO.puts("Login with any of: user1, user2, ..., user10")
