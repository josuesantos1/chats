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
        id: "7488a646-e31f-11e4-aace-600308960662",
        type: "some type"
      })
      |> Backend.Conversations.create_conversation()

    conversation
  end
end
