defmodule Backend.ConversationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Conversations` context.
  """

  @doc """
  Generate a conversation.
  """
  def conversation_fixture(attrs \\ %{}) do
    {:ok, conversation} =
      attrs
      |> Enum.into(%{
        type: "private"
      })
      |> Backend.Conversations.create_conversation()

    conversation
  end
end
