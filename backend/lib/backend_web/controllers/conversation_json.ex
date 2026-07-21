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

  defp data(%Conversation{} = conversation) do
    %{
      id: conversation.id,
      id: conversation.id,
      type: conversation.type
    }
  end
end
