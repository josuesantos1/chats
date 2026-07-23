defmodule BackendWeb.ConversationJSON do
  alias Backend.Conversations.Conversation

  @doc """
  Renders a list of conversations.
  """
  def index(%{conversations: conversations, last_messages: last_messages}) do
    %{data: for(conversation <- conversations, do: data(conversation, Map.get(last_messages, conversation.id)))}
  end

  @doc """
  Renders a single conversation.
  """
  def show(%{conversation: conversation}) do
    %{data: data(conversation)}
  end

  def members(%{members: members}) do
    %{data: for(m <- members, do: %{user_id: m.user_id})}
  end

  defp data(%Conversation{} = conversation, last_message \\ nil) do
    member_ids =
      case conversation.conversation_members do
        %Ecto.Association.NotLoaded{} -> []
        members -> Enum.map(members, & &1.user_id)
      end

    %{
      id: conversation.id,
      type: conversation.type,
      member_ids: member_ids,
      last_message:
        if last_message do
          %{content: last_message.content, inserted_at: last_message.inserted_at}
        end
    }
  end
end
