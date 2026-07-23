defmodule BackendWeb.ConversationJSON do
  alias Backend.Conversations.Conversation

  @doc """
  Renders a list of conversations.
  """
  def index(%{conversations: conversations}) do
    %{data: for(conversation <- conversations, do: data(conversation))}
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

  defp data(%Conversation{} = conversation) do
    member_ids =
      case conversation.conversation_members do
        %Ecto.Association.NotLoaded{} -> []
        members -> Enum.map(members, & &1.user_id)
      end

    %{
      id: conversation.id,
      type: conversation.type,
      member_ids: member_ids
    }
  end
end
