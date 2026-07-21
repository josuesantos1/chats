defmodule Backend.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Messages` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "some content",
        id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Backend.Messages.create_message()

    message
  end
end
