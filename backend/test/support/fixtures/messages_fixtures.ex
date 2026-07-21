defmodule Backend.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Messages` context.
  """

  import Backend.AccountsFixtures
  import Backend.ConversationsFixtures

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    user = user_fixture()
    conversation = conversation_fixture()

    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "some content",
        author_id: user.id,
        conversation_id: conversation.id
      })
      |> Backend.Messages.create_message()

    message
  end
end
