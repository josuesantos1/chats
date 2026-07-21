defmodule BackendWeb.MessageJSON do
  alias Backend.Messages.Message

  @doc """
  Renders a list of messages.
  """
  def index(%{messages: messages}) do
    %{data: for(message <- messages, do: data(message))}
  end

  @doc """
  Renders a single message.
  """
  def show(%{message: message}) do
    %{data: data(message)}
  end

  defp data(%Message{} = message) do
    %{
      id: message.id,
      content: message.content,
      author_id: message.author_id,
      conversation_id: message.conversation_id,
      inserted_at: message.inserted_at
    }
  end
end
