defmodule BackendWeb.ConversationChannel do
  @moduledoc """
  The ConversationChannel module handles real-time communication for conversations in the chat application. It allows users to join conversation channels and send messages, which are then broadcasted to all participants in the conversation.
  """

  use BackendWeb, :channel

  alias Backend.Messages

  @impl true
  def join("conversation:" <> _conversation_id, _params, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in(
        "send_message",
        %{"conversation_id" => conversation_id, "author_id" => author_id, "content" => content},
        socket
      ) do
    attrs = %{
      conversation_id: conversation_id,
      author_id: author_id,
      content: content
    }

    case Messages.create_message(attrs) do
      {:ok, message} ->
        broadcast!(socket, "new_message", %{
          id: message.id,
          conversation_id: message.conversation_id,
          author_id: message.author_id,
          content: message.content,
          inserted_at: message.inserted_at
        })

        {:noreply, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: format_errors(changeset)}}, socket}
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
